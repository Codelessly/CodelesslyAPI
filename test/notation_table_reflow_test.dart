// A Table and a component's root row are left as written by reflow (test 9:
// at a tablet's width a table's header and rows were laid out apart, the
// header no longer over its columns; a mail row's root Row, called alone,
// was wrapped on a phone); a table column says where it is left out.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

void main() {
  test('a table gets no rules of reflow; a column with "hide" is left out there, header and cells alike', () {
    final r = parseNotation('''
state rows:list=[{"id":"a","title":"x","email":"e","due":"d","seats":3}]
Column
  Table#t r in rows columns=[{"key":"id","label":"Id","w":80},{"key":"title","label":"Title"},{"key":"email","label":"Email","w":240,"hide":"phone"},{"key":"due","label":"Due","w":120,"hide":"tablet"},{"key":"seats","label":"Seats","w":64,"align":"end"}]
''', catalog: standardCatalog, options: const NotationOptions(width: 1440));
    expect(r.issues, isEmpty);
    final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
    // The header and the row: only their cells' own hide rules.
    for (final row in ['t-head', 't-row']) {
      final cells = (_node(r, row)['children'] as List).cast<String>();
      final media = [for (final c in cells) jsonEncode((nodes[c] as Map)['media'])];
      expect(media, ['null', 'null', contains('"maxWidth":699'), contains('"maxWidth":1023'), 'null'], reason: row);
      expect(_node(r, row)['media'], isNull);
    }
  });

  test("a component's root row of parts of their own size keeps its layout", () {
    final r = parseNotation('''
component MailRow "A message in a list."
Row#rowBody gap=12 pad=[16,10,16,10]
  box w=8 h=8 radius=4 fill=#FF0D9488
  Column gap=2 grow
    Text "Maya Reyes"
    Text "Q4 roadmap review moved to Thursday"
  Text "9:42 AM" size=12
''', catalog: standardCatalog, options: const NotationOptions(width: 1440));
    expect(r.issues, isEmpty);
    expect(_node(r, 'rowBody')['media'], isNull);
  });
}
