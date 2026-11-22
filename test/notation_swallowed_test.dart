// Words a line takes in no place were swallowed with no word said (test 9,
// second cycle, kanban 4): keys after an each's list became part of its
// formula, `squeezable=false` on a Text in a Row was set true again. Each is
// read as written or said with what to write.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => parseNotation(text, catalog: standardCatalog);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

void main() {
  test('keys after an each\'s list are said, and the list is its expression alone', () {
    final r = _parse('''
state checklist:list=[{"id":"a"}]
Column
  each k in checklist reorder gap=2 onSwipe={checklist=[]}
    Text "{k.id}"
''');
    expect(r.issues.single.message, allOf(contains('gap=2 onSwipe={checklist=[]} are not read there'), contains('Column gap=2 reorder onReorder={…}')));
    final list = _node(r, 'listView1');
    expect((list['bind'] as Map)['data'], r'${checklist}');
    // reorder, written before the others, is still the each's own.
    expect((list['props'] as Map)['reorder'], isNotNull);
  });

  test('an each over a formula with quotes, spaces and its own words is read whole', () {
    final r = _parse('''
state rows:list=[{"id":"a"}]
Column
  each j in filter(rows, c => c.id != 'a b' && c.id != "c d") stagger=80
    Text "{j.id}"
''');
    expect(r.issues, isEmpty);
    expect((_node(r, 'listView1')['bind'] as Map)['data'], r'''${= filter(rows, c => c.id != 'a b' && c.id != "c d")}''');
  });

  test('an unknown key is said with the nearest one, at every width', () {
    final r = _parse('''
Column
  Column scroll maxh=640
    Text "a"
  Column scroll tablet.maxh=640
    Text "a"
''');
    expect(r.issues.map((i) => i.message), everyElement(contains('did you mean maxHeight?')));
    expect(r.issues.map((i) => i.line), [2, 4]);
  });

  test('squeezable=false on a Text in a Row keeps it whole', () {
    final r = _parse('''
Row
  Text#t "STK-142" squeezable=false
  Text#u "STK-142"
  Spacer
''');
    expect(r.issues, isEmpty);
    expect((_node(r, 't')['layout'] as Map)['squeezable'], false, reason: jsonEncode(_node(r, 't')));
    expect((_node(r, 'u')['layout'] as Map)['squeezable'], true);
  });

  test(r"'\n' in an expression inside a quoted text is the expression's (it was printed raw)", () {
    final r = _parse(r'''
state body="a"
Column
  Text#t "{replace(body, '\n', ' ')}"
  Text#u "Body: {replace(body, '\n', ' ')}."
  Text#v "line1\nline2"
''');
    expect(r.issues, isEmpty);
    expect((_node(r, 't')['props'] as Map)['text'], r"${= replace(body, '\n', ' ')}");
    expect((_node(r, 'u')['props'] as Map)['text'], r"Body: ${= replace(body, '\n', ' ')}.");
    expect((_node(r, 'v')['props'] as Map)['text'], 'line1\nline2');
    // And it prints to lines that read back as the same document.
    final again = _parse(printNotation(r.document, catalog: standardCatalog));
    expect(jsonEncode(again.document), jsonEncode(r.document));
  });

  test('a quoted text the line ends inside is said, and the parser goes on (it threw)', () {
    final r = _parse('Column\n  Text#a "one\n  Text#b "two"\n');
    expect(r.issues.first.message, contains('not closed on its line'));
    expect(r.issues.first.line, 2);
  });
}
