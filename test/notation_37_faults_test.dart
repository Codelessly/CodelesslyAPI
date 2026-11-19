// Lines that follow the notation as released in 37.0.0 and drew wrongly: each
// test is such a line and what it now expands to.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, {NotationOptions options = const NotationOptions()}) =>
    parseNotation(text, catalog: standardCatalog, options: options);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();
List<String> _children(NotationResult r, String id) => ((_node(r, id)['children'] as List?) ?? const []).cast<String>();

void main() {
  group('a ListView with lines of its own', () {
    test('beside an each: said at the line, read as the scrolling Column it names', () {
      final r = _parse('''
state days=[{"key":"Mon"},{"key":"Tue"}]
state msgs=[]
Column
  ListView#history h=200 gap=15
    if length(msgs) == 0
      Text "Start the conversation"
    each d in days
      Text "{d.key}"
''');
      expect(r.issues.single.line, 4);
      expect(r.issues.single.message, contains('Column scroll with the lines and the each'));
      expect(_node(r, 'history')['type'], 'column');
      expect(_props(r, 'history'), containsPair('scrollable', true));
      expect(_props(r, 'history'), containsPair('spacing', 15));
      // The empty state and the list the each makes, each drawn once.
      expect(_children(r, 'history'), hasLength(2));
      expect(_node(r, _children(r, 'history').last)['bind'], containsPair('data', r'${days}'));
    });

    test('with words a Column does not take (stickToEnd): a list of one item, its lines', () {
      final r = _parse('''
state days=[{"key":"Mon"}]
state follow=true
Column
  ListView#history h=200 gap=15 stickToEnd={follow}
    Text "Start"
    each d in days
      Text "{d.key}"
''');
      expect(r.issues.single.message, contains('stickToEnd'));
      expect(_node(r, 'history')['type'], 'listView');
      expect(_props(r, 'history'), containsPair('itemCount', 1));
      final item = _children(r, 'history').single;
      expect(_node(r, item)['type'], 'column');
      expect(_props(r, item), containsPair('spacing', 15));
      expect(_children(r, item), hasLength(2));
    });

    test('a ListView whose only line is its each is the list over the data, as before', () {
      final r = _parse('''
state days=[{"key":"Mon"}]
Column
  ListView#list h=200
    each d in days
      Text "{d.key}"
''');
      expect(r.issues, isEmpty);
      expect(_node(r, 'list')['type'], 'listView');
      expect(_node(r, 'list')['bind'], containsPair('data', r'${days}'));
    });
  });
}
