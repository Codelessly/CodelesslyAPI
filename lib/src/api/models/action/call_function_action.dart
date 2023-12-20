// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../../codelessly_api.dart';

part 'call_function_action.g.dart';

/// An action that calls a custom function.
@JsonSerializable()
class CallFunctionAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// Name of the custom function to be called.
  final String name;

  /// Parameters to be passed to the function.
  final Map<String, dynamic> params;

  /// Creates a new [CallFunctionAction].
  CallFunctionAction({
    required this.name,
    Map<String, dynamic>? params,
    super.nonBlocking,
    super.enabled,
  })  : params = params ?? {},
        super(type: ActionType.callFunction);

  @override
  List<Object?> get props => [name, params];

  /// Duplicates this [CallFunctionAction] with given data overrides.
  CallFunctionAction copyWith({
    String? name,
    Map<String, dynamic>? params,
  }) =>
      CallFunctionAction(
        name: name ?? this.name,
        params: params ?? this.params,
      );

  /// Creates a new [CallFunctionAction] instance from a JSON object.
  factory CallFunctionAction.fromJson(Map json) =>
      _$CallFunctionActionFromJson(json);

  @override
  Map toJson() => _$CallFunctionActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitCallFunctionAction(this);
}
