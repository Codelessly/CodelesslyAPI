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

  group("A1, A2: a site's theme reaches a Link and a Badge's tone", () {
    final site = {
      'primary': '#FF15803D',
      'colors': {'ink': '#FF201746'},
    };
    Map<String, Object?> styleOf(NotationResult r, String text) => ((_nodes(r).values.cast<Map>().firstWhere((n) => n['type'] == 'text' && (n['props'] as Map)['text'] == text))['props'] as Map)['style'] as Map<String, Object?>;
    Map<String, Object?> decoOf(NotationResult r, String text) {
      final t = _nodes(r).entries.firstWhere((e) => (e.value as Map)['type'] == 'text' && ((e.value as Map)['props'] as Map)['text'] == text).key;
      final row = _nodes(r).values.cast<Map>().firstWhere((n) => readStrings(n['children']).contains(t));
      return (row['decoration'] as Map).cast<String, Object?>();
    }

    test("a Link is in the theme's primary, named where the site names its colors (it was #FF2563EB)", () {
      for (final named in [true, false]) {
        final r = _parse('Page\n  Section\n    Link "Go" onTap={go home}\n', NotationOptions.fromTheme(site, named: named, width: 1440));
        expect(styleOf(r, 'Go')['color'], named ? 'primary' : '#FF15803D');
      }
    });

    test('Badge.success, .warning, .info, .primary under a theme with no tints: a tint of the tone (it was the neutral grey)', () {
      final r = _parse('Column\n  Badge.success "S"\n  Badge.warning "W"\n  Badge.info "I"\n  Badge.primary "P"\n  Badge "N"\n', NotationOptions.fromTheme(site, named: true, width: 1440));
      expect(((decoOf(r, 'S')['fills'] as List).single as Map)['color'], '#1A16A34A');
      expect(((decoOf(r, 'W')['fills'] as List).single as Map)['color'], '#1AEA580C');
      expect(((decoOf(r, 'I')['fills'] as List).single as Map)['color'], '#1A0891B2');
      expect(((decoOf(r, 'P')['fills'] as List).single as Map)['color'], '#1A15803D');
      expect(((decoOf(r, 'N')['fills'] as List).single as Map)['color'], '#FFF3F4F6');
      expect(styleOf(r, 'S')['color'], '#FF16A34A');
    });

    test('a theme with its own tints keeps them', () {
      final r = _parse('Column\n  Badge.success "S"\n', NotationOptions.fromTheme({...site, 'colors': {'success': '#FF00AA00', 'successTint': '#FFDDFFDD', 'successTintBorder': '#FFBBEEBB'}}, width: 1440));
      expect(((decoOf(r, 'S')['fills'] as List).single as Map)['color'], '#FFDDFFDD');
    });
  });

  group('A3: a theme text style changes only the keys it sets', () {
    const theme = {
      'primary': '#FF15803D',
      'colors': {'forest': '#FF234535'},
      'textStyles': {
        'serif': {'fontFamily': 'Georgia', 'fontWeight': 700},
        'heading2': {'fontFamily': 'Georgia', 'fontWeight': 600, 'color': 'forest'},
        'heading1': {'fontFamily': 'Roboto Slab', 'fontWeight': 800},
      },
    };
    Map<String, Object?> styleOf(NotationResult r, String text) =>
        (((_nodes(r).values.cast<Map>().firstWhere((n) => n['type'] == 'text' && (n['props'] as Map)['text'] == text))['props'] as Map)['style'] as Map).cast<String, Object?>();
    const page = 'Column\n  Heading "Head" level=1\n  Text.heading2 "Shop"\n  Text.heading2 "Ingredients" style=serif\n  Text.pageTitle "Cook" style=serif color=#FF283822\n';

    test('named (a site): a style named as a variant keeps the variant\'s size; style= keeps the variant\'s size and ink', () {
      final r = _parse(page, NotationOptions.fromTheme(theme, named: true, width: 1440));
      expect(styleOf(r, 'Shop'), {'from': 'heading2', 'fontSize': 24});
      expect(styleOf(r, 'Ingredients'), {'color': 'forest', 'fontSize': 24, 'from': 'serif'});
      expect(styleOf(r, 'Cook'), {'fontSize': 20, 'color': '#FF283822', 'from': 'serif'});
    });

    test('as values: the same', () {
      final r = _parse(page, NotationOptions.fromTheme(theme, width: 1440));
      expect(styleOf(r, 'Shop'), allOf(containsPair('fontSize', 24), containsPair('fontWeight', 600), containsPair('color', '#FF234535')));
      expect(styleOf(r, 'Ingredients'), allOf(containsPair('fontSize', 24), containsPair('fontWeight', 700), containsPair('fontFamily', 'Georgia'), containsPair('color', '#FF234535')));
    });
  });

  group('A4: layout', () {
    test('a Column maxw=720 in a centered column is as wide as its place up to 720 (it hugged its content)', () {
      final r = _parse('Column center\n  Column#capped maxw=720 gap=18\n    Text "A flashcard"\n');
      expect((_node(r, 'capped')!['layout'] as Map)['width'], {'fill': 0});
      expect(((_node(r, 'capped')!['layout'] as Map)['constraints'] as Map)['maxWidth'], 720);
    });

    test('a gauge\'s figure is sized to its shorter side (a 44 px figure over a 100 px arc)', () {
      final r = _parse('Column\n  Gauge#g 71 min=55 max=85 unit="°F" h=100\n');
      expect(((_node(r, 'gValue')!['props'] as Map)['style'] as Map)['fontSize'], 18);
    });

    test('Section bleed with no ground of its own has no padding: a hero meets the bar above it', () {
      final r = _parse('Page\n  Section#hero bleed\n    Box h=200 w=fill fill=#FF884422\n  Section#band bleed fill=#FF223344\n    Text "x"\n', const NotationOptions(width: 1440));
      expect((_node(r, 'hero')!['layout'] as Map)['padding'], anyOf(0, isNull));
      expect((_node(r, 'band')!['layout'] as Map)['padding'], [0, 64, 0, 64]);
    });
  });
}
