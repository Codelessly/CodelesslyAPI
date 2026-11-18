// Events and actions in the notation (docs/design/22-notation-parity.md
// sections 2.2 and 2.3): every trigger of the catalog as `on<Trigger>(…)={…}`
// and every action type by its name and fields; each written, expanded,
// printed and read back as the same line.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/notation.dart' show notationEventName, notationEventTrigger;
import 'package:codelessly_api/src/core/notation/print_events.dart' show printCanvasEvents, printEvents, printNormalized;
import 'package:codelessly_api/src/core/notation/print_fields.dart' show PrintContext;
import 'package:test/test.dart';

NotationResult _parse(String text, {bool open = false}) =>
    parseNotation(text, catalog: standardCatalog, options: NotationOptions(openVocabulary: open));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

List<Object?> _reactions(NotationResult r, String id) => _node(r, id)['actions']! as List;

/// [line] (a box with [event]) expanded, printed and read back: the print's
/// line for the box, which must have no `{…}` tail, and the document read
/// back must be the one expanded.
String _roundTrip(String text) {
  final r = _parse(text);
  expect(r.issues, isEmpty, reason: text);
  final printed = printNotation(r.document, catalog: standardCatalog);
  expect(printed, isNot(contains(' {"')), reason: printed);
  expect(printed, isNot(startsWith('document ')), reason: printed);
  final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(r.document));
  expect(jsonEncode(back.document), jsonEncode(r.document));
  return printed;
}

/// [text] read with [catalog], printed and read back: the print, which has
/// no `{…}` tail and no `document` line.
String _roundTripWith(String text, Catalog catalog) {
  final r = parseNotation(text, catalog: catalog);
  expect(r.issues, isEmpty, reason: text);
  final printed = printNotation(r.document, catalog: catalog);
  expect(printed, isNot(contains(' {"')), reason: printed);
  expect(printed, isNot(contains('document ')), reason: printed);
  final back = parseNotation(printed, catalog: catalog, options: notationOptionsFor(r.document));
  expect(back.issues, isEmpty, reason: printed);
  expect(jsonEncode(back.document), jsonEncode(r.document));
  return printed;
}

