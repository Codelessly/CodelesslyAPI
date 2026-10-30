import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Generate wire-field schemas and A2UI/DPP metadata for annotated API nodes.
Builder flutterPropsBuilder(BuilderOptions options) => _FlutterPropsBuilder();

/// Stable v1 A2UI catalog identifier.
const catalogId =
    'https://codelessly.com/a2ui/catalogs/codelessly/v1/catalog.json';

/// Published v0.9.1 A2UI common type definitions.
const common =
    'https://a2ui.org/specification/v0_9_1/common_types.json#/\$defs/';

class _FlutterPropsBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.flutter_catalog.json'],
  };

  @override
  Future<void> build(BuildStep step) async {
    if (!step.inputId.path.contains('/nodes/') ||
        step.inputId.path.endsWith('.g.dart'))
      return;
    final library = await step.resolver.libraryFor(step.inputId);
    final output = <String, dynamic>{};
    for (final cls in library.classes) {
      final nodeTag = _annotation(cls.metadata.annotations, 'FlutterNode');
      if (nodeTag == null) continue;
      final widget = nodeTag.read('widget').stringValue;
      final family = nodeTag.read('family').stringValue;
      final nodeType = nodeTag.read('nodeType').stringValue;
      final variant = nodeTag.peek('variant')?.stringValue;
      final kindKey = switch (nodeType) {
        'chart' => 'chartKind',
        'gauge' => 'gaugeKind',
        'signature' => 'signatureKind',
        _ => null,
      };
      if ((variant == null) != (kindKey == null)) {
        throw InvalidGenerationSourceError(
          'Variant required exactly for canonical chart, gauge and signature nodes',
          element: cls,
        );
      }
      final wireTypes = <String, DartType>{};
      final annotated = <String, (DartType, Element, ConstantReader)>{};
      void include(InterfaceElement element, {String prefix = ''}) {
        for (final field in element.fields.where((field) => !field.isStatic)) {
          final name = '$prefix${field.name}';
          wireTypes[name] = field.type;
          final tag = _annotation(field.metadata.annotations, 'FlutterProp');
          if (tag != null) {
            annotated.putIfAbsent(name, () => (field.type, field, tag));
          }
        }
        // Getter-backed persisted properties (BaseNode.margin / padding)
        // are not FieldElements; inspect explicit annotated declarations only.
        for (final getter in element.getters.where(
          (getter) => !getter.isStatic,
        )) {
          final tag = _annotation(getter.metadata.annotations, 'FlutterProp');
          if (tag == null) continue;
          final wireName = _serializedGetterPath(getter, prefix);
          wireTypes[wireName] = getter.returnType;
          annotated.putIfAbsent(
            wireName,
            () => (getter.returnType, getter, tag),
          );
        }
      }

      include(cls);
      for (final ancestor in cls.allSupertypes) {
        include(ancestor.element);
      }
      // Nested properties may be declared on a shared abstract node base.
      final propertyField = [cls, ...cls.allSupertypes.map((t) => t.element)]
          .expand((element) => element.fields)
          .where((field) => field.name == 'properties')
          .firstOrNull;
      final nestedElement = propertyField?.type.element;
      if (nestedElement is InterfaceElement) {
        include(nestedElement, prefix: 'properties.');
        for (final ancestor in nestedElement.allSupertypes) {
          include(ancestor.element, prefix: 'properties.');
        }
      }
      // BlendMixin owns InkWellModel?; only nodes that actually inherit that
      // field receive nested InkWell descriptors. Keep the declaration in the
      // model as the source of truth, not a fabricated InkWell node type.
      final inkWellField = [cls, ...cls.allSupertypes.map((t) => t.element)]
          .expand((element) => element.fields)
          .where((field) => field.name == 'inkWell')
          .firstOrNull;
      final inkWellElement = inkWellField?.type.element;
      if (inkWellElement is InterfaceElement) {
        include(inkWellElement, prefix: 'inkWell.');
      }
      // Opt-in typed paths for persisted nested objects and list items. The
      // `[]` means any item, never a guessed positional index. Only fields
      // annotated on the item's concrete source class can enter the registry.
      final edgePinsField = [cls, ...cls.allSupertypes.map((t) => t.element)]
          .expand((element) => element.fields)
          .where((field) => field.name == 'edgePins')
          .firstOrNull;
      final pinsType = edgePinsField?.type.element;
      if (pinsType is InterfaceElement) {
        include(pinsType, prefix: 'edgePins.');
      }
      for (final (listName, itemName) in const [
        ('fills', 'PaintModel'),
        ('textMixedProps', 'StartEndProp'),
      ]) {
        final listField = [cls, ...cls.allSupertypes.map((t) => t.element)]
            .expand((element) => element.fields)
            .where((field) => field.name == listName)
            .firstOrNull;
        final listType = listField?.type;
        if (listType is! InterfaceType ||
            listType.element.name != 'List' ||
            listType.typeArguments.single.element?.name != itemName) {
          continue;
        }
        final itemType = listType.typeArguments.single.element;
        if (itemType is! InterfaceElement) continue;
        include(itemType, prefix: '$listName[].');
        if (listName == 'textMixedProps') {
          for (final ancestor in itemType.allSupertypes) {
            if (ancestor.element.name == 'TextProp') {
              include(ancestor.element, prefix: '$listName[].');
            }
          }
        }
      }
      for (final nestedName in const ['transition', 'pulse']) {
        final nestedField = [cls, ...cls.allSupertypes.map((t) => t.element)]
            .expand((element) => element.fields)
            .where((field) => field.name == nestedName)
            .firstOrNull;
        final nestedType = nestedField?.type.element;
        if (nestedType is InterfaceElement) {
          include(nestedType, prefix: '$nestedName.');
        }
      }
      final schemaFields = <String, dynamic>{};
      final controls = <Map<String, dynamic>>[];
      final matrix = <Map<String, dynamic>>[];
      final a2uiFields = <String, dynamic>{
        'component': {'const': widget},
      };
      final required = <String>['component'];
      if (kindKey != null) {
        schemaFields[kindKey] = {'const': variant};
        a2uiFields[kindKey] = {'const': variant};
        required.add(kindKey);
      }
      final drift = <Map<String, String>>[];
      for (final entry in annotated.entries) {
        // IconButton has an icon parameter, not a child widget.
        if (cls.name == 'IconButtonNode' && entry.key == 'properties.label')
          continue;
        if (cls.name != 'IconButtonNode' &&
            cls.name != 'IconNode' &&
            entry.key == 'properties.icon')
          continue;
        // Only the RowColumn component consumes the axis-alignment fields of
        // this shared mixin; other consumers have their own Flutter contract.
        if (cls.name != 'RowNode' &&
            cls.name != 'ColumnNode' &&
            (entry.key == 'mainAxisAlignment' ||
                entry.key == 'crossAxisAlignment')) {
          continue;
        }
        if (cls.name == 'ListTileNode' && entry.key == 'children') continue;
        if (entry.key == 'ephemeral' &&
            cls.name != 'SinglePlaceholderNode' &&
            cls.name != 'AutoPlaceholderNode')
          continue;
        if (entry.key == 'flex' && cls.name != 'SpacerNode') continue;
        final actualType = entry.value.$1;
        final field = entry.value.$2;
        final tag = entry.value.$3;
        final flutterName = tag.read('name').stringValue;
        final isFlutterParam = tag.peek('flutterParam')?.boolValue ?? true;
        final isA2ui =
            (tag.peek('a2ui')?.boolValue ?? true) &&
            (entry.key != 'opacity' || cls.name == 'RectangleNode');
        final note = tag.peek('note')?.stringValue;
        if (!isFlutterParam && (note == null || note.isEmpty)) {
          throw InvalidGenerationSourceError(
            'Codelessly convenience field $flutterName requires a note',
            element: field,
          );
        }
        final mapped = tag.peek('field')?.stringValue ?? entry.key;
        if (mapped != entry.key || !wireTypes.containsKey(mapped)) {
          throw InvalidGenerationSourceError(
            'FlutterProp($flutterName): field $mapped does not identify its annotated declaration ${entry.key}',
            element: field,
          );
        }
        final type = tag.read('type').stringValue;
        final schemaType = _type(actualType, type);
        final group = tag.read('group').stringValue;
        final control = tag.read('control').stringValue;
        final defaultSource = tag.peek('defaultSource')?.stringValue;
        final bindable = tag.read('bindable').boolValue;
        final isRequired = tag.read('required').boolValue;
        if (mapped.contains('[]')) {
          if (isA2ui) {
            throw InvalidGenerationSourceError(
              'Indexed DPP path $mapped cannot be exposed as an A2UI field',
              element: field,
            );
          }
          _validateIndexedPath(mapped, wireTypes, field);
        }
        _putNested(schemaFields, mapped, schemaType);
        final a2uiName = switch (control) {
          'action' => 'action',
          'children' => 'children',
          _ => mapped,
        };
        if (isA2ui) {
          _putNested(a2uiFields, a2uiName, switch (control) {
            'action' => {'\$ref': '${common}Action'},
            'children' => {'\$ref': '${common}ChildList'},
            'child' => {'\$ref': '${common}ComponentId'},
            _ => schemaType,
          });
          if (isRequired) required.add(a2uiName);
        }
        if (isFlutterParam && flutterName != mapped)
          drift.add({'flutterName': flutterName, 'fieldPath': mapped});
        controls.add({
          'nodeType': nodeType,
          if (variant != null) 'variant': variant,
          'flutterName': isFlutterParam ? flutterName : null,
          if (!isFlutterParam) 'flutterParam': null,
          if (!isFlutterParam) 'note': note,
          'fieldPath': mapped,
          'group': group,
          'control': control,
          'schemaType': type,
          'defaultSource': defaultSource,
          'bindable': bindable,
        });
        matrix.add({
          'parameter': isFlutterParam ? flutterName : null,
          if (!isFlutterParam) 'note': note,
          'field': mapped,
          'defaultSource': defaultSource,
          'testValues': _testValues(type),
        });
      }
      if (annotated.isEmpty)
        throw InvalidGenerationSourceError(
          '$widget has no annotated wire fields',
          element: cls,
        );
      output[cls.name!] = {
        'widget': widget,
        'family': family,
        'nodeType': nodeType,
        if (variant != null) 'variant': variant,
        'drift': drift,
        'jsonSchema': {
          '\$schema': 'https://json-schema.org/draft/2020-12/schema',
          'type': 'object',
          'properties': schemaFields,
          if (kindKey != null) 'required': [kindKey],
        },
        'dpp': controls,
        'a2ui': {
          '\$schema': 'https://json-schema.org/draft/2020-12/schema',
          '\$id': catalogId,
          'catalogId': catalogId,
          'components': {
            widget: {
              'allOf': [
                {'\$ref': '${common}ComponentCommon'},
                {
                  'type': 'object',
                  'properties': a2uiFields,
                  'required': required,
                },
              ],
              'unevaluatedProperties': false,
            },
          },
          'functions': <String, dynamic>{},
        },
        'testMatrix': matrix,
      };
    }
    if (output.isNotEmpty)
      await step.writeAsString(
        step.inputId.changeExtension('.flutter_catalog.json'),
        '${const JsonEncoder.withIndent('  ').convert(output)}\n',
      );
  }
}

