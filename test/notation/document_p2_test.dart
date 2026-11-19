// The document family's second pass (docs/design/22, section 4.5): each form
// is written, expanded, checked in the document, printed, and read back.
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

Map<String, Object?> _node(Map<String, Object?> doc, String id) => ((doc['nodes'] as Map)[id] as Map).cast<String, Object?>();

/// [text] expanded with no issue; printed, it has every line of [same] and
/// no `{…}` tail or `document {…}` line, and reads back to the same document.
Map<String, Object?> _roundTrip(String text, {List<String> same = const []}) {
  final r = parseNotation(text, catalog: standardCatalog);
  expect(r.issues.map((i) => i.message), isEmpty, reason: text);
  final doc = r.document;
  final printed = printNotation(doc, catalog: standardCatalog);
  final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(doc));
  expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(doc)), reason: printed);
  final lines = printed.split('\n').map((l) => l.trimRight()).toList();
  for (final l in same) {
    expect(lines, contains(l), reason: printed);
  }
  expect(printed, isNot(contains(' {"')), reason: printed);
  expect(printed, isNot(contains('\ndocument {')), reason: printed);
  return doc;
}

/// [doc] printed: no tail and no `document {…}` line, and every line of [same].
String _prints(Map<String, Object?> doc, {List<String> same = const []}) {
  final printed = printNotation(doc, catalog: standardCatalog);
  final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(doc));
  expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(doc)), reason: printed);
  expect(printed, isNot(contains(' {"')), reason: printed);
  expect(printed, isNot(contains('document {')), reason: printed);
  final lines = printed.split('\n').map((l) => l.trimRight()).toList();
  for (final l in same) {
    expect(lines, contains(l), reason: printed);
  }
  return printed;
}

