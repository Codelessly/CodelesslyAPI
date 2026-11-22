// An `each` written where lines are spaced (a Column or a Row with a gap,
// a design system's block whose children slot is in a spaced row or column,
// a writer's word that passes its lines on) spaces its copies by that
// place's gap, as the copies written out one by one would be. (Under a
// block the list was one child of the slot with no spacing of its own:
// the task cards of a board's column touched.)
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _block(String type, {required String holder, num? spacing, bool grid = false}) => {
      'schema': 3,
      'id': type,
      'roots': ['r'],
      'widget': {
        'type': type,
        'doc': 'What a $type is for.',
        'props': [
          {'key': 'title', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': ''},
        ],
        'children': 'list',
      },
      'nodes': {
        'r': {
          'type': 'column',
          'layout': {'width': {'fill': 200}, 'height': {'hug': 0}},
          'props': {'spacing': 4},
          'children': ['head', 'body'],
        },
        'head': {'type': 'text', 'props': {'text': 'Head'}},
        'body': {
          'type': holder,
          'layout': {'width': {'fill': 200}, 'height': {'hug': 0}},
          if (spacing != null) 'props': {'spacing': spacing},
          'children': ['c'],
        },
        'c': {'type': 'slot'},
      },
    };

void main() {
  late DesignSystem ds;
  late Catalog catalog;
  setUp(() async {
    final files = {
      'design_system.json': jsonEncode({
        'id': 'acme',
        'name': 'Acme',
        'theme': {'primary': '#FF2563EB', 'onSurface': '#FF111827'},
        'components': ['components/BoardColumn.json', 'components/Strip.json', 'components/Bare.json', 'components/Tile.json'],
      }),
      'components/BoardColumn.json': jsonEncode(_block('BoardColumn', holder: 'column', spacing: 10)),
      'components/Strip.json': jsonEncode(_block('Strip', holder: 'row', spacing: 6)),
      'components/Bare.json': jsonEncode(_block('Bare', holder: 'column')),
      // Its named slot is in a spaced row; its children slot in a column with no gap.
      'components/Tile.json': jsonEncode({
        ..._block('Tile', holder: 'column'),
        'nodes': {
          ...(_block('Tile', holder: 'column')['nodes']! as Map),
          'r': {'type': 'column', 'layout': {'width': {'fill': 200}, 'height': {'hug': 0}}, 'children': ['foot', 'body']},
          'foot': {'type': 'row', 'props': {'spacing': 8}, 'children': ['a']},
          'a': {'type': 'slot', 'props': {'name': 'actions'}},
        },
      }),
    };
    final problems = <String>[];
    ds = await DesignSystem.load((ref) async => files[ref], problems: problems);
    expect(problems, isEmpty);
    catalog = ds.catalogOver(standardCatalog);
  });

  NotationResult parse(String text) => Catalog.run(catalog, () => parseNotation(text, catalog: catalog, options: NotationOptions.fromDesignSystem(ds, width: 1440)));
  List<Map> lists(NotationResult r) => [
        for (final n in (r.document['nodes'] as Map).values)
          if ((n as Map)['type'] == 'listView' || n['type'] == 'gridView') n,
      ];
  Map props(Map list) => list['props'] as Map;

  const state = 'state cards=[{"id":1,"col":"a","t":"x"},{"id":2,"col":"a","t":"y"}]\nstate cols=[{"key":"a"}]\n';

  test('the options know the gap of the place a block\'s lines go in', () {
    final o = NotationOptions.fromDesignSystem(ds, width: 1440);
    expect(o.frameGaps, {'BoardColumn': 10, 'Strip': 6});
    expect(o.frameRows, {'Strip'});
  });

  test('a board\'s cards under its column (the shape that touched): spaced by the slot\'s gap, beside other lines too', () {
    final r = parse('''
${state}Row gap=12 top
  each col in cols
    BoardColumn "{col.key}" w=280
      Row end
        IconButton "more_horiz" tooltip="Column menu"
      each c in filter(cards,x=>x.col==col.key)
        Card
          Text "{c.t}"
      Box pad=6
        Text "Drop here"
''');
    expect(r.issues, isEmpty);
    final inner = lists(r).singleWhere((l) => '${(l['bind'] as Map)['data']}'.contains('filter(cards'));
    expect(props(inner)['spacing'], 10);
    expect(props(inner)['scrollDirection'], isNull);
    // The list of columns takes its own row's gap, as it did.
    expect(props(lists(r).singleWhere((l) => !identical(l, inner)))['spacing'], 12);
  });

  test('alone under the block, under an if, reordered and following: the same gap; a gap written on a following each wins', () {
    for (final (line, more) in [
      ('each c in cards', ''),
      ('each c in cards reorder', '\n      Handle'),
      ('each c in cards follow h=200', ''),
    ]) {
      final r = parse('${state}Column\n  BoardColumn "A"\n    $line\n      Text "{c.t}"$more\n');
      expect(r.issues, isEmpty, reason: line);
      expect(props(lists(r).single)['spacing'], 10, reason: line);
    }
    final under = parse('${state}state on=true\nColumn\n  BoardColumn "A"\n    if on\n      each c in cards\n        Text "{c.t}"\n');
    expect(props(lists(under).single)['spacing'], 10);
    final own = parse('${state}Column\n  BoardColumn "A"\n    each c in cards follow h=200 gap=2\n      Text "{c.t}"\n');
    expect(props(lists(own).single)['spacing'], 2);
  });

  test('a slot that is a row: the copies go across, spaced by its gap', () {
    final r = parse('${state}Column\n  Strip "A"\n    each c in cards\n      Text "{c.t}"\n');
    expect(r.issues, isEmpty);
    expect(props(lists(r).single), allOf(containsPair('spacing', 6), containsPair('scrollDirection', 'horizontal'), containsPair('scrollable', false)));
  });

  test('a block whose place has no gap, and a Grid under a block: as they were', () {
    final bare = parse('${state}Column\n  Bare "A"\n    each c in cards\n      Text "{c.t}"\n');
    expect(props(lists(bare).single)['spacing'], 0);
    final grid = parse('${state}Column\n  BoardColumn "A"\n    Grid cols=2 gap=8\n      each c in cards\n        Text "{c.t}"\n');
    expect(grid.issues, isEmpty);
    final g = lists(grid).single;
    expect(g['type'], 'gridView');
    expect(props(g), allOf(containsPair('mainAxisSpacing', 8), containsPair('crossAxisSpacing', 8)));
    expect(props(g).containsKey('spacing'), isFalse);
  });

  test('a writer\'s word that passes its lines on to a block, and one whose own Column holds them', () {
    final passed = parse('''
define Lane "title"
  BoardColumn "{title}"
    ...
${state}Column
  Lane "A"
    each c in cards
      Text "{c.t}"
''');
    expect(passed.issues, isEmpty);
    expect(props(lists(passed).single)['spacing'], 10);
    final own = parse('''
define Stack2 "title"
  Column gap=14
    Text "{title}"
    ...
${state}Column
  Stack2 "A"
    each c in cards
      Text "{c.t}"
''');
    expect(own.issues, isEmpty);
    expect(props(lists(own).single)['spacing'], 14);
  });

  test('the plain case, as it was: an each under a Column or a Row with a gap, alone or beside other lines', () {
    for (final (parent, key) in [('Column gap=10', null), ('Row gap=10', 'horizontal')]) {
      for (final beside in ['', '  Text "first"\n']) {
        final r = parseNotation('$state$parent\n$beside  each c in cards\n    Text "{c.t}"\n', catalog: standardCatalog, options: const NotationOptions(width: 1440));
        expect(r.issues, isEmpty);
        expect(props(lists(r).single)['spacing'], 10, reason: '$parent $beside');
        expect(props(lists(r).single)['scrollDirection'], key, reason: parent);
      }
    }
  });
}
