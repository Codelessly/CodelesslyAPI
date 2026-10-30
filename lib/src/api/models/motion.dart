import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'motion.g.dart';

/// The easing a [MotionModel] transition follows.
enum MotionCurve {
  /// Constant speed.
  linear,

  /// Starts slow, ends slow.
  easeInOut,

  /// Starts fast, ends slow.
  easeOut,

  /// Starts slow, ends fast.
  easeIn,

  /// Overshoots a little and settles, like a spring.
  easeOutBack,

  /// A fast cubic deceleration.
  easeOutCubic,

  /// Springs past the target and settles with a few small wobbles, like a
  /// card snapping back into place.
  spring,

  /// A stronger, rubbery overshoot that oscillates before settling.
  elasticOut,

  /// Bounces off the target like a dropped ball.
  bounceOut,

  /// Material-style fast start and long, gentle settle.
  fastOutSlowIn;

  /// Displayable name.
  String get prettify => switch (this) {
    MotionCurve.linear => 'Linear',
    MotionCurve.easeInOut => 'Ease in out',
    MotionCurve.easeOut => 'Ease out',
    MotionCurve.easeIn => 'Ease in',
    MotionCurve.easeOutBack => 'Overshoot',
    MotionCurve.easeOutCubic => 'Decelerate',
    MotionCurve.spring => 'Spring',
    MotionCurve.elasticOut => 'Elastic',
    MotionCurve.bounceOut => 'Bounce',
    MotionCurve.fastOutSlowIn => 'Fast out, slow in',
  };
}

/// Whether a [MotionModel] repeats on its own.
enum MotionLoop {
  /// Moves only when its values change.
  none,

  /// From rest to its values, then jumps back to rest and starts again.
  restart,

  /// From rest to its values and back, over and over (a pulse).
  reverse;

  /// Displayable name.
  String get prettify => switch (this) {
    MotionLoop.none => 'No loop',
    MotionLoop.restart => 'Loop',
    MotionLoop.reverse => 'Back and forth',
  };
}

/// How a node moves: a transform drawn on top of its layout (it never changes
/// the space the node takes up), an animated transition whenever a value
/// changes, and an optional continuous spin.
///
/// Every value can be bound to a variable or formula through
/// [BaseNode.variables] using the property names in [MotionModel.properties]
/// (for example `variables['motion.rotateX'] = '${= front - index}'`), so a
/// motion can follow app state: a sleeve tips forward when it is flipped, a
/// tonearm swings in as a side plays, a platter spins while it is playing.
@JsonSerializable()
class MotionModel with Equatable, SerializableMixin {
  /// Horizontal offset in logical pixels.
  final double translateX;

  /// Vertical offset in logical pixels.
  final double translateY;

  /// Uniform scale; 1 is the node's own size.
  final double scale;

  /// Horizontal scale on top of [scale]: a bar growing from its left edge
  /// (origin -1, 0) from 0 to 1.
  final double scaleX;

  /// Vertical scale on top of [scale].
  final double scaleY;

  /// Opacity from 0 (invisible) to 1, animated like the other values, on
  /// top of the node's own opacity.
  final double opacity;

  /// Rotation in the plane, in degrees. Unlike [BaseNode.rotationDegrees]
  /// this doesn't change the node's layout box, accepts fractions and can be
  /// animated.
  final double rotate;

  /// Tilt around the horizontal axis, in degrees. Positive tips the top
  /// toward the viewer.
  final double rotateX;

  /// Tilt around the vertical axis, in degrees. Positive turns the right
  /// edge toward the viewer.
  final double rotateY;

  /// Depth of the 3D tilt: the larger, the stronger the perspective.
  /// 0 draws tilts flat (orthographic).
  final double perspective;

  /// The point everything scales, rotates and tilts around, in the node's
  /// box: (-1, -1) is the top left, (0, 0) the centre, (1, 1) the bottom
  /// right.
  final double originX;

  /// See [originX].
  final double originY;

  /// Duration of the animation when any value changes, in milliseconds.
  /// 0 jumps straight to the new values.
  final int durationMs;

  /// Easing of the transition.
  final MotionCurve curve;

  /// Continuous rotation in turns per second (0.555 is 33⅓ rpm). 0 stops.
  /// Changes in speed ease in and out over [spinRampMs], like a motor
  /// coming up to speed.
  final double spin;

  /// How long the spin takes to reach a new speed, in milliseconds.
  final int spinRampMs;

