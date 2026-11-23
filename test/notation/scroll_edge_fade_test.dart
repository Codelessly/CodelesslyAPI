// What scrolls sideways ends in a fade where it continues past an edge, not
// in a hard cut: a row that scrolls, and a row of one repeated line (chips
// drawn from a list), which is a list that scrolls sideways.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog));

Map _node(NotationResult r, String id) => (r.document['nodes'] as Map)[id] as Map;

void main() {
  test('a row that scrolls fades at its edges', () {
    final r = _parse('Column\n  Row#chips scroll gap=8\n    Text "World"\n    Text "Politics"\n');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect((_node(r, 'chips')['props'] as Map)['edgeFade'], 12);
  });

  test('a row that scrolls and repeats one line (a list sideways) fades at its edges too', () {
    final r = _parse('state tags=["World","Politics"]\nColumn\n  Row#chips scroll gap=8\n    each t in tags\n      Text "{t}"\n');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    final chips = _node(r, 'chips');
    expect((chips['props'] as Map)['scrollDirection'], 'horizontal', reason: '$chips');
    expect((chips['props'] as Map)['edgeFade'], 12, reason: '$chips');
  });

  test('a fade of its own is kept; a list down the page has none', () {
    final r = _parse('state tags=["World","Politics"]\nColumn\n  Row#chips scroll gap=8 edgeFade=0\n    each t in tags\n      Text "{t}"\n  Column#down\n    each t in tags\n      Text "{t}"\n');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect((_node(r, 'chips')['props'] as Map)['edgeFade'], 0);
    expect(((_node(r, 'down')['props'] as Map?) ?? const {}).containsKey('edgeFade'), isFalse);
  });
}
