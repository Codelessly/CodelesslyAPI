// Round 19 (30 briefs through the Playground's assistant): lines the
// writers wrote that the reader refused or read as something else, each as
// it was written.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/prompt.dart' show notationTableLine;
import 'package:test/test.dart';

NotationResult _page(String text, {NotationOptions options = const NotationOptions(width: 1440)}) => parseNotation(text, catalog: standardCatalog, options: options);

Map _node(NotationResult r, String id) => (r.document['nodes'] as Map)[id] as Map;

List _tap(NotationResult r, String id) => ((_node(r, id)['actions'] as List).first as Map)['actions'] as List;

Map<Object?, Map> _variables(NotationResult r) => {
      for (final scope in (r.document['variables'] as Map? ?? const {}).values)
        for (final v in scope as List) (v as Map)['name']: v,
    };

List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];

void main() {
  group('a state line', () {

    test('a list whose texts write their own braces \\{ and \\} is that list, the braces plain', () {
      final r = _page(r'''
state methods=[
{"name":"diff","code":"diff(a, b, \{ level: 'line' \})"}
]
Column
  each m in methods
    Text "{m.code}"
''');
      expect(_said(r), isEmpty);
      expect(_variables(r)['methods'], allOf(containsPair('type', 'list'), containsPair('value', [
        {'name': 'diff', 'code': "diff(a, b, { level: 'line' })"},
      ])));
    });
  });

  group('an action', () {

  });

  group('a range', () {
    const devices = 'state devices=[{"id":"t1","heatTo":20,"coolTo":25}]\nstate sel="t1"\n';
    test('of two fields of the record a worked-out state finds', () {
      final r = _page('${devices}state cur={find(devices,x=>x.id==sel)}\nColumn\n  Slider#s @cur.heatTo @cur.coolTo min=10 max=32\n');
      expect(_said(r), isEmpty);
      final s = _node(r, 's');
      expect(s['bind'], {'props.value': r'${= (find(devices,x=>x.id==sel)).heatTo}', 'props.rangeEnd': r'${= (find(devices,x=>x.id==sel)).coolTo}'});
      expect(((s['actions'] as List).single as Map)['actions'], [
        {'type': 'setVariable', 'variable': 'devices', 'value': r'${= updateWhere(devices,x=>x.id==sel,x=>with(x,"heatTo",result.low))}'},
        {'type': 'setVariable', 'variable': 'devices', 'value': r'${= updateWhere(devices,x=>x.id==sel,x=>with(x,"coolTo",result.high))}'},
      ]);
    });

    test('under an each over a list with nowhere to write says why, not the form that was written', () {
      final r = _page('state room="a"\nColumn\n  each d in filter(devices,x=>x.room==room)\n    Slider @d.heatTo @d.coolTo min=10 max=32\n');
      expect(_said(r), everyElement(startsWith('@d.heatTo: the each repeats')));
      expect(_said(r), isNotEmpty);
    });
  });

  group('an each', () {

    test('follow grow with a height: the height is the list\'s', () {
      final r = _page('state shown=[{"t":"a"}]\nstate following=true\nColumn h=600\n  each e in shown follow grow h=520 gap=8 onScroll={following=result.fraction>0.97}\n    Text "{e.t}"\n');
      expect(_said(r), isEmpty);
      final list = (r.document['nodes'] as Map).values.firstWhere((n) => (n as Map)['type'] == 'listView') as Map;
      expect((list['layout'] as Map)['height'], 520);
      expect((list['layout'] as Map).containsKey('flex'), isFalse);
      expect((list['props'] as Map)['stickToEnd'], isTrue);
    });

    test('reorder over the list a worked-out state finds in a record is stored in that record', () {
      final r = _page('''
state tms=[{"name":"A","members":["x","y"]}]
state ta="A"
state la={find(tms,t=>t.name==ta).members}
Column
  each n in la reorder
    Row
      Handle
      Text "{n}"
''');
      expect(_said(r), isEmpty);
      expect(jsonEncode(r.document), contains(r'"variable":"tms","value":"${= updateWhere(tms,t=>t.name==ta,t=>with(t,\"members\",'));
    });

    test('reorder over a function\'s list is refused with the line to write, which the prompt teaches up front', () {
      final r = _page('state all=[{"k":1,"a":1}]\nstate ordered(a):list={filter(all,i=>i.a==a)}\nColumn\n  each i in ordered(1) reorder\n    Text "{i.k}"\n');
      expect(_said(r).single, contains('each row in <list> reorder onReorder={<variable>=…}'));
      final prompt = notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 1440));
      expect(prompt, contains('each t in shown reorder onReorder={order=map(result,x=>x.id)}'));
      final taught = _page('state all=[{"id":1,"on":true}]\nstate order=[]\nstate shown={filter(all,x=>x.on)}\nColumn\n  each t in shown reorder onReorder={order=map(result,x=>x.id)}\n    Text "{t.id}"\n');
      expect(_said(taught), isEmpty);
    });
  });

  group('an id for a scroll', () {
    test('worked out from a definition\'s parameter is each use\'s own', () {
      final r = _page('''
define Chapter "title" n=0
  Row#top gap=40 id="ch{n}"
    Text "{title}"
define Part "title" slug="x"
  Column id={slug}
    Text "{title}"
Column
  Button#b0 "Go" onTap={scroll ch1}
  Button#b1 "Go" onTap={scroll two}
  Chapter "A" n=0
  Chapter "B" n=1
  Part "P" slug="one"
  Part "Q" slug="two"
''');
      expect(_said(r), isEmpty);
      final to0 = (_tap(r, 'b0').single as Map)['node'], to1 = (_tap(r, 'b1').single as Map)['node'];
      expect(_node(r, to0 as String)['type'], 'row');
      expect(_node(r, to1 as String)['type'], 'column');
      expect(to0, isNot('ch1'));
    });

  });

  test('a key that takes a list reads a bare name nothing declares yet as its value', () {
    final r = _page('state team=""\nColumn\n  Select#s "Team" @team items=teamNames\n');
    expect((_node(r, 's')['bind'] as Map)['props.items'], r'${teamNames}');
    expect((_node(r, 's')['props'] as Map).containsKey('items'), isFalse);
  });

  test('a paragraph of a drawing takes a Text\'s words for its style', () {
    final r = _page('Box#p w=200 h=100\n  customPaint viewBox=[200,100]\n    paragraph "Aurora" offset=[50,20] color=#FFFFFFFF size=12 weight=700\n');
    expect(_said(r), isEmpty);
    expect((((_node(r, 'p')['customPaint'] as Map)['painter'] as List).single as Map)['style'], {'color': '#FFFFFFFF', 'fontSize': 12, 'fontWeight': 700});
  });

  group('what a page\'s prompt teaches up front', () {
    test('a table of records is a Table, its line read with no issue; no table by hand is taught', () {
      final prompt = notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 1440));
      expect(prompt, contains('\n    $notationTableLine\n'));
      expect(prompt, isNot(contains("A table's row is a Row whose cells have widths")));
      expect(notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 390)), isNot(contains('Table#orders')));
      final line = notationTableLine.substring(0, notationTableLine.indexOf(': a table of records'));
      final r = _page('''
state orders=[{"id":"o1","name":"Ada Byron","status":"Paid","total":30}]
state shown={filter(orders,o=>o.total>0)}
state sortKey="name"
state chosen=[]
Page
  Section
    $line
      Row gap=8
        Avatar "{o.name}" size=28
        Text.strong "{o.name}"
      Badge "{o.status}"
''');
      expect(_said(r), isEmpty);
      expect(jsonEncode(r.document), allOf(contains('sortBy('), contains('No orders match.')));
    });

    test('a sidebar\'s parts are the design system\'s words that take rail; with none, a Row per item', () async {
      Map<String, Object?> component(String type, List<Map<String, Object?>> props) => {
            'schema': 3,
            'id': type,
            'roots': ['r'],
            'widget': {'type': type, 'doc': 'What a $type is for.', 'props': props},
            'nodes': {
              'r': {'type': 'column', 'layout': {'width': {'fill': 200}, 'height': 28}},
            },
          };
      const string = {'kind': 'string', 'flutter': 'String'};
      const boolean = {'kind': 'boolean', 'flutter': 'bool'};
      final files = {
        'design_system.json': jsonEncode({
          'id': 'acme',
          'name': 'Acme',
          'theme': {'primary': '#FF2563EB', 'onSurface': '#FF111827'},
          'components': ['components/NavItem.json', 'components/Brand.json', 'components/Pill.json'],
        }),
        for (final name in ['NavItem', 'Brand'])
          'components/$name.json': jsonEncode(component(name, [
            {'key': 'label', 'type': string, 'default': ''},
            {'key': 'rail', 'type': boolean, 'default': false},
          ])),
        'components/Pill.json': jsonEncode(component('Pill', [
          {'key': 'label', 'type': string, 'default': ''},
        ])),
      };
      final problems = <String>[];
      final ds = await DesignSystem.load((ref) async => files[ref], problems: problems);
      expect(problems, isEmpty);
      final catalog = ds.catalogOver(standardCatalog);
      final prompt = Catalog.run(catalog, () => notationPrompt(catalog: catalog, options: NotationOptions.fromDesignSystem(ds, width: 1440), designSystem: ds));
      expect(prompt, contains('Sidebar                a fixed pane at the side (w=240): its parts are the components that take rail (NavItem, Brand: on a tablet the sidebar folds to a rail of their icons, which lines written by hand cannot), Spacer grow'));
      expect(prompt, contains('A row that is chosen, anywhere but in a Sidebar: Row w=fill gap=10'));
      expect(prompt, isNot(contains("A sidebar's item: Row")));
      final plain = notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 1440));
      expect(plain, contains('(w=240): the name, a Row per item, Spacer grow'));
      expect(plain, contains("A sidebar's item: Row w=fill gap=10"));
    });
  });

  test('a state of the pointer given a condition says how its look is written, in a definition too', () {
    const say = 'has no "hover": left out. A line knows by itself when it is hovered';
    expect(_said(_page('state hov=0\nColumn\n  Card hover={hov==1} onHover={hov=1}\n    Text "a"\n')).single, contains(say));
    final r = _page('define Tile "t"\n  Card hover={hov==1} onHover={hov=1}\n    Text "{t}"\nstate hov=0\nColumn\n  Tile "a"\n', options: const NotationOptions(width: 1440, openVocabulary: true));
    expect(_said(r).single, allOf(contains(say), contains('hovered.fill=')));
  });

  // One way to write a thing: what an existing form already says is not
  // read under another spelling; the refusal names the line to write, with
  // the writer's own values in it.
  group('a form another form already says is refused with that line', () {
    test('a type by another language\'s name', () {
      final r = _page('state cells=[]\nstate cellAt(c):record={find(cells,x=>x.c==c)}\nstate ph(id):any={find(cells,p=>p.id==id)}\nstate n:int=3\nColumn\n  Text "{n}"\n');
      expect(_said(r), [
        endsWith('("record" is not one): state cellAt(c):map={find(cells,x=>x.c==c)}.'),
        endsWith('("any" is not one): state ph(id):map={find(cells,p=>p.id==id)}.'),
        endsWith('("int" is not one): state n:integer=3.'),
      ]);
    });

    test('every: its condition written as a key', () {
      for (final line in ['every 1s when={playing} onTick={prog=prog+1}', 'every 1s onTick={prog=prog+1} when={playing}']) {
        final r = _page('state playing=false\nstate prog=0\n$line\nColumn\n  Text "{prog}"\n');
        expect(_said(r).single, endsWith(': every 1s when playing onTick={prog=prog+1}'), reason: line);
        expect(_node(r, 'screen')['actions'], isNull);
      }
    });

    test('an action in parentheses', () {
      final r = _page('state done=[]\nstate score=0\nColumn\n  Button#b "Go" onTap={done=append(done,2); (length(done)==4 ? {score=score+1} : {})}\n');
      expect(_said(r).single, endsWith(': write length(done)==4 ? {score=score+1} : {}'));
      expect(_tap(r, 'b'), hasLength(1));
      // The line it names reads.
      final named = _page('state done=[]\nstate score=0\nColumn\n  Button#b "Go" onTap={done=append(done,2); length(done)==4 ? {score=score+1} : {}}\n');
      expect(_said(named), isEmpty);
      expect((_tap(named, 'b').last as Map)['type'], 'if');
    });

    test('a verb\'s text worked out beside its quotes, or with none', () {
      final r = _page('''
state curId="A-1"
state say(a,b):text={"Seat "+a+"-"+b}
Column
  Button#b "Say" onTap={announce "Removed "+curId; announce say(1,2); toast {curId}; toast Saved}
''');
      expect(_said(r), [
        'announce takes one text, a value it reads in braces inside it: announce "Removed {curId}". "+curId" is left out.',
        'A announce\'s text is in quotes, a value it reads in braces inside them: announce "{say(1,2)}".',
        'A toast\'s text is in quotes, a value it reads in braces inside them: toast "{curId}".',
      ]);
      // The lines they name read; words with no quotes are the text.
      final named = _page('state curId="A-1"\nstate say(a,b):text={"Seat "+a+"-"+b}\nColumn\n  Button#b "Say" onTap={announce "Removed {curId}"; announce "{say(1,2)}"; toast "{curId}"; toast Saved}\n');
      expect(_said(named), isEmpty);
      expect([for (final a in _tap(named, 'b')) (a as Map)['message']], [r'Removed ${curId}', r'${= say(1,2)}', r'${curId}', 'Saved']);
    });

    test('a field set on the record a worked-out state finds', () {
      final r = _page('''
state rules=[{"id":1,"conds":["a"],"n":1}]
state selR=1
state r={find(rules,x=>x.id==selR)}
Column
  Button#add "Add" onTap={r.conds=append(r.conds,"night")}
''');
      expect(_said(r).single, endsWith('Write the change to its list: rules=updateWhere(rules,x=>x.id==selR,x=>with(x,"conds",append(x.conds,"night")))'));
      final named = _page('state rules=[{"id":1,"conds":["a"]}]\nstate selR=1\nColumn\n  Button#add "Add" onTap={rules=updateWhere(rules,x=>x.id==selR,x=>with(x,"conds",append(x.conds,"night")))}\n');
      expect(_said(named), isEmpty);
      // Of any other worked-out value: the shape of the line.
      final other = _page('state rules=[{"id":1,"done":false}]\nstate top={first(filter(rules,x=>!x.done))}\nColumn\n  Button "Do" onTap={top.done=true}\n');
      expect(_said(other).single, endsWith('<list>=updateWhere(<list>,x=>x.id==<id>,x=>with(x,"done",<value>))'));
    });

    test('an each that names its index', () {
      final r = _page('state cities=[{"name":"Oslo"}]\nColumn\n  each x,i in cities\n    Text#a "{x.name}"\n');
      expect(_said(r).single, endsWith('Write each x in cities, and read i as index.'));
      expect((_node(r, 'a')['props'] as Map)['text'], r'${item.name}');
    });

    test('an id from a copy\'s place, and a scroll whose id has a value in it', () {
      final r = _page('''
state secs=[{"n":"a"},{"n":"b"}]
Column
  each s in secs
    Button#go "{s.n}" onTap={scroll sec{index}}
  each s in secs
    Column#row id={"sec"+index}
      Text "{s.n}"
''');
      expect(_said(r), [
        'A scroll to an id that is worked out is the expression in braces, not a text with a value in it: scroll {"sec" + (index)}. scroll sec{index} is left out.',
        allOf(startsWith('A copy an each inside another each repeats (or one named by its position) has no id of its own'), contains('scrollTo node=row item={x}')),
      ]);
      final named = _page('state secs=[{"n":"a"}]\nColumn\n  each s in secs\n    Button#go "{s.n}" onTap={scrollTo node=row item={index}}\n  each s in secs\n    Column#row\n      Text "{s.n}"\n');
      expect(_said(named), isEmpty);
    });

    test('a percent, written or worked out, in a definition too; none is kept as a text', () {
      final r = _page('''
state frac=0.4
Column w=400 h=200
  Box#a w=40% h=3
  Box#b h=3 w={frac*100}% fill=#FFE8702A
  Box#c w="{frac*100}%" h=3
  Box#e h=50% w=10
''');
      expect(_said(r), [
        endsWith('not a percent: widthFactor=0.4. w=40% is left out.'),
        endsWith('not a percent: widthFactor={(frac*100)/100}. w={frac*100}% is left out.'),
        endsWith('not a percent: widthFactor={(frac*100)/100}. w="{frac*100}%" is left out.'),
        endsWith('not a percent: heightFactor=0.5. h=50% is left out.'),
      ]);
      expect(jsonEncode(r.document), isNot(contains('40%')));
      final inWord = _page('define G "t"\n  Box h=3\n    Box h=3 w={frac*100}% fill=#FFE8702A\nstate frac=0.4\nColumn\n  G "a"\n');
      expect(_said(inWord).single, contains('widthFactor={(frac*100)/100}'));
      final named = _page('state frac=0.4\nColumn w=400\n  Box#a widthFactor=0.4 h=3\n  Box#b widthFactor={(frac*100)/100} h=3\n');
      expect(_said(named), isEmpty);
      expect((_node(named, 'a')['layout'] as Map)['widthFactor'], 0.4);
      expect((_node(named, 'b')['bind'] as Map)['layout.widthFactor'], r'${= (frac*100)/100}');
    });

    test('a call on a list written out, a call\'s result or a group, and one by another language\'s name', () {
      final r = _page('''
state secs=[{"on":true,"name":"A"}]
state chips={["All"].concat(map(filter(secs,x=>x.on),x=>x.name))}
Column
  each f in chips
    Text "{f}"
  Text#t "{secs.includes(1)}"
  Text#u "{secs.length} {filter(secs,x=>x.on).length} {secs.filter(x=>x.on)}"
''');
      expect(_said(r), [
        endsWith('write (concat(["All"],map(filter(secs,x=>x.on),x=>x.name)))'),
        endsWith('write contains(secs,1)'),
        endsWith('write length(secs)'),
        endsWith('write length(filter(secs,x=>x.on))'),
        endsWith('write filter(secs,x=>x.on)'),
      ]);
      // and, or, not; another name of a function.
      expect(_said(_page('state a=true\nstate b=false\nstate s=75\nColumn\n  Text "x" visible={a and not b or b}\n  Text "{formatTime(s)} {s.toFixed(1)}"\n')), [
        endsWith('write a && !b || b'),
        endsWith('write duration(s)'),
        endsWith('write fixed(s,1)'),
      ]);
      // The formulas they name read.
      final named = _page('state secs=[{"on":true,"name":"A"}]\nstate a=true\nstate s=75\nColumn\n  Text#u "{length(secs)} {length(filter(secs,x=>x.on))} {duration(s)} {fixed(s,1)}" visible={a && !a || a}\n');
      expect(_said(named), isEmpty);
      expect((_node(named, 'u')['props'] as Map)['text'], r'${= length(secs)} ${= length(filter(secs,x=>x.on))} ${= duration(s)} ${= fixed(s,1)}');
    });

    test('a flag given a width\'s name', () {
      final r = _page('state listW=300\nRow\n  Column#c w={listW} grow=phone\n    Text "a"\n');
      expect(_said(r).single, 'What a line is at a width is written with the width first: phone.grow. grow=phone is left out.');
      expect((_node(r, 'c')['layout'] as Map).containsKey('flex'), isFalse);
      expect(_said(_page('state listW=300\nRow\n  Column#c w={listW} phone.grow\n    Text "a"\n')), isEmpty);
    });

    test('a shadow that follows the state', () {
      final r = _page('state playing=false\nColumn\n  Box#b radius=30 shadow={playing ? "lg" : "none"}\n    Text "a"\n');
      expect(_said(r).single, contains('is the look of a state of the line: selected={playing} selected.shadow=lg. shadow={playing ? "lg" : "none"} is left out.'));
      final named = _page('state playing=false\nColumn\n  Box#b radius=30 selected={playing} selected.shadow=lg\n    Text "a"\n');
      expect(_said(named), isEmpty);
      expect(jsonEncode(_node(named, 'b')['states']), contains('dropShadow'));
    });

    test('a shortcut written on a node\'s line', () {
      final r = _page('state g=""\nColumn\n  Row#r gap=8 onTap={g="a"} key ArrowRight onPress={g="b"}\n    Text "x"\n');
      expect(_said(r).single, startsWith('A key pressed while a line has the focus is that line\'s event: onKeyDown(key=ArrowRight)={g="b"}.'));
      expect(_node(r, 'r')['actions'], hasLength(1));
      final named = _page('state g=""\nColumn\n  Row#r gap=8 onTap={g="a"} onKeyDown(key=ArrowRight)={g="b"}\n    Text "x"\n');
      expect(_said(named), isEmpty);
      expect(_node(named, 'r')['actions'], hasLength(2));
      // The screen's own shortcut is a line of its own, as it was.
      expect(_said(_page('state g=""\nkey ArrowRight onPress={g="b"}\nColumn\n  Text "{g}"\n')), isEmpty);
    });
  });

  group('one name for each key, word and line', () {
    test('a line\'s keys: maxw, the border words, a Text\'s size, weight and fontFamily', () {
      final r = _page('''
Column
  Column max-width=720
    Text "a"
  Box borderBottom=#FF111111 border-t=#FF111111
  Box border=#FF111111 borderWidth=2
  Box borderColor=#FF222222 border-width=3
  Text "a" fontSize=20 fontWeight=700 font="Georgia"
''');
      expect(_said(r), [
        'A Column\'s max-width is written maxw: maxw=720.',
        'A Box\'s borderBottom is written border-bottom: border-bottom=#FF111111.',
        'A Box\'s border-t is written border-top: border-top=#FF111111.',
        'A Box\'s borderWidth is written strokeWidth: strokeWidth=2.',
        'A Box\'s borderColor is written border: border=#FF222222.',
        'A Box\'s border-width is written strokeWidth: strokeWidth=3.',
        'A Text\'s fontSize is written size: size=20.',
        'A Text\'s fontWeight is written weight: weight=700.',
        'A Text\'s font is written fontFamily: fontFamily="Georgia".',
      ]);
      final named = _page('Column\n  Column#c maxw=720\n    Text "a"\n  Box#b border-bottom=#FF111111 border-top=#FF111111\n  Box#d border=#FF222222 strokeWidth=3\n  Text#t "a" size=20 weight=700 fontFamily="Georgia"\n');
      expect(_said(named), isEmpty);
      expect(((_node(named, 'c')['layout'] as Map)['constraints'] as Map)['maxWidth'], 720);
      expect(_node(named, 'd')['decoration'], {'strokes': [{'color': '#FF222222'}], 'strokeWidth': 3});
      expect(((_node(named, 't')['props'] as Map)['style'] as Map), allOf(containsPair('fontSize', 20), containsPair('fontWeight', 700), containsPair('fontFamily', 'Georgia')));
      // What prints is what reads.
      final printed = printNotation(named.document, catalog: standardCatalog);
      expect(printed, allOf(contains('maxw=720'), contains('border=#FF222222 strokeWidth=3'), contains('fontFamily=Georgia')));
      expect(_said(_page(printed)), isEmpty);
    });

    test('a Table\'s words', () {
      const state = 'state people=[{"id":1,"name":"a"}]\nstate s="name"\nstate c=[]\n';
      expect(_said(_page('${state}Column\n  Table p in people cols=["Name"] sortBy=@s selected=@c dense\n')), [
        'A Table\'s cols is written columns: columns=["Name"].',
        'A Table\'s selected is written select: select=@c.',
        'A Table\'s sortBy is written sort: sort=@s.',
        'A Table with denser rows is written compact.',
      ]);
      expect(_said(_page('${state}Column\n  Table rows={people} columns=["Name"]\n')).first, startsWith('A Table names its record and its list, as an each does: write Table row in people columns=[…]'));
      expect(_said(_page('${state}Column\n  Table p in people columns=["Name"] sort=@s select=@c compact\n')), isEmpty);
    });

    test('an every\'s unit', () {
      expect(_said(_page('state n=0\nevery 1min onTick={n=n+1}\nColumn\n  Text "{n}"\n')).single, endsWith(': write every 1m onTick={n=n+1}'));
      expect(_said(_page('state n=0\nevery 1m onTick={n=n+1}\nColumn\n  Text "{n}"\n')), isEmpty);
    });
  });
}
