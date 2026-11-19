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

    test('with no page of the name the item is what go reads, as before', () {
      final r = _parse('''
state tabs=["home","library"]
Column
  each tab in tabs
    Button#b "{tab}" onTap={go tab}
''', options: const NotationOptions().withScreens(const ['home', 'library']));
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
