// Lines that follow the notation as released in 39.0.0 and drew wrongly, or
// were wrong and said nothing: each test is such a line and what it now
// expands to or says.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

NotationResult _parse(String text, {NotationOptions options = const NotationOptions()}) =>
    parseNotation(text, catalog: standardCatalog, options: withTestWords(options));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();
List<String> _children(NotationResult r, String id) => ((_node(r, id)['children'] as List?) ?? const []).cast<String>();
List<String> _roots(NotationResult r) => (r.document['roots'] as List).cast<String>();
Iterable<Map> _nodes(NotationResult r) => (r.document['nodes'] as Map).values.cast<Map>();
List<Map> _variables(NotationResult r) => [
      for (final scope in (r.document['variables'] as Map? ?? const {}).values)
        for (final v in scope as List) v as Map,
    ];

/// The first action of [id]'s first reaction.
Map _action(NotationResult r, String id) => (((_node(r, id)['actions'] as List).first as Map)['actions'] as List).first as Map;

void main() {
  namesTests();
  themeReadTests();
  saidTests();
  wordsTests();
  itemsTests();
  valueTextTests();
  drawingTests();
  gridWidthTests();
  wordOverParameterTests();
  componentParamTests();
  stateValueTests();
  overlayGoTests();
  group('a defined word whose body is an overlay', () {
    const drawer = '''
define SideMenu current="today"
  Drawer#menu "Navigation" w=290
    Text "{current}"
''';

    test('in the page\'s tree: the overlay, opened by the id its body gives, not drawn in the page', () {
      final r = _parse('''
${drawer}Column#page
  Button#opener "Menu" onTap={open menu}
  SideMenu current=home
  Text#after "After"
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'menu']);
      expect(_children(r, 'page'), ['opener', 'after']);
      expect(_action(r, 'opener'), containsPair('to', 'menu'));
      expect(_action(r, 'opener'), containsPair('cover', true));
      expect(_nodes(r).where((n) => (n['props'] as Map?)?['text'] == 'home'), hasLength(1));
    });

    test('after the page, at the margin, with no id on its use', () {
      final r = _parse('''
${drawer}Column#page
  Button#opener "Menu" onTap={open menu}
SideMenu
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'menu']);
      expect(_children(r, 'page'), ['opener']);
    });

    test('an id on the use is the overlay\'s, over the body\'s', () {
      final r = _parse('''
${drawer}Column#page
  Button#opener "Menu" onTap={open side}
SideMenu#side
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'side']);
    });

    test('a dictionary\'s ConfirmDialog with an id, in the page\'s tree', () {
      final r = _parse('''
state n=0
Column#page
  Button#opener "Reset" onTap={open ask}
  ConfirmDialog#ask "Reset?" "Really." onConfirm={n=0}
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'ask']);
      expect(_children(r, 'page'), ['opener']);
    });

    test('with no id inside an overlay: that overlay\'s content, its title, its note and its buttons', () {
      final r = _parse('''
state n=0
Column#page
  Button#opener "Delete" onTap={open sure}
Dialog#sure "Delete event?"
  ConfirmDialog "Delete this event?" "It will be removed." confirm="Delete event" onConfirm={n=1}
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'sure']);
      final texts = [for (final n in _nodes(r)) (n['props'] as Map?)?['text'] ?? (n['props'] as Map?)?['label']];
      expect(texts, containsAll(['Delete event?', 'Delete this event?', 'It will be removed.', 'Cancel', 'Delete event']));
      // One close button: the dialog's own.
      expect(_nodes(r).where((n) => n['type'] == 'iconButton'), hasLength(1));
    });
  });
}

// ---- names ----
void namesTests() {
  group('a bare word where a name is read', () {
    test('icon=mail on a defined word is the icon mail, whatever state is called mail', () {
      final r = _parse('''
state mail=[{"id":"a"}]
Column
  Brand#brand "Postbox" icon=mail
''');
      expect(r.issues, isEmpty);
      final icon = _nodes(r).singleWhere((n) => n['type'] == 'icon');
      expect((icon['props'] as Map)['icon'], 'mail');
      expect(icon['bind'], isNull);
    });

    test('a text variable of the name could be meant: the name, and the braces said', () {
      final r = _parse('''
state mail="inbox"
Column
  Brand "Postbox" icon=mail
''');
      expect(r.issues.single.message, contains('icon={mail}'));
      expect((_nodes(r).singleWhere((n) => n['type'] == 'icon')['props'] as Map)['icon'], 'mail');
    });

    test('in braces it is the variable; an each\'s item of the name is the item', () {
      final r = _parse('''
state mail="inbox"
state icons=["home","star"]
Column
  Brand#a "Postbox" icon={mail}
  each icon in icons
    Brand "Row" icon=icon
''');
      expect(r.issues, isEmpty);
      final binds = [for (final n in _nodes(r)) if (n['type'] == 'icon') (n['bind'] as Map?)?['props.icon']];
      expect(binds, [r'${mail}', r'${item}']);
    });

    test('a parameter that is no name still reads a variable of the word given (bpm=bpm)', () {
      final r = _parse('''
state bpm=120
define Tempo bpm=90
  Text "{bpm} bpm"
Column
  Tempo#t bpm=bpm
''');
      expect(r.issues, isEmpty);
      expect('${_node(r, 't')}', contains(r'${bpm}'));
    });

    test('go album under each album in …, with a page called album, goes to the page', () {
      final r = _parse('''
state albums=[{"id":"x","title":"One"}]
state openAlbum=""
Column
  each album in albums
    Button#b "{album.title}" onTap={openAlbum=album.id; go album}
''', options: const NotationOptions().withScreens(const ['album', 'library']));
      expect(r.issues, isEmpty);
      final actions = ((_node(r, 'b')['actions'] as List).first as Map)['actions'] as List;
      expect(actions.last, {'type': 'navigate', 'to': 'album'});
      expect((actions.first as Map)['value'], contains('item.id'));
    });

    test('with no page of the name: a bare word is a page\'s id, the item is read in braces', () {
      const page = '''
state tabs=["home","library"]
Column
  each tab in tabs
    Button#b "{tab}" onTap={go tab}
''';
      final said = _parse(page, options: const NotationOptions().withScreens(const ['home', 'library']));
      expect(said.issues.single.message, startsWith('A page that is worked out is written in braces: go {item}.'));
      final r = _parse(page.replaceFirst('go tab', 'go {tab}'), options: const NotationOptions().withScreens(const ['home', 'library']));
      expect(r.issues, isEmpty);
      expect(_action(r, 'b')['to'], r'${= item}');
    });

    test('a page and a variable of one name after go: the page (section="news"; go section)', () {
      final r = _parse('''
state section="profile"
Column
  Button#b "Open" onTap={section="news"; go section}
''', options: const NotationOptions().withScreens(const ['section', 'profile']));
      expect(r.issues, isEmpty);
      final actions = ((_node(r, 'b')['actions'] as List).first as Map)['actions'] as List;
      expect(actions.last, {'type': 'navigate', 'to': 'section'});
    });
  });
}

void overlayGoTests() {
  test('go in an overlay names a page as it does in the page, whatever state has the name', () {
    final r = _parse('''
state playlists=[]
Column
  Button "Add" onTap={open add}
Dialog#add "Add to playlist"
  Button#b "Go to playlists" onTap={close; go playlists}
''', options: const NotationOptions().withScreens(const ['library', 'playlists']));
    expect(r.issues, isEmpty);
    final actions = ((_node(r, 'b')['actions'] as List).first as Map)['actions'] as List;
    expect(actions.last, {'type': 'navigate', 'to': 'playlists'});
  });
}

void stateValueTests() {
  group('a state whose value reads an element by a key', () {
    String text(NotationResult r) => '${_props(r, 't')['text']}';

    test('computed piece=stories[story] is the formula, not its text', () {
      final r = _parse('''
state story="a"
state stories={"a":{"title":"One"}}
computed piece=stories[story]
Column
  Text#t "{piece.title}"
''');
      expect(r.issues, isEmpty);
      expect(_variables(r).map((v) => v['name']), ['story', 'stories']);
      expect(text(r), r'${= (stories[story]).title}');
    });

    test('state too, in braces or not, by a number or a name, with a field after', () {
      final r = _parse('''
state at=1
state rows=[{"name":"a"},{"name":"b"}]
state first={rows[0]}
state second=rows[1].name
state current=rows[at].name
Column
  Text#t "{first.name} {second} {current}"
''');
      expect(r.issues, isEmpty);
      expect(_variables(r).map((v) => v['name']), ['at', 'rows']);
      expect(text(r), r'${= (rows[0]).name} ${= (rows[1].name)} ${= (rows[at].name)}');
    });

    test('a quoted text with brackets, and a list, stay values', () {
      final r = _parse('''
state label="rows[0]"
state rows=[1,2]
Column
  Text#t "{label}"
''');
      expect(r.issues, isEmpty);
      expect(_variables(r).firstWhere((v) => v['name'] == 'label')['value'], 'rows[0]');
      expect(_variables(r).firstWhere((v) => v['name'] == 'rows')['value'], [1, 2]);
    });
  });
}

void componentParamTests() {
  group('a component\'s parameter read by its bare name', () {
    test('in braces it is the component\'s (props.name): a size, a text, a paint line, a condition', () {
      final r = _parse('''
component CoverArt "Art"
  param edge:double=180
  param fluid:bool=false
  param record:Map={}
Column#root w={fluid ? 'fill' : edge} h={fluid ? 'hug' : edge} aspectRatio=1
  Text#t "{record.title} at {edge}"
  if fluid
    Text#f "wide"
  Box#b w=40 h=40
    customPaint viewBox=[10,10]
      rect rect=[0,0,10,10] fill={record.color}
''');
      expect(r.issues, isEmpty);
      expect(_node(r, 'root')['bind'], {
        'layout.width': r"${= props.fluid ? 'fill' : props.edge}",
        'layout.height': r"${= props.fluid ? 'hug' : props.edge}",
      });
      expect(_props(r, 't')['text'], r'${props.record.title} at ${props.edge}');
      expect('${_node(r, 'f')}', contains('props.fluid'));
      expect('${_node(r, 'b')}', contains('props.record.color'));
    });

    test('a word outside braces, a state of the name and an each\'s item are not the parameter', () {
      final r = _parse('''
component Tile "A tile"
  param fill:String="red"
  param count:int=1
  param row:Map={}
state count=3
state rows=[{"n":1}]
Column#root w=fill
  Text#a "{count}"
  each row in rows
    Text#b "{row.n} {fill}"
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'root')['layout'] as Map)['width'], {'fill': 0});
      expect(_props(r, 'a')['text'], r'${count}');
      expect(_props(r, 'b')['text'], r'${item.n} ${props.fill}');
    });

    test('props.name as written stays', () {
      final r = _parse('''
component Tile "A tile"
  param label:String="x"
Text#a "{props.label} {label}"
''');
      expect(_props(r, 'a')['text'], r'${props.label} ${props.label}');
    });
  });

  test('a bound size that names its fit as a word is that fit', () {
    final node = Node.fromJson(const {
      'type': 'column',
      'layout': {'width': 0, 'height': 0},
    }, id: 'n')!;
    expect(BindPaths.apply(node, 'layout.width', 'fill').layout.width.fit, SizeFit.fill);
    expect(BindPaths.apply(node, 'layout.height', 'hug').layout.height.fit, SizeFit.hug);
    expect(BindPaths.apply(node, 'layout.width', 64).layout.width, const AxisSize.fixed(64));
  });
}

