// An inset written as a list is four numbers. Two (`pad=[16,18]`) drew no
// inset at all, without a word: now said, and left out.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

void main() {
  test('two numbers for a pad: said, and left out', () {
    final r = parseNotation('Column\n  Row#bar w=fill pad=[16,18]\n    Text "Locked"\n', catalog: standardCatalog);
    expect(r.issues.single.message, contains('pad is one number (every side) or four, [left, top, right, bottom]'));
    final bar = (r.document['nodes'] as Map)['bar'] as Map;
    expect((bar['layout'] as Map).containsKey('padding'), isFalse);
  });

  test('a list its key cannot read: said, and left out (a path\'s view box is [width, height])', () {
    final r = parseNotation('Stack w=100 h=100\n  Path#p data="M6 0 L12 6 L6 12 L0 6 Z" w=24 h=24 viewBox=[0,0,12,12]\n', catalog: standardCatalog);
    expect(r.issues.single.message, contains('A Path\'s viewBox is a Size'));
    expect(((r.document['nodes'] as Map)['p'] as Map)['props'], isNot(contains('viewBox')));
    final ok = parseNotation('Stack w=100 h=100\n  Path#p data="M6 0 L12 6 L6 12 L0 6 Z" w=24 h=24 viewBox=[12,12]\n', catalog: standardCatalog);
    expect(ok.issues, isEmpty);
  });

  test('one number and four are read as written', () {
    final r = parseNotation('Column\n  Row#a pad=12\n    Text "A"\n  Row#b pad=[16,18,16,18]\n    Text "B"\n', catalog: standardCatalog);
    expect(r.issues, isEmpty);
    final nodes = r.document['nodes'] as Map;
    expect(((nodes['a'] as Map)['layout'] as Map)['padding'], 12);
    expect(((nodes['b'] as Map)['layout'] as Map)['padding'], [16, 18, 16, 18]);
  });
}
