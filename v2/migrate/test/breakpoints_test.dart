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

Map<String, Object?> _variance(String id, String parent,
        {double? tablet, double? desktop, List<String> breakpoints = const ['mobile', 'desktop']}) =>
    {
      'id': id, 'name': id, 'type': 'variance', 'parentID': parent,
      'basicBoxLocal': {'x': 0, 'y': 0, 'width': 100, 'height': 100},
      'variants': [
        for (final b in breakpoints) {'id': '$id-$b', 'name': b, 'children': <String>[], 'breakpoint': b},
      ],
      'currentVariantId': '$id-${breakpoints.first}',
      'properties': {'tabletMinWidth': ?tablet, 'desktopMinWidth': ?desktop},
    };

/// A page of one canvas holding [variances].
Map<String, Object?> _page(List<Map<String, Object?>> variances, {String canvas = 'c'}) => {
      'rootNode': {'children': [canvas]},
      canvas: _canvas(canvas, 390),
      '$canvas-b': _frame('$canvas-b', canvas, children: [for (final v in variances) v['id'] as String]),
      for (final v in variances) v['id'] as String: v,
    };

Map<String, Object?>? _minWidths(Map<String, Object?> doc, String id) =>
    ((((doc['nodes'] as Map)[id] as Map)['props'] as Map)['minWidths'] as Map?)?.cast<String, Object?>();

List<Object?> _variantBreakpoints(Map<String, Object?> doc, String id) => [
      for (final v in (((doc['nodes'] as Map)[id] as Map)['props'] as Map)['variants'] as List) (v as Map)['breakpoint'],
    ];

List<(String, num)> _ids(MigratedBreakpoints b) => [for (final x in b.json) (x['id'] as String, (x['minWidth'] as num?) ?? 0)];

