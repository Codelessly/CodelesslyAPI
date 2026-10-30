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
      expect(annotated.length, 54);
      for (final path in annotated) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    },
  );
  test('shared scrolling descriptors retain actual mixin fields on applicable nodes', () {
    final catalog = jsonDecode(
      File('lib/src/schema/generated/dpp_descriptors.json').readAsStringSync(),
    ) as Map;
    final descriptors = (catalog['descriptors'] as List).cast<Map>();
    const fields = {
      'isScrollable',
      'scrollDirection',
      'reverse',
      'primary',
      'physics',
      'keyboardDismissBehavior',
      'useFlutterListView',
      'shouldAlwaysScroll',
    };
    for (final nodeType in {
      'canvas',
      'frame',
      'gridView',
      'listView',
      'pageView',
      'row',
      'column',
      'tabBar',
    }) {
      final scrolling = descriptors
          .where(
            (descriptor) =>
                descriptor['nodeType'] == nodeType &&
                fields.contains(descriptor['fieldPath']),
          )
          .toList();
      expect(
        scrolling.map((descriptor) => descriptor['fieldPath']).toSet(),
        fields,
      );
      expect(
        scrolling.every((descriptor) => descriptor['group'] == 'Scrolling'),
        isTrue,
      );
      expect(
        scrolling.every((descriptor) => descriptor['flutterName'] == null),
        isTrue,
      );
    }
    expect(
      descriptors
          .where((descriptor) => descriptor['nodeType'] == 'spacer')
          .map((descriptor) => descriptor['fieldPath']),
      contains('flex'),
    );
  });

  test('shared Frame DPP paths and nested InkWell source fields are exact', () {
    final data = jsonDecode(
      File('lib/src/schema/generated/dpp_descriptors.json').readAsStringSync(),
    ) as Map;
    final descriptors = (data['descriptors'] as List).cast<Map>();
    final paths = descriptors
        .where((descriptor) => descriptor['nodeType'] == 'frame')
        .map((descriptor) => descriptor['fieldPath'])
        .toSet();
    expect(
      paths,
      containsAll({
        'visible',
        'enabled',
        'clipsContent',
        'opacity',
        'horizontalFit',
        'verticalFit',
        'transition.durationMillis',
        'pulse.minOpacity',
        'pulse.durationMillis',
        'inkWell.overlayColor',
        'inkWell.highlightColor',
        'inkWell.splashColor',
        'inkWell.hoverColor',
        'inkWell.focusColor',
      }),
    );
  });

  test(
    'migrated inspector descriptor paths stay canonical and editor-only',
    () {
      final registry = jsonDecode(
        File('lib/src/schema/generated/dpp_descriptors.json')
            .readAsStringSync(),
      ) as Map;
      final descriptors = (registry['descriptors'] as List).cast<Map>();
      final pairs = {
        for (final descriptor in descriptors)
          (descriptor['nodeType'] as String, descriptor['fieldPath'] as String),
      };
      for (final buttonType in const {
        'elevatedButton',
        'filledButton',
        'outlinedButton',
        'textButton',
        'iconButton',
      }) {
        expect(pairs, contains((buttonType, 'properties.enabled')));
        final field = descriptors.singleWhere(
          (descriptor) =>
              descriptor['nodeType'] == buttonType &&
              descriptor['fieldPath'] == 'properties.enabled',
        );
        expect(field['flutterName'], isNull);
      }
      for (final path in const {
        'fills',
        'strokes',
        'strokeWeight',
        'dashPattern',
        'cornerRadius',
        'cornerSmoothing',
        'margin',
        'padding',
        'effects',
      }) {
        expect(pairs, contains(('frame', path)), reason: path);
      }
      for (final path in const {
        'textMixedProps',
        'textAlignHorizontal',
        'overflow',
        'tabularFigures',
      }) {
        expect(pairs, contains(('text', path)), reason: path);
      }
      for (final path in const {
        'fontSize',
        'fontFamily',
        'textAlign',
        'rotationDegrees',
        'rootColor',
        'basicBoxLocal.width',
        'fills.imageTransform',
        'cornerRadius.tl',
      }) {
        expect(
          pairs.where((pair) => pair.$2 == path),
          isEmpty,
          reason:
              'No invented alias, editor geometry, or array-item path: $path',
        );
      }
      final catalog = jsonDecode(
        File('lib/src/schema/generated/codelessly_a2ui_catalog.json')
            .readAsStringSync(),
      ) as Map;
      final stack = catalog['components']['Stack'] as Map;
      final fields =
          ((stack['allOf'] as List).last as Map)['properties'] as Map;
      for (final path in const {
        'margin',
        'padding',
        'fills',
        'strokes',
        'effects',
      }) {
        expect(
          fields.containsKey(path),
          isFalse,
          reason: 'No new BASIC Stack field $path',
        );
      }
    },
  );

  test('editor-only scrolling metadata leaves BASIC Stack wire unchanged', () {
    final catalog = jsonDecode(
      File('lib/src/schema/generated/codelessly_a2ui_catalog.json')
          .readAsStringSync(),
    ) as Map;
    final components = catalog['components'] as Map;
    final stack = components['Stack'] as Map;
    final shape = (stack['allOf'] as List).last as Map;
    final fields = shape['properties'] as Map;
    expect(fields.keys, containsAll(['component', 'children']));
    expect(fields.keys, isNot(contains('isScrollable')));
    expect(fields.keys, isNot(contains('scrollDirection')));
    expect(fields.keys, isNot(contains('opacity')));
  });

  test('DateTimeInput is correctly cataloged as a custom widget', () {
    final fragments = jsonDecode(
      File('lib/src/api/nodes/date_time_input_node.flutter_catalog.json')
          .readAsStringSync(),
    ) as Map;
    expect((fragments['DateTimeInputNode'] as Map)['family'], 'codelessly');
  });

  for (final entry in {
    'text_node': ('TextNode', 'Text', 3),
    'button_node': ('ElevatedButtonNode', 'ElevatedButton', 1),
    'row_column_node': ('RowNode', 'Row', 11),
    'divider_node': ('DividerNode', 'Divider', 4),
    'badge_node': ('BadgeNode', 'Badge', 3),
    'app_bar_node': ('AppBarNode', 'AppBar', 4),
    'checkbox_node': ('CheckboxNode', 'Checkbox', 4),
    'slider_node': ('SliderNode', 'Slider', 5),
    'list_view_node': ('ListViewNode', 'ListView', 10),
    'switch_node': ('SwitchNode', 'Switch', 4),
    'frame_node': ('FrameNode', 'Stack', 9),
    'grid_view_node': ('GridViewNode', 'GridView', 10),
    'page_view_node': ('PageViewNode', 'PageView', 12),
    'chip_node': ('ChipNode', 'ChoiceChip', 5),
    'radio_node': ('RadioNode', 'Radio', 5),
    'text_field_node': ('TextFieldNode', 'TextField', 8),
    'dropdown_node': ('DropdownNode', 'DropdownButton', 6),
    'segmented_button_node': ('SegmentedButtonNode', 'SegmentedButton', 3),
    'tab_bar_node': ('TabBarNode', 'TabBar', 9),
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
    'date_time_input_node': ('DateTimeInputNode', 'DateTimeInput', 7),
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
    'modal_node': ('ModalNode', 'CodelesslyModal', 3),
    'tabs_node': ('TabsNode', 'CodelesslyTabs', 2),
    'canvas_node': ('CanvasNode', 'CodelesslyCanvas', 10),
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
      expect(
        (node['dpp'] as List).length,
        greaterThanOrEqualTo(entry.value.$3),
      );
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
        expect(
          ((output['ColumnNode'] as Map)['dpp'] as List).length,
          greaterThanOrEqualTo(11),
        );
      }
      expect(
        ((node['a2ui'] as Map)['components'] as Map).keys,
        contains(entry.value.$2),
      );
      expect(
        (node['testMatrix'] as List).length,
        greaterThanOrEqualTo(entry.value.$3),
      );
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
    expect(catalog.components.length, 70);
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
    expect((mappings['mappings'] as Map)['Video']['bridgeStatus'], 'ready');
    expect(
      (mappings['mappings'] as Map)['AudioPlayer']['nodeType'],
      'audioPlayer',
    );
    expect(
      (mappings['mappings'] as Map)['AudioPlayer']['bridgeStatus'],
      'ready',
    );
    expect((mappings['mappings'] as Map)['Modal']['nodeType'], 'modal');
    expect((mappings['mappings'] as Map)['Modal']['bridgeStatus'], 'ready');
    expect((mappings['mappings'] as Map)['Tabs']['nodeType'], 'tabs');
    expect((mappings['mappings'] as Map)['Tabs']['bridgeStatus'], 'ready');
    expect(
      (mappings['mappings'] as Map)['DateTimeInput']['nodeType'],
      'dateTimeInput',
    );
    expect(
      (mappings['mappings'] as Map)['DateTimeInput']['bridgeStatus'],
      'ready',
    );
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
    expect(
      (node['dpp'] as List).cast<Map>().map((field) => field['fieldPath']),
      contains('data'),
    );
    expect(
      ((node['jsonSchema'] as Map)['properties'] as Map).keys,
      contains('data'),
    );
    expect(node['drift'], isEmpty);
  });
}
