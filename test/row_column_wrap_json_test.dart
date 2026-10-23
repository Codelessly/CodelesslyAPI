import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

RowColumnNode _row({bool wrap = false, double runSpacing = 0}) => RowColumnNode(
  id: 'row',
  name: 'Row',
  basicBoxLocal: NodeBox(0, 0, 200, 100),
  children: const [],
  rowColumnType: RowColumnType.row,
  wrap: wrap,
  runSpacing: runSpacing,
);

void main() {
  test('wrap and runSpacing default to off and are omitted from JSON', () {
    final RowColumnNode row = _row();
    expect(row.wrap, isFalse);
    expect(row.runSpacing, 0);

    final Map json = row.toJson();
    expect(json.containsKey('wrap'), isFalse);
    expect(json.containsKey('runSpacing'), isFalse);

    final RowColumnNode again = RowColumnNode.fromJson(
      Map<String, dynamic>.from(json),
    );
    expect(again.wrap, isFalse);
    expect(again.runSpacing, 0);
  });

  test('wrap and runSpacing round-trip through JSON', () {
    final Map json = _row(wrap: true, runSpacing: 8).toJson();
    expect(json['wrap'], isTrue);
    expect(json['runSpacing'], 8);

    final RowColumnNode again = RowColumnNode.fromJson(
      Map<String, dynamic>.from(json),
    );
    expect(again.wrap, isTrue);
    expect(again.runSpacing, 8);
  });

  test('wrap and runSpacing read from minimal JSON', () {
    final RowColumnNode node = RowColumnNode.fromJson({
      'type': 'rowColumn',
      'id': 'col',
      'name': 'Column',
      'basicBoxLocal': [0, 0, 100, 300],
      'rowColumnType': 'column',
      'wrap': true,
      'runSpacing': 12,
    });
    expect(node.wrap, isTrue);
    expect(node.runSpacing, 12.0);
  });

  test('wrap and runSpacing are exposed as fields', () {
    final RowColumnNode row = _row();
    final FieldsMap fields = row.generateFields();
    expect(fields['wrap'], isA<BoolFieldAccess>());
    expect(fields['runSpacing'], isA<NumFieldAccess<double>>());
    fields['wrap']!.setValue(true);
    (fields['runSpacing'] as NumFieldAccess<double>).setValue(4.0);
    expect(row.wrap, isTrue);
    expect(row.runSpacing, 4);
  });
}
