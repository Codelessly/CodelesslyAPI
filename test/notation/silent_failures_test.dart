// What drew or behaved wrongly with nothing said, in a 30-part recreation of
// a production app in the notation (nocd/REGISTER.md, "Silent failures"),
// each fixed at its cause: made to work where the writer's form is the
// natural one, said at expand where it is not.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _expand(String text, {Catalog? catalog}) {
  final c = catalog ?? standardCatalog;
  return Catalog.run(c, () => parseNotation(text, catalog: c, options: const NotationOptions(width: 390, reflow: false)));
}

Map<String, Object?> _nodes(NotationResult r) => (r.document['nodes']! as Map).cast<String, Object?>();

Map<String, Object?> _node(NotationResult r, String id) => (_nodes(r)[id]! as Map).cast<String, Object?>();

List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];

List<Map<String, Object?>> _actions(NotationResult r, String id) => [
      for (final reaction in (_node(r, id)['actions'] as List?) ?? const [])
        for (final a in (reaction as Map)['actions'] as List) (a as Map).cast<String, Object?>(),
    ];

Map<String, Object?> _variable(NotationResult r, String name) => [
      for (final scope in (r.document['variables']! as Map).values)
        for (final v in scope as List)
          if ((v as Map)['name'] == name) v.cast<String, Object?>(),
    ].single;

