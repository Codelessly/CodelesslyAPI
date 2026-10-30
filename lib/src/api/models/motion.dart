import 'dart:math' as math;

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

/// One moment of a [MotionModel]'s keyframes: the values a transition
/// passes through at [t], a share of its time from 0 (start) to 1 (end).
///
/// A value left null isn't keyed here. A value keyed in any keyframe
/// follows a smooth curve from where the transition starts, through each
/// keyframe that names it, to where it ends; the others follow the
/// motion's curve as usual. `[{"t": 0.5, "scale": 1.25}]` swells a node
/// to 1.25 halfway through and settles it back.
@JsonSerializable()
class MotionKeyframe with Equatable, SerializableMixin {
  /// When this keyframe is reached, as a share of the transition's time
  /// (before its curve), between 0 and 1. Keyframes at 0 or 1 or beyond are
  /// ignored: a transition always starts and ends at its own values.
  final double t;

  /// See [MotionModel.translateX].
  final double? translateX;

  /// See [MotionModel.translateY].
  final double? translateY;

  /// See [MotionModel.scale].
  final double? scale;

  /// See [MotionModel.scaleX].
  final double? scaleX;

  /// See [MotionModel.scaleY].
  final double? scaleY;

  /// See [MotionModel.opacity].
  final double? opacity;

  /// See [MotionModel.rotate].
  final double? rotate;

  /// See [MotionModel.rotateX].
  final double? rotateX;

  /// See [MotionModel.rotateY].
  final double? rotateY;

  /// See [MotionModel.pathProgress].
  final double? pathProgress;

  /// Creates a [MotionKeyframe].
  const MotionKeyframe({
    required this.t,
    this.translateX,
    this.translateY,
    this.scale,
    this.scaleX,
    this.scaleY,
    this.opacity,
    this.rotate,
    this.rotateX,
    this.rotateY,
    this.pathProgress,
  });

