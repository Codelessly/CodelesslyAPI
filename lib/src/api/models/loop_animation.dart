import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'loop_animation.g.dart';

/// What a [LoopAnimation] animates.
enum LoopAnimationType {
  /// Scales the node from [LoopAnimation.scaleFrom] to
  /// [LoopAnimation.scaleTo] while fading it from [LoopAnimation.opacityFrom]
  /// to [LoopAnimation.opacityTo]: a halo that grows and fades out.
  pulse,

  /// Fades the node from [LoopAnimation.opacityFrom] to
  /// [LoopAnimation.opacityTo]: a skeleton bar that breathes.
  fade,

  /// Scales the node from [LoopAnimation.scaleFrom] to
  /// [LoopAnimation.scaleTo].
  scale,

  /// Rotates the node by [LoopAnimation.turns] full turns each cycle: a
  /// spinner.
  spin,

  /// Hops up [LoopAnimation.distance] pixels and lands, over and over: a
  /// bouncing ball, letters doing a wave.
  bob,

  /// Rocks [LoopAnimation.angle] degrees either way and back, like a
  /// pendulum.
  sway;

  /// Displayable string representation of the type.
  String get prettify => switch (this) {
    LoopAnimationType.pulse => 'Pulse',
    LoopAnimationType.fade => 'Fade',
    LoopAnimationType.scale => 'Scale',
    LoopAnimationType.spin => 'Spin',
    LoopAnimationType.bob => 'Bob',
    LoopAnimationType.sway => 'Sway',
  };

  /// Whether this type animates the node's scale.
  bool get scales => this == pulse || this == scale;

  /// Whether this type animates the node's opacity.
  bool get fades => this == pulse || this == fade;
}

/// The easing curve of a [LoopAnimation]. Mirrors Flutter's `Curves`.
enum LoopAnimationCurve {
  /// `Curves.linear`.
  linear,

  /// `Curves.easeIn`.
  easeIn,

  /// `Curves.easeOut`.
  easeOut,

  /// `Curves.easeInOut`.
  easeInOut,

  /// `Curves.fastOutSlowIn`.
  fastOutSlowIn,

  /// `Curves.decelerate`.
  decelerate;

  /// Displayable string representation of the curve.
  String get prettify => switch (this) {
    LoopAnimationCurve.linear => 'Linear',
    LoopAnimationCurve.easeIn => 'Ease In',
    LoopAnimationCurve.easeOut => 'Ease Out',
    LoopAnimationCurve.easeInOut => 'Ease In Out',
    LoopAnimationCurve.fastOutSlowIn => 'Fast Out Slow In',
    LoopAnimationCurve.decelerate => 'Decelerate',
  };
}

/// An animation that repeats for as long as its node is shown: a pulsing
/// halo, a breathing skeleton bar, a spinning icon.
///
/// Each cycle runs from the `from` values to the `to` values in
/// [durationMs]. With [reverse], it then runs back to the `from` values;
/// otherwise it jumps back and starts over.
///
/// The node's own opacity, rotation and size stay as designed; the animated
/// values multiply them. The design canvas holds the animation still at its
/// `from` values; previews and published apps run it.
///
/// Bind the node's `loopAnimationEnabled` variable to turn it on and off at
/// runtime.
@JsonSerializable()
class LoopAnimation with Equatable, SerializableMixin {
  /// What this animation animates.
  @JsonKey(unknownEnumValue: LoopAnimationType.pulse)
  final LoopAnimationType type;

  /// Whether the animation runs. A disabled animation leaves the node as
  /// designed.
  final bool enabled;

  /// How long one cycle takes, in milliseconds. With [reverse], running back
  /// takes as long again.
  final int durationMs;

  /// How long to wait before the first cycle, in milliseconds.
  final int delayMs;

  /// Whether each cycle runs back to the `from` values instead of jumping
  /// back to them.
  final bool reverse;

  /// The easing curve of each cycle.
  @JsonKey(unknownEnumValue: LoopAnimationCurve.linear)
  final LoopAnimationCurve curve;

  /// The scale at the start of a cycle, for [LoopAnimationType.pulse] and
  /// [LoopAnimationType.scale]. The node scales about its center.
  final double scaleFrom;

