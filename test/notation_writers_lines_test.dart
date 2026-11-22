// Lines a writer of an app of files wrote that were right and were said to
// be wrong, or that a reasonable reading makes work: each test is such a
// line and what it now expands to, or what is now said of it in one line
// that can be written.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, {String? definitions, int width = 1440}) => parseNotation(
      text,
      catalog: standardCatalog,
      definitions: definitions,
      options: NotationOptions(openVocabulary: true, width: width.toDouble(), screen: 'home'),
    );

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Iterable<Map> _nodes(NotationResult r) => (r.document['nodes'] as Map).values.cast<Map>();
List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];
List<String> _standIns(NotationResult r) => [
      for (final u in r.vocabulary)
        if (const {'type', 'overlay', 'parameter', 'flag', 'event', 'variant', 'verb'}.contains(u.kind)) '${u.kind} ${u.word}',
    ];
List<String> _roots(NotationResult r) => (r.document['roots'] as List).cast<String>();

void main() {
  group('a list over many lines', () {
    test('a state list of a record a line, longer than 60 lines, is one value and says nothing', () {
      final rows = [for (var i = 1; i <= 75; i++) '  {"id":$i,"m":"2025-09","c1":"#FF2B4C7E"},'].join('\n');
      final text = 'state photos=[\n$rows\n]\nstate after=1\nColumn\n  Text "{length(photos)} {after}"\n';
      expect(notationBracketIssues(text), isEmpty);
      final r = _parse(text);
      expect(_said(r), isEmpty);
      final variables = [for (final scope in (r.document['variables'] as Map).values) ...scope as List];
      expect((variables.firstWhere((v) => (v as Map)['name'] == 'photos') as Map)['value'], hasLength(75));
    });

    test('one never closed is still said, at its first line', () {
      final said = notationBracketIssues('state rows=[\n  {"id":1},\n  {"id":2}\nColumn\n  Text "a"\n');
      expect(said.single.line, 1);
      expect(said.single.message, contains('is never closed'));
    });
  });

  group('an app\'s sidebar and a button for a narrow window', () {
    const nav = 'define LedgerNav page="home"\n  Sidebar\n    NavItem "Home" icon="home" onTap={go home}\n';

    test('a button shown on a phone that opens a sheet is no menu button: the sidebar keeps its drawer', () {
      final r = _parse('''
App
  LedgerNav page="home"
  Main
    Column pad=24
      Row
        Button "Add transaction" hide=phone onTap={open addTxn}
        Button "Add" show=phone onTap={open addSheet}
Dialog#addTxn "Add transaction"
  Text "x"
Sheet#addSheet "Add transaction"
  Text "y"
''', definitions: nav);
      expect(_said(r), isEmpty);
      expect(_standIns(r).where((s) => s.startsWith('overlay')), isEmpty, reason: 'nothing opens an overlay nobody wrote');
      expect(_roots(r), containsAll(['home_sidebar', 'addTxn', 'addSheet']));
    });

    test('the writer\'s own menu button leaves the made one undrawn, and nothing is left opening a drawer never made', () {
      final r = _parse('''
App
  LedgerNav page="home"
  Main
    Column pad=24
      IconButton "menu" show=phone onTap={open houseNav}
      Text "Hi"
Sheet#houseNav "Navigation"
  Text "y"
''', definitions: nav);
      expect(_said(r), isEmpty);
      expect(_standIns(r).where((s) => s.startsWith('overlay')), isEmpty);
      expect(_roots(r), isNot(contains('home_sidebar')));
      expect(jsonEncode(r.document), isNot(contains('"to":"home_sidebar"')));
    });
  });

  group('overlays a word of the writer\'s own writes', () {
    test('a word that is a dialog and a sheet: both are over the page, opened by the ids written', () {
      const word = '''
define AddTxn
  Dialog#addTxn "Add transaction" "Record money in or out"
    Text "Form"
    Row
      Button.outline "Cancel" onTap={close}
  Sheet#addSheet "Add transaction" stops=[0.5,0.92] stop=@aSnap
    Text "Form"
    Button "Save" onTap={close}
''';
      final r = _parse('''
state aSnap=0
Column#page
  Button#wide "Add transaction" onTap={open addTxn}
  Button#narrow "Add" onTap={open addSheet}
  AddTxn
''', definitions: word);
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(_roots(r), ['home', 'addTxn_addTxn1', 'addSheet_addTxn1']);
      expect(jsonEncode(_node(r, 'wide')['actions']), contains('"to":"addTxn_addTxn1"'), reason: 'the page opens each by the id it is written with');
      expect(jsonEncode(_node(r, 'narrow')['actions']), allOf(contains('"to":"addSheet_addTxn1"'), contains('snapHeights')));
    });

    test('a shell: the page\'s frame with a slot, its keys, and its dialogs at the definition\'s margin', () {
      const shell = '''
define Shell "title"
  key n onPress={open event}
  Column#frame
    Text.heading3 "{title}"
    ...
  Dialog#event "{editing ? "Edit event" : "New event"}" guard={draft!=""} guardText="Discard what you typed?" onDiscard={draft=""}
    Input "Title" @draft
''';
      final r = _parse('''
state draft=""
state editing=false
Shell "Week"
  Button#new "New event" onTap={open event}
''', definitions: shell);
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      final dialog = _roots(r).singleWhere((id) => id != 'home');
      expect(dialog, startsWith('event_'));
      expect(jsonEncode(_node(r, 'new')['actions']), contains('"to":"$dialog"'), reason: 'the page opens it by the id it is written with');
      expect(jsonEncode(r.document), contains('Discard what you typed?'));
    });

    test('a word whose body is a key and an overlay: its own open names the overlay the page opens', () {
      const search = 'define QuillSearch\n  key mod+k onPress={open search}\n  Dialog#search "Search the docs"\n    Text "Results"\n';
      final r = _parse('Column#page\n  IconButton#find "search" onTap={open search}\nQuillSearch\n', definitions: search);
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(_roots(r), ['home', 'search']);
      expect(jsonEncode(r.document), isNot(contains('quillSearch1')));
    });

    test('a title whose formula holds a text of its own is one title, the note after it the note', () {
      final r = _parse('state cur="2026-05-04"\nColumn\n  Button "Day" onTap={open day}\nDialog#day "{formatDate(cur,"EEEE, MMMM d")}" "Events on this day"\n  Text "x"\n');
      expect(_said(r), isEmpty);
      final all = jsonEncode(r.document);
      expect(all, contains(r'formatDate(cur,\"EEEE, MMMM d\")'));
      expect(all, contains('Events on this day'));
      expect(all, isNot(contains(r'EEEE, \"Events')));
    });
  });

  group('a word of the writer\'s own that calls a word not written yet', () {
    test('stands in where it is used, as on a page: no issue, and it is recorded as a type owed', () {
      const shell = 'define Shell "title"\n  Column\n    Text "{title}"\n    CalRow c={title}\n    ...\n';
      final r = _parse('Shell "Week"\n  MonthView\n', definitions: shell);
      expect(_said(r), isEmpty);
      expect(_standIns(r), unorderedEquals(['type CalRow', 'type MonthView']));
    });
  });

  group('open and close name an overlay', () {
    test('whatever state or item has the name: the id is not written out as the state\'s formula', () {
      final r = _parse('''
state items=[{"id":1,"t":"a"}]
state cur=0
state story={items[cur]}
Column
  Text "{story.t}"
  Button#read "Read" onTap={cur=0; open story}
  each reader in items
    Button "x" onTap={open reader}
Dialog#story "Story"
  Text "{story.t}"
  Button "Done" onTap={close story}
Dialog#reader "Reader"
  Text "r"
''');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(jsonEncode(_node(r, 'read')['actions']), contains('"to":"story"'));
    });
  });

  group('a motion on one side of a condition', () {
    test('animate={reduced ? "" : "slide-up"} with times worked out: the motion, off while reduced, its times bound', () {
      final r = _parse('state reduced=false\nColumn\n  Text#t "{1}" animate={reduced ? "" : "slide-up"} duration={reduced ? 0 : 500} delay={reduced ? 0 : 150}\n  Text#u "b" animate={reduced ? "" : "slide-up"} duration=400\n');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      final bind = _node(r, 't')['bind'] as Map;
      expect(bind['animations[0].enabled'], r'${= !(reduced)}');
      expect(bind['animations[0].duration'], r'${= reduced ? 0 : 500}');
      expect(bind['animations[0].delay'], r'${= reduced ? 0 : 150}');
      expect(((_node(r, 'u')['animations'] as List).single as Map)['duration'], 400);
    });

    test('an animate= that is refused is said once: its duration is not said to want an animate=', () {
      final r = _parse('state on=false\nColumn\n  Text "a" animate={on ? "fade" : "pulse"} duration=400\n');
      expect(_said(r).single, startsWith('animate= takes one name'));
    });
  });

  group('a gradient worked out', () {
    test('from a list of the state, from one of two lists, and from a list written without braces', () {
      final r = _parse('''
state ps=[{"c1":"#FF112233","c2":"#FF445566","grad":["#FF112233","#FF445566"]}]
state view=0
Column
  each p in ps
    Box#a h=96 gradient={p.grad}
    Box#b h=96 gradient=[p.c1,p.c2]
    Box#c h=96 gradient={view==0 ? [p.c1,p.c2] : [p.c2,p.c1]}
''');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      String fills(String id) => (_node(r, id)['bind'] as Map)['decoration.fills'] as String;
      expect(fills('a'), allOf(contains('"linear"'), contains('map(range(length(item.grad))'), contains('(item.grad)[gradientStop]')));
      expect(fills('b'), allOf(contains('(item.c1)'), contains('(item.c2)'), contains('"position": 1.0')));
      expect(fills('c'), contains('(view==0 ? [item.c1,item.c2] : [item.c2,item.c1])[gradientStop]'));
    });
  });

  group('a table of records written on its line', () {
    test('DataTable rows=[{…}] columns=[…]: the records are its rows', () {
      final r = _parse('Column\n  DataTable#t rows=[{"name":"mode","type":"\'char\' | \'word\'","def":"\'word\'"},{"name":"timeout","type":"number","def":"1000"}] columns=[{"key":"name","label":"Option"},{"key":"type","label":"Type"}]\n');
      expect(_said(r), isEmpty);
      expect((_node(r, 't')['bind'] as Map)['data'], allOf(startsWith(r'${= ['), contains('"name": "mode"'), contains('"timeout"')));
    });

    test('rows=orders, the bare name of a list of the state, is that list; rows that are no records are said once', () {
      final r = _parse('state orders=[]\nColumn\n  DataTable#t rows=orders columns=[{"key":"name","label":"Name"}]\n');
      expect(_said(r), isEmpty);
      expect((_node(r, 't')['bind'] as Map)['data'], r'${orders}');
      final odd = _parse('Column\n  DataTable rows="orders" columns=[{"key":"name","label":"Name"}]\n');
      expect(_said(odd), ['The rows of a table are its records: a list of the state in braces (rows={orders}), or the records written out (rows=[{"name":"Ada","total":12}]).']);
    });
  });

  group('a list that is reordered', () {
    test('each … reorder onReorder={…} on the each\'s line stores the move as the writer says', () {
      final r = _parse('''
state plans=[{"id":1,"ex":[{"id":1,"n":"a"},{"id":2,"n":"b"}]}]
state sel=1
Column
  Column#list gap=4
    each x in find(plans,p=>p.id==sel).ex reorder onReorder={plans=updateWhere(plans,q=>q.id==sel,q=>with(q,"ex",result.list))}
      Row
        Handle
        Text "{x.n}"
''');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      final list = _nodes(r).singleWhere((n) => n['type'] == 'listView');
      expect(((list['props'] as Map)['reorder'] as Map)['apply'], 'none');
      expect(jsonEncode(list['actions']), allOf(contains('"type":"reorder"'), contains('move(find(plans,p=>p.id==sel).ex, result.from, result.to)')));
    });

    test('over a field of the record a find picks, or of the item of the each around it: written back into that record', () {
      final r = _parse('''
state autos=[{"id":1,"name":"A","conds":[{"id":1,"t":"x"}]}]
state at=1
state cur={find(autos,a=>a.id==at)}
Column
  each a in autos
    Column
      each c in a.conds reorder
        Text "{c.t}"
  Column
    each t in find(autos,a=>a.id==at).conds reorder
      Text "{t.t}"
  Column
    each u in cur.conds reorder
      Text "{u.t}"
''');
      expect(_said(r), isEmpty);
      final stores = [
        for (final n in _nodes(r))
          if (n['type'] == 'listView' && (n['props'] as Map)['reorder'] != null) jsonEncode(n['actions']),
      ];
      expect(stores, hasLength(3));
      expect(stores[0], contains(r'updateWhere(autos,reorderRow=>reorderRow.id==item.id,reorderRow=>with(reorderRow,\"conds\",(move(item.conds, result.from, result.to))))'));
      expect(stores[1], contains(r'updateWhere(autos,a=>a.id==at,a=>with(a,\"conds\",'));
      expect(stores[2], contains(r'updateWhere(autos,a=>a.id==at,a=>with(a,\"conds\",'));
    });

    test('over any other formula: what is said can be written, and is read when it is', () {
      final r = _parse('state rows=[{"id":1,"on":true}]\nColumn\n  each row in filter(rows,r=>r.on) reorder\n    Text "{row.id}"\n');
      expect(_said(r).single, startsWith('reorder writes the new order to a list variable, and this each repeats a list that is worked out: reorder is left out. Say on the same line how a move is stored: each row in <list> reorder onReorder={<variable>=…}'));
      // (What is under the each is still read: nothing more is said of it.)
      expect(_nodes(r).where((n) => n['type'] == 'listView'), hasLength(1));
      expect(_said(r).single, isNot(contains('state filter(')));
      final written = _parse('state rows=[{"id":1,"on":true}]\nColumn\n  each row in filter(rows,r=>r.on) reorder onReorder={rows=result}\n    Text "{row.id}"\n');
      expect(_said(written), isEmpty);
    });

    test('in a Grid or across a Row: said with the line to write', () {
      final r = _parse('state rows=[1,2]\nGrid cols=2\n  each row in rows reorder\n    Text "{row}"\n');
      expect(_said(r).single, endsWith('write the each under a Column (Column gap=8, and under it each row in rows reorder).'));
    });
  });

  group('values given to a word of the writer\'s own, in the order its signature has them', () {
    const words = '''
define StoryCard "section" "title" mins=5 tall=false
  Text#story "{section} {title} {mins} min"
define WeekSlot "d" "m"
  Text "{d} {m}"
define Pic "c1" "c2" seed=0
  Text "{c1}{c2}{seed}"
define MiseNav tab="recipes"
  Text#nav "{tab}"
''';

    test('a number after the texts is the next parameter: StoryCard "Tides" "…" 14 tall=true', () {
      final r = _parse('Column\n  StoryCard "Tides" "The last" 14 tall=true\n', definitions: words);
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(_nodes(r).where((n) => n['type'] == 'text').map((n) => (n['props'] as Map)['text']), ['Tides The last 14 min']);
    });

    test('a value of the page where a text goes is that text, and after the texts the next parameter', () {
      final r = _parse('''
state days=["Mon","Tue"]
state rs=[{"id":3,"name":"A"}]
state dayi=0
Column
  each d in days
    each m in ["B","L"]
      WeekSlot d m
  WeekSlot days[dayi] "x"
  each p in rs
    Pic "{p.name}" "b" p.id
    WeekSlot p.name p.id
''', definitions: words);
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      final texts = [for (final n in _nodes(r)) if (n['type'] == 'text') ((n['bind'] as Map?)?['props.text'] ?? (n['props'] as Map)['text'])];
      expect(texts, containsAll([r'${parent.item} ${item}', r'${= days[dayi]} x', r'${item.name}b${item.id}', r'${item.name} ${item.id}']));
    });

    test('a text past the signature\'s own is its next parameter\'s value; a value past them all is still said', () {
      final r = _parse('Column\n  MiseNav "week"\n  StoryCard "a" "b" 3 4\n', definitions: words);
      expect(_nodes(r).where((n) => n['type'] == 'text').map((n) => (n['props'] as Map)['text']), contains('week'));
      expect(_standIns(r), ['flag 4']);
    });
  });

  group('a function of the state', () {
    test('with no type is read: its type is what its formula starts as', () {
      final r = _parse('''
state mk(rid,d,m)={with(with(with({},"rid",rid),"day",d),"meal",m)}
state free(r,s)={!contains(r.taken,s)}
state rowsOf(z)={filter(seats,x=>x.zone==z)}
state seats=[]
Column
  Text "{mk(1,2,3).day} {free({"taken":[]},1)} {length(rowsOf(1))}"
''');
      expect(_said(r), isEmpty);
      final variables = {for (final scope in (r.document['variables'] as Map).values) for (final v in scope as List) (v as Map)['name']: v};
      expect(variables['mk'], containsPair('type', 'map'));
      expect(variables['mk'], containsPair('parameters', ['rid', 'd', 'm']));
      expect(variables['free'], containsPair('type', 'boolean'));
      expect(variables['rowsOf'], containsPair('type', 'list'));
    });

    test('a type the notation has not says the line to write: the type it names, the function\'s parameters kept', () {
      final r = _parse('state makeSeat(r,i):record={with({},"id",i)}\nstate best(r):number={r.n*2}\nstate pick(r,i):seat={with({},"id",i)}\nstate n:int=3\nColumn\n  Text "{n}"\n');
      expect(_said(r), [
        endsWith('("record" is not one): state makeSeat(r,i):map={with({},"id",i)}.'),
        endsWith('("number" is not one): state best(r):decimal={r.n*2}.'),
        endsWith('("seat" is not one): state pick(r,i):map={with({},"id",i)}.'),
        endsWith('("int" is not one): state n:integer=3.'),
      ]);
    });
  });

  group('a value written without braces that can only be read from the state', () {
    test('the name of a list of the state, and a call of a formula function', () {
      final r = _parse('''
state rooms=["A","B"]
state room="A"
state shows=[{"id":"x"}]
state pid="x"
Column
  Select#a @room items=rooms
  Select#b @pid items=map(shows,x=>x.id) hide=phone
''');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(jsonEncode(_node(r, 'a')['bind']), contains('rooms'));
      expect(jsonEncode(_node(r, 'b')['bind']), contains('map(shows,x=>x.id)'));
    });

    test('the name of a text or a number of the state is still said, with the line to write', () {
      final r = _parse('state n=2\nColumn\n  Text "a" maxLines=n\n');
      expect(_said(r).single, 'A value read from the state is written in braces: maxLines={n}.');
    });
  });

  group('a control bound to a field', () {
    test('a range slider under an each, an end a field of the item: one change writes both', () {
      final r = _parse('state ds=[{"id":1,"heat":18,"cool":24}]\nColumn\n  each d in ds\n    Slider#s @d.heat @d.cool min=16 max=30\n');
      expect(_said(r), isEmpty);
      final node = _nodes(r).firstWhere((n) => n['type'] == 'slider');
      expect((node['bind'] as Map)['props.rangeEnd'], r'${item.cool}');
      final writes = jsonEncode(node['actions']);
      expect(writes, allOf(contains('result.low'), contains('result.high'), contains('"variable":"ds"')));
    });

    test('a field of the record at a place of a list, also through a state worked out: @p.name for state p={plans[at]}', () {
      final r = _parse('state plans=[{"id":1,"name":"P"}]\nstate at=0\nstate p={plans[at]}\nColumn\n  Input#i "Routine name" @p.name\n');
      expect(_said(r), isEmpty);
      expect(jsonEncode(_node(r, 'i')['actions']), contains(r'setAt(plans,at,with(plans[at],\"name\",result))'));
    });
  });

  group('a Section out of a page\'s frame', () {
    test('narrow is still its width, and says nothing as a word the Column does not have', () {
      final r = _parse('Row\n  Section#s narrow\n    Text "a"\n');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(jsonEncode(_node(r, 's')['layout']), contains('720'));
    });
  });
group('a scroll written in an app\'s sidebar', () {
    test('goes to the line with that id= in the drawer made of the sidebar too: nothing is said of it', () {
      final r = _parse('App\n  Sidebar\n    NavItem "First" onTap={scroll first}\n  Main\n    Column\n      Text.heading2#h "Your first diff" id=first\n      Text "x"\n');
      expect(_said(r), isEmpty);
      expect(_roots(r), contains('home_sidebar'));
      final scrolls = RegExp(r'"type":"scrollTo","node":"([^"]+)"').allMatches(jsonEncode(r.document)).map((m) => m[1]).toSet();
      expect(scrolls, hasLength(1), reason: 'the page\'s item and the drawer\'s copy go to the same node');
      expect(scrolls.single, isNot('first'));
    });

    test('an id no line has is still said', () {
      final r = _parse('App\n  Sidebar\n    NavItem "First" onTap={scroll nowhere}\n  Main\n    Text "x"\n');
      expect(_said(r).single, startsWith('No line of this page has the id "nowhere" for a scroll to go to'));
    });
  });
}
