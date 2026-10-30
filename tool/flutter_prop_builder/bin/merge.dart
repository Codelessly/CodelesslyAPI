// ---
// name: Merge generated Flutter node catalog
// description: Collect every generated node fragment into one A2UI v0.9.1 catalog and DPP descriptor registry, failing duplicate components or wire types.
// usage: cd CodelesslyAPI && dart run tool/flutter_prop_builder/bin/merge.dart
// ---
import 'dart:convert';
import 'dart:io';

import 'package:a2ui_core/a2ui_core.dart';

const catalogId =
    'https://codelessly.com/a2ui/catalogs/codelessly/v1/catalog.json';
void main(List<String> args) {
  final flutterCatalog = args.isEmpty
      ? null
      : jsonDecode(File(args.first).readAsStringSync()) as Map;
  final flutterWidgets = flutterCatalog?['widgets'] as Map?;
  const dir = 'lib/src/api/nodes';
  final files =
      Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.flutter_catalog.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) throw StateError('No generated metadata fragments found');
  final components = <String, dynamic>{};
  final descriptors = <Map<String, dynamic>>[];
  final drift = <Map<String, dynamic>>[];
  final nodeTypes = <String>{};
  for (final file in files) {
    final data = jsonDecode(file.readAsStringSync()) as Map;
    for (final node in data.entries) {
      final record = node.value as Map;
      final widget = record['widget'] as String;
      final type = record['nodeType'] as String;
      final variant = record['variant'] as String?;
      if (!nodeTypes.add('$type:${variant ?? ''}'))
        throw StateError('Duplicate node wire variant $type/$variant');
      if (const {'chart', 'gauge', 'signature'}.contains(type) !=
          (variant != null)) {
        throw StateError('Invalid family discriminator $type/$variant');
      }
      if (flutterWidgets != null && record['family'] != 'codelessly') {
        final flutter = flutterWidgets[widget] as Map?;
        if (flutter == null)
          throw StateError('Unknown Flutter widget $widget on $type');
        final constructors = flutter['constructors'] as Map;
        final parameters = <String>{
          for (final ctor in constructors.values)
            ...((ctor as Map)['parameters'] as Map).keys.cast<String>(),
        };
        for (final descriptor in record['dpp'] as List) {
          final descriptorMap = descriptor as Map;
          if (descriptorMap.containsKey('flutterParam') &&
              descriptorMap['flutterParam'] == null) {
            continue; // Explicitly Codelessly-only wire convenience field.
          }
          final name = descriptorMap['flutterName'];
          if (!parameters.contains(name)) {
            throw StateError(
              'Unknown Flutter parameter $widget.$name in $type',
            );
          }
        }
      }
      final schema = (record['a2ui'] as Map)['components'] as Map;
      if (components.containsKey(widget))
        throw StateError('Duplicate A2UI component $widget');
      components[widget] = schema[widget];
      descriptors.addAll(
        (record['dpp'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      for (final mismatch in record['drift'] as List) {
        drift.add({
          'nodeType': type,
          if (variant != null) 'variant': variant,
          ...Map<String, dynamic>.from(mismatch as Map),
        });
      }
    }
  }
  // a2ui_core 0.4.0 embeds the official A2UI v0.9 BASIC document
  // (specification/v0_9/catalogs/basic/catalog.json; checked against upstream
  // revision 4d4b3e3197977afe7ac18ce67200299db5b27259). This brings all
  // Dynamic* bindings, Checkable, functions and the full 18-name vocabulary.
  // Merge official BASIC names over colliding Flutter metadata names (e.g.
  // TextField/Slider/Divider); DPP keeps the Flutter-field projections.
  final officialBasic = BasicCatalog.v0_9().toJson();
  final basicComponents = officialBasic['components'] as Map;
  for (final entry in basicComponents.entries) {
    components[entry.key as String] = entry.value;
  }
  // Mapping describes the current node bridge, not permission to advertise
  // every schema in a live store. Partial entries require typed field guards;
  // null means W3 has no correct renderer yet.
  const basicNodeTypes = <String, String?>{
    'Text': 'text',
    'Button': 'textButton',
    'Row': 'row',
    'Column': 'column',
    'List': 'listView',
    'Card': 'frame',
    'Image': 'rectangle',
    'Icon': 'icon',
    'Divider': 'divider',
    'TextField': 'textField',
    'CheckBox': 'checkbox',
    'Slider': 'slider',
    'ChoicePicker': 'segmentedButton',
    'Video': null,
    'Tabs': null,
    'DateTimeInput': null,
    'AudioPlayer': null,
    'Modal': null,
  };
  if (basicNodeTypes.keys
          .toSet()
          .difference(basicComponents.keys.toSet())
          .isNotEmpty ||
      basicComponents.keys
          .toSet()
          .difference(basicNodeTypes.keys.toSet())
          .isNotEmpty) {
    throw StateError(
      'BASIC mapping registry does not match pinned A2UI catalog',
    );
  }
  final catalog = {
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    r'$id': catalogId,
    'catalogId': catalogId,
    'title': 'Codelessly generated v1 catalog',
    'description': 'Generated Flutter node metadata plus pinned A2UI v0.9 BASIC vocabulary; schema presence does not imply a typed renderer.',
    'components': components,
    'functions': officialBasic['functions'],
    r'$defs': {
      ...(officialBasic[r'$defs'] as Map),
      'anyComponent': {
        'oneOf': [
          for (final name in components.keys) {r'$ref': '#/components/$name'},
        ],
        'discriminator': {'propertyName': 'component'},
      },
    },
  };
  final out = Directory('lib/src/schema/generated')
    ..createSync(recursive: true);
  void write(String name, dynamic data) => File(
    '${out.path}/$name',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
  write('codelessly_a2ui_catalog.json', catalog);
  write('basic_node_mappings.json', {
    'sourceCatalogId': officialBasic['catalogId'],
    'catalogId': catalogId,
    'mappings': {
      for (final entry in basicNodeTypes.entries)
        entry.key: {
          'nodeType': entry.value,
          'bridgeStatus': entry.value == null ? 'deferred' : 'partial',
        },
    },
  });
  write('dpp_descriptors.json', {'descriptors': descriptors, 'drift': drift});
  stdout.writeln(
    '${components.length} components, ${descriptors.length} descriptors, ${drift.length} naming drifts',
  );
}
