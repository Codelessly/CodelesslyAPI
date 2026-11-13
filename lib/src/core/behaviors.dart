// What a node does beyond its layout and paint: how it moves (motion,
// animations, transitions), how it reacts (ink, interaction states, drag and
// drop, tooltip) and the one-shot effects it plays. Each is an immutable
// value with total decoding and sparse encoding; all of them together are a
// node's [Behaviors], stored flat in the node's JSON (`"motion": {...}`,
// `"tooltip": "..."`).
//
// Durations are whole milliseconds (`duration`, `delay`).
import 'dart:convert' show jsonDecode;
import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'custom_paint.dart';
import 'json.dart';
import 'path_follow.dart';
import 'values/color.dart';
import 'values/enums.dart';
import 'values/geometry.dart';
import 'values/text.dart';

part 'animation.dart';
part 'animation_presets.dart';
part 'gestures.dart';

/// An easing curve, by the name of its Flutter `Curves` constant. `spring`
/// is a damped spring (see [Motion.spring]); `step` jumps half way.
enum AnimationCurve {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  easeOutBack,
  easeOutCubic,
  easeInOutCubic,
  easeInOutSine,
  fastOutSlowIn,
  decelerate,
  elasticOut,
  bounceOut,
  spring,
  step,

  /// Material 3's emphasized easing, `Cubic(0.2, 0, 0, 1)`: a quick start
  /// that settles gently (entrances, page and sheet motion).
  emphasized,

  /// The web's ease-out-back, `cubic-bezier(0.34, 1.56, 0.64, 1)`: a
  /// bigger overshoot than [easeOutBack], landing with a slap (stickers,
  /// cards dropping onto a wall).
  overshoot;

  /// The curve named [v] (any case, spaces and dashes ignored), or null.
  static AnimationCurve? parse(Object? v) {
    if (v is AnimationCurve) return v;
    if (v is! String) return null;
    String simple(String s) => s.toLowerCase().replaceAll(RegExp(r'[\s_,-]'), '');
    final s = simple(v);
    for (final c in values) {
      if (simple(c.name) == s) return c;
    }
    return null;
  }

  /// This curve at [t] (0–1). `spring` follows a fixed damped spring, as a
  /// transition between two values does.
  double transform(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    return switch (this) {
      linear => t,
      easeIn => _cubic(0.42, 0, 1, 1, t),
      easeOut => _cubic(0, 0, 0.58, 1, t),
      easeInOut => _cubic(0.42, 0, 0.58, 1, t),
      easeOutBack => _cubic(0.175, 0.885, 0.32, 1.275, t),
      easeOutCubic => _cubic(0.215, 0.61, 0.355, 1, t),
      easeInOutCubic => _cubic(0.645, 0.045, 0.355, 1, t),
      easeInOutSine => _cubic(0.445, 0.05, 0.55, 0.95, t),
      fastOutSlowIn => _cubic(0.4, 0, 0.2, 1, t),
      decelerate => 1 - (1 - t) * (1 - t),
      elasticOut => math.pow(2, -10 * t) * math.sin((t - 0.1) * 2 * math.pi / 0.4) + 1,
      bounceOut => _bounce(t),
      spring => 1 - math.exp(-6.5 * t) * math.cos(2 * math.pi * 1.25 * t) * (1 - t * t),
      step => t < 0.5 ? 0 : 1,
      emphasized => _cubic(0.2, 0, 0, 1, t),
      overshoot => _cubic(0.34, 1.56, 0.64, 1, t),
    };
  }

  // Flutter's Cubic.
  static double _cubic(double a, double b, double c, double d, double t) {
    double eval(double p, double q, double m) => 3 * p * (1 - m) * (1 - m) * m + 3 * q * (1 - m) * m * m + m * m * m;
    var start = 0.0, end = 1.0;
    while (true) {
      final mid = (start + end) / 2;
      final x = eval(a, c, mid);
      if ((t - x).abs() < 0.001) return eval(b, d, mid);
      if (x < t) {
        start = mid;
      } else {
        end = mid;
      }
    }
  }

  static double _bounce(double t) {
    if (t < 1 / 2.75) return 7.5625 * t * t;
    if (t < 2 / 2.75) {
      t -= 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    }
    if (t < 2.5 / 2.75) {
      t -= 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    }
    t -= 2.625 / 2.75;
    return 7.5625 * t * t + 0.984375;
  }
}

// --- helpers ------------------------------------------------------------------

/// Value equality over [props] (deep for lists and maps).
@immutable
abstract base class _Value {
  const _Value();
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other.runtimeType == runtimeType && jsonEquality.equals((other as _Value).props, props);

  @override
  int get hashCode => jsonEquality.hash(props);
}

extension type const _R(Json m) {
  double d(String k, double fallback) => readDouble(m[k]) ?? fallback;
  double? dn(String k) => readDouble(m[k]);
  int i(String k, int fallback) => readInt(m[k]) ?? fallback;
  int ms(String k, int fallback) => math.max(0, readInt(m[k]) ?? fallback);
  bool b(String k, bool fallback) => readBool(m[k]) ?? fallback;
  String s(String k, [String fallback = '']) => readString(m[k]) ?? fallback;
  String? sn(String k) => readString(m[k]);
  T e<T extends Enum>(List<T> values, String k, T fallback) => readEnum(values, m[k], fallback);
  AnimationCurve curve(String k, AnimationCurve fallback) => AnimationCurve.parse(m[k]) ?? fallback;
  Color? color(String k) => Color.fromJson(m[k]);
  List<double> doubles(String k) => [...?readList(m[k])?.map(readDouble).nonNulls];
}

extension on Json {
  void d(String k, double v, double fallback) {
    if (v != fallback) this[k] = writeDouble(v);
  }

  void dn(String k, double? v) {
    if (v != null) this[k] = writeDouble(v);
  }

  void i(String k, int v, int fallback) {
    if (v != fallback) this[k] = v;
  }

  void b(String k, bool v, bool fallback) {
    if (v != fallback) this[k] = v;
  }

  void s(String k, String? v, [String fallback = '']) {
    if (v != null && v != fallback) this[k] = v;
  }

  void e(String k, Enum v, Enum fallback) {
    if (v != fallback) this[k] = v.name;
  }

  void color(String k, Color? v) {
    if (v != null) this[k] = v.toJson();
  }
}


/// [v], or the JSON [v] holds as text (a bound list given as JSON text).
Object? _jsonText(Object? v) {
  if (v is! String) return v;
  try {
    return jsonDecode(v);
  } catch (_) {
    return null;
  }
}

/// A bound switch read loosely: true, 1, `on`, `true`.
bool? _loose(Object? v) => switch (v) {
  final bool b => b,
  final num n => n != 0,
  final String s => switch (s.trim().toLowerCase()) {
    'true' || 'on' || '1' => true,
    'false' || 'off' || '0' || '' => false,
    _ => null,
  },
  _ => null,
};

// --- motion -------------------------------------------------------------------

/// A transform painted over the node's layout (Flutter's `Transform`): it
/// moves nothing else. Its values are the node's rest pose; how it gets
/// there is the node's `animations` and `transitions`.
///
/// One matrix, outermost first: a translation (the [path]'s offset, then
/// [translateX]/[translateY] in pixels, then [shiftX]/[shiftY] times the
/// node's size, `FractionalTranslation`), then about [alignment]: the scale
/// ([scale] times [scaleX]/[scaleY]), the rotation [rotate] (degrees, about
/// z, plus the path's turn), then [rotateX] and [rotateY] (3D, seen with
/// [perspective]). JSON (sparse): `{"translateY": -4, "scale": 1.02,
/// "alignment": [0, 1]}`.
///
/// Reads the legacy keys too: `originX`/`originY` as [alignment]; the flat
/// path keys (`path` text, `pathProgress`, `orientToPath`, `orientUpright`,
/// `uprightMirror`, `pathViewBox`, `pathPacing`, `pathFocusX/Y`) as
/// [path]. Its other legacy keys belong to the node ([Node.fromJson]:
/// `opacity`, `blur`) or to its animations and transitions
/// ([Behaviors.fromJson]: the timing, entrance, loop, spin, keyframes and
/// shimmer).
@immutable
final class Motion extends _Value {
  const Motion({
    this.translateX = 0,
    this.translateY = 0,
    this.shiftX = 0,
    this.shiftY = 0,
    this.scale = 1,
    this.scaleX = 1,
    this.scaleY = 1,
    this.rotate = 0,
    this.rotateX = 0,
    this.rotateY = 0,
    this.perspective = 1,
    this.alignment = Alignment.center,
    this.backfaceHidden = false,
    this.path,
  });

  static const Motion none = Motion();

  /// Pixels (`Transform.translate(offset:)`).
  final double translateX, translateY;

  /// Multiples of the node's own size (`FractionalTranslation`).
  final double shiftX, shiftY;

  /// `Transform.scale(scale:, scaleX:, scaleY:)`: the axis factors multiply
  /// [scale].
  final double scale, scaleX, scaleY;

  /// Degrees. [rotate] turns about z (`Transform.rotate`); [rotateX] and
  /// [rotateY] turn in 3D, seen with [perspective] (0 flat).
  final double rotate, rotateX, rotateY, perspective;

  /// The point the scale and rotations are about (`Transform.alignment`):
  /// `[x, y]`, −1…1, the center `[0, 0]`.
  final Alignment alignment;

  /// Not painted while its back faces the viewer (through every transform
  /// above it too).
  final bool backfaceHidden;

  /// A path the node sits on, at its progress; turned with it as it says.
  final PathFollow? path;

  /// The number properties an animation track or a transition drives, as
  /// paths under `motion.` (`motion.rotate`, `motion.path.progress`).
  static const List<String> properties = [
    'translateX', 'translateY', 'shiftX', 'shiftY', 'scale', 'scaleX', 'scaleY', 'rotate', 'rotateX', 'rotateY', //
    'perspective', 'path.progress',
  ];

  bool get hasPath => path?.hasPath ?? false;

  /// Whether it draws the node anywhere but where it's laid out.
  bool get hasTransform => this != none && (_numbers.any((e) => e) || backfaceHidden || hasPath);

  List<bool> get _numbers => [
        translateX != 0, translateY != 0, shiftX != 0, shiftY != 0, scale != 1, scaleX != 1, scaleY != 1, //
        rotate != 0, rotateX != 0, rotateY != 0,
      ];

  /// The value of [property] (one of [properties]); the value at rest for
  /// any other.
  double valueOf(String property) => switch (property) {
        'translateX' => translateX,
        'translateY' => translateY,
        'shiftX' => shiftX,
        'shiftY' => shiftY,
        'scale' => scale,
        'scaleX' => scaleX,
        'scaleY' => scaleY,
        'rotate' => rotate,
        'rotateX' => rotateX,
        'rotateY' => rotateY,
        'perspective' => perspective,
        'path.progress' || 'pathProgress' => path?.progress ?? 0,
        _ => restOf(property),
      };

  /// [property] at rest: 1 for the scales (and the perspective), else 0.
  static double restOf(String property) => switch (property) {
        'scale' || 'scaleX' || 'scaleY' || 'perspective' => 1,
        _ => 0,
      };

  /// This motion with [property] (one of [properties]) set to [value].
  Motion withValue(String property, double value) {
    double v(String p, double own) => p == property ? value : own;
    return Motion(
      translateX: v('translateX', translateX),
      translateY: v('translateY', translateY),
      shiftX: v('shiftX', shiftX),
      shiftY: v('shiftY', shiftY),
      scale: v('scale', scale),
      scaleX: v('scaleX', scaleX),
      scaleY: v('scaleY', scaleY),
      rotate: v('rotate', rotate),
      rotateX: v('rotateX', rotateX),
      rotateY: v('rotateY', rotateY),
      perspective: v('perspective', perspective),
      alignment: alignment,
      backfaceHidden: backfaceHidden,
      path: (property == 'path.progress' || property == 'pathProgress') && path != null
          ? path!.copyWith(progress: value)
          : path,
    );
  }

  /// [a] to [b] at [t], number by number (settings are [b]'s).
  static Motion lerp(Motion a, Motion b, double t) {
    var m = b;
    for (final p in properties) {
      final x = a.valueOf(p), y = b.valueOf(p);
      if (x != y) m = m.withValue(p, x + (y - x) * t);
    }
    return m;
  }

  /// A path direction [radians] folded into −90…90 degrees
  /// ([PathFollow.uprightAngle]).
  static double uprightAngle(double radians) => PathFollow.uprightAngle(radians);

  static Motion? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final legacyOrigin = m.containsKey('originX') || m.containsKey('originY');
    final alignment = Alignment.fromJson(m['alignment']) ?? Alignment.center;
    return Motion(
      translateX: r.d('translateX', 0),
      translateY: r.d('translateY', 0),
      shiftX: r.d('shiftX', 0),
      shiftY: r.d('shiftY', 0),
      scale: r.d('scale', 1),
      scaleX: r.d('scaleX', 1),
      scaleY: r.d('scaleY', 1),
      rotate: r.d('rotate', 0),
      rotateX: r.d('rotateX', 0),
      rotateY: r.d('rotateY', 0),
      perspective: r.d('perspective', 1),
      alignment: legacyOrigin ? Alignment(r.d('originX', alignment.x), r.d('originY', alignment.y)) : alignment,
      backfaceHidden: r.b('backfaceHidden', false),
      path: PathFollow.fromLegacy(m),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..d('translateX', translateX, 0)
      ..d('translateY', translateY, 0)
      ..d('shiftX', shiftX, 0)
      ..d('shiftY', shiftY, 0)
      ..d('scale', scale, 1)
      ..d('scaleX', scaleX, 1)
      ..d('scaleY', scaleY, 1)
      ..d('rotate', rotate, 0)
      ..d('rotateX', rotateX, 0)
      ..d('rotateY', rotateY, 0)
      ..d('perspective', perspective, 1);
    if (alignment != Alignment.center) j['alignment'] = alignment.toJson();
    j.b('backfaceHidden', backfaceHidden, false);
    if (path != null) j['path'] = path!.toJson();
    return j;
  }

  @override
  List<Object?> get props => [
        translateX, translateY, shiftX, shiftY, scale, scaleX, scaleY, rotate, rotateX, rotateY, perspective, //
        alignment, backfaceHidden, path,
      ];
}

/// A [Motion] drawn with a fade and a blur: the pose a page of a page view
/// (`pageMotion`) or a side of a route transition is drawn at. Flutter: a
/// `Transform` in an `Opacity` in an `ImageFiltered`. JSON: [motion]'s keys
/// with `opacity` and `blur` beside them, flat (`{"shiftX": -1, "opacity":
/// 0.5}`).
@immutable
final class Pose extends _Value {
  const Pose({this.motion = Motion.none, this.opacity = 1, this.blur = 0});

  static const Pose none = Pose();

  final Motion motion;

  /// 0–1.
  final double opacity;

  /// A layer blur's radius.
  final double blur;

  bool get isNone => this == none;

  /// [a] to [b] at [t].
  static Pose lerp(Pose a, Pose b, double t) => Pose(
        motion: Motion.lerp(a.motion, b.motion, t),
        opacity: (a.opacity + (b.opacity - a.opacity) * t).clamp(0.0, 1.0),
        blur: math.max(0, a.blur + (b.blur - a.blur) * t),
      );

  static Pose? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Pose(
      motion: Motion.fromJson(m) ?? Motion.none,
      opacity: r.d('opacity', 1).clamp(0.0, 1.0),
      blur: math.max(0, r.d('blur', 0)),
    );
  }

  Json toJson() => motion.toJson()
    ..d('opacity', opacity, 1)
    ..d('blur', blur, 0);

  @override
  List<Object?> get props => [motion, opacity, blur];
}

/// A band of light across what the node paints (a loading skeleton's
/// shimmer: Flutter's `ShaderMask` with a moving `LinearGradient`), blended
/// over the node's own pixels only. [position] places it; the `shimmer`
/// animation preset sweeps it across, over and over. JSON (sparse):
/// `{"color": "#FFFFFFFF", "strength": 0.8, "width": 0.44, "angle": 0,
/// "position": 0.5}`.
@immutable
final class Shimmer extends _Value {
  const Shimmer({this.color = Color.white, this.strength = 0.8, this.width = 0.44, this.angle = 0, this.position = 0.5});

  final Color color;

  /// How strongly the band's center blends the color in (0–1).
  final double strength;

  /// The band's width, a share of the node's size along the sweep.
  final double width;

  /// The sweep's direction in degrees: 0 left to right, 90 top to bottom.
  final double angle;

  /// Where the band is: 0 fully off the start side, 1 fully off the end.
  /// Bindable as `shimmer.position`.
  final double position;

  static Shimmer? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Shimmer(
      color: r.color('color') ?? Color.white,
      strength: r.d('strength', 0.8),
      width: r.d('width', 0.44),
      angle: r.d('angle', 0),
      position: r.d('position', 0.5),
    );
  }

  Json toJson() {
    final j = <String, Object?>{};
    if (color != Color.white) j['color'] = color.toJson();
    return j
      ..d('strength', strength, 0.8)
      ..d('width', width, 0.44)
      ..d('angle', angle, 0)
      ..d('position', position, 0.5);
  }

  @override
  List<Object?> get props => [color, strength, width, angle, position];
}

