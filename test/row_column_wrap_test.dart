import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

RowColumnNode _row({
  bool wrap = false,
  double spacing = 0,
  double runSpacing = 0,
  RowColumnType type = RowColumnType.row,
}) => RowColumnNode(
  id: 'row',
  name: 'Row',
  basicBoxLocal: NodeBox(0, 0, 200, 40),
  children: const ['a', 'b'],
  rowColumnType: type,
  wrap: wrap,
  spacing: spacing,
  runSpacing: runSpacing,
);

Map<String, dynamic> _encodeDecode(Map json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void main() {
  group('RowColumnNode wrap', () {
    test('defaults are off and left out of the JSON', () {
      final RowColumnNode node = _row();
      expect(node.wrap, isFalse);
      expect(node.spacing, 0);
      expect(node.runSpacing, 0);

      final Map json = node.toJson();
      expect(json.containsKey('wrap'), isFalse);
      expect(json.containsKey('spacing'), isFalse);
      expect(json.containsKey('runSpacing'), isFalse);
      expect(json.containsKey('wrapsChildren'), isFalse);
    });

    test('JSON without the keys reads the defaults', () {
      final RowColumnNode node = RowColumnNode.fromJson(
        _encodeDecode(_row().toJson()),
      );
      expect(node.wrap, isFalse);
      expect(node.spacing, 0);
      expect(node.runSpacing, 0);
    });

    test('round-trips wrap, spacing and runSpacing', () {
      final Map<String, dynamic> json = _encodeDecode(
        _row(wrap: true, spacing: 8, runSpacing: 6).toJson(),
      );
      expect(json['wrap'], isTrue);
      expect(json['spacing'], 8);
      expect(json['runSpacing'], 6);

      final RowColumnNode node = RowColumnNode.fromJson(json);
      expect(node.wrap, isTrue);
      expect(node.spacing, 8.0);
      expect(node.runSpacing, 6.0);
      expect(node.wrapsChildren, isTrue);
    });

    test('accepts integer spacing values in JSON', () {
      final Map<String, dynamic> json = _encodeDecode(_row().toJson())
        ..['wrap'] = true
        ..['spacing'] = 4
        ..['runSpacing'] = 2;
      final RowColumnNode node = RowColumnNode.fromJson(json);
      expect(node.spacing, isA<double>());
      expect(node.spacing, 4.0);
      expect(node.runSpacing, 2.0);
    });

    test('only rows wrap their children', () {
      expect(_row(wrap: true).wrapsChildren, isTrue);
      expect(
        _row(wrap: true, type: RowColumnType.column).wrapsChildren,
        isFalse,
      );
      expect(_row().wrapsChildren, isFalse);
    });

    test('fields are exposed for overrides', () {
      final RowColumnNode node = _row();
      final FieldsMap fields = node.generateFields();
      fields['wrap']!.setValue(true);
      fields['spacing']!.setValue(12.0);
      fields['runSpacing']!.setValue(3.0);
      expect(node.wrap, isTrue);
      expect(node.spacing, 12.0);
      expect(node.runSpacing, 3.0);
    });
  });
}
