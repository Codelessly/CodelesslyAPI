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

/// A design system whose components a word of the notation shadows.
final _shadowed = standardCatalog +
    Catalog.fromJson({
      'id': 'ds',
      'widgets': [
        {
          'type': 'Button',
          'props': [
            {'key': 'label', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': 'Button', 'required': true},
            {'key': 'variant', 'type': {'kind': 'enumeration', 'flutter': 'String', 'values': ['primary', 'ghost']}, 'default': 'primary'},
          ],
          'events': [
            {'key': 'onPressed'},
          ],
        },
        {
          'type': 'Chip',
          'props': [
            {'key': 'label', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': 'Chip', 'required': true},
            {'key': 'selected', 'type': {'kind': 'variable', 'flutter': 'ValueNotifier<bool>', 'of': {'kind': 'boolean', 'flutter': 'bool'}}, 'default': ''},
          ],
          'events': [
            {'key': 'onRemove', 'type': {'kind': 'string', 'flutter': 'String'}},
          ],
          'slots': ['leading'],
        },
      ],
    });

void main() {
  group('a design system component a word of the notation shadows', () {
    test('its events are its own, by their names, on a line that names it', () {
      final doc = _roundTrip('''
state removed="none"
Column
  Button#apply "Apply" type=Button variant=ghost onPressed={toast "Applied"}
  Chip#tag "Design" type=Chip onRemove={removed=result}
''', catalog: _shadowed, same: ['  Button#apply "Apply" type=Button variant=ghost onPressed={toast "Applied"}']);
      final apply = _nodes(doc)['apply']! as Map;
      expect(apply['type'], 'Button');
      expect(apply['actions'], [
        {
          'trigger': {'type': 'event', 'event': 'onPressed'},
          'actions': [
            {'type': 'showToast', 'message': 'Applied'},
          ],
        },
      ]);
      expect(((_nodes(doc)['tag']! as Map)['actions'] as List).single, containsPair('trigger', {'type': 'event', 'event': 'onRemove'}));
    });

    test('its variable parameter is a mark, its slot a slot line', () {
      final doc = _roundTrip('''
state on=true
Column
  Chip#tag "Design" type=Chip @on
    slot leading
      box#dot w=8 h=8
''', catalog: _shadowed, same: ['  Chip#tag "Design" type=Chip @on', '    slot leading']);
      final tag = _nodes(doc)['tag']! as Map;
      expect(tag['props'], containsPair('selected', 'on'));
      expect(tag['slots'], {'leading': 'dot'});
    });

    test('in its own tree, a component raises an event of its own with emit', () {
      _prints({
        'schema': 3,
        'id': 'Banner',
        'roots': ['banner'],
        'widget': {
          'type': 'Banner',
          'props': [
            {'key': 'action', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': 'Undo'},
          ],
          'events': [
            {'key': 'onAction'},
          ],
        },
        'nodes': {
          'banner': {
            'type': 'row',
            'children': ['act'],
          },
          'act': {
            'type': 'Button',
            'props': {'label': 'Undo'},
            'actions': [
              {
                'trigger': {'type': 'event', 'event': 'onPressed'},
                'actions': [
                  {'type': 'componentEvent', 'event': 'onAction'},
                ],
              },
            ],
          },
        },
      }, catalog: _shadowed);
    });
  });

  group('the document line', () {
    // One spelling of what the API reads two ways (design 22, 4.9): the print
    // reads back as the document in the parser's spelling.
    test('an empty parameter list, a preview with no values, a document with no schema', () {
      final doc = {
        'id': 'Rule',
        'roots': ['rule'],
        'widget': {'type': 'Rule', 'props': <Object?>[]},
        'previews': [
          {
            'name': 'Default',
            'size': [300, 2],
          },
        ],
        'nodes': {
          'rule': {'type': 'divider'},
        },
      };
      final printed = printNotation(doc, catalog: standardCatalog);
      expect(printed, isNot(contains('document {')), reason: printed);
      expect(printed, contains('document schema=2'));
      expect(printed, contains('  preview "Default" 300x2'));
      final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(doc)).document;
      expect(back['schema'], 2);
      expect((back['widget']! as Map).containsKey('props'), isFalse);
      expect(back['previews'], [
        {
          'name': 'Default',
          'size': [300, 2],
          'props': <String, Object?>{},
        },
      ]);
    });

    test('a type written on a state line is kept: a Pages does not widen it', () {
      final doc = _roundTrip('''
state page:integer=0
Column
  Pages @page h=100
    Text "a"
''', same: ['state page:integer=0']);
      expect(((doc['variables']! as Map)['screen'] as List).single, containsPair('type', 'integer'));
    });
  });

  group('a component a word shadows, its fields', () {
    final badge = standardCatalog +
        Catalog.fromJson({
          'id': 'ds',
          'widgets': [
            {
              'type': 'Badge',
              'props': [
                {'key': 'label', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': '', 'required': true},
              ],
            },
          ],
        });

    test('named with type=, a width on it is its own (no cell around it)', () {
      final doc = _roundTrip('Row\n  Badge#count "3" type=Badge w=24', catalog: badge, same: ['  Badge#count "3" type=Badge w=24']);
      expect((_nodes(doc)['row1']! as Map)['children'], ['count']);
    });

    test('a main field with a value and a binding: the value by its path, the binding by its key', () {
      final doc = _roundTrip('state n="5"\nRow\n  Badge#count type=Badge props.label="0" label={n}',
          catalog: badge, same: ['  Badge#count type=Badge label={n} props.label="0"']);
      expect((_nodes(doc)['count']! as Map)['props'], containsPair('label', '0'));
    });
  });

  group('components two design systems declare differently', () {
    test('a code sample\'s braces in a string are text, and print as written', () {
      const code = "import { Beacon } from '@beacon/sdk';\n\nconst beacon = new Beacon({\n  writeKey: 'KEY',\n});";
      final doc = _roundTrip('Column\n  Text#t ${jsonEncode(code)}', same: ['  Text#t ${jsonEncode(code)}']);
      expect(((_nodes(doc)['t']! as Map)['props'] as Map)['text'], code);
    });
  });

  group('structure', () {
    test('Pages prints as Pages: its page is no line, each line shown at its position', () {
      final doc = _roundTrip('''
state page=0
Column
  Pages @page h=160
    Text "a"
    Text "b"
''', same: ['    Text "a" h=fill', '    Text "b" h=fill']);
      expect(_nodes(doc).keys, contains('pageView1Page'));
      final printed = printNotation(doc, catalog: standardCatalog);
      expect(printed, contains('  Pages h=160 @page'));
      expect(printed, isNot(contains('pageView1Page')));
      expect(printed, isNot(contains('index ==')));
    });

    test('Pages over data prints its each', () {
      _roundTrip('''
state items=["a","b"]
Column
  Pages#pages h=100
    each item in items
      Column#page
        Text "{item}"
''', same: ['    each item in items', '      Column#page h=fill']);
    });

    test('PageView (pageView), the catalog name, is the node as written: its lines are its children', () {
      final doc = _roundTrip('''
state items=["a","b"]
Column
  pageView#raw h=50
    each item in items
      Text#t "{item}"
''', same: ['  PageView#raw h=50', '    each item in items', '      Text#t "{item}"']);
      expect((_nodes(doc)['raw']! as Map)['children'], ['t']);
      expect(((_nodes(doc)['raw']! as Map)['bind'] as Map)['data'], r'${items}');
      expect((_nodes(doc)['raw']! as Map)['props'], isNot(contains('itemCount')));
      final two = parseNotation('Column\n  pageView#v h=50\n    Text#a "a"\n    Text#b "b"', catalog: standardCatalog).document;
      expect((_nodes(two)['v']! as Map)['children'], ['a', 'b']);
      expect(jsonEncode(_nodes(two)['a']), isNot(contains('visible')));
    });
  });

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

    test('in a definition, an action naming a body id with hyphens names the use\'s', () {
      final r = parseNotation('''
Column
  Cell#cell
define Cell
  Column#box gap=4
    Input#cell-input "x" onSubmit={focus #cell-input; scroll box}
    Button "Edit" onTap={focus cell-input}
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      final nodes = _nodes(r.document);
      expect(nodes.keys, contains('cell-input_cell'));
      expect(jsonEncode(nodes['cell-input_cell']), contains('"node":"cell-input_cell"'));
      expect(jsonEncode(nodes['filledButton1']), contains('"node":"cell-input_cell"'));
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
