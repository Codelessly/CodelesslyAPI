// A text's style written as a record (`style={…}`) beside the style keys of
// its line (`color=`, `size=`): the record joins them, in either order. (It
// replaced what came before it: a link's color was lost and it painted white
// on white.)
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _style(String line) {
  final r = parseNotation('Column\n  $line\n', catalog: standardCatalog);
  expect(r.issues, isEmpty);
  final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
  final text = nodes.values.cast<Map>().firstWhere((n) => n['type'] == 'text');
  return ((text['props'] as Map)['style'] as Map).cast<String, Object?>();
}

void main() {
  test('a color, then a record: the text keeps the color and takes the record', () {
    final style = _style('Text "Privacy Policy" color=#FF4A90E2 style={"decoration":"underline"}');
    expect(style['color'], '#FF4A90E2');
    expect(style['decoration'], 'underline');
  });

  test('the same in the other order', () {
    final style = _style('Text "Privacy Policy" style={"decoration":"underline"} color=#FF4A90E2');
    expect(style['color'], '#FF4A90E2');
    expect(style['decoration'], 'underline');
  });

  test('both orders keep the same keys; of a key both write, the later wins', () {
    final a = _style('Text "x" color=#FF4A90E2 size=18 style={"decoration":"underline","fontSize":20}');
    final b = _style('Text "x" style={"decoration":"underline","fontSize":20} color=#FF4A90E2 size=18');
    expect(a['fontSize'], 20);
    expect(b['fontSize'], 18);
    expect(a['color'], b['color']);
    expect(a['decoration'], b['decoration']);
    expect(a.keys.toSet(), b.keys.toSet());
  });
}
