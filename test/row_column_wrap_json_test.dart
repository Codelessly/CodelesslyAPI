import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  RowColumnNode row({
    bool wrap = false,
    double runSpacing = 0,
    MainAxisAlignmentC runAlignment = MainAxisAlignmentC.start,
  }) => RowColumnNode(
    id: 'row',
    name: 'Row',
    basicBoxLocal: NodeBox(0, 0, 200, 40),
    children: [],
    rowColumnType: RowColumnType.row,
    wrap: wrap,
    runSpacing: runSpacing,
    runAlignment: runAlignment,
  );

  test('a wrapping row round-trips through JSON', () {
    final json = row(
      wrap: true,
      runSpacing: 8,
      runAlignment: MainAxisAlignmentC.center,
    ).toJson();
    expect(json['wrap'], isTrue);
    expect(json['runSpacing'], 8);
    expect(json['runAlignment'], 'center');

    final node = RowColumnNode.fromJson(json);
    expect(node.wrap, isTrue);
    expect(node.runSpacing, 8);
    expect(node.runAlignment, MainAxisAlignmentC.center);
  });

  test('a row that does not wrap writes none of the wrap keys', () {
    final json = row().toJson();
    expect(json.containsKey('wrap'), isFalse);
    expect(json.containsKey('runSpacing'), isFalse);
    expect(json.containsKey('runAlignment'), isFalse);

    final node = RowColumnNode.fromJson(json);
    expect(node.wrap, isFalse);
    expect(node.runSpacing, 0);
    expect(node.runAlignment, MainAxisAlignmentC.start);
  });

  test('a patch with only wrap and runSpacing reads', () {
    final node = RowColumnNode.fromJson({
      ...row().toJson(),
      'wrap': true,
      'runSpacing': 8,
    });
    expect(node.wrap, isTrue);
    expect(node.runSpacing, 8.0);
    expect(node.runAlignment, MainAxisAlignmentC.start);
  });
}
