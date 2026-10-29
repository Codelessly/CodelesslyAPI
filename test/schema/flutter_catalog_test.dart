import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:a2ui_core/a2ui_core.dart';

void main() {
  for (final entry in {
    'text_node': ('TextNode', 'Text', 3),
    'button_node': ('ButtonNode', 'ElevatedButton', 1),
    'row_column_node': ('RowColumnNode', 'Row', 3),
    'divider_node': ('DividerNode', 'Divider', 4),
    'badge_node': ('BadgeNode', 'Badge', 3),
    'app_bar_node': ('AppBarNode', 'AppBar', 4),
    'checkbox_node': ('CheckboxNode', 'Checkbox', 4),
    'slider_node': ('SliderNode', 'Slider', 5),
    'list_view_node': ('ListViewNode', 'ListView', 2),
    'switch_node': ('SwitchNode', 'Switch', 4),
  }.entries) {
    test('${entry.key} metadata has four consistent projections', () {
      final output = jsonDecode(File('lib/src/api/nodes/${entry.key}.flutter_catalog.json').readAsStringSync()) as Map;
      final node = output[entry.value.$1] as Map;
      expect(node['widget'], entry.value.$2);
      final properties = (node['jsonSchema'] as Map)['properties'] as Map;
      expect((node['dpp'] as List).length, entry.value.$3);
      expect(properties, isNotEmpty);
      if (entry.key == 'button_node') {
        expect((((properties['properties'] as Map)['properties'] as Map)).keys, contains('label'));
      }
      expect(((node['a2ui'] as Map)['components'] as Map).keys, contains(entry.value.$2));
      expect((node['testMatrix'] as List).length, entry.value.$3);
      expect((node['jsonSchema'] as Map)['\$schema'], 'https://json-schema.org/draft/2020-12/schema');
    });
  }
  test('a2ui_core accepts merged catalog identifier and components', () {
    final raw = jsonDecode(File('catalog/codelessly_catalog_v1.json').readAsStringSync()) as Map<String, dynamic>;
    final catalog = Catalog.fromJson(raw);
    expect(catalog.id, 'https://codelessly.com/a2ui/catalogs/codelessly/v1/catalog.json');
    expect(catalog.components.keys, containsAll(['Text', 'Row', 'ElevatedButton', 'Divider', 'Badge', 'AppBar', 'Checkbox', 'Slider', 'ListView', 'Switch']));
  });
  test('Text data points at actual characters storage', () {
    final node = (jsonDecode(File('lib/src/api/nodes/text_node.flutter_catalog.json').readAsStringSync()) as Map)['TextNode'] as Map;
    expect(((node['dpp'] as List).first as Map)['fieldPath'], 'characters');
    expect(((node['jsonSchema'] as Map)['properties'] as Map).keys, contains('characters'));
    expect(((node['drift'] as List).first as Map)['flutterName'], 'data');
    expect(((node['drift'] as List).first as Map)['fieldPath'], 'characters');
  });
}
