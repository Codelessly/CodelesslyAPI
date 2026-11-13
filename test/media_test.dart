// Media rules (a node's fields by screen size, as CSS media queries), the
// flex node, and the CSS flex-item fields (order, basis).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

Json doc(Json nodes) => {
      'schema': 2,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'f'}},
        ...nodes,
      },
    };

List<String> codesOf(Json d) => [for (final x in validateDocument(d)) '${x.code.name} ${x.path}'];

void main() {
  final bps = Breakpoints.defaults; // mobile 0, tablet 600, desktop 1024

  group('conditions hold as CSS media queries', () {
    MediaRule r(Json j) => MediaRule.fromJson({...j, 'patch': {}})!;
    bool at(MediaRule m, double w, [double? h]) => m.holds(w, h, bps);
    test('min-width and max-width in px are inclusive', () {
      expect([for (final w in [599.0, 600.0, 601.0]) at(r({'minWidth': 600}), w)], [false, true, true]);
      expect([for (final w in [599.0, 600.0, 601.0]) at(r({'maxWidth': 600}), w)], [true, true, false]);
    });
    test('a breakpoint name: minWidth from its min width, maxWidth up to the next one', () {
      expect([for (final w in [599.0, 600.0, 1023.0, 1024.0]) at(r({'minWidth': 'tablet'}), w)], [false, true, true, true]);
      expect([for (final w in [599.0, 600.0, 1023.0, 1024.0]) at(r({'maxWidth': 'tablet'}), w)], [true, true, true, false]);
      expect([for (final w in [599.0, 600.0]) at(r({'maxWidth': 'mobile'}), w)], [true, false]);
      expect([for (final w in [599.0, 600.0, 1023.0, 1024.0]) at(r({'minWidth': 'tablet', 'maxWidth': 'tablet'}), w)],
          [false, true, true, false]);
    });
    test('orientation; an unknown name never holds; no condition never holds', () {
      expect(at(r({'orientation': 'portrait'}), 390, 844), isTrue);
      expect(at(r({'orientation': 'portrait'}), 1440, 900), isFalse);
      expect(at(r({'minWidth': 'phablet'}), 2000), isFalse);
      expect(at(r({}), 400), isFalse);
    });
  });

  test('a node on a screen: rules that hold merge in order, the later winning (the CSS cascade)', () {
    final n = Node.fromJson({
      'type': 'flex',
      'children': ['a', 'b'],
      'layout': {'width': {'fill': 100}, 'height': {'hug': 10}, 'padding': 40},
      'props': {'spacing': 24},
      'media': [
        {'maxWidth': 'tablet', 'patch': {'props': {'spacing': 16}, 'layout': {'padding': 24}}},
        {'maxWidth': 599, 'patch': {'props': {'direction': 'vertical'}, 'layout': {'padding': 16}}},
      ],
    }, id: 'f')!;
    expect(Node.fromJson(n.toJson(), id: 'f'), n, reason: 'round-trips');
    expect(n.atScreen(1440, 900, bps), n);
    final tab = n.atScreen(834, 1112, bps);
    expect(tab.prop(FlexProps.spacing), 16);
    expect(tab.layout.padding, const EdgeInsets.all(24));
    expect(flexAxisOf(tab), Axis.horizontal);
    final mob = n.atScreen(390, 844, bps);
    expect(flexAxisOf(mob), Axis.vertical);
    expect(mob.prop(FlexProps.spacing), 16);
    expect(mob.layout.padding, const EdgeInsets.all(16));
    expect(mob.layout.width, n.layout.width, reason: 'unpatched fields stay');
  });

  test('row and column are flex with a fixed direction', () {
    expect(flexAxisOf(const Node(id: 'r', type: 'row')), Axis.horizontal);
    expect(flexAxisOf(const Node(id: 'r', type: 'column')), Axis.vertical);
    final v = Node.fromJson({'type': 'flex', 'props': {'direction': 'vertical'}}, id: 'f')!;
    expect(allowedChildFits(v, horizontal: false), contains(SizeFit.flexible));
    expect(allowedChildFits(v, horizontal: true), isNot(contains(SizeFit.flexible)));
  });

  test('order and basis round-trip in layout', () {
    final l = Layout.fromJson({'width': 10, 'height': 10, 'order': -1, 'basis': 280});
    expect((l.order, l.basis), (-1, 280.0));
    expect(Layout.fromJson(l.toJson()), l);
    expect(const Layout().toJson().containsKey('order'), isFalse);
  });

  group('validation', () {
    Json base(Object? media, {Json? b}) => doc({
          'f': {
            'type': 'flex',
            'children': ['a', 'b'],
            'layout': {'width': {'fill': 390}, 'height': {'hug': 20}},
            'props': {'wrap': true},
            'media': media,
            'bind': {'props.spacing': r'${= 4}'},
          },
          'a': {'type': 'box', 'layout': {'width': 10, 'height': 10}},
          'b': b ?? {'type': 'box', 'layout': {'width': 10, 'height': 10}},
        });

    test('a clean rule validates', () {
      expect(codesOf(base([
        {'maxWidth': 'mobile', 'patch': {'props': {'direction': 'vertical'}, 'layout': {'padding': 8}}},
        {'minWidth': 600, 'maxWidth': 1023, 'orientation': 'landscape', 'patch': {'visible': false}},
      ])), isEmpty);
    });

    test('values in a patch are type-checked as the node\'s own', () {
      expect(codesOf(base([
        {'maxWidth': 600, 'patch': {'props': {'direction': 'sideways', 'spacng': 3}}},
      ])), containsAll([
        'invalid_enum /nodes/f/media/0/patch/props/direction',
        'unknown_prop /nodes/f/media/0/patch/props/spacng',
      ]));
    });

    test('conditions, names, keys, ranges, bindings', () {
      final c = codesOf(base([
        {'patch': {'props': {}}},
        {'minWidth': 'phone', 'patch': {}},
        {'smallerThan': 'desktop', 'patch': {}},
        {'maxWidth': 600, 'patch': {'bind': {}, 'children': ['b', 'a']}},
        {'maxWidth': 600, 'patch': {'props': {'spacing': 2}}},
        {'minWidth': 'desktop', 'maxWidth': 'mobile', 'patch': {}},
        'x',
      ]));
      expect(c, containsAll([
        'invalid_media /nodes/f/media/0',
        'unknown_breakpoint /nodes/f/media/1/minWidth',
        'invalid_media /nodes/f/media/2/smallerThan',
        'invalid_media /nodes/f/media/3/patch/bind',
        'invalid_media /nodes/f/media/3/patch/children',
        'media_overridden /nodes/f/media/4/patch',
        'invalid_media /nodes/f/media/5',
        'invalid_media /nodes/f/media/6',
      ]));
    });

    test('a filling child with a basis in a wrapping flex is allowed; basis without wrap is ignored', () {
      Map f(Json d) => (d['nodes'] as Map)['f'] as Map;
      Json noMedia(Json d) {
        f(d).remove('media');
        return d;
      }
      expect(codesOf(noMedia(base(null, b: {'type': 'box', 'layout': {'width': {'fill': 10}, 'height': 10, 'basis': 280}}))), isEmpty);
      expect(codesOf(noMedia(base(null, b: {'type': 'box', 'layout': {'width': {'fill': 10}, 'height': 10}}))),
          ['fit_not_allowed /nodes/b/layout/width']);
      final d = noMedia(base(null, b: {'type': 'box', 'layout': {'width': 10, 'height': 10, 'basis': 280}}));
      f(d)['props'] = {};
      expect(codesOf(d), ['layout_field_ignored /nodes/b/layout/basis']);
    });
  });
}
