import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('scrolling containers, lists and grids take dragEdgeScroll (on by default)', () {
    for (final type in ['column', 'row', 'stack', 'listView', 'gridView']) {
      final spec = standardCatalog.widgets.firstWhere((w) => w.type == type);
      expect(spec.props.map((p) => p.key), contains('dragEdgeScroll'), reason: type);
    }
    expect(ScrollProps.dragEdgeScroll.defaultValue, isTrue);
    final props = Props.fromJson(standardCatalog.widgets.firstWhere((w) => w.type == 'listView'), {'dragEdgeScroll': false});
    expect(props.get(CollectionScrollProps.dragEdgeScroll), isFalse);
  });
}
