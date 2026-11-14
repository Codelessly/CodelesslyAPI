// Migrates schema-2 documents to schema 3, for authors.
//
//   dart run tool/migrate.dart <file|dir>... [--write] [--report out.json] [--markdown out.md]
//
// Reads every .json file given (directories recursively); every document in
// it (a layout document, a publish model or bundle, a component definition,
// a site manifest, a plugin package, a file holding several) is migrated
// with `migrateJson2to3`. Without --write it only reports; with it, each
// file that changed is rewritten (indented as it was: two spaces, or one
// line). --report writes the MigrationReport as JSON; --markdown as the
// summary table. Exit code 0 always, unless a file could not be read.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/core.dart';

void main(List<String> args) {
  final write = args.contains('--write');
  String? option(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final reportPath = option('--report'), markdownPath = option('--markdown');
  final inputs = [
    for (var i = 0; i < args.length; i++)
      if (!args[i].startsWith('--') && (i == 0 || (args[i - 1] != '--report' && args[i - 1] != '--markdown'))) args[i],
  ];
  if (inputs.isEmpty) {
    stderr.writeln('usage: dart run tool/migrate.dart <file|dir>... [--write] [--report out.json] [--markdown out.md]');
    exit(64);
  }
  final files = <File>[
    for (final p in inputs)
      if (FileSystemEntity.isDirectorySync(p))
        ...Directory(p).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json'))
      else
        File(p),
  ]..sort((a, b) => a.path.compareTo(b.path));
  final report = MigrationReport();
  var changed = 0, failed = 0;
  for (final f in files) {
    final String text;
    final Object? json;
    try {
      text = f.readAsStringSync();
      json = jsonDecode(text);
    } catch (e) {
      stderr.writeln('${f.path}: not JSON ($e)');
      failed++;
      continue;
    }
    report.document = f.path;
    final out = migrateJson2to3(json, report: report);
    if (jsonEquality.equals(out, json)) continue;
    changed++;
    if (write) {
      final indented = text.contains('\n  "') || text.contains('\n "');
      f.writeAsStringSync(indented ? '${const JsonEncoder.withIndent('  ').convert(out)}\n' : jsonEncode(out));
    }
    stdout.writeln('${write ? 'migrated' : 'would migrate'} ${f.path}');
  }
  stdout.writeln('${files.length} files, $changed ${write ? 'migrated' : 'to migrate'}; '
      '${report.rewrites.length} rewrites, ${report.unconvertible.length} unconvertible values, '
      '${report.behaviorChanges.length} behavior changes.');
  for (final e in [...report.unconvertible, ...report.behaviorChanges]) {
    stdout.writeln('  $e${e.instead.isEmpty ? '' : '\n      instead: ${e.instead}'}');
  }
  if (reportPath != null) File(reportPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report.toJson()));
  if (markdownPath != null) File(markdownPath).writeAsStringSync(migrationReportMarkdown(report));
  if (failed > 0) exitCode = 1;
}
