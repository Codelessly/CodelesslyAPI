import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

ConstantReader? annotation(Element element, String name) {
  for (final value in element.metadata.annotations) {
    final constant = value.computeConstantValue();
    if (constant?.type?.element?.name == name) return ConstantReader(constant);
  }
  return null;
}

void main() {
  test(
    'all concrete node types emit each applicable annotated mixin field',
    () async {
      final root = Directory.current.absolute.path;
      final collection = AnalysisContextCollection(includedPaths: [root]);
      addTearDown(collection.dispose);
      final data = jsonDecode(
        File('lib/src/schema/generated/dpp_descriptors.json')
            .readAsStringSync(),
      ) as Map;
      final descriptors = (data['descriptors'] as List).cast<Map>();
      final pairs = {
        for (final descriptor in descriptors)
          (descriptor['nodeType'] as String, descriptor['fieldPath'] as String),
      };
      var checkedNodes = 0;
      var checkedFields = 0;
      final files = Directory('lib/src/api/nodes')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('_node.dart'));
      for (final file in files) {
        final path = file.absolute.path;
        final result = await collection
            .contextFor(path)
            .currentSession
            .getResolvedLibrary(path);
        if (result is! ResolvedLibraryResult) {
          fail('Could not analyze $path: $result');
        }
        for (final cls in result.element.classes) {
          final node = annotation(cls, 'FlutterNode');
          if (node == null) continue;
          checkedNodes++;
          final nodeType = node.read('nodeType').stringValue;
          final className = cls.name;
          final ancestors = cls.allSupertypes.map((type) => type.element);
          for (final mixin in ancestors.whereType<MixinElement>()) {
            for (final field in mixin.fields) {
              final prop = annotation(field, 'FlutterProp');
              if (prop == null) continue;
              final path = prop.peek('field')?.stringValue ?? field.name;
              if (path == null) continue;
              // These are deliberate node-level filters in the builder: Flutter
              // Row/Column axis alignment and Spacer flex have separate meaning
              // on other consumers. ListTile handles children as own slots.
              if (path == 'flex' && className != 'SpacerNode') continue;
              if (path == 'children' && className == 'ListTileNode') continue;
              if ((path == 'mainAxisAlignment' ||
                      path == 'crossAxisAlignment') &&
                  className != 'RowNode' &&
                  className != 'ColumnNode') {
                continue;
              }
              checkedFields++;
              expect(
                pairs,
                contains((nodeType, path)),
                reason: '$className inherits ${mixin.name}.$path',
              );
            }
          }
        }
      }
      expect(checkedNodes, greaterThanOrEqualTo(54));
      expect(checkedFields, greaterThan(100));
    },
  );
}
