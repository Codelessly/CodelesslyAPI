import 'dart:core';

import 'package:meta/meta.dart';

import '../../codelessly_api.dart';

/// Signature for callbacks that report that an underlying value has changed.
typedef FieldSetterCallback<T> = void Function(T value);

/// Signature for callbacks that return a value.
typedef FieldGetterCallback<T extends Object?> = T Function();

/// Signature for callbacks that return the default value of a property.
typedef DefaultFieldValueCallback<T> = T Function();

/// Signature for callbacks that return the options of a property.
typedef FieldOptionsGetter<T> = Iterable<T> Function();

/// Signature for callbacks that return a label of an item in an iterable.
typedef IterableFieldItemIdentifier<T> = String Function(T item);

/// A mixin that provides a map of extrinsic meta access to a list of fields.
mixin FieldsHolder {
  /// The map of fields.
  Map<String, FieldAccess> get fields;

  /// The complete schema of the [FieldsHolder]'s [fields].
  dynamic get schema => {
        for (final MapEntry(:key, :value) in fields.entries) key: value.schema,
      };
}

/// A class that provides extrinsic meta access to a field.
sealed class FieldAccess<T extends Object?> {
  /// The label of the field.
  final FieldGetterCallback<String> label;

  /// The description of the field.
  final FieldGetterCallback<String> description;

  /// The setter of the field.
  @protected
  final FieldSetterCallback<T> setter;

  /// Returns the value of the field.
  final FieldGetterCallback<T> getValue;

  /// Sets the value of the field.
  void setValue(Object? value);

  final DefaultFieldValueCallback<T>? _defaultValue;

  /// The default value of the field.
  DefaultFieldValueCallback<T>? get getDefaultValue => _defaultValue;

  /// The serialized value of the field.
  dynamic serialize(T obj) => obj;

  /// The dynamic key type of the field, used by the dynamic settings panel to
  /// determine the type of the field to be displayed and modified.
  String get dynamicKeyType;

  /// The supplementary schema of the field, used by the dynamic settings panel
  /// to provide additional information about the field, such as constraints,
  /// regex input pattern, etc...
  Map<String, dynamic>? get supplementarySchema => null;

  /// The schema of the field, used to generate a complete dynamic settings
  /// panel entry for this field.
  dynamic get schema => {
        'type': dynamicKeyType,
        'label': label(),
        'description': description(),
        'value': serialize(getValue()),
        if (getDefaultValue case DefaultFieldValueCallback<T> defaultValue)
          'default': serialize(defaultValue()),
        if (supplementarySchema case Map<String, dynamic> supplementary)
          ...supplementary
      };

  /// Constructs a new [FieldAccess] instance with the given parameters.
  const FieldAccess(
    this.label,
    this.description,
    this.getValue,
    this.setter, {
    DefaultFieldValueCallback<T>? defaultValue,
  }) : _defaultValue = defaultValue;
}

/// A field accessor for a [String] field.
final class StringFieldAccess extends FieldAccess<String> {
  /// Constructs a new [StringFieldAccess] instance with the given parameters.
  const StringFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'string';

  @override
  void setValue(Object? value) => setter(value.typedValue<String>()!);
}

/// A field accessor for a [num] field.
final class NumFieldAccess<Number extends num> extends FieldAccess<Number> {
  /// Constructs a new [NumFieldAccess] instance with the given parameters.
  const NumFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    this.min,
    this.max,
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'num';

  /// The minimum value of the field.
  final FieldGetterCallback<Number>? min;

  /// The maximum value of the field.
  final FieldGetterCallback<Number>? max;

  @override
  Map<String, dynamic> get supplementarySchema => {
        if (getValue() is double) 'fractionDigits': 2,
        if (min case FieldGetterCallback<Number> min) 'min': min(),
        if (max case FieldGetterCallback<Number> max) 'max': max(),
      };

  @override
  void setValue(Object? value) => setter(value.typedValue<Number>()!);
}

/// A field accessor for a [bool] field.
final class BoolFieldAccess extends FieldAccess<bool> {
  /// Constructs a new [BoolFieldAccess] instance with the given parameters.
  const BoolFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'bool';

  @override
  void setValue(Object? value) => setter(value.typedValue<bool>()!);
}

/// A field accessor for an [Enum] field.
final class EnumFieldAccess<T extends Enum> extends FieldAccess<T> {
  /// Constructs a new [EnumFieldAccess] instance with the given parameters.
  const EnumFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    required super.defaultValue,
    required FieldOptionsGetter<T> options,
  }) : getOptions = options;

  /// The options of the field.
  final FieldOptionsGetter<T> getOptions;

  @override
  String get dynamicKeyType => 'options';

  @override
  dynamic serialize(T obj) => obj.name;

  @override
  Map<String, dynamic> get supplementarySchema => {
        'options': {
          for (final T option in getOptions())
            option.name: option.name.toUpperCase(),
        }
      };

  @override
  void setValue(Object? value) {
    final Map<String, T> allValues = getOptions().asNameMap();
    setter(allValues[value] ?? getDefaultValue!());
  }
}

/// A field accessor for an [Iterable] field.
final class IterableFieldAccess<T> extends FieldAccess<List<T>> {
  /// Constructs a new [IterableFieldAccess] instance with the given parameters.
  const IterableFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter,
    this.itemLabel, {
    super.defaultValue,
  });

  /// The label of an item in this iterable.
  final IterableFieldItemIdentifier<T> itemLabel;

  @override
  String get dynamicKeyType => 'items';

  Map<String, dynamic> _wrap(T item, dynamic nested) => {
        'label': itemLabel(item),
        // 'type': item.runtimeType.subTypeString,
        'properties': nested,
      };

  @override
  dynamic get schema {
    final items = [];
    for (final T item in getValue()) {
      if (item is FieldsHolder) {
        items.add(_wrap(item, item.schema));
      } else if (item is FieldAccess) {
        items.add(_wrap(item, item.schema));
      } else {
        throw UnimplementedError();
      }
    }

    return items;
  }

  @override
  void setValue(Object? value) => setter(value as List<T>);
}

/// A field accessor for a [ColorRGB] field.
final class ColorFieldAccess extends FieldAccess<ColorRGB?> {
  /// Constructs a new [ColorFieldAccess] instance with the given parameters.
  ColorFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'color';

  @override
  dynamic serialize(ColorRGB? obj) => obj?.toJson();

  @override
  void setValue(Object? value) => setter(value.typedValue<ColorRGB>());
}

/// A field accessor for a [CornerRadius] field.
final class RadiusFieldAccess extends FieldAccess<CornerRadius> {
  /// Constructs a new [RadiusFieldAccess] instance with the given parameters.
  RadiusFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'radius';

  @override
  dynamic serialize(CornerRadius obj) => obj.toJson();

  @override
  void setValue(Object? value) => setter(value.typedValue<CornerRadius>()!);
}
