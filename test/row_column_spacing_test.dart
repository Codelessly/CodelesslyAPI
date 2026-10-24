import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

RowColumnNode _row({double spacing = 0}) => RowColumnNode(
  id: 'row',
  name: 'Row',
  basicBoxLocal: NodeBox(0, 0, 1072, 100),
  children: const ['a', 'b', 'c'],
  rowColumnType: RowColumnType.row,
  spacing: spacing,
);

void main() {
  group('RowColumnNode.spacing', () {
    test('defaults to 0 and is omitted from JSON', () {
      final node = _row();
      expect(node.spacing, 0);
      expect(node.toJson().containsKey('spacing'), isFalse);
    });

    test('round-trips a non-zero spacing', () {
      final json = jsonDecode(jsonEncode(_row(spacing: 20).toJson())) as Map;
      expect(json['spacing'], 20);
      final decoded = RowColumnNode.fromJson(json);
      expect(decoded.spacing, 20);
      expect(decoded.toJson()['spacing'], 20);
    });

    test('loads JSON written without spacing', () {
      final json = _row().toJson()..remove('spacing');
      expect(RowColumnNode.fromJson(json).spacing, 0);
    });

    test('accepts integer spacing in JSON', () {
      final json = _row().toJson()..['spacing'] = 12;
      expect(RowColumnNode.fromJson(json).spacing, 12.0);
    });

    test('is exposed as a layout field', () {
      final node = _row(spacing: 8);
      final field = node.fields['spacing']!;
      expect(field.getValue(), 8);
      expect(field.requiresLayout, isTrue);
      field.setValue(16.0);
      expect(node.spacing, 16);
    });

    test('other RowColumnMixin nodes load old JSON without spacing', () {
      final placeholder = AutoPlaceholderNode(
        id: 'placeholder',
        name: 'Placeholder',
        basicBoxLocal: NodeBox(0, 0, 100, 100),
        children: const [],
      );
      final json = placeholder.toJson();
      expect(json.containsKey('spacing'), isFalse);
      expect(AutoPlaceholderNode.fromJson(json).spacing, 0);
    });
  });
}
