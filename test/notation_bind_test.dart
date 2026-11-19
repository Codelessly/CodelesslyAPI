// Binding in the notation (docs/design/13-compact-notation.md, "Binding"):
// `@name` is the variable itself, read and written. Bare, it is the line's
// value; `key=@name` binds another property by name; a control with two ends
// takes `@low @high`; a bound variable is declared; `bind=` is refused with
// the line as it is written now; a definition binds through `@value`,
// `name=@` and a plain `value=1`; the printer writes `@name`; and the
// rewrite of a line from `bind=` to `@` that the parser's message shows.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

NotationResult _parse(String text, {NotationOptions options = const NotationOptions(), Catalog? catalog}) =>
    catalog == null ? parseNotation(text, options: withTestWords(options)) : Catalog.run(catalog, () => parseNotation(text, catalog: catalog, options: withTestWords(options)));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

Map<String, Object?> _bind(NotationResult r, String id) => ((_node(r, id)['bind'] as Map?) ?? const {}).cast<String, Object?>();

/// The variables a node's change writes.
List<String> _writes(NotationResult r, String id) => [
      for (final reaction in (_node(r, id)['actions'] as List?) ?? const [])
        if (const {'changed', 'rowTap'}.contains(((reaction as Map)['trigger'] as Map)['type']))
          for (final a in (reaction['actions'] as List)) if ((a as Map)['type'] == 'setVariable') a['variable'] as String,
    ];

List<String> _messages(NotationResult r) => [for (final i in r.issues) i.message];

/// A design system's blocks: a sort menu (the column sorted by, and its
/// direction) and a choice of a group (its one variable is not called
/// value).
Future<Catalog> _withSortMenu() async {
  Map<String, Object?> component(String type, List<Object?> props) => {
        'schema': 3,
        'id': type,
        'roots': ['r'],
        'widget': {'type': type, 'doc': 'What a $type is for.', 'props': props},
        'nodes': {
          'r': {'type': 'column', 'layout': {'width': 100, 'height': 28}},
        },
      };
  const string = {'kind': 'string', 'flutter': 'String'};
  const variable = {'kind': 'variable', 'flutter': 'String', 'of': string};
  final files = {
    'design_system.json': jsonEncode({
      'id': 'acme',
      'name': 'Acme',
      'theme': {'primary': '#FF2563EB', 'onSurface': '#FF111827'},
      'components': ['components/SortMenu.json', 'components/Choice.json'],
    }),
    'components/SortMenu.json': jsonEncode(component('SortMenu', [
      {'key': 'value', 'type': variable, 'default': ''},
      {'key': 'direction', 'type': variable, 'default': ''},
      {'key': 'options', 'type': {'kind': 'list', 'flutter': 'List<String>', 'item': string}, 'default': <Object?>[]},
    ])),
    'components/Choice.json': jsonEncode(component('Choice', [
      {'key': 'group', 'type': variable, 'default': ''},
      {'key': 'label', 'type': string, 'default': ''},
    ])),
  };
  final ds = await DesignSystem.load((ref) async => files[ref]);
  return ds.catalogOver(standardCatalog);
}