void _putNested(
  Map<String, dynamic> fields,
  String path,
  Map<String, dynamic> schema,
) {
  final parts = path.split('.');
  var current = fields;
  for (final part in parts.take(parts.length - 1)) {
    if (part.endsWith('[]')) {
      final listName = part.substring(0, part.length - 2);
      final list = current.putIfAbsent(
        listName,
        () => <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'type': 'object'},
        },
      ) as Map<String, dynamic>;
      if (list['type'] != 'array') {
        throw InvalidGenerationSourceError(
          '$listName must be an array for $path',
        );
      }
      final item = list['items'] as Map<String, dynamic>;
      item.putIfAbsent('properties', () => <String, dynamic>{});
      current = item['properties'] as Map<String, dynamic>;
    } else {
      final parent = current.putIfAbsent(
        part,
        () => <String, dynamic>{'type': 'object'},
      ) as Map<String, dynamic>;
      if (parent['type'] != 'object') {
        throw InvalidGenerationSourceError('$part must be an object for $path');
      }
      parent.putIfAbsent('properties', () => <String, dynamic>{});
      current = parent['properties'] as Map<String, dynamic>;
    }
  }
  if (parts.last.endsWith('[]')) {
    throw InvalidGenerationSourceError(
      'Indexed descriptor needs an item field: $path',
    );
  }
  final existing = current[parts.last];
  if (existing == null) {
    current[parts.last] = schema;
  } else if (existing is Map && existing['type'] == schema['type']) {
    // An annotated list has its item schema enriched by annotated item fields.
    if (schema['type'] == 'array') {
      (existing as Map<String, dynamic>).putIfAbsent(
        'items',
        () => schema['items'],
      );
    }
  } else {
    throw InvalidGenerationSourceError(
      'Conflicting descriptor schema for $path',
    );
  }
}

