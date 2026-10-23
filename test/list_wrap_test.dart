import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('wrap settings survive JSON and are omitted at their defaults', () {
    expect(ListViewProperties().toJson().keys,
        isNot(anyOf(contains('wrap'), contains('wrapSpacing'),
            contains('wrapRunSpacing'), contains('wrapAlignment'))));

    final ListViewProperties props = ListViewProperties(
      wrap: true,
      wrapSpacing: 8,
      wrapRunSpacing: 6,
      wrapAlignment: MainAxisAlignmentC.center,
    );
    final Map<String, dynamic> json = props.toJson();
    expect(json['wrap'], isTrue);
    expect(json['wrapSpacing'], 8);
    expect(json['wrapRunSpacing'], 6);
    expect(json['wrapAlignment'], 'center');

    final ListViewProperties copy = ListViewProperties.fromJson(json);
    expect(copy, props);
    expect(copy.isWrapping, isTrue);
    expect(props.copyWith(), props);
    expect(props.copyWith(stacked: true).isWrapping, isFalse);
  });

  test('a wrapping list node round-trips', () {
    final ListViewNode node = ListViewNode(
      id: 'list',
      name: 'Crates',
      basicBoxLocal: NodeBox(0, 0, 300, 40),
      properties: ListViewProperties(wrap: true, wrapSpacing: 4),
      children: const [],
      scrollDirection: AxisC.horizontal,
    );
    final ListViewNode copy = ListViewNode.fromJson(node.toJson());
    expect(copy.properties.wrap, isTrue);
    expect(copy.properties.wrapSpacing, 4);
    expect(copy.scrollDirection, AxisC.horizontal);
  });
}
