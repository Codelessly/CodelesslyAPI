import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

void main() {
  for (final entry in {
    'text_node': ('TextNode', 'Text', 3),
    'button_node': ('ButtonNode', 'ElevatedButton', 2),
    'row_column_node': ('RowColumnNode', 'Row', 3),
  }.entries) {
    test('${entry.key} metadata has four consistent projections', () {
      final output = jsonDecode(File('lib/src/api/nodes/${entry.key}.flutter_catalog.json').readAsStringSync()) as Map;
      final node = output[entry.value.$1] as Map;
      expect(node['widget'], entry.value.$2);
      final properties = (node['jsonSchema'] as Map)['properties'] as Map;
      expect(properties.length, entry.value.$3);
      expect((node['dpp'] as List).length, properties.length);
      expect(((node['a2ui'] as Map)['components'] as Map).keys, contains(entry.value.$2));
      expect((node['testMatrix'] as List).length, properties.length);
      expect((node['jsonSchema'] as Map)['\$schema'], 'https://json-schema.org/draft/2020-12/schema');
    });
  }
  test('Text data points at actual characters storage', () {
    final node = (jsonDecode(File('lib/src/api/nodes/text_node.flutter_catalog.json').readAsStringSync()) as Map)['TextNode'] as Map;
    expect(((node['dpp'] as List).first as Map)['field'], 'characters');
    expect(((node['jsonSchema'] as Map)['required'] as List), contains('data'));
  });
}
