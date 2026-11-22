// The space under a page's bar, a grid of picture tiles on a phone, and a
// DataTable in the looks of the theme's Table.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

NotationResult _parse(String text, [NotationOptions options = const NotationOptions(width: 1440)]) =>
    parseNotation(text, catalog: standardCatalog, options: withTestWords(options));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id]! as Map).cast<String, Object?>();

void main() {
  group('the first Section under a page\'s bar', () {
    test('with the page\'s headline in it (a hero) keeps a section\'s space above it', () {
      for (final head in ['Text.heading1 "Fill every room"', 'Text.pageTitle "Fill every room"', 'Text "Fill every room" size=56']) {
        final r = _parse('Page\n  Nav\n    Text "Brand"\n  Section#first\n    $head\n  Section#second\n    Text "More"\n');
        expect(r.issues, isEmpty);
        expect((_node(r, 'first')['layout']! as Map)['padding'], [24, 64, 24, 64], reason: head);
      }
    });

    test('with no headline (a list, a form: a page that is a tool) starts half of it down', () {
      final r = _parse('Page\n  Nav\n    Text "Brand"\n  Section#first\n    Text.heading2 "Orders"\n    Text "A list"\n  Section#second\n    Text "More"\n');
      expect(r.issues, isEmpty);
      expect((_node(r, 'first')['layout']! as Map)['padding'], [24, 32, 24, 64]);
      expect((_node(r, 'second')['layout']! as Map)['padding'], [24, 32, 24, 64], reason: 'a Section after a Section, as before');
    });

    test('a ground of its own, a padding of its own, or no bar above it: as written', () {
      expect((_node(_parse('Page\n  Nav\n    Text "Brand"\n  Section#first tint\n    Text "A list"\n'), 'first')['layout']! as Map)['padding'], [24, 64, 24, 64]);
      expect((_node(_parse('Page\n  Nav\n    Text "Brand"\n  Section#first pad=[24,48,24,48]\n    Text "A list"\n'), 'first')['layout']! as Map)['padding'], [24, 48, 24, 48]);
      expect((_node(_parse('Page\n  Section#first\n    Text "A list"\n'), 'first')['layout']! as Map)['padding'], [24, 64, 24, 64]);
    });

    test('as it arrives: the space is patched once the section is read', () {
      final r = parseNotation('Page\n  Nav\n    Text "Brand"\n  Section#first\n    Text "A list"\n',
          catalog: standardCatalog, options: withTestWords(const NotationOptions(width: 1440)));
      expect(jsonEncode(r.document), contains('"padding":[24,32.0,24,64]'));
    });
  });

  group('a Grid of one tile repeated, five or more across', () {
    Object? colsAt(NotationResult r, num width) {
      final grid = (r.document['nodes'] as Map).values.cast<Map>().firstWhere((n) => n['type'] == 'gridView');
      Object? cols = (grid['props'] as Map)['crossAxisCount'];
      for (final m in (grid['media'] as List? ?? const []).cast<Map>()) {
        if ((m['maxWidth'] as num) >= width) cols = (((m['patch'] as Map)['props'] as Map?)?['crossAxisCount']) ?? cols;
      }
      return cols;
    }

    const state = 'state photos:list=[{"a":"#FF112233","b":"#FF445566"}]\n';
    test('a tile of a set height (a photo) folds: three across a tablet, two across a phone', () {
      final r = _parse('${state}Column w=fill\n  Grid cols=5 gap=2\n    each p in photos\n      Box h=130 gradient=[p.a,p.b]\n');
      expect(r.issues, isEmpty);
      expect([colsAt(r, 1440), colsAt(r, 834), colsAt(r, 390)], [5, 3, 2]);
    });

    test('a small thing (a dot, a day\'s number) keeps its columns', () {
      final r = _parse('${state}Column w=fill\n  Grid cols=5 gap=2\n    each p in photos\n      Box w=24 h=24 fill=#FF112233\n');
      expect([colsAt(r, 1440), colsAt(r, 390)], [5, 5]);
    });
  });

  group('a DataTable', () {
    const table = 'state rows:list=[{"name":"Ada"}]\nColumn w=fill\n  DataTable#t rows={rows} columns=[{"key":"name","label":"Name"}]\n';
    test('under a theme that has a table\'s header band: its rows, header and lines are the Table\'s', () {
      final r = _parse(table, NotationOptions.fromTheme(const {
        'colors': {'band': '#FFFAFAFB', 'line': '#FFE4E4E7', 'primaryBorder': '#FFE4E4E7'},
        'textStyles': {
          'body': {'fontSize': 13},
          'columnHead': {'fontSize': 12, 'fontWeight': 500},
        },
      }, named: true, width: 1440));
      expect(r.issues, isEmpty);
      final props = (_node(r, 't')['props']! as Map);
      expect(props['rowHeight'], 44);
      expect(props['headerHeight'], 40);
      expect(props['headerColor'], 'band');
      expect(props['gridLineColor'], 'line');
      // Rules under its rows only, as the theme's Table has.
      expect(props['columnLines'], false);
      expect(jsonEncode(_node(r, 'tHeader')['props']), contains('columnHead'));
    });

    test('under that theme, columnLines=true keeps the lines between its columns', () {
      final r = _parse(table.replaceFirst('DataTable#t', 'DataTable#t columnLines=true'), NotationOptions.fromTheme(const {
        'colors': {'band': '#FFFAFAFB', 'line': '#FFE4E4E7', 'primaryBorder': '#FFE4E4E7'},
        'textStyles': {
          'body': {'fontSize': 13},
          'columnHead': {'fontSize': 12, 'fontWeight': 500},
        },
      }, named: true, width: 1440));
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect((_node(r, 't')['props']! as Map)['columnLines'], true);
    });

    test('with no such theme: as before', () {
      final props = (_node(_parse(table), 't')['props']! as Map);
      expect(props['rowHeight'], 48);
      expect(props.containsKey('headerColor'), isFalse);
      expect(props.containsKey('columnLines'), isFalse, reason: 'a table draws both directions unless it says otherwise');
    });

    test('columnLines is a tableView prop, true unless said', () {
      expect(TableViewProps.columnLines.defaultValue, isTrue);
      expect(TableViewProps.spec.props, contains(TableViewProps.columnLines));
    });
  });
}
