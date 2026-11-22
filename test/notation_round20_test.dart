// Round 20 (30 briefs in the Cards design system): what the reader got
// wrong of lines that were written right, and messages that named nothing
// to write.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _page(String text, {NotationOptions options = const NotationOptions(width: 1440)}) => parseNotation(text, catalog: standardCatalog, options: options);

Map _node(NotationResult r, String id) => (r.document['nodes'] as Map)[id] as Map;

List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];

void main() {
  group('a worked-out state that an action sets', () {
    test('where the page opens, and in a branch of a choice: said by its name, never as its formula', () {
      final r = _page('''
state cards=[{"deck":1}]
state deck=1
state pool={filter(cards,c=>c.deck==deck)}
state month={today()}
state thread=[]
state msgs={thread}
state draft=""
on load={pool=filter(cards,c=>c.deck==deck); month=today()}
key mod+Enter onPress={draft!="" ? msgs=append(msgs,draft) : toast "Write something first"}
Column
  Text "{length(pool)} {month} {length(msgs)}"
''');
      expect(_said(r), [
        startsWith('pool is worked out (state pool={filter(cards,c=>c.deck==deck)}): it is that formula wherever it is read, so it is never set, and this action is left out. '
            'For a value that starts there and then changes, give it a start and set it when the page opens: state pool=[] and on load={pool=filter(cards,c=>c.deck==deck)}'),
        startsWith('month is worked out (state month={today()})'),
        allOf(startsWith('msgs is worked out (state msgs={thread})'), contains('state msgs=[] and on load={msgs=thread}')),
      ]);
      expect(_said(r).join(), isNot(contains('Unknown action')));
    });
  });

  group('a definition', () {
    test('a key line\'s key is the key, whatever its lines call an item', () {
      final r = _page('''
define Shell "page"=Month
  key w onPress={at="week"}
  key alt+c onPress={at="c"}
  Column
    each w in ["M","T"]
      Text "{w}"
    each c in ["a"]
      Text "{c}"
state at=""
Column
  Shell "a"
''');
      expect(_said(r), isEmpty);
      expect([for (final a in _node(r, 'screen')['actions'] as List) ((a as Map)['trigger'] as Map)['key']], ['w', 'alt+c']);
    });

    test('a record parameter with nothing given reads as no value, not as empty brackets', () {
      final r = _page('''
define RC rec={}
  Card#c pad=12 onTap={rid=rec.id}
    Text "{rec.name}"
state rid=0
Column
  RC
''');
      expect(_said(r), isEmpty);
      expect(jsonEncode(r.document), allOf(contains(r'${= null.id}'), isNot(contains('()'))));
    });

    test('a bare word after open is the overlay\'s id, beside a parameter of that name', () {
      final r = _page('''
define BC card={}
  Card pad=12 onTap={openId=card.id; open card}
    Text "{card.title}"
state cards=[{"id":"c1","title":"t"}]
state openId=""
Column
  each c in cards
    BC card={c}
Dialog#card "Card"
  Text "{openId}"
''');
      expect(_said(r), isEmpty);
      expect(jsonEncode(r.document), allOf(contains('"type":"openModal","to":"card"'), isNot(contains('"to":"(item)"'))));
    });
  });

  test('a color of the theme by its name alone in a formula says the read to write', () {
    final options = NotationOptions.fromTheme({
      'primary': '#FF4F7A3A',
      'colors': {'tomato': '#FFD9482B', 'herb': '#FF4F7A3A'},
    }, width: 1440);
    final r = _page('state left=0\nColumn\n  Icon "timer" color=tomato\n  Text#t "x" color={left==0?herb:tomato}\n', options: options);
    expect(_said(r), [
      startsWith('herb is a color of the theme, and in a formula a name alone is a variable: write theme.colors.herb there'),
      startsWith('tomato is a color of the theme'),
    ]);
    final named = _page('state left=0\nColumn\n  Text#t "x" color={left==0 ? theme.colors.herb : theme.colors.tomato}\n', options: options);
    expect(_said(named), isEmpty);
  });

  test('a bound under a shortened name, and a rect\'s radius, say the line to write', () {
    final r = _page('Column\n  Column minw=200\n    Text "a"\n  Box w=40 h=40\n    customPaint viewBox=[40,40]\n      rect rect=[0,0,40,40] radius=6 fill=#FF000000\n');
    expect(_said(r), [
      'A Column has no "minw" (did you mean minWidth?): left out.',
      'A rect has no "radius": a rectangle with round corners is rrect, with the same fields: rrect rect=[left,top,width,height] radius=6 fill=….',
    ]);
    expect(_said(_page('Column\n  Column minWidth=200\n    Text "a"\n  Box w=40 h=40\n    customPaint viewBox=[40,40]\n      rrect rect=[0,0,40,40] radius=6 fill=#FF000000\n')), isEmpty);
  });
}