// --- flicker ------------------------------------------------------------------

/// How far (0–1) the `flicker` preset ([AnimationPresets]) is between its `from` and
/// `to` values at [t] (0–1) of a run: waves of 3, 7 and 17 per run, so it
/// wavers, flares and dips like a flame and ends where it began.
double flickerAt(double t) {
  final a = math.sin(t * 2 * math.pi * 3) * 0.35;
  final b = math.sin(t * 2 * math.pi * 7 + 1.3) * 0.25;
  final c = math.sin(t * 2 * math.pi * 17 + 0.4) * 0.15;
  return (0.5 + (a + b + c) / 1.5).clamp(0.0, 1.0);
}

// --- transitions --------------------------------------------------------------

/// How a change of [property] animates (Flutter's implicit animations:
/// `AnimatedContainer(duration:, curve:)`, `AnimatedOpacity`,
/// `AnimatedScale`, `TweenAnimationBuilder`): when the value there changes
/// (a binding, a condition, a state style), the node tweens from what it
/// shows to the new value over [duration] after [delay] on [curve], or on
/// [spring]. A change mid-flight carries on from where it is. A behavior
/// key, a list: `"transitions": [{"property": "motion", "duration": 240,
/// "curve": "easeOutCubic"}, {"property": "opacity", "duration": 120}]`.
///
/// [property] is a binding path or a prefix of one; the longest that
/// matches wins (`motion.rotate` over `motion`), `*` matches every path. A
/// prefix eases what's under it as one value, as `AnimatedContainer` does
/// its `transform`: a change of any of its numbers starts them together,
/// and [keyframes] are passed through each time. A path an animation track
/// is playing isn't transitioned. The design canvas shows new values at
/// once.
///
/// Reads the legacy `{"style", "opacity", "size"}` object: `style` as
/// `opacity`, `scale`, `decoration.fills` and `visible`; `size` as
/// `layout`. A map from property to timing reads too.
@immutable
final class Transition extends _Value {
  const Transition({
    this.property = '',
    this.duration = 0,
    this.delay = 0,
    this.curve = AnimationCurve.linear,
    this.spring,
    this.keyframes = const [],
    this.interpolation = KeyframeInterpolation.linear,
    this.arc = 0,
  });

  /// The binding path (or prefix) it eases: `motion`, `motion.rotate`,
  /// `opacity`, `decoration.fills`, `layout`, `visible`, `*`.
  final String property;

  /// Milliseconds.
  final int duration, delay;
  final AnimationCurve curve;

  /// Eases on this spring instead of [duration] and [curve].
  final Spring? spring;

  /// Values passed through on the way ([Keyframe]s, `at` 0–1 of the run):
  /// a number for a single property; for a prefix, an object of the
  /// numbers under it (`{"at": 0.5, "value": {"scale": 1.05}}`: a card
  /// that swells as it turns over). Joined as [interpolation] says.
  final List<Keyframe> keyframes;
  final KeyframeInterpolation interpolation;

  /// Deprecated (one app): bends a change of a `motion` position
  /// (`translateX/Y`, `shiftX/Y`) into a quadratic curve whose middle sits
  /// this share of the distance off the straight line, to the right of the
  /// way it goes (negative: left). Different curves on the two axes
  /// (`motion.translateX` and `motion.translateY`) or a `motion.path` say
  /// the same in the current shape.
  final double arc;

  /// Whether it eases binding path [path].
  bool matches(String path) => property == '*' || path == property || path.startsWith('$property.');

  /// The transition of [list] that eases [path]: the longest match.
  static Transition? of(List<Transition> list, String path) {
    Transition? best;
    for (final t in list) {
      if (!t.matches(path)) continue;
      if (best == null || (best.property == '*' && t.property != '*') || t.property.length > best.property.length && t.property != '*') {
        best = t;
      }
    }
    return best;
  }

  /// The values [keyframes] give [key] (a number under a prefix, or the
  /// property's own when it has no prefix).
  List<Keyframe> keyframesOf(String key) => [
        for (final k in keyframes)
          if ((k.value is Map ? readDouble((k.value as Map)[key]) : (key.isEmpty ? readDouble(k.value) : null)) case final double v)
            Keyframe(at: k.at, value: v, curve: k.curve),
      ];

  static Transition? fromJson(Object? json, {String? property}) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Transition(
      property: property ?? r.s('property'),
      duration: r.ms('duration', 0),
      delay: r.ms('delay', 0),
      curve: r.curve('curve', AnimationCurve.linear),
      spring: Spring.fromJson(m['spring']),
      keyframes: [...?readList(_jsonText(m['keyframes']))?.map(Keyframe.fromJson).nonNulls],
      interpolation: r.e(KeyframeInterpolation.values, 'interpolation', KeyframeInterpolation.linear),
      arc: r.d('arc', 0),
    );
  }

  /// A node's `transitions`: the list, a property → timing map, or the
  /// legacy `{style, opacity, size}` object.
  static List<Transition> listFromJson(Object? json) {
    if (readList(_jsonText(json)) case final List<Object?> l) return [...l.map(fromJson).nonNulls];
    final m = readMap(json);
    if (m == null) return const [];
    if (m.keys.every((k) => k == 'style' || k == 'opacity' || k == 'size')) {
      final style = m['style'], opacity = m['opacity'], size = m['size'];
      return [
        if (fromJson(opacity ?? style, property: 'opacity') case final Transition t) t,
        if (fromJson(style, property: 'scale') case final Transition t) t,
        if (fromJson(style, property: 'decoration.fills') case final Transition t) t,
        if (fromJson(style, property: 'visible') case final Transition t) t,
        if (fromJson(size, property: 'layout') case final Transition t) t,
      ];
    }
    return [
      for (final e in m.entries)
        if (fromJson(e.value, property: e.key) case final Transition t) t,
    ];
  }

  Json toJson() {
    final j = <String, Object?>{'property': property}
      ..i('duration', duration, 0)
      ..i('delay', delay, 0)
      ..e('curve', curve, AnimationCurve.linear);
    if (spring != null) j['spring'] = spring!.toJson();
    if (keyframes.isNotEmpty) j['keyframes'] = [for (final k in keyframes) k.toJson()];
    return j
      ..e('interpolation', interpolation, KeyframeInterpolation.linear)
      ..d('arc', arc, 0);
  }

  @override
  List<Object?> get props => [property, duration, delay, curve, spring, keyframes, interpolation, arc];
}

// --- ink and states -------------------------------------------------------------

/// The ink a tappable box shows, as Flutter's `InkWell`: ripples and the
/// overlays of its states. Clipped to the box's radius.
@immutable
final class InkWellStyle extends _Value {
  const InkWellStyle({this.overlayColor, this.splashColor, this.highlightColor, this.hoverColor, this.focusColor});

  /// Every state's overlay (Flutter's `overlayColor`, for all states).
  final Color? overlayColor;
  final Color? splashColor, highlightColor, hoverColor, focusColor;

  /// The overlay shown in [state], or null for none (Flutter's defaults
  /// from the theme apply).
  Color? colorFor(WidgetState state) =>
      overlayColor ??
      switch (state) {
        WidgetState.hovered => hoverColor,
        WidgetState.focused => focusColor,
        WidgetState.pressed => highlightColor,
        _ => null,
      };

  static InkWellStyle? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return InkWellStyle(
      overlayColor: r.color('overlayColor'),
      splashColor: r.color('splashColor'),
      highlightColor: r.color('highlightColor'),
      hoverColor: r.color('hoverColor'),
      focusColor: r.color('focusColor'),
    );
  }

  Json toJson() => <String, Object?>{}
    ..color('overlayColor', overlayColor)
    ..color('splashColor', splashColor)
    ..color('highlightColor', highlightColor)
    ..color('hoverColor', hoverColor)
    ..color('focusColor', focusColor);

  @override
  List<Object?> get props => [overlayColor, splashColor, highlightColor, hoverColor, focusColor];
}

/// The interaction states of Flutter's `WidgetState` a node can style.
enum WidgetState {
  /// A pointer is over the node.
  hovered,

  /// The node, or an input in it, has keyboard focus.
  focused,

  /// A pointer is pressing the node.
  pressed,

  /// Its `selected` binding is true.
  selected,

  /// Its `disabled` binding is true; a disabled node runs no actions.
  disabled,

  /// The node, or one around it, is being dragged.
  dragged,
}

/// What a node and its descendants change to in each [WidgetState]: per
/// state, node id → a patch of that node's JSON (a merge patch: maps
/// merge, `null` removes, anything else replaces; see [mergePatch]). Later
/// states in [WidgetState]'s order win where active states overlap.
@immutable
final class StateStyles extends _Value {
  const StateStyles([this.patches = const {}]);

  static const StateStyles none = StateStyles();

  final Map<WidgetState, Map<String, Json>> patches;

  bool get isEmpty => patches.isEmpty;

  /// The merged patch of node [id] while [active] states hold.
  Json? patchFor(String id, Set<WidgetState> active) {
    Json? out;
    for (final s in WidgetState.values) {
      if (!active.contains(s)) continue;
      final p = patches[s]?[id];
      if (p != null) out = out == null ? p : mergePatch(out, p, keepNulls: true);
    }
    return out;
  }

  /// The ids of the nodes a state restyles.
  Set<String> get targets => {for (final p in patches.values) ...p.keys};

  static StateStyles fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return none;
    final out = <WidgetState, Map<String, Json>>{};
    for (final s in WidgetState.values) {
      final per = readMap(m[s.name]);
      if (per == null) continue;
      final nodes = <String, Json>{
        for (final e in per.entries)
          if (readMap(e.value) case final Json p) e.key: _migratePatch(p),
      };
      if (nodes.isNotEmpty) out[s] = nodes;
    }
    return out.isEmpty ? none : StateStyles(out);
  }

  /// A patch's legacy `motion.opacity` as the node's `opacity` (times the
  /// patch's own), since that is where a motion's opacity went
  /// ([Node.fromJson]). Exact when the node's own opacity is 1.
  static Json _migratePatch(Json patch) {
    final motion = readMap(patch['motion']);
    final o = readDouble(motion?['opacity']);
    if (motion == null || o == null) return patch;
    final own = readDouble(patch['opacity']);
    return {
      ...patch,
      'motion': {...motion}..remove('opacity'),
      'opacity': writeDouble((o * (own ?? 1)).clamp(0.0, 1.0)),
    };
  }

  Json toJson() => {for (final e in patches.entries) e.key.name: e.value};

  @override
  List<Object?> get props => [patches];
}

/// [base] with [patch] merged in (RFC 7386): maps merge recursively, a
/// `null` value removes the key (kept as `null` with [keepNulls], to merge
/// two patches), anything else replaces.
Json mergePatch(Json base, Json patch, {bool keepNulls = false}) {
  final out = <String, Object?>{...base};
  for (final e in patch.entries) {
    final v = e.value, cur = out[e.key];
    if (v == null && !keepNulls) {
      out.remove(e.key);
    } else if (v is Map && cur is Map) {
      out[e.key] = mergePatch(readMap(cur)!, readMap(v)!, keepNulls: keepNulls);
    } else {
      out[e.key] = v;
    }
  }
  return out;
}

/// The merge patch that turns [from] into [to] (null when they're equal).
Json? diffPatch(Json from, Json to) {
  final out = <String, Object?>{};
  for (final e in to.entries) {
    final a = from[e.key], b = e.value;
    if (a is Map && b is Map) {
      final d = diffPatch(readMap(a)!, readMap(b)!);
      if (d != null) out[e.key] = d;
    } else if (!from.containsKey(e.key) || !jsonEquality.equals(a, b)) {
      out[e.key] = b;
    }
  }
  for (final k in from.keys) {
    if (!to.containsKey(k)) out[k] = null;
  }
  return out.isEmpty ? null : out;
}

// --- drag and drop --------------------------------------------------------------

enum DragAxis { free, horizontal, vertical }

/// How a node starts a drag: on press, on long press, or long press on
/// touch and press with a mouse.
enum DragStart { press, longPress, auto }

/// What the node shows where it was picked up while dragged
/// (`Draggable.childWhenDragging`): a faded copy, nothing, or itself.
enum DragSourceStyle { ghost, hidden, keep }

/// Which point of the copy that follows the pointer sits under it
/// (`Draggable.dragAnchorStrategy`): where it was grabbed
/// (`childDragAnchorStrategy`), or its center (a feedback node of another
/// size). The legacy `feedbackAnchor` (`grab`, `center`) reads as it.
enum DragAnchor { child, center }

/// Lets the user pick the node up and drop it on a [DropTarget] that takes
/// its [group] (Flutter's `Draggable`; `LongPressDraggable` with [start]
/// `longPress`).
@immutable
final class DragSource extends _Value {
  const DragSource({
    this.group = '',
    this.data = '',
    this.start = DragStart.auto,
    this.axis = DragAxis.free,
    this.childWhenDragging = DragSourceStyle.ghost,
    this.ghostOpacity = 0.35,
    this.feedback = '',
    this.dragAnchor = DragAnchor.child,
    this.feedbackRotation = -2,
    this.feedbackScale = 1,
    this.feedbackOpacity = 1,
    this.feedbackElevation = 24,
    this.returnSpring = DragSource.defaultSpring,
    this.enabled = true,
  });

  /// The drag group a [DropTarget] [DropTarget.accepts], and the data it
  /// hands over (`Draggable.data`; may hold `${...}`).
  final String group, data;

  /// How a drag starts: press, long press (`LongPressDraggable`), or long
  /// press on touch and press with a mouse.
  final DragStart start;

  /// `Draggable.axis`: the feedback moves only along it.
  final DragAxis axis;

  /// What stays where it was picked up (the legacy `whileDragging`).
  final DragSourceStyle childWhenDragging;

  /// The opacity of a [DragSourceStyle.ghost].
  final double ghostOpacity;

  /// The node drawn under the pointer instead of this one
  /// (`Draggable.feedback`); empty: the node itself. The legacy
  /// `feedbackNodeId` reads as it.
  final String feedback;

  /// The legacy `feedbackAnchor` reads as it.
  final DragAnchor dragAnchor;

  /// The feedback's tilt (degrees), scale, opacity and shadow while it
  /// follows the pointer. Not yet a `states.dragged` patch: their defaults
  /// (−2°, a 24 shadow) can't change under existing documents.
  final double feedbackRotation, feedbackScale, feedbackOpacity, feedbackElevation;

  /// The spring a drop no target takes flies home on; null: none (it
  /// reappears at once, as Flutter's `Draggable` does). JSON `false` is
  /// null. The legacy `returnSpring: true` with `spring`,
  /// `springStiffness`/`springDamping` or `physics` reads as it.
  final Spring? returnSpring;
  static const Spring defaultSpring = Spring.physical(stiffness: 260, damping: 14);

  /// Bindable as `draggable.enabled`.
  final bool enabled;

  /// The spring it flies back on, as gesture physics; null for none.
  GesturePhysics? get effectivePhysics => returnSpring == null ? null : GesturePhysics(spring: returnSpring!, fling: false);

  /// [m]'s return spring: `returnSpring` (an object, `false`, or `true`
  /// with the legacy `spring`, `springStiffness`/`springDamping` or
  /// `physics`).
  static Spring? _returnSpringOf(Json m) {
    final v = m['returnSpring'];
    if (Spring.fromJson(v, fallback: defaultSpring) case final Spring s) return s;
    // The legacy `physics` overrode `returnSpring: false`.
    if (GesturePhysics.fromJson(m['physics']) case final GesturePhysics p) return p.spring;
    if (readBool(v) == false) return null;
    return Spring.fromJson(m['spring'], fallback: defaultSpring) ??
        Spring.legacy(m, 'springStiffness', 'springDamping', fallback: defaultSpring) ??
        defaultSpring;
  }

