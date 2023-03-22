// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import 'action.dart';

part 'set_value_action.g.dart';

/// An action that sets a value to a property on a node.
@JsonSerializable()
class SetValueAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// ID of the node to set the value on.
  final String nodeID;

  /// Values to set on the node.
  @JsonKey(fromJson: valuesFromJson)
  final List<ValueModel> values;

  /// Creates a new [SetValueAction].
  SetValueAction({
    required this.nodeID,
    required this.values,
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
}

/// Describes how to set the value.
enum SetValueMode {
  /// Sets the value directly.
  discrete,

  /// Toggles the value before setting it. Only applies to toggleable values
  /// like booleans.
  toggle,

  ///
  syncValue;

  /// Displayable string representation of this enum.
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

/// Represents a value to set on a node.
abstract class ValueModel<T> with SerializableMixin {
  /// The name of the property to set the value on.
  final String name;

  /// Describes how to set the value.
  final SetValueMode mode;

  /// The value to set.
  final T value;

  /// Creates a new [ValueModel].
  const ValueModel({
    required this.name,
    this.mode = SetValueMode.discrete,
    required this.value,
  });

  /// Duplicate this [ValueModel] with given data overrides.
  ValueModel copyWith({SetValueMode? mode, T? value});

  /// Whether this [ValueModel] has the same generic type as [other].
  bool hasSameType(ValueModel other) => other is ValueModel<T>;

  /// Creates a new [ValueModel] instance from a JSON data.
  static ValueModel fromJson(Map json) {
    final value = json['value'];
    if (value is bool?) return BoolValue.fromJson(json);
    if (value is int) return IntValue.fromJson(json);
    if (value is double) return DoubleValue.fromJson(json);
    if (value is String) return StringValue.fromJson(json);
    return IntValue.fromJson(json);
  }
}

/// A deserializer for list of [ValueModel].
List<ValueModel> valuesFromJson(List values) =>
    values.map((value) => ValueModel.fromJson(value)).toList();

/// A boolean type of value.
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
  });

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

/// An integer type of value.
@JsonSerializable()
class IntValue extends ValueModel<int> with SerializableMixin {
  /// Creates a new [IntValue].
  IntValue({
    required super.name,
    super.mode,
    super.value = 0,
  }) {
    assert(mode != SetValueMode.toggle, '${mode.prettify} mode not supported.');
  }

  /// Creates a new [IntValue] where the default value is 0 and mode is discrete.
  const IntValue.discreteZero({
    required super.name,
    super.value = 0,
    super.mode,
  });

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

/// A double type of value.
@JsonSerializable()
class DoubleValue extends ValueModel<double> with SerializableMixin {
  /// Creates a new [DoubleValue].
  DoubleValue({
    required super.name,
    super.mode,
    super.value = 0,
  }) {
    assert(mode != SetValueMode.toggle, '${mode.prettify} mode not supported.');
  }

  /// Creates a new [DoubleValue] where the default value is 0 and mode is discrete.
  const DoubleValue.discreteZero({
    required super.name,
    super.value = 0,
    super.mode,
  });

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

/// A string type of value.
@JsonSerializable()
class StringValue extends ValueModel<String> with SerializableMixin {
  /// Creates a new [StringValue].
  StringValue({
    required super.name,
    super.mode,
    super.value = '',
  }) {
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
