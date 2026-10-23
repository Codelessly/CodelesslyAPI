import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

RowColumnNode _row({bool wrap = false, double runSpacing = 0}) =>
    RowColumnNode(
      id: 'row',
      name: 'Row',
      basicBoxLocal: NodeBox(0, 0, 330, 100),
      children: const ['a', 'b', 'c'],
      rowColumnType: RowColumnType.row,
      spacing: 8,
      wrap: wrap,
      runSpacing: runSpacing,
    );

void main() {
  group('RowColumnNode wrap', () {
    test('defaults to no wrap and is omitted from JSON', () {
      final node = _row();
      expect(node.wrap, isFalse);
      expect(node.runSpacing, 0);
      final json = node.toJson();
      expect(json.containsKey('wrap'), isFalse);
      expect(json.containsKey('runSpacing'), isFalse);
    });

    test('round-trips wrap and runSpacing', () {
      final json =
          jsonDecode(jsonEncode(_row(wrap: true, runSpacing: 12).toJson()))
              as Map;
      expect(json['wrap'], isTrue);
      expect(json['runSpacing'], 12);
      final decoded = RowColumnNode.fromJson(json);
      expect(decoded.wrap, isTrue);
      expect(decoded.runSpacing, 12);
      expect(decoded.spacing, 8);
    });

    test('loads JSON written without wrap; accepts integer runSpacing', () {
      final json = _row().toJson()..['runSpacing'] = 4;
      final decoded = RowColumnNode.fromJson(json);
      expect(decoded.wrap, isFalse);
      expect(decoded.runSpacing, 4.0);
    });

    test('is exposed as layout fields', () {
      final node = _row();
      expect(node.fields['wrap']!.requiresLayout, isTrue);
      expect(node.fields['runSpacing']!.requiresLayout, isTrue);
      node.fields['wrap']!.setValue(true);
      node.fields['runSpacing']!.setValue(6.0);
      expect(node.wrap, isTrue);
      expect(node.runSpacing, 6);
    });

    test('a wrapping row/column scrolls along its cross axis', () {
      expect(_row().scrollDirection, AxisC.horizontal);
      expect(_row(wrap: true).scrollDirection, AxisC.vertical);
      final column = _row(wrap: true)..rowColumnType = RowColumnType.column;
      expect(column.scrollDirection, AxisC.horizontal);
    });

    test('other RowColumnMixin nodes load old JSON without wrap', () {
      final placeholder = AutoPlaceholderNode(
        id: 'placeholder',
        name: 'Placeholder',
        basicBoxLocal: NodeBox(0, 0, 100, 100),
        children: const [],
      );
      final json = placeholder.toJson();
      expect(json.containsKey('wrap'), isFalse);
      final decoded = AutoPlaceholderNode.fromJson(json);
      expect(decoded.wrap, isFalse);
      expect(decoded.runSpacing, 0);
    });
  });
}
