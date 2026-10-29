import 'dart:convert';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:build/build.dart';

/// Builds node metadata projections from [FlutterProp] annotations.
Builder flutterPropsBuilder(BuilderOptions options) => _FlutterPropsBuilder();

class _FlutterPropsBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const {'.dart': ['.flutter_catalog.json']};

  @override
  Future<void> build(BuildStep step) async {
    if (!step.inputId.path.contains('/nodes/') || step.inputId.path.endsWith('.g.dart')) return;
    final unit = parseString(content: await step.readAsString(step.inputId), throwIfDiagnostics: false).unit;
    final output = <String, dynamic>{};
    for (final cls in unit.declarations.whereType<ClassDeclaration>()) {
      final tag = cls.metadata.where((a) => a.name.name == 'FlutterNode').firstOrNull;
      if (tag == null) continue;
      final args = tag.arguments?.arguments;
      if (args == null || args.isEmpty) continue;
      String str(AstNode e) => e.toSource().replaceAll("'", '').replaceAll('"', '');
      String? named(NodeList<Argument> expressions, String key) {
        for (final e in expressions.whereType<NamedArgument>()) {
          if (e.name.lexeme == key) return str(e.argumentExpression);
        }
        return null;
      }
      final widget = str(args.first);
      final family = named(args, 'family') ?? 'widgets';
      final props = <String, dynamic>{};
      for (final annotation in cls.metadata.where((a) => a.name.name == 'FlutterProp')) {
        final a = annotation.arguments?.arguments;
        if (a == null || a.isEmpty) continue;
        final name = str(a.first);
        props[name] = {
          'type': named(a, 'type') ?? 'string',
          'group': named(a, 'group') ?? 'Widget',
          'control': named(a, 'control') ?? 'text',
          'field': named(a, 'field') ?? name,
          'defaultSource': named(a, 'defaultSource'),
          'required': named(a, 'required') == 'true',
          'bindable': named(a, 'bindable') == 'true',
        };
      }
      final schemaProps = {for (final entry in props.entries) entry.key: {
        'type': entry.value['type'],
        'description': '${entry.value['group']}: ${entry.value['field']}',
      }};
      output[cls.namePart.toSource()] = {
        'widget': widget, 'family': family,
        'jsonSchema': {'\$schema': 'https://json-schema.org/draft/2020-12/schema', 'type': 'object', 'additionalProperties': false, 'properties': schemaProps,
          'required': [for (final entry in props.entries) if (entry.value['required'] == true) entry.key]},
        'dpp': [for (final entry in props.entries) {'name':entry.key, 'field':entry.value['field'], 'group':entry.value['group'], 'control':entry.value['control'], 'bindable':entry.value['bindable']}],
        'a2ui': {'\$schema': 'https://json-schema.org/draft/2020-12/schema', '\$id': 'https://codelessly.com/a2ui/catalog/$family/$widget', 'components': {widget: {'type':'object', 'properties': schemaProps}}},
        'testMatrix': [for (final entry in props.entries) {'parameter':entry.key, 'field':entry.value['field'], 'defaultSource':entry.value['defaultSource'], 'testValues':entry.value['type'] == 'boolean' ? [false,true] : ['number', 'integer'].contains(entry.value['type']) ? [0,1] : entry.value['type'] == 'array' ? [[], ['sample']] : ['', 'sample']}],
      };
    }
    if (output.isNotEmpty) await step.writeAsString(step.inputId.changeExtension('.flutter_catalog.json'), '${const JsonEncoder.withIndent('  ').convert(output)}\n');
  }
}
