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

/// An action that sets value of a variable.
@JsonSerializable()
class SetVariableAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// Variable whose value is to be set.
  final VariableData variable;

  /// Value that the variable needs to be updated with.
  final String newValue;

  /// Creates a new [SetValueAction].
  SetVariableAction({
    required this.variable,
    required this.newValue,
  }) : super(type: ActionType.setVariable);

  @override
  List<Object?> get props => [variable, newValue];

  /// Duplicates this [SetVariableAction] with given data overrides.
  SetVariableAction copyWith({
    VariableData? variable,
    String? newValue,
  }) =>
      SetVariableAction(
        variable: variable ?? this.variable,
        newValue: newValue ?? this.newValue,
      );

  /// Creates a new [SetVariableAction] instance from a JSON data.
  factory SetVariableAction.fromJson(Map json) =>
      _$SetVariableActionFromJson(json);

  @override
  Map toJson() => _$SetVariableActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSetVariableAction(this);
}
