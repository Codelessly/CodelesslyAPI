// Migrates a directory of stored v1 page documents (`*.json.gz`, the
// editor's page format) to v2 layout documents, and prints coverage.
//
//   dart run bin/migrate_pages.dart <in-dir> <out-dir>
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_migrate/codelessly_migrate.dart';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: migrate_pages <in-dir> <out-dir>');
    exit(64);
  }
  final out = Directory(args[1])..createSync(recursive: true);
  final total = MigrationReport();
  final files = Directory(args[0]).listSync().whereType<File>().where((f) => f.path.endsWith('.json.gz')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in files) {
    final json = jsonDecode(utf8.decode(gzip.decode(f.readAsBytesSync()))) as Map<String, dynamic>;
    final doc = ((json['document'] as Map?) ?? json).cast<String, Object?>();
    final name = f.uri.pathSegments.last.replaceAll('.json.gz', '');
    final report = MigrationReport();
    final v2 = migrateDocument(doc, id: name, report: report);
    total.merge(report);
    File('${out.path}/$name.json.gz').writeAsBytesSync(gzip.encode(utf8.encode(jsonEncode(v2))));
  }
  stdout.writeln('${files.length} pages, ${total.nodes} nodes');
  stdout.writeln('types: ${total.types}');
  stdout.writeln('unported types: ${total.unportedTypes}');
  final unmapped = total.unmapped.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  stdout.writeln('unmapped v1 keys (${unmapped.length}):');
  for (final e in unmapped.take(60)) {
    stdout.writeln('  ${e.key}: ${e.value}');
  }
}
