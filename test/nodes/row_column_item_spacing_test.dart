import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

RowColumnNode _row({double itemSpacing = 0}) => RowColumnNode(
  id: 'row',
  name: 'Row',
  basicBoxLocal: NodeBox(0, 0, 200, 50),
  children: ['a', 'b'],
  rowColumnType: RowColumnType.row,
  itemSpacing: itemSpacing,
);

Map<String, dynamic> _roundTripJson(RowColumnNode node) =>
    jsonDecode(jsonEncode(node.toJson())) as Map<String, dynamic>;

void main() {
  group('RowColumnNode.itemSpacing', () {
    test('defaults to 0 and is omitted from JSON', () {
      final node = _row();
      expect(node.itemSpacing, 0);
      expect(node.toJson().containsKey('itemSpacing'), isFalse);
      expect(RowColumnNode.fromJson(_roundTripJson(node)).itemSpacing, 0);
    });

    test('non-default value round-trips through JSON', () {
      final node = _row(itemSpacing: 12.5);
      final json = _roundTripJson(node);
      expect(json['itemSpacing'], 12.5);
      final decoded = RowColumnNode.fromJson(json);
      expect(decoded.itemSpacing, 12.5);
      expect(decoded.toJson(), node.toJson());
    });

    test('accepts integer JSON values', () {
      final json = _roundTripJson(_row(itemSpacing: 8));
      json['itemSpacing'] = 8;
      expect(RowColumnNode.fromJson(json).itemSpacing, 8.0);
    });

    test('is exposed as a layout field', () {
      final node = _row(itemSpacing: 4);
      final field = node.fields['itemSpacing'];
      expect(field, isNotNull);
      expect(field!.getValue(), 4);
      expect(field.requiresLayout, isTrue);
      field.setValue(16);
      expect(node.itemSpacing, 16);
    });
  });
}