  static DragSource? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return DragSource(
      group: r.s('group'),
      data: r.s('data'),
      start: r.e(DragStart.values, 'start', DragStart.auto),
      axis: r.e(DragAxis.values, 'axis', DragAxis.free),
      childWhenDragging: readEnum(
        DragSourceStyle.values,
        m['childWhenDragging'] ?? m['whileDragging'],
        DragSourceStyle.ghost,
      ),
      ghostOpacity: r.d('ghostOpacity', 0.35),
      feedback: readString(m['feedback']) ?? r.s('feedbackNodeId'),
      dragAnchor: switch (m['dragAnchor'] ?? m['dragAnchorStrategy'] ?? m['feedbackAnchor']) {
        'center' || 'pointer' => DragAnchor.center,
        _ => DragAnchor.child,
      },
      feedbackRotation: r.d('feedbackRotation', -2),
      feedbackScale: r.d('feedbackScale', 1),
      feedbackOpacity: r.d('feedbackOpacity', 1),
      feedbackElevation: r.d('feedbackElevation', 24),
      returnSpring: _returnSpringOf(m),
      enabled: _loose(m['enabled']) ?? true,
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..s('group', group)
      ..s('data', data)
      ..e('start', start, DragStart.auto)
      ..e('axis', axis, DragAxis.free)
      ..e('childWhenDragging', childWhenDragging, DragSourceStyle.ghost)
      ..d('ghostOpacity', ghostOpacity, 0.35)
      ..s('feedback', feedback)
      ..e('dragAnchor', dragAnchor, DragAnchor.child)
      ..d('feedbackRotation', feedbackRotation, -2)
      ..d('feedbackScale', feedbackScale, 1)
      ..d('feedbackOpacity', feedbackOpacity, 1)
      ..d('feedbackElevation', feedbackElevation, 24);
    if (returnSpring == null) {
      j['returnSpring'] = false;
    } else if (returnSpring != defaultSpring) {
      j['returnSpring'] = returnSpring!.toJsonOver(defaultSpring);
    }
    return j..b('enabled', enabled, true);
  }

  @override
  List<Object?> get props => [
    group, data, start, axis, childWhenDragging, ghostOpacity, feedback, dragAnchor, feedbackRotation, //
    feedbackScale, feedbackOpacity, feedbackElevation, returnSpring, enabled,
  ];
}

/// Where a [DropTarget] inserts what's dropped on a list.
enum DropSlot { none, gap, node }

/// How big the slot a [DropTarget] opens in its list is: the dragged
/// node's size, the slot node's own (room for an insertion line), or none:
/// [inGap] draws the slot node in the gap between the items it would land
/// between, moving nothing (a board's column insertion bar).
enum DropSlotSize { dragged, node, inGap }

/// Takes [DragSource]s of the groups it [accepts] (Flutter's `DragTarget`).
@immutable
final class DropTarget extends _Value {
  const DropTarget({
    this.accepts = const [],
    this.key = '',
    this.acceptIf = '',
    this.listNodeId = '',
    this.slot = DropSlot.gap,
    this.slotNodeId = '',
    this.slotSize = DropSlotSize.dragged,
    this.slotWhenRefused = true,
    this.hoverDelay = 0,
    this.fullIf = '',
    this.enabled = true,
  });

  final List<String> accepts;
  final String key;

  /// A condition on the dragged data.
  final String acceptIf;

  /// The list it drops into, and how. A target outside the list's repeat
  /// (a column's tab, beside the columns) drops at the end of the copy of
  /// the list whose own target has the same [key].
  final String listNodeId;
  final DropSlot slot;
  final String slotNodeId;
  final DropSlotSize slotSize;

  /// Whether the list opens its slot for a drop [acceptIf] refuses; off,
  /// only accepted drops show where they'd land.
  final bool slotWhenRefused;
  final int hoverDelay;
  final String fullIf;
  final bool enabled;

  static DropTarget? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return DropTarget(
      accepts: readStrings(m['accepts']),
      key: r.s('key'),
      acceptIf: r.s('acceptIf'),
      listNodeId: r.s('listNodeId'),
      slot: r.e(DropSlot.values, 'slot', DropSlot.gap),
      slotNodeId: r.s('slotNodeId'),
      slotSize: r.e(DropSlotSize.values, 'slotSize', DropSlotSize.dragged),
      slotWhenRefused: r.b('slotWhenRefused', true),
      hoverDelay: r.ms('hoverDelay', 0),
      fullIf: r.s('fullIf'),
      enabled: _loose(m['enabled']) ?? true,
    );
  }

  Json toJson() => <String, Object?>{if (accepts.isNotEmpty) 'accepts': accepts}
    ..s('key', key)
    ..s('acceptIf', acceptIf)
    ..s('listNodeId', listNodeId)
    ..e('slot', slot, DropSlot.gap)
    ..s('slotNodeId', slotNodeId)
    ..e('slotSize', slotSize, DropSlotSize.dragged)
    ..b('slotWhenRefused', slotWhenRefused, true)
    ..i('hoverDelay', hoverDelay, 0)
    ..s('fullIf', fullIf)
    ..b('enabled', enabled, true);

  @override
  List<Object?> get props => [
    accepts, key, acceptIf, listNodeId, slot, slotNodeId, slotSize, slotWhenRefused, hoverDelay, fullIf, enabled, //
  ];
}

/// A direction a node is dragged or dismissed in.
enum DragDirection { left, right, up, down }

/// The shape of a [Track]: a straight line, an arc about a pivot, or an
/// SVG path ([Track.path]).
enum TrackShape { line, arc, path }

/// How the pointer moves along a [Track]: following it (along the line or
/// path, round the arc), or dragging up/down, left/right, or either (up or
/// right raises it: dx − dy).
enum TrackInput { follow, vertical, horizontal, both }

/// Where a [Track]'s node takes the pointer: on itself, or anywhere in
/// its parent too (a knob turned from anywhere in its box).
enum TrackHitArea { self, parent }

/// What a [Track]'s line and pivot are measured in: pixels, or fractions of
/// the parent's size (x values of its width, y of its height).
enum TrackUnits { pixels, parent }

/// How the pointer may move a [Track]'s value (Flutter's
/// `SliderInteraction`, the two it has of four): only by dragging the thumb
/// (`slideThumb`), or also by pressing the track, which moves the thumb
/// there before the drag goes on (`tapAndSlide`; [TrackInput.follow] only).
enum TrackInteraction { slideThumb, tapAndSlide }

/// A value the user sets by dragging (node key `track`): Flutter's `Slider`
/// (`value`, `min`, `max`, divisions as [step], `onChanged` as the
/// `changed` reaction, `onChangeEnd` as `changeEnd`), generalised from a
/// straight bar to a line, an arc or any path. The node carrying it is the
/// thumb: it moves along the track as variable [variable] goes from [min] to
/// [max], and the design canvas draws it at the variable's value. Dragging
/// it writes the variable; the wheel and arrow keys step it. Inside it
/// `${track.value}`, `${track.progress}`, `${track.dragging}`,
/// `${track.fine}` and `${track.focused}` can be read; it fires `changed`
/// (`${result.value}`, `from`, `direction`, `crossed`), `dragEnd` and
/// `changeEnd`.
///
/// Its settings and geometry are bindable as `track.<field>`
/// (`track.x2`: `${= parent.width - 26}`); `track.value` gives the value the
/// node is drawn at in place of reading [variable]. The legacy
/// `drag.track` (and its `drag.track.*` binding paths) reads as this: see
/// [fromJson] for its renamed keys.
@immutable
final class Track extends _Value {
  const Track({
    this.enabled = true,
    this.variable = '',
    this.value,
    this.min = 0,
    this.max = 1,
    this.step = 0,
    this.clamp = true,
    this.input = TrackInput.follow,
    this.allowedInteraction = TrackInteraction.slideThumb,
    this.hitArea = TrackHitArea.self,
    this.pixelsPerRange = 200,
    this.wheelStep,
    this.keyStep,
    this.shape = TrackShape.line,
    this.x1 = 0,
    this.y1 = 0,
    this.x2 = 0,
    this.y2 = -100,
    this.relative = false,
    this.units = TrackUnits.pixels,
    this.startAngle = -135,
    this.sweepAngle = 270,
    this.pivotX = 0,
    this.pivotY = 0,
    this.rotate = true,
    this.path,
    this.detent = 0,
    this.overscroll = 0,
    this.physics,
    this.settle = 0,
    this.settleCurve = AnimationCurve.easeOutCubic,
    this.settleSpring = Track.defaultSettleSpring,
    this.snap = 0,
    this.snapCurve = AnimationCurve.easeOutBack,
    this.defaultValue,
    this.doubleTapValues = const [],
    this.parkedProgress,
    this.fineStep = 0,
    this.finePixelsPerRange = 0,
    this.fineHold = 380,
    this.fineVariable = '',
    this.smooth = false,
    this.gain = 1,
  });

  // --- the value (Slider) ---

  /// Whether it takes the pointer, the wheel and the keys (bindable as
  /// `track.enabled`; the legacy `drag.enabled` reads as it).
  final bool enabled;

  /// The variable it reads and writes; empty when `track.value` is bound
  /// and its reactions write the value (the legacy `write: false`).
  final String variable;

  /// The value the node is drawn at, from a binding (`track.value`); null
  /// reads [variable].
  final double? value;

  /// The range and its step (`Slider.divisions` = (max − min) / step; 0 is
  /// continuous).
  final double min, max, step;

  /// Whether the value stays within [min]–[max]. Off, an [TrackShape.arc]
  /// keeps turning past its ends and the value counts on (a combination
  /// dial; the legacy `endless`).
  final bool clamp;

  // --- input ---

  final TrackInput input;

  /// The legacy `jumpOnTap: true` reads as [TrackInteraction.tapAndSlide].
  final TrackInteraction allowedInteraction;

  /// With [TrackHitArea.parent] the node's parent takes the pointer too.
  final TrackHitArea hitArea;

  /// Pixels of drag for the whole range ([TrackInput.vertical],
  /// [TrackInput.horizontal], [TrackInput.both]; the legacy `gain` divides
  /// it).
  final double pixelsPerRange;

  /// One wheel notch, one arrow key: null [step], else 1% of the range; 0
  /// turns the wheel (the legacy `wheel: false`) or the keys (`keyboard:
  /// false`) off. With the keys on it takes focus: arrows step, Page Up/Down
  /// by 10 steps, Home and End to the ends.
  final double? wheelStep, keyStep;

  // --- where the thumb is drawn ---

  /// Inferred from [path] when not given.
  final TrackShape shape;

  /// A line's ends, from the node's place (pixels, or with [relative]
  /// multiples of the node's size, with [units] parent of the parent's).
  final double x1, y1, x2, y2;

  /// A line's ends are multiples of the node's own size (a full-width scrub
  /// area: `x1: -0.5, x2: 0.5`).
  final bool relative;
  final TrackUnits units;

  /// An arc: the angle of [min] (degrees, clockwise, 0 up) and the turn to
  /// [max] (the legacy `endAngle` is `startAngle + sweepAngle`), about the
  /// pivot (from the node's center); the node orbits it on the circle
  /// through its place, turning with it ([rotate]). A pivot at the center is
  /// a knob that turns in place.
  final double startAngle, sweepAngle, pivotX, pivotY;
  final bool rotate;

  /// A path ([TrackShape.path]): its SVG data in pixels from the node's
  /// place, or in a view box stretched over the parent, and whether the node
  /// turns with it (the legacy `path`, `viewBoxWidth`/`viewBoxHeight`,
  /// `orientToPath` and `orientUpright`).
  final PathFollow? path;

  // --- feel ---

  /// How magnetic [step]s are while dragging (0–1): 0 jumps from step to
  /// step; above 0 the node follows that share of the way past a step.
  final double detent;

  /// How far it can be dragged past an end, a share of the pointer's
  /// travel there (0–1); it springs back on release.
  final double overscroll;

  /// Let go while moving, with [GesturePhysics.fling] it coasts on, slowing
  /// by [GesturePhysics.friction], then settles on a [step] (the legacy
  /// `momentum` and its `friction` rate). Null stops where let go.
  final GesturePhysics? physics;

  /// The glide to its value's place when not following the pointer (ms; 0
  /// jumps), its curve, and the spring of [AnimationCurve.spring] (mass 1),
  /// which a release mid-fling starts at the pointer's speed.
  final int settle;
  final AnimationCurve settleCurve;

  /// The spring of a `spring` [settleCurve] (JSON `settleSpring`; the
  /// legacy `settleStiffness`/`settleDamping` read as it).
  final Spring settleSpring;
  static const Spring defaultSettleSpring = Spring.physical(stiffness: 380, damping: 20);

  /// Animates the node to each new value over [snap] ms along [snapCurve]
  /// (a knob clicking from detent to detent); 0 jumps.
  final int snap;
  final AnimationCurve snapCurve;

  // --- deprecated: one-app fields, kept working until migrated ---

  /// What a double tap resets to, or the values it moves between in order.
  /// Deprecated: a `doubleTap` reaction.
  final double? defaultValue;
  final List<double> doubleTapValues;

  /// Where the node parks while the value is out of range or empty, as a
  /// progress that may lie outside 0–1; null draws such a value at the
  /// nearest end. Deprecated: bind `track.value` outside the range.
  final double? parkedProgress;

  /// A finer step while Shift is held or after the pointer is held still
  /// [fineHold] ms (0: hold doesn't), [finePixelsPerRange] pixels for the
  /// range (0: 4 × [pixelsPerRange]); 0 has no fine mode. [fineVariable], a
  /// boolean variable, is kept true while fine. Deprecated: a boolean
  /// variable set by key and hold reactions, bound to `track.step` and
  /// `track.pixelsPerRange`.
  final double fineStep, finePixelsPerRange;
  final int fineHold;
  final String fineVariable;

  /// Draws the node between [step]s while dragged or coasting, springing
  /// onto the nearest when it rests. Deprecated: [detent] 1.
  final bool smooth;

  /// How far an arc followed round its pivot turns per degree of pointer
  /// turn (0.5 fine). Deprecated; on any other input it is folded into
  /// [pixelsPerRange].
  final double gain;

  /// Whether the value is unbounded (not [clamp]ed).
  bool get unbounded => !clamp;

  bool get hasVariable => variable.trim().isNotEmpty;
  bool get hasFine => fineStep > 0;
  bool get usesViewBox => shape == TrackShape.path && path?.viewBoxSize != null;
  bool get jumpOnTap => allowedInteraction == TrackInteraction.tapAndSlide;
  bool get momentum => physics?.fling ?? false;

  /// The legacy coast rate: the share of speed lost per second as an
  /// exponential rate (`v *= e^(−rate·dt)`).
  double get frictionRate => physics == null ? 0 : -math.log(physics!.frictionDrag);
  double get endAngle => startAngle + sweepAngle;
  double get effectiveFinePixelsPerRange => finePixelsPerRange > 0 ? finePixelsPerRange : pixelsPerRange * 4;

  /// Where [value] is along the track (0–1; past them when unbounded).
  double progressOf(double value) {
    if (max == min) return 0;
    final p = (value - min) / (max - min);
    return unbounded ? p : p.clamp(0.0, 1.0);
  }

  /// Whether [value] is drawn at [parkedProgress] (out of range, or NaN for
  /// an empty variable).
  bool isParked(double value) {
    if (parkedProgress == null) return false;
    if (value.isNaN) return true;
    final lo = math.min(min, max), hi = math.max(min, max);
    return value < lo || value > hi;
  }

  /// Where the node is drawn for [value].
  double restProgressOf(double value) => isParked(value) ? parkedProgress! : (value.isNaN ? 0 : progressOf(value));

  /// [progress] held to the track (any progress when unbounded).
  double clampProgress(double progress) => unbounded ? progress : progress.clamp(0.0, 1.0);

  /// [v] snapped to [by] (from [min]; 0 continuous) and kept in range.
  double snapTo(double v, double by) {
    final lo = math.min(min, max), hi = math.max(min, max);
    var out = unbounded ? v : v.clamp(lo, hi).toDouble();
    if (by > 0) {
      out = min + ((out - min) / by).round() * by;
      if (!unbounded) out = out.clamp(lo, hi).toDouble();
      // Keep 0.1 steps from turning into 0.30000000000000004.
      out = double.parse(out.toStringAsFixed(6));
    }
    return out;
  }

  double snapValue(double v) => snapTo(v, step);

  /// The value at [progress], snapped to [step].
  double valueAt(double progress) => snapValue(min + (max - min) * clampProgress(progress));

  /// Whether the wheel steps it.
  bool get wheel => wheelStep != 0;

  double get effectiveWheelStep => (wheelStep ?? 0) > 0 ? wheelStep! : (step > 0 ? step : (max - min).abs() / 100);

  /// Null with the keys off ([keyStep] 0).
  double? get effectiveKeyStep =>
      keyStep == 0 ? null : ((keyStep ?? 0) > 0 ? keyStep! : (step > 0 ? step : (max - min).abs() / 100));

  /// The value a double tap moves to from [v], or null when it does nothing.
  double? doubleTapTarget(double v) {
    final cycle = doubleTapValues.isNotEmpty ? doubleTapValues : [?defaultValue];
    if (cycle.isEmpty) return null;
    final current = snapValue(v);
    for (var i = 0; i < cycle.length; i++) {
      if ((snapValue(cycle[i]) - current).abs() < 1e-6) return snapValue(cycle[(i + 1) % cycle.length]);
    }
    return snapValue(cycle.first);
  }

  double angleAt(double progress) => startAngle + sweepAngle * clampProgress(progress);

  /// The track of a legacy `drag` object [d] (its `track`, switched by its
  /// `enabled`), or null when it has none.
  static Track? fromLegacyDrag(Json? d) {
    if (d == null || readMap(d['track']) == null) return null;
    final t = <String, Object?>{...readMap(d['track'])!};
    if (!t.containsKey('enabled') && d.containsKey('enabled')) t['enabled'] = d['enabled'];
    return fromJson(t);
  }

