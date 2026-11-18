// A pane's head and what takes its room (test 9): a `sticky` toolbar at the
// top of a Pane or Main was pinned 16 px down inside the scrolling pane,
// over its first row; a `grow` line in Main had no height (Main scrolled).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

void main() {
  test('sticky lines at the top of a Pane stay above its scrolling body, not over it', () {
    final r = parseNotation('''
App
  Pane#list w=300
    Row#hdr sticky h=56
      Text "Inbox"
    Text#first "First message"
  Main#reader
    Text "Body"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280));
    expect(r.issues, isEmpty);
    final pane = _node(r, 'list');
    expect((pane['props'] as Map)['scrollable'], isNull);
    expect(pane['children'], ['hdr', 'listScroll']);
    expect(_node(r, 'hdr')['sticky'], isNull);
    expect((_node(r, 'listScroll')['props'] as Map)['scrollable'], true);
    expect(_node(r, 'listScroll')['children'], ['first']);
    // Main with no head scrolls as before.
    expect((_node(r, 'reader')['props'] as Map)['scrollable'], true);
  });

  test('a line that takes the room left in Main gives Main a height (it does not scroll)', () {
    final r = parseNotation('''
App
  Main#main
    Row#bar h=56
      Text "Board"
    Row#lanes grow
      Text "Lane"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280));
    expect(r.issues, isEmpty);
    expect((_node(r, 'main')['props'] as Map)['scrollable'], isNull);
  });

  test('copies that grow across a row: one a line where the row is a column; a width of their own at another size is said', () {
    final r = parseNotation('''
state teams:list=[{"id":"a"},{"id":"b"}]
Row#board gap=16 phone.direction=vertical
  each t in teams
    Column grow
      Text "{t.id}"
''', catalog: standardCatalog, options: const NotationOptions(width: 1440));
    expect(r.issues, isEmpty);
    expect(_node(r, 'listView1')['media'], [
      {
        'maxWidth': 699,
        'patch': {
          'props': {'crossAxisCount': 1, 'mainAxisSpacing': 16},
          'bind': {'props.crossAxisCount': null},
        },
      },
    ]);
    final lanes = parseNotation('''
state cols:list=[{"id":"a"}]
Row gap=12
  each c in cols
    Column w=fill grow tablet.w=272 tablet.grow=false
      Text "{c.id}"
''', catalog: standardCatalog, options: const NotationOptions(width: 1440));
    expect(lanes.issues.single.message, contains('tablet.w=272 tablet.grow=false) is not read'));
  });
}
