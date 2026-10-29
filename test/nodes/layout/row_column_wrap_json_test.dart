import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map encodeDecode(Object? json) => jsonDecode(jsonEncode(json)) as Map;

RowColumnNode _row({
  bool wrap = false,
  double spacing = 0,
  double runSpacing = 0,
}) => RowColumnNode(
  id: 'chips',
  name: 'Chips',
  basicBoxLocal: NodeBox(0, 0, 200, 40),
  children: ['a', 'b', 'c'],
  rowColumnType: RowColumnType.row,
  wrap: wrap,
  spacing: spacing,
  runSpacing: runSpacing,
);

void main() {
  group('RowColumnNode wrap', () {
    test('defaults to no wrap and zero spacing', () {
      final node = _row();
      expect(node.wrap, isFalse);
      expect(node.spacing, 0);
      expect(node.runSpacing, 0);
    });

    test('default values are left out of JSON', () {
      final json = encodeDecode(_row().toJson());
      expect(json.containsKey('wrap'), isFalse);
      expect(json.containsKey('spacing'), isFalse);
      expect(json.containsKey('runSpacing'), isFalse);
    });

    test('round-trips wrap, spacing and runSpacing', () {
      final json = encodeDecode(
        _row(wrap: true, spacing: 8, runSpacing: 6.5).toJson(),
      );
      expect(json['wrap'], isTrue);
      expect(json['spacing'], 8);
      expect(json['runSpacing'], 6.5);

      final back = NodeJsonConverter().fromJson(json)! as RowColumnNode;
      expect(back.wrap, isTrue);
      expect(back.spacing, 8);
      expect(back.runSpacing, 6.5);
      expect(encodeDecode(back.toJson()), json);
    });

    test('reads JSON written without the wrap keys', () {
      final json =
          encodeDecode(_row(wrap: true, spacing: 8, runSpacing: 6).toJson())
            ..remove('wrap')
            ..remove('spacing')
            ..remove('runSpacing');
      final back = RowColumnNode.fromJson(json);
      expect(back.wrap, isFalse);
      expect(back.spacing, 0);
      expect(back.runSpacing, 0);
    });

    test('exposes wrap fields through generateFields', () {
      final node = _row();
      final fields = node.generateFields();
      fields['wrap']!.setValue(true);
      fields['spacing']!.setValue(12.0);
      fields['runSpacing']!.setValue(4.0);
      expect(node.wrap, isTrue);
      expect(node.spacing, 12);
      expect(node.runSpacing, 4);
    });
  });
}
