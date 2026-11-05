import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'flip_tilt.g.dart';

/// The axis a [FlipModel] card turns around.
enum FlipAxis {
  /// Turns left and right, like a playing card (around the vertical axis,
  /// [MotionModel.rotateY]).
  y,

  /// Turns top over bottom, like a calendar page (around the horizontal
  /// axis, [MotionModel.rotateX]).
  x;

  /// Displayable name.
  String get prettify => switch (this) {
    FlipAxis.y => 'Left / right',
    FlipAxis.x => 'Top / bottom',
  };
}

/// Makes a node a two-sided card: its first child is the front, its second
/// child the back, and the node turns over to show one or the other.
///
/// The turn is the node's own 3D motion: the SDK sets
/// [MotionModel.rotateY] (or [MotionModel.rotateX] for [FlipAxis.x]) to 0
/// or 180, and takes the perspective, duration, curve and keyframes from
/// the node's [BaseNode.motion] (a flip that swells halfway:
/// `motion.keyframes: [{t: 0.5, scale: 1.06}]`). The faces hide when they
/// face away ([MotionModel.backfaceHidden]) and the back is turned 180° in
/// advance, so it reads the right way round once the card has turned.
///
/// Inside the node, `${flip.flipped}` and `${flip.progress}` (0 front, 1
/// back, live during a drag) can be read.
@JsonSerializable()
class FlipModel with Equatable, SerializableMixin {
  /// The axis the card turns around.
  final FlipAxis axis;

  /// Whether the back shows. Bindable as `variables['flip.flipped']`.
  final bool flipped;

  /// Whether tapping the card turns it over (and writes [variable]).
  final bool tapToFlip;

  /// Whether dragging across the card turns it with the finger; on release
  /// it settles on the nearer face, or follows a fling.
  final bool dragToFlip;

  /// The name of a boolean variable the card follows and that a tap or drag
  /// writes, so a button elsewhere can flip it. Empty for none.
  final String variable;

  /// The spring the card settles with after a drag. PROVISIONAL: see
  /// [TransitionSpring].
  final TransitionSpring spring;

  /// Creates a [FlipModel].
  const FlipModel({
    this.axis = FlipAxis.y,
    this.flipped = false,
    this.tapToFlip = true,
    this.dragToFlip = false,
    this.variable = '',
    this.spring = const TransitionSpring(),
  });

  /// The key in [BaseNode.variables] that binds [flipped].
  static const String flippedKey = 'flip.flipped';

  /// Duplicates this with the given overrides.
  FlipModel copyWith({
    FlipAxis? axis,
    bool? flipped,
    bool? tapToFlip,
    bool? dragToFlip,
    String? variable,
    TransitionSpring? spring,
  }) => FlipModel(
    axis: axis ?? this.axis,
    flipped: flipped ?? this.flipped,
    tapToFlip: tapToFlip ?? this.tapToFlip,
    dragToFlip: dragToFlip ?? this.dragToFlip,
    variable: variable ?? this.variable,
    spring: spring ?? this.spring,
  );

  /// Creates a [FlipModel] from JSON.
  factory FlipModel.fromJson(Map json) => _$FlipModelFromJson(json);

  @override
  Map toJson() => _$FlipModelOmitDefaults(this, _$FlipModelToJson(this));

  @override
  List<Object?> get props => [
    axis,
    flipped,
    tapToFlip,
    dragToFlip,
    variable,
    spring,
  ];
}

/// Tilts a node in 3D toward the pointer while it hovers over it or drags
/// across it, with depth for parallax.
///
/// [max] holds the values the node reaches with the pointer at its edge,
/// and they are [MotionModel] values. The edge under the pointer tips away
/// from the viewer: by [MotionModel.rotateX] with the pointer at the top or
/// bottom edge, and by [MotionModel.rotateY] at the left or right edge,
/// seen with [MotionModel.perspective]. [MotionModel.scale],
/// [MotionModel.translateX] and [MotionModel.translateY] are reached while
/// the pointer is over the node at all (a lift on hover).
///
/// Inside the node, `${tilt.x}` and `${tilt.y}` (-1 to 1, 0 at rest) can
/// be read, so a child can parallax:
/// `motion.translateX: ${= tilt.x * 12}`.
@JsonSerializable()
class TiltModel with Equatable, SerializableMixin {
  /// The values at the edges; see [TiltModel].
  final MotionModel max;

  /// Whether a hovering mouse tilts it.
  final bool hover;

  /// Whether a drag (or a touch held down) tilts it.
  final bool drag;

  /// Milliseconds the node takes to settle back when the pointer leaves.
  final int resetMs;

  /// Easing of the settle back.
  final MotionCurve curve;

  /// Creates a [TiltModel].
  const TiltModel({
    this.max = const MotionModel(rotateX: 10, rotateY: 10, scale: 1.03),
    this.hover = true,
    this.drag = true,
    this.resetMs = 400,
    this.curve = MotionCurve.easeOutCubic,
  });

  /// Duplicates this with the given overrides.
  TiltModel copyWith({
    MotionModel? max,
    bool? hover,
    bool? drag,
    int? resetMs,
    MotionCurve? curve,
  }) => TiltModel(
    max: max ?? this.max,
    hover: hover ?? this.hover,
    drag: drag ?? this.drag,
    resetMs: resetMs ?? this.resetMs,
    curve: curve ?? this.curve,
  );

  /// Creates a [TiltModel] from JSON.
  factory TiltModel.fromJson(Map json) => _$TiltModelFromJson(json);

  @override
  Map toJson() => _$TiltModelOmitDefaults(this, _$TiltModelToJson(this));

  @override
  List<Object?> get props => [max, hover, drag, resetMs, curve];
}
