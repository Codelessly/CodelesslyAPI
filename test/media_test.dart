// Media rules (a node's fields by screen size, as CSS media queries), the
// flex node, and the CSS flex-item fields (order, basis).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Json doc(Json nodes) => {
      'schema': 3,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'f'}},
        ...nodes,
      },
    };

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

  group('a patch', () {
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

    test('a patch may bind at its sizes only, drop a binding, and move what is painted (motion)', () {
      Json withVisible(List<Object?> media) {
        final d = base(media);
        ((d['nodes'] as Map)['f'] as Map)['bind'] = {'visible': r'${= !open}'};
        return d;
      }
      final d = base([
        {'maxWidth': 599, 'patch': {'bind': {'visible': r'${= !open}'}, 'motion': {'translateY': -36}}},
      ]);
      // On a screen the patch's binding and transform apply.
      final n = Node.fromJson((d['nodes'] as Map)['f'], id: 'f')!;
      final narrow = n.atScreen(390, 844, bps);
      expect(narrow.bind['visible'], r'${= !open}');
      expect(narrow.behaviors.motion?.translateY, -36);
      expect(n.atScreen(1440, 900, bps).bind.containsKey('visible'), isFalse);
      final dropped = Node.fromJson({...?((withVisible([
        {'minWidth': 600, 'patch': {'visible': true, 'bind': {'visible': null}}},
      ])['nodes'] as Map)['f'] as Map?)}, id: 'f')!.atScreen(1440, 900, bps);
      expect((dropped.visible, dropped.bind.containsKey('visible')), (true, false));
    });
  });

  group('a patch replaces a value written in another form (as CSS replaces a declaration)', () {
    test('a size changes mode; null removes a key, as documented', () {
      final n = Node.fromJson({
        'type': 'row',
        'layout': {'width': {'fill': 292}, 'height': 52, 'x': {'align': 0}, 'constraints': {'minWidth': 10, 'maxWidth': 400}},
        'media': [
          {'minWidth': 'tablet', 'patch': {'layout': {'width': {'hug': 200}}}},
          {'minWidth': 'desktop', 'patch': {'layout': {'width': {'fill': null, 'hug': 232}, 'constraints': {'maxWidth': null}}}},
        ],
      }, id: 'b')!;
      expect(n.atScreen(390, 844, bps).layout.width, const AxisSize.fill(292));
      expect(n.atScreen(834, 1112, bps).layout.width, const AxisSize.hug(200), reason: 'was {"fill", "hug"}: no size');
      final desk = n.atScreen(1440, 900, bps);
      expect(desk.layout.width, const AxisSize.hug(232));
      expect(desk.layout.constraints.maxWidth, isNull, reason: 'null removes maxWidth');
      expect(desk.layout.constraints.minWidth, 10, reason: 'constraints are separate fields: they merge');
    });

    test('positions, paints, icons and borders replace across forms and merge within one', () {
      Json m(Json base, Json patch, {List<PropDef<Object?>>? props}) => mergeNodePatch(base, patch, props: props);
      expect(m({'layout': {'x': {'align': 0}}}, {'layout': {'x': {'start': 8}}}), {'layout': {'x': {'start': 8}}});
      expect(m({'layout': {'x': {'start': 0, 'end': 0}}}, {'layout': {'x': {'start': 8}}}), {'layout': {'x': {'start': 8, 'end': 0}}},
          reason: 'edges are one form: they merge (as CSS left/right)');
      final text = TextProps.spec.props;
      expect(
          m({'props': {'style': {'foreground': {'type': 'linear', 'stops': []}}}}, {'props': {'style': {'foreground': {'type': 'solid', 'color': '#FF000000'}}}},
              props: text),
          {'props': {'style': {'foreground': {'type': 'solid', 'color': '#FF000000'}}}});
      expect(
          m({'props': {'style': {'foreground': {'type': 'solid', 'color': '#FF000000', 'opacity': 0.5}}}}, {'props': {'style': {'foreground': {'color': '#FFFFFFFF'}}}},
              props: text),
          {'props': {'style': {'foreground': {'type': 'solid', 'color': '#FFFFFFFF', 'opacity': 0.5}}}},
          reason: 'the same form merges');
      final icon = IconProps.spec.props;
      expect(m({'props': {'icon': {'type': 'MATERIAL_ICON', 'name': 'add'}}}, {'props': {'icon': {'type': 'SVG', 'svg': '<svg/>'}}}, props: icon),
          {'props': {'icon': {'type': 'SVG', 'svg': '<svg/>'}}});
      // Two patches merged into one (a media cascade, active states) keep
      // the later form too.
      expect(mergeNodePatch({'layout': {'width': {'fill': 1}}}, {'layout': {'width': {'hug': 2}}}, keepNulls: true),
          {'layout': {'width': {'hug': 2}}});
    });
  });
}
