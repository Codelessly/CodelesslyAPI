// The closing pass of notation parity (docs/design/22): the last gaps the
// measure found and four bugs found by reading the reference as a writer.
// Each form is written, expanded, printed, and printed back.
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
String _prints(Map<String, Object?> doc, {List<String> same = const []}) {
  String? whole;
  final printed = printNotation(doc, catalog: standardCatalog, whole: (why) => whole = why);
  expect(whole, isNull, reason: printed);
  expect(printed, isNot(contains(' {"')), reason: printed);
  expect(printed, isNot(contains('document {')), reason: printed);
  final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(doc));
  expect(back.issues.map((i) => i.message), isEmpty, reason: printed);
  expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(doc)), reason: printed);
  final lines = printed.split('\n');
  for (final l in same) {
    expect(lines, contains(l), reason: printed);
  }
  return printed;
}

/// [text] expanded with no issue at [width], printed in words and read back.
Map<String, Object?> _roundTrip(String text, {double width = 390, List<String> same = const []}) {
  final r = parseNotation(text, catalog: standardCatalog, options: NotationOptions(width: width));
  expect(r.issues.map((i) => i.message), isEmpty, reason: text);
  _prints(r.document, same: same);
  return r.document;
}

Map<String, Object?> _nodes(Map<String, Object?> doc) => (doc['nodes']! as Map).cast<String, Object?>();

void main() {
  group('a Grid at another width', () {
    test('tablet.cols=2 is a rule of the grid its each makes, and prints back', () {
      final doc = _roundTrip('state items=[1,2,3]\nGrid cols=4 tablet.cols=2 phone.cols=1\n  each item in items\n    Text "{item}"', same: [
        'Grid cols=4 tablet.cols=2 phone.cols=1',
      ]);
      expect(_nodes(doc)['gridView1'], containsPair('media', [
        {'maxWidth': 1023, 'patch': {'props': {'crossAxisCount': 2}}},
        {'maxWidth': 699, 'patch': {'props': {'crossAxisCount': 1}}},
      ]));
    });

    test('over cells written one by one, or not a number, it is said', () {
      final rows = parseNotation('Grid cols=3 tablet.cols=2\n  Text "a"\n  Text "b"');
      expect(rows.issues.map((i) => i.message), [contains('cells an each repeats')]);
      final word = parseNotation('state items=[1]\nGrid cols=3 tablet.cols=two\n  each item in items\n    Text "{item}"');
      expect(word.issues.map((i) => i.message), [contains('a number from 1 to 24: tablet.cols=2')]);
    });
  });

  test("a state's one stroke prints as border=", () {
    _roundTrip('Row#r pad=8 focused.border=#FF2563EB hovered.border=accent\n  Text "a"', same: [
      'Row#r pad=8 focused.border=#FF2563EB hovered.border=accent',
    ]);
    // The stroke's JSON still reads as the same state.
    final json = parseNotation('Row#r pad=8 focused.strokes=[{"color":"#FF2563EB"}]\n  Text "a"').document;
    final word = parseNotation('Row#r pad=8 focused.border=#FF2563EB\n  Text "a"').document;
    expect(jsonEncode(_sorted(json)), jsonEncode(_sorted(word)));
  });

  group('a Dialog', () {
    test('prints as its head, its open as the verb', () {
      _roundTrip('Column\n  Button "Open" onTap={open confirm}\nDialog#confirm "Delete file?"\n  Text "This cannot be undone."\n  Button "Delete" onTap={close}',
          same: ['  Button "Open" onTap={open confirm}', 'Dialog#confirm "Delete file?"', '  Text "This cannot be undone."']);
    });

    test('with no title, its own width and padding', () {
      _roundTrip('state n=1\nColumn\n  Button "Open" onTap={open note}\nDialog#note w=360 pad=16\n  Text "No title {n}"',
          same: ['Dialog#note w=360 pad=16']);
    });

    test('another canvas prints its width as a whole number', () {
      final doc = parseNotation('Column\n  Text "Home"\nCanvas#about "About" w=480\n  Text "About us"').document;
      final printed = printNotation(doc, catalog: standardCatalog);
      expect(printed, contains('Canvas#about "About" w=480'));
      expect(printed, isNot(contains('480.0')));
    });
  });

  test("in an App with a drawer, a NavItem's onTap is the verb", () {
    final printed = printNotation(
        parseNotation('state tab="home"\nApp\n  Sidebar\n    NavItem "Home" icon="home" onTap={tab="home"}\n  Main\n    Text "x"',
                options: const NotationOptions(width: 1280))
            .document,
        catalog: standardCatalog);
    expect(printed, contains('onTap={tab=home}'));
    expect(printed, isNot(contains('setVariable')));
  });

  group('a width written by its full path', () {
    const row = 'Column\n  Row gap=12\n    Text "Northwind" w=200\n    Text "Active" w=200\n    Text "Pro" w=200';
    test('w= in a row of columns wider than the page is a share of it', () {
      final layout = (_nodes(parseNotation(row).document)['text1']! as Map)['layout'];
      expect(layout, containsPair('flex', 200));
    });

    test('layout.width= keeps the width, and prints so', () {
      final doc = _roundTrip(row.replaceAll(' w=200', ' layout.width=200'), same: ['    Text "Northwind" layout.width=200']);
      expect((_nodes(doc)['text1']! as Map)['layout'], isNot(contains('flex')));
    });

    test('layout.flex= keeps the flex beside them', () {
      final doc = _roundTrip('Column\n  Row gap=12\n    Text "Name" layout.flex=1\n    Text "Northwind" layout.width=200\n    Text "Active" layout.width=200\n    Text "Pro" w=200\n    Text "Plan" w=200');
      expect((_nodes(doc)['text1']! as Map)['layout'], containsPair('flex', 1));
    });
  });

  test("the document's conditions are a JSON value on the document line", () {
    const conditions = {
      'plans': [
        {
          'id': 'billing',
          'branches': [
            {
              'when': {'left': r'${annual}', 'op': 'isTrue'},
              'set': [
                {'node': 'price', 'path': 'props.text', 'value': r'$120 / year'},
              ],
            },
          ],
        },
      ],
    };
    final doc = _roundTrip('document conditions=${jsonEncode(conditions)}\nstate annual=false\nColumn\n  Text#price "\$12 / month"');
    expect(doc['conditions'], conditions);
    final bad = parseNotation('document conditions=yes\nText "x"');
    expect(bad.issues.map((i) => i.message), [contains('conditions={…}')]);
  });

  test('a page view with no props prints as Pages with props=null', () {
    final doc = parseNotation('state page=0\nstate images=["a","b"]\nColumn\n  Pages h=280 @page\n    each item in images\n      Image "{item}"').document;
    final nodes = _nodes(doc);
    (nodes['pageView1']! as Map).remove('props');
    final printed = _prints(doc);
    expect(printed, contains('Pages h=280 props=null @page'));
  });
}
