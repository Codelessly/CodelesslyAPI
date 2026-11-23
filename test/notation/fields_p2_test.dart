// A node's line, second wave (docs/design/22-notation-parity.md, section
// 4.2): every word the fields family added is written, expanded, checked in
// the document, printed, and read back as the same line.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

final _ids = RegExp(r'^(\s*[A-Za-z][A-Za-z0-9.]*)#[A-Za-z_][A-Za-z0-9_]*', multiLine: true);

/// [text] expanded with [catalog], with no issue.
Json _expand(String text, [Catalog? catalog]) {
  final r = parseNotation(text, catalog: catalog ?? standardCatalog);
  expect(r.issues, isEmpty, reason: text);
  return r.document;
}

/// The last node of [type] in [doc].
Json _node(Json doc, String type) => readMap(doc['nodes'])!.values.map(readMap).nonNulls.lastWhere((n) => n['type'] == type);

/// The value at [path] of [node]: `bind.x` is the binding of path x.
Object? _at(Json node, String path) {
  if (path.startsWith('bind.')) return readMap(node['bind'])?[path.substring(5)];
  Object? v = node;
  for (final part in path.split('.')) {
    v = v is Map ? v[part] : null;
  }
  return v;
}

/// Writes [text], expands it, expects [path] of its last [type] node to be
/// [value], prints the document and gets [text] back.
void _says(String text, String type, String path, Object? value, {Catalog? catalog, bool absent = false}) {
  final doc = _expand(text, catalog);
  final node = _node(doc, type);
  if (absent) {
    expect(jsonEncode(node), isNot(contains('"${path.split('.').last}"')), reason: '$path of $text');
  } else {
    expect(_at(node, path), value, reason: '$path of $text');
  }
  expect(printNotation(doc, catalog: catalog ?? standardCatalog).replaceAllMapped(_ids, (m) => m[1]!), text);
}

/// [doc] printed with no tail, containing [word], and read back as [doc].
void _exact(Json doc, String word) {
  final printed = printNotation(doc, catalog: standardCatalog);
  expect(printed, contains(word));
  expect(printed, isNot(contains(' {"')), reason: printed);
  final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(doc)).document;
  expect(jsonEncode(_sorted(back)), jsonEncode(_sorted(doc)), reason: printed);
}

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

/// A page with [nodes] under its body column `col` (children [kids]).
Json _page(List<String> kids, Map<String, Json> nodes) => {
      'schema': 3,
      'roots': ['screen'],
      'nodes': {
        'screen': {'type': 'canvas', 'slots': {'body': 'col'}, 'layout': {'width': 390, 'height': 800}, 'decoration': {'fills': [{'color': '#FFFFFFFF'}]}},
        'col': {'type': 'column', 'children': kids, 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}, 'props': {'crossAxisAlignment': 'start'}},
        ...nodes,
      },
    };

