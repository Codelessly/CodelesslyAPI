// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../condition.dart';
import '../variables_model.dart';
import 'action.dart';

part 'set_variable_action.g.dart';

/// An action that sets value of a variable.
@JsonSerializable()
class SetVariableAction extends ActionModel
    with EquatableMixin, SerializableMixin
    implements DataOperationInterface {
  /// Variable whose value is to be set.
  final VariableData variable;

  @override
  final String index;

  @override
  final ListOperation listOperation;

  @override
  final String mapKey;

  @override
  final MapOperation mapOperation;

  @override
  final String newValue;

  @override
  final bool toggled;

  @override
  final NumberOperation numberOperation;

  /// Creates a new [SetValueAction].
  SetVariableAction({
    required this.variable,
    this.newValue = '',
    this.toggled = false,
    this.listOperation = ListOperation.replace,
    this.index = '0',
    this.mapOperation = MapOperation.replace,
    this.mapKey = 'key',
    this.numberOperation = NumberOperation.set,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.setVariable);

  @override
  List<Object?> get props => [
        variable,
        newValue,
        toggled,
        listOperation,
        index,
        mapOperation,
        mapKey,
        numberOperation,
      ];

  /// Duplicates this [SetVariableAction] with given data overrides.
  SetVariableAction copyWith({
    VariableData? variable,
    String? newValue,
    bool? toggled,
    ListOperation? listOperation,
    String? index,
    MapOperation? mapOperation,
    String? mapKey,
    NumberOperation? numberOperation,
  }) =>
      SetVariableAction(
        variable: variable ?? this.variable,
        newValue: newValue ?? this.newValue,
        toggled: toggled ?? this.toggled,
        listOperation: listOperation ?? this.listOperation,
        index: index ?? this.index,
        mapOperation: mapOperation ?? this.mapOperation,
        mapKey: mapKey ?? this.mapKey,
        numberOperation: numberOperation ?? this.numberOperation,
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
