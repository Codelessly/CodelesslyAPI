import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:a2ui_core/a2ui_core.dart';

void main() {
  test(
    'every cataloged concrete API node has a generated metadata fragment',
    () {
      final source = Directory('lib/src/api/nodes')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('_node.dart'));
      final annotated = source
          .where((file) => file.readAsStringSync().contains('@FlutterNode('))
          .map(
            (file) => file.path.replaceFirst('.dart', '.flutter_catalog.json'),
          );
      expect(annotated.length, 50);
      for (final path in annotated) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    },
  );
  for (final entry in {
    'text_node': ('TextNode', 'Text', 3),
    'button_node': ('ElevatedButtonNode', 'ElevatedButton', 1),
    'row_column_node': ('RowNode', 'Row', 3),
    'divider_node': ('DividerNode', 'Divider', 4),
    'badge_node': ('BadgeNode', 'Badge', 3),
    'app_bar_node': ('AppBarNode', 'AppBar', 4),
    'checkbox_node': ('CheckboxNode', 'Checkbox', 4),
    'slider_node': ('SliderNode', 'Slider', 5),
    'list_view_node': ('ListViewNode', 'ListView', 2),
    'switch_node': ('SwitchNode', 'Switch', 4),
    'frame_node': ('FrameNode', 'Stack', 1),
    'grid_view_node': ('GridViewNode', 'GridView', 2),
    'page_view_node': ('PageViewNode', 'PageView', 4),
    'chip_node': ('ChipNode', 'ChoiceChip', 5),
    'radio_node': ('RadioNode', 'Radio', 5),
    'text_field_node': ('TextFieldNode', 'TextField', 8),
    'dropdown_node': ('DropdownNode', 'DropdownButton', 6),
    'segmented_button_node': ('SegmentedButtonNode', 'SegmentedButton', 3),
    'tab_bar_node': ('TabBarNode', 'TabBar', 1),
    'list_tile_node': ('ListTileNode', 'ListTile', 8),
    'expansion_tile_node': ('ExpansionTileNode', 'ExpansionTile', 4),
    'floating_action_button_node': (
      'FloatingActionButtonNode',
      'FloatingActionButton',
      4,
    ),
    'chart_node': ('ChartNode', 'CodelesslyChartSeries', 1),
    'bar_chart_node': ('BarChartNode', 'CodelesslyBarChart', 1),
    'line_chart_node': ('LineChartNode', 'CodelesslyLineChart', 1),
    'plot_chart_node': ('PlotChartNode', 'CodelesslyPlotChart', 1),
    'gauge_node': ('GaugeNode', 'CodelesslyRadialGauge', 1),
    'gauge_meter_node': ('GaugeMeterNode', 'CodelesslyGaugeMeter', 1),
    'signature_node': ('SignatureNode', 'CodelesslySignature', 2),
    'signature_normalized_node': (
      'SignatureNormalizedNode',
      'CodelesslyNormalizedSignature',
      3,
    ),
    'web_view_node': ('WebViewNode', 'CodelesslyWebView', 1),
    'embedded_video_node': ('EmbeddedVideoNode', 'CodelesslyEmbeddedVideo', 2),
    'video_node': ('VideoNode', 'CodelesslyVideo', 3),
    'date_picker_node': ('DatePickerNode', 'CalendarDatePicker', 3),
    'time_picker_node': ('TimePickerNode', 'TimePickerDialog', 1),
    'auto_placeholder_node': (
      'AutoPlaceholderNode',
      'CodelesslyAutoPlaceholder',
      2,
    ),
    'freeform_placeholder_node': (
      'FreeformPlaceholderNode',
      'CodelesslyFreeformPlaceholder',
      1,
    ),
    'placeholder_node': ('PlaceholderNode', 'CodelesslyPlaceholder', 2),
    'single_placeholder_node': (
      'SinglePlaceholderNode',
      'CodelesslySinglePlaceholder',
      2,
    ),
    'external_component_node': (
      'ExternalComponentNode',
      'CodelesslyExternalComponent',
      1,
    ),
    'variance_node': ('VarianceNode', 'CodelesslyVariance', 2),
    'accordion_node': ('AccordionNode', 'CodelesslyAccordion', 2),
    'canvas_node': ('CanvasNode', 'CodelesslyCanvas', 2),
    'progressbar_node': ('ProgressBarNode', 'CodelesslyProgressBar', 2),
    'root_node': ('RootNode', 'CodelesslyRoot', 1),
    'icon_node': ('IconNode', 'CodelesslyIcon', 1),
    'loading_indicator_node': (
      'LoadingIndicatorNode',
      'CodelesslyLoadingIndicator',
      1,
    ),
    'navigation_bar_node': ('NavigationBarNode', 'NavigationBar', 1),
    'rectangle_node': ('RectangleNode', 'CodelesslyRectangle', 1),
    'spacer_node': ('SpacerNode', 'Spacer', 1),
  }.entries) {
    test('${entry.key} metadata has four consistent projections', () {
      final output = jsonDecode(
        File('lib/src/api/nodes/${entry.key}.flutter_catalog.json')
            .readAsStringSync(),
      ) as Map;
      final node = output[entry.value.$1] as Map;
      expect(node['widget'], entry.value.$2);
      final properties = (node['jsonSchema'] as Map)['properties'] as Map;
      expect((node['dpp'] as List).length, entry.value.$3);
      expect(properties, isNotEmpty);
      if (entry.key == 'button_node') {
        expect(
          (((properties['properties'] as Map)['properties'] as Map)).keys,
          contains('label'),
        );
        final label = (node['dpp'] as List).cast<Map>().singleWhere(
          (descriptor) => descriptor['fieldPath'] == 'properties.label',
        );
        expect(label['flutterParam'], isNull);
        expect(label['flutterName'], isNull);
        expect(label['note'], "label text rendered as the button's child Text");
        final component =
            ((node['a2ui'] as Map)['components'] as Map)['ElevatedButton']
                as Map;
        final fields =
            (((component['allOf'] as List)[1] as Map)['properties']
                    as Map)['properties']
                as Map;
        expect(fields['properties'], contains('label'));
        expect(fields['properties'], isNot(contains('child')));
        for (final (className, widget, field) in [
          ('TextButtonNode', 'TextButton', 'label'),
          ('OutlinedButtonNode', 'OutlinedButton', 'label'),
          ('FilledButtonNode', 'FilledButton', 'label'),
          ('IconButtonNode', 'IconButton', 'icon'),
        ]) {
          final variant = output[className] as Map;
          expect(variant['widget'], widget);
          expect(
            (((variant['jsonSchema'] as Map)['properties'] as Map)['properties']
                as Map)['properties'],
            contains(field),
          );
          expect((variant['dpp'] as List), isNotEmpty);
        }
      }
      if (entry.key == 'row_column_node') {
        expect((output['ColumnNode'] as Map)['widget'], 'Column');
        expect(((output['ColumnNode'] as Map)['dpp'] as List).length, 3);
      }
      expect(
        ((node['a2ui'] as Map)['components'] as Map).keys,
        contains(entry.value.$2),
      );
      expect((node['testMatrix'] as List).length, entry.value.$3);
      expect(
        (node['jsonSchema'] as Map)['\$schema'],
        'https://json-schema.org/draft/2020-12/schema',
      );
    });
  }
  test('a2ui_core accepts merged catalog identifier and components', () {
    final raw = jsonDecode(
      File('lib/src/schema/generated/codelessly_a2ui_catalog.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final catalog = Catalog.fromJson(raw);
    expect(
      catalog.id,
      'https://codelessly.com/a2ui/catalogs/codelessly/v1/catalog.json',
    );
    expect(
      catalog.components.keys,
      containsAll([
        'Text',
        'Button',
        'Row',
        'Column',
        'List',
        'ElevatedButton',
        'Divider',
        'Badge',
        'AppBar',
        'Checkbox',
        'Slider',
        'ListView',
        'Switch',
        'Stack',
        'GridView',
        'PageView',
        'ChoiceChip',
        'Radio',
        'TextField',
        'DropdownButton',
        'SegmentedButton',
        'TabBar',
        'ListTile',
        'ExpansionTile',
        'FloatingActionButton',
        'CodelesslyChartSeries',
        'CodelesslyBarChart',
        'CodelesslyLineChart',
        'CodelesslyPlotChart',
        'CodelesslyRadialGauge',
        'CodelesslyGaugeMeter',
        'CodelesslySignature',
        'CodelesslyNormalizedSignature',
        'CodelesslyWebView',
        'CodelesslyEmbeddedVideo',
        'CodelesslyVideo',
        'CodelesslyAutoPlaceholder',
        'CodelesslyFreeformPlaceholder',
        'CodelesslyPlaceholder',
        'CodelesslySinglePlaceholder',
        'CodelesslyExternalComponent',
        'CodelesslyVariance',
        'CodelesslyAccordion',
        'CodelesslyCanvas',
        'CodelesslyProgressBar',
        'CodelesslyRoot',
        'CodelesslyIcon',
        'CodelesslyLoadingIndicator',
        'NavigationBar',
        'CodelesslyRectangle',
        'Spacer',
      ]),
    );
    final basic = BasicCatalog.v0_9().toJson()['components'] as Map;
    final generated = raw['components'] as Map;
    expect(basic.length, 18);
    for (final entry in basic.entries) {
      expect(
        generated[entry.key],
        entry.value,
        reason: '${entry.key} must retain every official BASIC property',
      );
    }
    expect(catalog.components.length, 67);
    expect(
      ((raw[r'$defs'] as Map)['anyComponent']['oneOf'] as List).length,
      catalog.components.length,
    );
    for (final name in ['TextField', 'Button']) {
      final schema = generated[name] as Map;
      expect(
        (schema['allOf'] as List).whereType<Map>().any(
          (part) => (part[r'$ref'] as String?)?.endsWith('/Checkable') ?? false,
        ),
        isTrue,
        reason: '$name must include BASIC checks',
      );
    }
    final mappings = jsonDecode(
      File('lib/src/schema/generated/basic_node_mappings.json')
          .readAsStringSync(),
    ) as Map;
    expect((mappings['mappings'] as Map).keys.toSet(), basic.keys.toSet());
    expect((mappings['mappings'] as Map)['Text']['nodeType'], 'text');
    expect(
      (mappings['mappings'] as Map)['ChoicePicker']['nodeType'],
      'segmentedButton',
    );
    expect((mappings['mappings'] as Map)['Video']['nodeType'], 'video');
    for (final name in ['Tabs', 'DateTimeInput', 'AudioPlayer', 'Modal']) {
      expect(
        (mappings['mappings'] as Map)[name]['nodeType'],
        isNull,
        reason: '$name needs W3 renderer before runtime advertisement',
      );
    }
    final text = generated['Text'] as Map;
    final textProps =
        ((text['allOf'] as List).last as Map)['properties'] as Map;
    expect(textProps.keys, contains('text'));
    expect(textProps.keys, isNot(contains('characters')));
    final button = generated['Button'] as Map;
    expect(
      (((button['allOf'] as List).last as Map)['properties'] as Map).keys,
      containsAll(['child', 'action', 'variant']),
    );
    for (final name in ['Row', 'Column']) {
      final flex = generated[name] as Map;
      expect(
        (((flex['allOf'] as List).last as Map)['properties'] as Map).keys,
        containsAll(['children', 'justify', 'align']),
      );
    }
  });
  test('Text data points at canonical data storage without naming drift', () {
    final node =
        (jsonDecode(
              File('lib/src/api/nodes/text_node.flutter_catalog.json')
                  .readAsStringSync(),
            ) as Map)['TextNode']
            as Map;
    expect(((node['dpp'] as List).first as Map)['fieldPath'], 'data');
    expect(
      ((node['jsonSchema'] as Map)['properties'] as Map).keys,
      contains('data'),
    );
    expect(node['drift'], isEmpty);
  });
}
