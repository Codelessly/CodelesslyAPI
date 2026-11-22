// A DataTable that says no height is as tall as its rows, up to 320 (more
// rows scroll in that): it was 320 tall whatever its rows.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog));

Map _layout(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map)['layout'] as Map;

void main() {
  test('a DataTable with no height hugs its rows under a cap of 320', () {
    final r = _parse('''
state rows=[{"n":"a","t":"string"}]
Column
  DataTable#t rows={rows} columns=[{"key":"n","label":"Parameter"},{"key":"t","label":"Type"}]
''');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect(_layout(r, 't')['height'], {'hug': 0});
    expect((_layout(r, 't')['constraints'] as Map)['maxHeight'], 320);
  });

  test('a height of its own is the table\'s height', () {
    final r = _parse('''
state rows=[{"n":"a","t":"string"}]
Column
  DataTable#t rows={rows} columns=[{"key":"n","label":"Parameter"},{"key":"t","label":"Type"}] h=480
''');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect(_layout(r, 't')['height'], isNot({'hug': 0}));
    expect((_layout(r, 't')['constraints'] as Map?)?['maxHeight'], isNull);
  });
}
