import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

// An aspect ratio keeps its precision in JSON (Strata v2: 320/180 stored as
// 1.7778 made a 300 px drawing 168.748 tall, and the text below it landed on
// the other side of a device pixel from the reference's).

void main() {
  test('a position given as a number is its distance from the start', () {
    // DESIGN.md: layout.x / layout.y take a distance from the start or a
    // position map; a bound `layout.x` of 42 used to place the node at 0.
    expect(AxisPosition.fromJson(42), const AxisPosition.start(42));
    expect(AxisPosition.fromJson(12.5), const AxisPosition.start(12.5));
    expect(AxisPosition.fromJson({'start': 3}), const AxisPosition.start(3));
    expect(AxisPosition.fromJson({'align': 0}), const AxisPosition.align(0));
    expect(AxisPosition.fromJson(null), AxisPosition.zero);
    final l = Layout.fromJson({'x': 42, 'y': 7});
    expect(l.x, const AxisPosition.start(42));
    expect(l.y, const AxisPosition.start(7));
  });

  final docJson = <String, Object?>{
    'schema': 3,
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

  test('a document round-trips through JSON exactly', () {
    final doc = LayoutDocument.fromJson(docJson);
    final out = doc.toJson();
    expect(jsonDecode(jsonEncode(out)), jsonDecode(jsonEncode(docJson)));
    expect(LayoutDocument.fromJson(out).nodes, doc.nodes);
  });

  test('each node knows its parent from the children lists', () {
    final doc = LayoutDocument.fromJson(docJson);
    expect(doc.parentOf('col'), 'c');
    expect(doc.parentOf('t'), 'col');
    expect(doc.parentOf('c'), isNull);
    expect(doc.subtree('c').map((n) => n.id), ['c', 'col', 't', 'x']);
  });

  test('a node of an unknown type and unknown keys survive a round trip', () {
    final x = LayoutDocument.fromJson(docJson)['x']!;
    expect(x.spec, isNull);
    expect(x.extra, {'hello': 1});
    expect(x.toJson()['props'], {'whatever': [1, 2]});
  });

  test('a document with bad values still loads, each falling back to its default', () {
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

  test('values left at their defaults are not written to JSON', () {
    const n = Node(id: 'a', type: 'row');
    final m = n.withProp(FlexProps.mainAxisAlignment, MainAxisAlignment.start);
    expect(m, n);
    expect(m.toJson(), {'id': 'a', 'type': 'row', 'layout': {'width': 0, 'height': 0}});
    final c = n.withProp(FlexProps.mainAxisAlignment, MainAxisAlignment.center);
    expect(c == n, isFalse);
    expect(c.toJson()['props'], {'mainAxisAlignment': 'center'});
  });

  group('setting a prop', () {
    const row = Node(id: 'r', type: 'row');

    test('a whole number given to a decimal prop is stored as a decimal', () {
      // T infers as num here: the declaration decides the stored type.
      final n = row.withProp(FlexProps.spacing, 31);
      expect(n.prop(FlexProps.spacing), isA<double>());
      expect(n.prop(FlexProps.spacing), 31.0);
      expect(n, row.withProp(FlexProps.spacing, 31.0));
      expect(n.toJson()['props'], {'spacing': 31});
    });

    test('a JSON value is decoded, and a default or null clears the prop', () {
      final n = row.withProp<Object?>(FlexProps.mainAxisAlignment, 'center');
      expect(n.prop(FlexProps.mainAxisAlignment), MainAxisAlignment.center);
      expect(n.withProp<Object?>(FlexProps.mainAxisAlignment, 'start').props.isEmpty, isTrue);
      expect(row.withProp<Object?>(FlexProps.spacing, 4).withProp<Object?>(FlexProps.spacing, null).props.isEmpty, isTrue);
    });

    test('a value of the wrong type is refused', () {
      expect(() => row.withProp<Object?>(FlexProps.spacing, 'wide'), throwsArgumentError);
      expect(() => row.withProp<Object?>(FlexProps.mainAxisAlignment, CrossAxisAlignment.end), throwsArgumentError);
    });
  });

  test('a border radius has circular or elliptical corners and writes the shortest JSON', () {
    for (final (json, radius) in [
      (8, const BorderRadius.circular(8)),
      ([16, 8], const BorderRadius.elliptical(16, 8)),
      ([1, 2, 3, 4], const BorderRadius.only(topLeft: 1, topRight: 2, bottomRight: 3, bottomLeft: 4)),
      ([
        [16, 8],
        4,
        0,
        0
      ], const BorderRadius.only(topLeft: 16, topLeftY: 8, topRight: 4)),
    ]) {
      expect(BorderRadius.fromJson(json), radius, reason: '$json');
      expect(radius.toJson(), json);
    }
    // A Y equal to X is circular, given or not.
    expect(const BorderRadius.only(topLeft: 4, topLeftY: 4), const BorderRadius.only(topLeft: 4));
    expect(const BorderRadius.elliptical(16, 8).isCircular, isFalse);
    expect(const BorderRadius.elliptical(16, 8).topRightY, 8);
    expect(BorderRadius.fromJson([1, 'x']), BorderRadius.zero);
    expect(BindPaths.apply(const Node(id: 'b', type: 'box'), 'decoration.radius', [12, 6]).decoration.radius,
        const BorderRadius.elliptical(12, 6));
  });

  group('number precision', () {
    test('an aspect ratio keeps its full precision through JSON', () {
      const ratio = 320 / 180;
      final back = Layout.fromJson(const Layout(aspectRatio: ratio).toJson()).aspectRatio!;
      expect((300 / back - 168.75).abs(), lessThan(1e-8));
    });

    test('pixel values round to 4 decimals and whole ratios stay whole numbers', () {
      expect(writeDouble(1.23456789), 1.2346);
      expect(writeRatio(2.0), 2);
      expect(writeRatio(16 / 9), closeTo(16 / 9, 1e-12));
    });
  });
}
