import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'drag.g.dart';

/// Which ways a [DragModel] node can be dragged.
enum DragAxis {
  /// Any direction.
  free,

  /// Left and right only.
  horizontal,

  /// Up and down only.
  vertical;

  /// Displayable name.
  String get prettify => switch (this) {
    DragAxis.free => 'Free',
    DragAxis.horizontal => 'Horizontal',
    DragAxis.vertical => 'Vertical',
  };
}

/// What a [DragModel] node does when the pointer lets go.
enum DragRelease {
  /// Springs back to where it rests.
  snapBack,

  /// Stays where it was dropped.
  stay,

  /// Flies off in the direction it was thrown when it went past
  /// [DragModel.distanceThreshold] or was flung faster than
  /// [DragModel.velocityThreshold] in one of [DragModel.directions], and
  /// fires that direction's swipe trigger; otherwise springs back.
  dismiss;

  /// Displayable name.
  String get prettify => switch (this) {
    DragRelease.snapBack => 'Snap back',
    DragRelease.stay => 'Stay',
    DragRelease.dismiss => 'Dismiss (fly off)',
  };
}

/// A direction a node can be dragged or dismissed in.
enum DragDirection {
  /// Toward the left edge.
  left,

  /// Toward the right edge.
  right,

  /// Toward the top edge.
  up,

  /// Toward the bottom edge.
  down;

  /// The swipe trigger fired when a node is dismissed this way.
  TriggerType get swipeTrigger => switch (this) {
    DragDirection.left => TriggerType.swipeLeft,
    DragDirection.right => TriggerType.swipeRight,
    DragDirection.up => TriggerType.swipeUp,
    DragDirection.down => TriggerType.swipeDown,
  };

  /// Unit vector of this direction in screen coordinates (y points down).
  (double, double) get unit => switch (this) {
    DragDirection.left => (-1, 0),
    DragDirection.right => (1, 0),
    DragDirection.up => (0, -1),
    DragDirection.down => (0, 1),
  };

  /// Displayable name.
  String get prettify => switch (this) {
    DragDirection.left => 'Left',
    DragDirection.right => 'Right',
    DragDirection.up => 'Up',
    DragDirection.down => 'Down',
  };
}

/// Makes a node draggable: it follows the pointer as a transform drawn on
/// top of its layout (like [MotionModel], so the space it takes up never
/// changes), tilts as it goes, and on release springs back, stays, or flies
/// off and fires a swipe trigger.
///
/// While dragged, the node and everything inside it read the drag through
/// the `drag` variable: `drag.dx`, `drag.dy`, `drag.left`, `drag.right`,
/// `drag.up`, `drag.down` (0 to 1 progress toward dismissing that way),
/// `drag.progress` (the largest of those), `drag.direction` and
/// `drag.dragging`, so an overlay can fade in with
/// `opacity: ${drag.right}` without any actions.
///
/// A swipeable card deck is a stacked list whose item has a dismissing drag;
/// a swipe-to-delete row is a horizontal drag dismissing left; a bottom
/// sheet is a vertical drag that snaps back. [ControlDragAction] flings,
/// returns or resets a drag from an action.
@JsonSerializable()
class DragModel with Equatable, SerializableMixin {
  /// Which ways the node moves.
  final DragAxis axis;

  /// What happens on release.
  final DragRelease release;

  /// The directions [DragRelease.dismiss] may fly off in. Dragging the
  /// other ways is held back by [resistance] and always springs back.
  final List<DragDirection> directions;

  /// How far, as a fraction of the node's width (left and right) or height
  /// (up and down), a drag must go to dismiss on release.
  final double distanceThreshold;

  /// How fast, in logical pixels per second, a shorter drag must be flung
  /// toward an allowed direction to dismiss.
  final double velocityThreshold;

  /// Degrees the node tilts per node-width of horizontal drag: 15 tips a
  /// card 15° when it has moved its own width, the way swipe cards do.
  final double rotateFactor;

  /// The point the tilt turns around, in the node's box: (-1, -1) top left,
  /// (0, 0) centre, (1, 1) bottom right. Values past 1 pivot outside the
  /// box; (0, 1.6) swings a card like a hand holding its bottom.
  final double originX;

  /// See [originX].
  final double originY;

  /// How much a direction that can't dismiss (or the off axis) resists, from
  /// 0 (moves freely) to 1 (doesn't move). In between it stretches like a
  /// rubber band.
  final double resistance;

