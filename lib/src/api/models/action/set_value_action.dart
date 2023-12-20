// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'set_value_action.g.dart';

/// An action that sets value of a property of the node.
@JsonSerializable()
class SetValueAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// ID of the node whose values are to be set.
  final String nodeID;

  /// List of values to be set in the node.
  @JsonKey(fromJson: valuesFromJson)
  final List<ValueModel> values;

  /// Creates a new [SetValueAction].
  SetValueAction({
    required this.nodeID,
    required this.values,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.setValue);

  @override
  List<Object?> get props => [nodeID, values];

  /// Duplicates this [SetValueAction] with given data overrides.
  SetValueAction copyWith({
    String? nodeID,
    List<ValueModel>? values,
  }) =>
      SetValueAction(
        nodeID: nodeID ?? this.nodeID,
        values: values ?? this.values,
      );

  /// Creates a new [SetValueAction] instance from a JSON data.
  factory SetValueAction.fromJson(Map json) => _$SetValueActionFromJson(json);

  @override
  Map toJson() => _$SetValueActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSetValueAction(this);
}

/// Describes how to set the value.
enum SetValueMode {
  /// Sets the value directly.
  discrete,

  /// Toggles the value before setting it.
  /// Only applicable on toggleable values, such as booleans.
  toggle,

  /// Syncs the value with the internal value of the node that is performing the
  /// action. [syncValue] works only if both the values are of same type.
  /// For example, if a checkbox node is performing an action to change the
  /// visibility of a node, the visibility will sync with checkbox's internal
  /// value, i.e., [checked -> visible] and [unchecked -> invisible].
  /// In this case, both the values are of type [bool].
  syncValue;

  /// Displayable string representation of [SetValueMode].
  String get prettify {
    switch (this) {
      case SetValueMode.discrete:
        return 'Set Value';
      case SetValueMode.toggle:
        return 'Toggle Value';
      case SetValueMode.syncValue:
        return 'Sync Value';
    }
  }
}

/// Describes the type of the value.
enum ValueType {
  /// Represents a text value.
  string,

  /// Represents a number without a decimal point.
  int,

  /// Represents a number with a decimal point.
  double,

  /// Represents a boolean value.
  bool,

  /// Represents a color value.
  color,

  /// Represents a paint value which can be color, gradient, etc.
  paint,
}

/// Represents a value to set in a node.
abstract class ValueModel<T extends Object?> with SerializableMixin {
  /// The name of the property to set the value of.
  final String name;

  /// Describes how to set the value.
  final SetValueMode mode;

  /// The value to set.
  final T value;

  /// The type of the value.
  @JsonKey(includeToJson: true)
  final ValueType type;

  /// Creates a new [ValueModel].
  const ValueModel({
    required this.name,
    this.mode = SetValueMode.discrete,
    required this.value,
    required this.type,
  });

  /// Duplicate this [ValueModel] with given data overrides.
  ValueModel copyWith({SetValueMode? mode, T? value});

  /// Whether this [ValueModel] has the same generic type as [other].
  bool hasSameType(ValueModel other) => other is ValueModel<T>;

  /// Creates a new [ValueModel] instance from a JSON data.
  static ValueModel fromJson(Map json) {
    final type = ValueType.values.byName(json['type']);
    switch (type) {
      case ValueType.bool:
        return BoolValue.fromJson(json);
      case ValueType.int:
        return IntValue.fromJson(json);
      case ValueType.double:
        return DoubleValue.fromJson(json);
      case ValueType.string:
        return StringValue.fromJson(json);
      case ValueType.color:
        return ColorValue.fromJson(json);
      case ValueType.paint:
        return PaintValue.fromJson(json);
    }
  }
}

/// A deserializer for list of [ValueModel].
List<ValueModel> valuesFromJson(List values) =>
    values.map((value) => ValueModel.fromJson(value)).toList();

/// Value of boolean type.
@JsonSerializable()
class BoolValue extends ValueModel<bool?> with SerializableMixin {
  /// Whether this property is nullable.
  final bool nullable;

  /// Creates a new [BoolValue].
  const BoolValue({
    required super.name,
    super.mode,
    super.value = false,
    this.nullable = false,
  }) : super(type: ValueType.bool);

  @override
  BoolValue copyWith({
    SetValueMode? mode,
    bool? value,
    bool isNull = false,
    bool? nullable,
  }) =>
      BoolValue(
        name: name,
        mode: mode ?? this.mode,
        value: isNull ? null : (value ?? this.value),
        nullable: nullable ?? this.nullable,
      );

  /// Creates a new [BoolValue] instance from a JSON data.
  factory BoolValue.fromJson(Map json) => _$BoolValueFromJson(json);

