// A Grid's cell written as an `if` and its `else`: the else's line is in
// the cell of the if's (the same row, no cell more), so the cells after it
// keep their places. Each branch was a cell of its own: `Grid cols=2` over a
// column, an `if` card and its `else` card made a second row for the else,
// of no height while the if showed.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _nodes(String text) {
  final r = Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog));
  expect(r.issues, isEmpty, reason: '${r.issues}');
  return (r.document['nodes'] as Map).cast<String, Object?>();
}

List<Object?> _kids(Map<String, Object?> nodes, String id) => ((nodes[id] as Map)['children'] as List?) ?? const [];

void main() {
  test('the else is in the row of its if, and the next cell follows them', () {
    final nodes = _nodes('''
state sent=false
Column
  Grid#g cols=2 gap=48
    Column#words
      Text "Say hello."
    if !sent
      Box#form h=200
    else
      Box#thanks h=120
    Box#next h=40
    Box#last h=40
''');
    expect(_kids(nodes, 'g'), ['gRow1', 'gRow2']);
    expect(_kids(nodes, 'gRow1'), ['words', 'form', 'thanks']);
    expect(_kids(nodes, 'gRow2'), ['next', 'last']);
    expect(((nodes['thanks'] as Map)['bind'] as Map)['visible'], contains('!(!sent)'));
  });

  test('an else if and its else share the cell too; an if of two lines gives its else two cells', () {
    final nodes = _nodes('''
state step=0
Column
  Grid#g cols=3
    if step==0
      Box#a h=40
    else if step==1
      Box#b h=40
    else
      Box#c h=40
    if step>1
      Box#d h=40
      Box#e h=40
    else
      Box#f h=40
      Box#h h=40
''');
    expect(_kids(nodes, 'g'), ['gRow1']);
    expect(_kids(nodes, 'gRow1'), ['a', 'b', 'c', 'd', 'e', 'f', 'h']);
  });

  test('with columns at other widths the else is drawn in the copy of its if', () {
    final nodes = _nodes('''
state sent=false
Column
  Grid#g cols=3 phone.cols=1
    Box#a h=40
    if !sent
      Box#form h=40
    else
      Box#thanks h=40
    Box#c h=40
''');
    final list = (nodes['gCells'] as Map).cast<String, Object?>();
    expect((list['bind'] as Map)['data'], contains('range(3)'));
    String shows(String id) => '${((nodes[id] as Map)['bind'] as Map)['visible']}';
    expect(shows('form'), contains('item == 1'));
    expect(shows('thanks'), contains('item == 1'));
    expect(shows('c'), contains('item == 2'));
  });
}
