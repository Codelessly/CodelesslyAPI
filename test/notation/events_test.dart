// Events and actions in the notation (docs/design/22-notation-parity.md
// sections 2.2 and 2.3): every trigger of the catalog as `on<Trigger>(…)={…}`
// and every action type by its name and fields; each written, expanded,
// printed and read back as the same line.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/notation.dart' show notationEventName, notationEventTrigger;
import 'package:codelessly_api/src/core/notation/print_events.dart' show printCanvasEvents, printEvents;
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
      final r = _parse('Input#q "Search" bind=query onSubmit={toast "Go"}');
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
}
