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

  /// The threshold for up and down, when it differs from
  /// [distanceThreshold] (a fraction of the node's height): a card that
  /// skips with a shorter swipe up than it grades sideways. Null uses
  /// [distanceThreshold].
  final double? verticalThreshold;

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

  /// How much a disabled node still follows the pointer, from 0 (not at
  /// all) to 1: 0.3 lets a card that can't be graded yet move a little
  /// before it springs back. Its drag end reactions then get
  /// `result.blocked` true, e.g. to show a "flip me first" hint.
  final double disabledFollow;

  /// Extra turn, in degrees, a node takes as it flies off: clockwise when
  /// it leaves right (or down), counter-clockwise when it leaves left (or
  /// up).
  final double flyOutRotate;

  /// The name of a variable that mirrors the live drag (the same map as the
  /// `drag` variable inside the node: dx, dy, left, right, up, down,
  /// progress, direction, dragging), so nodes outside the dragged one can
  /// follow it too: a background that tints as a card is dragged. Empty for
  /// none.
  final String shareAs;

  /// Where the node rests horizontally, in logical pixels from where its
  /// layout puts it. Bind it through `drag.restX` (and [restY] through
  /// `drag.restY`) to hold a card mid-drag from data, or to make it peek;
  /// it springs back there, and moves there when the value changes.
  final double restX;

  /// Where the node rests vertically. See [restX].
  final double restY;

  /// Makes the node a value control instead of a free drag: it moves along
  /// this track (a line, an arc it rotates through, or a path) and reads
  /// and writes a variable. [axis], [release] and the dismiss settings don't
  /// apply then. See [DragTrackModel].
  final DragTrackModel? track;

  /// Makes the node the drag handle of a row in a data list: dragging it
  /// lifts the row and moves it among the others (the list becomes
  /// reorderable). Dropping it runs the node's `reorder` reactions with
  /// `${result.from}` and `${result.to}`, the row's old and new index, so a
  /// Set Variable can store the new order (`${= move(songs, result.from,
  /// result.to)}`). The other drag settings don't apply.
  final bool reorder;

  /// Whether the node moves with the pointer. When false the drag is only
  /// reported (to [xVariable], [yVariable], the `drag` variable and the
  /// reactions) and the node stays put: a handle that drives something
  /// else.
  final bool follow;

  /// How far the node flies off when dismissed, as a multiple of its size
  /// along the direction it leaves in (1.25 clears its own box). Null flies
  /// it off the screen.
  final double? flyOutDistance;

  /// The easing of the fly-off.
  final MotionCurve flyOutCurve;

  /// A number variable that holds the horizontal distance dragged, in
  /// logical pixels, while the node is dragged, springs back or flies off;
  /// 0 at rest. Empty for none. Unlike [shareAs] it holds just the number,
  /// for formulas such as `${= abs(deckDrag) / 300}`.
  final String xVariable;

  /// Like [xVariable], for the vertical distance.
  final String yVariable;

  /// How the node moves on its own after release: a fling with friction,
  /// a spring settle with the release velocity, snap points and overscroll
  /// at the bounds. Null keeps the curve-timed [snapBackMs] / [snapCurve]
  /// release. With physics, [DragRelease.snapBack] springs to rest,
  /// [DragRelease.stay] flings and settles (on a [PhysicsModel.snap] target
  /// when it has one) and [DragRelease.dismiss] springs back below its
  /// threshold. See [effectivePhysics].
  final PhysicsModel? physics;

  /// What the node is kept inside of while dragged and flung: its parent's
  /// box ([GestureBounds.contain], [GestureBounds.cover]) or nothing.
  /// [minX], [maxX], [minY] and [maxY] narrow it further.
  @JsonKey(unknownEnumValue: GestureBounds.none)
  final GestureBounds bounds;

  /// The leftmost offset from rest, in pixels; null for no limit.
  final double? minX;

  /// The rightmost offset from rest; null for no limit.
  final double? maxX;

  /// The highest offset from rest (negative is up); null for no limit. A
  /// bottom sheet that opens 560px: `minY: -560, maxY: 0`.
  final double? minY;

  /// The lowest offset from rest; null for no limit.
  final double? maxY;

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
    this.verticalThreshold,
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
    this.disabledFollow = 0,
    this.flyOutRotate = 0,
    this.shareAs = '',
    this.restX = 0,
    this.restY = 0,
    this.track,
    this.reorder = false,
    this.follow = true,
    this.flyOutDistance,
    this.flyOutCurve = MotionCurve.easeIn,
    this.xVariable = '',
    this.yVariable = '',
    this.physics,
    this.bounds = GestureBounds.none,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
  });

  /// Whether the drag is kept inside limits.
  bool get hasBounds =>
      bounds != GestureBounds.none ||
      minX != null ||
      maxX != null ||
      minY != null ||
      maxY != null;

  /// The physics of the release: [physics], or what the first release
  /// settings amount to: a [MotionCurve.spring] snap back is a spring that
  /// settles in [snapBackMs] with a little bounce. Null for a curve-timed
  /// release (any other [snapCurve]), which keeps animating on its curve.
  PhysicsModel? get effectivePhysics {
    if (physics != null) return physics;
    if (snapCurve == MotionCurve.spring) {
      return PhysicsModel(bounce: 0.25, durationMs: snapBackMs, fling: false);
    }
    return null;
  }

  /// The key in [BaseNode.variables] that binds [enabled].
  static const String enabledVariableKey = 'drag.enabled';

  /// The key in [BaseNode.variables] that binds [restX].
  static const String restXVariableKey = 'drag.restX';

  /// The key in [BaseNode.variables] that binds [restY].
  static const String restYVariableKey = 'drag.restY';

  /// The fraction of the node's size a drag toward [direction] must travel
  /// to dismiss.
  double thresholdFor(DragDirection direction) =>
      direction == DragDirection.up || direction == DragDirection.down
      ? verticalThreshold ?? distanceThreshold
      : distanceThreshold;

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
    'settling',
    'snapIndex',
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
    double? verticalThreshold,
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
    double? disabledFollow,
    double? flyOutRotate,
    String? shareAs,
    double? restX,
    double? restY,
    DragTrackModel? track,
    bool clearTrack = false,
    bool? follow,
    double? flyOutDistance,
    bool clearFlyOutDistance = false,
    MotionCurve? flyOutCurve,
    String? xVariable,
    String? yVariable,
    bool? reorder,
    PhysicsModel? physics,
    bool clearPhysics = false,
    GestureBounds? bounds,
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    bool clearLimits = false,
  }) => DragModel(
    axis: axis ?? this.axis,
    release: release ?? this.release,
    directions: directions ?? this.directions,
    distanceThreshold: distanceThreshold ?? this.distanceThreshold,
    verticalThreshold: verticalThreshold ?? this.verticalThreshold,
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
    disabledFollow: disabledFollow ?? this.disabledFollow,
    flyOutRotate: flyOutRotate ?? this.flyOutRotate,
    shareAs: shareAs ?? this.shareAs,
    restX: restX ?? this.restX,
    restY: restY ?? this.restY,
    track: clearTrack ? null : (track ?? this.track),
    reorder: reorder ?? this.reorder,
    follow: follow ?? this.follow,
    flyOutDistance: clearFlyOutDistance
        ? null
        : flyOutDistance ?? this.flyOutDistance,
    flyOutCurve: flyOutCurve ?? this.flyOutCurve,
    xVariable: xVariable ?? this.xVariable,
    yVariable: yVariable ?? this.yVariable,
    physics: clearPhysics ? null : physics ?? this.physics,
    bounds: bounds ?? this.bounds,
    minX: clearLimits ? minX : minX ?? this.minX,
    maxX: clearLimits ? maxX : maxX ?? this.maxX,
    minY: clearLimits ? minY : minY ?? this.minY,
    maxY: clearLimits ? maxY : maxY ?? this.maxY,
  );

  @override
  List<Object?> get props => [
    axis,
    release,
    directions,
    distanceThreshold,
    verticalThreshold,
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
    disabledFollow,
    flyOutRotate,
    shareAs,
    restX,
    restY,
    track,
    reorder,
    follow,
    flyOutDistance,
    flyOutCurve,
    xVariable,
    yVariable,
    physics,
    bounds,
    minX,
    maxX,
    minY,
    maxY,
  ];

  /// Creates a [DragModel] from JSON.
  ///
  /// Also reads the first drag format (Meridian's), whose keys are mapped
  /// onto these: `rotate` is [rotateFactor], `returnMs` and `returnCurve`
  /// are [snapBackMs] and [snapCurve], `dismissDistance` and
  /// `dismissVelocity` make it [DragRelease.dismiss] with those thresholds
  /// (a missing one never dismisses), `dismissTo`, `dismissMs` and
  /// `dismissCurve` are [flyOutDistance], [flyOutMs] and [flyOutCurve].
  factory DragModel.fromJson(Map json) =>
      _$DragModelFromJson(migrateLegacyJson(json));

  /// The keys only the first drag format had.
  static const Set<String> legacyKeys = {
    'rotate',
    'returnMs',
    'returnCurve',
    'dismissDistance',
    'dismissVelocity',
    'dismissTo',
    'dismissMs',
    'dismissCurve',
  };

  /// Rewrites JSON in the first drag format (see [DragModel.fromJson]) into
  /// this one. JSON without its keys is returned as is.
  static Map migrateLegacyJson(Map json) {
    if (!json.keys.any(legacyKeys.contains)) return json;
    final Map out = {
      for (final MapEntry entry in json.entries)
        if (!legacyKeys.contains(entry.key)) entry.key: entry.value,
    };
    // The first format's defaults, which its JSON left out.
    out['snapBackMs'] = json['returnMs'] ?? 260;
    out['snapCurve'] = json['returnCurve'] ?? MotionCurve.easeOutBack.name;
    out['flyOutMs'] = json['dismissMs'] ?? 240;
    out['flyOutCurve'] = json['dismissCurve'] ?? MotionCurve.easeIn.name;
    out['flyOutDistance'] = json['dismissTo'] ?? 1.25;
    if (json['rotate'] != null) out['rotateFactor'] = json['rotate'];
    final Object? distance = json['dismissDistance'];
    final Object? velocity = json['dismissVelocity'];
    if (distance != null || velocity != null) {
      out['release'] = DragRelease.dismiss.name;
      // A threshold the first format left out never dismissed.
      out['distanceThreshold'] = distance ?? double.maxFinite;
      out['velocityThreshold'] = velocity ?? double.maxFinite;
    }
    return out;
  }

  @override
  Map toJson() => _$DragModelOmitDefaults(this, _$DragModelToJson(this));
}