  /// Whether the track JSON [m] holds the legacy `write: false` with a
  /// variable: the variable is dropped and, without a literal `value`, moves
  /// to a `track.value` binding ([readsOnly], [Behaviors.migrateBind]).
  static bool _dropsVariable(Json m) =>
      readBool(m['write']) == false && (readString(m['variable'])?.trim().isNotEmpty ?? false);

  /// [_dropsVariable] with no literal `value`: the variable is then bound.
  static bool readsOnly(Json m) => _dropsVariable(m) && m['value'] == null;

  /// Reads the new shape and every legacy key: `endAngle` (as
  /// [sweepAngle]), `endless` ([clamp] off on an arc), `jumpOnTap`
  /// ([allowedInteraction]), `wheel`/`keyboard: false` ([wheelStep]/
  /// [keyStep] 0), `momentum`/`friction` ([physics]: fling with the share of
  /// speed lost a second the rate amounts to), `gain` ([pixelsPerRange] ÷
  /// gain, except round an arc followed by angle), the path string,
  /// `viewBoxWidth`/`viewBoxHeight`, `orientToPath`/`orientUpright` ([path]),
  /// `write: false` (the variable dropped: see [readsOnly]) and
  /// `settleStiffness`/`settleDamping` ([settleSpring]).
  static Track? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final path = _pathOf(m);
    final shape = readEnum(TrackShape.values, m['shape'], path != null ? TrackShape.path : TrackShape.line);
    final input = r.e(TrackInput.values, 'input', TrackInput.follow);
    final start = r.d('startAngle', -135);
    final gain = r.d('gain', 1);
    // A gain other than round an arc followed by angle is a pixel rate.
    final angular = shape == TrackShape.arc && input == TrackInput.follow;
    final ppr = r.d('pixelsPerRange', 200);
    return Track(
      enabled: _loose(m['enabled']) ?? true,
      variable: _dropsVariable(m) ? '' : r.s('variable'),
      value: r.dn('value'),
      min: r.d('min', 0),
      max: r.d('max', 1),
      step: math.max(0, r.d('step', 0)),
      clamp: readBool(m['clamp']) ?? !(r.b('endless', false) && shape == TrackShape.arc),
      input: input,
      allowedInteraction: readEnum(
        TrackInteraction.values,
        m['allowedInteraction'],
        r.b('jumpOnTap', false) ? TrackInteraction.tapAndSlide : TrackInteraction.slideThumb,
      ),
      hitArea: r.e(TrackHitArea.values, 'hitArea', TrackHitArea.self),
      pixelsPerRange: angular || gain <= 0 ? ppr : ppr / gain,
      wheelStep: r.b('wheel', true) ? r.dn('wheelStep') : 0,
      keyStep: r.b('keyboard', true) ? r.dn('keyStep') : 0,
      shape: shape,
      x1: r.d('x1', 0),
      y1: r.d('y1', 0),
      x2: r.d('x2', 0),
      y2: r.d('y2', -100),
      relative: r.b('relative', false),
      units: r.e(TrackUnits.values, 'units', TrackUnits.pixels),
      startAngle: start,
      sweepAngle: r.dn('sweepAngle') ?? (r.d('endAngle', 135) - start),
      pivotX: r.d('pivotX', 0),
      pivotY: r.d('pivotY', 0),
      rotate: r.b('rotate', true),
      path: path,
      detent: r.d('detent', 0),
      overscroll: r.d('overscroll', 0),
      physics: GesturePhysics.fromJson(m['physics']) ??
          ((_loose(m['momentum']) ?? false) ? _legacyMomentum(r.d('friction', 2.6)) : null),
      settle: r.ms('settle', 0),
      settleCurve: r.curve('settleCurve', AnimationCurve.easeOutCubic),
      settleSpring: Spring.fromJson(m['settleSpring'], fallback: defaultSettleSpring) ??
          Spring.legacy(m, 'settleStiffness', 'settleDamping', fallback: defaultSettleSpring) ??
          defaultSettleSpring,
      snap: r.ms('snap', 0),
      snapCurve: r.curve('snapCurve', AnimationCurve.easeOutBack),
      defaultValue: r.dn('defaultValue'),
      doubleTapValues: r.doubles('doubleTapValues'),
      parkedProgress: r.dn('parkedProgress'),
      fineStep: r.d('fineStep', 0),
      finePixelsPerRange: angular || gain <= 0 ? r.d('finePixelsPerRange', 0) : r.d('finePixelsPerRange', 0) / gain,
      fineHold: r.ms('fineHold', 380),
      fineVariable: r.s('fineVariable'),
      smooth: _loose(m['smooth']) ?? false,
      gain: angular ? gain : 1,
    );
  }

  /// The legacy `momentum` coast slowing at [rate] per second
  /// (`v *= e^(−rate·dt)`): a fling losing `1 − e^(−rate)` of its speed a
  /// second (to 4 places).
  static GesturePhysics _legacyMomentum(double rate) =>
      GesturePhysics(friction: double.parse((1 - math.exp(-math.max(0, rate))).toStringAsFixed(4)));

  /// [m]'s path: `path` as an object or SVG data, with the legacy
  /// `viewBoxWidth`/`viewBoxHeight`, `orientToPath` and `orientUpright`.
  static PathFollow? _pathOf(Json m) {
    final p = PathFollow.fromJson(m['path']);
    if (p == null || m['path'] is! String) return p;
    final r = _R(m);
    final w = r.d('viewBoxWidth', 0), h = r.d('viewBoxHeight', 0);
    return PathFollow(
      path: p.path,
      viewBox: w > 0 && h > 0 ? [w, h] : const [],
      orient: !r.b('orientToPath', false)
          ? PathOrient.none
          : (r.b('orientUpright', false) ? PathOrient.upright : PathOrient.tangent),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..b('enabled', enabled, true)
      ..s('variable', variable)
      ..dn('value', value)
      ..d('min', min, 0)
      ..d('max', max, 1)
      ..d('step', step, 0)
      ..b('clamp', clamp, true)
      ..e('input', input, TrackInput.follow)
      ..e('allowedInteraction', allowedInteraction, TrackInteraction.slideThumb)
      ..e('hitArea', hitArea, TrackHitArea.self)
      ..d('pixelsPerRange', pixelsPerRange, 200)
      ..dn('wheelStep', wheelStep)
      ..dn('keyStep', keyStep)
      ..e('shape', shape, path != null ? TrackShape.path : TrackShape.line)
      ..d('x1', x1, 0)
      ..d('y1', y1, 0)
      ..d('x2', x2, 0)
      ..d('y2', y2, -100)
      ..b('relative', relative, false)
      ..e('units', units, TrackUnits.pixels)
      ..d('startAngle', startAngle, -135)
      ..d('sweepAngle', sweepAngle, 270)
      ..d('pivotX', pivotX, 0)
      ..d('pivotY', pivotY, 0)
      ..b('rotate', rotate, true);
    if (path != null) j['path'] = path!.toJson();
    j
      ..d('detent', detent, 0)
      ..d('overscroll', overscroll, 0);
    if (physics != null) j['physics'] = physics!.toJson();
    j
      ..i('settle', settle, 0)
      ..e('settleCurve', settleCurve, AnimationCurve.easeOutCubic);
    if (settleSpring != defaultSettleSpring) j['settleSpring'] = settleSpring.toJsonOver(defaultSettleSpring);
    j
      ..i('snap', snap, 0)
      ..e('snapCurve', snapCurve, AnimationCurve.easeOutBack)
      ..dn('defaultValue', defaultValue);
    if (doubleTapValues.isNotEmpty) j['doubleTapValues'] = doubleTapValues.map(writeDouble).toList();
    return j
      ..dn('parkedProgress', parkedProgress)
      ..d('fineStep', fineStep, 0)
      ..d('finePixelsPerRange', finePixelsPerRange, 0)
      ..i('fineHold', fineHold, 380)
      ..s('fineVariable', fineVariable)
      ..b('smooth', smooth, false)
      ..d('gain', gain, 1);
  }

  @override
  List<Object?> get props => [
    enabled, variable, value, min, max, step, clamp, input, allowedInteraction, hitArea, pixelsPerRange, //
    wheelStep, keyStep, shape, x1, y1, x2, y2, relative, units, startAngle, sweepAngle, pivotX, pivotY, rotate,
    path, detent, overscroll, physics, settle, settleCurve, settleSpring, snap, snapCurve, defaultValue,
    doubleTapValues, parkedProgress, fineStep, finePixelsPerRange, fineHold, fineVariable, smooth, gain,
  ];
}

// --- following the pointer: dismissible and pan ---------------------------------

/// The legacy `drag` fields that only some apps used, kept read and working
/// on [DismissibleBehavior] and [Pan] until each has its replacement (see
/// docs/design/04-drag-and-track.md, "Not yet migrated"). Deprecated: new
/// documents should not use them.
mixin _LegacyFollow {
  /// Degrees the node tilts per its own width of horizontal travel, about
  /// ([originX], [originY]) (-1–1 of its box). Deprecated: bind
  /// `motion.rotate` to the drag's offset.
  double get rotateFactor;
  double get originX;
  double get originY;

  /// Wiggles when a disabled drag is tried. Deprecated: a `dragEnd`
  /// reaction playing the `shake` animation preset.
  bool get shakeWhenDisabled;

  /// The share of the pointer's travel a disabled drag still follows (and
  /// springs back from). Deprecated: stay enabled and bind the limits.
  double get disabledFollow;

  /// A variable the live drag values (`${drag}`) are written to.
  /// Deprecated: [Pan.xVariable]/[Pan.yVariable], or a reaction writing
  /// what is shared.
  String get shareAs;

  /// Off, the node isn't moved, only reports its drag. Deprecated.
  bool get follow;
}

/// How [DismissibleBehavior]'s and [Pan]'s legacy fields read from [r].
({double rotateFactor, double originX, double originY, bool shakeWhenDisabled, double disabledFollow, String shareAs, bool follow})
    _legacyFollowOf(_R r) => (
          rotateFactor: r.d('rotateFactor', 0),
          originX: r.d('originX', 0),
          originY: r.d('originY', 0),
          shakeWhenDisabled: r.b('shakeWhenDisabled', false),
          disabledFollow: r.d('disabledFollow', 0),
          shareAs: r.s('shareAs'),
          follow: r.b('follow', true),
        );

extension on Json {
  void legacyFollow(_LegacyFollow f) => this
    ..d('rotateFactor', f.rotateFactor, 0)
    ..d('originX', f.originX, 0)
    ..d('originY', f.originY, 0)
    ..b('shakeWhenDisabled', f.shakeWhenDisabled, false)
    ..d('disabledFollow', f.disabledFollow, 0)
    ..s('shareAs', f.shareAs)
    ..b('follow', f.follow, true);
}

/// The [DragDirection]s of a list of names, or of a Flutter
/// `DismissDirection` name (`horizontal`, `vertical`, `endToStart`,
/// `startToEnd`, `up`, `down`, `none`); null when [v] is neither.
List<DragDirection>? _directionsOf(Object? v) {
  if (v is String) {
    return switch (v) {
      'horizontal' => const [DragDirection.left, DragDirection.right],
      'vertical' => const [DragDirection.up, DragDirection.down],
      'endToStart' || 'left' => const [DragDirection.left],
      'startToEnd' || 'right' => const [DragDirection.right],
      'up' => const [DragDirection.up],
      'down' => const [DragDirection.down],
      'none' => const [],
      _ => null,
    };
  }
  final l = readList(_jsonText(v));
  if (l == null) return null;
  return [
    for (final d in DragDirection.values)
      if (l.contains(d.name)) d,
  ];
}

/// Swiped away past a threshold (node key `dismissible`): Flutter's
/// `Dismissible`. The node follows the pointer toward its [directions]
/// (held back by [resistance] the other ways); let go past its
/// [dismissThresholds] share of its size, or faster than [flingVelocity],
/// it flies off over [movementDuration] and fires the swipe of that
/// direction (`swipeLeft`...; `Dismissible.onDismissed`), then shows its
/// next content back at rest. Otherwise it returns: on [returnSpring], else
/// over [returnDuration] along [returnCurve]. A swipe card.
///
/// Inside it `${dismiss.dx}`, `${dismiss.dy}`, `${dismiss.progress}` (0–1
/// toward the threshold, `Dismissible.onUpdate`), `${dismiss.direction}`,
/// `${dismiss.dragging}` can be read (and the same as the legacy
/// `${drag.*}`). It fires `drag` and `dragEnd`. The legacy `drag` with
/// `release: dismiss` reads as this, with its old defaults written out.
@immutable
final class DismissibleBehavior extends _Value with _LegacyFollow {
  const DismissibleBehavior({
    this.enabled = true,
    this.directions = const [DragDirection.left, DragDirection.right],
    this.axis = DragAxis.free,
    this.dismissThresholds = const {},
    this.flingVelocity = 700,
    this.resistance = 0,
    this.movementDuration = 200,
    this.curve = AnimationCurve.linear,
    this.returnDuration,
    this.returnCurve,
    this.returnSpring,
    this.restX = 0,
    this.restY = 0,
    this.xVariable = '',
    this.yVariable = '',
    this.flyOutRotate = 0,
    this.rotateFactor = 0,
    this.originX = 0,
    this.originY = 0,
    this.shakeWhenDisabled = false,
    this.disabledFollow = 0,
    this.shareAs = '',
    this.follow = true,
  });

  /// `Dismissible`'s `_kDismissThreshold`: the share of the node's size a
  /// drag must travel when [dismissThresholds] doesn't name its direction.
  static const double defaultThreshold = 0.4;

  /// Bindable as `dismissible.enabled`: off, a drag doesn't move it.
  final bool enabled;

  /// The directions it can be dismissed in (`Dismissible.direction`; its
  /// Flutter names `horizontal`, `vertical`, `endToStart`, `startToEnd`,
  /// `up`, `down` and `none` read too).
  final List<DragDirection> directions;

  /// The axis it moves on (`Draggable.axis`); free moves it both ways, the
  /// ones it can't be dismissed in held back by [resistance].
  final DragAxis axis;

  /// Per direction, the share of its size a drag must travel to dismiss
  /// (`Dismissible.dismissThresholds`); a direction not named takes
  /// [defaultThreshold].
  final Map<DragDirection, double> dismissThresholds;

  /// Pixels per second along a direction past which a release dismisses
  /// however short the drag.
  final double flingVelocity;

  /// 0–1: how much of the pointer's travel toward a direction it can't be
  /// dismissed in is ignored (1 none follows; below 1 a rubber band).
  final double resistance;

  /// The fly-off (ms, `Dismissible.movementDuration`) and its curve.
  final int movementDuration;
  final AnimationCurve curve;

  /// The return to rest when let go short (ms and curve); null takes
  /// [movementDuration] and [curve]. [returnSpring] overrides them.
  final int? returnDuration;
  final AnimationCurve? returnCurve;

  /// The spring it returns on, carrying the release's speed; null returns
  /// over [returnDuration].
  final Spring? returnSpring;

  /// Where it rests, from where its layout puts it (pixels); a new value
  /// moves it there. Deprecated (one app): a `motion.translateX` binding.
  final double restX, restY;

  /// Number variables its offset is written to (rounded to hundredths) as
  /// it moves. Deprecated: a `drag` reaction writing `${result.dx}`.
  final String xVariable, yVariable;

  /// Degrees it turns while flying off (left and up negative). Deprecated:
  /// an animation played by the swipe's reaction.
  final double flyOutRotate;
  @override
  final double rotateFactor, originX, originY, disabledFollow;
  @override
  final bool shakeWhenDisabled, follow;
  @override
  final String shareAs;

  int get effectiveReturnDuration => returnDuration ?? movementDuration;
  AnimationCurve get effectiveReturnCurve => returnCurve ?? curve;

  /// The share of its size a drag toward [d] must travel to dismiss.
  double thresholdFor(DragDirection d) => dismissThresholds[d] ?? defaultThreshold;

  /// The dismissible a legacy `drag` object [d] amounts to (`release:
  /// dismiss`, no track, not a reorder handle), its old defaults written
  /// out; null for any other drag.
  static DismissibleBehavior? fromLegacyDrag(Json? d) {
    if (d == null || readMap(d['track']) != null || readBool(d['reorder']) == true) return null;
    final r = _R(d);
    if (r.e(DragRelease.values, 'release', DragRelease.snapBack) != DragRelease.dismiss) return null;
    final distance = r.d('distanceThreshold', 0.35), vertical = r.dn('verticalThreshold') ?? distance;
    final physics = GesturePhysics.fromJson(d['physics']);
    final legacy = _legacyFollowOf(r);
    return DismissibleBehavior(
      enabled: _loose(d['enabled']) ?? true,
      directions: _directionsOf(d['directions']) ?? DragDirection.values,
      axis: r.e(DragAxis.values, 'axis', DragAxis.free),
      dismissThresholds: {
        for (final dir in DragDirection.values)
          if ((dir == DragDirection.up || dir == DragDirection.down ? vertical : distance) case final t
              when t != defaultThreshold)
            dir: t,
      },
      flingVelocity: r.d('velocityThreshold', 800),
      resistance: r.d('resistance', 0),
      movementDuration: r.ms('flyOut', 320),
      curve: r.curve('flyOutCurve', AnimationCurve.easeIn),
      returnDuration: r.ms('snapBack', 450),
      returnCurve: r.curve('snapCurve', AnimationCurve.spring),
      returnSpring: physics?.spring,
      restX: r.d('restX', 0),
      restY: r.d('restY', 0),
      xVariable: r.s('xVariable'),
      yVariable: r.s('yVariable'),
      flyOutRotate: r.d('flyOutRotate', 0),
      rotateFactor: legacy.rotateFactor,
      originX: legacy.originX,
      originY: legacy.originY,
      shakeWhenDisabled: legacy.shakeWhenDisabled,
      disabledFollow: legacy.disabledFollow,
      shareAs: legacy.shareAs,
      follow: legacy.follow,
    );
  }

