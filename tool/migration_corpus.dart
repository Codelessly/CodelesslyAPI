// The schema-3 migration over a corpus of schema-2 documents: every document
// migrates without throwing and re-encodes stably (migrate → encode →
// decode → encode is a fixed point); the aggregated MigrationReport is
// written as Markdown.
//
//   dart run tool/migration_corpus.dart <file|dir>... [--markdown out.md] [--strip prefix]
//
// --strip removes a prefix from the file names in the report.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/migrate/steps_spellings.dart' show spellingMigrationSteps;

void main(List<String> args) {
  String? option(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final options = {'--markdown', '--strip'};
  final inputs = [
    for (var i = 0; i < args.length; i++)
      if (!args[i].startsWith('--') && (i == 0 || !options.contains(args[i - 1]))) args[i],
  ];
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
        // Idempotent: again is the same, and 30.1.0's one-way steps change
        // nothing in their own output.
        if (!identical(migrate2to3(out), out)) failures.add('$key: a schema-3 document changed when migrated again');
        final again = migrate2to3({...out, 'schema': 2}, steps: spellingMigrationSteps);
        if (jsonEncode(again) != jsonEncode(out)) failures.add('$key: the one-way steps changed their own output');
        // A fixed point: encode → decode → encode.
        final e1 = LayoutDocument.fromJson(out, catalog: standardCatalog).toJson();
        final e2 = LayoutDocument.fromJson(e1, catalog: standardCatalog).toJson();
        if (jsonEncode(e1) != jsonEncode(e2)) failures.add('$key: re-encoding is not a fixed point');
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
      '${report.rewrites.length} rewrites, ${report.unconvertible.length} unconvertible, ${report.behaviorChanges.length} behavior changes');
  final growth = bytesBefore == 0 ? 0 : (bytesAfter - bytesBefore) * 100 / bytesBefore;
  final bytes = 'encoded size of the schema-2 documents: $bytesBefore bytes before, $bytesAfter after '
      '(${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(2)}%)';
  stdout.writeln(bytes);
  stdout.writeln('failures: ${failures.length}${failures.isEmpty ? '' : '\n  ${failures.join('\n  ')}'}');
  final markdown = option('--markdown');
  if (markdown != null) {
    final body = migrationReportMarkdown(report, title: 'Schema 2 → 3: the migration over the corpus');
    File(markdown).writeAsStringSync('$body\n## Checks\n\n'
        '- $documents documents in ${files.length} files ($migrated schema 2) migrated without throwing.\n'
        '- Migrating each result again changed nothing; migrate → encode → decode → encode was a fixed point for '
        '${failures.isEmpty ? 'every one' : 'all but ${failures.length}'}.\n'
        '- ${bytes[0].toUpperCase()}${bytes.substring(1)}.\n'
        '${failures.map((e) => '  - $e\n').join()}');
  }
  if (failures.isNotEmpty) exitCode = 1;
}
