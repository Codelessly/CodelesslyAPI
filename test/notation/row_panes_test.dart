// The panes of a row that has a height of its own are as tall as the row:
// under a row that says `stretch`, and a Column that scrolls under any such
// row. A pane that hugged kept its content's height, so its fill and its
// hairline stopped under its last line.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog));

Object? _height(NotationResult r, String id) => (((r.document['nodes'] as Map)[id] as Map)['layout'] as Map?)?['height'];

void main() {
  test('under a row that grows and says stretch, a pane with no height is as tall as the row', () {
    final r = _parse('''
Column h=600
  Row grow stretch
    Column#a w=200 fill=#FFF8FAFC border-right=#FFE2E8F0
      Text "Inbox"
    Box#b w=120 fill=#FFEEEEEE
    Column#c w=200 h=80
      Text "Sized"
    Column#d grow
      Text "Body"
''');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect(_height(r, 'a'), {'fill': 0});
    expect(_height(r, 'b'), {'fill': 0});
    // A height of its own is kept.
    expect(_height(r, 'c'), {'hug': 80});
    expect(_height(r, 'd'), {'fill': 0});
  });

  test('a Column that scrolls is as tall as the row that has a height, whatever the row says across', () {
    final r = _parse('''
Column h=600
  Row grow top
    Column#tree w=220 scroll border-right=#FFE2D6BC
      Text "Notebooks"
    Column#plain w=220
      Text "Plain"
''');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect(_height(r, 'tree'), {'fill': 0});
    // A pane that neither scrolls nor is stretched keeps its content's height.
    expect(_height(r, 'plain'), {'hug': 0});
  });

  test('a row as tall as its content leaves its children their own heights', () {
    final r = _parse('''
Column
  Row stretch
    Column#a w=200 fill=#FFF8FAFC
      Text "One"
    Column#b w=200 scroll
      Text "Two"
''');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect(_height(r, 'a'), {'hug': 0});
    expect(_height(r, 'b'), {'hug': 0});
  });
}
