// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../serializable_mixin.dart';
import 'models.dart';

part 'reaction.g.dart';

/// Holds data about a reaction in UI.
@JsonSerializable()
class Reaction with EquatableMixin, SerializableMixin {
  /// Name of the reaction.
  final String name;

  /// Action information about the reaction.
  @JsonKey(fromJson: actionFromJson)
  final ActionModel action;

  /// Trigger information about the reaction.
  final TriggerModel trigger;

  /// Creates a [Reaction] with the given data.
  const Reaction({
    this.name = 'Action',
    required this.action,
    required this.trigger,
  });

  @override
  List<Object?> get props => [name, action, trigger];

  /// Duplicate the current [Reaction] with the given data.
  Reaction copyWith({
    String? name,
    ActionModel? action,
    TriggerModel? trigger,
  }) =>
      Reaction(
        name: name ?? this.name,
        action: action ?? this.action,
        trigger: trigger ?? this.trigger,
      );

  /// Factory constructor for creating a new [Reaction] instance from JSON data.
  factory Reaction.fromJson(Map json) => _$ReactionFromJson(json);

  @override
  Map toJson() => _$ReactionToJson(this);
}

/// A deserializer for [ActionModel]s.
ActionModel actionFromJson(Map json) {
  final ActionType type = ActionModel.fromJson(json).type;
  switch (type) {
    case ActionType.navigation:
      return NavigationAction.fromJson(json);
    case ActionType.link:
      return LinkAction.fromJson(json);
    case ActionType.submit:
      return SubmitAction.fromJson(json);
    case ActionType.setValue:
      return SetValueAction.fromJson(json);
    case ActionType.setVariant:
      return SetVariantAction.fromJson(json);
    case ActionType.callFunction:
      return CallFunctionAction.fromJson(json);
  }
}
