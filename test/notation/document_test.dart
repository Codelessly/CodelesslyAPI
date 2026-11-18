// The document family of notation parity (docs/design/22, section 4.5):
// what is not a node's own line. Each form is written, expanded, checked in
// the document, printed, and printed back as written.
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

/// [text] expanded with no issue; its print reads back to the same document
/// and holds every line of [same] as written.
Map<String, Object?> _roundTrip(String text, {NotationOptions options = const NotationOptions(), List<String> same = const []}) {
  final r = parseNotation(text, catalog: standardCatalog, options: options);
  expect(r.issues.map((i) => i.message), isEmpty, reason: text);
  final doc = r.document;
  String? whole;
  final printed = printNotation(doc, catalog: standardCatalog, whole: (why) => whole = why);
  expect(whole, isNull, reason: printed);
  final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(doc));
  expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(doc)), reason: printed);
  final lines = printed.split('\n');
  for (final l in same) {
    expect(lines, contains(l), reason: printed);
  }
  return doc;
}

List<Object?> _vars(Map<String, Object?> doc, [String scope = 'screen']) => (doc['variables']! as Map)[scope] as List;

void main() {
  group('state', () {
    test('a type the value does not say, no value, a formula, a function, saved', () {
      final doc = _roundTrip('''
state count:decimal=2
state note:text
state price=2
state total:decimal={price*count}
state clamp(v):decimal={min(1, max(0, v))}
state draft="" saved
state accent:color="#FF2563EB"
Column
  Text "x"
''', same: [
        'state count:decimal=2',
        'state note:text',
        'state price=2',
        'state total:decimal={price*count}',
        'state clamp(v):decimal={min(1, max(0, v))}',
        'state draft="" saved',
        'state accent:color="#FF2563EB"',
      ]);
      expect(_vars(doc), [
        {'name': 'count', 'type': 'decimal', 'value': 2},
        {'name': 'note', 'type': 'text'},
        {'name': 'price', 'type': 'integer', 'value': 2},
        {'name': 'total', 'type': 'decimal', 'formula': 'price*count'},
        {'name': 'clamp', 'type': 'decimal', 'formula': 'min(1, max(0, v))', 'parameters': ['v']},
        {'name': 'draft', 'type': 'text', 'value': '', 'persist': true},
        {'name': 'accent', 'type': 'color', 'value': '#FF2563EB'},
      ]);
    });

    test('a typed formula keeps its single quotes; a type the document has not is said', () {
      final doc = _roundTrip('''
state status:text={coalesce(find(rows, 'id', sel), 'none')}
Column
  Text "x"
''', same: ["state status:text={coalesce(find(rows, 'id', sel), 'none')}"]);
      expect((_vars(doc).single as Map)['formula'], "coalesce(find(rows, 'id', sel), 'none')");
      final r = parseNotation('state n:float=1\nColumn\n  Text "x"', catalog: standardCatalog);
      expect(r.issues.single.message, contains('integer, text, decimal'));
    });
  });

  group('the tree', () {
    test('siblings that share a condition are under an if, the rest of it an else', () {
      final doc = _roundTrip('''
state open=true
Column gap=8
  if open
    Text "One"
    Text "Two"
  else
    Text "Closed"
''', same: ['  if open', '    Text "One"', '  else', '    Text "Closed"']);
      final nodes = doc['nodes']! as Map;
      expect((nodes['text1'] as Map)['bind'], {'visible': r'${= open}'});
      expect((nodes['text3'] as Map)['bind'], {'visible': r'${= !(open)}'});
    });

    test('a list over data is an each; an each in an each names the outer element apart', () {
      final doc = _roundTrip('''
state groups=[{"name":"A","rows":[{"t":"x"}]}]
Column
  each g in groups
    Text.strong "Group"
    each r in g.rows
      Text "Row"
''', same: ['  each row in groups', '    each item in item.rows']);
      final nodes = doc['nodes']! as Map;
      expect((nodes['listView1'] as Map)['bind'], {'data': r'${groups}'});
      // The inner list is read where the outer element is `item`.
      expect((nodes['listView2'] as Map)['bind'], {'data': r'${item.rows}'});
    });

    test("an each's words: reorder, follow with its height", () {
      _roundTrip('''
state rows=["a","b"]
state log=["x"]
Column
  each item in rows reorder
    Text "Row"
  each item in log follow h=180
    Text "Line"
''', same: ['  each item in rows reorder', '  each item in log follow h=180']);
    });

    test('an id the parser gives is left out; any other is written, with its parts joined by _', () {
      final doc = _roundTrip('''
Column
  Text "a"
  Text#m_title "b"
  Text "c"
''', same: ['Column', '  Text "a"', '  Text#m_title "b"', '  Text "c"']);
      expect((doc['nodes']! as Map).keys, containsAll(['text1', 'm_title', 'text2']));
    });
  });

  group('canvases', () {
    test("the screen's own fields are a canvas line", () {
      final doc = _roundTrip('''
canvas "Trip" path="/trip" h=844 fill=#FFF9FAFB props.blockBack=true
Column
  Text "x"
''', same: ['canvas "Trip" path="/trip" h=844 fill=#FFF9FAFB props.blockBack=true']);
      final screen = (doc['nodes']! as Map)['screen'] as Map;
      expect(screen['name'], 'Trip');
      expect(screen['path'], '/trip');
      expect((screen['layout'] as Map)['height'], 844);
      expect((screen['decoration'] as Map)['fills'], [
        {'color': '#FFF9FAFB'},
      ]);
      expect((screen['props'] as Map)['blockBack'], true);
    });

    test('another canvas is a Canvas#id block, its tree under it', () {
      final doc = _roundTrip('''
Column
  Button "About" onTap={go about}
Canvas#about "About" path="about"
  Column#aboutCol
    Text "About us"
''', same: ['Canvas#about "About" path="about"', '  Column#aboutCol', '    Text "About us"']);
      expect(doc['roots'], ['screen', 'about']);
      final about = (doc['nodes']! as Map)['about'] as Map;
      expect(about['type'], 'canvas');
      expect(about['slots'], {'body': 'aboutCol'});
      expect(about['name'], 'About');
    });

    test('canvas none: a tree with no canvas, its root the first line', () {
      final doc = _roundTrip('''
canvas none
Row#board gap=4
  Text "x"
''', same: ['canvas none', 'Row#board gap=4']);
      expect(doc['roots'], ['board']);
      expect((doc['nodes']! as Map).containsKey('screen'), isFalse);
    });
  });

  group('a component', () {
    const head = '''
component StatusPill "A short status, colored by its tone."
  param label="Active" required doc="What it says."
  param tone:neutral|success|danger="neutral" doc="Its color."
  param count:int=0
  param value:ValueNotifier<bool>=false
  param tags=["a","b"]
  param ratio=0.5
  event onPressed
  event onChanged:String doc="The new label."
  slot trailing
  preview "Default" 120x28 label="Active" tone="success"''';

    test('its head is its declaration and previews; its tree has no canvas', () {
      final doc = _roundTrip('''
$head
Row#pill gap=4
  Text#pillLabel "Active"
''', same: head.split('\n'));
      expect(doc['id'], 'StatusPill');
      expect(doc['roots'], ['pill']);
      expect((doc['nodes']! as Map).keys, ['pill', 'pillLabel']);
      expect(doc['previews'], [
        {
          'name': 'Default',
          'size': [120, 28],
          'props': {'label': 'Active', 'tone': 'success'},
        },
      ]);
      final widget = doc['widget']! as Map;
      expect(widget['type'], 'StatusPill');
      expect(widget['doc'], 'A short status, colored by its tone.');
      expect(widget['slots'], ['trailing']);
      expect(widget['events'], [
        {'key': 'onPressed'},
        {
          'key': 'onChanged',
          'payload': {'kind': 'string', 'flutter': 'String'},
          'doc': 'The new label.',
        },
      ]);
      final props = {for (final p in widget['props'] as List) (p as Map)['key']: p};
      expect(props['label'], {
        'key': 'label',
        'type': {'kind': 'string', 'flutter': 'String'},
        'default': 'Active',
        'required': true,
        'doc': 'What it says.',
      });
      expect((props['tone'] as Map)['type'], {
        'kind': 'enumeration',
        'flutter': 'String',
        'values': ['neutral', 'success', 'danger'],
      });
      expect((props['count'] as Map)['type'], {'kind': 'integer', 'flutter': 'int'});
      expect((props['value'] as Map)['type'], {
        'kind': 'variable',
        'of': {'kind': 'boolean', 'flutter': 'bool'},
      });
      expect((props['tags'] as Map)['type'], {
        'kind': 'list',
        'flutter': 'List<String>',
        'item': {'kind': 'string', 'flutter': 'String'},
      });
      expect((props['ratio'] as Map)['type'], {'kind': 'number', 'flutter': 'double'});
    });

    test('its variables are its root\x27s; a head line it does not take is said', () {
      final doc = _roundTrip('''
component Counter
  param start=0
state n:decimal=0
Row#counter
  Text "n"
''', same: ['component Counter', '  param start=0', 'state n:decimal=0']);
      expect((doc['variables']! as Map).keys, ['counter']);
      final r = parseNotation('component Counter\n  param start:float=0\nRow\n  Text "n"', catalog: standardCatalog);
      expect(r.issues.single.message, contains('No type "float"'));
    });
  });
}
