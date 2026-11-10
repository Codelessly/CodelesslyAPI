import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

VarianceNode layout({double? tablet, double? desktop}) => VarianceNode(
  id: 'r',
  name: 'Responsive',
  basicBoxLocal: NodeBox(0, 0, 100, 100),
  variants: [
    for (final b in ScreenBreakpoint.values)
      Variant(id: b.name, name: b.label, children: [], breakpoint: b),
  ],
  properties: VarianceProperties(tabletMinWidth: tablet, desktopMinWidth: desktop),
);

void main() {
  test('standard widths: 600 and 1024', () {
    final node = layout();
    expect(node.variantForWidth(599).id, 'mobile');
    expect(node.variantForWidth(650).id, 'tablet');
    expect(node.variantForWidth(1100).id, 'desktop');
  });

  test('a layout can switch at its own widths, e.g. 700 and 1200', () {
    final node = layout(tablet: 700, desktop: 1200);
    expect(node.variantForWidth(650).id, 'mobile');
    expect(node.variantForWidth(700).id, 'tablet');
    expect(node.variantForWidth(1100).id, 'tablet');
    expect(node.variantForWidth(1200).id, 'desktop');
    // The default design widths stay in their own layouts.
    expect(node.variantForWidth(390).id, 'mobile');
    expect(node.variantForWidth(834).id, 'tablet');
    expect(node.variantForWidth(1440).id, 'desktop');
  });

  test('the widths survive JSON and are left out when standard', () {
    final copy = VarianceNode.fromJson(layout(tablet: 700, desktop: 1200).toJson());
    expect(copy.properties.tabletMinWidth, 700);
    expect(copy.properties.desktopMinWidth, 1200);
    expect(layout().toJson()['properties'] ?? {}, isNot(contains('tabletMinWidth')));
  });
}
