// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'reaction.g.dart';

/// [Reaction] holds the action and the trigger which performs the action.
@JsonSerializable()
class Reaction with EquatableMixin, SerializableMixin {
  /// Name of the reaction.
  final String name;

  /// Action to be performed.
  final ActionModel action;

  /// Event that will trigger the action.
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