  /// How long the spring back takes, in milliseconds.
  final int snapBackMs;

  /// The easing of the spring back.
  final MotionCurve snapCurve;

  /// How long the node takes to fly off, in milliseconds.
  final int flyOutMs;

  /// Whether the drag works. Bind it through `drag.enabled` in
  /// [BaseNode.variables] (for example `${flipped}`) so a card can only be
  /// swiped once its answer shows. A disabled drag doesn't move the node.
  final bool enabled;

  /// When a disabled node is dragged, shakes it sideways once as a hint.
  final bool shakeWhenDisabled;

  /// Makes the node a value control instead of a free drag: it moves along
  /// this track (a line, an arc it rotates through, or a path) and reads
  /// and writes a variable. [axis], [release] and the dismiss settings don't
  /// apply then. See [DragTrackModel].
  final DragTrackModel? track;

  /// Creates a [DragModel].
  const DragModel({
    this.axis = DragAxis.free,
    this.release = DragRelease.snapBack,
    this.directions = const [
      DragDirection.left,
      DragDirection.right,
      DragDirection.up,
      DragDirection.down,
    ],
    this.distanceThreshold = 0.35,
    this.velocityThreshold = 800,
    this.rotateFactor = 0,
    this.originX = 0,
    this.originY = 0,
    this.resistance = 0,
    this.snapBackMs = 450,
    this.snapCurve = MotionCurve.spring,
    this.flyOutMs = 320,
    this.enabled = true,
    this.shakeWhenDisabled = false,
    this.track,
  });

  /// The key in [BaseNode.variables] that binds [enabled].
  static const String enabledVariableKey = 'drag.enabled';

  /// The names of the live values the `drag` variable has.
  static const List<String> liveValues = [
    'dx',
    'dy',
    'left',
    'right',
    'up',
    'down',
    'progress',
    'direction',
    'dragging',
    'dismissed',
  ];

  /// Whether a release can fly off toward [direction].
  bool canDismiss(DragDirection direction) =>
      release == DragRelease.dismiss &&
      directions.contains(direction) &&
      switch (axis) {
        DragAxis.free => true,
        DragAxis.horizontal =>
          direction == DragDirection.left || direction == DragDirection.right,
        DragAxis.vertical =>
          direction == DragDirection.up || direction == DragDirection.down,
      };

  /// Returns a copy with the given values replaced.
  DragModel copyWith({
    DragAxis? axis,
    DragRelease? release,
    List<DragDirection>? directions,
    double? distanceThreshold,
    double? velocityThreshold,
    double? rotateFactor,
    double? originX,
    double? originY,
    double? resistance,
    int? snapBackMs,
    MotionCurve? snapCurve,
    int? flyOutMs,
    bool? enabled,
    bool? shakeWhenDisabled,
    DragTrackModel? track,
    bool clearTrack = false,
  }) => DragModel(
    axis: axis ?? this.axis,
    release: release ?? this.release,
    directions: directions ?? this.directions,
    distanceThreshold: distanceThreshold ?? this.distanceThreshold,
    velocityThreshold: velocityThreshold ?? this.velocityThreshold,
    rotateFactor: rotateFactor ?? this.rotateFactor,
    originX: originX ?? this.originX,
    originY: originY ?? this.originY,
    resistance: resistance ?? this.resistance,
    snapBackMs: snapBackMs ?? this.snapBackMs,
    snapCurve: snapCurve ?? this.snapCurve,
    flyOutMs: flyOutMs ?? this.flyOutMs,
    enabled: enabled ?? this.enabled,
    shakeWhenDisabled: shakeWhenDisabled ?? this.shakeWhenDisabled,
    track: clearTrack ? null : (track ?? this.track),
  );

  @override
  List<Object?> get props => [
    axis,
    release,
    directions,
    distanceThreshold,
    velocityThreshold,
    rotateFactor,
    originX,
    originY,
    resistance,
    snapBackMs,
    snapCurve,
    flyOutMs,
    enabled,
    shakeWhenDisabled,
    track,
  ];

  /// Creates a [DragModel] from JSON.
  factory DragModel.fromJson(Map json) => _$DragModelFromJson(json);

  @override
  Map toJson() => _$DragModelOmitDefaults(this, _$DragModelToJson(this));
}
