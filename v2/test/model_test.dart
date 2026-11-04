import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final docJson = <String, Object?>{
    'schema': 2,
    'id': 'L',
    'roots': ['c'],
    'nodes': {
      'c': {
        'type': 'canvas',
        'name': 'Home',
        'slots': {'body': 'col'},
        'layout': {'width': 1440, 'height': 900},
        'decoration': {
          'fills': [
            {'color': '#FFFFFFFF'}
          ]
        },
      },
      'col': {
        'type': 'column',
        'children': ['t', 'x'],
        'layout': {
          'width': {'fill': 1440},
          'height': {'hug': 626},
          'padding': 24,
          'margin': [0, 16, 0, 0],
        },
        'props': {'crossAxisAlignment': 'start', 'spacing': 12},
        'decoration': {
          'fills': [
            {'color': '#FF102030'}
          ],
          'radius': 8,
          'strokes': [
            {'color': '#FF000000'}
          ],
          'strokeWidth': 2,
        },
        'bind': {'visible': r'${loading}'},
      },
      't': {
        'type': 'text',
        'layout': {
          'width': {'hug': 40},
          'height': {'hug': 16},
          'x': {'start': 4},
        },
        'props': {
          'text': 'Hello',
          'runs': [
            {
              'start': 0,
              'end': 5,
              'style': {'fontSize': 13, 'fontWeight': 700, 'color': '#FFE9EBEE', 'height': 1.2308}
            }
          ],
        },
      },
      'x': {'type': 'futureWidget', 'layout': {'width': 10, 'height': 10}, 'props': {'whatever': [1, 2]}, 'hello': 1},
    },
  };

  test('round-trips exactly', () {
    final doc = LayoutDocument.fromJson(docJson);
    final out = doc.toJson();
    expect(jsonDecode(jsonEncode(out)), jsonDecode(jsonEncode(docJson)));
    expect(LayoutDocument.fromJson(out).nodes, doc.nodes);
  });

  test('typed access with Flutter defaults', () {
    final doc = LayoutDocument.fromJson(docJson);
    final col = doc['col']!;
    expect(col.prop(FlexProps.crossAxisAlignment), CrossAxisAlignment.start);
    expect(col.prop(FlexProps.mainAxisAlignment), MainAxisAlignment.start);
    expect(col.prop(FlexProps.spacing), 12);
    expect(col.layout.width, const AxisSize.fill(1440));
    expect(col.layout.padding, const EdgeInsets.all(24));
    expect(col.decoration.radius, const BorderRadius.circular(8));
    expect(col.decoration.strokeWidth, 2);
    final t = doc['t']!;
    expect(t.prop(TextProps.runs).single.style.fontWeight, 700);
    expect(t.prop(TextProps.textAlign), TextAlign.start);
    expect(t.layout.x, const AxisPosition.start(4));
  });

  test('parents are derived', () {
    final doc = LayoutDocument.fromJson(docJson);
    expect(doc.parentOf('col'), 'c');
    expect(doc.parentOf('t'), 'col');
    expect(doc.parentOf('c'), isNull);
    expect(doc.subtree('c').map((n) => n.id), ['c', 'col', 't', 'x']);
  });

  test('unknown types and keys round-trip', () {
    final x = LayoutDocument.fromJson(docJson)['x']!;
    expect(x.spec, isNull);
    expect(x.extra, {'hello': 1});
    expect(x.toJson()['props'], {'whatever': [1, 2]});
  });

  test('decoding is total', () {
    final n = Node.fromJson({
      'type': 'row',
      'opacity': 'lots',
      'children': [1, 'a', null],
      'layout': {'width': {'stretchy': 'x'}, 'height': -5, 'flex': 'two', 'margin': [1, 2], 'x': 7},
      'props': {'mainAxisAlignment': 'sideways', 'spacing': -3, 'wrap': 'true'},
      'decoration': {'fills': [{'type': 'solid', 'color': 'not a color'}, 5], 'radius': [1, 2, 3]},
    }, id: 'r')!;
    expect(n.opacity, 1);
    expect(n.children, ['a']);
    expect(n.layout.width, const AxisSize.fixed(0));
    expect(n.layout.height, const AxisSize.fixed(0));
    expect(n.layout.flex, 1);
    expect(n.layout.margin, EdgeInsets.zero);
    expect(n.prop(FlexProps.mainAxisAlignment), MainAxisAlignment.start);
    expect(n.prop(FlexProps.spacing), 0);
    expect(n.prop(FlexProps.wrap), true);
    expect(n.decoration.fills.single.color, isNull);
    expect(n.decoration.radius, BorderRadius.zero);
    expect(Node.fromJson({'name': 'no type'}), isNull);
    expect(LayoutDocument.fromJson('garbage').nodes, isEmpty);
  });

  test('sparse: defaults are not written', () {
    const n = Node(id: 'a', type: 'row');
    final m = n.withProp(FlexProps.mainAxisAlignment, MainAxisAlignment.start);
    expect(m, n);
    expect(m.toJson(), {'id': 'a', 'type': 'row', 'layout': {'width': 0, 'height': 0}});
    final c = n.withProp(FlexProps.mainAxisAlignment, MainAxisAlignment.center);
    expect(c == n, isFalse);
    expect(c.toJson()['props'], {'mainAxisAlignment': 'center'});
  });
}
