import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../generate_id.dart';
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

  /// Unique id of the reaction.
  final String id;

  /// Creates a [Reaction] with the given data.
  Reaction({
    String? id,
    this.name = 'Action',
    required this.action,
    required this.trigger,
  }) : id = id ?? generateId();

  @override
  List<Object?> get props => [id, name, action, trigger];

  /// Duplicate the current [Reaction] with the given data.
  Reaction copyWith({
    String? id,
    String? name,
    ActionModel? action,
    TriggerModel? trigger,
  }) =>
      Reaction(
        id: id ?? this.id,
        name: name ?? this.name,
        action: action ?? this.action,
        trigger: trigger ?? this.trigger,
      );

  /// Factory constructor for creating a new [Reaction] instance from JSON data.
  factory Reaction.fromJson(Map json) => _$ReactionFromJson(json);

  @override
  Map toJson() => _$ReactionToJson(this);

  /// Sanitize the [Reaction] by removing the [id] and replacing it with a
  /// new one if [changeIds] is true.
  Reaction sanitize({required bool changeIds}) {
    return copyWith(
      id: changeIds ? generateId() : id,
    );
  }
}