void main() {
  group('the document line', () {
    test('id and the scope of the state lines', () {
      final doc = _roundTrip('document id="checkout" scope=page_variables\nstate n=1\nColumn\n  Text "{n}"', same: ['document id="checkout" scope=page_variables']);
      expect(doc['id'], 'checkout');
      expect(doc['schema'], 3);
      expect((doc['variables'] as Map).keys, ['page_variables']);
    });

    test('a page with other canvases keeps its state on its own canvas: scope=<its id>', () {
      final doc = _roundTrip('document scope=screen\nstate n=1\nColumn\n  Text "{n}"\nCanvas#about "About"\n  Column\n    Text "about"', same: ['document scope=screen']);
      expect((doc['variables'] as Map).keys, ['screen']);
    });

    test('a word it does not take is said', () {
      final r = parseNotation('document id="x" flavor=1\nColumn', catalog: standardCatalog);
      expect(r.issues.map((i) => i.message).join(), contains('A document line takes'));
      // Schema 3 is the only one a document line names.
      expect(parseNotation('document schema=2\nColumn', catalog: standardCatalog).issues.map((i) => i.message).join(), contains('A document line takes'));
      expect(parseNotation('document schema=3\nColumn', catalog: standardCatalog).issues, isEmpty);
    });
  });

  test('what the screen does on load reads as a word of its canvas line and prints as an on line', () {
    final doc = _roundTrip('state n=0\non load={n=1}\nColumn\n  Text "{n}"', same: ['on load={n=1}']);
    expect(((_node(doc, 'screen')['actions'] as List).single as Map)['trigger'], {'type': 'load'});
  });

  group('slots', () {
    test('slot lines put a node in a slot of a plain node', () {
      final doc = _roundTrip('Column\n  ListTile#t\n    slot title\n      Text#a "Hello"\n    slot trailing\n      Icon#i "chevron_right"', same: ['    slot title', '    slot trailing']);
      expect(_node(doc, 't')['slots'], {'title': 'a', 'trailing': 'i'});
      expect(_node(doc, 't')['children'], isNull);
    });

    test('a slot the node does not have, and a second line in one, are said', () {
      expect(parseNotation('Column\n  ListTile\n    slot body\n      Text "x"', catalog: standardCatalog).issues.single.message, contains('Its slots: '));
      expect(parseNotation('Column\n  ListTile\n    slot title\n      Text "x"\n      Text "y"', catalog: standardCatalog).issues.single.message, contains('A slot holds one node'));
    });
  });

  group('lists', () {
    test('a list of its own line repeats its one child over data, with an each under it', () {
      final doc = _roundTrip('state rows=[{"n":"a"}]\nColumn\n  ListView#l h=300 scrollDirection=horizontal\n    each r in rows\n      Row#t gap=4\n        Text "{r.n}"',
          same: ['  ListView#l h=300 scrollDirection=horizontal', '    each item in rows']);
      expect(_node(doc, 'l')['children'], ['t']);
      expect((_node(doc, 'l')['bind'] as Map)['data'], r'${rows}');
    });

    test('stagger= is the each line\'s', () {
      final doc = _roundTrip('state rows=[1,2]\nColumn\n  each r in rows stagger=80\n    Text "{r}"', same: ['  each item in rows stagger=80']);
      expect((_node(doc, 'text1')['bind'] as Map)['animations[0].delay'], r'${= index*80}');
    });
  });

  test('a parameter\'s type no Flutter name says is its JSON', () {
    final doc = _roundTrip('component Counter\n  param count:{"kind":"number","flutter":"int"}=0\nRow#r\n  Text "x"',
        same: ['  param count:{"kind":"number","flutter":"int"}=0']);
    expect(((doc['widget'] as Map)['props'] as List).single, {
      'key': 'count',
      'type': {'kind': 'number', 'flutter': 'int'},
      'default': 0,
    });
  });

  test('a component call\'s optional variable given by its tail declares no variable of its own', () {
    final cat = standardCatalog +
        Catalog.fromJson({
          'id': 't',
          'widgets': [
            {
              'type': 'Flag',
              'children': 'none',
              'props': [
                {'key': 'on', 'type': {'kind': 'variable', 'of': {'kind': 'boolean'}}, 'default': ''},
              ],
            },
          ],
        });
    final r = Catalog.run(cat, () => parseNotation('state open=false\nColumn\n  Flag#f {"bind":{"props.on":"\${open}"}}', catalog: cat));
    expect(((r.document['variables'] as Map)['screen'] as List).map((v) => (v as Map)['name']), ['open']);
    final bare = Catalog.run(cat, () => parseNotation('Column\n  Flag#f', catalog: cat));
    expect(((bare.document['variables'] as Map)['screen'] as List).map((v) => (v as Map)['name']), ['f_on']);
  });

  group('the catalog\'s chart names are the node as written', () {
    test('barChart and lineChart add no height or color; BarChart and LineChart do', () {
      final plain = parseNotation('Column\n  barChart#b\n  lineChart#l', catalog: standardCatalog).document;
      expect((_node(plain, 'b')['layout'] as Map)['height'], {'hug': 0});
      expect((_node(plain, 'b')['props'] as Map?)?['color'], isNull);
      expect((_node(plain, 'l')['props'] as Map?)?['lineColor'], isNull);
      final ours = parseNotation('Column\n  BarChart#b\n  LineChart#l', catalog: standardCatalog).document;
      expect((_node(ours, 'b')['layout'] as Map)['height'], 140);
      expect((_node(ours, 'l')['props'] as Map)['lineColor'], isNotNull);
    });

    test('a document\'s bar chart prints back with no tail', () {
      _prints({
        'schema': 3,
        'roots': ['screen'],
        'nodes': {
          'screen': {'type': 'canvas', 'slots': {'body': 'column1'}, 'layout': {'width': 390, 'height': {'hug': 0}}, 'decoration': {'fills': [{'color': '#FFFFFFFF'}]}},
          'column1': {'type': 'column', 'children': ['b'], 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}, 'props': {'crossAxisAlignment': 'start'}},
          'b': {
            'type': 'barChart',
            'layout': {'width': {'fill': 0}, 'height': 200},
            'props': {'values': [3, 5, 2]},
          },
        },
      }, same: ['  barChart#b h=200 values=[3,5,2]']);
    });
  });

  test('a record block replaces what the line\'s tail gave, merged again or not', () {
    final r = parseNotation('Column\n  box#n {"animations":[{"id":"a","duration":100}]}\n    animation#b duration=300', catalog: standardCatalog);
    expect([for (final a in _node(r.document, 'n')['animations'] as List) (a as Map)['id']], ['a', 'b']);
  });

  test('a node a tail takes out of its parent is not in the document', () {
    final r = parseNotation('Column\n  Badge#b "x" {"children":null}', catalog: standardCatalog);
    expect((r.document['nodes'] as Map).keys, isNot(contains('text1')));
  });
}
