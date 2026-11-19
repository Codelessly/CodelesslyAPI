// What a definition says beyond a macro of fixed lines (docs/design/20
// section 13): values worked out as a use is read, the line that takes a
// use's other words, a role on a body's root, several lines at its margin,
// and a word that stands for a statement.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

NotationResult _read(String text, {bool open = false, double width = 1440}) =>
    parseNotation(text, catalog: standardCatalog, options: withTestWords(open ? NotationOptions(width: width).open() : NotationOptions(width: width)));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast();

List<Map<String, Object?>> _nodes(NotationResult r, String type) => [
      for (final n in (r.document['nodes'] as Map).values.cast<Map>())
        if (n['type'] == type) n.cast<String, Object?>(),
    ];

void main() {
  group('values worked out as a use is read', () {
    test('arithmetic on a written value is its result, not a binding', () {
      final r = _read('''
Column
  Tile size=48
  Tile
define Tile size=40
  Box w={size} h={size} radius={round(size/4)} center middle
    Icon "star" size={size/2}
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'tile1')['decoration'] as Map)['radius'], 12);
      expect(_node(r, 'tile1')['bind'], isNull);
      expect((_node(r, 'tile2')['decoration'] as Map)['radius'], 10);
      expect([for (final i in _nodes(r, 'icon')) (i['props'] as Map)['size']], [24, 20]);
    });

    test('a value read from the state is still read at run time', () {
      final r = _read('''
state n=40
Column
  Tile size={n}
define Tile size=40
  Box w=40 h=40 radius={size/4}
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'tile1')['bind'] as Map)['decoration.radius'], r'${= (n)/4}');
    });

    test('a line written only when its parameter is given; an else when it is not', () {
      final r = _read('''
Column
  Item "Inbox" badge="3"
  Item "Sent"
define Item "label" badge
  Row gap=8
    Text "{label}"
    if badge
      Text.caption "{badge}"
    else
      Icon "check"
''');
      expect(r.issues, isEmpty);
      expect([for (final t in _nodes(r, 'text')) (t['props'] as Map)['text']], ['Inbox', '3', 'Sent']);
      expect(_nodes(r, 'icon'), hasLength(1));
      expect(jsonEncode(r.document), isNot(contains('visible')));
    });

    test('an if that reads the state stays an if', () {
      final r = _read('''
state on=true
Column
  Item on={on}
define Item on=false
  Column
    if on
      Text "on"
''');
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains(r'"visible":"${= (on)}"'));
    });

    test('a text worked out: a label in capitals; a variant chosen by a value', () {
      final r = _read('''
Column
  Head "Hello" level=1
  Head "Small print" level=3
define Head "text" level=2
  Text.{level == 1 ? "heading1" : level == 2 ? "heading2" : "heading3"} "{upper(text)}"
''');
      expect(r.issues, isEmpty);
      final texts = _nodes(r, 'text');
      expect([for (final t in texts) (t['props'] as Map)['text']], ['HELLO', 'SMALL PRINT']);
      final h1 = _read('Column\n  Text.heading1 "HELLO"\n  Text.heading3 "SMALL PRINT"\n');
      expect([for (final t in texts) (t['props'] as Map)['style']], [for (final t in _nodes(h1, 'text')) (t['props'] as Map)['style']]);
    });

    test('a text with a value of the state in it is upper-cased at run time', () {
      final r = _read('''
state team={"name":"Ops"}
Column
  Label "{team.name}"
define Label "text"
  Text "{upper(text)}"
''');
      expect(r.issues, isEmpty);
      expect((_nodes(r, 'text').single['props'] as Map)['text'], contains('upper'));
    });
  });

  group('the line that takes what a use writes beyond its signature', () {
    test('... on a body line: the universal words go there, and every other word the use writes', () {
      final r = _read('''
Column
  Band center id=pricing tablet.pad=16
    Text "in"
define Band
  Column w=fill pad=24 ...
    Column w=fill maxw=720
      ...
''', open: true);
      final band = _node(r, 'band1');
      expect((band['props'] as Map)['crossAxisAlignment'], 'center');
      expect(jsonEncode(band['media']), contains('"padding":16'));
      expect(r.vocabulary.where((u) => u.word == 'tablet.pad' || u.word == 'center'), isEmpty);
    });

    test('... on an inner line: the root keeps the use\'s id, the marked line its words', () {
      final r = _read('''
Column
  Band#prices center
    Text "in"
define Band
  Column w=fill pad=24
    Column w=fill maxw=720 ...
      ...
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'prices')['props'] as Map)['crossAxisAlignment'], 'start');
      final inner = _node(r, (_node(r, 'prices')['children'] as List).single as String);
      expect((inner['props'] as Map)['crossAxisAlignment'], 'center');
    });

    test('a key the use gives that the marked line writes too is the use\'s', () {
      final r = _read('Column\n  Box2 pad=4\ndefine Box2\n  Column pad=24 gap=8 ...\n    Text "x"\n');
      expect(r.issues, isEmpty);
      expect((_node(r, 'box21')['layout'] as Map)['padding'], 4);
    });

    test('without the mark, a word the definition does not have is recorded, as before', () {
      final r = _read('Column\n  Box2 wobble=4\ndefine Box2\n  Column pad=24\n    Text "x"\n', open: true);
      expect(r.vocabulary.where((u) => u.kind == 'parameter' && u.word == 'wobble'), hasLength(1));
    });
  });

  group('a role on a body\'s root, and several lines at its margin', () {
    test('Column~section on the root is the root\'s role: the reflow gives it a section\'s tablet and phone padding', () {
      const page = 'Page\n  Band\n    Text "in"\ndefine Band\n  Column~section w=fill pad=[24,64,24,64]\n    ...\n';
      final r = _read(page);
      expect(r.issues, isEmpty);
      final word = _read('Page\n  Section\n    Text "in"\n');
      expect(_node(r, 'band1')['media'], isNotNull);
      expect(jsonEncode(_node(r, 'band1')['media']), jsonEncode(_node(word, 'column2')['media']));
      expect(readDefinitions({'x.txt': 'Band\n  Row~app w=fill\n'}).problems, isEmpty);
    });

    test('two lines at the margin are written where the use is, the use\'s words on the marked one', () {
      final r = _read('''
Column
  Foot gap=4
    Text "me"
define Foot gap=2
  Spacer
  Column w=fill gap={gap} border-top=#FFE5E7EB ...
    ...
''');
      expect(r.issues, isEmpty);
      final root = _nodes(r, 'column').first;
      expect([for (final c in root['children'] as List) _node(r, c as String)['type']], ['spacer', 'column']);
    });
  });

  group('a word that stands for a statement', () {
    test('a key line: the chord worked out from the use, the use\'s other words where the mark is', () {
      final r = _read('''
state items=[1]
Column
  Hotkey "ctrl + k" hint="K" onPress={toast "k"}
  Hotkey keys="ArrowLeft" when={items!=[]} onPress={toast "l"}
  Hotkey "enter" when items!=[] onPress={toast "e"}
define Hotkey "keys" key hint onPress
  key {replace(coalesce(keys, key), " ", "")} ... onPress={onPress}
''');
      expect(r.issues, isEmpty);
      final byHand = _read('state items=[1]\nColumn\n  key ctrl+k onPress={toast "k"}\n  key ArrowLeft when items!=[] onPress={toast "l"}\n  key enter when items!=[] onPress={toast "e"}\n');
      expect(jsonEncode(_node(r, 'screen')['actions']), jsonEncode(_node(byHand, 'screen')['actions']));
    });

    test('a state line, under a lowercase word', () {
      final r = _read('state cart=[1,2]\nColumn\n  total2 sum={sum(cart)}\n  Text "{sum}"\ndefine total2\n  state ...\n');
      expect(r.issues, isEmpty);
      expect((_nodes(r, 'text').single['props'] as Map)['text'], r'${= (sum(cart))}');
    });

    test('a node is still the first line of any other body, and a lowercase word is still refused there', () {
      expect(readDefinitions({'x.txt': 'lower\n  Text "x"\n'}).problems.single, contains('capitalised'));
      // A statement of the grammar is never a word's: `if` lines stay `if` lines.
      expect(readDefinitions({'x.txt': 'if\n  state ...\n'}).problems.single, contains('is a statement of the notation'));
      final r = _read('state on=true\nColumn\n  if on\n    Text "a"\ndefine if\n  state ...\n');
      expect(_nodes(r, 'text'), hasLength(1));
    });
  });

  group('what stopped definitions', () {
    test('a dotted key in a body reads the use\'s values (hovered.fill={p}, a state\'s look)', () {
      final r = _read('Column\n  Chip2 tint=#FFDC2626\ndefine Chip2 tint=#FF2563EB\n  Row pad=8 hovered.fill={tint} selected.fills=[{"color":"{tint}","opacity":0.12}] selected=true\n    Text "x"\n');
      expect(r.issues, isEmpty);
      final states = jsonEncode(_node(r, 'chip21')['states']);
      expect(states, contains('#FFDC2626'));
      expect(states, isNot(contains('tint')));
    });
  });

  group('the theme read in a body (theme.<name>)', () {
    Json theme(String name) => (jsonDecode(File('test/fixtures/themes/$name.json').readAsStringSync()) as Map).cast<String, Object?>();
    NotationResult under(String text, String? name) => parseNotation(text,
        catalog: standardCatalog, options: name == null ? const NotationOptions(width: 1440) : NotationOptions.fromTheme(ThemeTokens.fromJson(theme(name)).toJson(), width: 1440));

    test('a look the page words read, as they write it: the same document as the page word', () {
      const word = 'Page\n  Section\n    Text "in"\n';
      const defined = 'Page\n  Band\n    Text "in"\ndefine Band\n  Column~section w=fill center pad=[theme.gutter,theme.sectionPad,theme.gutter,theme.sectionPad]\n    Column w=fill maxw={theme.contentWidth} gap=32\n      ...\n';
      for (final name in [null, 'cards', 'desk']) {
        final a = under(word, name), b = under(defined, name);
        expect(b.issues, isEmpty);
        expect(jsonEncode(_node(b, 'band1')..remove('children')), jsonEncode(_node(a, 'column2')..remove('children')), reason: '$name');
      }
    });

    test('a look the theme does not give leaves the key out; in an expression, a colour, a role and a named colour as the page words write them', () {
      const text = 'Column\n  Pane2\ndefine Pane2\n  Column fill={theme.paneFill} border={theme.line}\n    Box w=6 h=6 fill={1 == 1 ? theme.accent : theme.track}\n';
      final core = under(text, null), desk = under(text, 'desk');
      expect((_node(core, 'pane21')['decoration'] as Map).containsKey('fills'), isFalse);
      expect(jsonEncode(_node(desk, 'pane21')['decoration']), contains('fills'));
      expect(jsonEncode(core.document), contains('#FF2563EB'));
      final named = parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(ThemeTokens.fromJson(theme('desk')).toJson(), width: 1440, named: true));
      expect(named.issues, isEmpty);
    });

    test('a text style by name when the theme has it, else the fallback', () {
      const text = 'Column\n  Note2 "x"\ndefine Note2 "t"\n  Text.{coalesce(theme.style.nope, theme.style.caption, "muted")} "{t}"\n';
      final r = under(text, null);
      expect(r.issues, isEmpty);
      expect(jsonEncode(_nodes(r, 'text').single['props']), jsonEncode(_nodes(under('Column\n  Text.caption "x"\n', null), 'text').single['props']));
    });

    test('a name the theme does not give a definition is an issue that lists the names; the run-time theme is left to the app', () {
      final r = under('Column\n  Odd2\ndefine Odd2\n  Text "{theme.wobble}" color={theme.colors.ink}\n', null);
      expect(r.issues.single.message, allOf(contains('theme.wobble'), contains('theme.accent'), contains('theme.style.<name>')));
      expect(jsonEncode(r.document), contains(r'${theme.colors.ink}'));
    });
  });

  group('what stopped definitions, more', () {
    List<Object?> actionsOf(NotationResult r, String id) => (_node(r, id)['actions'] as List?) ?? const [];

    test('a record line of a definition is its body\'s, written before the page or after it, and never the page\'s', () {
      const def = 'define Pic\n  Stack w=100 h=100\n    Box w=100 h=100\n    customPaint viewBox=[100,100]\n      circle c=[50,50] radius=20 fill=#FF2563EB\n';
      const page = 'Column\n  Row\n    Pic\n  Row\n    Text "last row"\n';
      for (final text in ['$def$page', '$page$def']) {
        final r = _read(text);
        expect(r.issues, isEmpty, reason: text);
        final painted = [for (final e in (r.document['nodes'] as Map).entries) if ((e.value as Map).containsKey('customPaint')) e.key];
        expect(painted, ['pic1'], reason: text);
      }
    });

    test('key {param} in a body with a root takes the chord from the use', () {
      final r = _read('state n=0\nColumn\n  Keys2 keys="ctrl+j" onGo={n=1}\ndefine Keys2 keys onGo\n  key {keys} onPress={onGo}\n  Text "k"\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(_node(r, 'screen')['actions']), contains('"key":"ctrl+j"'));
    });

    test('a parameter named like an action\'s field leaves the field\'s name', () {
      final r = _read('Column\n  Save2 "hello" sound="ding"\ndefine Save2 "text" sound\n  Button "Save" onTap={downloadFile fileName="a.txt" text={text}; playSound sound={sound}}\n');
      expect(r.issues, isEmpty);
      final a = jsonEncode(actionsOf(r, 'save21'));
      expect(a, allOf(contains('"text"'), contains('hello'), contains('ding')));
      expect(a, isNot(contains('"hello":')));
    });

    test('an event of a trigger with fields in a body is forwarded, and the word\'s state in it is its own', () {
      final r = _read('state n=0\nColumn\n  Pad onCompose={n=n+1}\ndefine Pad onCompose\n  state held=false\n  Column w=40 h=40 onKeyDown(key=c)={onCompose} onHold(holdMs=300)={held=true}\n');
      expect(r.issues, isEmpty);
      final a = jsonEncode(actionsOf(r, 'pad1'));
      expect(a, contains('"variable":"n"'));
      expect(a, contains('held_pad1'));
      expect(r.vocabulary.where((u) => u.kind == 'verb'), isEmpty);
    });

    test('an on line in a body forwards the use\'s events, before the root or under it', () {
      final r = _read('state n=0\nstate x=0\nColumn\n  Watch2 onSeen={n=n+1}\ndefine Watch2 onSeen\n  on valueChanged(variable=x)={onSeen}\n  Text "w"\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains('"variable":"n"'));
    });

    test('a variable a key names by a string (measure.variable) is the word\'s own when the body states it', () {
      final r = _read('Column\n  Frame2\n  Frame2\ndefine Frame2\n  state box={}\n  Column w=fill measure.variable="box"\n    Text "{box.width}"\n');
      expect(r.issues, isEmpty);
      final doc = jsonEncode(r.document);
      expect(doc, allOf(contains('"box_frame21"'), contains('"box_frame22"')));
      expect((_node(r, 'frame21')['measure'] as Map)['variable'], 'box_frame21');
      expect((_node(r, 'frame22')['measure'] as Map)['variable'], 'box_frame22');
    });
  });
}
