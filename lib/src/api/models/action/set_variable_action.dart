// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../condition.dart';
import '../variables_model.dart';
import 'action.dart';

part 'set_variable_action.g.dart';

/// Defines the operation to be perfomed on a list type variable.
enum ListOperation {
  /// Replace entire list.
  replace,

  /// Add [newValue] to the list.
  add,

  /// Insert [newValue] at [index] in the list.
  insert,

  /// Remove value at [index] from the list.
  remove,

  /// Update value at [index] with [newValue] in the list.
  update;

  /// Returns a string representation of this enum.
  String get prettify {
    switch (this) {
      case ListOperation.replace:
        return 'Replace';
      case ListOperation.add:
        return 'Add';
      case ListOperation.insert:
        return 'Insert';
      case ListOperation.remove:
        return 'Remove';
      case ListOperation.update:
        return 'Update';
    }
  }
}

/// An action that sets value of a variable.
@JsonSerializable()
class SetVariableAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// Variable whose value is to be set.
  final VariableData variable;

  /// Value that the variable needs to be updated with.
  final String newValue;

  /// Whether to toggle the value of the variable instead of setting it
  /// if the variable is a boolean.
  final bool toggled;

  final ListOperation listOperation;

  /// Index of the value to be updated/removed/inserted.
  /// Can be a discrete value or a variable refered by '${}' syntax.
  /// Used for list type variable.
  final String index;

  /// Creates a new [SetValueAction].
  SetVariableAction({
    required this.variable,
    required this.newValue,
    this.toggled = false,
    this.listOperation = ListOperation.replace,
    this.index = '0',
  }) : super(type: ActionType.setVariable);

  @override
  List<Object?> get props => [variable, newValue];

  /// Duplicates this [SetVariableAction] with given data overrides.
  SetVariableAction copyWith({
    VariableData? variable,
    String? newValue,
    bool? toggled,
    ListOperation? listOperation,
    String? index,
  }) =>
      SetVariableAction(
        variable: variable ?? this.variable,
        newValue: newValue ?? this.newValue,
        toggled: toggled ?? this.toggled,
        listOperation: listOperation ?? this.listOperation,
        index: index ?? this.index,
      );

  /// Creates a new [SetVariableAction] instance from a JSON data.
  factory SetVariableAction.fromJson(Map json) =>
      _$SetVariableActionFromJson(json);

  @override
  Map toJson() => _$SetVariableActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitSetVariableAction(this);
}
