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

    test('a page and a text variable of one name after go: the page, and the braces said', () {
      final r = _parse('''
state settings="profile"
Column
  Button#b "Open" onTap={go settings}
''', options: const NotationOptions().withScreens(const ['settings', 'profile']));
      expect(r.issues.single.message, contains('go {settings}'));
      expect(_action(r, 'b')['to'], 'settings');
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
