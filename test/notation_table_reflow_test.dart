// A Table and a component's root row are left as written by reflow (test 9:
// at a tablet's width a table's header and rows were laid out apart, the
// header no longer over its columns; a mail row's root Row, called alone,
// was wrapped on a phone); a table column says where it is left out.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

void main() {
  test('a table gets no rules of reflow; a column with "hide" is left out there, header and cells alike', () {
    final r = parseNotation('''
state rows:list=[{"id":"a","title":"x","email":"e","due":"d","seats":3}]
Column
  Table#t r in rows columns=[{"key":"id","label":"Id","w":80},{"key":"title","label":"Title"},{"key":"email","label":"Email","w":240,"hide":"phone"},{"key":"due","label":"Due","w":120,"hide":"tablet"},{"key":"seats","label":"Seats","w":64,"align":"end"}]
''', catalog: standardCatalog, options: withTestWords(NotationOptions(width: 1440)));
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

  group('a table whose columns say nothing of other widths', () {
    // Each cell's widths at which it is left out ('-': none), the header's and the row's alike.
    List<String> hides(String page, {double width = 1440}) {
      final r = parseNotation('state rows:list=[]\nstate chosen:list=[]\n$page\n', catalog: standardCatalog, options: withTestWords(NotationOptions(width: width)));
      expect(r.issues, isEmpty);
      final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
      final head = (_node(r, 't-head')['children'] as List).cast<String>();
      final row = (_node(r, 't-row')['children'] as List).cast<String>();
      String at(String id) => switch ((nodes[id] as Map)['media']) {
            final List m => m.map((x) => (x as Map)['maxWidth']).join(','),
            _ => '-',
          };
      expect([for (final c in head) at(c)], [for (final c in row) at(c)]);
      return [for (final c in row) at(c)];
    }

    const members = 'Table#t p in rows columns=[{"key":"name","label":"Name"},{"key":"role","label":"Role","w":90},{"key":"teams","label":"Teams","w":170},{"key":"status","label":"Status","w":100},{"key":"menu","label":"","w":32}]';

    test('a phone leaves out the columns after the name it has no room for; the checkbox and the menu stay (track C: the name was cut to nothing at 390)', () {
      expect(
        hides('Column\n  Table#t o in rows columns=[{"key":"name","label":"Customer"},{"key":"status","label":"Status","w":140},{"key":"total","label":"Total","w":120},{"key":"menu","label":"","w":40,"sort":false}] select=@chosen'),
        ['-', '-', '699', '699', '-'],
      );
      expect(hides('Column\n  $members'), ['-', '-', '699', '699', '-']);
    });

    test("a tablet leaves out what has no room beside the app's sidebar as wide as written, not beside a rail", () {
      expect(hides('App\n  Sidebar\n    NavItem "Members" icon="group"\n  Main\n    $members'), ['-', '-', '1023', '1023', '-']);
      expect(hides('App\n  Sidebar tablet.w=64 hide=phone\n    NavItem "Members" icon="group"\n  Main\n    $members'), ['-', '-', '699', '699', '-']);
    });

    test('a width at which the writer leaves a column out is theirs; a phone still leaves out what has no room when the writer said a tablet', () {
      expect(
        hides('Column\n  Table#t c in rows columns=[{"key":"title","label":"Card"},{"key":"col","label":"Status","w":130},{"key":"who","label":"Assignee","w":170},{"key":"due","label":"Due","w":120},{"key":"labels","label":"Labels","w":210,"hide":"tablet"}] select=@chosen'),
        ['-', '-', '-', '699', '699', '1023'],
      );
    });

    test('a table that fits, or a page written for a phone, is as written', () {
      expect(hides('Column\n  Table#t o in rows columns=[{"key":"name","label":"Name"},{"key":"total","label":"Total","w":120}]'), ['-', '-']);
      expect(hides('Column\n  Table#t o in rows columns=[{"key":"name","label":"Name"},{"key":"a","label":"A","w":140},{"key":"b","label":"B","w":140}]', width: 390), ['-', '-', '-']);
    });
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
''', catalog: standardCatalog, options: withTestWords(NotationOptions(width: 1440)));
    expect(r.issues, isEmpty);
    expect(_node(r, 'rowBody')['media'], isNull);
  });

  test("a table's header pins at the very top while the page scrolls (it pinned 16 px down, a row showing above it)", () {
    final r = parseNotation('state rows:list=[]\nColumn\n  Table#t r in rows columns=["Name"]\n', catalog: standardCatalog, options: withTestWords(NotationOptions(width: 1440)));
    expect(_node(r, 't-head')['sticky'], {'offset': 0});
  });
}
