// Values, the third wave (docs/design/22-notation-parity.md, section 4.8):
// each form is written, expanded, checked in the document, printed with no
// `{…}` tail, and read back as the same document.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

/// [text] expanded, with no issue.
Json _expand(String text) {
  final r = parseNotation(text, catalog: standardCatalog);
  expect(r.issues.map((i) => i.message), isEmpty, reason: text);
  return r.document;
}

/// The node with [id] in [doc].
Json _node(Json doc, String id) => readMap(readMap(doc['nodes'])![id])!;

/// The value at [path] of [node]: `bind.x` is the binding of path x.
Object? _at(Json node, String path) {
  if (path.startsWith('bind.')) return readMap(node['bind'])?[path.substring(5)];
  Object? v = node;
  for (final part in path.split('.')) {
    v = v is Map ? v[part] : null;
  }
  return v;
}

/// [doc] printed with no tail, containing each of [words], and read back as
/// [doc].
void _exact(Json doc, List<String> words) {
  final printed = printNotation(doc, catalog: standardCatalog);
  for (final w in words) {
    expect(printed, contains(w), reason: printed);
  }
  expect(printed, isNot(contains(' {"')), reason: printed);
  expect(printed, isNot(contains('document {')), reason: printed);
  final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(doc)).document;
  expect(jsonEncode(_sorted(back)), jsonEncode(_sorted(doc)), reason: printed);
}

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

/// Writes [text], expects [path] of node [id] to be [value], and the
/// document to print back exactly, with [words] in the print.
void _says(String text, String id, String path, Object? value, List<String> words) {
  final doc = _expand(text);
  expect(_at(_node(doc, id), path), value, reason: '$path of $text');
  _exact(doc, words);
}