  static DismissibleBehavior? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final legacy = _legacyFollowOf(r);
    final thresholds = readMap(_jsonText(m['dismissThresholds']));
    return DismissibleBehavior(
      enabled: _loose(m['enabled']) ?? true,
      directions: _directionsOf(m['directions'] ?? m['direction']) ?? const [DragDirection.left, DragDirection.right],
      axis: r.e(DragAxis.values, 'axis', DragAxis.free),
      dismissThresholds: {
        for (final d in DragDirection.values)
          if (readDouble(thresholds?[d.name]) case final double t) d: t,
      },
      flingVelocity: r.d('flingVelocity', 700),
      resistance: r.d('resistance', 0),
      movementDuration: r.ms('movementDuration', 200),
      curve: r.curve('curve', AnimationCurve.linear),
      returnDuration: readInt(m['returnDuration'])?.let((v) => math.max(0, v)),
      returnCurve: AnimationCurve.parse(m['returnCurve']),
      returnSpring: Spring.fromJson(m['returnSpring']),
      restX: r.d('restX', 0),
      restY: r.d('restY', 0),
      xVariable: r.s('xVariable'),
      yVariable: r.s('yVariable'),
      flyOutRotate: r.d('flyOutRotate', 0),
      rotateFactor: legacy.rotateFactor,
      originX: legacy.originX,
      originY: legacy.originY,
      shakeWhenDisabled: legacy.shakeWhenDisabled,
      disabledFollow: legacy.disabledFollow,
      shareAs: legacy.shareAs,
      follow: legacy.follow,
    );
  }

  Json toJson() {
    final j = <String, Object?>{}..b('enabled', enabled, true);
    if (!jsonEquality.equals(directions, const [DragDirection.left, DragDirection.right])) {
      j['directions'] = [for (final d in directions) d.name];
    }
    j.e('axis', axis, DragAxis.free);
    if (dismissThresholds.isNotEmpty) {
      j['dismissThresholds'] = {for (final e in dismissThresholds.entries) e.key.name: writeDouble(e.value)};
    }
    j
      ..d('flingVelocity', flingVelocity, 700)
      ..d('resistance', resistance, 0)
      ..i('movementDuration', movementDuration, 200)
      ..e('curve', curve, AnimationCurve.linear);
    if (returnDuration != null) j['returnDuration'] = returnDuration;
    if (returnCurve != null) j['returnCurve'] = returnCurve!.name;
    if (returnSpring != null) j['returnSpring'] = returnSpring!.toJson();
    return j
      ..d('restX', restX, 0)
      ..d('restY', restY, 0)
      ..s('xVariable', xVariable)
      ..s('yVariable', yVariable)
      ..d('flyOutRotate', flyOutRotate, 0)
      ..legacyFollow(this);
  }

  @override
  List<Object?> get props => [
    enabled, directions, axis, dismissThresholds, flingVelocity, resistance, movementDuration, curve, //
    returnDuration, returnCurve, returnSpring, restX, restY, xVariable, yVariable, flyOutRotate, rotateFactor, originX,
    originY,
    shakeWhenDisabled, disabledFollow, shareAs, follow,
  ];
}

/// What a [Pan] does when let go: springs back to rest, or stays where it
/// is (settling by its physics: a fling, snap points).
enum PanRelease { snapBack, stay }

/// The legacy `drag.release`; `dismiss` reads as [DismissibleBehavior].
enum DragRelease { snapBack, stay, dismiss }

/// Follows the pointer (node key `pan`): `GestureDetector(onPanUpdate:)`
/// moving a `Transform.translate`. On release it springs back to rest or
/// stays ([release]), with [physics] a fling that slows by friction, a
/// spring and snap points within [bounds] and the limits [minX]...[maxY]
/// (a bottom sheet: `{"axis": "vertical", "release": "stay", "minY": -560,
/// "maxY": 0, "physics": {"snap": {"points": [[0, 0], [0, -560]]}}}`).
/// Its offset binds two-way to [xVariable] and [yVariable]; [x] and [y]
/// (bindable) place its rest.
///
/// Inside it `${pan.dx}`, `${pan.dy}`, `${pan.dragging}`,
/// `${pan.settling}`, `${pan.snapIndex}` can be read (and the same as the
/// legacy `${drag.*}`). It fires `drag` and `dragEnd`. The legacy `drag`
/// that is neither a track, a reorder handle nor dismissing reads as this.
@immutable
final class Pan extends _Value with _LegacyFollow {
  const Pan({
    this.enabled = true,
    this.axis = DragAxis.free,
    this.release = PanRelease.snapBack,
    this.returnDuration = 450,
    this.returnCurve = AnimationCurve.spring,
    this.x = 0,
    this.y = 0,
    this.xVariable = '',
    this.yVariable = '',
    this.physics,
    this.bounds = GestureBounds.none,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
    this.rotateFactor = 0,
    this.originX = 0,
    this.originY = 0,
    this.shakeWhenDisabled = false,
    this.disabledFollow = 0,
    this.shareAs = '',
    this.follow = true,
  });

  /// Bindable as `pan.enabled`.
  final bool enabled;

  /// The axis it moves on (`Draggable.axis`, `InteractiveViewer.panAxis`).
  final DragAxis axis;
  final PanRelease release;

  /// The spring back to rest without [physics] (ms and curve).
  final int returnDuration;
  final AnimationCurve returnCurve;

  /// Where it rests, from where its layout puts it (pixels; bindable as
  /// `pan.x`, `pan.y`): it springs back here, and a new value moves it.
  final double x, y;

  /// Number variables its offset from where its layout puts it is written
  /// to (rounded to hundredths) as it moves.
  final String xVariable, yVariable;

  /// How it moves on its own after release (a fling, a spring settle, snap
  /// points, overscroll); null returns over [returnDuration].
  final GesturePhysics? physics;

  /// What it's kept inside of while dragged and flung, narrowed by the
  /// offsets from rest [minX]...[maxY] (null: no limit).
  final GestureBounds bounds;
  final double? minX, maxX, minY, maxY;
  @override
  final double rotateFactor, originX, originY, disabledFollow;
  @override
  final bool shakeWhenDisabled, follow;
  @override
  final String shareAs;

  bool get hasBounds => bounds != GestureBounds.none || minX != null || maxX != null || minY != null || maxY != null;

  /// The pan a legacy `drag` object [d] amounts to (not a track, a reorder
  /// handle or dismissing); null for any other drag.
  static Pan? fromLegacyDrag(Json? d) {
    if (d == null || readMap(d['track']) != null || readBool(d['reorder']) == true) return null;
    final r = _R(d);
    final release = r.e(DragRelease.values, 'release', DragRelease.snapBack);
    if (release == DragRelease.dismiss) return null;
    return fromJson({
      ...d,
      'release': release.name,
      'returnDuration': ?d['snapBack'],
      'returnCurve': ?d['snapCurve'],
      'x': ?d['restX'],
      'y': ?d['restY'],
    });
  }

  static Pan? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final legacy = _legacyFollowOf(r);
    return Pan(
      enabled: _loose(m['enabled']) ?? true,
      axis: r.e(DragAxis.values, 'axis', DragAxis.free),
      release: r.e(PanRelease.values, 'release', PanRelease.snapBack),
      returnDuration: r.ms('returnDuration', 450),
      returnCurve: r.curve('returnCurve', AnimationCurve.spring),
      x: r.d('x', 0),
      y: r.d('y', 0),
      xVariable: r.s('xVariable'),
      yVariable: r.s('yVariable'),
      physics: GesturePhysics.fromJson(m['physics']),
      bounds: r.e(GestureBounds.values, 'bounds', GestureBounds.none),
      minX: r.dn('minX'),
      maxX: r.dn('maxX'),
      minY: r.dn('minY'),
      maxY: r.dn('maxY'),
      rotateFactor: legacy.rotateFactor,
      originX: legacy.originX,
      originY: legacy.originY,
      shakeWhenDisabled: legacy.shakeWhenDisabled,
      disabledFollow: legacy.disabledFollow,
      shareAs: legacy.shareAs,
      follow: legacy.follow,
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..b('enabled', enabled, true)
      ..e('axis', axis, DragAxis.free)
      ..e('release', release, PanRelease.snapBack)
      ..i('returnDuration', returnDuration, 450)
      ..e('returnCurve', returnCurve, AnimationCurve.spring)
      ..d('x', x, 0)
      ..d('y', y, 0)
      ..s('xVariable', xVariable)
      ..s('yVariable', yVariable);
    if (physics != null) j['physics'] = physics!.toJson();
    return j
      ..e('bounds', bounds, GestureBounds.none)
      ..dn('minX', minX)
      ..dn('maxX', maxX)
      ..dn('minY', minY)
      ..dn('maxY', maxY)
      ..legacyFollow(this);
  }

  @override
  List<Object?> get props => [
    enabled, axis, release, returnDuration, returnCurve, x, y, xVariable, yVariable, physics, bounds, minX, maxX, //
    minY, maxY, rotateFactor, originX, originY, shakeWhenDisabled, disabledFollow, shareAs, follow,
  ];
}

// --- one-shot effects -----------------------------------------------------------

/// A particle's shape; `image` draws the emitter's [ParticleEmitter.image].
enum ParticleShape {
  square,
  circle,
  strip,
  star,

  /// The emitter's [ParticleEmitter.image] (a URL), [ParticleEmitter.size]
  /// wide at the image's aspect ratio.
  image,

  /// A paper triangle.
  triangle,

  /// A wavy ribbon (stroked).
  squiggle,

  /// The emitter's [ParticleEmitter.glyph] (an emoji or any text), drawn at
  /// the particle's size.
  emoji,
}

/// Confetti, stars or emoji the node bursts with on cue.
///
/// Each particle leaves from the origin at [speed] (55–115%) in a direction
/// within [spread] of [direction], slows by [drag], falls by [gravity] no
/// faster than [terminalVelocity], sways [sway] px side to side, spins and
/// turns over ([flutter]), and fades out over the last [fadeOut] ms of its
/// [lifetime].
@immutable
final class ParticleEmitter extends _Value {
  const ParticleEmitter({
    this.count = 40,
    this.emit = 0,
    this.colors = defaultColors,
    this.shapes = const [ParticleShape.square, ParticleShape.strip, ParticleShape.circle],
    this.size = 10,
    this.originX = 0,
    this.originY = 0,
    this.originWidth = 0,
    this.direction = 0,
    this.spread = 60,
    this.speed = 700,
    this.gravity = 900,
    this.lifetime = 2600,
    this.playOnAppear = false,
    this.playKey,
    this.image = '',
    this.delay = 0,
    this.drag = 0,
    this.terminalVelocity = 0,
    this.sway = 0,
    this.flutter = 8,
    this.spin = 515,
    this.fadeOut = 500,
    this.mirror = false,
    this.glyph = '',
  });

  static const List<Color> defaultColors = [
    Color(0xFFFFC83D), Color(0xFFFF6F61), Color(0xFF2FD9A4), Color(0xFF8B6CFF), Color(0xFF3FB8FF), //
    Color(0xFFFF8BC6),
  ];

  final int count;

  /// Over how long the particles leave (ms; 0 all at once).
  final int emit;
  final List<Color> colors;
  final List<ParticleShape> shapes;
  final double size, originX, originY, originWidth, direction, spread, speed, gravity;
  final int lifetime;
  final bool playOnAppear;

  /// A cue the node's bindings set (`particles.playKey`): the particles
  /// burst each time it changes.
  final String? playKey;

  /// The image `image` particles draw (a URL; petals, seeds, raindrops),
  /// [size] wide, spinning as they fly.
  final String image;
  /// Wait after the cue before the first particle leaves (ms).
  final int delay;

  /// Air resistance: the speed falls by e^(-drag) each second (0: none).
  final double drag;

  /// The fastest a particle falls (px/s; 0: no limit). Paper floats.
  final double terminalVelocity;

  /// How far each particle sways side to side as it goes (px).
  final double sway;

  /// How fast each particle turns over in 3D (radians per second, up to;
  /// 0 keeps it flat).
  final double flutter;

  /// The fastest a particle spins (degrees per second).
  final double spin;

  /// The last part of its life over which a particle fades out (ms).
  final int fadeOut;

  /// Every other particle leaves mirrored across the node's vertical
  /// middle (its origin and direction flipped): two cannons facing each
  /// other.
  final bool mirror;

  /// What [ParticleShape.emoji] particles draw (bindable as
  /// `particles.glyph`).
  final String glyph;

  static ParticleEmitter? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final colors = readList(m['colors']);
    final shapes = readList(m['shapes']);
    return ParticleEmitter(
      count: math.max(0, r.i('count', 40)),
      emit: r.ms('emit', 0),
      colors: colors == null ? defaultColors : [...colors.map(Color.fromJson).nonNulls],
      shapes: shapes == null
          ? const [ParticleShape.square, ParticleShape.strip, ParticleShape.circle]
          : [
              for (final s in shapes)
                if (ParticleShape.values.where((v) => v.name == s).firstOrNull case final v?) v,
            ],
      size: r.d('size', 10),
      originX: r.d('originX', 0),
      originY: r.d('originY', 0),
      originWidth: r.d('originWidth', 0),
      direction: r.d('direction', 0),
      spread: r.d('spread', 60),
      speed: r.d('speed', 700),
      gravity: r.d('gravity', 900),
      lifetime: r.ms('lifetime', 2600),
      playOnAppear: r.b('playOnAppear', false),
      playKey: m['playKey']?.toString(),
      delay: r.ms('delay', 0),
      drag: math.max(0, r.d('drag', 0)),
      terminalVelocity: math.max(0, r.d('terminalVelocity', 0)),
      sway: r.d('sway', 0),
      flutter: math.max(0, r.d('flutter', 8)),
      spin: r.d('spin', 515),
      fadeOut: r.ms('fadeOut', 500),
      mirror: r.b('mirror', false),
      glyph: r.s('glyph'),
      image: r.s('image'),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..i('count', count, 40)
      ..i('emit', emit, 0);
    if (!jsonEquality.equals(colors, defaultColors)) j['colors'] = [for (final c in colors) c.toJson()];
    if (!jsonEquality.equals(shapes, const [ParticleShape.square, ParticleShape.strip, ParticleShape.circle])) {
      j['shapes'] = [for (final s in shapes) s.name];
    }
    return j
      ..d('size', size, 10)
      ..d('originX', originX, 0)
      ..d('originY', originY, 0)
      ..d('originWidth', originWidth, 0)
      ..d('direction', direction, 0)
      ..d('spread', spread, 60)
      ..d('speed', speed, 700)
      ..d('gravity', gravity, 900)
      ..i('lifetime', lifetime, 2600)
      ..b('playOnAppear', playOnAppear, false)
      ..s('playKey', playKey)
      ..i('delay', delay, 0)
      ..d('drag', drag, 0)
      ..d('terminalVelocity', terminalVelocity, 0)
      ..d('sway', sway, 0)
      ..d('flutter', flutter, 8)
      ..d('spin', spin, 515)
      ..i('fadeOut', fadeOut, 500)
      ..b('mirror', mirror, false)
      ..s('glyph', glyph)
      ..s('image', image.isEmpty ? null : image);
  }

  @override
  List<Object?> get props => [
    count, emit, colors, shapes, size, originX, originY, originWidth, direction, spread, speed, gravity, //
    lifetime, playOnAppear, playKey, image, delay, drag, terminalVelocity, sway, flutter, spin, fadeOut, mirror, glyph,
  ];
}

/// How a node with a [Behaviors.flightKey] flies in from where the node
/// with the same key was: on a spring by default, or, with a [duration],
/// along a curve that rises [lift] (or [liftShare] of the distance, the
/// larger) above the higher end, swelling to [swell] at the middle and
/// spinning [turns] times (toward the way it flies), trailing [trail] fading
/// dots.
@immutable
final class Flight extends _Value {
  const Flight({
    this.duration = 0,
    this.curve = AnimationCurve.easeInOut,
    this.lift = 0,
    this.liftShare = 0,
    this.swell = 1,
    this.turns = 0,
    this.trail = 0,
    this.trailColor = const Color(0xFFFFC83D),
  });