  /// The names of the values a keyframe can key.
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
    'pathProgress',
  ];

  /// The value this keyframe gives [property], or null when it doesn't key
  /// it.
  double? valueOf(String property) => switch (property) {
    'translateX' => translateX,
    'translateY' => translateY,
    'scale' => scale,
    'scaleX' => scaleX,
    'scaleY' => scaleY,
    'opacity' => opacity,
    'rotate' => rotate,
    'rotateX' => rotateX,
    'rotateY' => rotateY,
    'pathProgress' => pathProgress,
    _ => null,
  };

  /// Returns a copy keyed at [t] instead.
  MotionKeyframe atTime(double t) => withValues(t, values);

  /// The values this keyframe keys, by property name.
  Map<String, double> get values => {
    for (final String p in properties)
      if (valueOf(p) case final double value) p: value,
  };

  /// Returns a copy with [property] keyed to [value], or no longer keyed
  /// when [value] is null.
  MotionKeyframe withValue(String property, double? value) {
    final Map<String, double> next = values..remove(property);
    if (value != null) next[property] = value;
    return withValues(t, next);
  }

  /// A keyframe at [t] keying [values] by property name.
  static MotionKeyframe withValues(double t, Map<String, double> values) =>
      MotionKeyframe(
        t: t,
        translateX: values['translateX'],
        translateY: values['translateY'],
        scale: values['scale'],
        scaleX: values['scaleX'],
        scaleY: values['scaleY'],
        opacity: values['opacity'],
        rotate: values['rotate'],
        rotateX: values['rotateX'],
        rotateY: values['rotateY'],
        pathProgress: values['pathProgress'],
      );

  @override
  List<Object?> get props => [
    t,
    translateX,
    translateY,
    scale,
    scaleX,
    scaleY,
    opacity,
    rotate,
    rotateX,
    rotateY,
    pathProgress,
  ];

  /// Creates a [MotionKeyframe] from JSON.
  factory MotionKeyframe.fromJson(Map json) => _$MotionKeyframeFromJson(json);

  @override
  Map toJson() =>
      _$MotionKeyframeOmitDefaults(this, _$MotionKeyframeToJson(this));
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
  /// (`M0 0 C 80 -160 240 -200 300 -40`). Its coordinates aren't absolute:
  /// the node is moved by the offset of the point at [pathProgress] from the
  /// path's first point (its first `M`), on top of its laid-out position and
  /// [translateX]/[translateY]. So at progress 0 the node sits where it
  /// rests, and a path is easiest to read starting at `M0 0`;
  /// `M100 100 L200 100` moves it exactly like `M0 0 L100 0`. Null for none.
  final String? path;

  /// How far along [path] the node is, from 0 (its start) to 1 (its end),
  /// by arc length. Animated like the other values, so a change glides the
  /// node along the curve. Bindable as `motion.pathProgress`.
  final double pathProgress;

  /// Turns the node to follow the direction of [path] at [pathProgress],
  /// added to [rotate].
  final bool orientToPath;

  /// Values the node passes through during every transition (a value
  /// change, the entrance, a replay, a [pulseKey] pulse, each loop), each at
  /// a share of the transition's time: a card flip that swells at the
  /// halfway point, `[{"t": 0.5, "scale": 1.08}]`, or a sticker whose scale
  /// rises and falls over its flight. Empty for none.
  final List<MotionKeyframe> keyframes;

  /// Plays the [keyframes] once, over [durationMs], from where the node is
  /// back to where it is, whenever this changes: a counter that bumps
  /// (`[{"t": 0.4, "scale": 1.25}]`) each time its value changes. Meant to
  /// be bound through `motion.pulseKey` in [BaseNode.variables], e.g. to
  /// `${count}`.
  final String? pulseKey;

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
    this.keyframes = const [],
    this.pulseKey,
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

  /// The name of the binding that plays the [keyframes] once when its value
  /// changes; see [pulseKey].
  static const String pulseKeyProperty = 'pulseKey';

  /// The names of the settings of the transition that can be bound to
  /// variables, as `motion.<name>` keys of [BaseNode.variables]:
  /// [durationMs] and [delayMs] (numbers) and [curve] (a [MotionCurve]
  /// name such as `elasticOut`), so a node can open with a slow spring and
  /// close quickly: `variables['motion.durationMs'] = '${= open ? 380 :
  /// 160}'`. See [withSetting].
  static const List<String> settings = ['durationMs', 'delayMs', 'curve'];

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

  /// Whether transitions pass through [keyframes].
  bool get hasKeyframes => keyframes.isNotEmpty;

  /// Whether the node animates in when it first appears.
  bool get hasEntrance => enter || enterFrom != null;

  /// Where the entrance starts: these settings with the values [enterFrom]
  /// names, or at rest when there is none. A value [enterFrom] leaves at
  /// rest (its default) keeps this motion's own value, so a node tilted 8°
  /// that enters from `{"opacity": 0}` fades in tilted instead of turning
  /// from 0°.
  ///
  /// [pathProgress] is the exception: a node on a [path] always enters from
  /// [enterFrom]'s progress, 0 (the path's start) unless it names another,
  /// so a star flies along its path to `pathProgress: 1` from
  /// `{"pathProgress": 0}`.
  MotionModel get entranceStart {
    final MotionModel? from = enterFrom;
    if (from == null) return atRest;
    MotionModel start = this;
    for (final String property in properties) {
      if (property == 'spin') continue;
      final double value = from.valueOf(property);
      if (value != none.valueOf(property) ||
          property == 'pathProgress' && hasPath) {
        start = start.withValue(property, value);
      }
    }
    return start;
  }

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
    List<MotionKeyframe>? keyframes,
    String? pulseKey,
    bool clearPulseKey = false,
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
    keyframes: keyframes ?? this.keyframes,
    pulseKey: clearPulseKey ? null : pulseKey ?? this.pulseKey,
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

  /// Returns a copy with the setting [property] (one of [settings]) given by
  /// [value], a bound variable's value: a number (or numeric text) of
  /// milliseconds for [durationMs] and [delayMs], a [MotionCurve] name for
  /// [curve]. Returns this unchanged when [value] doesn't name one.
  MotionModel withSetting(String property, Object? value) {
    switch (property) {
      case 'durationMs' || 'delayMs':
        final double? number = switch (value) {
          num n => n.toDouble(),
          String s => double.tryParse(s.trim()),
          _ => null,
        };
        if (number == null || !number.isFinite) return this;
        final int ms = number.round() < 0 ? 0 : number.round();
        return property == 'durationMs'
            ? copyWith(durationMs: ms)
            : copyWith(delayMs: ms);
      case 'curve':
        final MotionCurve? curve = parseCurve(value);
        return curve == null ? this : copyWith(curve: curve);
      default:
        throw ArgumentError.value(property, 'property');
    }
  }

  /// The curve [value] names: a [MotionCurve] name (`elasticOut`), in any
  /// case and with spaces, dashes or underscores, or its displayed name
  /// (`Elastic`, `Overshoot`). Null when it names none.
  static MotionCurve? parseCurve(Object? value) {
    if (value is MotionCurve) return value;
    if (value == null) return null;
    String simple(String text) =>
        text.toLowerCase().replaceAll(RegExp(r'[\s_,-]'), '');
    final String text = simple(value.toString());
    if (text.isEmpty) return null;
    for (final MotionCurve curve in MotionCurve.values) {
      if (simple(curve.name) == text || simple(curve.prettify) == text) {
        return curve;
      }
    }
    return null;
  }

  /// The value [property] has at [t] (0 to 1, a share of the transition's
  /// time before its curve) in a transition from [from] to [to] that passes
  /// through [keyframes], or null when no keyframe keys [property] (it then
  /// follows the transition's curve).
  ///
  /// The value follows a smooth curve through the start, each keyframe and
  /// the end that doesn't overshoot between them (monotone cubic), so a
  /// single keyframe at 0.5 makes a hump like sin(πt).
  static double? keyframedValue(
    List<MotionKeyframe> keyframes,
    String property,
    double from,
    double to,
    double t,
  ) {
    if (keyframes.isEmpty) return null;
    final List<(double, double)> points = [(0, from)];
    final List<MotionKeyframe> sorted =
        keyframes.where((k) => k.t > 0 && k.t < 1).toList()
          ..sort((a, b) => a.t.compareTo(b.t));
    for (final MotionKeyframe keyframe in sorted) {
      final double? value = keyframe.valueOf(property);
      if (value == null || !value.isFinite) continue;
      if (keyframe.t == points.last.$1) {
        points[points.length - 1] = (keyframe.t, value);
      } else {
        points.add((keyframe.t, value));
      }
    }
    if (points.length == 1) return null;
    points.add((1, to));
    if (t <= 0) return from;
    if (t >= 1) return to;

    final int n = points.length;
    // Slopes of each segment, then a tangent at each point that is flat at a
    // peak or a valley so the curve never overshoots a keyframe.
    final List<double> slopes = [
      for (int i = 0; i < n - 1; i++)
        (points[i + 1].$2 - points[i].$2) / (points[i + 1].$1 - points[i].$1),
    ];
    final List<double> tangents = List.filled(n, 0);
    tangents[0] = slopes.first;
    tangents[n - 1] = slopes.last;
    for (int i = 1; i < n - 1; i++) {
      final double a = slopes[i - 1];
      final double b = slopes[i];
      tangents[i] = a * b <= 0 ? 0 : (a + b) / 2;
    }
    for (int i = 0; i < n - 1; i++) {
      if (slopes[i] == 0) {
        tangents[i] = 0;
        tangents[i + 1] = 0;
        continue;
      }
      final double alpha = tangents[i] / slopes[i];
      final double beta = tangents[i + 1] / slopes[i];
      final double sum = alpha * alpha + beta * beta;
      if (sum > 9) {
        final double tau = 3 / math.sqrt(sum);
        tangents[i] = tau * alpha * slopes[i];
        tangents[i + 1] = tau * beta * slopes[i];
      }
    }

    int i = 0;
    while (i < n - 2 && t > points[i + 1].$1) {
      i++;
    }
    final (double t0, double v0) = points[i];
    final (double t1, double v1) = points[i + 1];
    final double h = t1 - t0;
    final double s = (t - t0) / h;
    final double s2 = s * s;
    final double s3 = s2 * s;
    return (2 * s3 - 3 * s2 + 1) * v0 +
        (s3 - 2 * s2 + s) * h * tangents[i] +
        (-2 * s3 + 3 * s2) * v1 +
        (s3 - s2) * h * tangents[i + 1];
  }

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
    keyframes,
    pulseKey,
  ];

  /// Creates a [MotionModel] from JSON.
  factory MotionModel.fromJson(Map json) => _$MotionModelFromJson(json);

  @override
  Map toJson() {
    final Map json = _$MotionModelOmitDefaults(this, _$MotionModelToJson(this));
    // A node on a path enters from enterFrom's progress even when it is 0
    // (see entranceStart): spell it out so the JSON reads as it plays.
    final MotionModel? from = enterFrom;
    if (from != null && hasPath && json['enterFrom'] is Map) {
      json['enterFrom'] = {
        ...json['enterFrom'] as Map,
        'pathProgress': from.pathProgress,
      };
    }
    return json;
  }
}
