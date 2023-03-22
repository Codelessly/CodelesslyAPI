// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../codelessly_api.dart';

part 'call_function_action.g.dart';

/// An action that calls a custom function.
@JsonSerializable()
class CallFunctionAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// Name of the custom function to be called.
  final String name;

  /// Creates a new [CallFunctionAction].
  CallFunctionAction({
    required this.name,
  }) : super(type: ActionType.callFunction);

  @override
  List<Object?> get props => [name];

  /// Duplicates this [CallFunctionAction] with given data overrides.
  CallFunctionAction copyWith({String? name}) =>
      CallFunctionAction(name: name ?? this.name);

  /// Creates a new [CallFunctionAction] instance from a JSON object.
  factory CallFunctionAction.fromJson(Map json) =>
      _$CallFunctionActionFromJson(json);

  @override
  Map toJson() => _$CallFunctionActionToJson(this);
}