  /// The flight's length (ms); 0 flies on the node's spring.
  final int duration;
  final AnimationCurve curve;

  /// How far the path's control point rises above the higher end (px), or
  /// a share of the distance flown, whichever is larger; 0 and 0 fly
  /// straight.
  final double lift, liftShare;

  /// The node's scale at the middle of the flight (1: none).
  final double swell;

  /// Whole turns over the flight, clockwise when flying right.
  final double turns;

  /// Fading dots left behind (0: none), in [trailColor].
  final int trail;
  final Color trailColor;

  static Flight? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Flight(
      duration: r.ms('duration', 0),
      curve: r.e(AnimationCurve.values, 'curve', AnimationCurve.easeInOut),
      lift: r.d('lift', 0),
      liftShare: r.d('liftShare', 0),
      swell: r.d('swell', 1),
      turns: r.d('turns', 0),
      trail: math.max(0, r.i('trail', 0)),
      trailColor: Color.fromJson(m['trailColor']) ?? const Color(0xFFFFC83D),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..i('duration', duration, 0);
    if (curve != AnimationCurve.easeInOut) j['curve'] = curve.name;
    j
      ..d('lift', lift, 0)
      ..d('liftShare', liftShare, 0)
      ..d('swell', swell, 1)
      ..d('turns', turns, 0)
      ..i('trail', trail, 0);
    if (trailColor != const Color(0xFFFFC83D)) j['trailColor'] = trailColor.toJson();
    return j;
  }

  @override
  List<Object?> get props => [duration, curve, lift, liftShare, swell, turns, trail, trailColor];
}

// --- paint and scroll -------------------------------------------------------------

/// The unit of a [StrokePath] coordinate.
enum PathUnit { fraction, pixels }

/// How a [StrokePath] joins its points.
enum PathCurve {
  straight,
  vertical,
  horizontal,

  /// Quadratic Béziers: after the first point the points come in pairs, a
  /// control point and an end point (a hand-drawn outline exactly as a
  /// painter's `quadraticBezierTo` draws it, not sampled into lines). A
  /// last point without its pair is a straight line to it.
  quadratic,
}

/// A line drawn through [points] in the node's box (a dotted trail, a
/// connector), behind its content or [inFront] of it. x and y are fractions
/// of the box or pixels, per [xUnit]/[yUnit].
///
/// With [drawMs] a running app draws the line along its length, like a pen
/// (a map's passages inking in, a route tracing itself): over [drawMs] ms
/// after [drawDelayMs], eased by [drawCurve], up to [progress]; when the
/// node first shows, again from nothing when [drawKey] changes, and from
/// where it is when [progress] changes. The design canvas draws it at
/// [progress].
@immutable
final class StrokePath extends _Value {
  const StrokePath({
    this.points = const [],
    this.xUnit = PathUnit.fraction,
    this.yUnit = PathUnit.pixels,
    this.curve = PathCurve.straight,
    this.color = Color.white,
    this.width = 4,
    this.progress = 1,
    this.dashPattern = const [],
    this.cap = StrokeCap.round,
    this.inFront = false,
    this.drawMs = 0,
    this.drawDelayMs = 0,
    this.drawCurve = AnimationCurve.easeInOut,
    this.drawKey = '',
    this.fillColor,
    this.untilWidth = false,
  });

  final List<Offset> points;
  final PathUnit xUnit, yUnit;

  /// The shape the points enclose (the path closed), filled behind the
  /// line: a hand-drawn box with its own wobble. It fades in as the line
  /// draws (its alpha times [progress]). Null: no fill.
  final PathCurve curve;
  final Color color;
  final double width;

  /// Fraction of the stroke drawn, measured along its length.
  final double progress;

  /// Dash and gap lengths, alternating; empty is solid.
  final List<double> dashPattern;
  final StrokeCap cap;
  final bool inFront;

  /// How long (ms) a running app takes to draw the line; 0 shows it at once.
  final int drawMs;

  /// How long (ms) it waits before drawing.
  final int drawDelayMs;

  /// How the drawing eases.
  final AnimationCurve drawCurve;

  /// A cue: the line draws again from nothing each time it changes (bindable
  /// as `strokePath.drawKey`, e.g. `${route.id}`).
  final String drawKey;

  final Color? fillColor;

  /// Draws only the segments that start within the box's width, as a
  /// painter's loop `for (x = 0; x <= width; ...)` does: a long run of
  /// points (a hand-ruled line) rules any width, its last segment running
  /// past the edge as the painter's does.
  final bool untilWidth;

  /// Whether a running app animates it.
  bool get draws => drawMs > 0;

  StrokePath copyWith({double? progress}) => StrokePath(
        points: points,
        xUnit: xUnit,
        yUnit: yUnit,
        curve: curve,
        color: color,
        width: width,
        progress: progress ?? this.progress,
        dashPattern: dashPattern,
        cap: cap,
        inFront: inFront,
        drawMs: drawMs,
        drawDelayMs: drawDelayMs,
        drawCurve: drawCurve,
        drawKey: drawKey,
        fillColor: fillColor,
        untilWidth: untilWidth,
      );

  static StrokePath? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return StrokePath(
      points: [...?readList(m['points'])?.map(_pathPoint).nonNulls],
      xUnit: r.e(PathUnit.values, 'xUnit', PathUnit.fraction),
      yUnit: r.e(PathUnit.values, 'yUnit', PathUnit.pixels),
      curve: r.e(PathCurve.values, 'curve', PathCurve.straight),
      color: r.color('color') ?? Color.white,
      width: r.d('width', 4),
      progress: r.d('progress', 1).clamp(0, 1).toDouble(),
      dashPattern: r.doubles('dashPattern'),
      cap: r.e(StrokeCap.values, 'cap', StrokeCap.round),
      inFront: r.b('inFront', false),
      drawMs: r.ms('drawMs', 0),
      drawDelayMs: r.ms('drawDelayMs', 0),
      drawCurve: r.curve('drawCurve', AnimationCurve.easeInOut),
      drawKey: readString(m['drawKey']) ?? (m['drawKey'] == null ? '' : '${m['drawKey']}'),
      fillColor: r.color('fillColor'),
      untilWidth: r.b('untilWidth', false),
    );
  }

  /// A point as `[x, y]` or `{"x", "y"}` (the form Firestore can store, and
  /// what data bound to `strokePath.points` may give).
  static Offset? _pathPoint(Object? p) {
    final l = readList(p);
    if (l != null) return l.length == 2 ? Offset.fromJson(l) : null;
    final m = readMap(p);
    final x = readDouble(m?['x']), y = readDouble(m?['y']);
    return x == null || y == null ? null : Offset(x, y);
  }

  Json toJson() {
    final j =
        <String, Object?>{
            'points': [for (final p in points) p.toJson()],
          }
          ..e('xUnit', xUnit, PathUnit.fraction)
          ..e('yUnit', yUnit, PathUnit.pixels)
          ..e('curve', curve, PathCurve.straight);
    if (color != Color.white) j['color'] = color.toJson();
    j.d('width', width, 4);
    j.d('progress', progress, 1);
    if (dashPattern.isNotEmpty) j['dashPattern'] = dashPattern.map(writeDouble).toList();
    j
      ..e('cap', cap, StrokeCap.round)
      ..b('inFront', inFront, false)
      ..i('drawMs', drawMs, 0)
      ..i('drawDelayMs', drawDelayMs, 0)
      ..e('drawCurve', drawCurve, AnimationCurve.easeInOut);
    if (drawKey.isNotEmpty) j['drawKey'] = drawKey;
    if (fillColor != null) j['fillColor'] = fillColor!.toJson();
    j.b('untilWidth', untilWidth, false);
    return j;
  }

  @override
  List<Object?> get props => [points, xUnit, yUnit, curve, color, width, progress, dashPattern, cap, inFront, drawMs, drawDelayMs, drawCurve, drawKey, fillColor, untilWidth];
}

/// Text that types itself out in a running app, like a typewriter or a
/// terminal: [charsPerSecond] characters a second after [delayMs], with a
/// blinking block [caret] after the last one while it types. It types when
/// the text first shows and again from the start when [playKey] changes; when
/// the text grows by appending (a streamed reply) only the new characters
/// type, and when it changes otherwise it types afresh. [skip] (bindable, e.g.
/// to a tap that sets a variable) shows the rest at once; off [enabled] it
/// shows all of it. The layout never changes as it types: the whole text is
/// laid out and only what's typed is painted. The design canvas shows it
/// all.
@immutable
final class Typewriter extends _Value {
  const Typewriter({
    this.enabled = true,
    this.charsPerSecond = 40,
    this.delayMs = 0,
    this.caret = true,
    this.caretColor,
    this.caretWidth = 0,
    this.caretHeight = 0,
    this.caretGap = 1,
    this.caretAlignStyle = TextStyle.empty,
    this.blinkMs = 500,
    this.skip = false,
    this.playKey = '',
    this.holdAtMs,
    this.grow = false,
  });

  /// Off, the whole text shows (bindable as `typewriter.enabled`).
  final bool enabled;

  /// How fast it types (bindable as `typewriter.charsPerSecond`).
  final double charsPerSecond;

  /// How long (ms) it waits before the first character (bindable as
  /// `typewriter.delayMs`, e.g. to follow the line before it).
  final int delayMs;

  /// Whether a block caret blinks after the last character while it types.
  final bool caret;

  /// The caret's color, painted as given; null uses the text's, a little
  /// faded.
  final Color? caretColor;

  /// The caret's width; 0 is about half the font size.
  final double caretWidth;

  /// The caret's height, centered on the text's middle (as a widget span
  /// aligned to the middle of the line); 0 is about three quarters of the
  /// line, from just below its top.
  final double caretHeight;

  /// The space between the last character and the caret.
  final double caretGap;

  /// With [caretHeight]: the style whose middle the caret centers on, as a
  /// middle-aligned widget span outside the text's own span takes its
  /// paragraph's style (e.g. the app's default text style). Empty: the
  /// text's own.
  final TextStyle caretAlignStyle;

  /// How long the caret stays on, and off (ms).
  final int blinkMs;

  /// Shows the rest of the text at once (bindable as `typewriter.skip`).
  final bool skip;

  /// A cue: types again from the start each time it changes (bindable as
  /// `typewriter.playKey`).
  final String playKey;

  /// Stops the typing clock this many ms after it starts (its delay
  /// included): the text holds part-typed, caret blinking, as a still of
  /// the moment (bindable as `typewriter.holdAtMs`). Lines that type one
  /// after another (each delayed by the ones before) all stop at the same
  /// moment. Null types to the end.
  final int? holdAtMs;

  /// The node is only as tall as the lines typed so far, growing line by
  /// line (a note card that fills as it's written). Off, it keeps the whole
  /// text's size from the start, so nothing around it moves.
  final bool grow;

  /// Whether a running app types (rather than shows the whole text).
  bool get types => enabled && !skip && charsPerSecond > 0;

  static Typewriter? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final cps = r.d('charsPerSecond', 40);
    return Typewriter(
      enabled: r.b('enabled', true),
      charsPerSecond: cps.isFinite && cps > 0 ? cps : 40,
      delayMs: r.ms('delayMs', 0),
      caret: r.b('caret', true),
      caretColor: r.color('caretColor'),
      caretWidth: math.max(0, r.d('caretWidth', 0)),
      caretHeight: math.max(0, r.d('caretHeight', 0)),
      caretGap: r.d('caretGap', 1),
      caretAlignStyle: TextStyle.fromJson(m['caretAlignStyle']),
      blinkMs: math.max(1, r.ms('blinkMs', 500)),
      skip: r.b('skip', false),
      playKey: readString(m['playKey']) ?? (m['playKey'] == null ? '' : '${m['playKey']}'),
      holdAtMs: m['holdAtMs'] == null || m['holdAtMs'] == '' ? null : math.max(0, r.ms('holdAtMs', 0)),
      grow: r.b('grow', false),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..b('enabled', enabled, true)
      ..d('charsPerSecond', charsPerSecond, 40)
      ..i('delayMs', delayMs, 0)
      ..b('caret', caret, true);
    if (caretColor != null) j['caretColor'] = caretColor!.toJson();
    j
      ..d('caretWidth', caretWidth, 0)
      ..d('caretHeight', caretHeight, 0)
      ..d('caretGap', caretGap, 1);
    if (!caretAlignStyle.isEmpty) j['caretAlignStyle'] = caretAlignStyle.toJson();
    j
      ..i('blinkMs', blinkMs, 500)
      ..b('skip', skip, false);
    if (playKey.isNotEmpty) j['playKey'] = playKey;
    if (holdAtMs != null) j['holdAtMs'] = holdAtMs;
    j.b('grow', grow, false);
    return j;
  }

  @override
  List<Object?> get props => [enabled, charsPerSecond, delayMs, caret, caretColor, caretWidth, caretHeight, caretGap, caretAlignStyle, blinkMs, skip, playKey, holdAtMs, grow];
}

/// Scrolls the node into view when it appears (or when its `reveal.when`
/// binding turns true), to [alignment] of the viewport (0 top, 1 bottom).
/// With [follow] it stays there while the content around it moves (lines
/// added above an end marker, an image that loads late), until the user
/// scrolls away: a chat or transcript pinned to its newest line.
@immutable
final class Reveal extends _Value {
  const Reveal({this.alignment = 0.5, this.duration = 600, this.delay = 0, this.when = true, this.follow = false});

  final double alignment;
  final int duration, delay;
  final bool when;

  /// Keeps the node revealed as the content moves, until the user scrolls.
  final bool follow;

  static Reveal? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Reveal(
      alignment: r.d('alignment', 0.5),
      duration: r.ms('duration', 600),
      delay: r.ms('delay', 0),
      when: r.b('when', true),
      follow: r.b('follow', false),
    );
  }

  Json toJson() => <String, Object?>{}
    ..d('alignment', alignment, 0.5)
    ..i('duration', duration, 600)
    ..i('delay', delay, 0)
    ..b('when', when, true)
    ..b('follow', follow, false);

  @override
  List<Object?> get props => [alignment, duration, delay, when, follow];
}

/// Pins the node inside the scrolling row or column it scrolls in, as CSS
/// `position: sticky`: once its leading edge reaches [offset] from the
/// view's leading edge it stays there, drawn above the content scrolling
/// under it, until the end of its parent (the section it heads) pushes it
/// on. `${sticky.stuck}` says whether it is pinned now (the node's own
/// bindings and the nodes inside it read it). The design canvas, which
/// doesn't scroll, draws it in place. JSON `true` or `{"offset": 8}`.
@immutable
final class Sticky extends _Value {
  const Sticky({this.offset = 0});

  /// Distance from the view's leading edge where it pins, in pixels.
  final double offset;

  static Sticky? fromJson(Object? json) {
    if (json == true) return const Sticky();
    final m = readMap(json);
    if (m == null) return null;
    return Sticky(offset: _R(m).d('offset', 0));
  }

  Json toJson() => <String, Object?>{}..d('offset', offset, 0);

  @override
  List<Object?> get props => [offset];
}

/// Writes where the node is laid out, `{x, y, width, height, centerX,
/// centerY}` in pixels, to a variable as layout changes: in the
/// coordinates of the ancestor node [relativeTo] (empty: the screen),
/// under [key] when the variable is a map. Other nodes then follow it: a
/// marker travelling to the chip of the reader's layer on a timeline whose
/// chips are laid out by data. The design canvas measures too.
@immutable
final class Measure extends _Value {
  const Measure({this.variable = '', this.key = '', this.relativeTo = ''});

  final String variable;

  /// With [variable] a map: the key (an expression, `${item.id}`).
  final String key;

  /// The id of an ancestor node whose box the position is measured in.
  final String relativeTo;

  static Measure? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Measure(variable: r.s('variable'), key: r.s('key'), relativeTo: r.s('relativeTo'));
  }

  Json toJson() => <String, Object?>{}
    ..s('variable', variable)
    ..s('key', key)
    ..s('relativeTo', relativeTo);

  @override
  List<Object?> get props => [variable, key, relativeTo];
}

/// How a [ViewProgress] measures its node against the viewport.
enum ViewProgressMode {
  /// The node's leading edge travels from [ViewProgress.from] to
  /// [ViewProgress.to] of the viewport (0 to 1).
  travel,

  /// A line at [ViewProgress.from] of the viewport passes over the node,
  /// from its leading edge (0) to its trailing edge (1).
  pass,
}

/// How far the node has scrolled through the viewport of the scrolling row
/// or column (or list) it is in, as `${view.progress}` (0–1) and
/// `${view.visible}` for its own bindings and the nodes inside it: a
/// figure that draws itself as it scrolls up the screen (a path's
/// `trimEnd`), a heading that fades in, a gauge reading how far through a
/// section the reader is. Positions are fractions of the viewport's extent
/// from its leading edge (0 top, 1 bottom), plus [offset] pixels. With
/// [variable], the progress is also written to that screen (or app)
/// variable, under [key] when it's a map, for nodes elsewhere to read.
/// The design canvas reads progress 0 above the fold and 1 for a node it
/// shows whole.
@immutable
final class ViewProgress extends _Value {
  const ViewProgress({
    this.mode = ViewProgressMode.travel,
    this.from = 1,
    this.to = 0,
    this.offset = 0,
    this.variable = '',
    this.key = '',
  });