  /// Repeats the motion on its own, between the node at rest (no
  /// transform) and these values, each way over [durationMs]: a skeleton's
  /// pulse, a blinking cursor.
  final MotionLoop loop;

  /// Animates from rest (or from [enterFrom]) to these values when the node
  /// first appears, over [durationMs], instead of starting there: a record
  /// sliding out of its sleeve when the screen opens.
  final bool enter;

  /// Where the entrance starts instead of rest: its offset, scale, opacity,
  /// rotation and tilts (its other settings are ignored). Setting it plays
  /// an entrance even when [enter] is false: a record fading and settling in
  /// from `{"scale": 1.15, "opacity": 0}`.
  final MotionModel? enterFrom;

  /// Plays the entrance again, from [enterFrom] or rest, whenever this
  /// changes. Meant to be bound through `motion.replayKey` in
  /// [BaseNode.variables] to any value, for example `${playingId}`, so
  /// loading another record replays its entrance.
  final String? replayKey;

  /// Waits this long, in milliseconds, before a transition, entrance or
  /// loop starts, so motions can be staggered.
  final int delayMs;

  /// Paints the node only while its front faces the viewer, judged by its
  /// whole transform on screen (a rotating parent counts), like CSS
  /// `backface-visibility: hidden`. Two faces of a flip card set it, the
  /// back one turned 180° around Y, inside a frame that rotates.
  final bool backfaceHidden;

  /// A path the node moves along, as SVG path data in logical pixels
  /// relative to the node's rest position (`M0 0 C 80 -160 240 -200 300 -40`).
  /// [pathProgress] says how far along it the node is. Null for none.
  final String? path;

  /// How far along [path] the node is, from 0 (its start) to 1 (its end),
  /// by arc length. Animated like the other values, so a change glides the
  /// node along the curve. Bindable as `motion.pathProgress`.
  final double pathProgress;

  /// Turns the node to follow the direction of [path] at [pathProgress],
  /// added to [rotate].
  final bool orientToPath;

  /// Creates a [MotionModel].
  const MotionModel({
    this.translateX = 0,
    this.translateY = 0,
    this.scale = 1,
    this.scaleX = 1,
    this.scaleY = 1,
    this.opacity = 1,
    this.rotate = 0,
    this.rotateX = 0,
    this.rotateY = 0,
    this.perspective = 1,
    this.originX = 0,
    this.originY = 0,
    this.durationMs = 0,
    this.curve = MotionCurve.easeInOut,
    this.spin = 0,
    this.spinRampMs = 800,
    this.loop = MotionLoop.none,
    this.enter = false,
    this.enterFrom,
    this.replayKey,
    this.delayMs = 0,
    this.backfaceHidden = false,
    this.path,
    this.pathProgress = 0,
    this.orientToPath = false,
  });

  /// No motion at all.
  static const MotionModel none = MotionModel();

  /// The names of the values that can be bound to variables, as
  /// `motion.<name>` keys of [BaseNode.variables].
  static const List<String> properties = [
    'translateX',
    'translateY',
    'scale',
    'scaleX',
    'scaleY',
    'opacity',
    'rotate',
    'rotateX',
    'rotateY',
    'spin',
    'pathProgress',
  ];

  /// The name of the binding that replays the entrance when its value
  /// changes; see [replayKey].
  static const String replayKeyProperty = 'replayKey';

  /// The name of the binding that gives [path] from a variable or formula
  /// (text), e.g. a curve built from the screen's width.
  static const String pathProperty = 'path';

  /// The key in [BaseNode.variables] that binds [property].
  static String variableKey(String property) => 'motion.$property';

  /// Whether this changes how the node is drawn when nothing is bound.
  bool get hasTransform =>
      translateX != 0 ||
      translateY != 0 ||
      scale != 1 ||
      scaleX != 1 ||
      scaleY != 1 ||
      opacity != 1 ||
      rotate != 0 ||
      rotateX != 0 ||
      rotateY != 0 ||
      backfaceHidden ||
      hasPath;

  /// Whether the node moves along a [path].
  bool get hasPath => path != null && path!.trim().isNotEmpty;

  /// Whether the node animates in when it first appears.
  bool get hasEntrance => enter || enterFrom != null;

  /// Where the entrance starts: these settings with the transform of
  /// [enterFrom], or at rest when there is none.
  MotionModel get entranceStart => switch (enterFrom) {
    null => atRest,
    MotionModel from => copyWith(
      translateX: from.translateX,
      translateY: from.translateY,
      scale: from.scale,
      scaleX: from.scaleX,
      scaleY: from.scaleY,
      opacity: from.opacity,
      rotate: from.rotate,
      rotateX: from.rotateX,
      rotateY: from.rotateY,
      pathProgress: from.pathProgress,
    ),
  };

