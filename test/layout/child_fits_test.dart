import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Node n(String type, [Props props = Props.empty]) => Node(id: 'p', type: type, props: props);

void main() {
  test('a child of a stack can be fixed, hug or fill, never flexible', () {
    expect(allowedChildFits(n('stack'), horizontal: true), [SizeFit.fixed, SizeFit.fill, SizeFit.hug]);
    expect(allowedChildFits(null, horizontal: false), [SizeFit.fixed, SizeFit.fill, SizeFit.hug]);
  });

  test('nothing can fill a scrolling stack along its scroll direction', () {
    final p = n('stack', Props.empty.set(ScrollProps.scrollable, true));
    expect(allowedChildFits(p, horizontal: false), isNot(contains(SizeFit.fill)));
    expect(allowedChildFits(p, horizontal: true), contains(SizeFit.fill));
  });

  test('a row\'s child can be flexible along the row only, and a wrapping row keeps sizes along it', () {
    expect(allowedChildFits(n('row'), horizontal: true), contains(SizeFit.flexible));
    expect(allowedChildFits(n('row'), horizontal: false), isNot(contains(SizeFit.flexible)));
    expect(allowedChildFits(n('column'), horizontal: false), contains(SizeFit.flexible));
    final wrap = n('row', Props.empty.set(FlexProps.wrap, true));
    expect(allowedChildFits(wrap, horizontal: true), [SizeFit.fixed, SizeFit.hug]);
    expect(childFitOptions(wrap, horizontal: true)[SizeFit.fill], contains('wrapping'));
  });

  test('a list\'s items fill across it, and along it only when the list has an item extent', () {
    expect(allowedChildFits(n('listView'), horizontal: true), [SizeFit.fill]);
    expect(allowedChildFits(n('listView'), horizontal: false), [SizeFit.fixed, SizeFit.hug]);
    final extent = n('listView', Props.empty.set(ListViewProps.itemExtent, 48));
    expect(allowedChildFits(extent, horizontal: false), [SizeFit.fill]);
  });

  test('a grid and a page view size their children themselves', () {
    expect(allowedChildFits(n('gridView'), horizontal: true), [SizeFit.fill]);
    expect(allowedChildFits(n('pageView'), horizontal: false), [SizeFit.fill]);
  });
}