  final ViewProgressMode mode;

  /// [ViewProgressMode.travel]: where the leading edge is at progress 0;
  /// [ViewProgressMode.pass]: where the line is.
  final double from;

  /// [ViewProgressMode.travel]: where the leading edge is at progress 1.
  final double to;

  /// Pixels added to [from] and [to] (a sticky header's height).
  final double offset;

  /// A variable the progress is written to as it changes (rounded to 0.001).
  final String variable;

  /// With [variable] a map: the key it's written under.
  final String key;

  /// The progress of a node whose leading edge is [lead] pixels from the
  /// viewport's leading edge, [extent] long, in a viewport [viewport] long.
  double progressAt(double lead, double extent, double viewport) {
    final a = from * viewport + offset;
    if (mode == ViewProgressMode.pass) {
      if (extent <= 0) return a >= lead ? 1 : 0;
      return ((a - lead) / extent).clamp(0.0, 1.0);
    }
    final b = to * viewport + offset;
    if (a == b) return lead <= b ? 1 : 0;
    return ((a - lead) / (a - b)).clamp(0.0, 1.0);
  }

  static ViewProgress? fromJson(Object? json) {
    if (json == true) return const ViewProgress();
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return ViewProgress(
      mode: r.e(ViewProgressMode.values, 'mode', ViewProgressMode.travel),
      from: r.d('from', 1),
      to: r.d('to', 0),
      offset: r.d('offset', 0),
      variable: r.s('variable'),
      key: r.s('key'),
    );
  }

  Json toJson() => <String, Object?>{}
    ..e('mode', mode, ViewProgressMode.travel)
    ..d('from', from, 1)
    ..d('to', to, 0)
    ..d('offset', offset, 0)
    ..s('variable', variable)
    ..s('key', key);

  @override
  List<Object?> get props => [mode, from, to, offset, variable, key];
}

/// How a shared element flies between screens.
enum HeroFlightShuttle {
  /// Flutter's `Hero` flight.
  standard,

  /// Also morphs the corner radius from one box to the other.
  morphCorners,

  /// Along a curve (Material's arc), turning upright as it lands, with a
  /// halo in the color of its first drop shadow (soft white without one).
  arc,

  /// Both nodes fly fitted to the box in between, the leaving one fading
  /// out as the arriving one fades in, corners morphing.
  morph,

  /// [morph], the leaving node gone over the first 35% (Material fade
  /// through).
  fadeThrough,

  /// Material container transform: a card grows into a whole screen (tag
  /// the card and the destination's root the same); the card fades out over
  /// the first 30%.
  containerTransform;

  /// Whether both nodes are drawn during the flight, cross-fading.
  bool get crossFades => this == morph || this == fadeThrough || this == containerTransform;
}

/// Makes the node a shared element (Flutter's `Hero`): it flies between
/// its places on two screens with the same [tag] while a navigation plays.
@immutable
final class HeroTag extends _Value {
  const HeroTag(this.tag, {this.flight = HeroFlightShuttle.standard, this.placeholder = HeroPlaceholder.none});

  final String tag;
  final HeroFlightShuttle flight;

  /// What the destination shows until its own image has loaded.
  final HeroPlaceholder placeholder;

  static HeroTag? fromJson(Object? json) {
    if (json is String) return json.isEmpty ? null : HeroTag(json);
    final m = readMap(json);
    final tag = readString(m?['tag']);
    if (m == null || tag == null) return null;
    return HeroTag(
      tag,
      flight: readEnum(HeroFlightShuttle.values, m['flight'], HeroFlightShuttle.standard),
      placeholder: readEnum(HeroPlaceholder.values, m['placeholder'], HeroPlaceholder.none),
    );
  }

  Object toJson() => flight == HeroFlightShuttle.standard && placeholder == HeroPlaceholder.none
      ? tag
      : {
          'tag': tag,
          if (flight != HeroFlightShuttle.standard) 'flight': flight.name,
          if (placeholder != HeroPlaceholder.none) 'placeholder': placeholder.name,
        };

  @override
  List<Object?> get props => [tag, flight, placeholder];
}

// --- all together -----------------------------------------------------------------

/// A node's behaviors. Stored flat in the node's JSON under [keys].
@immutable
final class Behaviors extends _Value {
  const Behaviors({
    this.motion,
    this.scale = 1,
    this.animations = const [],
    this.transitions = const [],
    this.shimmer,
    this.inkWell,
    this.states = StateStyles.none,
    this.tooltip = '',
    this.ignorePointer = false,
    this.floating = false,
    this.hero,
    this.flightKey = '',
    this.flight,
    this.draggable,
    this.dropTarget,
    this.track,
    this.dismissible,
    this.pan,
    this.reorderHandle = false,
    this.reveal,
    this.strokePath,
    this.typewriter,
    this.particles,
    this.textDirection,
    this.flip,
    this.tilt,
    this.transformGesture,
    this.sticky,
    this.viewProgress,
    this.measure,
    this.customPaint,
  });

  static const Behaviors none = Behaviors();

  /// The transform over the layout (Flutter's `Transform`).
  final Motion? motion;

  /// Drawn at this size around its center; layout unchanged (Flutter's
  /// `Transform.scale`). Bindable as `scale`.
  final double scale;

  /// Its animation controllers and their tracks, outermost first
  /// ([NodeAnimation]); the legacy `loops` and `effectAnimations` read as
  /// these.
  final List<NodeAnimation> animations;

  /// How changes of its properties animate ([Transition], one per
  /// property path).
  final List<Transition> transitions;

  /// A band of light over what it paints (the `shimmer` animation preset
  /// sweeps it).
  final Shimmer? shimmer;

  /// Ink: ripples, and hover/focus/press overlays.
  final InkWellStyle? inkWell;

  /// Property overrides per interaction state.
  final StateStyles states;

  /// Shown on hover or long press; may hold `${...}` data.
  final String tooltip;

  /// Lets pointer events through to what's under the node (Flutter's
  /// `IgnorePointer`).
  final bool ignorePointer;

  /// Drawn above everything else at runtime (a menu under a field), still
  /// taking its place in the layout. The design canvas draws it in place.
  final bool floating;
  final HeroTag? hero;

  /// Flies the node in from where the node with the same key just was.
  final String flightKey;

  /// How it flies there ([flightKey]); null flies on the node's spring.
  final Flight? flight;
  final DragSource? draggable;
  final DropTarget? dropTarget;

  /// A value set by dragging the node along a line, arc or path (Flutter's
  /// `Slider`); the legacy `drag.track` reads as it.
  final Track? track;

  /// Swiped away past a threshold (Flutter's `Dismissible`); the legacy
  /// `drag` with `release: dismiss` reads as it.
  final DismissibleBehavior? dismissible;

  /// Follows the pointer and springs back or stays; the legacy `drag`
  /// that neither tracks, reorders nor dismisses reads as it.
  final Pan? pan;

  /// The handle a reorderable list's row is dragged by (Flutter's
  /// `ReorderableDragStartListener`); the legacy `drag.reorder` reads as it.
  final bool reorderHandle;
  final Reveal? reveal;
  final StrokePath? strokePath;

  /// A text that types itself out in a running app.
  final Typewriter? typewriter;
  final ParticleEmitter? particles;

  /// The direction its content lays out in (Flutter's `Directionality`);
  /// null inherits. Bindable as `textDirection`.
  final TextDirection? textDirection;

  /// A two-sided card that turns over (first child front, second back).
  final FlipCard? flip;

  /// Tilts in 3D toward the pointer.
  final Tilt? tilt;

  /// Pinch, pan and rotate, with fling physics and optional handles (the
  /// legacy `zoomable: true` reads as [TransformGesture.zoomable]).
  final TransformGesture? transformGesture;

  /// Pinned in its scrolling view while its parent is in view.
  final Sticky? sticky;

  /// `${view.progress}`: how far it has scrolled through the viewport.
  final ViewProgress? viewProgress;

  /// Its laid-out box, written to a variable.
  final Measure? measure;

  /// Flutter's `CustomPaint`: draw lists behind and over its content.
  final CustomPaint? customPaint;

  /// [transformGesture] (its former name, from when `zoomable` was its
  /// own key; the legacy `zoomable: true` now reads into [transformGesture]).
  TransformGesture? get effectiveTransformGesture => transformGesture;

  /// The node JSON keys these are stored under.
  static const Set<String> keys = {
    'motion', 'scale', 'animations', 'transitions', 'shimmer', 'inkWell', 'states', 'tooltip', 'ignorePointer', //
    'floating', 'hero', 'flightKey', 'flight', 'draggable', 'dropTarget', 'track', 'dismissible',
    'pan', 'reorderHandle', 'reveal', 'strokePath', 'typewriter',
    'particles', 'textDirection', 'flip', 'tilt', 'transformGesture', 'sticky', 'viewProgress', 'measure',
    'customPaint',
  };

  /// Legacy keys the decoder still reads (and never writes): `loops` and
  /// `effectAnimations` become [animations]; `drag` becomes [track],
  /// [dismissible], [pan] or [reorderHandle]; `zoomable: true` becomes
  /// [transformGesture] ([TransformGesture.zoomable]) when it has none.
  static const Set<String> legacyKeys = {'loops', 'effectAnimations', 'drag', 'zoomable'};

  bool get isNone => this == none;

  /// [bind] (a node's binding paths) with the legacy behavior paths
  /// rewritten to the animations they now address, read against the node's
  /// JSON [m]: `loops[i].<key>` → `animations.loop<i>.<key>` (a loop's
  /// `phase` and `lag` → one `phase` formula), `effectAnimations[i].<key>`
  /// → `animations.<its id>.<key>`, `motion.pulseKey` →
  /// `animations.pulse.playKey`. A key it can't rewrite is kept as given.
  static Map<String, String> migrateBind(Map<String, String> bind, Json m) {
    final motion = readMap(m['motion']);
    if (motion != null && (bind.keys.any((k) => k.startsWith('motion.')) || _legacyMotionKeys.any(motion.containsKey))) {
      bind = _migrateMotionBind(bind, m, motion);
    }
    bind = _migrateDragBind(bind, m);
    if (!bind.keys.any((k) => k.startsWith('loops') || k.startsWith('effectAnimations') || k == 'motion.pulseKey')) {
      return bind;
    }
    final loops = readList(m['loops']) ?? const [];
    final effects = readList(m['effectAnimations']) ?? const [];
    final out = <String, String>{};
    final phases = <int, (String?, String?)>{};
    final legacy = RegExp(r'^(loops|effectAnimations)(?:\[(\d+)\]|\.\*)\.(\w+)$');
    for (final e in bind.entries) {
      if (e.key == 'motion.pulseKey') {
        out['animations.pulse.playKey'] = e.value;
        continue;
      }
      final match = legacy.firstMatch(e.key);
      if (match == null) {
        out[e.key] = e.value;
        continue;
      }
      final isLoop = match[1] == 'loops';
      final list = isLoop ? loops : effects;
      final indices = match[2] == null ? [for (var i = 0; i < list.length; i++) i] : [int.parse(match[2]!)];
      final key = match[3]!;
      var kept = false;
      for (final i in indices) {
        if (i >= list.length) continue;
        if (isLoop) {
          if (key == 'phase' || key == 'lag') {
            final (p, l) = phases[i] ?? (null, null);
            phases[i] = key == 'phase' ? (e.value, l) : (p, e.value);
            continue;
          }
          final to = _loopKey(key);
          if (to == null) {
            kept = true;
            continue;
          }
          out['animations.loop$i.$to'] = e.value;
        } else {
          final a = AnimationPresets.fromEffect(list[i], i);
          final to = a == null ? null : _effectKey(key, a.preset == 'spin');
          if (a == null || to == null) {
            kept = true;
            continue;
          }
          out['animations.${a.id}.$to'] = e.value;
        }
      }
      if (kept) out[e.key] = e.value;
    }
    for (final MapEntry(key: i, value: (p, l)) in phases.entries) {
      final r = _R(readMap(loops[i]) ?? const {});
      final cycle = (r.b('reverse', false) ? 2 : 1) * math.max(1, r.ms('duration', 1000));
      final phase = p == null ? writeDouble(r.d('phase', 0)).toString() : _formula(p);
      final lag = l == null ? writeDouble(r.d('lag', 0)).toString() : _formula(l);
      if (phase == null || lag == null) {
        // Not a formula it can combine: kept as given (no longer read).
        if (p != null) out['loops[$i].phase'] = p;
        if (l != null) out['loops[$i].lag'] = l;
        continue;
      }
      out['animations.loop$i.phase'] = lag == '0' || lag == '0.0' ? '\${= $phase}' : '\${= ($phase) - ($lag) / $cycle}';
    }
    return out;
  }

  /// The temporal keys of a legacy motion.
  static const _legacyMotionKeys = [
    'duration', 'delay', 'curve', 'loop', 'spin', 'enter', 'enterFrom', 'keyframes', 'revealOnScroll', 'shimmer', //
  ];

  /// [bind]'s legacy `motion.*` paths (read against node JSON [m] and its
  /// [motion]) as what they set now, plus what its legacy motion adds
  /// ([AnimationPresets.fromMotion]): the pose's own paths stay (the flat
  /// path keys become `motion.path.*`); the timing, entrance, loop and spin
  /// keys address the animations and transitions they became; `opacity`
  /// and `blur` the node's (see [Node.fromJson]). A legacy key with no
  /// counterpart left (`rotateCurve`, `fadeShare`, `arc`, `spring`,
  /// `revealOnScroll`, `revealFraction`, a loop or entrance key on a motion
  /// that has none) is dropped.
  static Map<String, String> _migrateMotionBind(Map<String, String> bind, Json m, Json motion) {
    final legacy = _legacyMotion(m)!;
    final ids = {for (final a in legacy.animations) a.id};
    final played = [for (final id in const ['enter', 'loop']) if (ids.contains(id)) id];
    final transitions = _transitions(m, legacy.transitions);
    final legacyTransitions = {for (final t in legacy.transitions) t.property};
    final timed = [
      for (final (i, t) in transitions.indexed)
        if (legacyTransitions.contains(t.property)) (i, t),
    ];
    final share = (readDouble(motion['fadeShare']) ?? 1).clamp(0.01, 1.0);
    final reverse = AnimationPresets.legacyLoopMode(motion['loop'], bind['motion.loop']) == 'reverse';
    final out = <String, String>{};
    for (final e in bind.entries) {
      final key = e.key, value = e.value;
      if (!key.startsWith('motion.')) {
        out[key] = value;
        continue;
      }
      final rest = key.substring(7);
      switch (rest) {
        case 'pathProgress':
          out['motion.path.progress'] = value;
        case 'path':
          out['motion.path.path'] = value;
        case 'pathViewBox':
          out['motion.path.viewBox'] = value;
        case 'blur':
          out[AnimationPresets.legacyMotionPath('blur')] = value;
        case 'opacity':
          // The node's opacity, multiplied by its own (Node.fromJson).
          out['motion.opacity'] = value;
        case 'replayKey' when ids.contains('enter'):
          out['animations.enter.playKey'] = value;
        case 'enterHeld' when ids.contains('enter'):
          out['animations.enter.paused'] = value;
        case 'enter' when ids.contains('enter') && !(legacy.animations.firstWhere((a) => a.id == 'enter').enabled):
          out['animations.enter.enabled'] = value;
        case 'keyframes':
          for (final id in played) {
            out['animations.$id.params.frames'] = value;
          }
        case 'duration' || 'delay' || 'curve':
          for (final id in played) {
            if (rest == 'curve' && legacy.animations.any((a) => a.id == id && a.curve == AnimationCurve.linear)) {
              out['animations.$id.params.curve'] = value;
            } else {
              out['animations.$id.$rest'] = value;
            }
          }
          for (final (i, t) in timed) {
            if (rest == 'curve' && t.property != 'motion' && t.curve != AnimationCurve.parse(motion['curve'])) continue;
            final f = _formula(value);
            out['transitions[$i].$rest'] = rest == 'duration' && t.property == 'opacity' && share < 1 && f != null
                ? '\${= ($f) * ${writeDouble(share)}}'
                : value;
          }
        case 'paused':
          for (final id in const ['loop', 'spin']) {
            if (ids.contains(id)) out['animations.$id.paused'] = value;
          }
        case 'phase' when ids.contains('loop'):
          final f = _formula(value);
          if (reverse && f != null) {
            out['animations.loop.phase'] = '\${= ($f) / 2}';
          } else if (!reverse) {
            out['animations.loop.phase'] = value;
          }
        case 'repeat' when ids.contains('loop'):
          out['animations.loop.repeat.count'] = value;
        case 'loop' when ids.contains('loop'):
          final mode = AnimationPresets.legacyLoopMode(motion['loop'], value);
          final f = _formula(value);
          if (mode != null && f != null) out['animations.loop.enabled'] = "\${= ($f) == '$mode'}";
        case 'spin' when ids.contains('spin'):
          out['animations.spin.params.perSecond'] = value;
        case 'spinRamp' when ids.contains('spin'):
          out['animations.spin.ramp'] = value;
        case 'shimmer.duration' when ids.contains('shimmer'):
          out['animations.shimmer.duration'] = value;
        case _ when rest.startsWith('shimmer.'):
          out[rest] = value;
        case _ when rest.startsWith('enterFrom.') && ids.contains('enter'):
          out['animations.enter.params.from.${rest.substring(10)}'] = value;
        case 'replayKey' || 'enterHeld' || 'enter' || 'phase' || 'repeat' || 'loop' || 'spin' || 'spinRamp' || 'rotateCurve' ||
              'fadeShare' || 'arc' || 'spring' || 'springStiffness' || 'springDamping' || 'revealOnScroll' ||
              'revealFraction' || 'pathWrap' || 'shimmer':
          break;
        case _ when rest.startsWith('enterFrom') || rest.startsWith('spring') || rest.startsWith('keyframes'):
          break;
        default:
          out[key] = value;
      }
    }
    for (final e in legacy.bind.entries) {
      out.putIfAbsent(e.key, () => e.value);
    }
    return out;
  }