  /// The value of [property] in this model.
  double valueOf(String property) => switch (property) {
    'translateX' => translateX,
    'translateY' => translateY,
    'scale' => scale,
    'scaleX' => scaleX,
    'scaleY' => scaleY,
    'opacity' => opacity,
    'rotate' => rotate,
    'rotateX' => rotateX,
    'rotateY' => rotateY,
    'spin' => spin,
    'pathProgress' => pathProgress,
    _ => throw ArgumentError.value(property, 'property'),
  };

  /// Returns a copy with the given values replaced.
  MotionModel copyWith({
    double? translateX,
    double? translateY,
    double? scale,
    double? scaleX,
    double? scaleY,
    double? opacity,
    double? rotate,
    double? rotateX,
    double? rotateY,
    double? perspective,
    double? originX,
    double? originY,
    int? durationMs,
    MotionCurve? curve,
    double? spin,
    int? spinRampMs,
    MotionLoop? loop,
    bool? enter,
    MotionModel? enterFrom,
    bool clearEnterFrom = false,
    String? replayKey,
    bool clearReplayKey = false,
    int? delayMs,
    bool? backfaceHidden,
    String? path,
    bool clearPath = false,
    double? pathProgress,
    bool? orientToPath,
  }) => MotionModel(
    translateX: translateX ?? this.translateX,
    translateY: translateY ?? this.translateY,
    scale: scale ?? this.scale,
    scaleX: scaleX ?? this.scaleX,
    scaleY: scaleY ?? this.scaleY,
    opacity: opacity ?? this.opacity,
    rotate: rotate ?? this.rotate,
    rotateX: rotateX ?? this.rotateX,
    rotateY: rotateY ?? this.rotateY,
    perspective: perspective ?? this.perspective,
    originX: originX ?? this.originX,
    originY: originY ?? this.originY,
    durationMs: durationMs ?? this.durationMs,
    curve: curve ?? this.curve,
    spin: spin ?? this.spin,
    spinRampMs: spinRampMs ?? this.spinRampMs,
    loop: loop ?? this.loop,
    enter: enter ?? this.enter,
    enterFrom: clearEnterFrom ? null : enterFrom ?? this.enterFrom,
    replayKey: clearReplayKey ? null : replayKey ?? this.replayKey,
    delayMs: delayMs ?? this.delayMs,
    backfaceHidden: backfaceHidden ?? this.backfaceHidden,
    path: clearPath ? null : path ?? this.path,
    pathProgress: pathProgress ?? this.pathProgress,
    orientToPath: orientToPath ?? this.orientToPath,
  );

  /// These settings with every value at rest: no transform at all.
  MotionModel get atRest => copyWith(
    translateX: 0,
    translateY: 0,
    scale: 1,
    scaleX: 1,
    scaleY: 1,
    opacity: 1,
    rotate: 0,
    rotateX: 0,
    rotateY: 0,
    pathProgress: 0,
  );

  /// Returns a copy with [property] set to [value].
  MotionModel withValue(String property, double value) => switch (property) {
    'translateX' => copyWith(translateX: value),
    'translateY' => copyWith(translateY: value),
    'scale' => copyWith(scale: value),
    'scaleX' => copyWith(scaleX: value),
    'scaleY' => copyWith(scaleY: value),
    'opacity' => copyWith(opacity: value.clamp(0, 1).toDouble()),
    'rotate' => copyWith(rotate: value),
    'rotateX' => copyWith(rotateX: value),
    'rotateY' => copyWith(rotateY: value),
    'spin' => copyWith(spin: value),
    'pathProgress' => copyWith(pathProgress: value),
    _ => throw ArgumentError.value(property, 'property'),
  };

  @override
  List<Object?> get props => [
    translateX,
    translateY,
    scale,
    scaleX,
    scaleY,
    opacity,
    rotate,
    rotateX,
    rotateY,
    perspective,
    originX,
    originY,
    durationMs,
    curve,
    spin,
    spinRampMs,
    loop,
    enter,
    enterFrom,
    replayKey,
    delayMs,
    backfaceHidden,
    path,
    pathProgress,
    orientToPath,
  ];

  /// Creates a [MotionModel] from JSON.
  factory MotionModel.fromJson(Map json) => _$MotionModelFromJson(json);

  @override
  Map toJson() => _$MotionModelOmitDefaults(this, _$MotionModelToJson(this));
}