void _validateIndexedPath(
  String path,
  Map<String, DartType> wireTypes,
  Element leaf,
) {
  final match = RegExp(r'^([a-zA-Z]\w*)\[\]\.([a-zA-Z]\w*)$').firstMatch(path);
  if (match == null || !wireTypes.containsKey(match.group(1))) {
    throw InvalidGenerationSourceError('Invalid typed indexed path: $path');
  }
  final list = wireTypes[match.group(1)];
  if (list is! InterfaceType || list.element.name != 'List') {
    throw InvalidGenerationSourceError(
      'Indexed path $path must follow a List field',
    );
  }
  final item = list.typeArguments.single.element;
  if (item is! InterfaceElement ||
      !{
        item.name,
        ...item.allSupertypes.map((type) => type.element.name),
      }.contains(leaf.enclosingElement?.name)) {
    throw InvalidGenerationSourceError(
      'Indexed path $path is not declared on its List item type',
      element: leaf,
    );
  }
}

String _serializedGetterPath(GetterElement getter, String prefix) {
  final jsonKey = _annotation(getter.metadata.annotations, 'JsonKey');
  final wireName = jsonKey?.peek('name')?.stringValue ?? getter.name;
  return '$prefix$wireName';
}

ConstantReader? _annotation(List<ElementAnnotation> annotations, String name) {
  for (final annotation in annotations) {
    final constant = annotation.computeConstantValue();
    if (constant?.type?.element?.name == name) return ConstantReader(constant);
  }
  return null;
}

