// ---
// name: Merge generated Flutter node catalog
// description: Collect every generated node fragment into one A2UI v0.9.1 catalog and DPP descriptor registry, failing duplicate components or wire types.
// usage: cd CodelesslyAPI && dart run tool/flutter_prop_builder/bin/merge.dart
// ---
import 'dart:convert';
import 'dart:io';

const catalogId = 'https://codelessly.com/a2ui/catalogs/codelessly/v1/catalog.json';
void main(List<String> args) {
  final flutterCatalog = args.isEmpty ? null : jsonDecode(File(args.first).readAsStringSync()) as Map;
  final flutterWidgets = flutterCatalog?['widgets'] as Map?;
  const dir = 'lib/src/api/nodes';
  final files = Directory(dir).listSync().whereType<File>()
      .where((f) => f.path.endsWith('.flutter_catalog.json')).toList()
    ..sort((a,b) => a.path.compareTo(b.path));
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
      if (!nodeTypes.add(type)) throw StateError('Duplicate node wire type $type');
      if (flutterWidgets != null && record['family'] != 'codelessly') {
        final flutter = flutterWidgets[widget] as Map?;
        if (flutter == null) throw StateError('Unknown Flutter widget $widget on $type');
        final constructors = flutter['constructors'] as Map;
        final parameters = <String>{
          for (final ctor in constructors.values)
            ...((ctor as Map)['parameters'] as Map).keys.cast<String>(),
        };
        for (final descriptor in record['dpp'] as List) {
          final name = (descriptor as Map)['flutterName'];
          if (!parameters.contains(name)) {
            throw StateError('Unknown Flutter parameter $widget.$name in $type');
          }
        }
      }
      final schema = (record['a2ui'] as Map)['components'] as Map;
      if (components.containsKey(widget)) throw StateError('Duplicate A2UI component $widget');
      components[widget] = schema[widget];
      descriptors.addAll((record['dpp'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
      for (final mismatch in record['drift'] as List) {
        drift.add({'nodeType':type, ...Map<String, dynamic>.from(mismatch as Map)});
      }
    }
  }
  // Basic A2UI names are permanent alongside Flutter widget names. Only
  // properties consumed by the typed GenUI bridge are exposed here.
  Map<String, dynamic> basic(String name, Map<String, dynamic> properties, List<String> required) => {
    'allOf': [
      {'\$ref': 'https://a2ui.org/specification/v0_9_1/common_types.json#/\$defs/ComponentCommon'},
      {'type': 'object', 'properties': {'component': {'const': name}, ...properties}, 'required': ['component', ...required]},
    ],
    'unevaluatedProperties': false,
  };
  const childList = 'https://a2ui.org/specification/v0_9_1/common_types.json#/\$defs/ChildList';
  const componentId = 'https://a2ui.org/specification/v0_9_1/common_types.json#/\$defs/ComponentId';
  const action = 'https://a2ui.org/specification/v0_9_1/common_types.json#/\$defs/Action';
  components['Text'] = basic('Text', {'text': {'type': 'string'}}, ['text']);
  components['Button'] = basic('Button', {'child': {'\$ref': componentId}, 'label': {'type': 'string'}, 'action': {'\$ref': action}, 'variant': {'enum': ['primary', 'secondary', 'tertiary']}}, ['child', 'action']);
  final flexProps = <String, dynamic>{
    'children': {'\$ref': childList},
    'justify': {'enum': ['start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly']},
    'align': {'enum': ['start', 'center', 'end', 'stretch', 'baseline']},
  };
  components['Row'] = basic('Row', flexProps, ['children']);
  components['Column'] = basic('Column', flexProps, ['children']);
  // ListView is the Flutter-named component; List is its basic counterpart.
  components['List'] = basic('List', {'children': {'\$ref': childList}}, ['children']);
  final catalog = {
    '\$schema':'https://json-schema.org/draft/2020-12/schema',
    '\$id':catalogId,
    'catalogId':catalogId,
    'title':'Codelessly generated v1 catalog',
    'description':'Generated from annotated API node wire fields for A2UI v0.9.1.',
    'components':components,
    'functions':<String, dynamic>{},
  };
  final out = Directory('lib/src/schema/generated')..createSync(recursive: true);
  void write(String name, dynamic data) => File('${out.path}/$name').writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
  write('codelessly_a2ui_catalog.json', catalog);
  write('dpp_descriptors.json', {'descriptors':descriptors, 'drift':drift});
  stdout.writeln('${components.length} components, ${descriptors.length} descriptors, ${drift.length} naming drifts');
}
