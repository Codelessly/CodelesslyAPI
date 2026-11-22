// Lines writers of apps and websites wrote that were read wrong, refused
// with nothing to write instead, or reasonable to read: each test is the
// line as it was written and what it is now read as, or what is now said
// of it in one line that can be written.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/notation_site.dart';
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
Map _bind(Map node) => (node['bind'] as Map?) ?? const {};
List _reactions(Map node) => (node['actions'] as List?) ?? const [];
Map _first(NotationResult r, String type) => _nodes(r).firstWhere((n) => n['type'] == type);

void main() {
  group('a state named as a word of a line', () {
    test('a worked-out state named top is not pasted into border-top of another file\'s line', () {
      final r = _parse('''
state tracks=[{"artist":"A","t":"x"},{"artist":"A","t":"y"}]
state artist="A"
state top={take(filter(tracks,t=>t.artist==artist),3)}
Column
  each t in top
    Text "{t.t}"
  PlayerBar
''', definitions: 'define PlayerBar\n  Column gap=6 pad=[16,10,16,10] border-top=#33F5E6C8\n    Text "now"\n');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(jsonEncode(r.document), isNot(contains('border-(')));
      expect(jsonEncode(r.document), contains('take(filter(tracks,t=>t.artist==artist),3)'));
    });

    test('left, right and bottom the same, and the state is still read where it is a value', () {
      final r = _parse('''
state rows=[1,2,3]
state left={length(rows)+1}
state bottom={length(rows)*2}
Column
  Box border-left=#FF000000 border-bottom=#FF000000 pad=4
    Text "{left} {bottom}"
''');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(_first(r, 'text')['props']['text'], r'${= (length(rows)+1)} ${= (length(rows)*2)}');
    });

    test('a flag of a line keeps its meaning beside a state of its name: Row end, Column center', () {
      final r = _parse('''
state items=[1,2,3]
state end={length(items)+1}
state center={length(items)*2}
Column center
  Row end gap=4
    Text "{end} {center}"
''');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(_node(r, 'column1')['props'], containsPair('crossAxisAlignment', 'center'));
      expect(_node(r, 'row1')['props'], containsPair('mainAxisAlignment', 'end'));
    });

    test('an each may give its item the name of a worked-out state', () {
      final r = _parse('''
state items=[{"n":1}]
state total={length(items)+1}
Column
  each total in items
    Text "{total.n}"
''');
      expect(_said(r), isEmpty);
      expect(_first(r, 'text')['props']['text'], r'${item.n}');
    });
  });

  group('a word of a line given a condition', () {
    test('Row end={m.mine}: the row is at its end while the condition holds', () {
      final r = _parse('''
state msgs=[{"mine":true,"t":"a"}]
Column
  each m in msgs
    Row w=fill gap=8 pad=[24,3,24,3] end={m.mine}
      Text "{m.t}"
''');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      final row = _first(r, 'row');
      expect(_bind(row)['props.mainAxisAlignment'], r'${= (item.mine) ? "end" : null}');
      expect((row['props'] as Map).containsKey('mainAxisAlignment'), isFalse, reason: 'without the condition the row is as written');
    });

    test('in a word of the app too (it was "end is not a parameter the notation has")', () {
      const bubble = 'define Bubble mine=false\n  Row w=fill end={mine}\n    Text "x"\n';
      final off = _parse('Column\n  Bubble\n', definitions: bubble);
      expect(_said(off), isEmpty);
      expect((_first(off, 'row')['props'] as Map).containsKey('mainAxisAlignment'), isFalse);
      final on = _parse('Column\n  Bubble mine=true\n', definitions: bubble);
      expect(_first(on, 'row')['props'], containsPair('mainAxisAlignment', 'end'));
      final worked = _parse('state rows=[{"mine":true}]\nColumn\n  each m in rows\n    Bubble mine={m.mine}\n', definitions: bubble);
      expect(_said(worked), isEmpty);
      expect(_bind(_first(worked, 'row'))['props.mainAxisAlignment'], contains('? "end" : null'));
    });

    test('Column center={n==1}, Text center={…}', () {
      final r = _parse('state n=1\nColumn center={n==1}\n  Text "x" center={n>0}\n');
      expect(_said(r), isEmpty);
      expect(_bind(_node(r, 'column1'))['props.crossAxisAlignment'], r'${= (n==1) ? "center" : null}');
      expect(_bind(_first(r, 'text'))['props.textAlign'], r'${= (n>0) ? "center" : null}');
    });

    test('a word that sets nothing a value can follow says what to write', () {
      final r = _parse('state n=1\nColumn\n  Row keep={n==1}\n    Text "x"\n');
      expect(_said(r).single, contains('write the line under `if n==1` with keep, and under `else` without it'));
    });

    test('Button variant={s.done ? "primary" : "outline"} says the two lines to write', () {
      final r = _parse('''
state sets=[{"done":true}]
Column
  each s in sets
    Button "Done" variant={s.done ? "primary" : "outline"} onTap={toast "x"}
''');
      expect(_standIns(r), isEmpty);
      expect(_said(r).single, contains('`if item.done` with Button.primary … under it, then `else` with Button.outline … under it'));
    });
  });

  group('an item passed to a word of the app', () {
    test('RestCard r=r under each r in shown is r={r}', () {
      final r = _parse('''
state shown=[{"name":"A"}]
Column
  each r in shown
    RestCard r=r
''', definitions: 'define RestCard r={}\n  Text "{r.name}"\n');
      expect(_said(r), isEmpty);
      expect(_first(r, 'text')['props']['text'], r'${= (item).name}');
    });

    test('a field of the item written bare is still said, by the name written', () {
      final r = _parse('state shown=[{"name":"A","n":1}]\nColumn\n  each r in shown\n    Progress value=r.n\n');
      expect(_said(r).single, contains('value={r.n}'));
    });

    test('ProductCard p={p}: the card reads the item\'s fields', () {
      final r = _parse('''
state products=[{"id":"a","name":"Loaf","best":true}]
state current=""
Column
  each p in filter(products,p=>p.best)
    ProductCard p={p}
''', definitions: 'define ProductCard p={}\n  Card onTap={current=p.id}\n    Text "{p.name}"\n');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect(_first(r, 'text')['props']['text'], r'${= (item).name}');
    });

    test('the row a menu is opened on is the reader\'s own variable: it is not owed by the page', () {
      const page = '''
state msgs=[{"id":1,"t":"a"}]
state pick=0
Column
  each m in msgs
    Row menu=msgMenu onTap={pick=m.id}
      Text "{m.t}"
Menu#msgMenu
  MenuItem "Copy" onTap={copy "{m.t}"}
''';
      final r = _parse(page);
      expect(_said(r), isEmpty);
      expect(notationUndeclaredNames(r.document, text: page), isEmpty);
    });
  });

  group('a string of a signature with a default', () {
    const nav = '''
define CasaNav "current"=home
  Row gap=8
    Text "Home" color={current=="home" ? "#FF000000" : "#FF888888"}
    Text "Menu" color={current=="menu" ? "#FF000000" : "#FF888888"}
''';
    String color(NotationResult r, int i) => '${((_nodes(r).where((n) => n['type'] == 'text').elementAt(i)['props'] as Map)['style'] as Map)['color']}';

    test('define CasaNav "current"=home: a use with no string has the default', () {
      final r = _parse('Column\n  CasaNav\n', definitions: nav);
      expect(_said(r), isEmpty);
      expect([color(r, 0), color(r, 1)], ['#FF000000', '#FF888888']);
    });

    test('CasaNav "menu": a use\'s string fills it', () {
      final r = _parse('Column\n  CasaNav "menu"\n', definitions: nav);
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect([color(r, 0), color(r, 1)], ['#FF888888', '#FF000000']);
    });

    test('define BeaconNav "current"="" and define ListingCard "lid"=0', () {
      final r = _parse('Column\n  BeaconNav\n  BeaconNav "x"\n  ListingCard\n  ListingCard 3\n',
          definitions: 'define BeaconNav "current"=""\n  Text "[{current}]"\n\ndefine ListingCard "lid"=0\n  Text "id {lid}"\n');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect([for (final n in _nodes(r).where((n) => n['type'] == 'text')) (n['props'] as Map)['text']], ['[]', '[x]', 'id 0', 'id 3']);
    });

    test('what is no name in a signature is said with the form of one', () {
      final r = _parse('define Tile size-large\n  Text "x"\nColumn\n  Text "y"\n');
      expect(_said(r).join('\n'), contains('its strings by name ("title") and its parameters, each with what it is when a use gives none'));
    });
  });

  group('a drawing', () {
    test('if and else under a customPaint draw their shapes while the condition holds', () {
      final r = _parse('''
state kind="pie"
Box w=240 h=140
  customPaint viewBox=[240,140] fit=contain
    oval rect=[40,104,160,22] fill=#22000000
    if kind=="toast"
      rrect rect=[50,52,140,60] radius=12 fill=#FFD9A85F
    else if kind=="pie"
      circle c=[120,80] radius=50 fill=#FF3B3B3B
    else
      rect rect=[0,0,2,2] fill=#FF000000
''');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      final painter = ((_first(r, 'column')['customPaint'] as Map)['painter'] as List).cast<Map>();
      expect([for (final op in painter) op['op']], ['oval', 'group', 'group', 'group']);
      expect(painter[1]['when'], r'${= kind=="toast"}');
      expect(painter[2]['when'], r'${= !(kind=="toast") && (kind=="pie")}');
      expect(painter[3]['when'], r'${= !((kind=="toast") || (kind=="pie"))}');
      expect(((painter[2]['ops'] as List).single as Map)['op'], 'circle');
    });

    test('in a word of the app, with a parameter in the condition (it was "if: … is not a flag")', () {
      final r = _parse('Column\n  ProductArt shape=1\n',
          definitions: 'define ProductArt color=#FF8A5A3C shape=0 h=220\n  Box h={h} radius=14\n    customPaint viewBox=[240,160] fit=cover\n      if shape==0\n        rrect rect=[50,40,190,124] radius=8 fill={color}\n      if shape==1\n        circle c=[110,86] radius=48 fill={color}\n');
      expect(_said(r), isEmpty);
      expect(jsonEncode(r.document), contains('"op":"circle"'));
    });

    test('each x in list under a customPaint draws its shapes once an item, which they read by its name', () {
      final r = _parse('''
state bars=[{"v":3},{"v":7}]
Box w=200 h=30
  customPaint viewBox=[200,30]
    each b in bars
      rect rect=[{index*10},0,6,{b.v}] fill=#FF2563EB
''');
      expect(_said(r), isEmpty);
      final repeat = ((_first(r, 'column')['customPaint'] as Map)['painter'] as List).single as Map;
      expect(repeat, containsPair('op', 'repeat'));
      expect(repeat, containsPair('each', r'${bars}'));
      expect(repeat, containsPair('as', 'b'));
      expect(((repeat['ops'] as List).single as Map)['rect'], [r'${= index*10}', 0, 6, r'${b.v}']);
    });

    test('repeat count=50 whose lines read i says that the position is index', () {
      final r = _parse('''
state clips=[{"id":1}]
Column
  each c in clips
    Box h=30 w=fill
      customPaint viewBox=[200,30] fit=fill
        repeat count=50
          line p1=[{i*4+2},{15-(3+(i*37+c.id*11)%11)}] p2=[{i*4+2},15] stroke=#99101214 strokeWidth=2
''');
      expect(r.issues.single.line, 6);
      expect(r.issues.single.message, allOf(contains('draws the same shapes every time'), contains('"i" is no name a repeat gives: write index'), contains('indexAs=i')));
    });

    test('repeat count=50 indexAs=i, and one reading index, say nothing', () {
      final r = _parse('Box w=200 h=30\n  customPaint viewBox=[200,30]\n    repeat count=50 indexAs=i\n      line p1=[{i*4},0] p2=[{i*4},30] stroke=#FF000000\n    repeat count=5\n      line p1=[{index*4},0] p2=[{index*4},30] stroke=#FF000000\n    repeat count={n>0 ? 1 : 0}\n      rect rect=[0,0,4,4] fill=#FF000000\n');
      expect(_said(r), isEmpty);
    });

    test('in an each, the item of the each is still read under a repeat (the repeat\'s own item has another name)', () {
      final r = _parse('''
state clips=[{"id":1,"n":4}]
Column
  each c in clips
    Box h=30 w=fill
      customPaint viewBox=[200,30]
        repeat count={c.n}
          rect rect=[{index*10},0,6,{c.id*3}] fill=#FF000000
''');
      expect(_said(r), isEmpty);
      final repeat = ((_nodes(r).firstWhere((n) => n['customPaint'] != null)['customPaint'] as Map)['painter'] as List).single as Map;
      expect(repeat['as'], isNot('item'));
      expect(((repeat['ops'] as List).single as Map)['rect'], [r'${= index*10}', 0, 6, r'${= item.id*3}']);
    });

    test('customPaint … w=fill h={h} says the size is its line\'s', () {
      final r = _parse('state h=80\nBox h={h}\n  customPaint viewBox=[240,160] fit=contain w=fill h={h}\n    rect rect=[0,0,240,160] fill=#FFF1E8D6\n');
      expect(_standIns(r), isEmpty);
      expect(_said(r), hasLength(2));
      expect(_said(r).first, contains('write w= on that line (Box w=240 h=160, the customPaint under it)'));
    });
  });

  group('a name for each copy an each repeats', () {
    const page = '''
state methods=[{"name":"diff","sig":"diff(a,b)"},{"name":"patch","sig":"patch(a,p)"}]
state cats=["Starters","Mains"]
Column
  each m in methods
    Button "{m.name}" onTap={scroll {m.name}}
  Button "Mains" onTap={scroll sec1}
  Button "Top" onTap={scroll top}
  Column#top
    Text "top"
  each m in methods
    Card id={m.name}
      Text "{m.sig}"
  each c in cats
    Column gap=10 id={"sec"+indexOf(cats,c)}
      Text "{c}"
''';

    test('id={m.name} and id={"sec"+…} on a repeated line are read with nothing said; a text with a value in it is said', () {
      expect(_said(_parse('state cats=["a"]\nColumn\n  each c in cats\n    Column id="sec{c}"\n      Text "{c}"\n')).single, endsWith('id={"sec" + (c)}.'));
      final r = _parse(page);
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
    });

    test('scroll {m.name} reaches the copy whose item gives that name, by its position', () {
      final r = _parse(page);
      final action = ((_reactions(_first(r, 'filledButton')).single as Map)['actions'] as List).single as Map;
      expect(action['type'], 'if');
      final scroll = (action['then'] as List).single as Map;
      expect(scroll, containsPair('type', 'scrollTo'));
      expect(scroll['index'], r'${= indexOf(map(methods, anchorItem => anchorItem.name), (item.name))}');
      final card = _nodes(r).firstWhere((n) => jsonEncode(n['children'] ?? const []).contains('text') && (n['decoration'] as Map?)?['strokes'] != null);
      expect((r.document['nodes'] as Map)[scroll['node']], same(card));
      expect(jsonEncode(action['else']), contains(r'"node":"${item.name}"'), reason: 'a name no copy has may be a line\'s own id');
    });

    test('scroll sec1 reaches the copy named sec1, and a line\'s own id is scrolled to as before', () {
      final r = _parse(page);
      final buttons = _nodes(r).where((n) => n['type'] == 'filledButton').toList();
      expect(jsonEncode(buttons[1]['actions']), contains(r'indexOf(map(cats, anchorItem => \"sec\"+indexOf(cats,anchorItem)), \"sec1\")'));
      expect(((_reactions(buttons[2]).single as Map)['actions'] as List).single, {'type': 'scrollTo', 'node': 'top', 'durationMs': 400, 'offset': 72});
    });

    test('Section tint#figures says the id is written on the word', () {
      final r = _parse('Page\n  Section tint#figures center\n    Text "x"\n');
      expect(_said(r).single, contains('Section#figures tint (or id=figures)'));
    });
  });

  group('events and looks writers reached for', () {
    test('Sheet#story … onClose={…} runs once the sheet has closed, wherever the page opens it', () {
      final r = _parse('''
state readIds=[]
state cur={"id":1,"head":"H"}
key o onPress={open story}
Column
  Button "Open" onTap={open story; toast "after"}
Sheet#story "{cur.head}" stops=[0.5,0.9] onClose={readIds=append(readIds,cur.id)}
  Text "body"
''');
      expect(_said(r), isEmpty);
      final actions = ((_reactions(_first(r, 'filledButton')).single as Map)['actions'] as List).cast<Map>();
      expect([for (final a in actions) a['type']], ['openModal', 'setVariable', 'showToast']);
      expect(actions[1]['variable'], 'readIds');
      expect(jsonEncode((r.document['nodes'] as Map)['home']), contains('"type":"openModal"'));
      expect(jsonEncode(((r.document['nodes'] as Map)['home'] as Map)['actions']), contains('"variable":"readIds"'), reason: 'a key\'s open too');
    });

    test('onPressStart and onPressEnd are the pointer going down and coming up', () {
      final r = _parse('state paused=false\nStack h=640 onPressStart={paused=true} onPressEnd={paused=false}\n  Text "x"\n');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      expect([for (final a in _reactions(_first(r, 'stack'))) ((a as Map)['trigger'] as Map)['type']], ['pointerDown', 'pointerUp']);
    });

    test('onRelease beside onPress', () {
      final r = _parse('state hold=false\nColumn\n  Button.outline "Hold to compare" onPress={hold=true} onRelease={hold=false}\n');
      expect(_standIns(r), isEmpty);
      expect([for (final a in _reactions(_first(r, 'outlinedButton'))) ((a as Map)['trigger'] as Map)['type']], ['click', 'pointerUp']);
    });

    test('Box scale={zoom} rotate=10 translateX={panX}: drawn scaled, turned and moved', () {
      final r = _parse('state zoom=1\nstate panX=0\nColumn\n  Box h=360 scale={zoom} translateX={panX} rotate=10\n    Text "p"\n');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
      final box = _node(r, 'column2');
      expect(_bind(box), {'motion.scale': r'${zoom}', 'motion.translateX': r'${panX}'});
      expect(box['motion'], {'rotate': 10});
    });

    test('x={panX} on a line of a Column says translateX', () {
      final r = _parse('state panX=0\nColumn\n  Box h=40 x={panX}\n    Text "p"\n');
      expect(_said(r).single, contains('translateX= and translateY='));
    });

    test('Box shadow=sm is a small drop shadow; another word says the sizes, another name of one the size to write', () {
      expect(_said(_parse('Column\n  Box shadow=soft\n    Text "s"\n')).single, startsWith('shadow= takes a size (sm, md, lg) or none: write shadow=sm.'));
      final r = _parse('Column\n  Box shadow=sm pad=8\n    Text "s"\n  Card shadow=lg\n    Text "c"\n  Box shadow=glow\n    Text "g"\n');
      expect(_standIns(r), isEmpty);
      expect(((_node(r, 'column2')['decoration'] as Map)['effects'] as List).single, {'type': 'dropShadow', 'color': '#14000000', 'offset': [0, 2], 'blurRadius': 8});
      expect((((_node(r, 'column3')['decoration'] as Map)['effects'] as List).single as Map)['blurRadius'], 36);
      expect(_said(r).single, contains('shadow= takes a size (sm, md, lg) or none'));
    });

    test('follow on a Column says it is an each line\'s', () {
      final r = _parse('state msgs=[{"t":"a"}]\nColumn\n  Column follow gap=4\n    each m in msgs\n      Text "{m.t}"\n');
      expect(_standIns(r), isEmpty);
      expect(_said(r).single, contains('follow is a word of an each line: each m in messages follow grow'));
    });

    test('each m in … follow grow pad=[24,16,24,16]: the room around the rows of its list', () {
      final r = _parse('state msgs=[{"t":"a"}]\nColumn h=400\n  each m in msgs follow grow pad=[24,16,24,16] gap=6\n    Text "{m.t}"\n');
      expect(_said(r), isEmpty);
      final list = _first(r, 'listView');
      expect((list['layout'] as Map)['padding'], [24, 16, 24, 16]);
      expect((list['props'] as Map)['spacing'], 6);
    });

    test('Handle icon="menu" is the grip with that glyph', () {
      final r = _parse('state trip=[{"id":1}]\nColumn\n  each s in trip reorder\n    Row\n      Handle icon="menu"\n      Text "{s.id}"\n');
      expect(_said(r), isEmpty);
      expect((_first(r, 'iconButton')['props'] as Map)['icon'], 'menu');
      expect(_first(r, 'iconButton')['reorderHandle'], true);
    });

    test('menu=none is no menu', () {
      final r = _parse('state n=0\nColumn\n  Box menu=none onLongPress={n=1}\n    Text "m"\n');
      expect(_said(r), isEmpty);
      expect(_standIns(r), isEmpty);
    });

    test('a choice named by another word for its value: tone="error" where the tones have danger', () {
      const banner = 'component Banner\n  param message="" required\n  param tone:info|success|warning|danger|neutral="info"\nRow\n  Text "{props.message} {props.tone}"\n';
      final ds = DesignSystem(
        manifest: DesignSystemManifest.fromJson({'id': 't', 'components': [DesignSystem.componentRef('Banner')]}),
        components: ComponentLibrary({'Banner': LayoutDocument.fromJson(parseNotation(banner, catalog: standardCatalog, options: const NotationOptions(screen: 'Banner')).document)}),
      );
      final catalog = ds.catalogOver(standardCatalog);
      final r = Catalog.run(
          catalog,
          () => parseNotation('Column\n  Banner message="Sold out" tone="error"\n',
              catalog: catalog, options: NotationOptions.fromDesignSystem(ds, screen: 'home').open(openVocabulary: true)));
      expect(_standIns(r), isEmpty);
      expect((_first(r, 'Banner')['props'] as Map)['tone'], 'danger');
    });
  });

  group('what an action or a text says', () {
    test('setThemeMode lower(result) and setThemeMode result ? dark : light are the mode worked out', () {
      final r = _parse('Column\n  Select options=["Light","Dark"] onChange={setThemeMode lower(result)}\n  Toggle "Dark" onChange={setThemeMode result ? dark : light}\n');
      expect(_standIns(r).where((s) => s.startsWith('verb')), isEmpty);
      expect(jsonEncode(_first(r, 'dropdown')['actions']), contains(r'"mode":"${= lower(result)}"'));
      expect(jsonEncode(_first(r, 'switch')['actions']), contains(r'"mode":"${= result ? \"dark\" : \"light\"}"'));
    });

    test('setThemeMode dark is still the word, and setThemeMode mode reads the state', () {
      final r = _parse('state mode="dark"\nColumn\n  Button "a" onTap={setThemeMode dark}\n  Button "b" onTap={setThemeMode mode}\n');
      final buttons = _nodes(r).where((n) => n['type'] == 'filledButton').toList();
      expect(jsonEncode(buttons[0]['actions']), contains('"mode":"dark"'));
      expect(jsonEncode(buttons[1]['actions']), contains(r'"mode":"${mode}"'));
    });

    test('Text "Count {0}" shows Count 0', () {
      final r = _parse('Column\n  Text "Count {0}"\n  Text "{3} of {12} done."\n');
      expect([for (final n in _nodes(r).where((n) => n['type'] == 'text')) (n['props'] as Map)['text']], ['Count 0', '3 of 12 done.']);
    });

    test('a count after a part of a pattern stays as written', () {
      final r = _parse(r'Column' '\n' r'  Text "Three digits: \\d{3}"' '\n');
      expect((_first(r, 'text')['props'] as Map)['text'], contains('{3}'));
    });

    test(r'\{name\} in a text is the braces themselves', () {
      final r = _parse('Column\n  Text "Use \\{name\\} for the name"\n');
      expect(_said(r), isEmpty);
      expect((_first(r, 'text')['props'] as Map)['text'], 'Use {name} for the name');
      expect(notationUndeclaredNames(r.document, text: ''), isEmpty);
    });
  });

  group('once, when the page opens', () {
    test('on load={…} at the margin runs when the page appears', () {
      final r = _parse('state boot=false\nstate cur=0\non load={boot=true; cur=5}\nColumn\n  Text "{cur}"\n');
      expect(_said(r), isEmpty);
      final canvas = (r.document['nodes'] as Map)['home'] as Map;
      expect(jsonEncode(canvas['actions']), allOf(contains('"type":"load"'), contains('"variable":"cur"')));
    });
  });
}