void main() {
  group('a defined word', () {
    test('a parameter named like an id of its lines is the parameter where a value is read; #name is the id', () {
      final r = _expand('define PlayerBar expand=true\n  Row\n    if expand\n      Box#expand w=20 h=20 onTap={focus #expand}\nColumn\n  PlayerBar\n  PlayerBar expand=false\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      final shown = _nodes(r).entries.where((e) => e.key.startsWith('expand_')).toList();
      expect(shown, hasLength(1), reason: 'the second use hides it: ${_nodes(r).keys}');
      expect((shown.single.value! as Map)['bind'], isNull, reason: 'not bound to a variable named after the id');
    });

    test('a page variable read in a value beside an id of that name is the variable', () {
      final r = _expand('state therapists=[1,2]\ndefine Attach\n  Column\n    PageView#therapists h=100 data={therapists}\n      Text "{item}"\n    Button#go "x" onTap={scroll therapists}\nColumn\n  Attach\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      final view = _nodes(r).entries.singleWhere((e) => (e.value! as Map)['type'] == 'pageView');
      expect(view.key, 'therapists_attach1');
      expect(((view.value! as Map)['bind'] as Map)['data'], r'${therapists}');
      // An action's target is still the use's id.
      final scroll = _nodes(r).values.expand((n) => [for (final x in ((n! as Map)['actions'] as List?) ?? const []) ...((x as Map)['actions'] as List)]).single as Map;
      expect(scroll['node'], 'therapists_attach1');
    });

    test('{props.size} reads the word\'s own parameter, as a component\'s tree reads its', () {
      final r = _expand('define ChatAvatar label="" size=35\n  Stack w={props.size} h={size}\n    Text "{props.label}"\nColumn\n  ChatAvatar label="AB" size=40\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      final stack = _nodes(r).values.singleWhere((n) => (n! as Map)['type'] == 'stack')! as Map;
      expect(stack['layout'], containsPair('width', 40));
      expect(stack['bind'], isNull);
      final text = _nodes(r).values.singleWhere((n) => (n! as Map)['type'] == 'text')! as Map;
      expect((text['props'] as Map)['text'], 'AB');
    });
  });

  group('.length', () {
    test('of a component\'s parameter named length is that parameter', () {
      final r = _expand('component OrDivider\n  param length:double=243\nRow\n  Box w={props.length / 2} h=2 fill=#FF000000\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      final box = _nodes(r).values.singleWhere((n) => ((n! as Map)['bind'] as Map?)?.containsKey('layout.width') ?? false)! as Map;
      expect((box['bind'] as Map)['layout.width'], contains('props.length'));
      expect((box['bind'] as Map)['layout.width'], isNot(contains('length(props)')));
    });

    test('of a value not known as the page is read stays .length: a record\'s field when it has one', () {
      final r = _expand('component SessionRow\n  param session:Map={}\nRow\n  Text "{addMinutes(props.session.when, props.session.length)}"\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      final text = _nodes(r).values.singleWhere((n) => (n! as Map)['type'] == 'text')! as Map;
      expect((text['props'] as Map)['text'], contains('props.session.length'));
    });

    test('of a list is still its count', () {
      final r = _expand('state rows=[1,2]\nColumn\n  Text "{rows.length}"\n');
      expect(((_nodes(r).values.singleWhere((n) => (n! as Map)['type'] == 'text')! as Map)['props'] as Map)['text'], contains('length(rows)'));
    });
  });

  group('actions', () {
    test('a bound value in a field that takes a number written out is said, with the field that takes one', () {
      final r = _expand('state wait=2000\nColumn\n  Button "Go" onTap={delay ms={wait}; toast "x"}\n');
      expect(_said(r).single, allOf(contains('ms is a value written out'), contains('duration={…}')));
      final ok = _expand('state wait=2000\nColumn\n  Button "Go" onTap={delay duration={wait}; toast "x"}\n');
      expect(ok.issues, isEmpty, reason: '${_said(ok)}');
    });

    test('showDragHandle=false beside snapHeights is said: a sheet with stops always draws its grip', () {
      final r = _expand('state s=0\nColumn\n  Button "x" onTap={openModal to=more presentation=bottomSheet showDragHandle=false snapHeights=[0.5,0.6] stopVariable=s}\n');
      expect(_said(r), contains(contains('always draws its drag handle')));
    });
  });

  group('a sheet\'s stop', () {
    test('kept in a whole-number state is a decimal: the sheet writes 0.5', () {
      final r = _expand('state sheetStop=0\nColumn\n  Button#open "Read" onTap={open story}\nSheet#story "The tide" stops=[0.5,1] stop=@sheetStop\n  Text "x"\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      expect(_variable(r, 'sheetStop')['type'], 'decimal');
    });
  });

  group('fields', () {
    test('icon=none is no icon in the field', () {
      final r = _expand('state q=""\nColumn\n  Input#search hint="Search" icon=none @q\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      expect((_node(r, 'search')['props'] as Map)['decoration'], isNot(contains('prefixIcon')));
    });

    test('an inputFormatter of a kind no field applies is said', () {
      final r = _expand('state e=""\nColumn\n  Input#email @e inputFormatter={"type":"lowercase"}\n');
      expect(_said(r).single, contains('"lowercase" is not one'));
      final ok = _expand('state e=""\nColumn\n  Input#email @e inputFormatter={"type":"email"}\n');
      expect(ok.issues, isEmpty, reason: '${_said(ok)}');
    });
  });

  group('lists', () {
    test('GridView data={…} is a grid over the data, its line the cell', () {
      final r = _expand('Column\n  GridView#avatarGrid data={["UP","MO","AB"]} cols=3 gap=8\n    Box w=fill h=56\n      Text "{item}"\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      final grid = _node(r, 'avatarGrid');
      expect(grid['type'], 'gridView');
      expect((grid['bind'] as Map)['data'], contains('UP'));
    });

    test('a state named index read inside an each is said: there, index is the copy\'s place', () {
      final r = _expand('state index=1\nRow\n  each dot in [0,1,2]\n    Box w=10 h=10 fill={index == dot ? "#FF000000" : "#FFFFFFFF"}\n');
      expect(_said(r).single, contains('state currentIndex'));
    });

    test('an each under a ListView whose lines put two nodes under it repeats both, as one item', () {
      final r = _expand('state groups=["a","b"]\nstate records=[{"g":"a"}]\nColumn\n  ListView#list h=300\n    each group in groups\n'
          '      if length(filter(records, n => n.g == group)) > 0\n        Text "{group}"\n        each record in filter(records, n => n.g == group)\n          Text "{record.g}"\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      final kids = _node(r, 'list')['children']! as List;
      expect(kids, hasLength(1));
      final item = _node(r, kids.single as String);
      expect(item['type'], 'column');
      expect(item['children'], hasLength(2));
    });

    test('in a stack, the lines an each repeats are one layer each copy, in their places', () {
      final r = _expand('state rows=[{"y":0},{"y":40}]\nStack w=390 h=200\n  each row in rows\n    Box x=10 y={row.y} w=10 h=10\n    Text "t" x=30 y={row.y}\n');
      expect(r.issues, isEmpty, reason: '${_said(r)}');
      final list = _nodes(r).values.singleWhere((n) => (n! as Map)['type'] == 'listView')! as Map;
      final item = _node(r, (list['children']! as List).single as String);
      expect(item['type'], 'stack');
      expect(item['children'], hasLength(2));
    });

    test('an id written from the data under an each is its fixed part, and said with how a copy is named', () {
      final r = _expand('state rows=[1,2]\nColumn\n  each r in rows\n    Column#remove_{index} w=20 h=20\n');
      expect(_nodes(r), contains('remove'));
      expect(_said(r).single, allOf(contains('#remove_{index} is read as #remove'), contains('remove#2')));
    });
  });

  test('a child placed past the edge of a Stack that hugs is said, with the size that holds it', () {
    final r = _expand('Row gap=8\n  Stack\n    Box w=40 h=40\n    Box x=20 w=40 h=40\n  Text "x"\n');
    expect(r.issues.single.line, 4);
    expect(r.issues.single.message, allOf(contains('kept inside it'), contains('w=60')));
    final ok = _expand('Row gap=8\n  Stack w=60 h=40\n    Box w=40 h=40\n    Box x=20 w=40 h=40\n  Text "x"\n');
    expect(ok.issues, isEmpty, reason: '${_said(ok)}');
    // A negative place overhangs (it holds): nothing said.
    final over = _expand('Row gap=8\n  Stack\n    Box w=40 h=40\n    Box x=-12 y=-12 w=20 h=20\n  Text "x"\n');
    expect(over.issues, isEmpty, reason: '${_said(over)}');
  });

  test('a line given the page\'s own canvas id is said as the canvas\'s', () {
    final r = Catalog.run(standardCatalog, () => parseNotation('Column\n  Column#progress gap=4\n    Text "a"\n', catalog: standardCatalog, options: const NotationOptions(width: 390, reflow: false, screen: 'progress')));
    expect(r.issues.single.message, allOf(contains('"progress" is the canvas\'s own'), contains('progressBody')));
  });

  test('sticky takes its offset alone, as a bound sticky={on ? 0 : null} gives it', () {
    expect(Sticky.fromJson(0)?.offset, 0);
    expect(Sticky.fromJson(8)?.offset, 8);
    expect(Sticky.fromJson(null), isNull);
    expect(Sticky.fromJson(false), isNull);
    expect(Sticky.fromJson(true)?.offset, 0);
  });

  test('a definition root\'s limits (maxWidth) cap a call that writes none', () {
    final root = Node.fromJson({
      'type': 'column',
      'layout': {'width': {'fill': 0}, 'height': {'hug': 0}, 'constraints': {'maxWidth': 368}},
    })!;
    final call = Node.fromJson({'type': 'ZoneHeader', 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}})!;
    expect(seamCall(root, call).layout.constraints.maxWidth, 368);
    final own = Node.fromJson({'type': 'ZoneHeader', 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}, 'constraints': {'maxWidth': 200}}})!;
    expect(seamCall(root, own).layout.constraints.maxWidth, 200);
  });
}
