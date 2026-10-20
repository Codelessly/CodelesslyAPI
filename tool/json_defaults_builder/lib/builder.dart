/// Generates `_$<Class>OmitDefaults(instance, json)` for every class annotated
/// with `@JsonSerializable` that has a `toJson`.
///
/// The generated function removes each key whose field still equals its
/// default, so stored JSON only carries values that differ from what
/// json_serializable's `fromJson` restores for a missing key. A field's
/// default is, in order of precedence:
///
/// 1. `@JsonLegacyDefault(...)` on the field.
/// 2. `@JsonKey(defaultValue: ...)` on the field.
/// 3. The default of the matching parameter of the constructor used by
///    json_serializable (including inherited `super.` parameter defaults).
/// 4. The field's own initializer, if the field is set through that
///    constructor or is mutable, and the initializer is a constant-like
///    expression. A final field without a constructor parameter (such as a
///    node's `type`) is always written, and so is a field that overrides a
///    supertype's field (such as `webviewType` in a `WebViewProperties`
///    subclass), because polymorphic readers pick the subclass from it.
///
/// Fields annotated with `@JsonOmitIf(test)` are also removed when
/// `test(instance)` is true.
///
/// Classes call it from their `toJson`:
/// `Map toJson() => _$FooOmitDefaults(this, _$FooToJson(this));`
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// Builder factory referenced from build.yaml.
Builder jsonDefaultsBuilder(BuilderOptions options) =>
    SharedPartBuilder([JsonDefaultsGenerator()], 'json_defaults');

const _jsonKeyChecker = TypeChecker.typeNamed(
  JsonKey,
  inPackage: 'json_annotation',
);

/// `JsonOmitIf` is declared by the package being built, so match it by name.
bool _isOmitIf(ElementAnnotation annotation) =>
    annotation.computeConstantValue()?.type?.element?.name == 'JsonOmitIf';