  @override
  Map toJson() => _$BoolValueToJson(this);
}

/// Value of integer type.
@JsonSerializable()
class IntValue extends ValueModel<int> with SerializableMixin {
  /// Creates a new [IntValue].
  IntValue({
    required super.name,
    super.mode,
    super.value = 0,
  }) : super(type: ValueType.int) {
    assert(mode != SetValueMode.toggle, '${mode.prettify} mode not supported.');
  }

  /// Creates a new [IntValue] where the default value is 0 and mode is
  /// discrete.
  const IntValue.discreteZero({
    required super.name,
    super.value = 0,
    super.mode,
  }) : super(type: ValueType.int);

  @override
  IntValue copyWith({
    SetValueMode? mode,
    int? value,
  }) =>
      IntValue(
        name: name,
        mode: mode ?? this.mode,
        value: value ?? this.value,
      );

  /// Creates a new [IntValue] instance from a JSON data.
  factory IntValue.fromJson(Map json) => _$IntValueFromJson(json);

  @override
  Map toJson() => _$IntValueToJson(this);
}

/// Value of double type.
@JsonSerializable()
class DoubleValue extends ValueModel<double> with SerializableMixin {
  /// Creates a new [DoubleValue].
  DoubleValue({
    required super.name,
    super.mode,
    super.value = 0,
  }) : super(type: ValueType.double) {
    assert(mode != SetValueMode.toggle, '${mode.prettify} mode not supported.');
  }

  /// Creates a new [DoubleValue] where the default value is 0 and mode is
  /// discrete.
  const DoubleValue.discreteZero({
    required super.name,
    super.value = 0,
    super.mode,
  }) : super(type: ValueType.double);

  @override
  DoubleValue copyWith({
    SetValueMode? mode,
    double? value,
  }) =>
      DoubleValue(
        name: name,
        mode: mode ?? this.mode,
        value: value ?? this.value,
      );

  /// Creates a new [DoubleValue] instance from a JSON data.
  factory DoubleValue.fromJson(Map json) => _$DoubleValueFromJson(json);

  @override
  Map toJson() => _$DoubleValueToJson(this);
}

/// Value of string type.
@JsonSerializable()
class StringValue extends ValueModel<String> with SerializableMixin {
  /// Creates a new [StringValue].
  StringValue({
    required super.name,
    super.mode,
    super.value = '',
  }) : super(type: ValueType.string) {
    assert(mode != SetValueMode.toggle, '${mode.prettify} mode not supported.');
  }

  @override
  StringValue copyWith({
    SetValueMode? mode,
    String? value,
  }) =>
      StringValue(
        name: name,
        mode: mode ?? this.mode,
        value: value ?? this.value,
      );

  /// Creates a new [StringValue] instance from a JSON data.
  factory StringValue.fromJson(Map json) => _$StringValueFromJson(json);

  @override
  Map toJson() => _$StringValueToJson(this);
}

/// Value of boolean type.
@JsonSerializable()
class ColorValue extends ValueModel<ColorRGBA?> with SerializableMixin {
  /// Whether this property is nullable.
  final bool nullable;

  /// Creates a new [ColorValue].
  const ColorValue({
    required super.name,
    super.mode,
    super.value,
    this.nullable = false,
  }) : super(type: ValueType.color);

  @override
  ColorValue copyWith({
    SetValueMode? mode,
    ColorRGBA? value,
    bool isNull = false,
    bool? nullable,
  }) =>
      ColorValue(
        name: name,
        mode: mode ?? this.mode,
        value: isNull ? null : (value ?? this.value),
        nullable: nullable ?? this.nullable,
      );

  /// Creates a new [BoolValue] instance from a JSON data.
  factory ColorValue.fromJson(Map json) => _$ColorValueFromJson(json);

  @override
  Map toJson() => _$ColorValueToJson(this);
}

/// Value of boolean type.
@JsonSerializable()
class PaintValue extends ValueModel<PaintModel?> with SerializableMixin {
  /// Whether this property is nullable.
  final bool nullable;

  /// Creates a new [PaintValue].
  const PaintValue({
    required super.name,
    super.mode,
    super.value,
    this.nullable = false,
  }) : super(type: ValueType.paint);

  @override
  PaintValue copyWith({
    SetValueMode? mode,
    PaintModel? value,
    bool isNull = false,
    bool? nullable,
  }) =>
      PaintValue(
        name: name,
        mode: mode ?? this.mode,
        value: isNull ? null : (value ?? this.value),
        nullable: nullable ?? this.nullable,
      );

  /// Creates a new [BoolValue] instance from a JSON data.
  factory PaintValue.fromJson(Map json) => _$PaintValueFromJson(json);

  @override
  Map toJson() => _$PaintValueToJson(this);
}
