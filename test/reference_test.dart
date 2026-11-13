// The committed reference (docs/reference) is what the generator makes of
// the declarations today, and every JSON example in it is valid.
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

import '../tool/reference/src/reference.dart';

void main() {
  final root = Directory.current.path;

  test('docs/reference is up to date (dart run tool/reference/generate.dart)', () {
    final files = buildReference(root);
    final stale = [
      for (final e in files.entries)
        if (!File('$root/${e.key}').existsSync() || File('$root/${e.key}').readAsStringSync() != e.value) e.key,
    ];
    expect(stale, isEmpty, reason: 'Regenerate: dart run tool/reference/generate.dart');
  });

  test('every example document is valid, without warnings', () {
    final dir = Directory('$root/tool/reference/examples');
    final docs = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList();
    expect(docs, isNotEmpty);
    for (final f in docs) {
      final diagnostics = validateDocument(jsonDecode(f.readAsStringSync()));
      expect(diagnostics.map((d) => '$d'), isEmpty, reason: f.path);
    }
  });

  test('every JSON block in the guide parses, and every whole document in it is valid', () {
    final guide = File('$root/docs/reference/index.md').readAsStringSync();
    final blocks = RegExp(r'```json\n(.*?)\n```', dotAll: true).allMatches(guide).map((m) => m[1]!).toList();
    expect(blocks.length, greaterThan(10));
    var documents = 0;
    for (final b in blocks) {
      Object? json;
      try {
        json = jsonDecode(b);
      } on FormatException {
        json = jsonDecode('{$b}'); // a fragment: one or more keys of an object
      }
      if (json is Map && json['schema'] == 2) {
        documents++;
        expect(validateDocument(json).map((d) => '$d'), isEmpty, reason: b);
      }
    }
    expect(documents, greaterThan(10));
  });

  test('the catalog lists every diagnostic code and every node type', () {
    final catalog = jsonDecode(File('$root/docs/reference/catalog.json').readAsStringSync()) as Map;
    expect((catalog['diagnostics'] as List).length, Codes.all.length);
    expect((catalog['nodeTypes'] as Map).length, greaterThan(60));
  });
}