void main() {
  test('pages that switch nowhere else get the defaults', () {
    final b = migrateProjectBreakpoints([_page([_variance('v', 'c-b')])]);
    expect(b.isDefault, isTrue);
    expect(b.json, [
      {'id': 'mobile', 'name': 'Mobile', 'width': 390, 'height': 844},
      {'id': 'tablet', 'name': 'Tablet', 'minWidth': 600, 'width': 834, 'height': 1112},
      {'id': 'desktop', 'name': 'Desktop', 'minWidth': 1024, 'width': 1440, 'height': 900},
    ]);
    expect(b.added, isEmpty);
  });

  test("the most common widths are the project's tablet and desktop", () {
    final pages = [
      _page([_variance('a', 'c-b', desktop: 1100), _variance('b', 'c-b', desktop: 1100)]),
      _page([_variance('d', 'c-b')]),
    ];
    final b = migrateProjectBreakpoints(pages);
    // Two nodes switch to desktop at 1100, one at 1024: desktop is 1100,
    // and the node at 1024 keeps that as its own switch point.
    expect(_ids(b), [('mobile', 0), ('tablet', 600), ('desktop', 1100)]);
    expect(b.added, isEmpty);

    final first = migrateDocument(pages[0], breakpoints: b);
    expect(_variantBreakpoints(first, 'a'), ['mobile', 'desktop']);
    expect(_minWidths(first, 'a'), isNull, reason: 'switches where the project does');
    final second = migrateDocument(pages[1], breakpoints: b);
    expect(_variantBreakpoints(second, 'd'), ['mobile', 'desktop']);
    expect(_minWidths(second, 'd'), {'desktop': 1024});
    // Without the project's set: against the defaults, as before.
    expect(_minWidths(migrateDocument(pages[0]), 'a'), {'desktop': 1100});
  });

  test('disagreeing tablet widths: each v1 switch point is a breakpoint', () {
    final b = migrateProjectBreakpoints([
      _page([
        _variance('a', 'c-b', tablet: 700, breakpoints: ['mobile', 'tablet', 'desktop']),
        _variance('b', 'c-b', tablet: 700, breakpoints: ['mobile', 'tablet']),
        _variance('x', 'c-b', tablet: 500, breakpoints: ['mobile', 'tablet']),
      ]),
    ]);
    expect(_ids(b), [('mobile', 0), ('tablet', 700), ('desktop', 1024)]);
    expect(b.added, isEmpty);
    final doc = migrateDocument(_page([_variance('x', 'c-b', tablet: 500, breakpoints: ['mobile', 'tablet'])]), breakpoints: b);
    expect(_minWidths(doc, 'x'), {'tablet': 500});
    // A width only an unused class has doesn't count: b's desktop (1024)
    // is no switch point for it, x's 600 neither.
    expect(b.votes, {700: 2, 1024: 1, 500: 1});
  });

  test('a variance switching where it did, by the project set', () {
    final page = _page([_variance('v', 'c-b', tablet: 800, desktop: 1300, breakpoints: ['mobile', 'tablet', 'desktop'])]);
    final b = migrateProjectBreakpoints([page]);
    expect(_ids(b), [('mobile', 0), ('tablet', 800), ('desktop', 1300)]);
    final doc = migrateDocument(page, breakpoints: b);
    expect(_variantBreakpoints(doc, 'v'), ['mobile', 'tablet', 'desktop']);
    expect(_minWidths(doc, 'v'), isNull);
    // A tablet range v1 never showed (tablet at or above desktop): both
    // widths kept, so desktop stays at 1100.
    final empty = _page([_variance('e', 'c-b', tablet: 1200, desktop: 1100, breakpoints: ['mobile', 'tablet', 'desktop'])]);
    expect(_minWidths(migrateDocument(empty), 'e'), {'tablet': 1200, 'desktop': 1100});
  });

  test('a stored set reads back for later pages', () {
    final b = migrateProjectBreakpoints([_page([_variance('a', 'c-b', desktop: 1100)])]);
    final again = MigratedBreakpoints.fromJson(b.json);
    expect(again.json, b.json);
    expect(again.idAt(1100), 'desktop');
    expect(again.idNear(1050), 'tablet', reason: 'a width the set lacks: the one it falls in');
    expect(again.minWidthOf('desktop'), 1100);
    expect(MigratedBreakpoints.fromJson(null).isDefault, isTrue);
  });

  test('layout groups: each canvas gets the breakpoint its range starts at', () {
    final v1 = {
      'rootNode': {'children': ['m', 't', 'd', 'solo']},
      'm': _canvas('m', 390), 'm-b': _frame('m-b', 'm'),
      't': _canvas('t', 834), 't-b': _frame('t-b', 't'),
      'd': _canvas('d', 1440), 'd-b': _frame('d-b', 'd'),
      'solo': _canvas('solo', 390), 'solo-b': _frame('solo-b', 'solo'),
    };
    final groups = {
      'g': [
        {'nodeId': 'd', 'lowerBound': 1024},
        {'nodeId': 'm', 'lowerBound': 0, 'upperBound': 767},
        {'nodeId': 't', 'lowerBound': 768, 'upperBound': 1023},
      ],
      'alone': [
        {'nodeId': 'solo'},
      ],
    };
    final set = migrateProjectBreakpoints([v1], layoutGroups: [groups]);
    expect(_ids(set), [('mobile', 0), ('tablet', 768), ('desktop', 1024)]);
    final doc = migrateDocument(v1, breakpoints: set);
    final out = migrateLayoutGroups(doc, groups, breakpoints: set);
    expect(out['g'], [
      {'canvas': 'm', 'breakpoint': 'mobile'},
      {'canvas': 't', 'breakpoint': 'tablet'},
      {'canvas': 'd', 'breakpoint': 'desktop'},
    ]);
    expect(out.containsKey('alone'), isFalse);
    final nodes = doc['nodes'] as Map;
    expect((nodes['t'] as Map)['props'], containsPair('breakpoint', 'tablet'));
    expect((nodes['t'] as Map)['props'], containsPair('screen', 'g'));
    expect((nodes['t'] as Map)['props'], isNot(contains('breakpointMinWidth')));
    expect(((nodes['solo'] as Map)['props'] as Map?) ?? const {}, isNot(contains('breakpoint')));

    // Against the defaults, the tablet canvas keeps 768 as its own switch
    // point.
    final plain = migrateDocument(v1);
    expect(migrateLayoutGroups(plain, groups)['g'], [
      {'canvas': 'm', 'breakpoint': 'mobile'},
      {'canvas': 't', 'breakpoint': 'tablet', 'minWidth': 768},
      {'canvas': 'd', 'breakpoint': 'desktop'},
    ]);
    expect(((plain['nodes'] as Map)['t'] as Map)['props'], containsPair('breakpointMinWidth', 768));
  });

  test('a layout group with more canvases than breakpoints adds one', () {
    final v1 = {
      'rootNode': {'children': ['a', 'b', 'c', 'd']},
      for (final id in ['a', 'b', 'c', 'd']) ...{id: _canvas(id, 390), '$id-b': _frame('$id-b', id)},
    };
    final groups = {
      'g': [
        {'nodeId': 'a', 'lowerBound': 0},
        {'nodeId': 'b', 'lowerBound': 400},
        {'nodeId': 'c', 'lowerBound': 800},
        {'nodeId': 'd', 'lowerBound': 1200},
      ],
    };
    final set = migrateProjectBreakpoints([v1], layoutGroups: [groups]);
    // The group's own bounds vote: tablet at 800, desktop at 1200; the
    // 400 canvas has no breakpoint of its own left, so one is added there.
    expect(_ids(set), [('mobile', 0), ('mobile400', 400), ('tablet', 800), ('desktop', 1200)]);
    expect(set.added, ['mobile400']);
    final out = migrateLayoutGroups(migrateDocument(v1, breakpoints: set), groups, breakpoints: set);
    expect(out['g'], [
      {'canvas': 'a', 'breakpoint': 'mobile'},
      {'canvas': 'b', 'breakpoint': 'mobile400'},
      {'canvas': 'c', 'breakpoint': 'tablet'},
      {'canvas': 'd', 'breakpoint': 'desktop'},
    ]);
    // Against the defaults (no room): canvases shift up, keeping their
    // bounds as their own switch points; the last repeats the widest.
    expect(migrateLayoutGroups(migrateDocument(v1), groups)['g'], [
      {'canvas': 'a', 'breakpoint': 'mobile'},
      {'canvas': 'b', 'breakpoint': 'tablet', 'minWidth': 400},
      {'canvas': 'c', 'breakpoint': 'desktop', 'minWidth': 800},
      {'canvas': 'd', 'breakpoint': 'desktop', 'minWidth': 1200},
    ]);
  });

  test("formulas reading screen keep v1's global widths in the set", () {
    final page = _page([_variance('a', 'c-b', tablet: 768, breakpoints: ['mobile', 'tablet'])]);
    final c = page['c-b'] as Map<String, Object?>;
    page['c-b'] = {...c, 'variables': {'visible': r'${screen.isTablet}'}};
    final b = migrateProjectBreakpoints([page]);
    // 768 (the node) and 600 (the formula's) tie: 600 stays tablet, the
    // node keeps 768.
    expect(_ids(b), [('mobile', 0), ('tablet', 600), ('desktop', 1024)]);
    expect(_minWidths(migrateDocument(page, breakpoints: b), 'a'), {'tablet': 768});
  });

  test("an adaptive dialog's sheet width is a breakpoint reference", () {
    Map<String, Object?> page(double? sheetBelow) {
      // A node switching at v1's 600 and 1024 too.
      final p = _page([_variance('v', 'c-b', breakpoints: ['mobile', 'tablet', 'desktop'])]);
      final c = p['c-b'] as Map<String, Object?>;
      p['c-b'] = {
        ...c,
        'reactions': [
          {
            'trigger': {'type': 'click'},
            'action': {'type': 'showDialog', 'destinationId': 'x', 'presentation': 'adaptive', 'sheetBelowWidth': ?sheetBelow},
          },
        ],
      };
      return p;
    }

    Map<String, Object?> modal(Map<String, Object?> doc) {
      Map<String, Object?>? found;
      void walk(Object? v) {
        if (v is Map && v['type'] == 'openModal') found = v.cast<String, Object?>();
        if (v is Map) v.values.forEach(walk);
        if (v is List) v.forEach(walk);
      }

      walk(doc['nodes']);
      return found!;
    }

    // v1's 600: the breakpoint starting at 600, the default (the second).
    final plain = migrateDocument(page(null));
    expect(modal(plain).containsKey('sheetBelow'), isFalse);
    expect(modal(plain).containsKey('sheetBelowWidth'), isFalse);
    // A custom width: a breakpoint of the project at it.
    final custom = page(900);
    final set = migrateProjectBreakpoints([custom]);
    // An action has no switch points: the one case a project breakpoint
    // is added.
    expect(_ids(set), [('mobile', 0), ('tablet', 600), ('tablet900', 900), ('desktop', 1024)]);
    expect(set.added, ['tablet900']);
    expect(modal(migrateDocument(custom, breakpoints: set))['sheetBelow'], 'tablet900');
  });

  test("a toast's per-breakpoint look has an entry for every breakpoint", () {
    final p = _page([_variance('v', 'c-b', tablet: 700, breakpoints: ['mobile', 'tablet'])]);
    final c = p['c-b'] as Map<String, Object?>;
    p['c-b'] = {
      ...c,
      'reactions': [
        {
          'trigger': {'type': 'click'},
          'action': {'type': 'showToast', 'message': 'hi', 'alignments': {'mobile': 'start', 'tablet': 'end'}},
        },
      ],
    };
    final set = migrateProjectBreakpoints([p]);
    // The toast reads v1's global classes (600) and the node switches at
    // 700: one vote each, so tablet stays at 600; the node keeps 700.
    expect(_ids(set), [('mobile', 0), ('tablet', 600), ('desktop', 1024)]);
    Map? look;
    void walk(Object? v) {
      if (v is Map && v['type'] == 'showToast') look = v['look'] as Map?;
      if (v is Map) v.values.forEach(walk);
      if (v is List) v.forEach(walk);
    }

    walk(migrateDocument(p, breakpoints: set)['nodes']);
    expect(look!['alignments'], {'mobile': 'start', 'tablet': 'end'});
  });

  test('a v1 publish: the model carries the set its layouts need', () {
    final page = _page([_variance('v', 'c-b', desktop: 1200, breakpoints: ['mobile', 'desktop'])]);
    final layout = {
      'id': 'l',
      'canvases': {
        'c': {for (final e in page.entries) if (e.key != 'rootNode') e.key: e.value},
      },
    };
    final bundle = migratePublishModel({'projectId': 'p', 'layouts': {'l': layout}});
    final model = bundle['model'] as Map;
    expect([for (final b in model['breakpoints'] as List) (b as Map)['id']], ['mobile', 'tablet', 'desktop']);
    expect((model['breakpoints'] as List)[2], containsPair('minWidth', 1200));
    final l = (bundle['layouts'] as Map)['l'] as Map<String, Object?>;
    expect(_variantBreakpoints(l, 'v'), ['mobile', 'desktop']);
    expect(_minWidths(l, 'v'), isNull);
    // Given the project's set (from its pages), the publish uses it.
    final set = migrateProjectBreakpoints([page, _page([_variance('w', 'c-b', breakpoints: ['mobile', 'desktop'])])]);
    final withSet = migratePublishModel({'projectId': 'p', 'layouts': {'l': layout}}, breakpoints: set);
    final l2 = (withSet['layouts'] as Map)['l'] as Map<String, Object?>;
    expect(_ids(set), [('mobile', 0), ('tablet', 600), ('desktop', 1024)]);
    expect(_minWidths(l2, 'v'), {'desktop': 1200});
    // The defaults are stored as nothing.
    expect((migratePublishModel({'projectId': 'p', 'layouts': {}})['model'] as Map).containsKey('breakpoints'), isFalse);
  });
}
