// Lines models write whose meaning the expander could take wrongly without a
// word (docs/design/13-compact-notation.md, 19-open-vocabulary.md): each is
// read as meant, or said where it is written with what to write instead.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/vocabulary.dart' show parameterKin;
import 'package:test/test.dart';

NotationResult _parse(String text, [NotationOptions options = const NotationOptions()]) => parseNotation(text, catalog: standardCatalog, options: options);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

/// The actions of node [id]'s first reaction.
List<Object?> _firstActions(NotationResult r, String id) => ((_node(r, id)['actions'] as List).first as Map)['actions'] as List;

/// The screen's variables, by name.
Map<String, Map<String, Object?>> _variables(NotationResult r) => {
      for (final v in ((r.document['variables'] as Map?)?['screen'] as List?) ?? const []) (v as Map)['name'] as String: v.cast<String, Object?>(),
    };

/// The canvas's keyDown reactions, by key.
Map<String, Object?> _keys(NotationResult r) => {
      for (final a in (_node(r, 'screen')['actions'] as List?) ?? const [])
        if (((a as Map)['trigger'] as Map)['type'] == 'keyDown') (a['trigger'] as Map)['key'] as String: a['actions'],
    };

void main() {
  group('go: a bare word that names one of the app\'s screens is that screen', () {
    const text = '''
state recipes=[{"name":"Soup"}]
state tab="recipes"
Column
  Button#a "Recipes" onTap={go recipes}
  Button#b "Cook" onTap={go cook}
  Button#c "Worked out" onTap={go {recipes}}
  Button#d "Tab" onTap={go tab}
''';

    test('even beside a variable of its name; go {…} is still worked out', () {
      final r = _parse(text, const NotationOptions().withScreens(['recipes', 'cook-mode', 'favourites']));
      expect(r.issues, isEmpty);
      expect(_firstActions(r, 'a'), [
        {'type': 'navigate', 'to': 'recipes'},
      ]);
      // Named by part of its name, as the corpus tool reads it.
      expect(_firstActions(r, 'b'), [
        {'type': 'navigate', 'to': 'cook-mode'},
      ]);
      expect(_firstActions(r, 'c'), [
        {'type': 'navigate', 'to': r'${= recipes}'},
      ]);
      // A variable no screen is named after is the page it holds.
      expect(_firstActions(r, 'd'), [
        {'type': 'navigate', 'to': r'${= tab}'},
      ]);
    });

    test('alone (no screens known) a name the state has is read as before', () {
      expect(_firstActions(_parse(text), 'a'), [
        {'type': 'navigate', 'to': r'${= recipes}'},
      ]);
    });

    test('notationScreen: an id, its spelling with _ or capitals, or the one screen its words make', () {
      const screens = ['recipes', 'cook-mode', 'add-a-recipe', 'add-a-note'];
      expect(notationScreen('recipes', screens), 'recipes');
      expect(notationScreen('Cook_Mode', screens), 'cook-mode');
      expect(notationScreen('cook', screens), 'cook-mode');
      expect(notationScreen('add', screens), isNull, reason: 'two screens start with it');
      expect(notationScreen('recipes', const []), isNull);
    });
  });

  test('key: the names writers give keys are the keys a keyboard sends; a name no key has is said', () {
    final r = _parse('''
state n=0
key left onPress={n=n-1}
key alt+right onPress={n=n+1}
key Del onPress={n=0}
key esc onPress={n=0}
key mod+k onPress={n=5}
key foo onPress={n=9}
Column
  Text "{n}"
''');
    expect(_keys(r).keys, ['ArrowLeft', 'alt+ArrowRight', 'Delete', 'esc', 'mod+k']);
    expect(r.issues.map((i) => i.message), [startsWith('No key "foo". A shortcut names one key')]);
    expect(r.issues.single.line, 7);
  });

  test('shortcut= on a line that is tapped: the key runs its tap, its tooltip names the key; with nothing to run it is said', () {
    final r = _parse('''
state bold=false
Column
  Button#b "Bold" shortcut="mod+b" onTap={bold=!bold}
  Button#c "Next" shortcut="alt+right" onTap={toast "next"}
  Button#d "Nothing" shortcut="mod+d"
  Button#e "Bad" shortcut="mod+nokey" onTap={toast "x"}
''');
    expect(_keys(r), {
      'mod+b': [
        {'type': 'setVariable', 'variable': 'bold', 'value': r'${= !bold}'},
      ],
      'alt+ArrowRight': [
        {'type': 'showToast', 'message': 'next'},
      ],
    });
    expect(_node(r, 'b')['tooltip'], 'Ctrl+B');
    expect(_node(r, 'c')['tooltip'], 'Alt+→');
    expect(r.issues.map((i) => i.message), [startsWith('shortcut= presses a line that is tapped'), startsWith('No key "mod+nokey"')]);
  });

  test('an id with a hyphen is said once, where it is written, and read with _ there and where it is opened', () {
    final r = _parse('''
Column
  Button.ghost#indicators-button "Open" onTap={open live-image}
  Button#go "Down" onTap={scroll page-end}
  Text#page-end "End"
Dialog#live-image "Live"
  Text "x"
''');
    expect(r.issues.map((i) => i.message), [
      startsWith('An id is one word of letters, digits and _: #indicators_button, not #indicators-button'),
      startsWith('An id is one word of letters, digits and _: #page_end, not #page-end'),
      startsWith('An id is one word of letters, digits and _: #live_image, not #live-image'),
    ]);
    expect(r.issues.map((i) => i.line), [2, 4, 5]);
    expect(r.document['roots'], contains('live_image'));
    expect(_firstActions(r, 'indicators_button').single, containsPair('to', 'live_image'));
    expect((_firstActions(r, 'indicators_button').single as Map)['presentation'], 'dialog');
    expect(_firstActions(r, 'go').single, containsPair('node', 'page_end'));
  });

  test('a whole-number state that an action or a control gives a fraction is a decimal; one counted in steps of 1 stays whole', () {
    final r = _parse('''
state zoom=1
state progress=0
state n=0
state volume=50
state done=1
state total=4
state share=0
Column
  Button "+" onTap={zoom=zoom*1.25; progress=progress+0.1; n=n+1; share=done/total}
  Slider @volume
  Text "{zoom} {progress} {n} {share}"
''');
    expect(r.issues, isEmpty);
    final v = _variables(r);
    expect({for (final k in ['zoom', 'progress', 'n', 'volume', 'share']) k: v[k]!['type']},
        {'zoom': 'decimal', 'progress': 'decimal', 'n': 'integer', 'volume': 'decimal', 'share': 'decimal'});
    // A slider between whole numbers in whole steps keeps a whole-number
    // state whole (a text reading it shows 66); one whose ends have a
    // fraction writes fractions.
    final s = _parse('''
state volume=40
state zoom=1
Column
  Slider @volume min=0 max=100
  Slider @zoom min=0.5 max=3
''');
    expect(s.issues, isEmpty);
    expect({for (final k in ['volume', 'zoom']) k: _variables(s)[k]!['type']}, {'volume': 'integer', 'zoom': 'decimal'});
    expect(v['zoom']!['value'], 1);
  });

  group('selectable', () {
    test('on a line no each is directly under it is said, with where it goes', () {
      final r = _parse('''
state cards=[{"id":1,"t":"A"}]
state picked=[]
state other=[]
Column
  Column
    each c in cards
      Card selectable selected=@picked drag=todo(c.id)
        Text "{c.t}"
  Row selectable selected=@other
    Text "x"
''');
      expect(r.issues.map((i) => '${i.line}: ${i.message}'), [
        startsWith('7: selectable chooses among the rows an each repeats'),
        startsWith('9: selectable chooses among the rows an each repeats'),
      ]);
    });

    test('a row that takes its own tap chooses itself with it, then does what it does', () {
      final r = _parse('''
state cards=[{"id":1,"t":"A"},{"id":2,"t":"B"}]
state picked=[]
Column selectable selected=@picked
  each c in cards
    Card#card onTap={toast "{c.t}"}
      Text "{c.t}"
''');
      expect(r.issues, isEmpty);
      final actions = _firstActions(r, 'card');
      expect((actions.first as Map)['variable'], 'picked');
      expect(actions.last, {'type': 'showToast', 'message': r'${item.t}'});
      // The copy around it still chooses it where the row lets a tap through.
      final copy = _node(r, 'listView1Item');
      expect(((copy['actions'] as List).single as Map)['trigger'], {'type': 'click'});
    });
  });

  test('a state named as the runtime names what every expression reads is said; a site\'s variable a control binds is the site\'s', () {
    final r = _parse('state script="x"\nColumn\n  Text "{script}"\n');
    expect(r.issues.map((i) => i.message), [startsWith('script is a name the runtime gives every expression')]);
    final site = _parse('Column\n  Select @moveTo items=["a","b"]\n  Button "B" onTap={moveTo="b"}\n',
        const NotationOptions(projectVariables: {
          'moveTo': {'type': 'text', 'value': ''},
        }));
    expect(site.issues, isEmpty);
    expect(site.document['variables'], isNull);
  });

  test('size={…} on a text field is the size of its text', () {
    final r = _parse('state fs=14\nstate note=""\nColumn\n  Input "Note" multiline @note size={fs}\n');
    expect(r.issues, isEmpty);
    expect(jsonEncode(_node(r, 'textField1')['bind']), contains(r'"props.style.fontSize":"${fs}"'));
  });

  test('description, detail and note are one name, and placeholder and hint, where a word takes one of them', () {
    expect(parameterKin('description', {'note'}.contains), 'note');
    expect(parameterKin('note', {'detail'}.contains), 'detail');
    expect(parameterKin('placeholder', {'hint'}.contains), 'hint');
    expect(parameterKin('hint', {'placeholder', 'label'}.contains), 'placeholder');
    // Its own name, none of them, or two of them: left as written.
    expect(parameterKin('note', {'note', 'detail'}.contains), isNull);
    expect(parameterKin('description', {'label'}.contains), isNull);
    expect(parameterKin('description', {'detail', 'note'}.contains), isNull);
  });
}
