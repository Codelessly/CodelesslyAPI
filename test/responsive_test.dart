// Responsive patches (a node's fields per breakpoint) and the flex node.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

Json doc(Json nodes, {List<String> roots = const ['c']}) => {
      'schema': 2,
      'roots': roots,
      'nodes': {
        'c': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'f'}},
        ...nodes,
      },
    };

List<String> codesOf(Json d) => [for (final x in validateDocument(d)) '${x.code.name} ${x.path}'];

void main() {
  final bps = Breakpoints.defaults;
  Breakpoint at(String id) => bps.byId(id)!;

  group('conditions (ResponsiveFramework vocabulary, by named breakpoint)', () {
    ResponsivePatch p(Json j) => ResponsivePatch.fromJson({...j, 'patch': {}})!;
    test('equals, largerThan, smallerThan, between', () {
      expect([for (final b in bps.list) p({'equals': 'tablet'}).holds(b, bps)], [false, true, false]);
      expect([for (final b in bps.list) p({'largerThan': 'mobile'}).holds(b, bps)], [false, true, true]);
      expect([for (final b in bps.list) p({'smallerThan': 'desktop'}).holds(b, bps)], [true, true, false]);
      expect([for (final b in bps.list) p({'between': ['mobile', 'tablet']}).holds(b, bps)], [true, true, false]);
      expect(p({'equals': 'nope'}).holds(at('mobile'), bps), isFalse);
    });
  });

  test('a node at a breakpoint: patches that hold, merged in order (later wins)', () {
    final n = Node.fromJson({
      'type': 'flex',
      'children': ['a', 'b'],
      'layout': {'width': {'fill': 100}, 'height': {'hug': 10}, 'padding': 40},
      'props': {'spacing': 24},
      'responsive': [
        {'smallerThan': 'desktop', 'patch': {'props': {'spacing': 16}, 'layout': {'padding': 24}}},
        {'equals': 'mobile', 'patch': {'props': {'direction': 'vertical'}, 'children': ['b', 'a'], 'layout': {'padding': 16}}},
      ],
    }, id: 'f')!;
    expect(n.toJson()['responsive'], isA<List>(), reason: 'round-trips');
    expect(Node.fromJson(n.toJson(), id: 'f'), n);
    final desk = n.atBreakpoint(at('desktop'), bps);
    expect(desk, n);
    final tab = n.atBreakpoint(at('tablet'), bps);
    expect(tab.prop(FlexProps.spacing), 16);
    expect(tab.layout.padding, const EdgeInsets.all(24));
    expect(flexAxisOf(tab), Axis.horizontal);
    final mob = n.atBreakpoint(at('mobile'), bps);
    expect(flexAxisOf(mob), Axis.vertical);
    expect(mob.children, ['b', 'a']);
    expect(mob.prop(FlexProps.spacing), 16);
    expect(mob.layout.padding, const EdgeInsets.all(16));
    expect(mob.layout.width, n.layout.width, reason: 'unpatched fields stay');
  });

  test('row and column are flex with a fixed direction; flex lets a child fill its main axis', () {
    expect(flexAxisOf(Node(id: 'r', type: 'row')), Axis.horizontal);
    expect(flexAxisOf(Node(id: 'r', type: 'column')), Axis.vertical);
    final v = Node.fromJson({'type': 'flex', 'props': {'direction': 'vertical'}}, id: 'f')!;
    expect(allowedChildFits(v, horizontal: false), contains(SizeFit.flexible));
    expect(allowedChildFits(v, horizontal: true), isNot(contains(SizeFit.flexible)));
  });

  group('validation', () {
    Json base(Object? responsive) => doc({
          'f': {
            'type': 'flex',
            'children': ['a', 'b'],
            'layout': {'width': {'fill': 390}, 'height': {'hug': 20}},
            'responsive': responsive,
            'bind': {'props.spacing': r'${= 4}'},
          },
          'a': {'type': 'box', 'layout': {'width': 10, 'height': 10}},
          'b': {'type': 'box', 'layout': {'width': 10, 'height': 10}},
        });

    test('a clean patch validates', () {
      expect(codesOf(base([
        {'smallerThan': 'tablet', 'patch': {'props': {'direction': 'vertical'}, 'children': ['b', 'a'], 'layout': {'padding': 8}}},
      ])), isEmpty);
    });

    test('values in a patch are type-checked as the node\'s own', () {
      expect(codesOf(base([
        {'equals': 'mobile', 'patch': {'props': {'direction': 'sideways', 'spacng': 3}, 'layout': {'padding': [1, 2]}}},
      ])), containsAll([
        'invalid_enum /nodes/f/responsive/0/patch/props/direction',
        'unknown_prop /nodes/f/responsive/0/patch/props/spacng',
      ]));
    });

    test('conditions, breakpoint names, patch keys, children', () {
      final c = codesOf(base([
        {'patch': {'props': {}}},
        {'equals': 'phone', 'patch': {}},
        {'largerThan': 'mobile', 'smallerThan': 'desktop', 'patch': {}},
        {'equals': 'mobile', 'patch': {'bind': {}, 'children': ['a']}},
        {'equals': 'mobile', 'patch': {'props': {'spacing': 2}}},
        'x',
      ]));
      expect(c, containsAll([
        'invalid_responsive /nodes/f/responsive/0',
        'unknown_breakpoint /nodes/f/responsive/1/equals',
        'invalid_responsive /nodes/f/responsive/2',
        'invalid_responsive /nodes/f/responsive/3/patch/bind',
        'invalid_responsive /nodes/f/responsive/3/patch/children',
        'responsive_overridden /nodes/f/responsive/4/patch',
        'invalid_responsive /nodes/f/responsive/5',
      ]));
    });
  });
}
