import 'dart:core';

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
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

/// Represents a map of fields.
typedef FieldsMap = Map<String, FieldAccess<Object?>>;

/// A mixin that provides a map of extrinsic meta access to a list of fields.
mixin FieldsHolder {
  /// The map of fields. Key: Field name, Value: Field accessor.
  @JsonKey(includeToJson: false, includeFromJson: false)
  late final FieldsMap fields = Map.unmodifiable(generateFields());

  /// The complete schema of the [FieldsHolder]'s [fields].
  Object get fieldSchema => {
        for (final MapEntry(:key, :value) in fields.entries)
          key: value.fieldSchema,
      };

  /// Generates the fields of the [FieldsHolder].
  @mustCallSuper
  FieldsMap generateFields() => {};
}

/// A class that provides extrinsic meta access to a field.
sealed class FieldAccess<T extends Object?> {
  /// The label of the field.
  final String label;

  /// The description of the field.
  final String? description;

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
  dynamic serialize(T? obj) => obj;

  /// The dynamic key type of the field, used by the dynamic settings panel to
  /// determine the type of the field to be displayed and modified.
  String get dynamicKeyType;

  /// The supplementary schema of the field, used by the dynamic settings panel
  /// to provide additional information about the field, such as constraints,
  /// regex input pattern, etc...
  Map<String, dynamic>? get supplementarySchema => null;

  /// The schema of the field, used to generate a complete dynamic settings
  /// panel entry for this field.
  Map<String, dynamic> get fieldSchema => {
        'type': dynamicKeyType,
        'label': label,
        'description': description,
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
final class NumFieldAccess<Number extends num?> extends FieldAccess<Number> {
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
  String get dynamicKeyType => getValue() is double ? 'double' : 'int';

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
  void setValue(Object? value) => setter(value?.typedValue<Number>() as Number);
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

/// A field accessor for a [FieldsHolder] field. e.g. An object that holds
/// multiple fields.
final class ObjectFieldAccess<T extends FieldsHolder> extends FieldAccess<T> {
  /// Constructs a new [ObjectFieldAccess] instance with the given parameters.
  const ObjectFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'bool';

  @override
  void setValue(Object? value) {
    if (value is T) setter(value);
  }
}

/// A field accessor for a [FieldsHolder] field. e.g. An object that holds
/// multiple fields.
final class TextStyleFieldAccess<T extends TextProp> extends FieldAccess<T> {
  /// Constructs a new [TextStyleFieldAccess] instance with the given parameters.
  const TextStyleFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'text-style';

  @override
  void setValue(Object? value) {
    if (T == StartEndProp) {
      final StartEndProp? typedValue = switch (value) {
        Map() => StartEndProp.fromJson(value),
        _ => null,
      };
      if (typedValue != null) setter(typedValue as T);
    } else if (T == TextProp) {
      final TextProp? typedValue = switch (value) {
        Map() => TextProp.fromJson(value),
        _ => null,
      };
      if (typedValue != null) setter(typedValue as T);
    }
  }
}

/// A field accessor for a [IconModel] field.
final class IconFieldAccess extends FieldAccess<MultiSourceIconModel> {
  /// Constructs a new [IconFieldAccess] instance with the given parameters.
  const IconFieldAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    super.defaultValue,
  });

  @override
  String get dynamicKeyType => 'icon';

  @override
  dynamic serialize(MultiSourceIconModel? obj) => obj?.toJson();

  @override
  void setValue(Object? value) {
    if (value is Map) {
      final MultiSourceIconModel typedValue =
          MultiSourceIconModel.fromJson(value);
      setter(typedValue);
    }
    if (value is MultiSourceIconModel) setter(value);
  }
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
  dynamic serialize(T? obj) => obj?.name;

  @override
  Map<String, dynamic> get supplementarySchema => {
        'options': {
          for (final T option in getOptions())
            option.name: option.name.toUpperCase(),
        }
      };

  @override
  void setValue(Object? value) {
    if (value is T) return setter(value);
    final Map<String, T> allValues = getOptions().asNameMap();
    final T? typedValue = allValues[value];
    if (typedValue != null) setter(typedValue);
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
        'properties': nested,
      };

  @override
  Map<String, dynamic> get fieldSchema {
    final List<Object> items = [];
    for (final T item in getValue()) {
      if (item is FieldsHolder) {
        items.add(_wrap(item, item.fieldSchema));
      } else if (item is FieldAccess) {
        items.add(_wrap(item, item.fieldSchema));
      } else {
        throw UnimplementedError();
      }
    }

    return {
      'type': dynamicKeyType,
      'label': label,
      'description': description,
      'items': items,
    };
  }

  @override
  void setValue(Object? value) {
    if (value is! List) return;
    setter(value as List<T>);
  }
}

/// A field accessor for a [ColorRGB] field.
final class ColorFieldAccess<T extends ColorRGB> extends FieldAccess<T?> {
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
  void setValue(Object? value) {
    if (T == ColorRGBA) {
      final ColorRGBA? typedValue = switch (value) {
        Map() || String() => ColorRGBA.fromJson(value),
        _ => value?.typedValue<ColorRGBA>(),
      };
      setter(typedValue as T?);
    } else if (T == ColorRGB) {
      final ColorRGB? typedValue = switch (value) {
        Map() || String() => ColorRGB.fromJson(value),
        _ => value?.typedValue<ColorRGB>(),
      };
      setter(typedValue as T?);
    }
  }
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
  dynamic serialize(CornerRadius? obj) => obj?.toJson();

  @override
  void setValue(Object? value) {
    final CornerRadius? typedValue = switch (value) {
      Map() || List() => CornerRadius.fromJson(value),
      _ => value?.typedValue<CornerRadius>()
    };
    if (typedValue != null) setter(typedValue);
  }
}

/// A field accessor for variants.
final class VariantAccess extends FieldAccess<String> {
  /// Constructs a new [VariantAccess] instance with the given parameters.
  const VariantAccess(
    super.label,
    super.description,
    super.getValue,
    super.setter, {
    required super.defaultValue,
    // Variant ID -> Variant Name.
    required FieldOptionsGetter<String> options,
  }) : getOptions = options;

  /// The options of the field. Variant ID -> Variant Name.
  final FieldOptionsGetter<String> getOptions;

  @override
  String get dynamicKeyType => 'options';

  @override
  dynamic serialize(String? obj) => obj;

  @override
  Map<String, dynamic> get supplementarySchema => {
        'options': {
          for (final String name in getOptions()) name: name,
        },
      };

  @override
  void setValue(Object? value) {
    if (value case String? value) {
      setter(value ?? getDefaultValue!());
    }
  }
}
