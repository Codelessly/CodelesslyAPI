// Lines a 30-part app rebuild (NOCD) wrote while its reference gaps were
// closed, each refused wrongly, accepted and dropped, or misreported by the
// expander. Each is fixed where the line is read: made to work, or said with
// what to write.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _read(String text) => parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 390));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes']! as Map)[id]! as Map).cast<String, Object?>();

Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();

List<Map<String, Object?>> _actions(NotationResult r, String id, [int reaction = 0]) =>
    [for (final a in ((_node(r, id)['actions']! as List)[reaction] as Map)['actions'] as List) (a as Map).cast<String, Object?>()];

List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];

Map<String, Object?> _variable(NotationResult r, String name) =>
    [for (final scope in (r.document['variables']! as Map).values) for (final v in scope as List) (v as Map).cast<String, Object?>()].firstWhere((v) => v['name'] == name);

void main() {
  group('1: a control binds its component\'s variable parameter both ways', () {
    const head = 'component Search "A search field"\n  param @query=""\nColumn#c\n';

    void bindsTheParameter(NotationResult r) {
      expect(r.issues, isEmpty);
      expect(_node(r, 'in')['bind'], containsPair('props.initialValue', r'${props.query}'));
      expect(_actions(r, 'in').single, allOf(containsPair('type', 'setVariable'), containsPair('variable', 'props.query')));
    }

    test('Input @query and Input @props.query are the parameter', () {
      bindsTheParameter(_read('$head  Input#in "Search" @query\n'));
      bindsTheParameter(_read('$head  Input#in "Search" @props.query\n'));
    });

    test('a define\'s @name=… is bound by a use\'s @variable, as before', () {
      final r = _read('define Field @query=""\n  Input#in "Search" @query\nstate q=""\nColumn\n  Field @q\n');
      expect(r.issues, isEmpty);
      expect(_actions(r, 'field1').single, containsPair('variable', 'q'));
    });

    test('@value={props.query} is said with the form', () {
      final r = _read('$head  Input#in "Search" @value={props.query}\n');
      expect(_said(r).single, allOf(contains('is no form'), contains('Write @props.query'), contains('define Word @name=')));
    });

    test('@props.x of no variable parameter names the param line', () {
      final r = _read('$head  Input#in "Search" @props.term\n');
      expect(_said(r).single, contains('param @term=""'));
    });
  });

  test('2: a define\'s per-use id leaves a variable of the same name the page\'s', () {
    final r = _read('define Card2 "label"\n  Column\n    Toggle#postVisible "{label}" @postVisible\nstate postVisible=false\nColumn\n  Card2 "hi"\n');
    expect(r.issues, isEmpty);
    expect(_node(r, 'postVisible_card21')['bind'], containsPair('props.value', r'${postVisible}'));
    expect(_actions(r, 'postVisible_card21').single, containsPair('variable', 'postVisible'));
  });

  test('3: a parameter that carries actions works whatever its name', () {
    final r = _read('define Act "label" save\n  Button "{label}" onTap={save}\nstate n=0\nColumn\n  Act "Go" save={n=n+1}\n  Act#none "No"\n');
    expect(r.issues, isEmpty);
    expect(_actions(r, 'act1').single, {'type': 'setVariable', 'variable': 'n', 'value': r'${= n+1}'});
    expect(_node(r, 'none')['actions'], isNull, reason: 'a use that gives none runs nothing');
  });

  test('4: a record\'s key named like a parameter is not the parameter', () {
    final r = _read('component Rule "r"\n  param color:String="#FF000000"\nColumn#c\n  Row#r h=1 effects={[{type: "dropShadow", color: props.color}]}\n');
    expect(r.issues, isEmpty);
    expect((_node(r, 'r')['bind']! as Map)['decoration.effects'], contains('color: props.color'));
  });

  group('5: a number of an action given a value worked out', () {
    test('delay ms={…} is the delay\'s duration', () {
      final r = _read('state x=true\nColumn\n  Button#b "Go" onTap={delay ms={x ? 4000 : 3000}; x=false}\n');
      expect(r.issues, isEmpty);
      expect(_actions(r, 'b').first, {'type': 'delay', 'duration': r'${= x ? 4000 : 3000}'});
    });

    test('a number field with no worked-out form is said, not kept as text', () {
      final r = _read('state x=0\nColumn\n  Button#b "Go" onTap={scrollTo node=b offset={x}}\n');
      expect(_said(r).single, contains('scrollTo action\'s offset is a value written out'));
      expect(_actions(r, 'b').single.containsKey('offset'), isFalse);
    });
  });

  group('6: a run names no text', () {
    test('its text, found in the line\'s, is its range', () {
      final r = _read('Column\n  Text#t "Or find help now" runs=[{"text":"find help","link":"https://a.b"}]\n');
      expect(r.issues, isEmpty);
      expect(_props(r, 't')['runs'], [
        {'start': 3, 'end': 12, 'link': 'https://a.b'},
      ]);
    });

    test('a text the line does not have is said', () {
      final r = _read('Column\n  Text#t "runs" runs=[{"text":"find help","link":"https://a.b"}]\n');
      expect(_said(r).single, allOf(contains('A run holds no text'), contains('"start":0,"end":9')));
    });
  });

  test('7: a verb\'s key it does not take is said with the typed action', () {
    final r = _read('Column\n  Button#b "Go" onTap={toast "Bad" style=error}\n  Button#c "Go" onTap={toast "Bad" type=error}\n');
    expect(_said(r)[0], contains('showToast message="Bad" style=error'));
    expect(_said(r)[1], allOf(contains('"type=error" is left out'), contains('its fields: message')));
  });

  test('8: an Image keeps what its line wrote of the picture', () {
    final r = _read('Column\n  Image#i "a.png" fit=contain fills[0].image.alignment=topCenter\n');
    expect(r.issues, isEmpty);
    expect(((_node(r, 'i')['decoration']! as Map)['fills'] as List).single, {
      'image': {'alignment': 'topCenter', 'url': 'a.png', 'fit': 'contain'},
    });
  });

  test('9: a key suggested is one the line takes', () {
    final r = _read('Column\n  Button#b "L" labelStyle.fontWeight=600\n');
    expect(_said(r).single, contains('did you mean style.textStyle.fontWeight?'));
    final ok = _read('Column\n  Button#b "L" style.textStyle.fontWeight=600\n');
    expect(ok.issues, isEmpty);
  });

  test('10: not, and, or in a state\'s formula are said as in every other formula, with the formula to write', () {
    final said = _said(_read('state x=false\nstate g:boolean={not x}\nstate f(t):text={not t ? "a" : "b"}\nColumn\n  Text "{g}{f(true)}"\n'));
    expect(said, [endsWith(': write !x'), endsWith(': write !t ? "a" : "b"')]);
    final r = _read('state x=false\nstate g:boolean={!x}\nstate f(t):text={!t ? "a" : "b"}\nColumn\n  Text "{g}{f(true)}"\n');
    expect(r.issues, isEmpty);
    expect(_variable(r, 'g')['formula'], '!x');
    expect(_variable(r, 'f')['formula'], '!t ? "a" : "b"');
  });

  test('11: a flag written =true is the flag, =false none', () {
    final r = _read('Column\n  Input#i "m" multiline=true\n  Input#j "n" multiline=false\n  Text#t "a" italic=true\n');
    expect(r.issues, isEmpty);
    expect(_props(r, 'i'), allOf(containsPair('minLines', 3), containsPair('maxLines', 6)));
    expect(_props(r, 'j').containsKey('minLines'), isFalse);
    expect((_props(r, 't')['style']! as Map)['fontStyle'], 'italic');
  });

  test('12: each a,i in … is said with the index there with nothing written', () {
    final r = _read('state items=[1,2]\nColumn\n  each dot,index in items\n    Text "{dot}"\n');
    expect(_said(r).single, allOf(contains('its place is index'), contains('Write each dot in items')));
    expect(_said(r).single, isNot(contains('No node type')));
  });

  group('13: an overlay line', () {
    test('takes the keys of the open that shows it', () {
      final r = _read('Column\n  Button#o "o" onTap={open s}\nSheet#s "Title" sheetRadius=10 showDragHandle=false\n  Text "in"\n');
      expect(r.issues, isEmpty);
      expect(_actions(r, 'o').single, allOf(containsPair('sheetRadius', 10), containsPair('showDragHandle', false)));
    });

    test('onClose runs once the overlay has closed: after its open, in the chain that opens it', () {
      final r = _read('state x=true\nColumn\n  Button#o "o" onTap={open s}\nSheet#s "Title" onClose={x=false}\n  Text "in"\n');
      expect(_said(r), isEmpty);
      final chain = (((_node(r, 'o')['actions']! as List).single as Map)['actions'] as List).cast<Map>();
      expect([for (final a in chain) a['type']], ['openModal', 'setVariable']);
      expect(chain[1], containsPair('variable', 'x'));
    });
  });

  test('14: a ListView with lines beside its each keeps pulling to refresh', () {
    final r = _read('state items=[1,2]\nstate x=false\nListView#l h=300 onRefresh={x=true}\n  Text "head"\n  each it in items\n    Text "{it}"\n');
    expect(_said(r).single, contains('for onRefresh'));
    expect(_node(r, 'l')['type'], 'listView');
    expect(((_node(r, 'l')['actions']! as List).single as Map)['trigger'], {'type': 'refresh'});
  });

  test('15: a canvas line with an id is read, its name kept, the id said', () {
    final r = _read('canvas#chat-menu "Chat menu" h=844\nColumn\n  Text "x"\n');
    expect(_said(r).single, allOf(contains('A canvas line names no id'), contains('expand --id chat-menu')));
    expect(_node(r, 'screen')['name'], 'Chat menu');
  });

  test('16: a typed null start prints back as written', () {
    final r = _read('state selected:map=null\nColumn\n  Text "{selected.name}"\n');
    final text = Catalog.run(standardCatalog, () => printNotation(r.document, catalog: standardCatalog));
    expect(text, contains('state selected:map=null'));
    expect(text, isNot(contains('document')));
  });

  test('17: a bound border and a focused border are both the field\'s own', () {
    final r = _read('state bad=false\nstate pw=""\nColumn\n  Input#i hint="Password" @pw password border={bad ? "#FFEF5350" : "#FFF3F5F6"} focused.border=#FF00A3AD\n');
    expect(r.issues, isEmpty);
    final n = _node(r, 'i');
    expect(n['bind'], containsPair('props.decoration.border.borderSide.color', r'${= bad ? "#FFEF5350" : "#FFF3F5F6"}'));
    expect((n['bind']! as Map).keys.where((k) => '$k'.startsWith('decoration.')), isEmpty);
    expect(n['decoration'], isNull, reason: 'no stroke round the field');
    expect(jsonEncode(n['states']), contains('"borderSide":{"color":"#FF00A3AD"}'));
  });

  group('18: keys the model has', () {
    test('fontFamilyFallback on a Text and an Input', () {
      final r = _read('Column\n  Text#t "fb" fontFamily="Product Sans" fontFamilyFallback=["Roboto"]\n  Input#i "e" fontFamilyFallback=["Roboto"]\n');
      expect(r.issues, isEmpty);
      expect((_props(r, 't')['style']! as Map)['fontFamilyFallback'], ['Roboto']);
      expect(TextStyle.fromJson(_props(r, 't')['style']).fontFamilyFallback, ['Roboto']);
    });

    test('enableSuggestions on an Input', () {
      final r = _read('Column\n  Input#i "e" enableSuggestions=false\n');
      expect(r.issues, isEmpty);
      expect(_props(r, 'i')['enableSuggestions'], false);
    });

    test('onChangeStart on a Slider', () {
      final r = _read('state v=0.5\nstate held=false\nColumn\n  Slider#s @v onChangeStart={held=true}\n');
      expect(r.issues, isEmpty);
      expect([for (final x in _node(r, 's')['actions']! as List) ((x as Map)['trigger'] as Map)['type']], contains('changeStart'));
    });
  });
}
