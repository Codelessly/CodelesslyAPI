import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'play_animation_action.g.dart';

/// Plays a node's one-shot animation: one of its [EffectAnimation]s by
/// name, or its [ParticleEmitter] with the name `particles`. Every shown
/// instance of the node plays it (to play one item of a list, bind the
/// animation's `playKey` instead).
///
/// It waits until the animation ends unless it is non-blocking, so the
/// next action can follow the animation.
@JsonSerializable()
class PlayAnimationAction extends ActionModel
    with Equatable, SerializableMixin {
  /// The node whose animation plays.
  final String nodeId;

  /// The animation's [EffectAnimation.name], or `particles`.
  final String animation;

  /// Creates a [PlayAnimationAction].
  PlayAnimationAction({
    this.nodeId = '',
    this.animation = '',
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.playAnimation);

  /// Duplicates this action with the given values replaced.
  PlayAnimationAction copyWith({String? nodeId, String? animation}) =>
      PlayAnimationAction(
        nodeId: nodeId ?? this.nodeId,
        animation: animation ?? this.animation,
        nonBlocking: nonBlocking,
        enabled: enabled,
      );

  @override
  List<Object?> get props => [nodeId, animation];

  /// Creates an instance from a JSON object.
  factory PlayAnimationAction.fromJson(Map json) =>
      _$PlayAnimationActionFromJson(json);

  @override
  Map toJson() => _$PlayAnimationActionOmitDefaults(
    this,
    _$PlayAnimationActionToJson(this),
  );

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitPlayAnimationAction(this);
}
