// What test 11's direct writes (round 11, 30 briefs written from the grammar
// alone) showed the notation drawing wrongly: each is drawn as meant here.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, [NotationOptions options = const NotationOptions(openVocabulary: true)]) =>
    parseNotation(text, catalog: standardCatalog, options: options);

Map<String, Object?> _nodes(NotationResult r) => (r.document['nodes'] as Map).cast<String, Object?>();

Map<String, Object?>? _node(NotationResult r, String id) => (_nodes(r)[id] as Map?)?.cast<String, Object?>();

List<String> _texts(NotationResult r) => [
      for (final n in _nodes(r).values)
        if ((n as Map)['type'] == 'text') '${(n['props'] as Map)['text']}',
    ];

void main() {
  group('B: a stand-in with nothing to draw', () {
    const app = '''
state appearance="System"
KeyboardShortcut keys="Ctrl+K" onPress={toast "k"}
ThemePreference mode={appearance}
App
  Sidebar
    Brand "Notes"
  Main
    Nav
      Heading "Workspace" level=1
      KeyBindings onNew={toast "n"}
    Column#content pad=24 gap=12
      LiveStatus @appearance
      LiveAnnouncement "{appearance}"
      Text "Below the status"
      CardKeys focused=false
        Card
          Text "In a key wrapper"
      SeatMap rows=[] h=200
      SectionPreference "Show weather"
      PropertyScene h=120
      Text "End"

primitive ThemePreference mode="System"
primitive KeyBindings onNew
primitive LiveStatus @message
primitive CardKeys focused=false onLeft
primitive SeatMap rows=[]
primitive SectionPreference "text"
''';

    test('beside the App at the top of the page: not drawn, and the App is the root (with its window)', () {
      final r = _parse(app, const NotationOptions(openVocabulary: true, width: 1440));
      final canvas = _node(r, 'screen')!;
      final root = _node(r, (canvas['slots'] as Map)['body'] as String)!;
      expect(root['type'], 'row', reason: 'the App, not a column holding a bar above it');
      expect(_texts(r), isNot(contains(startsWith('KeyboardShortcut'))));
      expect(_texts(r), isNot(contains('ThemePreference')));
      expect((canvas['layout'] as Map)['height'], {'fill': 800.0}, reason: 'the App keeps the window');
      // Recorded as before.
      expect([for (final u in r.vocabulary) if (u.kind == 'type' || u.kind == 'primitive') u.word],
          containsAll(['KeyboardShortcut', 'ThemePreference', 'KeyBindings', 'LiveStatus', 'CardKeys', 'SeatMap', 'PropertyScene']));
    });

    test('a behaviour with no picture (keys, a live status, an announcement) draws nothing and takes no room', () {
      final r = _parse(app, const NotationOptions(openVocabulary: true, width: 1440));
      final content = readStrings(_node(r, 'content')!['children']);
      final words = [for (final id in content) _node(r, id)!['type']];
      expect(_texts(r), isNot(anyOf(contains('KeyBindings'), contains('LiveStatus'), contains(startsWith('LiveAnnouncement')))));
      expect(content.where((id) => id.startsWith('liveStatus')), isEmpty);
      expect(words.first, 'text', reason: 'the content starts with its first text');
    });

    test('a behaviour wrapped round lines is those lines, with no labelled box', () {
      final r = _parse(app, const NotationOptions(openVocabulary: true, width: 1440));
      final keys = _node(r, 'cardKeys1')!;
      expect(keys['decoration'], isNull);
      expect(_texts(r), isNot(contains('CardKeys')));
      expect(_texts(r), contains('In a key wrapper'));
    });

    test('a picture the notation cannot draw keeps its labelled box: a primitive with a size, one with a text, an unknown word', () {
      final r = _parse(app, const NotationOptions(openVocabulary: true, width: 1440));
      expect(_texts(r), containsAll(['SeatMap', 'SectionPreference: Show weather', 'PropertyScene']));
    });

    test('beside a Page: a primitive with nothing to draw is not a bar above the page', () {
      final r = _parse('''
primitive Clock onTick
Clock onTick={toast "t"}
Page
  Section
    Heading "Hello" level=1
''', const NotationOptions(openVocabulary: true, width: 1440));
      expect(_texts(r), isNot(contains('Waveform')));
      expect(_nodes(r).keys, isNot(contains('pageRoot')));
      expect(r.vocabulary.where((u) => u.word == 'Clock' && u.kind == 'primitive'), isNotEmpty);
    });

    test('a page with no App or Page: a top-level word keeps its box', () {
      final r = _parse('''
Column
  Text "a"
Waveform
''');
      expect(jsonEncode(r.document), contains('Waveform'));
    });
  });

  group('A5, A8: a definition of several lines, or of an each, is its lines where the use is', () {
    const page = '''
state items=[{"n":"a"},{"n":"b"},{"n":"c"}]
App
  Sidebar#side
    TenantMenu active="x"
  Main
    Column#content pad=24 gap=12
      Rows
      Grid#cells cols=3 gap=4
        Rows
      Rows#kept hide=phone

define TenantMenu active=""
  Brand "Tenant" icon="apartment"
  NavItem "Members" icon="people" selected={active=="x"}
  NavItem "Roles" icon="key"

define Rows
  each it in items
    Card
      Text "{it.n}"
''';

    test('two lines side by side: read, and the sidebar\'s own lines (it was refused, a placeholder)', () {
      final r = _parse(page, const NotationOptions(width: 1440));
      expect(r.issues, isEmpty);
      expect(_texts(r), containsAll(['Tenant', 'Members', 'Roles']));
      expect(readStrings(_node(r, 'side')!['children']), hasLength(3), reason: 'the brand and the two items are the sidebar\'s lines');
    });

    test('an each in a Column takes its gap; in a Grid each copy is a cell', () {
      final r = _parse(page, const NotationOptions(width: 1440));
      final first = _node(r, readStrings(_node(r, 'content')!['children']).first)!;
      expect(first['type'], 'listView');
      expect((first['props'] as Map)['spacing'], 12);
      final grid = _nodes(r).values.cast<Map>().where((n) => n['type'] == 'gridView').single;
      expect((grid['props'] as Map)['crossAxisCount'], 3);
    });

    test('a use with words of its own for the root keeps a Column holding the lines', () {
      final r = _parse(page, const NotationOptions(width: 1440));
      expect(_node(r, 'kept')!['type'], 'column');
      expect(readStrings(_node(r, 'kept')!['children']).single, startsWith('listView'));
    });
  });
}
