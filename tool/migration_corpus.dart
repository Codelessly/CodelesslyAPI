// The schema-3 migration over a corpus of schema-2 documents: every document
// migrates without throwing, validates with no new errors, and re-encodes
// stably (migrate → encode → decode → encode is a fixed point); the
// aggregated MigrationReport is written as Markdown.
//
//   dart run tool/migration_corpus.dart <file|dir>... [--baseline-errors errors.json] [--markdown out.md] [--strip prefix]
//
// --baseline-errors: per document (`file#pointer`), the error codes and
// counts the schema-2 validator reported (written by the same walk with the
// previous release); a code whose count grows is a new error. --strip
// removes a prefix from the file names in the report.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';

void main(List<String> args) {
  String? option(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final options = {'--baseline-errors', '--markdown', '--strip'};
  final inputs = [
    for (var i = 0; i < args.length; i++)
      if (!args[i].startsWith('--') && (i == 0 || !options.contains(args[i - 1]))) args[i],
  ];
  final baselinePath = option('--baseline-errors');
  final baseline = baselinePath == null ? null : (jsonDecode(File(baselinePath).readAsStringSync()) as Map).cast<String, Object?>();
  final strip = option('--strip') ?? '';
  final files = <File>[
    for (final p in inputs)
      if (FileSystemEntity.isDirectorySync(p))
        ...Directory(p).listSync(recursive: true).whereType<File>().where((f) =>
            f.path.endsWith('.json') && !f.path.contains('/node_modules/') && !f.path.contains('/.dart_tool/') && !f.path.contains('/build/'))
      else
        File(p),
  ]..sort((a, b) => a.path.compareTo(b.path));

  final report = MigrationReport();
  var documents = 0, migrated = 0;
  // The size of the schema-2 documents, encoded compactly, before and after.
  var bytesBefore = 0, bytesAfter = 0;
  final failures = <String>[];
  final newErrors = <String>[];
  for (final f in files) {
    Object? json;
    try {
      json = jsonDecode(f.readAsStringSync());
    } catch (_) {
      continue;
    }
    final name = f.path.startsWith(strip) ? f.path.substring(strip.length) : f.path;
    void walk(Object? v, String at) {
      if (isLayoutDocumentJson(v)) {
        documents++;
        final key = '${f.path}#$at';
        report.document = '$name${at.isEmpty ? '' : '#$at'}';
        final doc = readMap(v)!;
        Json out;
        try {
          out = migrate2to3(doc, report: report);
        } catch (e) {
          failures.add('$key: migrate threw $e');
          return;
        }
        if (schemaOf(doc) < 3) {
          migrated++;
          bytesBefore += utf8.encode(jsonEncode(doc)).length;
          bytesAfter += utf8.encode(jsonEncode(out)).length;
        }
        // Idempotent: again is the same.
        if (!identical(migrate2to3(out), out)) failures.add('$key: a schema-3 document changed when migrated again');
        // A fixed point: encode → decode → encode.
        final e1 = LayoutDocument.fromJson(out, catalog: standardCatalog).toJson();
        final e2 = LayoutDocument.fromJson(e1, catalog: standardCatalog).toJson();
        if (jsonEncode(e1) != jsonEncode(e2)) failures.add('$key: re-encoding is not a fixed point');
        // No new errors.
        final counts = <String, int>{};
        for (final d in validateDocument(out)) {
          if (d.isError) counts[d.code.name] = (counts[d.code.name] ?? 0) + 1;
        }
        final before = (readMap(baseline?[key]) ?? const <String, Object?>{});
        for (final e in counts.entries) {
          final was = readInt(before[e.key]) ?? 0;
          if (e.value > was) newErrors.add('$key: ${e.key} ${e.value} (was $was)');
        }
        return;
      }
      if (v is Map) {
        for (final e in v.entries) {
          walk(e.value, '$at/${e.key}');
        }
      } else if (v is List) {
        for (var i = 0; i < v.length; i++) {
          walk(v[i], '$at/$i');
        }
      } else if (v is String && v.length > 20 && v.trimLeft().startsWith('{') && v.contains('"nodes"')) {
        try {
          walk(jsonDecode(v), '$at(text)');
        } catch (_) {}
      }
    }

    walk(json, '');
  }
  stdout.writeln('$documents documents ($migrated schema 2) in ${files.length} files; '
      '${report.rewrites.length} rewrites, ${report.unconvertible.length} unconvertible, ${report.behaviourChanges.length} behaviour changes');
  final growth = bytesBefore == 0 ? 0 : (bytesAfter - bytesBefore) * 100 / bytesBefore;
  final bytes = 'encoded size of the schema-2 documents: $bytesBefore bytes before, $bytesAfter after '
      '(${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(2)}%)';
  stdout.writeln(bytes);
  stdout.writeln('failures: ${failures.length}${failures.isEmpty ? '' : '\n  ${failures.join('\n  ')}'}');
  stdout.writeln('new errors: ${newErrors.length}${newErrors.isEmpty ? '' : '\n  ${newErrors.join('\n  ')}'}');
  final markdown = option('--markdown');
  if (markdown != null) {
    final body = migrationReportMarkdown(report, title: 'Schema 2 → 3: the migration over the corpus');
    File(markdown).writeAsStringSync('$body\n## Checks\n\n'
        '- $documents documents in ${files.length} files ($migrated schema 2) migrated without throwing.\n'
        '- Migrating each result again changed nothing; migrate → encode → decode → encode was a fixed point for '
        '${failures.isEmpty ? 'every one' : 'all but ${failures.length}'}.\n'
        '- New validation errors against the schema-2 validator: ${newErrors.length}.\n'
        '- ${bytes[0].toUpperCase()}${bytes.substring(1)}.\n'
        '${[...failures, ...newErrors].map((e) => '  - $e\n').join()}');
  }
  if (failures.isNotEmpty) exitCode = 1;
}
