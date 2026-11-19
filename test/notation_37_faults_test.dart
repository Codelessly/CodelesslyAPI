// Lines that follow the notation as released in 37.0.0 and drew wrongly: each
// test is such a line and what it now expands to.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, {NotationOptions options = const NotationOptions()}) =>
    parseNotation(text, catalog: standardCatalog, options: options);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();
List<String> _children(NotationResult r, String id) => ((_node(r, id)['children'] as List?) ?? const []).cast<String>();

void main() {
  group('a ListView with lines of its own', () {
    test('beside an each: said at the line, read as the scrolling Column it names', () {
      final r = _parse('''
state days=[{"key":"Mon"},{"key":"Tue"}]
state msgs=[]
Column
  ListView#history h=200 gap=15
    if length(msgs) == 0
      Text "Start the conversation"
    each d in days
      Text "{d.key}"
''');
      expect(r.issues.single.line, 4);
      expect(r.issues.single.message, contains('Column scroll with the lines and the each'));
      expect(_node(r, 'history')['type'], 'column');
      expect(_props(r, 'history'), containsPair('scrollable', true));
      expect(_props(r, 'history'), containsPair('spacing', 15));
      // The empty state and the list the each makes, each drawn once.
      expect(_children(r, 'history'), hasLength(2));
      expect(_node(r, _children(r, 'history').last)['bind'], containsPair('data', r'${days}'));
    });

    test('with words a Column does not take (stickToEnd): a list of one item, its lines', () {
      final r = _parse('''
state days=[{"key":"Mon"}]
state follow=true
Column
  ListView#history h=200 gap=15 stickToEnd={follow}
    Text "Start"
    each d in days
      Text "{d.key}"
''');
      expect(r.issues.single.message, contains('stickToEnd'));
      expect(_node(r, 'history')['type'], 'listView');
      expect(_props(r, 'history'), containsPair('itemCount', 1));
      final item = _children(r, 'history').single;
      expect(_node(r, item)['type'], 'column');
      expect(_props(r, item), containsPair('spacing', 15));
      expect(_children(r, item), hasLength(2));
    });

    test('a ListView whose only line is its each is the list over the data, as before', () {
      final r = _parse('''
state days=[{"key":"Mon"}]
Column
  ListView#list h=200
    each d in days
      Text "{d.key}"
''');
      expect(r.issues, isEmpty);
      expect(_node(r, 'list')['type'], 'listView');
      expect(_node(r, 'list')['bind'], containsPair('data', r'${days}'));
    });
  });

  group('an each across a row of a height of its own', () {
    test('copies that grow are as tall as the row, at each width it gives a height', () {
      final r = _parse('''
state days=[1,2,3]
Column w=fill
  Row#week h=102 tablet.h=114 pad=[0,1,0,1] keep
    each d in days
      Column#cell grow h=fill pad=7
        Text "{d}"
''');
      expect(r.issues, isEmpty);
      final list = _children(r, 'week').single;
      expect(_node(r, list)['type'], 'gridView');
      expect(_props(r, list), containsPair('mainAxisExtent', 100));
      expect(_props(r, list), isNot(contains('shrinkWrapRows')));
      final media = (_node(r, list)['media'] as List).cast<Map<String, Object?>>();
      expect(media.map((m) => (m['patch'] as Map)['props']), contains(equals({'mainAxisExtent': 112})));
      expect(((_node(r, '${list}Item')['layout'] as Map)['height'] as Map), {'fill': 0});
    });

    test('copies of a width of their own fill its height; across a hugging row the copies hug as before', () {
      final r = _parse('''
state days=[1,2,3]
Column w=fill
  Row#fixed h=60
    each d in days
      Column w=80 h=fill
        Text "{d}"
  Row#hugs
    each d in days
      Column grow
        Text "{d}"
''');
      expect(r.issues, isEmpty);
      expect((_node(r, _children(r, 'fixed').single)['layout'] as Map)['height'], {'fill': 0});
      final hugs = _children(r, 'hugs').single;
      expect(_props(r, hugs), containsPair('shrinkWrapRows', true));
      expect(((_node(r, '${hugs}Item')['layout'] as Map)['height'] as Map), {'hug': 0});
    });
  });

  group('copies of an each placed in a Grid\'s cells', () {
    const timetable = '''
state slots=["9:00","10:00"]
state shown=[{"t":"A","col":2,"row":1}]
Column w=fill
  Grid#g cols=3 gap=8 mainAxisExtent=60
    each t in slots
      Column#time columnStart=1 rowStart={index + 1} h=fill
        Text "{t}"
    each s in shown
      Column#session columnStart={s.col} rowStart={s.row} h=fill
        Text "{s.t}"
''';

    test('the place written on the line under the each is the copy\'s, in rows of the height written', () {
      final r = _parse(timetable);
      expect(r.issues, isEmpty);
      final times = _children(r, 'g').first;
      final item = _node(r, '${times}Item');
      expect((item['layout'] as Map)['columnStart'], 1);
      expect((item['bind'] as Map)['layout.rowStart'], r'${= index + 1}');
      expect((_node(r, 'time')['layout'] as Map), isNot(contains('columnStart')));
      expect(_props(r, times), containsPair('mainAxisExtent', 60));
      // Rows at least that high (the renderer's), their content's when longer.
    });

    test('two eaches that place their copies are one grid: their lists lie over each other', () {
      final r = _parse(timetable);
      expect(_node(r, 'g')['type'], 'stack');
      expect(_children(r, 'g').map((k) => _node(r, k)['type']), ['gridView', 'gridView']);
    });

    test('a grid whose copies say their column keeps its columns at a tablet\'s width', () {
      final r = _parse(timetable, options: const NotationOptions(width: 1280));
      for (final k in _children(r, 'g')) {
        final media = (_node(r, k)['media'] as List?) ?? const [];
        expect(media.where((m) => ((m as Map)['patch'] as Map?)?['props'] is Map && (((m['patch'] as Map)['props'] as Map).containsKey('crossAxisCount'))), isEmpty);
      }
    });

    test('eaches whose copies take the next free cell stay one under another', () {
      final r = _parse('''
state a=[1,2]
Column w=fill
  Grid#g cols=3
    each x in a
      Text "{x}"
    each y in a
      Text "{y}"
''');
      expect(_node(r, 'g')['type'], 'column');
    });
  });

  test('a line of a width of its own that grows at a width takes the room there (w=280 phone.grow)', () {
    final r = _parse('''
state q=""
Column w=fill
  Row gap=8
    Input#f @q hint="Search" w=280 phone.grow
    Button "Filters"
''');
    expect(r.issues, isEmpty);
    expect((_node(r, 'f')['layout'] as Map)['width'], 280);
    expect(_node(r, 'f')['media'], [
      {
        'maxWidth': 699,
        'patch': {
          'layout': {'flex': 1, 'width': {'fill': 0}},
        },
      },
    ]);
  });

  test('cards side by side in a row that says top sit at its top (they stretched to the tallest)', () {
    const text = '''
Column w=fill
  Row#top gap=18 tablet.direction=vertical top
    Column gap=12 grow
      Text "Passes"
    Card w=322
      Text "Your order"
  Row#plain gap=18
    Card
      Text "A"
    Card w=322
      Text "B"
''';
    final r = _parse(text, options: const NotationOptions(width: 1440));
    expect(_props(r, 'top'), containsPair('crossAxisAlignment', 'start'));
    // A row that says nothing: its cards are one row of panels, as before.
    expect(_props(r, 'plain'), containsPair('crossAxisAlignment', 'stretch'));
  });

  test('a row whose growing texts end in an ellipsis keeps its line at narrower widths', () {
    final r = _parse('''
Column w=fill
  Row#person pad=[8,8,8,5] gap=9 middle
    Avatar "Amelia Moreno" size=30
    Column gap=2 grow
      Text.strong "Amelia Moreno" maxLines=1 overflow=ellipsis
      Text.caption "Workspace owner" maxLines=1 overflow=ellipsis
  Row#label gap=9 middle
    Avatar "Amelia Moreno" size=30
    Column gap=2 grow
      Text.strong "Amelia Moreno"
''', options: const NotationOptions(width: 1440));
    expect(_node(r, 'person'), isNot(contains('media')));
    // Texts that wrap: the row wraps before it overflows, as before.
    expect(_node(r, 'label')['media'], isNotEmpty);
  });

  group('the bar of an app whose sidebar is a drawer', () {
    String page(String bar) => '''
canvas "Progress" w=1440 h=900
App
  Sidebar
    NavItem "Decks" icon=style
    NavItem "Insights" icon=insights selected
  Main
    Nav
$bar
    Column pad=24
      Text "Your progress"
''';

    Map<String, Object?>? title(NotationResult r) => (r.document['nodes'] as Map).values
        .cast<Map>()
        .where((n) => n['type'] == 'text' && (n['props'] as Map?)?['text'] == 'Progress')
        .firstOrNull
        ?.cast<String, Object?>();

    test('names the page beside its menu button when what names it there is hidden', () {
      final r = _parse(page('      Text "Lexi / Progress" hide=phone'), options: const NotationOptions(width: 1440));
      final t = title(r);
      expect(t, isNotNull);
      // Shown where the menu button is, and taking the bar's room.
      expect(t!['media'], isNotEmpty);
      expect((t['layout'] as Map)['flex'], 1);
    });

    test('a bar that names the page at every width gets no second title', () {
      final r = _parse(page('      Text "Progress / overview"'), options: const NotationOptions(width: 1440));
      expect(title(r), isNull);
    });
  });
}