void main() {
  group('a field the node has not is key=null', () {
    test('the alignment a row is given, left out', () => _says('Column\n  Row crossAxisAlignment=null', 'row', 'props', null));
    test('a slot with no size at all', () => _says('Column\n  Slot w=null h=null', 'slot', 'layout', null));
    // A named style takes no body size under it, so size=null is not needed
    // to leave the size out: the line written with it reads as the one without.
    test('a text style\'s size, left out', () {
      _says('Column\n  Text "x" from=caption', 'text', 'props.style.fontSize', null, absent: true);
      expect(jsonEncode(_expand('Column\n  Text "x" size=null from=caption')), jsonEncode(_expand('Column\n  Text "x" from=caption')));
    });
  });

  group('an expression is kept as written, its quotes too', () {
    test('a condition with single quotes', () => _says("state t=\"a\"\nColumn\n  Text \"x\" visible={t == 'a'}", 'text', 'bind.visible', r"${= t == 'a'}"));
    test('a choice of colors', () => _says("state on=false\nColumn\n  box w=40 h=40 fill={on ? 'primary' : 'surface'}", 'box', 'bind.decoration.fills[0].color', r"${= on ? 'primary' : 'surface'}"));
    test(r'a \n written in it', () => _says("state code=\"a\"\nColumn\n  Text text={join(split(code, '\\n'), '\\n')}", 'text', 'bind.props.text', r"${= join(split(code, '\n'), '\n')}"));
    test('an if line\'s condition', () {
      final doc = _expand("state t=\"a\"\nColumn\n  if t == 'a'\n    Text \"x\"\n    Text \"y\"");
      expect(_at(_node(doc, 'text'), 'bind.visible'), r"${= t == 'a'}");
      expect(printNotation(doc, catalog: standardCatalog), contains("if t == 'a'"));
    });
  });

  group('bindings by their keys', () {
    test('a list\'s data that is no each', () => _says('state items=[]\nColumn\n  ListView data={items}', 'listView', 'bind.data', r'${items}'));
    test('enabled= on a box is its disabled state', () => _says('state on=true\nColumn\n  Row enabled={on}', 'row', 'bind.disabled', r'${= !on}'));
    test('enabled= with more than a name', () => _says('state a=true\nstate b=true\nColumn\n  Row enabled={a && b}', 'row', 'bind.disabled', r'${= !(a && b)}'));
    test('a size bound beside the number it starts at', () => _says('state n=24\nColumn\n  box w=40 layout.height=24 h={n}','box', 'layout.height', 24));
    test('a stroke\'s field by its path', () => _says('state x=0\nColumn\n  box w=40 h=40 border=#FF000000 strokes[0].visible={x > 0}', 'box', 'bind.decoration.strokes[0].visible', r'${= x > 0}'));
  });

  group('a design system\'s component a word of the notation shadows: type=', () {
    final catalog = standardCatalog +
        Catalog.fromJson({
          'id': 'ds',
          'widgets': [
            {
              'type': 'Button',
              'props': [
                {'key': 'label', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': 'OK'},
                {'key': 'variant', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': 'primary'},
              ],
            },
          ],
        });
    test('Button type=Button is the component', () => _says('Column\n  Button "Save" type=Button variant=ghost', 'Button', 'props.variant', 'ghost', catalog: catalog));
    test('Button alone is still the notation\'s', () {
      final doc = _expand('Column\n  Button "Save"', catalog);
      expect(_node(doc, 'filledButton')['type'], 'filledButton');
    });
  });

  group('what a word adds yields to what the line gives', () {
    test('a box\'s selected look given in its tail is kept', () {
      final doc = _expand('state on=false\nColumn\n  Row#r selected={on} {"states":{"selected":{"r":{"opacity":0.5}}}}');
      expect(_node(doc, 'row')['states'], {
        'selected': {
          'r': {'opacity': 0.5},
        },
      });
    });
    test('a fill with its design size stays in a grid\'s cell', () {
      _exact(
        _page(['grid'], {
          'grid': {
            'type': 'gridView',
            'children': ['cell'],
            'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
            'props': {'crossAxisCount': 2, 'shrinkWrapRows': true},
          },
          'cell': {'type': 'box', 'layout': {'width': {'fill': 140}, 'height': 40}},
        }),
        'w={"fill":140}',
      );
    });
  });

  group('a field by its own name', () {
    test('a row with no props at all', () {
      _exact(
        _page(['r'], {
          'r': {'type': 'row', 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}},
        }),
        'crossAxisAlignment=null',
      );
    });
    test('a list\'s spacing by the type\'s own key', () {
      _exact(
        _page(['g'], {
          'g': {'type': 'gridView', 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}, 'props': {'crossAxisCount': 3, 'shrinkWrapRows': true}},
        }),
        'cols=3',
      );
    });
  });

  group('the types written by their catalog names', () {
    test('a grid over data is written GridView, the catalog\'s name, and reads as it', () {
      final printed = printNotation(_expand('Column\n  GridView'), catalog: standardCatalog);
      expect(printed.split('\n').any((l) => l.trim().startsWith('GridView')), isTrue, reason: printed);
      expect(_node(_expand(printed), 'gridView')['type'], 'gridView');
    });

    for (final type in const ['box', 'badge']) {
      test('$type is written $type and reads as it', () {
        final doc = _expand('Column\n  $type');
        final printed = printNotation(doc, catalog: standardCatalog);
        expect(printed.split('\n').any((l) => l.trim().startsWith(type)), isTrue, reason: printed);
        expect(printed, isNot(contains(' {"')), reason: printed);
        expect(_node(_expand(printed), type)['type'], type);
      });
    }
  });
}