  /// A loop's key as the key of its animation; null when it has none.
  static String? _loopKey(String key) => switch (key) {
        'enabled' || 'duration' || 'delay' || 'curve' => key,
        'type' => 'preset',
        'reverse' => 'repeat.reverse',
        'scaleFrom' || 'scaleTo' || 'opacityFrom' || 'opacityTo' || 'turns' || 'distance' || 'angle' => 'params.$key',
        _ => null,
      };

  /// An effect's key as the key of its animation; null when it has none.
  static String? _effectKey(String key, bool spin) => switch (key) {
        'duration' || 'delay' || 'playKey' || 'curve' => key,
        'type' => 'preset',
        'playOnAppear' => 'autoplay',
        'amount' => spin ? 'params.turns' : 'params.amount',
        'cycles' => 'params.cycles',
        'keyframes' => 'params.frames',
        _ => null,
      };

  /// The formula of binding [expression]: `${= f}` → `f`, `${path}` →
  /// `path`, a number → itself; null for anything else (text around it).
  static String? formulaOf(String expression) => _formula(expression);

  static String? _formula(String expression) {
    final t = expression.trim();
    if (num.tryParse(t) != null) return t;
    final f = RegExp(r'^\$\{=\s*([^]*)\}$').firstMatch(t);
    if (f != null && !f[1]!.contains(r'${')) return f[1]!.trim();
    final p = RegExp(r'^\$\{([^{}=]+)\}$').firstMatch(t);
    return p?[1]!.trim();
  }

  /// The legacy keys of [m] as animations, after [m]'s own `animations`; a
  /// legacy one replaces an animation of the same id.
  static List<NodeAnimation> _animations(Json m, List<NodeAnimation> fromMotion) {
    final own = [...?readList(_jsonText(m['animations']))?.map(NodeAnimation.fromJson).nonNulls];
    final legacy = <NodeAnimation>[
      for (final (i, l) in (readList(m['loops']) ?? const []).indexed) ?AnimationPresets.fromLoop(l, i),
      for (final (i, e) in (readList(m['effectAnimations']) ?? const []).indexed) ?AnimationPresets.fromEffect(e, i),
      if (readMap(m['motion']) case final Json motion)
        ?AnimationPresets.fromPulseKey(motion, bound: readMap(m['bind'])?.containsKey('motion.pulseKey') ?? false),
      ...fromMotion,
    ];
    if (legacy.isEmpty) return own;
    final ids = {for (final a in legacy) a.id};
    return [...own.where((a) => !ids.contains(a.id)), ...legacy];
  }

  /// [m]'s own `transitions`, then those its legacy motion timing gives (a
  /// legacy one replaces one for the same property).
  static List<Transition> _transitions(Json m, List<Transition> fromMotion) {
    final own = Transition.listFromJson(m['transitions']);
    if (fromMotion.isEmpty) return own;
    final props = {for (final t in fromMotion) t.property};
    return [...own.where((t) => !props.contains(t.property)), ...fromMotion];
  }

  /// The legacy temporal keys of [m]'s motion, read
  /// ([AnimationPresets.fromMotion]); null without a motion.
  static ({List<NodeAnimation> animations, List<Transition> transitions, Shimmer? shimmer, Map<String, String> bind})?
      _legacyMotion(Json m) {
    final motion = readMap(m['motion']);
    if (motion == null) return null;
    final bind = {
      for (final e in (readMap(m['bind']) ?? const <String, Object?>{}).entries)
        if (e.value is String) e.key: e.value as String,
    };
    bool patches(String key) =>
        (readMap(m['states'])?.values ?? const []).any((state) => (readMap(state)?.values ?? const []).any((patch) => readMap(readMap(patch)?['motion'])?.containsKey(key) ?? false));
    return AnimationPresets.fromMotion(motion, bind: bind, patchesOpacity: patches('opacity'), patchesBlur: patches('blur'));
  }

  /// Reads the behavior keys of a node's JSON [m].
  static Behaviors fromJson(Json m) {
    if (!m.keys.any((k) => keys.contains(k) || legacyKeys.contains(k))) return none;
    final r = _R(m);
    final scale = r.d('scale', 1);
    final legacy = _legacyMotion(m);
    return Behaviors(
      motion: Motion.fromJson(m['motion']),
      scale: scale > 0 ? scale : 1,
      animations: _animations(m, legacy?.animations ?? const []),
      transitions: _transitions(m, legacy?.transitions ?? const []),
      shimmer: Shimmer.fromJson(m['shimmer']) ?? legacy?.shimmer,
      inkWell: InkWellStyle.fromJson(m['inkWell']),
      states: StateStyles.fromJson(m['states']),
      tooltip: r.s('tooltip'),
      ignorePointer: r.b('ignorePointer', false),
      floating: r.b('floating', false),
      hero: HeroTag.fromJson(m['hero']),
      flightKey: r.s('flightKey'),
      flight: Flight.fromJson(m['flight']),
      draggable: DragSource.fromJson(m['draggable']),
      dropTarget: DropTarget.fromJson(m['dropTarget']),
      track: Track.fromJson(m['track']) ?? Track.fromLegacyDrag(readMap(m['drag'])),
      dismissible: DismissibleBehavior.fromJson(m['dismissible']) ?? DismissibleBehavior.fromLegacyDrag(readMap(m['drag'])),
      pan: Pan.fromJson(m['pan']) ?? Pan.fromLegacyDrag(readMap(m['drag'])),
      reorderHandle: r.b('reorderHandle', false) || _isLegacyReorderHandle(readMap(m['drag'])),
      reveal: Reveal.fromJson(m['reveal']),
      strokePath: StrokePath.fromJson(m['strokePath']),
      typewriter: Typewriter.fromJson(m['typewriter']),
      particles: ParticleEmitter.fromJson(m['particles']),
      textDirection: m['textDirection'] is String
          ? r.e(TextDirection.values, 'textDirection', TextDirection.ltr)
          : null,
      flip: FlipCard.fromJson(m['flip']),
      tilt: Tilt.fromJson(m['tilt']),
      transformGesture: TransformGesture.fromJson(m['transformGesture']) ??
          (r.b('zoomable', false) ? TransformGesture.zoomable : null),
      sticky: Sticky.fromJson(m['sticky']),
      viewProgress: ViewProgress.fromJson(m['viewProgress']),
      measure: Measure.fromJson(m['measure']),
      customPaint: CustomPaint.fromJson(m['customPaint']),
    );
  }

  /// Writes these into a node's JSON [j] (sparse).
  void writeTo(Json j) {
    if (motion != null) j['motion'] = motion!.toJson();
    j.d('scale', scale, 1);
    if (animations.isNotEmpty) j['animations'] = [for (final a in animations) a.toJson()];
    if (transitions.isNotEmpty) j['transitions'] = [for (final t in transitions) t.toJson()];
    if (shimmer != null) j['shimmer'] = shimmer!.toJson();
    if (inkWell != null) j['inkWell'] = inkWell!.toJson();
    if (!states.isEmpty) j['states'] = states.toJson();
    j
      ..s('tooltip', tooltip)
      ..b('ignorePointer', ignorePointer, false)
      ..b('floating', floating, false);
    if (hero != null) j['hero'] = hero!.toJson();
    j.s('flightKey', flightKey);
    if (flight != null) j['flight'] = flight!.toJson();
    if (draggable != null) j['draggable'] = draggable!.toJson();
    if (dropTarget != null) j['dropTarget'] = dropTarget!.toJson();
    if (track != null) j['track'] = track!.toJson();
    if (dismissible != null) j['dismissible'] = dismissible!.toJson();
    if (pan != null) j['pan'] = pan!.toJson();
    j.b('reorderHandle', reorderHandle, false);
    if (reveal != null) j['reveal'] = reveal!.toJson();
    if (strokePath != null) j['strokePath'] = strokePath!.toJson();
    if (typewriter != null) j['typewriter'] = typewriter!.toJson();
    if (particles != null) j['particles'] = particles!.toJson();
    if (textDirection != null) j['textDirection'] = textDirection!.name;
    if (flip != null) j['flip'] = flip!.toJson();
    if (tilt != null) j['tilt'] = tilt!.toJson();
    if (transformGesture != null) j['transformGesture'] = transformGesture!.toJson();
    if (sticky != null) j['sticky'] = sticky!.toJson();
    if (viewProgress != null) j['viewProgress'] = viewProgress!.toJson();
    if (measure != null) j['measure'] = measure!.toJson();
    if (customPaint != null) j['customPaint'] = customPaint!.toJson();
  }

  Behaviors copyWith({
    Motion? motion,
    double? scale,
    List<NodeAnimation>? animations,
    List<Transition>? transitions,
    Shimmer? shimmer,
    InkWellStyle? inkWell,
    StateStyles? states,
    String? tooltip,
    bool? ignorePointer,
    bool? floating,
    HeroTag? hero,
    String? flightKey,
    Flight? flight,
    DragSource? draggable,
    DropTarget? dropTarget,
    Track? track,
    DismissibleBehavior? dismissible,
    Pan? pan,
    bool? reorderHandle,
    Reveal? reveal,
    StrokePath? strokePath,
    Typewriter? typewriter,
    ParticleEmitter? particles,
    TextDirection? textDirection,
    FlipCard? flip,
    Tilt? tilt,
    TransformGesture? transformGesture,
    Sticky? sticky,
    ViewProgress? viewProgress,
    Measure? measure,
    CustomPaint? customPaint,
  }) => Behaviors(
    motion: motion ?? this.motion,
    scale: scale ?? this.scale,
    animations: animations ?? this.animations,
    transitions: transitions ?? this.transitions,
    shimmer: shimmer ?? this.shimmer,
    inkWell: inkWell ?? this.inkWell,
    states: states ?? this.states,
    tooltip: tooltip ?? this.tooltip,
    ignorePointer: ignorePointer ?? this.ignorePointer,
    floating: floating ?? this.floating,
    hero: hero ?? this.hero,
    flightKey: flightKey ?? this.flightKey,
    flight: flight ?? this.flight,
    draggable: draggable ?? this.draggable,
    dropTarget: dropTarget ?? this.dropTarget,
    track: track ?? this.track,
    dismissible: dismissible ?? this.dismissible,
    pan: pan ?? this.pan,
    reorderHandle: reorderHandle ?? this.reorderHandle,
    reveal: reveal ?? this.reveal,
    strokePath: strokePath ?? this.strokePath,
    typewriter: typewriter ?? this.typewriter,
    particles: particles ?? this.particles,
    textDirection: textDirection ?? this.textDirection,
    flip: flip ?? this.flip,
    tilt: tilt ?? this.tilt,
    transformGesture: transformGesture ?? this.transformGesture,
    sticky: sticky ?? this.sticky,
    viewProgress: viewProgress ?? this.viewProgress,
    measure: measure ?? this.measure,
    customPaint: customPaint ?? this.customPaint,
  );

  @override
  List<Object?> get props => [
    motion, scale, animations, transitions, shimmer, inkWell, states, tooltip, ignorePointer, floating, hero, //
    flightKey, flight, draggable, dropTarget, track, dismissible, pan, reorderHandle, reveal, strokePath, typewriter,
    particles, textDirection, flip, tilt, transformGesture, sticky, viewProgress, measure, customPaint,
  ];

  /// Whether a legacy `drag` object [d] made its node a reorder handle
  /// (`reorder: true` without a track).
  static bool _isLegacyReorderHandle(Json? d) =>
      d != null && readMap(d['track']) == null && (readBool(d['reorder']) ?? false);

  /// [bind] with the legacy `drag.*` paths rewritten to the behavior the
  /// node's `drag` became: `drag.track.<k>` → `track.<k>`, and for a drag
  /// that follows the pointer `drag.<k>` → `dismissible.<k>` or `pan.<k>`
  /// under their new names (`drag.restX` → `pan.x`, `drag.flyOut` →
  /// `dismissible.movementDuration`...; `drag.distanceThreshold` binds each
  /// direction's `dismissible.dismissThresholds`). `drag.enabled` →
  /// `<behavior>.enabled`. A path it can't rewrite is kept as given.
  static Map<String, String> _migrateDragBind(Map<String, String> bind, Json m) {
    // A track that only shows its variable (`write: false`) binds its value.
    final legacyTrack = readMap(m['track']) ?? readMap(readMap(m['drag'])?['track']);
    if (legacyTrack != null && Track.readsOnly(legacyTrack) && !bind.containsKey('track.value') &&
        !bind.containsKey('drag.track.value')) {
      bind = {...bind, 'track.value': '\${${readString(legacyTrack['variable'])!.trim()}}'};
    }
    if (!bind.keys.any((k) => k.startsWith('drag.'))) return bind;
    final d = readMap(m['drag']) ?? const <String, Object?>{};
    final isTrack = readMap(d['track']) != null || bind.keys.any((k) => k.startsWith('drag.track.'));
    final isHandle = !isTrack && (readBool(d['reorder']) ?? false);
    final isDismiss = !isTrack && !isHandle && d['release'] == DragRelease.dismiss.name;
    final hasVertical = d.containsKey('verticalThreshold') || bind.containsKey('drag.verticalThreshold');
    final out = <String, String>{};
    for (final e in bind.entries) {
      final k = e.key;
      if (!k.startsWith('drag.')) {
        out[k] = e.value;
        continue;
      }
      final rest = k.substring(5);
      final List<String> to;
      if (rest.startsWith('track.')) {
        final key = rest.substring(6);
        to = [key == 'path' ? 'track.path.path' : 'track.$key'];
      } else if (isTrack) {
        to = rest == 'enabled' ? ['track.enabled'] : const [];
      } else if (isHandle) {
        to = const [];
      } else if (isDismiss) {
        String t(DragDirection d) => 'dismissible.dismissThresholds.${d.name}';
        to = switch (rest) {
          'distanceThreshold' => [
              t(DragDirection.left),
              t(DragDirection.right),
              if (!hasVertical) ...[t(DragDirection.up), t(DragDirection.down)],
            ],
          'verticalThreshold' => [t(DragDirection.up), t(DragDirection.down)],
          'velocityThreshold' => ['dismissible.flingVelocity'],
          'flyOut' => ['dismissible.movementDuration'],
          'flyOutCurve' => ['dismissible.curve'],
          'snapBack' => ['dismissible.returnDuration'],
          'snapCurve' => ['dismissible.returnCurve'],
          'physics.spring' => ['dismissible.returnSpring'],
          'enabled' || 'directions' || 'axis' || 'resistance' || 'restX' || 'restY' || 'xVariable' || 'yVariable' ||
          'flyOutRotate' ||
          'rotateFactor' || 'originX' || 'originY' || 'shakeWhenDisabled' || 'disabledFollow' || 'shareAs' ||
          'follow' =>
            ['dismissible.$rest'],
          _ => const [],
        };
      } else {
        final head = rest.split('.').first;
        to = switch (head) {
          'restX' => ['pan.x'],
          'restY' => ['pan.y'],
          'snapBack' => ['pan.returnDuration'],
          'snapCurve' => ['pan.returnCurve'],
          'enabled' || 'axis' || 'release' || 'xVariable' || 'yVariable' || 'physics' || 'bounds' || 'minX' ||
          'maxX' || 'minY' || 'maxY' || 'rotateFactor' || 'originX' || 'originY' || 'shakeWhenDisabled' ||
          'disabledFollow' || 'shareAs' || 'follow' =>
            ['pan.$rest'],
          _ => const [],
        };
      }
      if (to.isEmpty) {
        out[k] = e.value;
      } else {
        for (final t in to) {
          out[t] = e.value;
        }
      }
    }
    return out;
  }
}
