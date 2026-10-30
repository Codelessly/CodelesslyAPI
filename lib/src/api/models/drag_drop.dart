import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'drag_drop.g.dart';

/// What stays in a draggable node's place while it is dragged.
enum DragLeaveBehavior {
  /// The node stays as it is.
  keep,

  /// The node is drawn faded ([DraggableModel.ghostOpacity]): a ghost of
  /// where it came from.
  ghost,

  /// The node is invisible but keeps its space.
  hidden;

  /// Displayable name.
  String get prettify => switch (this) {
    DragLeaveBehavior.keep => 'Keep',
    DragLeaveBehavior.ghost => 'Ghost',
    DragLeaveBehavior.hidden => 'Hide',
  };
}

/// Which way a draggable node may move.
enum DragAxisLock {
  /// Anywhere.
  free,

  /// Left and right only.
  horizontal,

  /// Up and down only.
  vertical;

  /// Displayable name.
  String get prettify => switch (this) {
    DragAxisLock.free => 'Free',
    DragAxisLock.horizontal => 'Horizontal',
    DragAxisLock.vertical => 'Vertical',
  };
}

/// Makes a node draggable onto drop targets ([DropTargetModel]), carrying
/// [data] with it: a letter tile dragged onto a slot, a card dragged to
/// another column, a file dragged onto a folder.
///
/// While dragged, a copy of the node follows the pointer (scaled by
/// [feedbackScale], turned by [feedbackRotation], with
/// [feedbackOpacity]) and the node itself does what [whileDragging] says.
/// Let go over a drop target that accepts it, the target's drop reactions
/// run with the data; let go anywhere else (or on a target that rejects
/// it) and, with [returnSpring], the node springs back from where it was
/// let go to its place.
///
/// The node's own reactions can use the triggers `dragStart` (picked up),
/// `dragCompleted` (a target accepted it) and `dragCanceled` (let go
/// without being accepted).
///
/// [data] is bindable through `draggable.data` in [BaseNode.variables],
/// e.g. `${item}` in a list item to drag the item itself; [enabled]
/// through `draggable.enabled`.
@JsonSerializable()
class DraggableModel with Equatable, SerializableMixin {
  /// Whether the node can be dragged now.
  final bool enabled;

  /// What a drop target receives as `${drop.data}`. Plain text here;
  /// bind `draggable.data` for a value (a list item, a map).
  final String data;

  /// A tag drop targets can require ([DropTargetModel.groups]); empty
  /// means any target that doesn't require a group.
  final String group;

  /// Scale of the copy that follows the pointer; 1 is the node's size.
  final double feedbackScale;

  /// Rotation of the copy that follows the pointer, in degrees.
  final double feedbackRotation;

  /// Opacity of the copy that follows the pointer.
  final double feedbackOpacity;

  /// Whether the copy that follows the pointer casts a soft shadow, as if
  /// lifted.
  final bool feedbackShadow;

  /// What is left in the node's place while it is dragged.
  final DragLeaveBehavior whileDragging;

  /// Opacity of the node in its place while dragged with
  /// [DragLeaveBehavior.ghost].
  final double ghostOpacity;

  /// Which way the node may move.
  final DragAxisLock axis;

  /// How long the node must be pressed before it lifts, in milliseconds.
  /// 0 starts the drag as soon as the pointer moves; a delay lets a list
  /// under it still scroll on touch.
  final int longPressMs;

  /// Whether the node springs back to its place from wherever it was let
  /// go when no target accepts it. Off, it reappears in place at once.
  final bool returnSpring;

  /// Stiffness of the return spring: higher snaps back faster.
  final double springStiffness;

  /// Damping of the return spring: lower wobbles more.
  final double springDamping;

  /// Creates a [DraggableModel].
  const DraggableModel({
    this.enabled = true,
    this.data = '',
    this.group = '',
    this.feedbackScale = 1.1,
    this.feedbackRotation = 0,
    this.feedbackOpacity = 1,
    this.feedbackShadow = true,
    this.whileDragging = DragLeaveBehavior.ghost,
    this.ghostOpacity = 0.3,
    this.axis = DragAxisLock.free,
    this.longPressMs = 0,
    this.returnSpring = true,
    this.springStiffness = 260,
    this.springDamping = 14,
  });

  /// The key in [BaseNode.variables] that binds [data].
  static const String dataVariable = 'draggable.data';

  /// The key in [BaseNode.variables] that binds [enabled].
  static const String enabledVariable = 'draggable.enabled';

