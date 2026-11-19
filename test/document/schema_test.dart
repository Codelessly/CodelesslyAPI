// The one schema this package reads: a document, publish model or bundle of
// any other schema (or with none) is refused, saying the schema found and
// the one read; and nothing in the package reads an older one.
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Json _doc(Object? schema) => {
      'schema': ?schema,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas'},
      },
    };

Matcher _refused(String message) => throwsA(isA<UnsupportedSchemaException>().having((e) => e.message, 'message', message));

void main() {
  test('a document of schema 3 reads', () {
    expect(LayoutDocument.fromJson(_doc(3)).roots, ['c']);
    expect(LayoutDocument.fromJson(_doc(3)).toJson()['schema'], kSchemaVersion);
  });

  test('a document of another schema, or with none, is refused with the schema found and the one read', () {
    expect(() => LayoutDocument.fromJson(_doc(2)), _refused('The document is in schema 2; codelessly_api reads schema 3 only.'));
    expect(() => LayoutDocument.fromJson(_doc(4)), _refused('The document is in schema 4; codelessly_api reads schema 3 only.'));
    expect(() => LayoutDocument.fromJson(_doc(null)),
        _refused('The document has no "schema"; codelessly_api reads schema 3 only ("schema": 3).'));
    expect(() => LayoutDocument.fromJson(_doc('3')), _refused('The document has "schema": "3"; codelessly_api reads schema 3 only.'));
    expect(() => LayoutDocument.fromJson(_doc(2)), throwsFormatException);
  });

  test('JSON that is not a map is an empty document, as before', () {
    expect(LayoutDocument.fromJson(null).nodes, isEmpty);
    expect(LayoutDocument.fromJson('x').nodes, isEmpty);
  });

  test('a publish model, a bundle, a published layout and a stored component are refused the same way', () {
    expect(() => PublishModel.fromJson({'schema': 2, 'projectId': 'p'}),
        _refused('The publish model is in schema 2; codelessly_api reads schema 3 only.'));
    expect(() => PublishBundle.fromJson({'schema': 2, 'model': {'schema': 3}}),
        _refused('The bundle is in schema 2; codelessly_api reads schema 3 only.'));
    expect(() => PublishBundle.fromJson({'model': {'schema': 2}}),
        _refused('The publish model is in schema 2; codelessly_api reads schema 3 only.'));
    expect(() => PublishLayout.fromJson(_doc(2)), _refused('The document is in schema 2; codelessly_api reads schema 3 only.'));
    expect(() => PublishComponent.fromJson({'id': 'Card', 'document': _doc(2)}),
        _refused('The document is in schema 2; codelessly_api reads schema 3 only.'));
    expect(PublishModel.fromJson({'schema': 3, 'projectId': 'p'}).projectId, 'p');
  });

  test('the notation prints a document of schema 3 only', () {
    expect(() => printNotation(_doc(2), catalog: standardCatalog),
        _refused('The document is in schema 2; codelessly_api reads schema 3 only.'));
  });

  test('nothing under lib/ or tool/ reads an older schema or mentions migrating one', () {
    final older = RegExp(
        r'''migrat|kOldestSchemaVersion|schemaOf\(|schema[- ]2\b|schema2|["']schema["']\s*:\s*2\b|schema:\s*2\b|legacy\.''',
        caseSensitive: false);
    final found = <String>[];
    for (final dir in ['lib', 'tool']) {
      for (final f in Directory(dir).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (older.hasMatch(lines[i])) found.add('${f.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(found, isEmpty);
    expect(Directory('lib/src/core/migrate').existsSync(), isFalse);
  });
}
