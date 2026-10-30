import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'control_drag_action.g.dart';

/// What a [ControlDragAction] does to a draggable node.
enum DragCommand {
  /// Flies the node off toward [ControlDragAction.direction] as if it had
  /// been swiped that way, then fires that direction's swipe trigger: grade
  /// buttons and arrow keys under a swipe card.
  fling,

  /// Flies the node in from [ControlDragAction.direction] to where it
  /// rests: a card coming back on undo.
  returnFrom,

  /// Springs the node back to where it rests.
  reset;

  /// Displayable name.
  String get prettify => switch (this) {
    DragCommand.fling => 'Fling (swipe)',
    DragCommand.returnFrom => 'Return from',
    DragCommand.reset => 'Reset',
  };
}

/// Moves a node that has a [DragModel] from an action, as if it had been
/// dragged: flings it off, brings it back or resets it. When the node is
/// built more than once (in a list), the instance whose drag is enabled is
/// moved, e.g. the top card of a deck.
@JsonSerializable()
class ControlDragAction extends ActionModel with Equatable, SerializableMixin {
  /// The id of the node with the drag.
  final String nodeId;

  /// What to do.
  final DragCommand command;

  /// The direction to fling toward or return from.
  final DragDirection direction;

  /// Creates a [ControlDragAction].
  ControlDragAction({
    this.nodeId = '',
    this.command = DragCommand.fling,
    this.direction = DragDirection.right,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.controlDrag);

  /// Duplicates this action with the given values replaced.
  ControlDragAction copyWith({
    String? nodeId,
    DragCommand? command,
    DragDirection? direction,
  }) => ControlDragAction(
    nodeId: nodeId ?? this.nodeId,
    command: command ?? this.command,
    direction: direction ?? this.direction,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [nodeId, command, direction];

  /// Creates an instance from a JSON object.
  factory ControlDragAction.fromJson(Map json) =>
      _$ControlDragActionFromJson(json);

  @override
  Map toJson() =>
      _$ControlDragActionOmitDefaults(this, _$ControlDragActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitControlDragAction(this);
}
