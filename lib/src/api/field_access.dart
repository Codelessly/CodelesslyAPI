import 'dart:core';

import '../../codelessly_api.dart';

/// Signature for callbacks that report that an underlying value has changed.
typedef ValueChanged<T> = void Function(T value);

/// Signature for callbacks that return a value.
typedef GetterCallback<T extends Object?> = T Function();

/// Signature for callbacks that return the default value of a property.
typedef DefaultValueCallback<T> = T? Function();

/// Signature for callbacks that return the options of a property.
typedef FieldOptionsGetter<T> = Iterable<T> Function();

/// A mixin that provides a map of extrinsic meta access to a list of fields.
mixin FieldsHolder {
  /// The map of fields.
  Map<String, FieldAccess> get fields;
}

/// A class that provides extrinsic meta access to a field.
sealed class FieldAccess<GetValue extends Object?> {
  /// The label of the field.
  final GetterCallback<String> label;

  /// The description of the field.
  final GetterCallback<String> description;

  /// The setter of the field.
  final ValueChanged<GetValue> setter;

  final GetterCallback<GetValue> _getter;

  /// The getter of the field.
  GetterCallback<GetValue> get getValue => _getter;

  /// Sets the value of the field.
  void setValue(Object? value);

  final DefaultValueCallback<GetValue>? _defaultValue;

  /// The default value of the field.
  DefaultValueCallback<GetValue>? get getDefaultValue => _defaultValue;

  /// The serialized value of the field.
  dynamic get serialize;

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
        'value': serialize,
        if (getDefaultValue?.call() case Object defaultValue)
          'default': defaultValue,
        if (supplementarySchema case Map<String, dynamic> supplementary)
          ...supplementary
      };

  /// Constructs a new [FieldAccess] instance with the given parameters.
  const FieldAccess(
    this.label,
    this.description,
    this.setter,
    this._getter, {
    DefaultValueCallback<GetValue>? defaultValue,
  }) : _defaultValue = defaultValue;
}

/// A field accessor for a [String] field.
final class StringFieldAccess extends FieldAccess<String> {
  /// Constructs a new [StringFieldAccess] instance with the given parameters.
  const StringFieldAccess(
    super.label,
    super.description,
    super.setter,
    super.getter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'string';

  @override
  dynamic get serialize => getValue();

  @override
  void setValue(Object? value) => setter(value.typedValue<String>()!);
}

/// A field accessor for a [num] field.
final class NumFieldAccess<Number extends num> extends FieldAccess<Number> {
  /// Constructs a new [NumFieldAccess] instance with the given parameters.
  const NumFieldAccess(
    super.label,
    super.description,
    super.setter,
    super.getter, {
    this.min,
    this.max,
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'num';

  @override
  dynamic get serialize => getValue();

  /// The minimum value of the field.
  final GetterCallback<Number>? min;

  /// The maximum value of the field.
  final GetterCallback<Number>? max;

  @override
  Map<String, dynamic> get supplementarySchema => {
        if (getValue() is double) 'fractionDigits': 2,
        if (min case GetterCallback<Number> min) 'min': min(),
        if (max case GetterCallback<Number> max) 'max': max(),
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
    super.setter,
    super.getter, {
    super.defaultValue,
  });

  @override
  dynamic get serialize => getValue();

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
    super.setter,
    super.getter, {
    required super.defaultValue,
    required FieldOptionsGetter<T> options,
  }) : getOptions = options;

  /// The options of the field.
  final FieldOptionsGetter<T> getOptions;

  @override
  String get dynamicKeyType => 'options';

  @override
  dynamic get serialize => getValue().name;

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
    setter(allValues[value] ?? getDefaultValue!()!);
  }
}

/// A field accessor for an [Iterable] field.
final class IterableFieldAccess<T extends List<Object?>>
    extends FieldAccess<T> {
  /// Constructs a new [IterableFieldAccess] instance with the given parameters.
  const IterableFieldAccess(
    super.label,
    super.description,
    super.setter,
    super.getter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'items';

  @override
  dynamic get serialize => [
        for (final Object? item in getValue())
          item is FieldAccess ? item.serialize : item,
      ];

  @override
  Map<String, dynamic> get supplementarySchema => {
        'items': [
          for (final Object? item in getValue())
            item is FieldAccess ? item.schema : item,
        ],
      };

  @override
  void setValue(Object? value) => setter(value as T);
}

/// A field accessor for a [ColorRGB] field.
final class ColorFieldAccess extends FieldAccess<ColorRGB?> {
  /// Constructs a new [ColorFieldAccess] instance with the given parameters.
  ColorFieldAccess(
    super.label,
    super.description,
    super.setter,
    super.getter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'color';

  @override
  dynamic get serialize => getValue()?.toJson();

  @override
  Map<String, dynamic> get supplementarySchema => {
        'pattern': r'^#(?:[0-9a-fA-F]{3}){1,2}$',
      };

  @override
  void setValue(Object? value) => setter(value.typedValue<ColorRGB>());
}

/// A field accessor for a [CornerRadius] field.
final class RadiusFieldAccess extends FieldAccess<CornerRadius> {
  /// Constructs a new [RadiusFieldAccess] instance with the given parameters.
  RadiusFieldAccess(
    super.label,
    super.description,
    super.setter,
    super.getter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'radius';

  @override
  dynamic get serialize => getValue().toJson();

  @override
  void setValue(Object? value) => setter(value.typedValue<CornerRadius>()!);
}
