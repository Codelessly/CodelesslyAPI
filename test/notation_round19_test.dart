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
    test('a type by another language\'s name is the notation\'s; any is what the value says', () {
      final r = _page('''
state cells=[{"c":1,"v":"x"}]
state photos=[{"id":1}]
state cellAt(c):record={coalesce(find(cells,x=>x.c==c),{"v":""})}
state ph(id):any={find(photos,p=>p.id==id)}
state names(a):any={map(photos,p=>p.id)}
state n:int=3
state on:bool=true
state label:string="a"
state k:any=2
Column
  Text "{cellAt(1).v} {ph(1).id} {n} {on} {label} {k} {length(names(1))}"
''');
      expect(_said(r), isEmpty);
      final v = _variables(r);
      expect(v['cellAt'], allOf(containsPair('type', 'map'), containsPair('parameters', ['c'])));
      expect(v['ph'], containsPair('type', 'map'));
      expect(v['names'], containsPair('type', 'list'));
      expect(v['n'], containsPair('type', 'integer'));
      expect(v['on'], containsPair('type', 'boolean'));
      expect(v['label'], containsPair('type', 'text'));
      expect(v['k'], containsPair('type', 'integer'));
    });

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

  test('every: its condition written as a key, in either place', () {
    for (final line in ['every 1s when={playing} onTick={prog=prog+1}', 'every 1s onTick={prog=prog+1} when={playing}']) {
      final r = _page('state playing=false\nstate prog=0\n$line\nColumn\n  Text "{prog}"\n');
      expect(_said(r), isEmpty, reason: line);
      final timer = ((_node(r, 'screen')['actions'] as List).single as Map);
      expect(timer['trigger'], {'type': 'timer', 'intervalMs': 1000, 'when': r'${= playing}'});
    }
  });

  group('an action', () {
    test('in parentheses is grouped: a choice inside a sequence', () {
      final r = _page('''
state done=[]
state sel=0
state score=0
state answered=false
Column
  Button#b "Go" onTap={sel==0 ? toast "Pick" : (sel==2 ? {done=append(done,2); sel=0; (length(done)==4 ? {score=score+1; answered=true} : {})} : {sel=0})}
''');
      expect(_said(r), isEmpty);
      final inner = (((_tap(r, 'b').single as Map)['else'] as List).single as Map)['then'] as List;
      expect(inner, hasLength(3));
      expect(inner.last, {
        'type': 'if',
        'condition': {'left': r'${= length(done)==4}', 'op': 'isTrue'},
        'then': [
          {'type': 'setVariable', 'variable': 'score', 'value': r'${= score+1}'},
          {'type': 'setVariable', 'variable': 'answered', 'value': r'${= true}'},
        ],
      });
    });

    test('a verb\'s text may be worked out: joined to a text, a call, braces, a variable', () {
      final r = _page('''
state curId="A-1"
state xs=[{"name":"a"}]
state say(a,b):text={"Seat "+a+"-"+b}
Column
  Button#b "Say" onTap={announce "Removed "+curId; announce say(1,2); toast {curId}; toast curId; toast Saved; toast curId+" saved"; copy "x"+curId}
  each x in xs
    Button#c "Say" onTap={toast x.name}
''');
      expect(_said(r), isEmpty);
      expect([for (final a in _tap(r, 'b')) (a as Map)['message'] ?? a['text']], [
        r'${= "Removed "+curId}',
        r'${= say(1,2)}',
        r'${curId}',
        r'${curId}',
        'Saved',
        r'${= curId+" saved"}',
        r'${= "x"+curId}',
        'Copied',
      ]);
      expect((_tap(r, 'c').single as Map)['message'], r'${item.name}');
      // What follows the text that is no formula is still said.
      expect(_said(_page('Column\n  Button "A" onTap={toast "Bad" style=error}\n')).single, startsWith('toast takes its text only: "style=error" is left out.'));
    });

    test('a field of the record a worked-out state finds is that record changed in its list', () {
      final r = _page('''
state rules=[{"id":1,"conds":["a"],"n":1}]
state selR=1
state r={find(rules,x=>x.id==selR)}
Column
  each c in r.conds
    IconButton#x "close" tooltip="Remove" onTap={r.conds=without(r.conds,c)}
  Button#add "Add" onTap={r.conds=append(r.conds,"night")}
  Button#inc "More" onTap={r.n+=1}
''');
      expect(_said(r), isEmpty);
      expect(_tap(r, 'x').single, {
        'type': 'setVariable',
        'variable': 'rules',
        'value': r'${= updateWhere(rules,x=>x.id==selR,rec=>with(rec,"conds",without((find(rules,x=>x.id==selR)).conds,item)))}',
      });
      expect((_tap(r, 'add').single as Map)['value'], r'${= updateWhere(rules,x=>x.id==selR,rec=>with(rec,"conds",append((find(rules,x=>x.id==selR)).conds,"night")))}');
      expect((_tap(r, 'inc').single as Map)['value'], r'${= updateWhere(rules,x=>x.id==selR,rec=>with(rec,"n",(find(rules,x=>x.id==selR)).n + (1)))}');
      expect(_variables(r).keys, isNot(contains('r')));
    });

    test('a field of a value with nowhere to be written says the line to write', () {
      final r = _page('''
state rules=[{"id":1,"done":false}]
state top={first(filter(rules,x=>!x.done))}
Column
  Button "Do" onTap={top.done=true}
''');
      expect(_said(r).single, allOf(startsWith('A field is set on a variable'), contains('<list>=updateWhere(<list>,x=>x.id==<id>,x=>with(x,"done",<value>))')));
    });
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
    test('a second name is its index, parent.index from an each inside', () {
      final r = _page('''
state cities=[{"name":"Oslo","spots":[{"n":"a"}]}]
Column
  each x,i in cities
    Text#a "{i+1}. {x.name}"
    each (s, j) in x.spots
      Text#b "{i}.{j} {s.n}"
''');
      expect(_said(r), isEmpty);
      expect((_node(r, 'a')['props'] as Map)['text'], r'${= index+1}. ${item.name}');
      expect((_node(r, 'b')['props'] as Map)['text'], r'${parent.index}.${index} ${item.n}');
    });

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

    test('from a copy\'s place, and a scroll that writes a value in its id', () {
      final r = _page('''
state secs=[{"n":"a"},{"n":"b"}]
Column
  each s in secs
    Button#go "{s.n}" onTap={scroll sec{index}}
  each s in secs
    Column#row id={"sec"+index}
      Text "{s.n}"
''');
      expect(_said(r), isEmpty);
      final at = r'indexOf(map(secs, (anchorItem, anchorIndex) => "sec"+anchorIndex), (("sec" + (index))))';
      final chosen = _tap(r, 'go').single as Map;
      expect(chosen['condition'], {'left': '\${= $at >= 0}', 'op': 'isTrue'});
      expect((chosen['then'] as List).single, {'type': 'scrollTo', 'node': 'row', 'durationMs': 400, 'offset': 72, 'index': '\${= $at}'});
    });

    test('in an each inside another is refused with a line that reads', () {
      final r = _page('state a=[{"b":[{"id":1}]}]\nColumn\n  each x in a\n    each y in x.b\n      Column id={"s"+y.id}\n        Text "a"\n');
      expect(_said(r).single, allOf(startsWith('A copy an each inside another each repeats has no id of its own'), contains('scrollTo node=row item={x}')));
      final advised = _page('state a=[{"b":[{"id":1}]}]\nColumn\n  each x in a\n    each y in x.b\n      Column#row\n        Text "a"\n      Button "Go" onTap={scrollTo node=row item={index}}\n');
      expect(_said(advised), isEmpty);
    });
  });

  test('a percent is a share of the width or the height, written or worked out', () {
    final r = _page('''
state frac=0.4
Column w=400 h=200
  Box#a w=40% h=3
  Box#b h=3 w={frac*100}% fill=#FFE8702A
  Box#c w="{frac*100}%" h=3
  Box#d w={frac*100+"%"} h=3
  Box#e h=50% w=10
''');
    expect(_said(r), isEmpty);
    expect((_node(r, 'a')['layout'] as Map)['widthFactor'], 0.4);
    for (final id in ['b', 'c', 'd']) {
      expect((_node(r, id)['bind'] as Map)['layout.widthFactor'], r'${= (frac*100)/100}', reason: id);
      expect((_node(r, id)['layout'] as Map)['width'], {'fill': 0}, reason: id);
    }
    expect((_node(r, 'e')['layout'] as Map)['heightFactor'], 0.5);
  });

  test('a call on a list written out, a call\'s result or a group is the function of that name', () {
    final r = _page('''
state secs=[{"on":true,"name":"A"}]
state chips={["All"].concat(map(filter(secs,x=>x.on),x=>x.name))}
Column
  each f in chips
    Text "{f}"
  Text#t "{filter(secs,x=>x.on).length} {["a"].includes("a")} {map(secs,x=>x.name).join(", ")} {(1+2).toFixed(1)} {secs.map(x=>x.name).length} {secs.some(x=>x.on)}"
''');
    expect(_said(r), isEmpty);
    expect(jsonEncode(r.document), contains(r'concat([\"All\"],map(filter(secs,x=>x.on),x=>x.name))'));
    expect((_node(r, 't')['props'] as Map)['text'],
        r'${= length(filter(secs,x=>x.on))} ${= contains(["a"],"a")} ${= join(map(secs,x=>x.name),", ")} ${= fixed((1+2),1)} ${= length(map(secs,x=>x.name))} ${= any(secs,x=>x.on)}');
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

  group('the round replayed', () {
    test('a percent after braces in a definition\'s line, as it is written out where it is used', () {
      final r = _page('define G "current"=home\n  Box h=3 fill=#FFDCEBF3\n    Box#bar h=3 w={frac*100}% fill=#FFE8702A\nstate frac=0.4\nColumn\n  G "a"\n');
      expect(_said(r), isEmpty);
      expect(jsonEncode(r.document), contains(r'"layout.widthFactor":"${= (frac*100)/100}"'));
    });

    test('a flag given a width\'s name is the flag at that width', () {
      final r = _page('state listW=300\nRow\n  Column#c w={listW} grow=phone\n    Text "a"\n  Column#d w=200 grow=tablet\n    Text "b"\n');
      final same = _page('state listW=300\nRow\n  Column#c w={listW} phone.grow\n    Text "a"\n  Column#d w=200 tablet.grow\n    Text "b"\n');
      expect(_said(r), isEmpty);
      for (final id in ['c', 'd']) {
        expect((_node(r, id)['layout'] as Map).containsKey('flex'), isFalse, reason: id);
        expect(_node(r, id)['media'], isNotNull, reason: id);
        expect(jsonEncode(_node(r, id)), jsonEncode(_node(same, id)), reason: id);
      }
    });

    test('a shadow that follows the state: a choice between two sizes is bound, anything else says the form', () {
      final r = _page('state playing=false\nColumn\n  Box#b radius=30 shadow={playing ? "lg" : "none"}\n    Text "a"\n');
      expect(_said(r), isEmpty);
      expect((_node(r, 'b')['bind'] as Map)['decoration.effects'], allOf(startsWith(r'${= (playing) ? [{"type":"dropShadow"'), endsWith(': []}')));
      expect(_said(_page('state playing=false\nColumn\n  Box shadow={playing}\n    Text "a"\n')).single, contains('shadow={on ? "lg" : "none"}'));
    });

    test('a shortcut written on a node\'s line is that key while the line has the focus', () {
      final r = _page('state g=""\nColumn\n  Row#r gap=8 onTap={g="a"} key ArrowRight onPress={g="b"}\n    Text "x"\n');
      expect(_said(r), isEmpty);
      expect([for (final a in _node(r, 'r')['actions'] as List) (a as Map)['trigger']], [
        {'type': 'click'},
        {'type': 'keyDown', 'key': 'ArrowRight'},
      ]);
      // The screen's own shortcut is a line of its own, as it was.
      expect(_said(_page('state g=""\nkey ArrowRight onPress={g="b"}\nColumn\n  Text "{g}"\n')), isEmpty);
    });
  });
}
