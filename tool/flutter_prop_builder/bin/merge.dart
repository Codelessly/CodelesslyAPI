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
      if (flutterWidgets != null) {
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
  final catalog = {
    '\$schema':'https://json-schema.org/draft/2020-12/schema',
    '\$id':catalogId,
    'catalogId':catalogId,
    'title':'Codelessly generated v1 catalog',
    'description':'Generated from annotated API node wire fields for A2UI v0.9.1.',
    'components':components,
    'functions':<String, dynamic>{},
  };
  final out = Directory('catalog')..createSync(recursive: true);
  void write(String name, dynamic data) => File('${out.path}/$name').writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
  write('codelessly_catalog_v1.json', catalog);
  write('dpp_descriptors.json', {'descriptors':descriptors, 'drift':drift});
  stdout.writeln('${components.length} components, ${descriptors.length} descriptors, ${drift.length} naming drifts');
}
