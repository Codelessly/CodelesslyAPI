import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

// The keyboard's document fields: `focusable` (a press target's opt-out),
// `focusGroup` (one Tab stop the arrows move through) and a canvas's
// `semanticLabel` (an overlay's name).

void main() {
  test('focusable defaults to true and is written only when false', () {
    final plain = Node.fromJson({'type': 'box'}, id: 'a')!;
    expect(plain.behaviors.focusable, isTrue);
    expect(plain.toJson().containsKey('focusable'), isFalse);
    final out = Node.fromJson({'type': 'box', 'focusable': false}, id: 'a')!;
    expect(out.behaviors.focusable, isFalse);
    expect(out.toJson()['focusable'], false);
  });

  test('focusGroup reads true, an object and its defaults, and writes back sparse', () {
    final short = Node.fromJson({'type': 'column', 'focusGroup': true}, id: 'm')!;
    expect(short.behaviors.focusGroup, const FocusGroup());
    expect(short.behaviors.focusGroup!.axis, FocusGroupAxis.vertical);
    expect(short.behaviors.focusGroup!.wrap, isTrue);
    expect(short.behaviors.focusGroup!.typeAhead, isFalse);
    expect(short.toJson()['focusGroup'], <String, Object?>{});
    final full = Node.fromJson({
      'type': 'row',
      'focusGroup': {'axis': 'horizontal', 'wrap': false, 'typeAhead': true},
    }, id: 't')!;
    expect(full.behaviors.focusGroup, const FocusGroup(axis: FocusGroupAxis.horizontal, wrap: false, typeAhead: true));
    expect(full.toJson()['focusGroup'], {'axis': 'horizontal', 'wrap': false, 'typeAhead': true});
    expect(Node.fromJson({'type': 'row'}, id: 't')!.behaviors.focusGroup, isNull);
  });

  test('a canvas names itself for assistive technology', () {
    final canvas = Node.fromJson({
      'type': 'canvas',
      'props': {'semanticLabel': 'Join the waitlist'},
    }, id: 'signup')!;
    expect(canvas.props.get(CanvasProps.semanticLabel), 'Join the waitlist');
    expect(Node.fromJson({'type': 'canvas'}, id: 'c')!.props.get(CanvasProps.semanticLabel), '');
  });

  test('strict validation knows the keys', () {
    final doc = LayoutDocument.fromJson({
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas', 'slots': {'body': 'menu'}, 'props': {'semanticLabel': 'Sort'}},
        'menu': {'type': 'column', 'focusGroup': {'typeAhead': true}, 'children': ['row']},
        'row': {'type': 'box', 'focusable': false},
      },
    });
    expect(doc['menu']!.behaviors.focusGroup!.typeAhead, isTrue);
    expect(doc['row']!.behaviors.focusable, isFalse);
  });
}
