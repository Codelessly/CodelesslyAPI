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
        'invalid_media /nodes/f/media/3/patch/children',
        'media_overridden /nodes/f/media/4/patch',
        'invalid_media /nodes/f/media/5',
        'invalid_media /nodes/f/media/6',
      ]));
    });

    test('a patch may bind at its sizes only, drop a binding, and move what is painted (motion)', () {
      Json withVisible(List<Object?> media) {
        final d = base(media);
        ((d['nodes'] as Map)['f'] as Map)['bind'] = {'visible': r'${= !open}'};
        return d;
      }
      // The rule sets visible, which the node binds: the binding wins, and
      // the warning names both ways out.
      final over = validateDocument(withVisible([
        {'minWidth': 600, 'patch': {'visible': true}},
      ]));
      expect([for (final d in over) d.code.name], ['media_overridden']);
      expect(over.single.message, contains('"bind": {"visible": null}'));
      // Dropping the binding at those sizes, or binding only there: clean.
      expect(codesOf(withVisible([
        {'minWidth': 600, 'patch': {'visible': true, 'bind': {'visible': null}}},
      ])), isEmpty);
      final d = base([
        {'maxWidth': 599, 'patch': {'bind': {'visible': r'${= !open}'}, 'motion': {'translateY': -36}}},
      ]);
      expect(codesOf(d), isEmpty);
      expect(codesOf(base([
        {'maxWidth': 599, 'patch': {'bind': {'visibel': r'${= 1}'}, 'motion': {'translateY': 'up'}}},
      ])), containsAll(['unknown_bind_path /nodes/f/media/0/patch/bind/visibel', 'wrong_type /nodes/f/media/0/patch/motion/translateY']));
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

    test('validation accepts the mode change and the documented null, and judges the patched size', () {
      final d = doc({
        'f': {'type': 'column', 'children': ['b'], 'layout': {'width': {'fill': 390}, 'height': {'hug': 60}}, 'props': {'crossAxisAlignment': 'start'}},
        'b': {
          'type': 'row',
          'layout': {'width': {'fill': 292}, 'height': 52},
          'media': [
            {'minWidth': 'tablet', 'patch': {'layout': {'width': {'fill': null, 'hug': 200}}}},
            {'minWidth': 'desktop', 'patch': {'layout': {'width': {'hug': 232}, 'margin': null}, 'opacity': null}},
          ],
        },
      });
      expect(codesOf(d), isEmpty);
    });
  });

  group('fits are judged at each screen width, with the media rules that hold there', () {
    // A comparison table: its row of plan columns scrolls sideways on phones
    // only; the columns are fixed there and fill from tablet up.
    Json table({bool baseScrolls = true}) => doc({
          'f': {'type': 'column', 'children': ['plans'], 'layout': {'width': {'fill': 390}, 'height': {'hug': 60}}},
          'plans': {
            'type': 'row',
            'children': ['p1'],
            'layout': {'width': {'fill': 390}, 'height': {'hug': 60}},
            'props': {'scrollable': baseScrolls, 'scrollDirection': 'horizontal'},
            'media': [
              {'minWidth': 'tablet', 'patch': {'props': {'scrollable': !baseScrolls}}},
            ],
          },
          'p1': {
            'type': 'column',
            'layout': {'width': 128, 'height': {'hug': 40}},
            'media': [
              {'minWidth': 'tablet', 'patch': {'layout': {'width': {'fill': 220}}}},
            ],
          },
        });

    test('a child patch is checked against the parent as patched at the same widths', () {
      expect(codesOf(table()), isEmpty, reason: 'the row stops scrolling where the column starts to fill');
    });

    test('a true finding names the widths where it holds, at the value in effect', () {
      final d = table(baseScrolls: false);
      // Now the row scrolls from tablet up, where the column fills.
      final found = validateDocument(d).where((x) => x.code == Codes.fitNotAllowed).toList();
      expect(found.map((x) => x.path), ['/nodes/p1/media/0/patch/layout/width']);
      expect(found.single.message, contains('at screen widths from 600 px'));
      // A base value replaced at every width it is wrong is not reported.
      final e = table(baseScrolls: false);
      ((e['nodes'] as Map)['p1'] as Map)['layout'] = {'width': {'fill': 128}, 'height': {'hug': 40}};
      ((e['nodes'] as Map)['p1'] as Map)['media'] = [
        {'maxWidth': 599, 'patch': {'layout': {'width': 128}}},
      ];
      ((e['nodes'] as Map)['plans'] as Map)['props'] = {'scrollable': false, 'scrollDirection': 'horizontal'};
      ((e['nodes'] as Map)['plans'] as Map)['media'] = [
        {'maxWidth': 599, 'patch': {'props': {'scrollable': true}}},
      ];
      expect(codesOf(e), isEmpty);
    });

    test('flexible follows a flex whose direction changes: reported only where it is across', () {
      final d = doc({
        'f': {
          'type': 'flex',
          'children': ['b'],
          'layout': {'width': {'fill': 390}, 'height': {'hug': 60}},
          'props': {'direction': 'vertical'},
          'media': [
            {'minWidth': 'tablet', 'patch': {'props': {'direction': 'horizontal'}}},
          ],
        },
        'b': {'type': 'box', 'layout': {'width': {'flexible': 300}, 'height': 40}},
      });
      final found = validateDocument(d).where((x) => x.code == Codes.fitNotAllowed).toList();
      expect(found.map((x) => x.path), ['/nodes/b/layout/width']);
      expect(found.single.message, contains('at screen widths up to 599 px'));
      final e = Map<String, Object?>.from(d);
      ((e['nodes'] as Map)['b'] as Map)['media'] = [
        {'maxWidth': 'mobile', 'patch': {'layout': {'width': {'fill': 300}}}},
      ];
      expect(codesOf(e), isEmpty, reason: 'flexible in a flex where it is the main axis, as in a row');
    });
  });
}