void wordOverParameterTests() {
  test('a Table over a list given as a defined word\'s parameter reads the use\'s list', () {
    final r = _parse('''
state methods=[{"parameters":[{"name":"before","type":"string"}]}]
define MethodCard "name" parameters=[]
  Column w=fill ...
    Text "{name}"
    Table p in parameters columns=[{"key":"name","label":"Parameter","w":123},{"key":"type","label":"Type"}] compact
Column
  MethodCard "diff" parameters={methods[0].parameters}
  MethodCard "lit" parameters=[{"name":"x","type":"int"}]
''');
    expect(r.issues, isEmpty);
    final lists = [for (final n in _nodes(r)) if (n['type'] == 'listView') (n['bind'] as Map)['data']];
    expect(lists, hasLength(2));
    expect(lists.first, contains('methods[0].parameters'));
    expect(lists.last, contains('"name":"x"'));
    expect(lists.join(), isNot(contains(r'${parameters}')));
  });
}

void gridWidthTests() {
  test('phone.gap and phone.mainAxisExtent on a Grid are its each\'s cells at that width', () {
    final r = _parse('''
state trash=[{"title":"a"},{"title":"b"}]
Column w=fill
  Grid#g cols=4 phone.cols=2 gap=12 phone.gap=4 mainAxisExtent=260 phone.mainAxisExtent=226
    each picture in trash
      Text "{picture.title}"
''');
    expect(r.issues, isEmpty);
    final grid = _nodes(r).singleWhere((n) => n['type'] == 'gridView');
    expect((grid['props'] as Map)['mainAxisExtent'], 260);
    final phone = [for (final m in grid['media'] as List) if ((m as Map)['maxWidth'] == 699) (m['patch'] as Map)['props']];
    expect(phone, containsAll([
      {'crossAxisCount': 2},
      {'mainAxisSpacing': 4, 'crossAxisSpacing': 4},
      {'mainAxisExtent': 226},
    ]));
  });
}

