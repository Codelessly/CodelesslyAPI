import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

Map<String, Object?> _canvas(String id, double w) => {
      'id': id, 'name': id, 'type': 'canvas', 'parentID': 'ROOT_NODE',
      'basicBoxLocal': {'x': 0, 'y': 0, 'width': w, 'height': 800},
      'properties': {'bodyId': '$id-b'}, 'children': ['$id-b'],
    };

Map<String, Object?> _frame(String id, String parent, {List<String> children = const []}) => {
      'id': id, 'name': id, 'type': 'frame', 'parentID': parent,
      'basicBoxLocal': {'x': 0, 'y': 0, 'width': 100, 'height': 100}, 'children': children,
    };

void main() {
  test("a responsive node's custom widths become its own switch points", () {
    final report = MigrationReport();
    final doc = migrateDocument({
      'rootNode': {'children': ['c']},
      'c': _canvas('c', 390),
      'c-b': _frame('c-b', 'c', children: ['v']),
      'v': {
        'id': 'v', 'name': 'v', 'type': 'variance', 'parentID': 'c-b',
        'basicBoxLocal': {'x': 0, 'y': 0, 'width': 100, 'height': 100},
        'variants': [
          {'id': 'm', 'name': 'Mobile', 'children': ['a'], 'breakpoint': 'mobile'},
          {'id': 'd', 'name': 'Desktop', 'children': ['b'], 'breakpoint': 'desktop'},
        ],
        'currentVariantId': 'm',
        'properties': {'tabletMinWidth': 600, 'desktopMinWidth': 1100},
      },
      'a': _frame('a', 'v'),
      'b': _frame('b', 'v'),
    }, report: report);
    final v = (doc['nodes'] as Map)['v'] as Map;
    final props = v['props'] as Map;
    // v1's breakpoint names are the default project breakpoints' ids.
    expect([for (final x in props['variants'] as List) (x as Map)['breakpoint']], ['mobile', 'desktop']);
    // Tablet at v1's own 600 needs no override.
    expect(props['minWidths'], {'desktop': 1100});
    expect(report.unmapped.keys.where((k) => k.startsWith('variance.')), isEmpty);
    expect(v.containsKey('extra'), isFalse);
  });

  test('a node without custom widths has none', () {
    expect(varianceMinWidths(), isEmpty);
    expect(varianceMinWidths(tabletMinWidth: 700), {'tablet': 700});
  });

  test('layout groups: each canvas gets the breakpoint its range starts in', () {
    final doc = migrateDocument({
      'rootNode': {'children': ['m', 't', 'd', 'solo']},
      'm': _canvas('m', 390), 'm-b': _frame('m-b', 'm'),
      't': _canvas('t', 834), 't-b': _frame('t-b', 't'),
      'd': _canvas('d', 1440), 'd-b': _frame('d-b', 'd'),
      'solo': _canvas('solo', 390), 'solo-b': _frame('solo-b', 'solo'),
    });
    final groups = migrateLayoutGroups(doc, {
      'g': [
        {'nodeId': 'd', 'lowerBound': 1024},
        {'nodeId': 'm', 'lowerBound': 0, 'upperBound': 767},
        {'nodeId': 't', 'lowerBound': 768, 'upperBound': 1023},
      ],
      'alone': [
        {'nodeId': 'solo'},
      ],
    });
    expect(groups['g'], [
      {'canvas': 'm', 'breakpoint': 'mobile'},
      // A v1 range from 768 is the tablet canvas, switching at its own 768.
      {'canvas': 't', 'breakpoint': 'tablet', 'minWidth': 768},
      {'canvas': 'd', 'breakpoint': 'desktop'},
    ]);
    expect(groups.containsKey('alone'), isFalse);
    final nodes = doc['nodes'] as Map;
    expect((nodes['t'] as Map)['props'], containsPair('breakpoint', 'tablet'));
    expect((nodes['t'] as Map)['props'], containsPair('screen', 'g'));
    expect((nodes['t'] as Map)['props'], containsPair('breakpointMinWidth', 768));
    expect((nodes['m'] as Map)['props'], isNot(contains('breakpointMinWidth')));
    expect(((nodes['solo'] as Map)['props'] as Map?) ?? const {}, isNot(contains('breakpoint')));
  });
}
