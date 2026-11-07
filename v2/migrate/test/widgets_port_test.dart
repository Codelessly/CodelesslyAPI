// v1 features master added to text, values, rows and columns, lists and
// the new widget types: each maps to its v2 field and nothing is left in
// the node's `v1` leftovers.
import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

import 'inputs_test.dart' show page, props;

Map<String, Object?> node(Map<String, Object?> v2, String id) => ((v2['nodes'] as Map)[id] as Map).cast();

/// Unmapped keys reported for [id].
List<String> unmapped(MigrationReport r, String id) =>
    [for (final k in r.unmapped.keys) if (k.split('.').last != 'createdTimestamp') k];

void main() {
  group('text and values', () {
    test('font features, leading distribution and unit spellings', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        't': {
          'type': 'text',
          'data': 'Hi 10',
          'fontFeatures': 'lnum, liga=0',
          'tabularFigures': true,
          'textMixedProps': [
            {'start': 0, 'end': 5, 'fontSize': 20, 'fontName': {'family': 'Inter'},
             'lineHeight': {'value': 150, 'unit': 'Percent', 'leadingDistribution': 'even'},
             'letterSpacing': {'value': 10, 'unit': '%'}},
          ],
        },
      }), report: report);
      final p = props(v2, 't');
      expect(p['style'], {'tabularFigures': true, 'fontFeatures': ['lnum', 'liga=0']});
      final style = (p['runs'] as List).single['style'] as Map;
      expect(style['height'], 1.5);
      expect(style['leadingDistribution'], 'even');
      expect(style['letterSpacing'], 2);
      expect(unmapped(report, 't'), isEmpty);
    });

    test('input decoration: icon padding, always-visible affixes, padding with the border', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        'f': {
          'type': 'textField',
          'properties': {
            'decoration': {
              'suffixText': 'kWh',
              'affixesAlwaysVisible': true,
              'paddingIncludesBorder': true,
              'prefixIconPadding': [12, 0, 8, 0],
              'suffixIconPadding': [4, 4, 4, 4],
            },
          },
        },
      }), report: report);
      final d = props(v2, 'f')['decoration'] as Map;
      expect(d['affixesAlwaysVisible'], true);
      expect(d['paddingIncludesBorder'], true);
      expect(d['prefixIconPadding'], [12, 0, 8, 0]);
      expect(d['suffixIconPadding'], 4);
      expect(unmapped(report, 'f'), isEmpty);
    });

    test('an icon image given as imageUrl', () {
      final v2 = migrateDocument(page({
        'i': {
          'type': 'icon',
          'properties': {'icon': {'type': 'image', 'imageUrl': 'https://x/i.png', 'show': true}},
        },
      }));
      expect((props(v2, 'i')['icon'] as Map)['image'], 'https://x/i.png');
    });
  });
}