/// Generates the omit-defaults function for one class.
class JsonDefaultsGenerator extends GeneratorForAnnotation<JsonSerializable> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) return '';
    if (annotation.peek('createToJson')?.boolValue == false) return '';

    final className = element.name!;
    final ctorName = annotation.peek('constructor')?.stringValue ?? '';
    final ctor = ctorName.isEmpty
        ? element.unnamedConstructor
        : element.getNamedConstructor(ctorName);

    final params = ctor?.formalParameters ?? const <FormalParameterElement>[];
    final paramNames = {for (final param in params) ?param.name};
    final paramDefaults = <String, String>{
      for (final param in params)
        if (param.name != null &&
            param.defaultValueCode != null &&
            param.defaultValueCode != 'null')
          param.name!: param.defaultValueCode!,
    };

    final checks = <String>[];
    final seen = <String>{};
    for (final field in _serializableFields(element)) {
      final name = field.name!;
      if (!seen.add(name)) continue;

      final metadata = [
        ...field.metadata.annotations,
        ...?field.getter?.metadata.annotations,
      ];
      final jsonKey = _jsonKey(metadata);
      if (jsonKey != null && !_includedInToJson(jsonKey)) continue;
      final key = jsonKey?.peek('name')?.stringValue ?? name;
      final keyLiteral = "'${key.replaceAll("'", r"\'")}'";

      for (final omitIf in metadata.where(_isOmitIf)) {
        final test = omitIf
            .computeConstantValue()
            ?.getField('test')
            ?.toFunctionValue();
        if (test == null) continue;
        checks.add('  if (${test.name}(instance)) json.remove($keyLiteral);');
      }

      final declaration = await _declaration(field, buildStep);
      final defaultCode =
          _annotationArgument(declaration, 'JsonLegacyDefault') ??
          _jsonKeyDefaultValue(declaration) ??
          paramDefaults[name] ??
          ((paramNames.contains(name) || !field.isFinal) &&
                  !_overridesSuperField(field)
              ? _simpleInitializer(declaration)
              : null);
      if (defaultCode != null) {
        checks.add(
          '  if (isJsonDefault(instance.$name, $defaultCode)) '
          'json.remove($keyLiteral);',
        );
      }
    }

    final typeParams = element.typeParameters.map((t) => t.name!).toList();
    final generics = typeParams.isEmpty ? '' : '<${typeParams.join(', ')}>';
    return '''
Map<String, dynamic> _\$${className}OmitDefaults$generics(
  $className$generics instance,
  Map<String, dynamic> json,
) {
${checks.join('\n')}
  return json;
}
''';
  }

  /// Whether [field] overrides a field of a supertype of the class that
  /// declares it, like `late WebViewType webviewType = WebViewType.webpage`
  /// in a subclass of `WebViewProperties`.
  ///
  /// Such an initializer tells the subclasses apart rather than being a
  /// default: polymorphic readers such as `WebViewProperties.fromJson` pick
  /// the subclass from the key, so it must always be written.
  bool _overridesSuperField(FieldElement field) {
    final owner = field.enclosingElement;
    if (owner is! InterfaceElement) return false;
    return owner.allSupertypes.any(
      (type) => type.element.fields.any(
        (other) => !other.isStatic && other.name == field.name,
      ),
    );
  }

  /// Public instance fields of [element] and its superclasses, closest first.
  Iterable<FieldElement> _serializableFields(ClassElement element) sync* {
    final classes = <InterfaceElement>[
      element,
      ...element.allSupertypes.map((type) => type.element),
    ];
    for (final cls in classes) {
      for (final field in cls.fields) {
        if (field.isStatic || field.name == null) continue;
        if (field.name!.startsWith('_')) continue;
        yield field;
      }
    }
  }

  /// The declaration of [field] when it is declared in the package being
  /// built. Fields declared elsewhere (e.g. on Equatable) have no AST here
  /// and carry no serialized defaults.
  Future<VariableDeclaration?> _declaration(
    FieldElement field,
    BuildStep buildStep,
  ) async {
    final uri = field.library.uri;
    if (uri.scheme != 'package' ||
        uri.pathSegments.first != buildStep.inputId.package) {
      return null;
    }
    try {
      final node = await buildStep.resolver.astNodeFor(field.firstFragment);
      return node is VariableDeclaration ? node : null;
    } on Object {
      return null;
    }
  }

  /// The source of `defaultValue` in a `@JsonKey(...)` on [declaration].
  String? _jsonKeyDefaultValue(VariableDeclaration? declaration) {
    final fieldDeclaration = declaration?.parent?.parent;
    if (fieldDeclaration is! FieldDeclaration) return null;
    for (final annotation in fieldDeclaration.metadata) {
      if (annotation.name.name != 'JsonKey') continue;
      for (final argument in annotation.arguments?.arguments ?? const []) {
        if (argument is NamedArgument &&
            argument.name.lexeme == 'defaultValue') {
          // ignore: deprecated_member_use
          return argument.argumentExpression.toSource();
        }
      }
    }
    return null;
  }

  /// The source of the first positional argument of a `@[name](...)`
  /// annotation on [declaration].
  String? _annotationArgument(VariableDeclaration? declaration, String name) {
    final fieldDeclaration = declaration?.parent?.parent;
    if (fieldDeclaration is! FieldDeclaration) return null;
    for (final annotation in fieldDeclaration.metadata) {
      if (annotation.name.name != name) continue;
      final arguments = annotation.arguments?.arguments;
      if (arguments == null || arguments.isEmpty) return null;
      return arguments.first.toSource();
    }
    return null;
  }

  /// The source of [declaration]'s initializer when it is a constant-like
  /// expression, so it can be evaluated again in the generated code without
  /// side effects.
  String? _simpleInitializer(VariableDeclaration? declaration) {
    final initializer = declaration?.initializer;
    if (initializer == null || !_isSimple(initializer)) return null;
    final source = initializer.toSource();
    return source == 'null' ? null : source;
  }

  bool _isSimple(Expression expression) => switch (expression) {
    BooleanLiteral() || IntegerLiteral() || DoubleLiteral() => true,
    SimpleStringLiteral() || NullLiteral() => true,
    ListLiteral(:final elements) || SetOrMapLiteral(:final elements) =>
      elements.every((e) => e is Expression && _isSimple(e)),
    InstanceCreationExpression(:final isConst) => isConst,
    PrefixedIdentifier() || SimpleIdentifier() => true,
    PrefixExpression(:final operator, :final operand)
        when operator.lexeme == '-' =>
      _isSimple(operand),
    _ => false,
  };

  ConstantReader? _jsonKey(List<ElementAnnotation> metadata) {
    for (final annotation in metadata) {
      final value = annotation.computeConstantValue();
      if (value?.type != null && _jsonKeyChecker.isExactlyType(value!.type!)) {
        return ConstantReader(value);
      }
    }
    return null;
  }

  bool _includedInToJson(ConstantReader jsonKey) {
    if (jsonKey.peek('includeToJson')?.boolValue == false) return false;
    // ignore: deprecated_member_use
    if (jsonKey.peek('ignore')?.boolValue == true) return false;
    return true;
  }
}