Map<String, dynamic> _type(DartType actual, String schemaType) {
  if (!{
    'string',
    'number',
    'integer',
    'boolean',
    'array',
    'object',
  }.contains(schemaType)) {
    throw InvalidGenerationSourceError(
      'Unsupported JSON Schema type $schemaType on $actual',
    );
  }
  if (schemaType != 'array' && schemaType != 'object') {
    final inferred = _inferredType(actual);
    if (inferred != 'object' && inferred != schemaType) {
      throw InvalidGenerationSourceError(
        'Declared $schemaType but field has $actual (expected $inferred)',
      );
    }
  }
  if (schemaType == 'array') {
    if (actual is! InterfaceType || actual.element.name != 'List') {
      throw InvalidGenerationSourceError(
        'Declared array but field has type $actual',
      );
    }
    final item = actual.typeArguments.first;
    return {'type': 'array', 'items': _type(item, _inferredType(item))};
  }
  return {'type': schemaType};
}

String _inferredType(DartType type) {
  final name = type.getDisplayString();
  if (name == 'String' || name == 'String?') return 'string';
  if (name == 'int' || name == 'int?') return 'integer';
  if (name == 'double' || name == 'double?' || name == 'num' || name == 'num?')
    return 'number';
  if (name == 'bool' || name == 'bool?') return 'boolean';
  if (type is InterfaceType && type.element.name == 'List') return 'array';
  return 'object';
}

List<Object> _testValues(String type) => switch (type) {
  'boolean' => [false, true],
  'number' || 'integer' => [0, 1],
  'array' => [
    <Object>[],
    <Object>['sample'],
  ],
  _ => ['', 'sample'],
};
