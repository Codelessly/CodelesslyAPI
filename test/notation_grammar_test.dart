// The notation's grammar, one rule per role
// (docs/design/17-notation-grammar-audit.md): a parameter is key=value, a value
// worked out is in braces, a control's variable is bind=name, what a node
// does is an event with its actions in braces. The grammar it replaced
// (key:value, =name, key:=expression, -> actions) is not read: each of its
// spellings is an error that says what to write.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, {double width = 390}) =>
    Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: NotationOptions(width: width)));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

List<Object?> _actions(NotationResult r, String id) => (_node(r, id)['actions'] as List<Object?>?) ?? const [];

List<String> _triggers(NotationResult r, String id) => [for (final a in _actions(r, id)) '${((a! as Map)['trigger'] as Map)['type']}'];

/// What the parser says about [text], one message per issue.
List<String> _said(String text, {double width = 390}) => [for (final i in _parse(text, width: width).issues) i.message];

void main() {
  group('one rule per role', () {
    test('a parameter is key=value: a word, a number, a text, a list; a bare word is a flag or a layout word', () {
      final r = _parse('Column gap=12 pad=16\n  Input "Email" hint="you@example.com" w=240\n  Select items=["S","M","L"]\n  Row#bar between grow\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect((_node(r, 'column1')['props'] as Map)['spacing'], 12);
      expect((_node(r, 'textField1')['layout'] as Map)['width'], 240);
      expect((_node(r, 'dropdown1')['props'] as Map)['items'], ['S', 'M', 'L']);
      expect((_node(r, 'bar')['props'] as Map)['mainAxisAlignment'], 'spaceBetween');
      expect((_node(r, 'bar')['layout'] as Map)['flex'], 1);
    });

    test('braces hold a value worked out from the state: in a text and after a key, spaces and quotes included', () {
      final r = _parse('state count=2\nstate tab="all"\nColumn\n'
          '  Text#t "Total: {count * 2}"\n'
          '  Text#v "Some" visible={count > 0}\n'
          '  ChoiceChip#c "All" selected={tab == "all"} onTap={tab="all"}\n'
          '  Box#b fill={count > 1 ? "#FF2563EB" : "#FFE5E7EB"} w={count * 10} h=8\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect((_node(r, 't')['props'] as Map)['text'], r'Total: ${= count * 2}');
      expect(_node(r, 'v')['bind'], {'visible': r'${= count > 0}'});
      expect((_node(r, 'c')['bind'] as Map)['props.selected'], r'${= tab == "all"}');
      expect((_node(r, 'b')['bind'] as Map)['decoration.fills[0].color'], r'${= count > 1 ? "#FF2563EB" : "#FFE5E7EB"}');
      expect((_node(r, 'b')['bind'] as Map)['layout.width'], r'${= count * 10}');
    });

    test('a list or a map after a key is the JSON it is; one that is worked out is in braces', () {
      final r = _parse('state a=1\nColumn\n  BarChart#c values=[3,5,4] labels=["a","b","c"]\n  BarChart#d values={[a+1,a*2,3]}\n  Text "x" {"props":{"maxLines":2}}\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect((_node(r, 'c')['props'] as Map)['values'], [3, 5, 4]);
      expect((_node(r, 'd')['bind'] as Map)['props.values'], r'${= [a+1,a*2,3]}');
      expect((_node(r, 'text1')['props'] as Map)['maxLines'], 2);
    });

    test('bind=name keeps a control\'s value in a variable, both ways; bind={expression} is what a node only shows', () {
      final r = _parse('state done=1\nstate rows=[{"name":"Ada","on":true}]\nColumn\n'
          '  Slider#s bind=volume\n'
          '  Input#i "Email" bind=email\n'
          '  Progress#p bind={done/5}\n'
          '  each row in rows\n'
          '    Toggle#t "On" bind=row.on\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(_node(r, 's')['bind'], {'props.value': r'${volume}'});
      expect(_actions(r, 's').single, {
        'trigger': {'type': 'changed'},
        'actions': [
          {'type': 'setVariable', 'variable': 'volume', 'value': r'${result}'},
        ],
      });
      expect(_node(r, 'i')['bind'], {'props.initialValue': r'${email}'});
      expect(_node(r, 'p')['bind'], {'props.value': r'${= done/5}'});
      expect(_node(r, 'p')['actions'], isNull, reason: 'a share is shown, not set');
      expect(jsonEncode(_node(r, 't')['actions']), contains('setAt(rows,index,with(item,\\"on\\",result))'));
      final variables = ((r.document['variables'] as Map)['screen'] as List).map((v) => (v as Map)['name']);
      expect(variables, containsAll(['volume', 'email']));
    });

    test('what a node does is an event with its actions in braces: onTap, onChange on a control, the others by name', () {
      final r = _parse('state n=0\nColumn\n'
          '  Button#a "Add" onTap={n=n+1; toast "Added"}\n'
          '  Slider#s onChange={n=result}\n'
          '  Card#c onLongPress={n=0} onDoubleTap={n=2} onSwipeLeft={n=n-1} onRightClick={n=9} onHover={n=5} {"opacity":0.5}\n'
          '  Input#i "Name" onBlur={n=1} onFocus={n=2} onSubmit={n=3}\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect((_actions(r, 'a').single as Map)['actions'], [
        {'type': 'setVariable', 'variable': 'n', 'value': r'${= n+1}'},
        {'type': 'showToast', 'message': 'Added'},
      ]);
      expect(_triggers(r, 'a'), ['click']);
      expect(_triggers(r, 's'), ['changed']);
      expect(_triggers(r, 'c'), ['longPress', 'doubleTap', 'swipeLeft', 'secondaryClick', 'cursorEnter']);
      expect(_node(r, 'c')['opacity'], 0.5, reason: 'the {…} tail still closes the line');
      expect(_triggers(r, 'i'), ['focusLost', 'focusGained', 'submitted']);
    });

    test('= assigns a variable: where it starts, and what an action makes it', () {
      final r = _parse('state qty=1\nstate name="Ada"\nRow\n  Button#more "+" onTap={qty=qty+1; name="Bo"}\n');
      expect(r.issues, isEmpty);
      expect((r.document['variables'] as Map)['screen'], [
        {'name': 'qty', 'type': 'integer', 'value': 1},
        {'name': 'name', 'type': 'text', 'value': 'Ada'},
      ]);
      expect((_actions(r, 'more').single as Map)['actions'], [
        {'type': 'setVariable', 'variable': 'qty', 'value': r'${= qty+1}'},
        {'type': 'setVariable', 'variable': 'name', 'value': 'Bo'},
      ]);
    });

    test('a page named after go is its id; a page worked out is in braces', () {
      final r = _parse('state kind="A B"\nColumn\n  Button#a "Docs" onTap={go get-started}\n  Button#b "Open" onTap={go {replace(lower(kind)," ","_")}}\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect((_actions(r, 'a').single as Map)['actions'], [
        {'type': 'navigate', 'to': 'get-started'},
      ]);
      expect((_actions(r, 'b').single as Map)['actions'], [
        {'type': 'navigate', 'to': r'${= replace(lower(kind)," ","_")}'},
      ]);
    });

    test('a condition: an if line over the lines under it, visible={…} on one line; hide= and show= are sizes', () {
      final r = _parse('state step=0\nPage\n  Section\n    if step>0\n      Text#a "Back"\n    Text#b "Next" visible={step < 3}\n    Text#c "Wide only" hide=phone\n', width: 1280);
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(_node(r, 'a')['bind'], {'visible': r'${= step>0}'});
      expect(_node(r, 'b')['bind'], {'visible': r'${= step < 3}'});
      expect(jsonEncode(_node(r, 'c')['media']), contains('"visible":false'));
    });

    test('a name: #id after the type; id=name on a line is an anchor a scroll goes to', () {
      final r = _parse('Page\n  Section#pricing\n    Heading "Why" id=why\n    Button#go "Pricing" onTap={scroll pricing; scroll why; open more}\nMenu#more\n  MenuItem#share "Share" onTap={toast "Shared"}\n', width: 1280);
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect((r.document['nodes'] as Map).keys, containsAll(['pricing', 'more']));
      final actions = (_actions(r, 'go').single as Map)['actions'] as List;
      expect((actions[0] as Map)['node'], 'pricing');
      expect((r.document['nodes'] as Map).keys, contains((actions[1] as Map)['node']), reason: 'the anchor is the heading\'s node');
      expect((actions.last as Map)['to'], 'more');
      expect(jsonEncode(_node(r, 'share')['actions']), allOf(contains('showToast'), contains('closeModal')), reason: 'a menu\'s line closes it after its actions');
    });

    test('time, a drop and a menu: every … onTick={…}, drop=group onDrop={…}, menu=id', () {
      final r = _parse('state t=0\nstate done=[]\nevery 1s when t<9 onTick={t=t+1}\nColumn#root\n  Card#card drag=todo(t)\n  Column#bin drop=todo onDrop={done=append(done,result.data)} menu=more\nMenu#more\n  MenuItem "Clear" onTap={done=[]}\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(jsonEncode(_node(r, 'screen')['actions']), allOf(contains('"timer"'), contains('"intervalMs":1000')));
      expect(_triggers(r, 'bin'), ['drop', 'secondaryClick', 'longPress']);
    });

    test('the lines the notation writes itself are in the grammar: a Nav\'s menu, Dots, a NavItem\'s look', () {
      final r = _parse('state tab="a"\nstate page=0\nPage\n  Nav\n    Brand "Relay"\n    Row gap=4\n      Link "Docs" onTap={go docs}\n      Link "Pricing" href="#pricing"\n  Section#pricing\n    NavItem "A" selected={tab=="a"} onTap={tab="a"}\n    Dots bind=page count=3\n', width: 1280);
      expect(r.issues, isEmpty, reason: '${r.issues}');
      final doc = jsonEncode(r.document);
      expect(doc, contains('"variable":"navMenu"'));
      expect(doc, contains(r'${= index==page?16:6}'));
    });

    test('the prompt teaches only this grammar', () {
      for (final width in const [390.0, 1280.0]) {
        final prompt = Catalog.run(standardCatalog, () => notationPrompt(catalog: standardCatalog, options: NotationOptions(width: width)));
        expect(prompt, isNot(contains(':=')));
        expect(prompt, isNot(contains('->')));
        expect(RegExp(r'\s=[A-Za-z]').allMatches(prompt).map((m) => prompt.substring(m.start, m.start + 20)), isEmpty);
        expect(RegExp(r'\s(gap|pad|w|h|fill|radius|items|visible|selected|bind|size|icon):\S').allMatches(prompt).map((m) => prompt.substring(m.start, m.start + 20)), isEmpty);
        expect(prompt, contains('bind=name'));
        expect(prompt, contains('visible={count > 0}'));
        expect(prompt, contains('onTap={'));
      }
    });
  });

  group('the grammar it replaced is not read: each spelling is an error that says what to write', () {
    test('key:value', () {
      final r = _parse('Column gap:12\n  Text "x" size:20 hint:"a b"\n');
      expect(r.issues.map((i) => i.message), [
        'A value is written with =, not a colon: gap=12.',
        'A value is written with =, not a colon: size=20.',
        'A value is written with =, not a colon: hint=….',
      ]);
      expect((_node(r, 'column1')['props'] as Map).containsKey('spacing'), isFalse, reason: 'not read');
    });

    test('=name', () {
      final r = _parse('Column\n  Slider#s =volume\n');
      expect(r.issues.single.message, contains('write bind=name'));
      expect(_node(r, 's')['bind'], isNull);
    });

    test('key:=expression, and an expression written bare after a key', () {
      expect(_said('state n=1\nColumn\n  Text "x" visible:=n>0\n').single, contains('visible=…'));
      final bare = _said('state n=1\nColumn\n  Button "Go" enabled=n > 0\n');
      expect(bare.first, 'A value read from the state is written in braces: enabled={n}.');
      expect(bare.length, greaterThan(1), reason: 'what follows the first word is not read either');
    });

    test('a declared variable written bare is said, not guessed; a word that names none is the word', () {
      expect(_said('state pick="a"\nColumn\n  Text "x" color=pick\n').single, 'A value read from the state is written in braces: color={pick}.');
      expect(_said('Column\n  Text "x" color=primary\n'), isEmpty);
    });

    test('the arrow', () {
      final r = _parse('state n=0\nColumn\n  Button#b "Add" -> n=n+1\n');
      expect(r.issues.single.message, startsWith('There is no arrow. What a node does is an event with its actions in braces: onTap={'));
      expect(_node(r, 'b')['actions'], isNull);
    });

    test('a handler on a line of its own, with a colon, in quotes or to the end of the line', () {
      expect(_said('Column\n  Button "Zero"\n    onPressed: n = 0\n').single, startsWith('A handler is written on the line of its node'));
      expect(_said('Column\n  Button "Zero" onTap:{n=0}\n'), [contains('with =, not a colon')]);
      expect(_said('Column\n  Button "Zero" onTap="n=0"\n').single, startsWith('An event\'s actions are written in braces: onTap={'));
      expect(_said('Column\n  Button "Zero" onTap=n\n').single, startsWith('An event\'s actions are written in braces'));
    });

    test('an event a plain node does not have', () {
      expect(_said('Column\n  Button "Go" onWhatever={toast "x"}\n').single, startsWith('A Button has no event "onWhatever". Events: onTap, onChange'));
    });

    test('swipe:left, show:condition, an every with an arrow, go with a bare expression', () {
      expect(_said('Column\n  Row swipe=left onTap={toast "x"}\n'), isNotEmpty);
      expect(_said('state open=false\nPage\n  Section\n    Text "x" show={open}\n', width: 1280).single, 'show= takes a size (phone, tablet): a condition is written visible={condition}.');
      expect(_said('state t=0\nevery 1s -> t=t+1\nColumn\n').single, startsWith('An "every" line is: every 1000 onTick={name=value}'));
      expect(_said('state k="a"\nColumn\n  Button "Go" onTap={go lower(k)}\n').single, 'A page that is worked out is written in braces: go {lower(k)}. A bare word after go is the id of the page.');
    });

    test('a list holding expressions without braces, an anchor after the line, an expression where the text goes', () {
      expect(_said('state a=1\nColumn\n  BarChart values=[a+1,2]\n').single, 'Not a list of values. One that is worked out is written in braces: values={[a+1,2]}.');
      expect(_said('Column\n  Text "Why" #why\n').single, contains('Unknown word "#why"'));
      expect(_said('state open=true\nColumn\n  Button open ? "Hide" : "Show"\n'), isNotEmpty);
    });
  });

  group('read, though the prompt does not teach it', () {
    test('let, for … in, else, += and .add(), a bare each, single quotes, a name = value line, sticky=true', () {
      final r = _parse('rows = [{"n":1}]\nlet total = sum(rows, r => r.n)\nstate tab="a"\nColumn\n'
          '  for r in rows\n    Text "{r.n}"\n'
          '  each rows\n    Text "{row.n}"\n'
          '  if tab==\'a\'\n    Text "A"\n  else\n    Text "B {total}"\n'
          '  Button#b "Add" onTap={rows.add({"n":2}); tab += "b"}\n'
          '  Column sticky=true\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(jsonEncode(_node(r, 'b')['actions']), contains('append(rows,{'));
    });
  });
}
