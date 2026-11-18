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
}
