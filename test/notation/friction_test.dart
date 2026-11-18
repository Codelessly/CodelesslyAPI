// What six builders hit writing apps and sites in the notation (test 9),
// each fixed at its cause: a site's own component named like a
// word of the notation is said; braces after `when` and on an action's value
// mean the expression; a nested `each` that reuses a name reads its own
// element and never touches a string literal.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _expand(String text, {NotationOptions options = const NotationOptions(reflow: false), Catalog? catalog}) {
  final c = catalog ?? standardCatalog;
  return Catalog.run(c, () => parseNotation(text, catalog: c, options: options));
}

Map<String, Object?> _nodes(NotationResult r) => (r.document['nodes']! as Map).cast<String, Object?>();

List<Map<String, Object?>> _of(NotationResult r, String type) => [
      for (final n in _nodes(r).values)
        if ((n! as Map)['type'] == type) (n as Map).cast<String, Object?>(),
    ];

void main() {
  group('the app\'s own component named like a word of the notation', () {
    final footer = LayoutDocument.fromJson({
      'schema': 3,
      'id': 'Footer',
      'roots': ['f'],
      'widget': {'type': 'Footer', 'doc': 'The foot.'},
      'nodes': {
        'f': {'type': 'column', 'children': <Object?>[]},
      },
    });
    final card = LayoutDocument.fromJson({
      'schema': 3,
      'id': 'Card',
      'roots': ['c'],
      'widget': {
        'type': 'Card',
        'doc': 'A card.',
        'props': [
          {'key': 'title', 'type': {'kind': 'string'}, 'default': ''},
        ],
      },
      'nodes': {
        'c': {'type': 'column', 'children': <Object?>[]},
      },
    });
    final catalog = standardCatalog + ComponentLibrary.of([footer, card]).catalog;
    const own = NotationOptions(width: 1280, reflow: false);

    test('is said, with how to call it, where the notation reads its word instead', () {
      final r = _expand('Page\n  Section\n    Card title="x"\n  Footer\n', catalog: catalog, options: own.withOwnComponents(['Footer', 'Card']));
      final said = r.issues.map((i) => i.message).toList();
      expect(said, contains(contains('the component Footer is not called')));
      expect(said, contains(contains('the component Card is not called')));
    });

    test('is called when the line says its type', () {
      final r = _expand('Page\n  Section\n    Card type=Card title="x"\n  Footer type=Footer\n', catalog: catalog, options: own.withOwnComponents(['Footer', 'Card']));
      expect(r.issues, isEmpty);
      expect({for (final n in _nodes(r).values) (n! as Map)['type']}, containsAll(['Footer', 'Card']));
    });

    test('a design system\'s component of such a name is not the app\'s own: no issue', () {
      final r = _expand('Page\n  Section\n    Text "x"\n  Footer\n', catalog: catalog, options: own);
      expect(r.issues, isEmpty);
    });
  });

  group('braces around an expression in a trigger or an action mean the expression', () {
    String all(NotationResult r) => jsonEncode(r.document);

    test('key … when {cond} holds as key … when cond does', () {
      final braced = _expand('state sel:list=[]\nstate n=0\nkey escape when {length(sel) > 0} onPress={n=1}\nColumn\n  Text "a"\n');
      final bare = _expand('state sel:list=[]\nstate n=0\nkey escape when length(sel) > 0 onPress={n=1}\nColumn\n  Text "a"\n');
      expect(braced.issues, isEmpty);
      expect(all(braced), all(bare));
      expect(all(braced), contains(r'"when":"${= length(sel) > 0}"'));
    });

    test('every … when {cond}, on backPressed(when={cond})', () {
      final r = _expand('state n=0\nevery 1s when {n < 3} onTick={n=n+1}\non backPressed(when={n > 0})={n=0}\nColumn\n  Text "a"\n');
      expect(r.issues, isEmpty);
      expect(all(r), contains(r'"when":"${= n < 3}"'));
      expect(all(r), contains(r'"when":"${= n > 0}"'));
      expect(all(r), isNot(contains(r'${= {')));
    });

    test('x={expr} in an action list, in a choice, after then, in a timer', () {
      final r = _expand('state n=0\nstate p=false\nevery 1s onTick={p={n < 2}}\nColumn\n'
          '  Button "a" onTap={n={n + 1}; p={!p}}\n'
          '  Button "b" onTap={n > 2 ? {n=0} : {n={n * 2}}}\n'
          '  Button "c" onTap={confirm "Sure?" then {n={n - 1}}}\n');
      expect(r.issues, isEmpty);
      for (final f in [r'${= n + 1}', r'${= !p}', r'${= n * 2}', r'${= n - 1}', r'${= n < 2}']) {
        expect(all(r), contains('"$f"'));
      }
      expect(all(r), isNot(contains(r'${= {')));
    });

    test('a map literal keeps its braces', () {
      final r = _expand('state m:map={}\nColumn\n  Button "a" onTap={m={a: 1}}\n  Button "b" onTap={m={}}\n  Button "c" onTap={m={"id": 2}}\n');
      expect(r.issues, isEmpty);
      expect(all(r), contains(r'"${= {a: 1}}"'));
      expect(all(r), contains(r'"${= {}}"'));
    });

    test('notationUnbraced', () {
      expect(notationUnbraced('{a > 0}'), 'a > 0');
      expect(notationUnbraced('{{a}}'), 'a');
      expect(notationUnbraced('{a ? {b: 1} : {}}'), 'a ? {b: 1} : {}');
      expect(notationUnbraced('{a: 1}'), '{a: 1}');
      expect(notationUnbraced("{'k': 1}"), "{'k': 1}");
      expect(notationUnbraced('{a} + {b}'), '{a} + {b}');
      expect(notationUnbraced('{"}"}'), '"}"');
    });
  });
}
