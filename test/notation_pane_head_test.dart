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
}
