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
  easeOutCubic;

  /// Displayable name.
  String get prettify => switch (this) {
    MotionCurve.linear => 'Linear',
    MotionCurve.easeInOut => 'Ease in out',
    MotionCurve.easeOut => 'Ease out',
    MotionCurve.easeIn => 'Ease in',
    MotionCurve.easeOutBack => 'Overshoot',
    MotionCurve.easeOutCubic => 'Decelerate',
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

  /// Horizontal offset in multiples of the node's own width, added to
  /// [translateX]: 1 moves it one width right. Lets a layout move by its
  /// own size whatever size it gets, e.g. a chess piece moved `file` squares
  /// across a board that stretches to the screen.
  final double shiftX;

  /// Vertical offset in multiples of the node's own height; see [shiftX].
  final double shiftY;

  /// Horizontal scale, multiplied with [scale]: stretches the node along its
  /// width only (an arrow's shaft grown to a distance).
  final double scaleX;

  /// Vertical scale, multiplied with [scale].
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

  /// How many times a [loop] runs before the node comes to rest; 0 repeats
  /// forever. With [MotionLoop.reverse] one time is there and back, so a
  /// shake is a loop of 3 that plays again whenever its values change.
  final int repeat;

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

  /// Creates a [MotionModel].
  const MotionModel({
    this.translateX = 0,
    this.translateY = 0,
    this.scale = 1,
    this.shiftX = 0,
    this.shiftY = 0,
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
    this.repeat = 0,
    this.enter = false,
    this.enterFrom,
    this.replayKey,
    this.delayMs = 0,
  });

  /// No motion at all.
  static const MotionModel none = MotionModel();

  /// The names of the values that can be bound to variables, as
  /// `motion.<name>` keys of [BaseNode.variables].
  static const List<String> properties = [
    'translateX',
    'translateY',
    'shiftX',
    'shiftY',
    'scale',
    'scaleX',
    'scaleY',
    'opacity',
    'rotate',
    'rotateX',
    'rotateY',
    'spin',
  ];

  /// The name of the binding that replays the entrance when its value
  /// changes; see [replayKey].
  static const String replayKeyProperty = 'replayKey';

  /// The name of the binding that sets [durationMs], e.g. a "piece speed"
  /// setting chosen by the user.
  static const String durationProperty = 'durationMs';

  /// The key in [BaseNode.variables] that binds [property].
  static String variableKey(String property) => 'motion.$property';

  /// Whether this changes how the node is drawn when nothing is bound.
  bool get hasTransform =>
      translateX != 0 ||
      translateY != 0 ||
      shiftX != 0 ||
      shiftY != 0 ||
      scale != 1 ||
      scaleX != 1 ||
      scaleY != 1 ||
      opacity != 1 ||
      rotate != 0 ||
      rotateX != 0 ||
      rotateY != 0;

  /// Whether the node animates in when it first appears.
  bool get hasEntrance => enter || enterFrom != null;

  /// Where the entrance starts: these settings with the transform of
  /// [enterFrom], or at rest when there is none.
  MotionModel get entranceStart => switch (enterFrom) {
    null => atRest,
    MotionModel from => copyWith(
      translateX: from.translateX,
      translateY: from.translateY,
      shiftX: from.shiftX,
      shiftY: from.shiftY,
      scale: from.scale,
      scaleX: from.scaleX,
      scaleY: from.scaleY,
      opacity: from.opacity,
      rotate: from.rotate,
      rotateX: from.rotateX,
      rotateY: from.rotateY,
    ),
  };

  /// The value of [property] in this model.
  double valueOf(String property) => switch (property) {
    'translateX' => translateX,
    'translateY' => translateY,
    'shiftX' => shiftX,
    'shiftY' => shiftY,
    'scale' => scale,
    'scaleX' => scaleX,
    'scaleY' => scaleY,
    'opacity' => opacity,
    'rotate' => rotate,
    'rotateX' => rotateX,
    'rotateY' => rotateY,
    'spin' => spin,
    _ => throw ArgumentError.value(property, 'property'),
  };

  /// Returns a copy with the given values replaced.
  MotionModel copyWith({
    double? translateX,
    double? translateY,
    double? shiftX,
    double? shiftY,
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
    int? repeat,
    bool? enter,
    MotionModel? enterFrom,
    bool clearEnterFrom = false,
    String? replayKey,
    bool clearReplayKey = false,
    int? delayMs,
  }) => MotionModel(
    translateX: translateX ?? this.translateX,
    translateY: translateY ?? this.translateY,
    shiftX: shiftX ?? this.shiftX,
    shiftY: shiftY ?? this.shiftY,
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
    repeat: repeat ?? this.repeat,
    enter: enter ?? this.enter,
    enterFrom: clearEnterFrom ? null : enterFrom ?? this.enterFrom,
    replayKey: clearReplayKey ? null : replayKey ?? this.replayKey,
    delayMs: delayMs ?? this.delayMs,
  );

  /// These settings with every value at rest: no transform at all.
  MotionModel get atRest => copyWith(
    translateX: 0,
    translateY: 0,
    shiftX: 0,
    shiftY: 0,
    scale: 1,
    scaleX: 1,
    scaleY: 1,
    opacity: 1,
    rotate: 0,
    rotateX: 0,
    rotateY: 0,
  );

  /// Returns a copy with [property] set to [value].
  MotionModel withValue(String property, double value) => switch (property) {
    'translateX' => copyWith(translateX: value),
    'translateY' => copyWith(translateY: value),
    'shiftX' => copyWith(shiftX: value),
    'shiftY' => copyWith(shiftY: value),
    'scale' => copyWith(scale: value),
    'scaleX' => copyWith(scaleX: value),
    'scaleY' => copyWith(scaleY: value),
    'opacity' => copyWith(opacity: value.clamp(0, 1).toDouble()),
    'rotate' => copyWith(rotate: value),
    'rotateX' => copyWith(rotateX: value),
    'rotateY' => copyWith(rotateY: value),
    'spin' => copyWith(spin: value),
    _ => throw ArgumentError.value(property, 'property'),
  };

  @override
  List<Object?> get props => [
    translateX,
    translateY,
    shiftX,
    shiftY,
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
    repeat,
    enter,
    enterFrom,
    replayKey,
    delayMs,
  ];

  /// Creates a [MotionModel] from JSON.
  factory MotionModel.fromJson(Map json) => _$MotionModelFromJson(json);

  @override
  Map toJson() => _$MotionModelOmitDefaults(this, _$MotionModelToJson(this));
}
