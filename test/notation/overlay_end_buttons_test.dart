// The buttons a dialog ends with, given their widths: they keep them. Written
// one under another they stay a column (two 310 wide buttons were put side by
// side in a 310 wide row as equal shares, and each drew nothing wide).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _app = '''
Column
  Button "Cancel" onTap={open cancelDialog}
Dialog#cancelDialog "Are you sure?" "Your call slot will be removed once cancelled."
  Button#confirm "Confirm cancellation" w=310 h=48 onTap={close}
  Button.ghost#keep "Keep appointment" w=310 h=48 onTap={close}
''';

Map<String, Object?> _nodes(NotationResult r) => (r.document['nodes'] as Map).cast<String, Object?>();
Map<String, Object?> _layout(NotationResult r, String id) => ((_nodes(r)[id] as Map)['layout'] as Map).cast<String, Object?>();
String _parentOf(NotationResult r, String id) =>
    _nodes(r).entries.firstWhere((e) => ((e.value as Map)['children'] as List?)?.contains(id) ?? false).key;

void main() {
  test('written one under another with their widths: a column, each as wide as written', () {
    final r = parseNotation(_app, catalog: standardCatalog);
    expect(r.issues, isEmpty);
    for (final id in ['confirm', 'keep']) {
      expect(_layout(r, id)['width'], 310, reason: id);
      expect(_layout(r, id)['flex'], isNull, reason: id);
    }
    final holder = _nodes(r)[_parentOf(r, 'confirm')] as Map;
    expect(holder['type'], 'column');
    expect(holder['children'], containsAllInOrder(['confirm', 'keep']));
  });

  test('in a row they keep their widths; those without one share it', () {
    final r = parseNotation(
      'Column\n  Button "Go" onTap={open d}\nDialog#d "Sure?"\n  Row gap=8\n    Button#a "One" w=120 onTap={close}\n    Button#b "Two" onTap={close}\n',
      catalog: standardCatalog,
    );
    expect(r.issues, isEmpty);
    expect(_layout(r, 'a')['width'], 120);
    expect(_layout(r, 'b')['width'], {'fill': 0});
    expect(_layout(r, 'b')['flex'], 1);
  });

  test('without widths, buttons one under another are still put in one row of equal shares', () {
    final r = parseNotation(_app.replaceAll(' w=310', ''), catalog: standardCatalog);
    expect(r.issues, isEmpty);
    expect((_nodes(r)[_parentOf(r, 'confirm')] as Map)['type'], 'row');
    expect(_layout(r, 'confirm')['width'], {'fill': 0});
  });
}