  /// The scale at the end of a cycle.
  final double scaleTo;

  /// The opacity at the start of a cycle, for [LoopAnimationType.pulse] and
  /// [LoopAnimationType.fade].
  final double opacityFrom;

  /// The opacity at the end of a cycle.
  final double opacityTo;

  /// How many full turns the node rotates each cycle, for
  /// [LoopAnimationType.spin]. Negative turns rotate counterclockwise.
  final double turns;

  /// How high the node hops each cycle, in logical pixels, for
  /// [LoopAnimationType.bob].
  final double distance;

  /// How far the node rocks either way, in degrees, for
  /// [LoopAnimationType.sway].
  final double angle;

  /// Creates a [LoopAnimation].
  const LoopAnimation({
    required this.type,
    this.enabled = true,
    this.durationMs = 1000,
    this.delayMs = 0,
    this.reverse = false,
    this.curve = LoopAnimationCurve.linear,
    this.scaleFrom = 1,
    this.scaleTo = 1,
    this.opacityFrom = 1,
    this.opacityTo = 1,
    this.turns = 1,
    this.distance = 10,
    this.angle = 4,
  });

  /// A [LoopAnimation] of [type] with values that show it off: a halo that
  /// grows and fades out, a bar that breathes, a node that spins once a
  /// second.
  factory LoopAnimation.preset(LoopAnimationType type) => switch (type) {
    LoopAnimationType.pulse => const LoopAnimation(
      type: LoopAnimationType.pulse,
      durationMs: 1400,
      curve: LoopAnimationCurve.easeOut,
      scaleFrom: 0.65,
      scaleTo: 1,
      opacityFrom: 0.35,
      opacityTo: 0,
    ),
    LoopAnimationType.fade => const LoopAnimation(
      type: LoopAnimationType.fade,
      durationMs: 900,
      reverse: true,
      curve: LoopAnimationCurve.easeInOut,
      opacityFrom: 0.45,
      opacityTo: 1,
    ),
    LoopAnimationType.scale => const LoopAnimation(
      type: LoopAnimationType.scale,
      durationMs: 900,
      reverse: true,
      curve: LoopAnimationCurve.easeInOut,
      scaleFrom: 1,
      scaleTo: 1.1,
    ),
    LoopAnimationType.spin => const LoopAnimation(type: LoopAnimationType.spin),
    LoopAnimationType.bob => const LoopAnimation(
      type: LoopAnimationType.bob,
      durationMs: 1600,
    ),
    LoopAnimationType.sway => const LoopAnimation(
      type: LoopAnimationType.sway,
      durationMs: 2600,
    ),
  };

  /// Duplicates this instance with the given data overrides.
  LoopAnimation copyWith({
    LoopAnimationType? type,
    bool? enabled,
    int? durationMs,
    int? delayMs,
    bool? reverse,
    LoopAnimationCurve? curve,
    double? scaleFrom,
    double? scaleTo,
    double? opacityFrom,
    double? opacityTo,
    double? turns,
    double? distance,
    double? angle,
  }) => LoopAnimation(
    type: type ?? this.type,
    enabled: enabled ?? this.enabled,
    durationMs: durationMs ?? this.durationMs,
    delayMs: delayMs ?? this.delayMs,
    reverse: reverse ?? this.reverse,
    curve: curve ?? this.curve,
    scaleFrom: scaleFrom ?? this.scaleFrom,
    scaleTo: scaleTo ?? this.scaleTo,
    opacityFrom: opacityFrom ?? this.opacityFrom,
    opacityTo: opacityTo ?? this.opacityTo,
    turns: turns ?? this.turns,
    distance: distance ?? this.distance,
    angle: angle ?? this.angle,
  );

  @override
  List<Object?> get props => [
    type,
    enabled,
    durationMs,
    delayMs,
    reverse,
    curve,
    scaleFrom,
    scaleTo,
    opacityFrom,
    opacityTo,
    turns,
    distance,
    angle,
  ];

  /// Creates a [LoopAnimation] from JSON data.
  factory LoopAnimation.fromJson(Map json) => _$LoopAnimationFromJson(json);

  @override
  Map toJson() =>
      _$LoopAnimationOmitDefaults(this, _$LoopAnimationToJson(this));
}
