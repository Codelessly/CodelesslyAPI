// What two writers wrote for a chat screen from the notation's reference
// alone, and the notation read wrongly: a site's own theme colors read as
// `theme.<name>`, an id worked out on a repeated line, a following list's
// events on its each line, and a gradient worked out from data.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _site = {
  'primary': '#FF5B5BD6',
  'colors': {'mine': '#FF5B5BD6', 'theirs': '#FFFFFFFF', 'ink': '#FF1C1B2E', 'danger': '#FFE5484D'},
  'dark': {
    'colors': {'theirs': '#FF24263A', 'ink': '#FFECEBF7'},
  },
};

NotationResult _read(String text, {Map<String, Object?>? theme}) => parseNotation(text,
    catalog: standardCatalog,
    options: theme == null ? const NotationOptions(width: 390) : NotationOptions.fromTheme(theme, width: 390, named: true, roles: true));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast();

List<Map<String, Object?>> _nodes(NotationResult r, String type) => [
      for (final n in (r.document['nodes'] as Map).values.cast<Map>())
        if (n['type'] == type) n.cast<String, Object?>(),
    ];

void main() {
  group('a site\'s own theme colors read as theme.<name>', () {
    test('in a defined word\'s formula: the color as the page runs, light or dark, and no issue', () {
      final r = _read(
          'state mine=true\nColumn\n  Bubble2 "hi" mine=true\ndefine Bubble2 "text" mine=false\n  Column fill={mine ? theme.mine : theme.theirs}\n    Text "{text}" color={mine ? "#FFFFFFFF" : theme.ink}\n',
          theme: _site);
      expect(r.issues, isEmpty);
      final doc = jsonEncode(r.document);
      expect(doc, contains('theme.colors.mine'));
      expect(doc, contains('theme.colors.theirs'));
      expect(doc, contains('theme.colors.ink'));
    });

    test('as a plain value, on a page and in a defined word: the name alone, as color=ink', () {
      final r = _read('Column\n  Text "a" color=theme.ink\n  Box w=10 h=10 fill=theme.danger border=theme.mine\n  Note2\ndefine Note2\n  Text "b" color=theme.danger\n', theme: _site);
      expect(r.issues, isEmpty);
      final texts = _nodes(r, 'text');
      expect([for (final t in texts) ((t['props'] as Map)['style'] as Map)['color']], ['ink', 'danger']);
      final box = _nodes(r, 'column').firstWhere((n) => jsonEncode(n['decoration']).contains('danger'));
      expect(jsonEncode(box['decoration']), allOf(contains('"danger"'), contains('"mine"')));
      expect(jsonEncode(r.document), isNot(contains('theme.ink')));
    });

    test('a name the theme does not declare, read in a defined word, is an issue that names the theme\'s own colors', () {
      final r = _read('Column\n  Odd2\ndefine Odd2\n  Text "a" color={theme.nope}\n', theme: _site);
      expect(r.issues.single.message, allOf(contains('Odd2 reads theme.nope'), contains('theme.mine'), contains('theme.theirs'), contains('"colors"'), contains('theme.accent')));
      final none = _read('Column\n  Odd2\ndefine Odd2\n  Text "a" color={theme.nope}\n');
      expect(none.issues.single.message, contains('names no colors of its own'));
    });

    test('a look\'s name in a defined word stays the look\'s, where the site names a color so too', () {
      final r = _read('Column\n  Tag2\ndefine Tag2\n  Row border={theme.line}\n    Text "t" color={theme.accent}\n', theme: {..._site, 'colors': {...(_site['colors']! as Map), 'line': '#FFE6E4F0', 'accent': '#FF0D9488'}});
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), isNot(contains('theme.colors.line')));
    });
  });

  group('an id worked out on a repeated line', () {
    const rows = 'state rows=[{"id":"m1"},{"id":"m2"}]\nstate pinId="m2"\n';

    test('is said, with the way to scroll to a copy: the line\'s name and the item', () {
      final r = _read('${rows}Column\n  Row onTap={scroll {pinId}}\n    Text "pin"\n  each m in rows follow grow\n    Row#msg id={m.id}\n      Text "{m.id}"\n');
      final message = r.issues.single.message;
      expect(message, allOf(contains('id={m.id} is left out'), contains('scrollTo node=msg item={x}'), contains('follows its end')));
    });

    test('scroll {expression} reads the expression as the action runs', () {
      final r = _read('${rows}Column\n  Row#bar onTap={scroll {pinId}}\n    Text "pin"\n  Text#m2 "two"\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(_node(r, 'bar')['actions']), contains(r'"node":"${pinId}"'));
    });

    test('scrollTo node= item= reaches a copy by its item', () {
      final r = _read('${rows}Column\n  Row#bar onTap={scrollTo node=msg item={pinId}}\n    Text "pin"\n  each m in rows follow grow\n    Row#msg\n      Text "{m.id}"\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(_node(r, 'bar')['actions']), allOf(contains('"node":"msg"'), contains(r'"item":"${pinId}"')));
    });
  });

  group('a following list\'s events on its each line', () {
    test('onScroll on each … follow is the list\'s scroll reaction', () {
      final r = _read('state rows=[1,2,3]\nstate away=false\nColumn h=400\n  each m in rows follow grow onScroll={away = result.offset < result.max - 80}\n    Text "{m}"\n');
      expect(r.issues, isEmpty);
      final list = _nodes(r, 'listView').single;
      expect((list['props'] as Map)['stickToEnd'], isTrue);
      final actions = list['actions'] as List;
      expect((actions.single as Map)['trigger'], {'type': 'scroll'});
      expect(jsonEncode(actions), contains('result.offset < result.max - 80'));
    });

    test('an event a list has not is said; without follow an each line takes none', () {
      final odd = _read('state rows=[1]\nColumn h=400\n  each m in rows follow grow onWobble={rows=[]}\n    Text "{m}"\n');
      expect(odd.issues.single.message, contains('onWobble'));
      final plain = _read('state rows=[1]\nstate away=false\nColumn\n  each m in rows onScroll={away=true}\n    Text "{m}"\n');
      expect(plain.issues.single.message, allOf(contains('not read there'), contains('with follow, the list\'s events')));
    });
  });

  group('a gradient worked out from data', () {
    test('gradient={[a, b]} is a linear fill whose colors are read as the page runs', () {
      final r = _read('state people=[{"c1":"#FFFF9A6C","c2":"#FFE5484D"}]\nColumn\n  each m in people\n    Box#face w=40 h=40 gradient={[m.c1, m.c2]}\n');
      expect(r.issues, isEmpty);
      final bound = (_node(r, 'face')['bind'] as Map)['decoration.fills'] as String;
      expect(bound, allOf(contains('"linear"'), contains('(item.c1)'), contains('(item.c2)'), contains('"position": 1.0')));
    });

    test('one that is not a list of colors is said, not left out silently', () {
      final r = _read('state cs=["#FF000000","#FFFFFFFF"]\nColumn\n  Box w=40 h=40 gradient={cs}\n');
      expect(r.issues.single.message, allOf(contains('gradient={[m.c1, m.c2]}'), contains('gradient={cs} is left out')));
    });
  });
}