/// Blocks whose variables have defaults: a rating (its value starts at 3), a
/// stepper (a number), with the sort menu and the choice.
Future<Catalog> _withRating() async {
  Map<String, Object?> component(String type, List<Object?> props) => {
        'schema': 3,
        'id': type,
        'roots': ['r'],
        'widget': {'type': type, 'doc': 'What a $type is for.', 'props': props},
        'nodes': {
          'r': {'type': 'column', 'layout': {'width': 100, 'height': 28}},
        },
      };
  const number = {'kind': 'number', 'flutter': 'double'};
  const string = {'kind': 'string', 'flutter': 'String'};
  const variable = {'kind': 'variable', 'flutter': 'double', 'of': number};
  const variableText = {'kind': 'variable', 'flutter': 'String', 'of': string};
  final files = {
    'design_system.json': jsonEncode({
      'id': 'acme',
      'name': 'Acme',
      'theme': {'primary': '#FF2563EB', 'onSurface': '#FF111827'},
      'components': ['components/Rating.json', 'components/Stepper.json', 'components/SortMenu.json', 'components/Choice.json'],
    }),
    'components/Rating.json': jsonEncode(component('Rating', [
      {'key': 'value', 'type': variable, 'default': 3},
      {'key': 'max', 'type': number, 'default': 5},
      {'key': 'readonly', 'type': {'kind': 'boolean', 'flutter': 'bool'}, 'default': false},
      {'key': 'bindLabel', 'type': string, 'default': ''},
      {
        'key': 'pinned',
        'type': {
          'kind': 'variable',
          'flutter': 'bool',
          'of': {'kind': 'boolean', 'flutter': 'bool'},
        },
        'default': true,
      },
    ])),
    'components/Stepper.json': jsonEncode(component('Stepper', [
      {'key': 'value', 'type': variable, 'default': 0},
      {'key': 'steps', 'type': {'kind': 'list', 'flutter': 'List<String>', 'item': string}, 'default': <Object?>[]},
    ])),
    'components/SortMenu.json': jsonEncode(component('SortMenu', [
      {'key': 'value', 'type': variableText, 'default': ''},
      {'key': 'direction', 'type': variableText, 'default': ''},
    ])),
    'components/Choice.json': jsonEncode(component('Choice', [
      {'key': 'group', 'type': variableText, 'default': ''},
      {'key': 'label', 'type': string, 'default': ''},
    ])),
  };
  final ds = await DesignSystem.load((ref) async => files[ref]);
  return ds.catalogOver(standardCatalog);
}