void drawingTests() {
  group('drawing words that were kept and drew nothing', () {
    test('clip=true cuts what is in the box at its edge; clip=false does not', () {
      final r = _parse('''
Column
  Stack#a w=300 h=60 radius=9 clip=true
    Box w=fill h=200
  Stack#b w=300 h=60 clip=false
    Box w=fill h=200
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'a')['decoration'] as Map)['clip'], 'antiAlias');
      expect((_node(r, 'b')['decoration'] as Map?)?['clip'] ?? 'none', 'none');
    });

    test('two sides of a border on one line are both drawn', () {
      final r = _parse('''
Column
  Row#cell w=120 h=40 border-right=#FFD0D0D0 border-bottom=#FFD0D0D0
    Text "cell"
  Row#three w=120 h=40 border-top=#FFD0D0D0 border-left=#FFD0D0D0 border-bottom=#FFD0D0D0
    Text "cell"
  Row#one w=120 h=40 border-bottom=#FFD0D0D0
    Text "cell"
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'cell')['decoration'] as Map)['strokeSides'], 'bottomRight');
      expect((_node(r, 'three')['decoration'] as Map)['strokeSides'], 'noRight');
      expect((_node(r, 'one')['decoration'] as Map)['strokeSides'], 'bottom');
      expect((_node(r, 'cell')['decoration'] as Map)['strokes'], [
        {'color': '#FFD0D0D0'},
      ]);
    });

    test('sides of two colours: one colour is drawn, and that is said', () {
      final r = _parse('''
Column
  Row#cell w=120 h=40 border-right=#FFD0D0D0 border-bottom=#FF000000
    Text "cell"
''');
      expect(r.issues.single.message, contains('one colour'));
      expect((_node(r, 'cell')['decoration'] as Map)['strokeSides'], 'bottomRight');
    });

    test('a box pinned to both edges with no size there fills between them', () {
      final r = _parse('''
Stack w=222 h=112
  box#pinned x={"start":3,"end":3} y={"start":12,"end":2}
    customPaint viewBox=[240,100] fit=fill
      line p1=[0,53] p2=[240,53] stroke=#FF000000 strokeWidth=2
  box#sized x={"start":3,"end":3} y={"start":12,"end":2} h=20
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'pinned')['layout'] as Map)['height'], {'fill': 0});
      expect((_node(r, 'pinned')['layout'] as Map)['width'], {'fill': 0});
      expect((_node(r, 'sized')['layout'] as Map)['height'], 20);
    });

    test('an IconButton\'s fill is its own ground, written or worked out', () {
      final r = _parse('''
state playing=false
Row
  IconButton#a "pause" fill=#FFF5B56B color=#FF21160D
  IconButton#b "pause" fill={playing ? "#FFF5B56B" : "#FF000000"}
''');
      expect(r.issues, isEmpty);
      expect((_props(r, 'a')['style'] as Map)['backgroundColor'], '#FFF5B56B');
      expect(_node(r, 'a')['decoration'], isNull);
      expect((_node(r, 'b')['bind'] as Map)['props.style.backgroundColor'], contains('playing'));
    });
  });
}

void valueTextTests() {
  test('a place read from a text that is one value, also written as a document writes a read, is the number', () {
    final r = _parse(r'''
state pins=[{"id":"a","mapX":-0.5,"mapY":0.5}]
Stack w=400 h=200
  each p in pins
    Box#pin x={"align":"${p.mapX}"} y={"align":"{p.mapY}"} w=66 h=28
    Select#price items=["${fixed(p.mapX, 2)}"]
''');
    expect(r.issues, isEmpty);
    final bind = _node(r, 'pin')['bind'] as Map;
    expect(bind['layout.x'], r'${= {"align": (item.mapX)}}');
    expect(bind['layout.y'], r'${= {"align": (item.mapY)}}');
    // In a text a `$` before a value is a dollar sign, as before (a price).
    expect('${_node(r, 'price')['bind']}', contains(r'"$" + (fixed(item.mapX, 2))'));
  });

  test('a state\'s fill on a Text keeps the text: the look only, and the box to write is said', () {
    final r = _parse('''
state sample=0
state samples=[{"label":"One"},{"label":"Two"}]
Row
  each demo in samples
    Text#tab "{demo.label}" size=12 pad=[10,6,10,6] radius=5 selected={sample == index} selected.fill=#FFFFFFFF onTap={sample=index}
''');
    expect(r.issues.single.message, contains('write the box'));
    final states = '${_node(r, 'tab')['states']}';
    expect(states, isNot(contains('text: null')));
    expect(states, isNot(contains('style: null')));
    expect(_props(r, 'tab')['text'], r'${item.label}');
  });
}

void itemsTests() {
  group('items written with a value and what each shows', () {
    test('a SegmentedButton\'s are its segments', () {
      final r = _parse('''
state units="kg"
SegmentedButton#seg items=[{"value":"kg","label":"Kilograms"},{"value":"lb","label":"Pounds"}] @units
''');
      expect(r.issues, isEmpty);
      expect(_props(r, 'seg')['segments'], [
        {'value': 'kg', 'label': 'Kilograms'},
        {'value': 'lb', 'label': 'Pounds'},
      ]);
    });

    test('a Select lists the labels, shows the label of its value, and its change gives the value', () {
      final r = _parse('''
state appearance="system"
state log=""
Column
  Select#sel @appearance items=[{"value":"system","label":"Match device"},{"value":"dark","label":"Dark"}]
  Select#told items=[{"value":"a","label":"Alpha"},{"value":"b","label":"Beta"}] value="b" onChange={log=result}
  Select#plain @appearance items=["system","dark"]
''');
      expect(r.issues, isEmpty);
      expect(_props(r, 'sel')['items'], ['Match device', 'Dark']);
      expect((_node(r, 'sel')['bind'] as Map)['props.value'], r'${= get(["Match device","Dark"], indexOf(["system","dark"], appearance))}');
      expect(_action(r, 'sel')['value'], r'${= (get(["system","dark"], indexOf(["Match device","Dark"], result)))}');
      expect(_props(r, 'told')['value'], 'Beta');
      expect(_action(r, 'told')['value'], contains('indexOf(["Alpha","Beta"], result)'));
      // Plain texts are as before.
      expect(_props(r, 'plain')['items'], ['system', 'dark']);
      expect((_node(r, 'plain')['bind'] as Map)['props.value'], r'${appearance}');
    });
  });
}

void wordsTests() {
  group('a writer\'s own words', () {
    test('a Footer among a defined word\'s lines under a Sidebar is the sidebar\'s foot', () {
      final r = _parse('''
define Links current="a"
  NavItem "Photos" icon=photo
  Footer
    Text#storage "Storage"
App
  Sidebar#side
    Links current="a"
  Main
    Text "x"
''');
      expect(r.issues, isEmpty);
      final kids = _children(r, 'side');
      expect(kids, hasLength(3));
      expect(_node(r, kids[1])['type'], 'spacer');
      expect(_children(r, kids[2]).single, startsWith('storage'));
    });

    test('a page\'s define of a name the notation reads as another word (an alias) is the one read', () {
      final r = _parse('''
define MonthGrid month="Nov"
  Column gap=4
    Text "my grid {month}"
Column
  MonthGrid#mg month="Dec"
''');
      expect(r.issues, isEmpty);
      expect(_node(r, 'mg')['type'], 'column');
      expect(_nodes(r).where((n) => (n['props'] as Map?)?['text'] == 'my grid Dec'), hasLength(1));
      // Without a definition the name is no word: said with the notation's.
      expect(_parse('Column\n  MonthGrid#mg\n').issues.single.message, 'The notation has one name for each word and key: write Calendar#mg');
    });

    test('a define of a word the notation has itself is not used, and that is said', () {
      final r = _parse('''
define Card "t"
  Column
    Text "{t}"
define Rail
  Column w=64
Column
  Card#c "x"
''');
      expect(r.issues.map((i) => i.message), [contains('already has Card'), contains('already has Rail')]);
    });
  });
}

void saidTests() {
  group('what was dropped or read wrongly with nothing said', () {
    test('a state written twice, and a state and a computed of one name', () {
      final r = _parse('''
state pick="b"
state pick="c"
state total=3
computed total=length(pick)
Column
  Text "{pick} {total}"
''');
      expect(r.issues.map((i) => (i.line, i.message.contains('written twice'))), [(2, true), (4, true)]);
      expect(r.issues.first.message, contains('line 1'));
    });

    test('one state a name is said nothing of', () {
      final r = _parse('''
state pick="b"
state total=3
Column
  Text "{pick} {total}"
''');
      expect(r.issues, isEmpty);
    });

    test('Select selected={…} is read as its value, and value= is said', () {
      final r = _parse('''
state pick="b"
Select#s items=["a","b"] selected={pick}
''');
      expect(r.issues.single.message, contains('value='));
      expect((_node(r, 's')['bind'] as Map), {'props.value': r'${= pick}'});
    });

    test('LineChart series=[numbers] is one line; a series with no values and labels with none are said', () {
      final one = _parse('LineChart#c labels=["Mon","Tue"] series=[1,2]\n');
      expect(one.issues, isEmpty);
      expect(_props(one, 'c')['data'], [
        {'label': 'Mon', 's0': 1},
        {'label': 'Tue', 's0': 2},
      ]);
      final none = _parse('LineChart#c series=["visits"]\n');
      expect(none.issues.single.message, contains('series=[{"name"'));
      final labels = _parse('state rows=[{"d":"Mon","n":1}]\nLineChart#c data={rows} labels=["Mon"]\n');
      expect(labels.issues.single.message, contains('xField'));
    });

    test('a positional value written bare where a variable was meant says the braces', () {
      final r = _parse('''
state c={"icon":"home","label":"Home"}
Column
  Icon c.icon
''');
      expect(r.issues.single.message, contains('"{c.icon}"'));
    });
  });
}

void themeReadTests() {
  test('theme.<name> in a page expression is the theme color of that name, or the look the notation words take', () {
    final r = _parse('''
state on=true
Column
  Box#a w=40 h=40 fill={on ? theme.ember : theme.line}
  Box#b w=40 h=40 fill={theme.primary}
  Box#c w=40 h=40 fill={theme.colors.ember}
  Box#d w=40 h=40 fill={theme.nope}
''', options: const NotationOptions(themeColors: {'ember'}));
    expect(r.issues, isEmpty);
    String fill(String id) => '${(_node(r, id)['bind'] as Map)['decoration.fills[0].color']}';
    expect(fill('a'), r'${= on ? theme.colors.ember : "#FFE5E7EB"}');
    expect(fill('b'), r'${theme.primary}');
    expect(fill('c'), r'${theme.colors.ember}');
    // A name the theme has nothing under stays as written (a render says so).
    expect(fill('d'), r'${theme.nope}');
  });
}
