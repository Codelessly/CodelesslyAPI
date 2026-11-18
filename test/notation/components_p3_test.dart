// Wave 3 of notation parity, the components family (docs/design/22): a design
// system's component a notation word shadows, components two design systems
// declare differently, structure under a node, the document line, and ids
// with hyphens. Each form is written, expanded, printed, and printed back.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

/// [doc] printed with no tail and no document line, read back to itself.
String _prints(Map<String, Object?> doc, {Catalog? catalog, List<String> same = const []}) {
  final c = catalog ?? standardCatalog;
  String? whole;
  final printed = Catalog.run(c, () => printNotation(doc, catalog: c, whole: (why) => whole = why));
  expect(whole, isNull, reason: printed);
  expect(printed, isNot(contains(' {"')), reason: printed);
  expect(printed, isNot(contains('document {')), reason: printed);
  final back = parseNotation(printed, catalog: c, options: notationOptionsFor(doc));
  expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(doc)), reason: printed);
  final lines = printed.split('\n');
  for (final l in same) {
    expect(lines, contains(l), reason: printed);
  }
  return printed;
}

/// [text] expanded with no issue, printed in words and read back.
Map<String, Object?> _roundTrip(String text, {Catalog? catalog, List<String> same = const []}) {
  final c = catalog ?? standardCatalog;
  final r = parseNotation(text, catalog: c);
  expect(r.issues.map((i) => i.message), isEmpty, reason: text);
  _prints(r.document, catalog: c, same: same);
  return r.document;
}

Map<String, Object?> _nodes(Map<String, Object?> doc) => (doc['nodes']! as Map).cast<String, Object?>();

void main() {
  // Grammar change (the owner, 2026-11-17: "Support hyphens, that's very
  // common!"): an id is letters, digits and `_`, its parts joined by hyphens.
  group('an id with hyphens', () {
    test('is the id as written on a line, an overlay, a canvas, and where an action names it', () {
      final doc = _roundTrip('''
Column
  Text#m-title "Contact us"
  Button#hero-cta-2 "Open" onTap={open live-image}
  Button#down "Down" onTap={scroll page-end}
  Button#find "Find" onTap={focus note-title}
  Input#note-title "Title"
  Text#page-end "End"
Dialog#live-image "Live"
  Text "x"
''', same: ['  Text#m-title "Contact us"', '  Input#note-title "Title"', '  Text#page-end "End"']);
      expect(_nodes(doc).keys, containsAll(['m-title', 'hero-cta-2', 'note-title', 'page-end', 'live-image']));
    });

    test('names the line whose state it follows', () {
      final doc = _roundTrip('Row#m-nav gap=4\n  Text#m-nav-t "Docs" m-nav.hovered.color=#FF0F172A',
          same: ['  Text#m-nav-t "Docs" m-nav.hovered.color=#FF0F172A']);
      expect((_nodes(doc)['m-nav']! as Map)['states'], {
        'hovered': {
          'm-nav-t': {
            'props': {
              'style': {'color': '#FF0F172A'},
            },
          },
        },
      });
    });

    test('a variable named after a node takes the hyphens as _', () {
      final r = parseNotation('''
Column
  Button "Zoom" onTap={open photo-view}
Lightbox#photo-view photos={["a.png","b.png"]}
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      final names = [for (final scope in (r.document['variables']! as Map).values) for (final v in scope as List) (v as Map)['name']];
      expect(names, containsAll(['photo_viewZoom', 'photo_viewAt', 'photo_viewPhotos']));
    });

    test('another canvas with hyphens in its id is its block', () {
      final doc = _roundTrip('''
Column#m-root
  Text#m-title "Contact us"
Canvas#about-us "About" path="about"
  Text#about-body "About"
''', same: ['Column#m-root', '  Text#m-title "Contact us"', '  Text#about-body "About"']);
      expect(doc['roots'], contains('about-us'));
    });
  });
}