/// The standard catalog and two design system blocks: a row that is tapped
/// (`onPressed`, `onAction`) and a toggle that keeps its value in the
/// variable its `value` parameter names.
final _blocks = standardCatalog +
    Catalog.fromJson({
      'id': 'blocks',
      'widgets': [
        {
          'type': 'SessionRow',
          'props': [
            {'key': 'title', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': 'Intervals', 'required': true},
          ],
          'events': [
            {'key': 'onPressed'},
            {'key': 'onAction'},
          ],
        },
        {
          'type': 'ToggleRow',
          'props': [
            {'key': 'label', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': 'Watch', 'required': true},
            {'key': 'value', 'type': {'kind': 'variable', 'of': {'kind': 'boolean', 'flutter': 'bool'}}, 'default': ''},
          ],
          'events': [
            {'key': 'onChanged', 'payload': {'kind': 'boolean', 'flutter': 'bool'}},
          ],
        },
        {
          'type': 'SortMenu',
          'props': [
            {'key': 'column', 'type': {'kind': 'variable', 'of': {'kind': 'string', 'flutter': 'String'}}, 'default': ''},
            {'key': 'direction', 'type': {'kind': 'variable', 'of': {'kind': 'string', 'flutter': 'String'}}, 'default': ''},
          ],
        },
      ],
    });

/// A value for a field of kind [f], written as the printer writes it.
String _sample(PropDef<Object?> f) => switch (f.type.kind) {
      PropKind.boolean => '${f.defaultValue != true}',
      PropKind.integer => '7',
      PropKind.number => '0.5',
      PropKind.string => '"two words"',
      PropKind.enumeration => f.type.values.last,
      PropKind.value => '#FF112233',
      PropKind.list => '[1,2]',
      PropKind.object || PropKind.json => '{"a":1}',
    };

void main() {
  group('events: every trigger of the catalog', () {
    test('is on and its name with a capital, but the names the notation had', () {
      expect(notationEventName('click'), 'onTap');
      expect(notationEventName('changed'), 'onChange');
      expect(notationEventName('cursorEnter'), 'onHover');
      expect(notationEventName('hover'), 'onHoverMove');
      expect(notationEventName('enterViewport'), 'onEnterViewport');
      expect(notationEventName('dragEnd'), 'onDragEnd');
      for (final t in TriggerType.values.where((t) => t != TriggerType.event)) {
        expect(notationEventTrigger(notationEventName(t.name)), t.name);
      }
      // The catalog's own name reads too, where the notation has another.
      expect(notationEventTrigger('onClick'), 'click');
      expect(notationEventTrigger('onFocusGained'), 'focusGained');
      expect(notationEventTrigger('onCursorEnter'), 'cursorEnter');
    });

    for (final t in TriggerType.values.where((t) => t != TriggerType.event)) {
      test('${t.name}: written with every field of a trigger, expanded, printed and read back as written', () {
        final name = notationEventName(t.name);
        final fields = [
          for (final f in TriggerFields.all)
            if (f.key != 'type')
              switch (f.key) {
                'when' => 'when={ready}',
                'onceKey' => 'onceKey={item.id}',
                'intervalMs' => 'intervalMs=500',
                'key' => 'key=Enter',
                'variable' => 'variable=count',
                'event' => 'event=pick',
                _ => '${f.key}=${f.type.kind == PropKind.boolean ? 'true' : f.type.kind == PropKind.number ? '0.5' : '9'}',
              },
        ];
        final word = '$name(${fields.join(', ')})={toast "Hi"}';
        final r = _parse('state count=0\nstate ready=true\nBox#b $word');
        expect(r.issues, isEmpty);
        final trigger = (_reactions(r, 'b').single as Map)['trigger'] as Map;
        expect(trigger['type'], t.name);
        expect(trigger.length, TriggerFields.all.length);
        expect(trigger['when'], r'${ready}');
        expect(trigger['repeat'], true);
        expect(trigger['visibleFraction'], 0.5);
        final printed = _roundTrip('state count=0\nstate ready=true\nBox#b $word');
        expect(printed, contains(' $word'));
      });
    }

    test('a trigger\x27s field it does not have, and an event that is no trigger, are said with the nearest name', () {
      final r = _parse('Box#b onKeyDown(ky=Enter)={toast "x"} onScrol={toast "y"}');
      expect(r.issues.map((i) => i.message), [
        startsWith('A trigger has no field "ky". Did you mean "key"?'),
        allOf(startsWith('A Box has no event "onScrol".'), endsWith('Did you mean "onScroll"?')),
      ]);
      // With an open vocabulary the event is recorded, not said.
      final open = _parse('Box#b onScrol={toast "y"}', open: true);
      expect(open.issues, isEmpty);
      expect(open.vocabulary.single.word, 'onScrol');
    });

    test('the names the notation had keep their triggers, on a block too', () {
      final r = _parse('Box#b onHover={x=1} onHoverMove={x=2} onRightClick={x=3} onContextMenu={x=4} onBlur={x=5}');
      expect([for (final e in _reactions(r, 'b')) ((e as Map)['trigger'] as Map)['type']], ['cursorEnter', 'hover', 'secondaryClick', 'secondaryClick', 'focusLost']);
    });
  });

  group('actions: every action type of the catalog', () {
    for (final spec in standardCatalog.actions) {
      test('${spec.type}: written by its name with every field, expanded, printed and read back as written', () {
        final fields = [
          for (final f in [...spec.fields, ...ActionCommonFields.all])
            if (spec.nested.contains(f.key)) '${f.key}={toast "x"}' else '${f.key}=${_sample(f)}',
        ];
        final action = '${spec.type} ${fields.join(' ')}';
        final r = _parse('Box#b onTap={$action}');
        expect(r.issues, isEmpty);
        final a = ((_reactions(r, 'b').single as Map)['actions'] as List).single as Map;
        expect(a['type'], spec.type);
        expect(a.length, fields.length + 1);
        for (final f in spec.fields) {
          if (spec.nested.contains(f.key)) {
            expect(a[f.key], [
              {'type': 'showToast', 'message': 'x'},
            ]);
          } else if (f.type.kind == PropKind.string) {
            expect(a[f.key], 'two words');
          }
        }
        expect(a['enabled'], false);
        expect(a['nonBlocking'], true);
        expect(a['when'], {'a': 1});
        final printed = _roundTrip('Box#b onTap={$action}');
        expect(printed, contains('onTap={$action}'));
      });
    }

    test('a field\x27s value: a number, a word, a quoted string reading a value, an expression, JSON', () {
      final r = _parse('state n=1\nBox#b onTap={setVariable variable=n op=add value=2 index="{n}" mapKey={n + 1}; navigate to=home params={"id":"{n}"}}');
      expect(r.issues, isEmpty);
      expect((_reactions(r, 'b').single as Map)['actions'], [
        {'type': 'setVariable', 'variable': 'n', 'op': 'add', 'value': 2, 'index': r'${n}', 'mapKey': r'${= n + 1}'},
        {'type': 'navigate', 'to': 'home', 'params': {'id': '{n}'}},
      ]);
      _roundTrip('state n=1\nBox#b onTap={setVariable variable=n op=add value=2 index="{n}" mapKey={n + 1}; navigate to=home params={"id":"{n}"}}');
    });

    test('a list of actions as a field: in braces', () {
      const text = 'state ok=false\nBox#b onTap={runScript script=check onError={toast "Failed"; ok=false}}';
      final r = _parse(text);
      expect(r.issues, isEmpty);
      expect((_reactions(r, 'b').single as Map)['actions'], [
        {
          'type': 'runScript',
          'script': 'check',
          'onError': [
            {'type': 'showToast', 'message': 'Failed'},
            {'type': 'setVariable', 'variable': 'ok', 'value': r'${= false}'},
          ],
        },
      ]);
      expect(_roundTrip(text), contains('onTap={runScript script=check onError={toast "Failed"; ok=false}}'));
    });

    test('a verb that is an action type too takes its fields by name, and its word otherwise', () {
      final r = _parse('Box#b onTap={focus email; focus node=email selectAll=true; announce "Saved"; announce message=Saved}');
      expect(r.issues, isEmpty);
      expect((_reactions(r, 'b').single as Map)['actions'], [
        {'type': 'focus', 'node': 'email'},
        {'type': 'focus', 'node': 'email', 'selectAll': true},
        {'type': 'announce', 'message': 'Saved'},
        {'type': 'announce', 'message': 'Saved'},
      ]);
    });

    test('an unknown action, and an unknown field, are said with the nearest name', () {
      final r = _parse('Box#b onTap={animat node=hero; scrollTo nod=hero}');
      expect(r.issues.map((i) => i.message), [
        allOf(startsWith('Unknown action "animat".'), endsWith('Did you mean "animate"?')),
        startsWith('A scrollTo action has no field "nod". Did you mean "node"?'),
      ]);
      // An action written as JSON still reads.
      final j = _parse('Box#b onTap={{"type":"haptic","kind":"heavy"}}');
      expect((_reactions(j, 'b').single as Map)['actions'], [
        {'type': 'haptic', 'kind': 'heavy'},
      ]);
    });
  });

  group('the printer', () {
    test('writes the shortest verbs, the choice for an if, and the type and fields for the rest', () {
      const text = 'state n=0\nstate ok=false\n'
          'Box#b onTap={n=n+1; toast "Saved {n}"; ok ? {go home; close} : announce "Not yet"; emit done n; link https://example.com; scroll top; open sheet; '
          'copy n; confirm "Sure?" then {n=0}; animate node=hero command=reverse; haptic kind=heavy}';
      final printed = _roundTrip(text);
      // (A Box is a column.)
      expect(printed.split('\n').last, 'Column#b ${text.split('\n').last.substring('Box#b '.length)}');
    });

    test('leaves the change a bind writes to the line\x27s binding', () {
      final r = _parse('state query=""\nInput#q "Search" @query onSubmit={toast "Go"}');
      final n = _node(r, 'q');
      expect(printEvents('q', n, PrintContext(document: r.document, catalog: standardCatalog, options: notationOptionsFor(r.document))), ['onSubmit={toast "Go"}']);
    });

    test('writes the canvas\x27s timers and shortcuts as every and key lines', () {
      const text = 'state t=0\nstate on=true\nevery 1s when on onTick={t=t+1}\nevery {1000/2} onTick={t=t-1}\nkey mod+k onPress={open search}\nBox#b';
      final r = _parse(text);
      expect(r.issues, isEmpty);
      final context = PrintContext(document: r.document, catalog: standardCatalog, options: notationOptionsFor(r.document));
      expect(printCanvasEvents(r.document, context), ['every 1s when on onTick={t=t+1}', 'every {1000/2} onTick={t=t-1}', 'key mod+k onPress={open search}']);
      final printed = _roundTrip(text);
      expect(printed, isNot(contains('document')));
    });
  });
  group('the second pass (design 22, 4.3)', () {
    test('@name is printed for every two-way binding: a name, a field of a record, a field of the element under an each, two ends', () {
      const text = 'state rows=[{"id":1,"name":"a","on":true}]\nstate draft={"title":""}\nstate vol=0.5\nstate pick=""\nstate lo=20\nstate hi=80\n'
          'Column\n'
          '  each item in rows\n'
          '    Input @item.name onSubmit={toast "x"}\n'
          '    Checkbox @item.on\n'
          '  Input#d @draft.title\n'
          '  Slider#s @vol onChange={toast "moved"}\n'
          '  Select#sel @pick items=["a","b"]\n'
          '  Slider#r @lo @hi min=0 max=100';
      final printed = _roundTrip(text);
      for (final line in text.split('\n').skip(8)) {
        expect(printed, contains(line.trim()));
      }
      expect(printed, isNot(contains('bind=')));
    });

    test('@name on every control of the catalog, by a name and under an each, is printed with the control\x27s other events', () {
      final controls = <String>[];
      for (final w in standardCatalog.widgets) {
        final word = '${w.type[0].toUpperCase()}${w.type.substring(1)}';
        for (final (bind, text) in [
          ('@v', 'Column\n  $word#x @v onFocus={toast "x"}'),
          ('@item.f', 'state rows=[{"id":1,"f":1}]\nColumn\n  each item in rows\n    $word#x @item.f onFocus={toast "x"}'),
        ]) {
          var r = _parse(text);
          // A bound variable is declared: with the state line the issue gives.
          final declare = r.issues.length == 1 ? RegExp(r'^@v binds a variable nothing declares: add (state v=.*) at the top').firstMatch(r.issues.single.message) : null;
          if (declare != null) r = _parse('${declare[1]}\n$text');
          // A control: @name writes the change it stores, before onFocus.
          if (r.issues.isNotEmpty || (_node(r, 'x')['actions'] as List?)?.length != 2) continue;
          controls.add(w.type);
          final line = printNotation(r.document, catalog: standardCatalog).split('\n').firstWhere((l) => l.contains('#x'));
          expect(line, allOf(contains(' $bind onFocus={toast "x"}'), isNot(contains('{"'))), reason: w.type);
        }
      }
      expect(controls.toSet(), containsAll(['textField', 'checkbox', 'switch', 'slider', 'dropdown', 'radio', 'segmentedButton', 'datePicker']));
    });

    test('@name on a design system control is its variable parameter, by name and under an each, and its events are its own', () {
      const text = 'state public=true\nstate dirty=false\nstate rows=[{"id":1,"on":true}]\n'
          'Column\n'
          '  ToggleRow#tr "Public profile" @public onChanged={dirty=true}\n'
          '  each item in rows\n'
          '    ToggleRow "Row" @item.on';
      final r = parseNotation(text, catalog: _blocks);
      expect(r.issues, isEmpty);
      expect(_node(r, 'tr')['props'], containsPair('value', 'public'));
      final printed = _roundTripWith(text, _blocks);
      expect(printed, contains('ToggleRow#tr "Public profile" @public onChanged={dirty=true}'));
      expect(printed, contains('ToggleRow "Row" @item.on'));
    });

    test('a design system control\x27s further variable parameters are key=@name, its first bare', () {
      const text = 'state col="name"\nstate dir="asc"\nColumn\n  SortMenu#s @col direction=@dir';
      final r = parseNotation(text, catalog: _blocks);
      expect(r.issues, isEmpty);
      expect(_node(r, 's')['props'], allOf(containsPair('column', 'col'), containsPair('direction', 'dir')));
      expect(_roundTripWith(text, _blocks), contains('SortMenu#s @col direction=@dir'));
    });

    test('a calendar\x27s two ends are two marks, one change storing both', () {
      const text = 'state from=""\nstate to=""\nColumn\n  Calendar#c @from @to';
      expect(_roundTrip(text), contains('Calendar#c @from @to'));
    });

    test('a block\x27s events by their own names, on a block called without what it requires too', () {
      const text = 'state n=0\nColumn\n  SessionRow#a onPressed={emit open_session n} onAction={n=n+1}\n  SessionRow#b onTap={go home}';
      final r = parseNotation(text, catalog: _blocks);
      // (A block called without its title is said, and still printed.)
      expect(r.issues.map((i) => i.message), everyElement(startsWith('A SessionRow needs title')));
      expect((_reactions(r, 'b').single as Map)['trigger'], {'type': 'event', 'event': 'onPressed'});
      final printed = printNotation(r.document, catalog: _blocks);
      expect(printed, contains('SessionRow#a onPressed={emit open_session n} onAction={n=n+1}'));
      // onTap on a block is its first event: printed by that event's own name.
      expect(printed, contains('SessionRow#b onPressed={go home}'));
      expect(printed, isNot(contains(' {"')));
    });

    test('a component raises its events with emit, in its own tree', () {
      const text = 'component Pill\n  param label="Active"\n  event onPressed\n  event onChanged:String\nRow#pill onTap={emit onPressed; emit onChanged "x"}\n  Text "Active"';
      final printed = _roundTrip(text);
      expect(printed, contains('Row#pill onTap={emit onPressed; emit onChanged "x"}'));
    });

    test('a trigger written as its type alone reads as the same trigger, and prints as one', () {
      final doc = parseNotation('state n=0\nBox#b onTap={n=n+1} onScroll={n=0}', catalog: standardCatalog).document;
      final nodes = doc['nodes']! as Map;
      final b = (nodes['b']! as Map).cast<String, Object?>();
      final reactions = [
        for (final r in b['actions']! as List) {...(r as Map).cast<String, Object?>(), 'trigger': (r['trigger'] as Map)['type']},
      ];
      final asString = {
        ...doc,
        'nodes': {...nodes, 'b': {...b, 'actions': reactions}},
      };
      expect([for (final r in reactions) r['trigger']], ['click', 'scroll']);
      expect(jsonEncode(printNormalized(asString, standardCatalog)), jsonEncode(doc));
      expect(identical(printNormalized(doc, standardCatalog), doc), isTrue);
      final printed = printNotation(asString, catalog: standardCatalog);
      expect(printed, contains('onTap={n=n+1} onScroll={n=0}'));
      expect(printed, isNot(contains('{"')));
    });

    test('a condition\x27s operand given as a number or a boolean is its text', () {
      final doc = <String, Object?>{
        'nodes': {
          'b': {
            'type': 'box',
            'actions': [
              {
                'trigger': {'type': 'click'},
                'actions': [
                  {
                    'type': 'navigate',
                    'to': 'home',
                    'when': {'left': 3, 'op': 'equalsTo', 'right': true},
                  },
                  {
                    'type': 'if',
                    'condition': {
                      'and': [
                        {'left': 1, 'op': 'isTrue'},
                      ],
                    },
                    'then': [
                      {
                        'type': 'navigate',
                        'to': 'x',
                        'when': {'left': 2.5, 'op': 'isTrue'},
                      },
                    ],
                  },
                ],
              },
            ],
          },
        },
      };
      final n = printNormalized(doc, standardCatalog);
      final actions = ((((n['nodes']! as Map)['b'] as Map)['actions'] as List).single as Map)['actions'] as List;
      expect((actions[0] as Map)['when'], {'left': '3', 'op': 'equalsTo', 'right': 'true'});
      expect(((actions[1] as Map)['condition'] as Map)['and'], [
        {'left': '1', 'op': 'isTrue'},
      ]);
      expect((((actions[1] as Map)['then'] as List).single as Map)['when'], {'left': '2.5', 'op': 'isTrue'});
    });

    test('the screen\x27s other reactions are lines: on load={…}, a trigger\x27s fields in parentheses', () {
      const text = 'state saved=[]\nstate t=0\n'
          'on load={saved=coalesce(storage.saved, []); scroll top}\n'
          'on backPressed(when={t > 0})={t=t-1}\n'
          'every 1s onTick={t=t+1}\n'
          'on keyDown(key=Escape, repeat=true)={t=0}\n'
          'Box#top';
      final r = _parse(text);
      expect(r.issues, isEmpty);
      expect([for (final x in _reactions(r, 'screen')) (x as Map)['trigger']], [
        {'type': 'load'},
        {'type': 'backPressed', 'when': r'${= t > 0}'},
        {'type': 'timer', 'intervalMs': 1000},
        {'type': 'keyDown', 'key': 'Escape', 'repeat': true},
      ]);
      final printed = _roundTrip(text);
      for (final line in text.split('\n').skip(2).take(4)) {
        expect(printed, contains(line));
      }
      expect(printed, isNot(contains('document')));
    });

    test('an on line with a trigger the screen does not have, or written wrong, is said', () {
      final r = _parse('on lod={x=1}\non load {x=1}\nBox');
      expect(r.issues.map((i) => i.message), [
        startsWith('The screen has no trigger "lod". Did you mean "load"?'),
        startsWith('A reaction of the screen is a line of its own: on load={…}'),
      ]);
    });

    test('a formula that is only a name, in a field: a quoted string keeps \${…} as written', () {
      const line = r'Box#b onTap={setVariable variable=x value="${= ready}" op=toggle} onScroll(when="${= ready}")={x=true}';
      const text = 'state ready=true\nstate x=false\n$line';
      final r = _parse(text);
      expect(r.issues, isEmpty);
      final reactions = _reactions(r, 'b');
      expect(((reactions[0] as Map)['actions'] as List).single, {'type': 'setVariable', 'variable': 'x', 'value': r'${= ready}', 'op': 'toggle'});
      expect((reactions[1] as Map)['trigger'], {'type': 'scroll', 'when': r'${= ready}'});
      expect(_roundTrip(text).split('\n').last, 'Column#b ${line.substring('Box#b '.length)}');
    });
  });
}
