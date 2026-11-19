// Lines that follow the notation as released in 39.0.0 and drew wrongly, or
// were wrong and said nothing: each test is such a line and what it now
// expands to or says.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

NotationResult _parse(String text, {NotationOptions options = const NotationOptions()}) =>
    parseNotation(text, catalog: standardCatalog, options: withTestWords(options));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();
List<String> _children(NotationResult r, String id) => ((_node(r, id)['children'] as List?) ?? const []).cast<String>();
List<String> _roots(NotationResult r) => (r.document['roots'] as List).cast<String>();
Iterable<Map> _nodes(NotationResult r) => (r.document['nodes'] as Map).values.cast<Map>();
List<Map> _variables(NotationResult r) => [
      for (final scope in (r.document['variables'] as Map? ?? const {}).values)
        for (final v in scope as List) v as Map,
    ];

/// The first action of [id]'s first reaction.
Map _action(NotationResult r, String id) => (((_node(r, id)['actions'] as List).first as Map)['actions'] as List).first as Map;

void main() {
  group('a defined word whose body is an overlay', () {
    const drawer = '''
define SideMenu current="today"
  Drawer#menu "Navigation" w=290
    Text "{current}"
''';

    test('in the page\'s tree: the overlay, opened by the id its body gives, not drawn in the page', () {
      final r = _parse('''
${drawer}Column#page
  Button#opener "Menu" onTap={open menu}
  SideMenu current=home
  Text#after "After"
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'menu']);
      expect(_children(r, 'page'), ['opener', 'after']);
      expect(_action(r, 'opener'), containsPair('to', 'menu'));
      expect(_action(r, 'opener'), containsPair('cover', true));
      expect(_nodes(r).where((n) => (n['props'] as Map?)?['text'] == 'home'), hasLength(1));
    });

    test('after the page, at the margin, with no id on its use', () {
      final r = _parse('''
${drawer}Column#page
  Button#opener "Menu" onTap={open menu}
SideMenu
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'menu']);
      expect(_children(r, 'page'), ['opener']);
    });

    test('an id on the use is the overlay\'s, over the body\'s', () {
      final r = _parse('''
${drawer}Column#page
  Button#opener "Menu" onTap={open side}
SideMenu#side
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'side']);
    });

    test('a dictionary\'s ConfirmDialog with an id, in the page\'s tree', () {
      final r = _parse('''
state n=0
Column#page
  Button#opener "Reset" onTap={open ask}
  ConfirmDialog#ask "Reset?" "Really." onConfirm={n=0}
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'ask']);
      expect(_children(r, 'page'), ['opener']);
    });

    test('with no id inside an overlay: that overlay\'s content, its title, its note and its buttons', () {
      final r = _parse('''
state n=0
Column#page
  Button#opener "Delete" onTap={open sure}
Dialog#sure "Delete event?"
  ConfirmDialog "Delete this event?" "It will be removed." confirm="Delete event" onConfirm={n=1}
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'sure']);
      final texts = [for (final n in _nodes(r)) (n['props'] as Map?)?['text'] ?? (n['props'] as Map?)?['label']];
      expect(texts, containsAll(['Delete event?', 'Delete this event?', 'It will be removed.', 'Cancel', 'Delete event']));
      // One close button: the dialog's own.
      expect(_nodes(r).where((n) => n['type'] == 'iconButton'), hasLength(1));
    });
  });
}
