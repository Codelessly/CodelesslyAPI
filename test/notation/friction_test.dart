// What six builders hit writing apps and sites in the notation (test 9),
// each fixed at its cause: a line that names a theme text style and changes
// one field keeps the rest of the style; a site's own component named like a
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

Object? _style(Map<String, Object?> node) => (node['props']! as Map)['style'];

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

void main() {
  group('a named text style and an override', () {
    test('style=title size=18 keeps the style under the size, in either order', () {
      final r = _expand('Column\n  Text "a" style=title size=18\n  Text "b" size=18 style=title\n  Text "c" style=title weight=400 color=#FF00FF00\n');
      expect(r.issues, isEmpty);
      final t = _of(r, 'text');
      expect(_style(t[0]), {'from': 'title', 'fontSize': 18});
      expect(_style(t[1]), {'from': 'title', 'fontSize': 18});
      expect(_style(t[2]), {'from': 'title', 'fontWeight': 400, 'color': '#FF00FF00'});
    });

    test('from=title alone is the style, with nothing of the body under it', () {
      final r = _expand('Column\n  Text "a" from=title\n  Text "b" size=18 from=title\n  Text "c" from=title size=null color=null weight=null\n');
      expect(r.issues, isEmpty);
      final t = _of(r, 'text');
      expect(_style(t[0]), {'from': 'title'});
      expect(_style(t[1]), {'fontSize': 18, 'from': 'title'});
      expect(_style(t[2]), {'from': 'title'});
    });

    test('style=title phone.size=13 keeps the style at a phone\'s width', () {
      final r = _expand('Column\n  Text "a" style=title phone.size=13\n');
      expect(r.issues, isEmpty);
      final t = _of(r, 'text').single;
      expect(_style(t), 'title');
      expect(jsonEncode(t['media']), contains('{"from":"title","fontSize":13}'));
    });

    test('a step size and a bound colour keep a named style too', () {
      final r = _expand('state hot=false\nColumn\n  Text "a" style=title size=small\n  Text "b" style=title color={hot ? "#FFFF0000" : "#FF000000"}\n');
      expect(r.issues, isEmpty);
      final t = _of(r, 'text');
      expect((_style(t[0])! as Map)['from'], 'title');
      expect((_style(t[1])! as Map)['from'], 'title');
      expect((t[1]['bind']! as Map)['props.style.color'], isNotNull);
    });

    test('the print of a style with an override reads back to the same document', () {
      final r = _expand('Column\n  Text "a" style=title size=18\n');
      final printed = printNotation(r.document, catalog: standardCatalog);
      final back = _expand(printed, options: notationOptionsFor(r.document));
      expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(r.document)), reason: printed);
    });
  });

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

  test('a capitalised word no catalog has says how a site\'s components are known', () {
    final r = _expand('Column\n  PlanCard title="x"\n');
    expect(r.issues.single.message, contains('--site'));
  });
}
