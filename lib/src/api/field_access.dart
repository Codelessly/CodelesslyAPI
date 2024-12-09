import 'dart:core';

import '../../codelessly_api.dart';

/// Signature for callbacks that report that an underlying value has changed.
///
/// See also:
///
///  * [ValueSetter], for callbacks that report that a value has been set.
typedef ValueChanged<T> = void Function(T value);

/// A utility class to access properties of a class.
typedef GetterCallback<T extends Object?> = T Function();

/// A callback that returns the default value of a property.
typedef DefaultValueCallback<T> = T? Function();

/// A callback that returns the options of a property.
typedef FieldOptionsGetter<T> = Iterable<T> Function();

mixin FieldsHolder {
  Map<String, FieldAccess> get fields;

// String get dynamicKeyType;
}

/// A class that provides extrinsic meta access to a field.
// final class ExactFieldAccess<T extends Object?> extends FieldAccess<T, T> {
//   /// Constructs an exact field access.
//   const ExactFieldAccess(
//     super.setter,
//     super.getter, {
//     super.defaultValue,
//   });
//
//   /// Constructs an exact field access with options.
//   const ExactFieldAccess.options(
//     super.setter,
//     super.getter, {
//     required super.options,
//     super.defaultValue,
//   }) : super.options();
// }

/// A class that provides extrinsic meta access to a field.
sealed class FieldAccess<GetValue extends Object?> {
  final GetterCallback<String> label;

  final GetterCallback<String> description;
  final ValueChanged<GetValue> setter;

  final GetterCallback<GetValue> _getter;

  GetterCallback<GetValue> get getValue => _getter;

  void setValue(Object? value);

  final DefaultValueCallback<GetValue>? _defaultValue;

  DefaultValueCallback<GetValue>? get getDefaultValue => _defaultValue;

  dynamic get serialize;

  String get dynamicKeyType;

  Map<String, dynamic>? get supplementarySchema => null;

  dynamic get schema => {
        'type': dynamicKeyType,
        'value': serialize,
        if (getDefaultValue?.call() case Object defaultValue)
          'default': defaultValue,
        if (supplementarySchema case Map<String, dynamic> supplementary)
          ...supplementary
      };

  /// Constructs a field access.
  const FieldAccess(
    this.label,
    this.description,
    this.setter,
    this._getter, {
    DefaultValueCallback<GetValue>? defaultValue,
  }) : _defaultValue = defaultValue;
}

final class StringFieldAccess extends FieldAccess<String> {
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

final class NumFieldAccess<Number extends num> extends FieldAccess<Number> {
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

  final GetterCallback<Number>? min;

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

final class BoolFieldAccess extends FieldAccess<bool> {
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

final class EnumFieldAccess<T extends Enum> extends FieldAccess<T> {
  const EnumFieldAccess(
    super.label,
    super.description,
    super.setter,
    super.getter, {
    required DefaultValueCallback<T>? defaultValue,
    required FieldOptionsGetter<T> options,
  })  : getOptions = options,
        super(defaultValue: defaultValue);

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

final class IterableFieldAccess<T extends List<Object?>>
    extends FieldAccess<T> {
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

final class ColorFieldAccess extends FieldAccess<ColorRGB?> {
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

final class RadiusFieldAccess extends FieldAccess<CornerRadius> {
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
