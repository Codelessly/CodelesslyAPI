// A text placed at a side of its place (`Text … w=fill align=end`) has its
// lines at that side of its box too: a text as wide as its column stayed
// where it was, its lines at the start. Printed back as written.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _props(NotationResult r, String id) => (((r.document['nodes'] as Map)[id] as Map)['props'] as Map).cast<String, Object?>();

void main() {
  test('align=end and align=center on a text in a column: its lines there too', () {
    final r = parseNotation('Column\n  Text#a "Google Calendar" w=fill align=end\n  Text#b "Outlook" w=fill align=center\n  Text#c "Apple" w=fill\n', catalog: standardCatalog);
    expect(r.issues, isEmpty);
    expect(_props(r, 'a')['textAlign'], 'end');
    expect(_props(r, 'b')['textAlign'], 'center');
    expect(_props(r, 'c').containsKey('textAlign'), isFalse);
  });

  test('what the line says of its lines wins; in a row, align is up and down', () {
    final r = parseNotation('Column\n  Text#a "A" w=fill align=end textAlign=start\n  Row h=40\n    Text#b "B" align=end\n', catalog: standardCatalog);
    expect(r.issues, isEmpty);
    expect(_props(r, 'a')['textAlign'], 'start');
    expect(_props(r, 'b').containsKey('textAlign'), isFalse);
  });

  test('printed back as written', () {
    const text = 'Column\n  Text#a "Google Calendar" w=fill align=end\n';
    final r = parseNotation(text, catalog: standardCatalog);
    final printed = printNotation(r.document, catalog: standardCatalog);
    expect(printed, isNot(contains('textAlign')));
    final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(r.document));
    expect(jsonDecode(jsonEncode(back.document)), jsonDecode(jsonEncode(r.document)));
  });
}
