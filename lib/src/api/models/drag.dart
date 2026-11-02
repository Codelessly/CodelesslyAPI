import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'drag.g.dart';

/// The directions a node with a [DragModel] can be dragged in.
enum DragAxis {
  /// Left and right only. A vertical drag is left to a scroll view around
  /// the node.
  horizontal,

  /// Up and down only. A horizontal drag is left to a scroll view around
  /// the node.
  vertical,

  /// Any direction.
  free;

  /// Displayable name.
  String get prettify => switch (this) {
    DragAxis.horizontal => 'Horizontal',
    DragAxis.vertical => 'Vertical',
    DragAxis.free => 'Any direction',
  };
}

/// Makes a node follow the pointer while it is dragged and report the drag:
/// a card that can be pulled aside and either flies off or springs back, a
/// sheet pulled down, a knob dragged along a track.
///
/// While the node is dragged it moves with the pointer (when [follow] is
/// true), tilting by [rotate], and the distance dragged is written into the
/// number variables [xVariable] and [yVariable], so other nodes can react
/// (cards behind a dragged card lifting forward). The node's
/// [TriggerType.drag] reactions run on every move and its
/// [TriggerType.dragEnd] reactions once it is let go, reading
/// `${result.dx}`, `${result.dy}`, `${result.velocityX}`,
/// `${result.velocityY}` (px/s), `${result.dismissed}` and
/// `${result.direction}` (`left`, `right`, `up`, `down`, or empty when it
/// was not dismissed), so a conditional action can decide what happens.
///
/// On release the node either:
///
/// - flies off, when it was dragged past [dismissDistance] (a fraction of
///   its size along the drag) or let go faster than [dismissVelocity]: it
///   moves on to [dismissTo] times its size in the drag's direction over
///   [dismissMs], then the drag end reactions run with `dismissed` true and
///   the node jumps back to rest (by then the actions have usually moved it,
///   e.g. sent a card to the back of the deck);
/// - or springs back to rest over [returnMs] with [returnCurve], while the
///   drag end reactions run with `dismissed` false.
///
/// The offset and tilt are drawn over the node's layout and its motion
/// ([BaseNode.motion]), so the node keeps its place in its parent.
///
/// The `drag.enabled` binding in [BaseNode.variables] turns dragging on and
/// off, e.g. `${= depth == 0}` so only the front card of a deck can be
/// dragged.
@JsonSerializable()
class DragModel with Equatable, SerializableMixin {
  /// The directions the node can be dragged in.
  final DragAxis axis;

  /// Whether the node moves with the pointer. When false the drag is only
  /// reported (to the variables and reactions).
  final bool follow;

  /// Rotation in degrees when the node has been dragged its own width to
  /// the right (negative to the left), in proportion in between: 9 tilts a
  /// card 9° when it is pulled a full width aside.
  final double rotate;

  /// The point the node tilts around, in its box: (-1, -1) is the top
  /// left, (0, 0) the centre, (1, 1) the bottom right.
  final double originX;

  /// See [originX].
  final double originY;

  /// How long the node takes to spring back to rest, in milliseconds.
  final int returnMs;

  /// Easing of the spring back; [MotionCurve.easeOutBack] overshoots a
  /// little like a spring.
  final MotionCurve returnCurve;

  /// How far, as a fraction of the node's size along the drag, the node must
  /// be dragged to fly off when let go. Null: distance never dismisses.
  final double? dismissDistance;

  /// How fast, in logical pixels per second along the drag, the node must be
  /// let go to fly off. Null: speed never dismisses.
  final double? dismissVelocity;

  /// How far the node flies off, as a multiple of its size along the drag.
  final double dismissTo;

  /// How long the fly-off takes, in milliseconds.
  final int dismissMs;

  /// Easing of the fly-off.
  final MotionCurve dismissCurve;

  /// A number variable that holds the horizontal distance dragged, in
  /// logical pixels, while the node is dragged, springs back or flies off;
  /// 0 at rest. Null for none.
  final String? xVariable;

  /// Like [xVariable], for the vertical distance.
  final String? yVariable;

  /// Creates a [DragModel].
  const DragModel({
    this.axis = DragAxis.free,
    this.follow = true,
    this.rotate = 0,
    this.originX = 0,
    this.originY = 0,
    this.returnMs = 260,
    this.returnCurve = MotionCurve.easeOutBack,
    this.dismissDistance,
    this.dismissVelocity,
    this.dismissTo = 1.25,
    this.dismissMs = 240,
    this.dismissCurve = MotionCurve.easeIn,
    this.xVariable,
    this.yVariable,
  });

  /// The key in [BaseNode.variables] whose value turns dragging on (true)
  /// or off (false).
  static const String enabledVariableKey = 'drag.enabled';

  /// Whether the node is dismissed when let go after being dragged
  /// [distance] (a fraction of its size, signed) at [velocity] (px/s,
  /// signed) along an axis.
  bool dismisses({required double distance, required double velocity}) =>
      (dismissDistance != null && distance.abs() >= dismissDistance!) ||
      (dismissVelocity != null && velocity.abs() >= dismissVelocity!);

  /// Returns a copy with the given values replaced.
  DragModel copyWith({
    DragAxis? axis,
    bool? follow,
    double? rotate,
    double? originX,
    double? originY,
    int? returnMs,
    MotionCurve? returnCurve,
    double? dismissDistance,
    bool clearDismissDistance = false,
    double? dismissVelocity,
    bool clearDismissVelocity = false,
    double? dismissTo,
    int? dismissMs,
    MotionCurve? dismissCurve,
    String? xVariable,
    bool clearXVariable = false,
    String? yVariable,
    bool clearYVariable = false,
  }) => DragModel(
    axis: axis ?? this.axis,
    follow: follow ?? this.follow,
    rotate: rotate ?? this.rotate,
    originX: originX ?? this.originX,
    originY: originY ?? this.originY,
    returnMs: returnMs ?? this.returnMs,
    returnCurve: returnCurve ?? this.returnCurve,
    dismissDistance: clearDismissDistance
        ? null
        : dismissDistance ?? this.dismissDistance,
    dismissVelocity: clearDismissVelocity
        ? null
        : dismissVelocity ?? this.dismissVelocity,
    dismissTo: dismissTo ?? this.dismissTo,
    dismissMs: dismissMs ?? this.dismissMs,
    dismissCurve: dismissCurve ?? this.dismissCurve,
    xVariable: clearXVariable ? null : xVariable ?? this.xVariable,
    yVariable: clearYVariable ? null : yVariable ?? this.yVariable,
  );

  @override
  List<Object?> get props => [
    axis,
    follow,
    rotate,
    originX,
    originY,
    returnMs,
    returnCurve,
    dismissDistance,
    dismissVelocity,
    dismissTo,
    dismissMs,
    dismissCurve,
    xVariable,
    yVariable,
  ];

  /// Creates a [DragModel] from JSON.
  factory DragModel.fromJson(Map json) => _$DragModelFromJson(json);

  @override
  Map toJson() => _$DragModelOmitDefaults(this, _$DragModelToJson(this));
}
