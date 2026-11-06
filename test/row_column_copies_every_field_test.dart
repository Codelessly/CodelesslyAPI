import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A row or column is decoded into a generic RowColumnNode and then copied
/// into RowNode/ColumnNode field by field. Fields the copy forgot were
/// dropped silently on every load: `ignorePointer` (Safecracker's film-grain
/// overlay then swallowed every tap of the screen) and `floating`.
void main() {
  test('ignorePointer and floating survive a row and a column', () {
    for (final String type in ['row', 'column']) {
      final BaseNode node = NodeJsonConverter().fromJson({
        'type': type,
        'id': 'n',
        'name': 'Grain',
        'basicBoxLocal': [0, 0, 10, 10],
        'children': <String>[],
        'ignorePointer': true,
        'floating': true,
      })!;
      expect(node.ignorePointer, isTrue, reason: type);
      expect(node.toJson()['ignorePointer'], isTrue, reason: type);
      expect(node.toJson()['floating'], isTrue, reason: type);
    }
  });

  test('the copy sets every field the generated decoder sets', () {
    final String generated = File('lib/src/api/nodes/row_column_node.g.dart').readAsStringSync();
    final String source = File('lib/src/api/nodes/row_column_node.dart').readAsStringSync();
    final Set<String> decoded = RegExp(r'\.\.(\w+) = json').allMatches(generated).map((m) => m[1]!).toSet();
    final Set<String> copied = RegExp(r'target\.(\w+) = source').allMatches(source).map((m) => m[1]!).toSet();
    expect(decoded.difference(copied), isEmpty);
  });
}