  /// Returns a copy with the given values replaced.
  DraggableModel copyWith({
    bool? enabled,
    String? data,
    String? group,
    double? feedbackScale,
    double? feedbackRotation,
    double? feedbackOpacity,
    bool? feedbackShadow,
    DragLeaveBehavior? whileDragging,
    double? ghostOpacity,
    DragAxisLock? axis,
    int? longPressMs,
    bool? returnSpring,
    double? springStiffness,
    double? springDamping,
  }) => DraggableModel(
    enabled: enabled ?? this.enabled,
    data: data ?? this.data,
    group: group ?? this.group,
    feedbackScale: feedbackScale ?? this.feedbackScale,
    feedbackRotation: feedbackRotation ?? this.feedbackRotation,
    feedbackOpacity: feedbackOpacity ?? this.feedbackOpacity,
    feedbackShadow: feedbackShadow ?? this.feedbackShadow,
    whileDragging: whileDragging ?? this.whileDragging,
    ghostOpacity: ghostOpacity ?? this.ghostOpacity,
    axis: axis ?? this.axis,
    longPressMs: longPressMs ?? this.longPressMs,
    returnSpring: returnSpring ?? this.returnSpring,
    springStiffness: springStiffness ?? this.springStiffness,
    springDamping: springDamping ?? this.springDamping,
  );

  @override
  List<Object?> get props => [
    enabled,
    data,
    group,
    feedbackScale,
    feedbackRotation,
    feedbackOpacity,
    feedbackShadow,
    whileDragging,
    ghostOpacity,
    axis,
    longPressMs,
    returnSpring,
    springStiffness,
    springDamping,
  ];

  /// Creates a [DraggableModel] from JSON.
  factory DraggableModel.fromJson(Map json) => _$DraggableModelFromJson(json);

  @override
  Map toJson() =>
      _$DraggableModelOmitDefaults(this, _$DraggableModelToJson(this));
}

/// Makes a node a place draggable nodes ([DraggableModel]) can be dropped
/// on: a slot a letter tile snaps into, a column a card moves to.
///
/// While something is dragged over it, the node and everything inside it
/// can read `${drop.hovering}` (true), `${drop.data}` (what is dragged)
/// and `${drop.accepts}` (whether letting go here would be accepted), e.g.
/// to light the slot up.
///
/// Let go over it, it accepts the drop when the draggable's group is one
/// of [groups] (or [groups] is empty) and [acceptIf] (a condition that can
/// read `${drop.data}`) is true or empty. Its `drop` reactions then run;
/// otherwise its `dropRejected` reactions run and the draggable springs
/// back. Both see `${drop.data}`, and `${drop.dx}` / `${drop.dy}`: how far
/// the dragged copy's top left was from this node's top left when it was
/// let go (in logical pixels). `dragEnter` / `dragExit` reactions run as
/// something is dragged in and out.
///
/// A drop can fly into place: give the draggable and the node that shows
/// the dropped content the same [BaseNode.flightKey] (see there).
///
/// [acceptIf] is bindable through `dropTarget.acceptIf`, [enabled] through
/// `dropTarget.enabled`.
@JsonSerializable()
class DropTargetModel with Equatable, SerializableMixin {
  /// Whether the node takes drops now.
  final bool enabled;

  /// The [DraggableModel.group]s this node takes; empty takes any.
  final List<String> groups;

  /// A condition the drop must meet, e.g.
  /// `${= drop.data.letter == word[index]}`. Empty accepts every drop.
  final String acceptIf;

  /// Whether to take nothing while it already holds something: when the
  /// condition in [fullIf] is true, nothing can be dropped (no hover, no
  /// reactions), e.g. a slot that already has its letter.
  final String fullIf;

  /// Creates a [DropTargetModel].
  const DropTargetModel({
    this.enabled = true,
    this.groups = const [],
    this.acceptIf = '',
    this.fullIf = '',
  });

  /// The key in [BaseNode.variables] that binds [acceptIf].
  static const String acceptIfVariable = 'dropTarget.acceptIf';

  /// The key in [BaseNode.variables] that binds [fullIf].
  static const String fullIfVariable = 'dropTarget.fullIf';

  /// The key in [BaseNode.variables] that binds [enabled].
  static const String enabledVariable = 'dropTarget.enabled';

  /// Returns a copy with the given values replaced.
  DropTargetModel copyWith({
    bool? enabled,
    List<String>? groups,
    String? acceptIf,
    String? fullIf,
  }) => DropTargetModel(
    enabled: enabled ?? this.enabled,
    groups: groups ?? this.groups,
    acceptIf: acceptIf ?? this.acceptIf,
    fullIf: fullIf ?? this.fullIf,
  );

  @override
  List<Object?> get props => [enabled, groups, acceptIf, fullIf];

  /// Creates a [DropTargetModel] from JSON.
  factory DropTargetModel.fromJson(Map json) =>
      _$DropTargetModelFromJson(json);

  @override
  Map toJson() =>
      _$DropTargetModelOmitDefaults(this, _$DropTargetModelToJson(this));
}
