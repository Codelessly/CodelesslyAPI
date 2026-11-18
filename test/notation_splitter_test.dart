// A Splitter is as long as the panes it divides (test 9, mail and admin:
// it hugged, a 44 px stub at the top of the window beside the panes' own
// full-height borders), and its value may size the pane after it.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

void main() {
  test('in a row it fills the row\'s height, in a column (vertical) the column\'s width; a written size stays', () {
    final r = parseNotation('''
state w=300
Column h=fill
  Row#row h=fill
    Column w={w} border-right=line
      Text "List"
    Splitter#s @w min=200 max=500 w=9
    Splitter#t @w h=40
    Column grow
      Text "Reader"
  Splitter#v @w orientation=vertical
''', catalog: standardCatalog, options: const NotationOptions(width: 1440));
    expect(r.issues, isEmpty);
    expect((_node(r, 's')['layout'] as Map)['height'], {'fill': 0});
    expect((_node(r, 's')['layout'] as Map)['width'], 9);
    expect((_node(r, 't')['layout'] as Map)['height'], 40);
    expect((_node(r, 'v')['layout'] as Map)['width'], {'fill': 0});
  });

  test('pane=after: its value is the width of the pane after it', () {
    final r = parseNotation('state w=300\nRow\n  Column grow\n    Text "a"\n  Splitter#s @w pane=after\n  Column w={w}\n    Text "b"\n',
        catalog: standardCatalog, options: const NotationOptions(width: 1440));
    expect(r.issues, isEmpty);
    expect((_node(r, 's')['props'] as Map)['pane'], 'after');
  });
}