void main() {
  group('bare: the line\'s value', () {
    test('@name binds a control\'s value both ways, as value=@name does', () {
      for (final line in ['Slider @volume min=0 max=100', 'Slider value=@volume min=0 max=100', 'Slider min=0 max=100 @volume']) {
        final r = _parse('state volume=40\nColumn\n  $line');
        expect(r.issues, isEmpty, reason: line);
        expect(_bind(r, 'slider1')['props.value'], r'${volume}', reason: line);
        expect(_writes(r, 'slider1'), ['volume'], reason: line);
      }
    });

    test('every control keeps its value under one name', () {
      final r = _parse('''
state email=""
state on=false
state done=false
state size=""
state when=""
state page=0
state row=-1
Column
  Input "Email" @email
  Toggle "Wi-Fi" @on
  Checkbox "Done" @done
  Select items=["S","M"] @size
  DatePicker @when
  DataTable rows={[]} columns=[{"key":"a","label":"A"}] @row
''');
      expect(r.issues, isEmpty);
      expect(_writes(r, 'textField1'), ['email']);
      expect(_writes(r, 'switch1'), ['on']);
      expect(_writes(r, 'checkbox1'), ['done']);
      expect(_writes(r, 'dropdown1'), ['size']);
      expect(_writes(r, 'datePicker1'), ['when']);
      expect(_writes(r, 'tableView1'), ['row']);
    });

    test('a field of a loop item or of a record: @row.field', () {
      final r = _parse('''
state rows=[{"name":"Ada","done":false}]
state draft={"title":""}
Column
  Input "Title" @draft.title
  each row in rows
    Checkbox "{row.name}" @row.done
''');
      expect(r.issues, isEmpty);
      expect(_writes(r, 'textField1'), ['draft']);
      expect(_writes(r, 'checkbox1'), ['rows']);
    });

    test('a design system\'s block binds its value bare, and another variable by name', () async {
      final catalog = await _withSortMenu();
      final r = _parse('''
state sort="name"
state dir="asc"
state pick=""
Column
  SortMenu options=["name","date"] @sort direction=@dir
  Choice "A" @pick
''', catalog: catalog);
      expect(r.issues, isEmpty);
      Map<String, Object?> ofType(String type) => ((r.document['nodes'] as Map).values.firstWhere((n) => (n as Map)['type'] == type) as Map).cast<String, Object?>();
      expect(ofType('SortMenu')['props'], allOf(containsPair('value', 'sort'), containsPair('direction', 'dir')));
      expect(ofType('Choice')['props'], containsPair('group', 'pick'));
      // A block's variable is named with @: a bare name keeps nothing.
      final plain = _parse('state dir="asc"\nColumn\n  SortMenu direction=dir', catalog: catalog);
      expect(_messages(plain).single, contains('direction=@dir'));
      // A value worked out is shown, one way.
      final shown = _parse('state dir="asc"\nColumn\n  SortMenu direction={dir}', catalog: catalog);
      expect(shown.issues, isEmpty);
    });

    test('Pages, Dots and a gallery keep the page shown', () {
      final r = _parse('''
state page=0
Column
  Pages @page h=120
    Text "One"
    Text "Two"
  Dots @page count=2
''');
      expect(r.issues, isEmpty);
      expect(_writes(r, 'pageView1'), ['page']);
      expect(r.document.toString(), contains(r'variable: page, value: ${= index}'));
    });
  });

  group('named: another property', () {
    test('a list\'s selection is selected=@name', () {
      final r = _parse('''
state rows=["a","b"]
state picked=[]
Column selectable selected=@picked
  each r in rows
    Text "{r}"
''');
      expect(r.issues, isEmpty);
      expect(r.document.toString(), contains('picked'));
      expect(r.document.toString(), isNot(contains('column1Selected')));
    });

    test('a property the line cannot bind is said with what it can', () {
      final r = _parse('state x=0\nColumn\n  Slider tone=@x');
      expect(_messages(r).single, allOf(contains('no "tone" to bind'), contains('its value (@name)'), contains('@low @high')));
    });
  });

  group('a range: two ends in order', () {
    test('Slider @low @high, and low=@ high=@', () {
      for (final line in ['Slider @lo @hi min=0 max=100', 'Slider low=@lo high=@hi min=0 max=100', 'RangeSlider @lo @hi min=0 max=100', 'RangeSlider low=@lo high=@hi min=0 max=100']) {
        final r = _parse('state lo=10\nstate hi=90\nColumn\n  $line');
        expect(r.issues, isEmpty, reason: line);
        expect(_bind(r, 'slider1'), allOf(containsPair('props.value', r'${lo}'), containsPair('props.rangeEnd', r'${hi}')), reason: line);
        expect(_writes(r, 'slider1'), ['lo', 'hi'], reason: line);
      }
    });

    test('Calendar @start @end, and start=@ end=@', () {
      for (final line in ['Calendar @from @to', 'Calendar start=@from end=@to']) {
        final r = _parse('state from=""\nstate to=""\nColumn\n  $line');
        expect(r.issues, isEmpty, reason: line);
        expect(_bind(r, 'calendar1'), allOf(containsPair('props.start', r'${from}'), containsPair('props.end', r'${to}')), reason: line);
      }
    });
  });

  group('refused', () {
    test('a second bare mark, with what the line can bind', () {
      final r = _parse('state a=false\nstate b=false\nColumn\n  Toggle "x" @a @b');
      expect(_messages(r).single, allOf(contains('One @name a line is its value'), contains('binds its value (@name)')));
    });

    test('a third mark on a range', () {
      final r = _parse('state a=0\nstate b=1\nstate c=2\nColumn\n  Slider @a @b @c');
      expect(_messages(r).single, contains('two a range (@low @high)'));
    });

    test('a mark on a line with nothing to bind', () {
      final shown = _parse('state p=0.5\nColumn\n  Progress @p');
      expect(_messages(shown).single, contains('shows a value and keeps none: value={p}'));
      final text = _parse('state p="x"\nColumn\n  Text @p');
      expect(_messages(text).single, contains('Text "{p}"'));
      final box = _parse('state p=0\nColumn\n  Row @p');
      expect(_messages(box).single, contains('binds nothing'));
    });

    test('a variable no state line declares, with the state line to add', () {
      final r = _parse('Column\n  Slider @volume min=10 max=20\n  Input "Name" @name\n  Toggle "On" @on\n  Column selectable selected=@picked\n    each r in ["a"]\n      Text "{r}"');
      expect(_messages(r), [
        contains('add state volume=10'),
        contains('add state name=""'),
        contains('add state on=false'),
        contains('add state picked=[]'),
      ]);
    });

    test('a key written twice on a line is said', () {
      final r = _parse('state x=0.2\nColumn\n  Progress value={x} value=0.5\n  Text "a" size=12 size=14');
      expect(_messages(r), [contains('value= is written twice'), contains('size= is written twice')]);
    });

    test('a state line after the line that binds it declares it too', () {
      final r = _parse('Column\n  Toggle "On" @on\nstate on=true');
      expect(r.issues.where((i) => i.message.contains('declare')), isEmpty);
    });

    test('a site\'s variable is declared', () {
      final r = _parse('Column\n  Input "Name" @user', options: const NotationOptions(projectVariables: {'user': {'type': 'text', 'value': ''}}));
      expect(r.issues, isEmpty);
    });

    test('bind= is not read: one message, with the line in the form it is written now', () {
      final cases = {
        'Slider bind=heat min=14 max=24': 'Slider @heat min=14 max=24',
        'Slider bind={heat} min=14 max=24': 'Slider @heat min=14 max=24',
        'Slider bind=lo bindEnd=hi': 'Slider @lo @hi',
        'Calendar bind=a bindEnd=b': 'Calendar @a @b',
        'Progress bind=done': 'Progress value={done}',
        'Column selectable bind=picked': 'Column selectable selected=@picked',
      };
      for (final e in cases.entries) {
        final r = _parse('state heat=0\nstate lo=0\nstate hi=1\nstate a=""\nstate b=""\nstate done=0\nstate picked=[]\nColumn\n  ${e.key}');
        expect(_messages(r), contains(contains('Write: ${e.value}')), reason: e.key);
        expect(_messages(r).where((m) => m.contains('Write:')), hasLength(1), reason: e.key);
      }
    });
  });

  group('definitions', () {
    const stepper = '''
define Stepper "label" @value=1 step=1
  Row gap=8
    Text "{label}: {value}"
    Button "+" onTap={value=value+step}
''';

    test('@value in the signature: a use binds it bare or by name, both ways', () {
      for (final use in ['Stepper "Servings" @servings', 'Stepper "Servings" value=@servings']) {
        final r = _parse('state servings=2\nColumn\n  $use\n$stepper');
        expect(r.issues, isEmpty, reason: use);
        final s = r.document.toString();
        expect(s, contains('variable: servings'), reason: use);
        expect(s, contains(r'${servings}'), reason: use);
      }
    });

    test('a use that binds none keeps its own value, from the signature\'s default', () {
      final r = _parse('Column\n  Stepper "Guests"\n$stepper');
      expect(r.issues, isEmpty);
      final vars = ((r.document['variables'] as Map).values.first as List).cast<Map>();
      expect(vars.where((v) => (v['name'] as String).startsWith('value_')).single['value'], 1);
    });

    test('name=@ in the signature: a further variable a use binds by name', () {
      const panel = '''
define Disclosure "title" open=@
  state open=false
  Column gap=4
    Toggle "{title}" @open
    if open
      Text "Shown"
''';
      final bound = _parse('state shown=true\nColumn\n  Disclosure "A" open=@shown\n$panel');
      expect(bound.issues, isEmpty);
      expect(_writes(bound, 'switch1'), ['shown']);
      final own = _parse('Column\n  Disclosure "A"\n$panel');
      expect(own.issues, isEmpty);
      expect(_writes(own, 'switch1').single, startsWith('open_'));
    });

    test('a plain value=1 that a use binds is that variable both ways', () {
      const counter = '''
define Counter value=1 onChange
  Row gap=8
    Text "{value}"
    Button "+" onTap={value=value+1; onChange}
''';
      for (final use in ['Counter @n', 'Counter value=@n']) {
        final r = _parse('state n=0\nColumn\n  $use\n$counter');
        expect(r.issues, isEmpty, reason: use);
        expect(r.document.toString(), contains('variable: n'), reason: use);
      }
      // Unbound, it is the value given: a number, read.
      final plain = _parse('Column\n  Counter value=3\n$counter');
      expect(plain.document.toString(), contains('text: 3'));
    });

    test('a body control bound to a plain parameter keeps the use\'s own value unless the use binds it', () {
      const level = '''
define Level "label" level=5
  Slider @level min=0 max=10
''';
      final own = _parse('Column\n  Level "Bass"\n$level');
      expect(own.issues, isEmpty);
      expect(_writes(own, 'level1').single, startsWith('level_'));
      final bound = _parse('state bass=2\nColumn\n  Level "Bass" level=@bass\n$level');
      expect(bound.issues, isEmpty);
      expect(_writes(bound, 'level1'), ['bass']);
    });

    test('name=@0.5 in the signature: a variable a use binds by name, with what a use that binds none starts at', () {
      const crop = '''
define Crop "label" x=@0.5 y=@0.25
  Column
    Text "{label}: {x}, {y}"
    Slider @x min=0 max=1
    Button "Center" onTap={x=0.5; y=0.5}
''';
      final d = readPageDefinitions(crop).words['Crop']!.single;
      expect(d.bindables, {'x', 'y'});
      expect(d.parameters, {'x': '0.5', 'y': '0.25'});
      // Unbound: its own variables, started at the defaults.
      final own = _parse('Column\n  Crop "A"\n$crop');
      expect(own.issues, isEmpty);
      final vars = ((own.document['variables'] as Map).values.first as List).cast<Map>();
      expect(vars.where((v) => (v['name'] as String).startsWith('x_')).single['value'], 0.5);
      expect(vars.where((v) => (v['name'] as String).startsWith('y_')).single['value'], 0.25);
      // Bound: the page's, both ways.
      final bound = _parse('state cx=0.1\nstate cy=0.2\nColumn\n  Crop "A" x=@cx y=@cy\n$crop');
      expect(bound.issues, isEmpty);
      expect(_writes(bound, 'slider1'), ['cx']);
      // Bound to a variable nothing declares: the state line said starts at
      // the default.
      final undeclared = _parse('Column\n  Crop "A" x=@cx\n$crop');
      expect(_messages(undeclared), contains(contains('add state cx=0.5')));
    });

    test('a default after @ is read whole: a string, a list', () {
      final d = readPageDefinitions('define Tags @value=[0, 100] label=@"a b"\n  Text "{label} {value}"\n').words['Tags']!.single;
      expect(d.bindDefault, '[0, 100]');
      expect(d.parameters['label'], '"a b"');
      expect(d.bindables, {'label'});
      // A name after @ is no default: said.
      final bad = readPageDefinitions('define Bad x=@other\n  Text "{x}"\n');
      expect(bad.problems.map((p) => p.message).join('\n'), contains('x=@0 with its start'));
    });

    test('primitive signatures take the same forms', () {
      final r = _parse('state v=0\nColumn\n  Knob @v\n// A knob turned round.\nprimitive Knob @value=0\n');
      expect(r.issues, isEmpty);
    });

    test('a binding the word does not have is said with what it binds', () {
      final r = _parse('state x=0\nColumn\n  Stepper "A" @x tone=@x\n$stepper');
      expect(_messages(r).single, allOf(contains('no "tone" to bind'), contains('@name (its value)')));
      const label = '''
define Label "text"
  Text "{text}"
''';
      final none = _parse('state x=0\nColumn\n  Label "A" @x\n$label');
      expect(_messages(none).single, contains('keeps no value of its own: it binds nothing'));
    });

    test('bind= in a signature, a body or a use is refused with its new form', () {
      final r = _parse('state s=0\nColumn\n  Old "x" bind=s\ndefine Old "label" bind=value\n  state value=0\n  Slider bind=value\n');
      final said = _messages(r).join('\n');
      expect(said, contains('Write: define Old "label" @value'));
      expect(said, contains('Write: Slider @value'));
      expect(said, contains('Write: Old "x" @s'));
    });

    test('what a definition reads: a bound parameter is read, a bound page variable is outside', () {
      final d = readPageDefinitions('define Fader "label" @value=0 trim=0\n  Row\n    Slider @value\n    Slider @gain\n    Text "{label}"\n').words['Fader']!.single;
      final reads = definitionReads(d);
      expect(reads.unread, ['trim']);
      expect(reads.outside, ['gain']);
    });
  });

  group('the printer', () {
    test('writes a control\'s variable as @name, and reads back the same document', () {
      final r = _parse('state volume=40\nstate email=""\nColumn gap=8\n  Slider @volume min=0 max=100\n  Input "Email" @email');
      expect(r.issues, isEmpty);
      final printed = printNotation(r.document, catalog: Catalog.current);
      expect(printed, allOf(contains('@volume'), contains('@email')));
      expect(printed, isNot(contains('bind=')));
      final again = parseNotation(printed, options: notationOptionsFor(r.document));
      expect(again.document, r.document);
    });
  });

  group('the rewrite from bind=', () {
    test('a line in the form it is written now, with the variables it binds', () {
      final cases = <String, (String, Map<String, Object?>)>{
        '  Slider bind=heat min=14 max=24': ('  Slider @heat min=14 max=24', {'heat': 14}),
        'Input "Email" bind={email}': ('Input "Email" @email', {'email': ''}),
        'Toggle "On" bind=on': ('Toggle "On" @on', {'on': false}),
        'Slider bind=lo bindEnd=hi max=50': ('Slider @lo @hi max=50', {'lo': 0, 'hi': 50}),
        'Slider bindEnd=hi bind=lo': ('Slider @lo @hi', {'lo': 0, 'hi': 1}),
        'Calendar bind=a bindEnd=b': ('Calendar @a @b', {'a': '', 'b': ''}),
        'RangeSlider low=a high=b': ('RangeSlider @a @b', {'a': 0, 'b': 1}),
        'Progress bind={done/total}': ('Progress value={done/total}', {}),
        'Progress bind=share': ('Progress value={share}', {}),
        'Text bind=label': ('Text "{label}"', {}),
        'Column selectable bind=picked gap=8': ('Column selectable selected=@picked gap=8', {'picked': <Object?>[]}),
        'Checkbox "{row.name}" bind=row.done': ('Checkbox "{row.name}" @row.done', {}),
        'Pages bind=page h=120': ('Pages @page h=120', {'page': 0}),
        'Dots bind=page count=4': ('Dots @page count=4', {'page': ''}),
        'Thing bindStart=from': ('Thing start=@from', {'from': ''}),
        'define Stepper "label" bind=value min max': ('define Stepper "label" @value min max', {}),
        'Text "bind=x is old" size=12': ('Text "bind=x is old" size=12', {}),
        // A mark already written is the line's: not rewritten, not listed (a
        // state line is the rewrite's only for what it rewrote).
        'Slider @heat': ('Slider @heat', {}),
        'Column selectable reorder bind=picked': ('Column selectable reorder selected=@picked', {'picked': <Object?>[]}),
        // A list reordered (not selected from) kept nothing in its bind=: the
        // order goes to the list its each repeats.
        'Column reorder bind=xs onReorder={xs=result}': ('Column reorder onReorder={xs=result}', {}),
        'Column sortable gap=8 bind=xs': ('Column sortable gap=8', {}),
        'define Bar "label" value=0 bind=value': ('define Bar "label" @value=0', {}),
        'define Bar "label" bind=value value="x" onChange': ('define Bar "label" @value="x" onChange', {}),
        'define Crop bindX=0.5 bindY=0.5': ('define Crop x=@0.5 y=@0.5', {}),
        'define Pick bindItems=[] bindOn=true': ('define Pick items=@[] on=@true', {}),
        'define Crop bindX={x}': ('define Crop x=@', {}),
        // A display with a value= of its own showed that: the bind is dropped
        // (two value= would lose one).
        'Progress bind=x value=0.5': ('Progress value=0.5', {}),
        'Progress bind={0} value={done/total}': ('Progress value={done/total}', {}),
      };
      for (final e in cases.entries) {
        final got = notationBindRewrite(e.key);
        expect(got.line, e.value.$1, reason: e.key);
        expect({for (final b in got.bound) b.name: b.start}, e.value.$2, reason: e.key);
      }
    });

    test('a block\'s variables, from its catalog', () async {
      final catalog = await _withSortMenu();
      expect(notationBindForm('SortMenu bind=sort direction=dir options=["a"]', catalog: catalog), 'SortMenu @sort direction=@dir options=["a"]');
      expect(notationBindForm('Choice "A" group=pick', catalog: catalog), 'Choice "A" group=@pick');
      expect(notationBindForm('Choice "A" bind=pick', catalog: catalog), 'Choice "A" @pick');
    });

    test('a block\'s variables start at their kinds\' empty values (a variable parameter declares no value)', () async {
      final catalog = await _withRating();
      final got = notationBindRewrite('Rating bind=score pinned=keep', catalog: catalog);
      expect(got.line, 'Rating @score pinned=@keep');
      expect({for (final b in got.bound) b.name: b.start}, {'score': 0, 'keep': false});
    });

    // Each heuristic of the rewrite, on a line it must leave as it is.
    group('left as written', () {
      test('a value in braces was shown, one way, in 33: on every key', () async {
        final catalog = await _withRating();
        for (final line in [
          'Rating value={s} readonly',
          'Rating value={photos[at].myRating} max=5',
          'SortMenu direction={dir}',
          'Choice "A" group={pick}',
          'RangeSlider lo={lo} hi={hi} min=0 max=9',
          'RangeSlider low={a} high={b}',
          'Stepper.progress steps=["A","B"] value={step}',
        ]) {
          final got = notationBindRewrite(line, catalog: catalog);
          expect(got.line, line, reason: line);
          expect(got.bound, isEmpty, reason: line);
        }
        // Beside bind=, the block's value parameter is bind='s: left too.
        expect(notationBindForm('Rating bind=myRating max=5 value={photos[at].myRating}', catalog: catalog), 'Rating @myRating max=5 value={photos[at].myRating}');
        expect(notationBindForm('Rating bind=myRating value=other', catalog: catalog), 'Rating @myRating value=other');
      });

      test('what is no variable: numbers, words of the language, strings, lists, unbalanced parentheses', () async {
        final catalog = await _withRating();
        for (final line in [
          'Rating value=4.6',
          'Rating value=true',
          'Rating value=null',
          'RangeSlider low=4 high=9',
          'RangeSlider from="a" to="b"',
          'Slider bind="volume"',
          'Slider bind=[1,2]',
          'Thing bind=f(a',
          'Thing bindStart="x"',
        ]) {
          expect(notationBindForm(line, catalog: catalog), line, reason: line);
        }
      });

      test('what is no binding: statements, events, strings, keys that only start with bind', () {
        for (final line in [
          'state bind=3',
          'each bind in rows',
          'if bind=="x"',
          'let bindX=4',
          'Button "Go" onTap={bindX=1}',
          'Text "bind=x is old"',
          'Box bindings=3',
          'Text "{bindEnd}"',
          'Box w={bindWidth}',
          'Progress value={done}',
          'Slider @heat min=0',
          'Calendar @a @b',
          'Column selectable selected=@picked',
          'define Bar value=0',
          'define Panel "title" open=@',
          'define Knob @value=0',
          '// Slider bind=x',
          'a sentence that writes bind=x',
        ]) {
          final got = notationBindRewrite(line);
          expect(got.line, line, reason: line);
          expect(got.bound, isEmpty, reason: line);
        }
      });

      test('a name the runtime reserves is left, and said', () {
        for (final line in ['SegmentedButton items=["Light","Dark"] bind=theme', 'Select items=["a","b"] bind=device', 'Slider bind=data']) {
          final got = notationBindRewrite(line);
          expect(got.line, line, reason: line);
          expect(got.bound, isEmpty, reason: line);
          expect(got.refused, hasLength(1), reason: line);
        }
        // A field of one is no state line: rewritten.
        expect(notationBindForm('Input bind=theme.name'), 'Input @theme.name');
        // A signature's names are the definition's own.
        expect(notationBindRewrite('define Pick bind=theme').refused, isEmpty);
      });

      test('a component\'s own key that starts with bind is its own', () async {
        final catalog = await _withRating();
        expect(notationBindForm('Rating bindLabel=x', catalog: catalog), 'Rating bindLabel=x');
      });
    });

    test('what it rewrites expands with no issue once its variables are declared', () {
      const old = ['Slider bind=heat min=14 max=24', 'Slider bind=lo bindEnd=hi', 'Calendar bind=a bindEnd=b', 'Input "Email" bind=email', 'Pages bind=page h=80'];
      for (final line in old) {
        final got = notationBindRewrite(line);
        final states = [for (final b in got.bound) 'state ${b.name}=${b.start is String ? '"${b.start}"' : b.start}'];
        final r = _parse('${states.join('\n')}\nColumn\n  ${got.line}');
        expect(r.issues, isEmpty, reason: '$line → ${got.line}');
      }
    });
  });
}
