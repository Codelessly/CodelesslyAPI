// A grid item's span and start (CSS grid-column: span n, grid-column-start)
// are layout fields a gridView reads.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

Map<String, Object?> _doc(String parentType, Map<String, Object?> itemLayout) => {
      'schema': 3,
      'roots': ['home'],
      'nodes': {
        'home': {'type': 'canvas', 'slots': {'body': 'parent'}, 'layout': {'width': 1000, 'height': 800}},
        'parent': {
          'type': parentType,
          'children': ['item'],
          'layout': {'width': {'fill': 1000}, 'height': {'hug': 400}},
          if (parentType == 'gridView') 'props': {'crossAxisCount': 3, 'mainAxisExtent': 200, 'physics': 'never'},
        },
        'item': {'type': 'box', 'layout': {'width': {'fill': 100}, 'height': {'fill': 100}, ...itemLayout}},
      },
    };

void main() {
  test('a grid item\'s spans and starts round-trip, and unset ones are not written', () {
    final l = Layout.fromJson({'width': 10, 'height': 10, 'columnSpan': 2, 'rowSpan': 3, 'columnStart': 2, 'rowStart': 1});
    expect((l.columnSpan, l.rowSpan, l.columnStart, l.rowStart), (2, 3, 2, 1));
    expect(Layout.fromJson(l.toJson()), l);
    final plain = Layout.fromJson({'width': 10, 'height': 10});
    expect((plain.columnSpan, plain.rowSpan, plain.columnStart, plain.rowStart), (1, 1, null, null));
    expect(plain.toJson().keys, ['width', 'height']);
    // A span under 1 or a start under 1 means none.
    final bad = Layout.fromJson({'columnSpan': 0, 'columnStart': 0});
    expect((bad.columnSpan, bad.columnStart), (1, null));
  });

  test('a gridView reads its items\' spans; anywhere else they are reported as ignored', () {
    expect(validateDocument(_doc('gridView', {'columnSpan': 2, 'rowStart': 1})), isEmpty);
    final ignored = validateDocument(_doc('column', {'columnSpan': 2})).where((d) => d.code == Codes.layoutFieldIgnored);
    expect(ignored.map((d) => d.path), ['/nodes/item/layout/columnSpan']);
  });

  test('a span is bindable per item and patchable at a size', () {
    final doc = _doc('gridView', {});
    final item = (doc['nodes'] as Map)['item'] as Map<String, Object?>;
    item['media'] = [
      {'minWidth': 1024, 'patch': {'bind': {'layout.columnSpan': r'${= index == 0 ? 2 : 1}'}}},
    ];
    expect(validateDocument(doc), isEmpty);
    final n = LayoutDocument.fromJson(doc)['item']!;
    expect(BindPaths.apply(n, 'layout.columnSpan', 2).layout.columnSpan, 2);
  });
}