void main() {
  group(r'a quoted string with ${= …} in it is kept as written', () {
    test('a formula that is only a name, bound', () {
      _says(r'Text#t "x" color="${= theme.colors.ink}"', 't', 'bind.props.style.color', r'${= theme.colors.ink}', [r'color="${= theme.colors.ink}"']);
    });
    test("a validator holds its expression: it runs on the text typed", () {
      _says(r'''Input#name "Name" validator="${= trim(value) == '' ? 'Enter your name.' : ''}"''', 'name', 'props.validator',
          r"${= trim(value) == '' ? 'Enter your name.' : ''}", [r'validator="${= trim(value)']);
      final doc = _expand(r'''Input#name "Name" validator="${= trim(value) == '' ? 'Enter your name.' : ''}"''');
      expect(readMap(_node(doc, 'name')['bind'])?['props.validator'], isNull);
    });
    test("a text's own text holds it; braces around the quotes bind it", () {
      _says(r'''Text#t "${= upper('a')}"''', 't', 'props.text', r"${= upper('a')}", const []);
      _says('state ok=true\nText#t "Saved" text={"\${= ok ? \'Saved\' : \'Not saved\'}"}', 't', 'bind.props.text', r"${= ok ? 'Saved' : 'Not saved'}", ['text=']);
    });
    test(r'a $ before a read is still a dollar where no ${= is written (models write prices so)', () {
      final doc = _expand('state qty=2\nText#t "Total \${qty*12}"');
      expect(_at(_node(doc, 't'), 'props.text'), r'Total $${= qty*12}');
      _exact(doc, const []);
    });
    test('a string that reads data is bound on a field that does not work it out itself', () {
      final doc = _expand('state lane="todo"\nColumn#c dropTarget.key="{lane}"');
      expect(_at(_node(doc, 'c'), 'dropTarget.key'), r'${lane}', reason: 'a drop target works its key out for each drop');
      expect(readMap(_node(doc, 'c')['bind'])?['dropTarget.key'], isNull);
    });
  });

  group('bindings that had no form', () {
    test('selected bound to a plain read', () {
      _says('state on=true\nColumn\n  Row#r selected="{on}"\n    Text "a"', 'r', 'bind.selected', r'${on}', ['selected="{on}"']);
    });
    test('an element of a list by its index reads as a path', () {
      _says('state kpis=[{"value":"1"}]\nText#t "{kpis[0].value}"', 't', 'props.text', r'${kpis[0].value}', ['"{kpis[0].value}"']);
      _says('state kpis=[{"value":"1"}]\nText#t "x" text={kpis[0].value}', 't', 'bind.props.text', r'${kpis[0].value}', ['text={kpis[0].value}']);
    });
    test('node.disabled: the disabled state where enabled= is the prop', () {
      _says('state on=true\nInput#f "Name" enabled={on} node.disabled={!on}', 'f', 'bind.disabled', r'${= !on}', ['enabled={on}', 'node.disabled={!on}']);
    });
    test('a value and a binding of a behavior field', () {
      final doc = _expand('state budget="small"\nRow#r radioGroup.groupValue={budget} node.radioGroup.groupValue=small');
      expect(_at(_node(doc, 'r'), 'radioGroup.groupValue'), 'small');
      expect(_at(_node(doc, 'r'), 'bind.radioGroup.groupValue'), r'${budget}');
      _exact(doc, ['node.radioGroup.groupValue=small']);
    });
  });

  group('a section whole', () {
    test('props={}: an empty record of props', () {
      final doc = _expand('Column\n  Row#r props={}\n    Text "a"');
      expect(_node(doc, 'r')['props'], <String, Object?>{});
      _exact(doc, ['props={}']);
    });
    test('props=null: no props at all', () {
      final doc = _expand('Row#r props=null');
      expect(_node(doc, 'r').containsKey('props'), isFalse);
    });
  });

  group('a size written by its full path is that size exactly', () {
    test('a column of a fixed height with a text under it', () {
      final doc = _expand('Column\n  Column#box layout.height=108 fill=#FFEEEEEE\n    Text "a"');
      expect(readMap(_node(doc, 'box')['layout'])?['height'], 108);
      expect(readMap(_node(doc, 'box')['layout'])?['constraints'], isNull);
      _exact(doc, ['layout.height=108']);
    });
    test('h= stays a least height there', () {
      final doc = _expand('Column\n  Column#box h=108\n    Text "a"');
      expect(readMap(_node(doc, 'box')['layout'])?['height'], {'hug': 108});
    });
    test("a spacer's height in a column", () {
      final doc = _expand('Column\n  Text "a"\n  Spacer#s grow layout.height=hug\n  Text "b"');
      expect(readMap(_node(doc, 's')['layout'])?['height'], {'hug': 0});
      _exact(doc, ['layout.height=hug']);
    });
    test('a fit beside a bound size', () {
      final doc = _expand('state w=100\nStack#s w={w} layout.width=fill h=40');
      expect(readMap(_node(doc, 's')['layout'])?['width'], {'fill': 0});
      expect(_at(_node(doc, 's'), 'bind.layout.width'), r'${w}');
      _exact(doc, ['layout.width=']);
    });
    test('a rule word by its full path patches that path only', () {
      final doc = _expand('Row#plans h=40 scrollable=false scrollDirection=horizontal maxMobile.props.scrollable=true\n  Text "a"');
      expect((_node(doc, 'plans')['media'] as List).single, {
        'maxWidth': 'mobile',
        'patch': {
          'props': {'scrollable': true},
        },
      });
      _exact(doc, ['maxMobile.props.scrollable=true']);
    });
  });

  group('data the catalog now declares', () {
    test("widthFactor, a share of the parent's room, bound", () {
      final doc = _expand('state pct=40\nStack h=8\n  box#fill h=8 fill=#FF2563EB widthFactor={pct / 100}');
      expect(_at(_node(doc, 'fill'), 'bind.layout.widthFactor'), r'${= pct / 100}');
      _exact(doc, ['widthFactor={pct / 100}']);
      expect(LayoutFields.all.map((f) => f.key), containsAll(['widthFactor', 'heightFactor']));
    });
  });
}
