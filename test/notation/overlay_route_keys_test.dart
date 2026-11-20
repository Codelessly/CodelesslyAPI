// The fields of the route that shows a dialog or a sheet, written on its own
// line: its route's, as on an openModal (they were read as its column's keys
// and refused: `Sheet#live maxHeightFactor=0.9`).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _open(NotationResult r) {
  final nodes = (r.document['nodes'] as Map).values.cast<Map>();
  for (final n in nodes) {
    for (final reaction in (n['actions'] as List?) ?? const []) {
      for (final a in ((reaction as Map)['actions'] as List)) {
        if ((a as Map)['type'] == 'openModal') return a.cast<String, Object?>();
      }
    }
  }
  throw StateError('no openModal');
}

void main() {
  test('a sheet\'s line sets its height cap, its grip, its corners and its scrim', () {
    final r = parseNotation(
      'Column\n  Button "Open" onTap={open live}\nSheet#live maxHeightFactor=0.95 showDragHandle=false sheetRadius=10 barrierColor=#8A000000 pad=0\n  Text "Hello"\n',
      catalog: standardCatalog,
    );
    expect(r.issues, isEmpty);
    final open = _open(r);
    expect(open['presentation'], 'bottomSheet');
    expect(open['maxHeightFactor'], 0.95);
    expect(open['showDragHandle'], false);
    expect(open['sheetRadius'], 10);
    expect(open['barrierColor'], '#8A000000');
  });

  test('a dialog\'s line sets the space kept around it', () {
    final r = parseNotation('Column\n  Button "Open" onTap={open d}\nDialog#d "Sure?" insets=[24,48,24,48]\n  Text "Hello"\n', catalog: standardCatalog);
    expect(r.issues, isEmpty);
    expect(_open(r)['insets'], [24, 48, 24, 48]);
  });

  test('a dialog with nothing under it, then a node at the margin: said (its body was drawn on the page)', () {
    final r = parseNotation('Column\n  Button "Open" onTap={open alert}\nDialog#alert w=310\nColumn w=310 gap=12\n  Text "Body"\n', catalog: standardCatalog);
    expect(r.issues.single.message, startsWith('Dialog#alert has nothing indented under it, so the Column after it'));
    // Indented under it: nothing to say; a dialog that only has its title, then another overlay: nothing either.
    expect(parseNotation('Column\n  Button "Open" onTap={open alert}\nDialog#alert w=310\n  Column w=310 gap=12\n    Text "Body"\n', catalog: standardCatalog).issues, isEmpty);
    expect(
      parseNotation('Column\n  Button "A" onTap={open a}\n  Button "B" onTap={open b}\nDialog#a "Sure?"\nSheet#b\n  Text "Body"\n', catalog: standardCatalog).issues,
      isEmpty,
    );
  });

  test('unwritten, the word\'s own: a grip and 20 px corners', () {
    final r = parseNotation('Column\n  Button "Open" onTap={open live}\nSheet#live\n  Text "Hello"\n', catalog: standardCatalog);
    final open = _open(r);
    expect(open['showDragHandle'], true);
    expect(open['sheetRadius'], 20);
  });
}
