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
import 'values/color.dart';
import 'values/enums.dart';
import 'values/geometry.dart';
import 'values/text.dart';

part 'animation.dart';
part 'animation_presets.dart';
part 'gestures.dart';
part 'path_follow.dart';

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

/// What the node shows where it was picked up while dragged.
enum DragSourceStyle { ghost, hidden, keep }

/// Which point of the copy that follows the pointer sits under it: where
/// it was grabbed, or its center (a feedback node of another size).
enum FeedbackAnchor { grab, center }

/// Lets the user pick the node up and drop it on a [DropTarget] that takes
/// its [group] (Flutter's `Draggable`).
@immutable
final class DragSource extends _Value {
  const DragSource({
    this.group = '',
    this.data = '',
    this.start = DragStart.auto,
    this.axis = DragAxis.free,
    this.whileDragging = DragSourceStyle.ghost,
    this.ghostOpacity = 0.35,
    this.feedbackRotation = -2,
    this.feedbackScale = 1,
    this.feedbackOpacity = 1,
    this.feedbackElevation = 24,
    this.feedbackNodeId = '',
    this.feedbackAnchor = FeedbackAnchor.grab,
    this.returnSpring = true,
    this.spring = DragSource.defaultSpring,
    this.enabled = true,
    this.physics,
  });

  final String group, data;
  final DragStart start;
  final DragAxis axis;
  final DragSourceStyle whileDragging;
  final double ghostOpacity, feedbackRotation, feedbackScale, feedbackOpacity, feedbackElevation;

  /// The node drawn under the pointer instead of this one.
  final String feedbackNodeId;
  final FeedbackAnchor feedbackAnchor;
  final bool returnSpring;

  /// The spring it returns on with [returnSpring] (JSON `spring`; the
  /// legacy `springStiffness`/`springDamping` read as it).
  final Spring spring;
  static const Spring defaultSpring = Spring.physical(stiffness: 260, damping: 14);
  final bool enabled;

  /// The return spring of a drag no target takes; null uses
  /// [returnSpring] and [spring].
  final GesturePhysics? physics;

  /// The spring it flies back on, or null for none (it reappears at once).
  GesturePhysics? get effectivePhysics =>
      physics ??
      (returnSpring ? GesturePhysics(spring: spring, fling: false) : null);

  static DragSource? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return DragSource(
      group: r.s('group'),
      data: r.s('data'),
      start: r.e(DragStart.values, 'start', DragStart.auto),
      axis: r.e(DragAxis.values, 'axis', DragAxis.free),
      whileDragging: r.e(DragSourceStyle.values, 'whileDragging', DragSourceStyle.ghost),
      ghostOpacity: r.d('ghostOpacity', 0.35),
      feedbackRotation: r.d('feedbackRotation', -2),
      feedbackScale: r.d('feedbackScale', 1),
      feedbackOpacity: r.d('feedbackOpacity', 1),
      feedbackElevation: r.d('feedbackElevation', 24),
      feedbackNodeId: r.s('feedbackNodeId'),
      feedbackAnchor: r.e(FeedbackAnchor.values, 'feedbackAnchor', FeedbackAnchor.grab),
      returnSpring: r.b('returnSpring', true),
      spring: Spring.fromJson(m['spring'], fallback: defaultSpring) ??
          Spring.legacy(m, 'springStiffness', 'springDamping', fallback: defaultSpring) ??
          defaultSpring,
      enabled: _loose(m['enabled']) ?? true,
      physics: GesturePhysics.fromJson(m['physics']),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..s('group', group)
      ..s('data', data)
      ..e('start', start, DragStart.auto)
      ..e('axis', axis, DragAxis.free)
      ..e('whileDragging', whileDragging, DragSourceStyle.ghost)
      ..d('ghostOpacity', ghostOpacity, 0.35)
      ..d('feedbackRotation', feedbackRotation, -2)
      ..d('feedbackScale', feedbackScale, 1)
      ..d('feedbackOpacity', feedbackOpacity, 1)
      ..d('feedbackElevation', feedbackElevation, 24)
      ..s('feedbackNodeId', feedbackNodeId)
      ..e('feedbackAnchor', feedbackAnchor, FeedbackAnchor.grab)
      ..b('returnSpring', returnSpring, true);
    if (spring != defaultSpring) j['spring'] = spring.toJsonOver(defaultSpring);
    j.b('enabled', enabled, true);
    if (physics != null) j['physics'] = physics!.toJson();
    return j;
  }

  @override
  List<Object?> get props => [
    group, data, start, axis, whileDragging, ghostOpacity, feedbackRotation, feedbackScale, feedbackOpacity, //
    feedbackElevation, feedbackNodeId, feedbackAnchor, returnSpring, spring, enabled, physics,
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

/// What a dragged node does when let go.
enum DragRelease { snapBack, stay, dismiss }

enum DragDirection { left, right, up, down }

/// The shape of a [DragTrack].
enum DragTrackShape { line, arc, path }

/// How the pointer moves along a [DragTrack]: following it, or dragging
/// up/down, left/right, or either (up or right raises it: dx − dy).
enum DragTrackInput { follow, vertical, horizontal, both }

/// Where a [DragTrack]'s node takes the pointer: on itself, or anywhere in
/// its parent (a knob turned from anywhere in its box).
enum DragTrackHitArea { self, parent }

/// What a [DragTrack]'s geometry is measured in: pixels, or fractions of
/// the parent's size (x values of its width, y of its height).
enum DragTrackUnits { pixels, parent }

/// Makes a dragged node a value control (a knob, a fader): it moves along
/// the track as variable [variable] goes from [min] to [max], and the
/// design canvas draws it at the variable's value. Dragging it writes the
/// variable (unless [write] is off); a double tap goes to [defaultValue]
/// (or through [doubleTapValues]), the wheel and arrow keys step it. Inside
/// it `${track.value}`, `${track.progress}`, `${track.dragging}`,
/// `${track.fine}` and `${track.focused}` can be read.
///
/// Its settings and geometry are bindable as `drag.track.<field>`
/// (`drag.track.x2`: `${= parent.width - 26}`); `drag.track.value` gives
/// the value the node is drawn at in place of reading [variable].
@immutable
final class DragTrack extends _Value {
  const DragTrack({
    this.shape = DragTrackShape.line,
    this.variable = '',
    this.min = 0,
    this.max = 1,
    this.step = 0,
    this.defaultValue,
    this.input = DragTrackInput.follow,
    this.pixelsPerRange = 200,
    this.x1 = 0,
    this.y1 = 0,
    this.x2 = 0,
    this.y2 = -100,
    this.startAngle = -135,
    this.endAngle = 135,
    this.pivotX = 0,
    this.pivotY = 0,
    this.rotate = true,
    this.path,
    this.orientToPath = false,
    this.jumpOnTap = false,
    this.wheel = true,
    this.value,
    this.orientUpright = false,
    this.detent = 0,
    this.overscroll = 0,
    this.settle = 0,
    this.settleCurve = AnimationCurve.easeOutCubic,
    this.settleSpring = DragTrack.defaultSettleSpring,
    this.parkedProgress,
    this.keyboard = true,
    this.viewBoxWidth = 0,
    this.viewBoxHeight = 0,
    this.relative = false,
    this.wheelStep,
    this.doubleTapValues = const [],
    this.keyStep,
    this.hitArea = DragTrackHitArea.self,
    this.units = DragTrackUnits.pixels,
    this.fineStep = 0,
    this.finePixelsPerRange = 0,
    this.fineHold = 380,
    this.fineVariable = '',
    this.snap = 0,
    this.snapCurve = AnimationCurve.easeOutBack,
    this.write = true,
    this.endless = false,
    this.momentum = false,
    this.friction = 2.6,
    this.smooth = false,
    this.gain = 1,
  });

  final DragTrackShape shape;

  /// The variable it reads and writes; empty when `drag.track.value` is
  /// bound and its reactions write the value.
  final String variable;
  final double min, max, step;

  /// What a double tap resets to (bindable as `drag.track.defaultValue`).
  final double? defaultValue;
  final DragTrackInput input;
  final double pixelsPerRange;

  /// A line's ends, from the node's place (pixels, or with [relative]
  /// multiples of the node's size, with [units] parent of the parent's).
  final double x1, y1, x2, y2;

  /// An arc's angles (degrees, clockwise, 0 up) about the pivot (from the
  /// node's center).
  final double startAngle, endAngle, pivotX, pivotY;

  /// Turns the node with the arc.
  final bool rotate;
  final String? path;
  final bool orientToPath;

  /// Pressing anywhere along the track (or the [hitArea]) moves the node
  /// there, then the drag goes on (only for [DragTrackInput.follow]).
  final bool jumpOnTap;

  /// Whether the mouse wheel steps the value.
  final bool wheel;

  /// The value the node is drawn at, from a binding (`drag.track.value`);
  /// null reads [variable].
  final double? value;

  /// With [orientToPath], never upside down (as [Motion.orientUpright]).
  final bool orientUpright;

  /// How magnetic [step]s are while dragging (0–1): 0 jumps from step to
  /// step; above 0 the node follows that share of the way past a step.
  final double detent;

  /// How far it can be dragged past an end, a share of the pointer's
  /// travel there (0–1); it springs back on release.
  final double overscroll;

  /// The glide to its value's place when not following the pointer (ms; 0
  /// jumps), its curve, and the spring of [AnimationCurve.spring] (mass 1),
  /// which a release mid-fling starts at the pointer's speed.
  final int settle;
  final AnimationCurve settleCurve;
  /// The spring of a `spring` [settleCurve] (JSON `settleSpring`; the
  /// legacy `settleStiffness`/`settleDamping` read as it).
  final Spring settleSpring;
  static const Spring defaultSettleSpring = Spring.physical(stiffness: 380, damping: 20);

  /// Where the node parks while the value is out of range or empty, as a
  /// progress that may lie outside 0–1 (an unrated dial parks below its
  /// first mark); null draws such a value at the nearest end.
  final double? parkedProgress;

  /// Takes keyboard focus: arrows step by [keyStep] (else [step], else 1%
  /// of the range), Page Up/Down by 10 steps, Home and End to the ends.
  final bool keyboard;

  /// With both above 0, [path] is drawn in the box of the frame the node
  /// sits in, in these units, stretched to the frame's size.
  final double viewBoxWidth, viewBoxHeight;

  /// A line's ends are multiples of the node's own size (a full-width scrub
  /// area: `x1: -0.5, x2: 0.5`).
  final bool relative;

  /// One wheel notch, one arrow key (null: [step], else 1% of the range).
  final double? wheelStep, keyStep;

  /// Values a double tap moves between, in order (empty: [defaultValue]).
  final List<double> doubleTapValues;
  final DragTrackHitArea hitArea;
  final DragTrackUnits units;

  /// A finer step while Shift is held or after the pointer is held still
  /// [fineHold] ms (0: hold doesn't), [finePixelsPerRange] pixels for the
  /// range (0: 4 × [pixelsPerRange]); 0 has no fine mode. [fineVariable], a
  /// boolean variable, is kept true while fine.
  final double fineStep, finePixelsPerRange;
  final int fineHold;
  final String fineVariable;

  /// Animates the node to each new value over [snap] ms along [snapCurve]
  /// (a knob clicking from detent to detent); 0 jumps.
  final int snap;
  final AnimationCurve snapCurve;

  /// Whether dragging writes [variable]; off, it only shows it and its
  /// reactions set what changes from `${result.value}`.
  final bool write;

  /// An arc that keeps turning past its ends, the value unbounded (a
  /// combination dial).
  final bool endless;

  /// Let go while moving, it coasts, slowing by [friction] per second, then
  /// settles on a [step].
  final bool momentum;
  final double friction;

  /// Draws the node between [step]s while dragged or coasting, springing
  /// onto the nearest when it rests (the variable only holds steps).
  final bool smooth;

  /// How far the node moves per pointer movement (0.5 fine, 2 coarse).
  final double gain;

  /// Whether the value is unbounded ([endless] on an arc).
  bool get unbounded => endless && shape == DragTrackShape.arc;

  bool get hasVariable => variable.trim().isNotEmpty;
  bool get hasFine => fineStep > 0;
  bool get usesViewBox => viewBoxWidth > 0 && viewBoxHeight > 0;
  double get effectiveFinePixelsPerRange => finePixelsPerRange > 0 ? finePixelsPerRange : pixelsPerRange * 4;

  /// Where [value] is along the track (0–1; past them on an endless arc).
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

  /// [progress] held to the track (any progress on an endless arc).
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

  double get effectiveWheelStep => (wheelStep ?? 0) > 0 ? wheelStep! : (step > 0 ? step : (max - min).abs() / 100);

  /// Null with [keyboard] off.
  double? get effectiveKeyStep =>
      !keyboard ? null : ((keyStep ?? 0) > 0 ? keyStep! : (step > 0 ? step : (max - min).abs() / 100));

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

  double angleAt(double progress) => startAngle + (endAngle - startAngle) * clampProgress(progress);

  static DragTrack? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return DragTrack(
      shape: r.e(DragTrackShape.values, 'shape', DragTrackShape.line),
      variable: r.s('variable'),
      min: r.d('min', 0),
      max: r.d('max', 1),
      step: math.max(0, r.d('step', 0)),
      defaultValue: r.dn('defaultValue'),
      input: r.e(DragTrackInput.values, 'input', DragTrackInput.follow),
      pixelsPerRange: r.d('pixelsPerRange', 200),
      x1: r.d('x1', 0),
      y1: r.d('y1', 0),
      x2: r.d('x2', 0),
      y2: r.d('y2', -100),
      startAngle: r.d('startAngle', -135),
      endAngle: r.d('endAngle', 135),
      pivotX: r.d('pivotX', 0),
      pivotY: r.d('pivotY', 0),
      rotate: r.b('rotate', true),
      path: r.sn('path'),
      orientToPath: r.b('orientToPath', false),
      jumpOnTap: r.b('jumpOnTap', false),
      wheel: r.b('wheel', true),
      value: r.dn('value'),
      orientUpright: r.b('orientUpright', false),
      detent: r.d('detent', 0),
      overscroll: r.d('overscroll', 0),
      settle: r.ms('settle', 0),
      settleCurve: r.curve('settleCurve', AnimationCurve.easeOutCubic),
      settleSpring: Spring.fromJson(m['settleSpring'], fallback: defaultSettleSpring) ??
          Spring.legacy(m, 'settleStiffness', 'settleDamping', fallback: defaultSettleSpring) ??
          defaultSettleSpring,
      parkedProgress: r.dn('parkedProgress'),
      keyboard: r.b('keyboard', true),
      viewBoxWidth: r.d('viewBoxWidth', 0),
      viewBoxHeight: r.d('viewBoxHeight', 0),
      relative: r.b('relative', false),
      wheelStep: r.dn('wheelStep'),
      doubleTapValues: r.doubles('doubleTapValues'),
      keyStep: r.dn('keyStep'),
      hitArea: r.e(DragTrackHitArea.values, 'hitArea', DragTrackHitArea.self),
      units: r.e(DragTrackUnits.values, 'units', DragTrackUnits.pixels),
      fineStep: r.d('fineStep', 0),
      finePixelsPerRange: r.d('finePixelsPerRange', 0),
      fineHold: r.ms('fineHold', 380),
      fineVariable: r.s('fineVariable'),
      snap: r.ms('snap', 0),
      snapCurve: r.curve('snapCurve', AnimationCurve.easeOutBack),
      write: r.b('write', true),
      endless: r.b('endless', false),
      momentum: _loose(m['momentum']) ?? false,
      friction: r.d('friction', 2.6),
      smooth: _loose(m['smooth']) ?? false,
      gain: r.d('gain', 1),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..s('variable', variable)
      ..e('shape', shape, DragTrackShape.line)
      ..d('min', min, 0)
      ..d('max', max, 1)
      ..d('step', step, 0)
      ..dn('defaultValue', defaultValue)
      ..e('input', input, DragTrackInput.follow)
      ..d('pixelsPerRange', pixelsPerRange, 200)
      ..d('x1', x1, 0)
      ..d('y1', y1, 0)
      ..d('x2', x2, 0)
      ..d('y2', y2, -100)
      ..d('startAngle', startAngle, -135)
      ..d('endAngle', endAngle, 135)
      ..d('pivotX', pivotX, 0)
      ..d('pivotY', pivotY, 0)
      ..b('rotate', rotate, true)
      ..s('path', path)
      ..b('orientToPath', orientToPath, false)
      ..b('jumpOnTap', jumpOnTap, false)
      ..b('wheel', wheel, true)
      ..dn('value', value)
      ..b('orientUpright', orientUpright, false)
      ..d('detent', detent, 0)
      ..d('overscroll', overscroll, 0)
      ..i('settle', settle, 0)
      ..e('settleCurve', settleCurve, AnimationCurve.easeOutCubic)
      ..let((j) {
        if (settleSpring != defaultSettleSpring) j['settleSpring'] = settleSpring.toJsonOver(defaultSettleSpring);
      })
      ..dn('parkedProgress', parkedProgress)
      ..b('keyboard', keyboard, true)
      ..d('viewBoxWidth', viewBoxWidth, 0)
      ..d('viewBoxHeight', viewBoxHeight, 0)
      ..b('relative', relative, false)
      ..dn('wheelStep', wheelStep);
    if (doubleTapValues.isNotEmpty) j['doubleTapValues'] = doubleTapValues.map(writeDouble).toList();
    return j
      ..dn('keyStep', keyStep)
      ..e('hitArea', hitArea, DragTrackHitArea.self)
      ..e('units', units, DragTrackUnits.pixels)
      ..d('fineStep', fineStep, 0)
      ..d('finePixelsPerRange', finePixelsPerRange, 0)
      ..i('fineHold', fineHold, 380)
      ..s('fineVariable', fineVariable)
      ..i('snap', snap, 0)
      ..e('snapCurve', snapCurve, AnimationCurve.easeOutBack)
      ..b('write', write, true)
      ..b('endless', endless, false)
      ..b('momentum', momentum, false)
      ..d('friction', friction, 2.6)
      ..b('smooth', smooth, false)
      ..d('gain', gain, 1);
  }

  @override
  List<Object?> get props => [
    shape, variable, min, max, step, defaultValue, input, pixelsPerRange, x1, y1, x2, y2, startAngle, endAngle, //
    pivotX, pivotY, rotate, path, orientToPath, jumpOnTap, wheel, value, orientUpright, detent, overscroll, settle,
    settleCurve, settleSpring, parkedProgress, keyboard, viewBoxWidth, viewBoxHeight, relative,
    wheelStep, doubleTapValues, keyStep, hitArea, units, fineStep, finePixelsPerRange, fineHold, fineVariable, snap,
    snapCurve, write, endless, momentum, friction, smooth, gain,
  ];
}

/// Makes the node follow the pointer: it tilts, and on release springs
/// back, stays, or flies off past a threshold (a swiped card); with a
/// [track] it's a value control.
@immutable
final class DragMotion extends _Value {
  const DragMotion({
    this.axis = DragAxis.free,
    this.release = DragRelease.snapBack,
    this.directions = DragDirection.values,
    this.distanceThreshold = 0.35,
    this.verticalThreshold,
    this.velocityThreshold = 800,
    this.rotateFactor = 0,
    this.originX = 0,
    this.originY = 0,
    this.resistance = 0,
    this.snapBack = 450,
    this.snapCurve = AnimationCurve.spring,
    this.flyOut = 320,
    this.flyOutCurve = AnimationCurve.easeIn,
    this.flyOutDistance,
    this.flyOutRotate = 0,
    this.enabled = true,
    this.shakeWhenDisabled = false,
    this.disabledFollow = 0,
    this.shareAs = '',
    this.restX = 0,
    this.restY = 0,
    this.track,
    this.reorder = false,
    this.follow = true,
    this.xVariable = '',
    this.yVariable = '',
    this.physics,
    this.bounds = GestureBounds.none,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
  });

  final DragAxis axis;
  final DragRelease release;

  /// The directions it flies off in.
  final List<DragDirection> directions;

  /// The fraction of its size (and the speed, px/s) past which it flies off.
  final double distanceThreshold;
  final double? verticalThreshold;
  final double velocityThreshold;
  final double rotateFactor, originX, originY, resistance;

  /// Spring-back and fly-off times (ms) and curves.
  final int snapBack;
  final AnimationCurve snapCurve;
  final int flyOut;
  final AnimationCurve flyOutCurve;
  final double? flyOutDistance;
  final double flyOutRotate;
  final bool enabled, shakeWhenDisabled;
  final double disabledFollow;

  /// A variable the live drag values are written to.
  final String shareAs;
  final double restX, restY;
  final DragTrack? track;
  final bool reorder, follow;
  final String xVariable, yVariable;

  /// How it moves on its own after release (a fling, a spring settle, snap
  /// points, overscroll). Null keeps the curve-timed [snapBack] release;
  /// see [effectivePhysics].
  final GesturePhysics? physics;

  /// What it's kept inside of while dragged and flung, narrowed by the
  /// offsets from rest [minX]...[maxY] (null: no limit). A bottom sheet
  /// opening 560px: `minY: -560, maxY: 0`.
  final GestureBounds bounds;
  final double? minX, maxX, minY, maxY;

  bool get hasBounds => bounds != GestureBounds.none || minX != null || maxX != null || minY != null || maxY != null;

  /// [physics], or what the release settings amount to: a spring snap back
  /// is a spring settling in [snapBack] with a little bounce. Null for a
  /// curve-timed release.
  GesturePhysics? get effectivePhysics =>
      physics ??
      (snapCurve == AnimationCurve.spring ? GesturePhysics(spring: Spring(duration: snapBack, bounce: 0.25), fling: false) : null);

  static DragMotion? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final dirs = readList(m['directions']);
    return DragMotion(
      axis: r.e(DragAxis.values, 'axis', DragAxis.free),
      release: r.e(DragRelease.values, 'release', DragRelease.snapBack),
      directions: dirs == null
          ? DragDirection.values
          : [
              for (final d in DragDirection.values)
                if (dirs.contains(d.name)) d,
            ],
      distanceThreshold: r.d('distanceThreshold', 0.35),
      verticalThreshold: r.dn('verticalThreshold'),
      velocityThreshold: r.d('velocityThreshold', 800),
      rotateFactor: r.d('rotateFactor', 0),
      originX: r.d('originX', 0),
      originY: r.d('originY', 0),
      resistance: r.d('resistance', 0),
      snapBack: r.ms('snapBack', 450),
      snapCurve: r.curve('snapCurve', AnimationCurve.spring),
      flyOut: r.ms('flyOut', 320),
      flyOutCurve: r.curve('flyOutCurve', AnimationCurve.easeIn),
      flyOutDistance: r.dn('flyOutDistance'),
      flyOutRotate: r.d('flyOutRotate', 0),
      enabled: _loose(m['enabled']) ?? true,
      shakeWhenDisabled: r.b('shakeWhenDisabled', false),
      disabledFollow: r.d('disabledFollow', 0),
      shareAs: r.s('shareAs'),
      restX: r.d('restX', 0),
      restY: r.d('restY', 0),
      track: DragTrack.fromJson(m['track']),
      reorder: r.b('reorder', false),
      follow: r.b('follow', true),
      xVariable: r.s('xVariable'),
      yVariable: r.s('yVariable'),
      physics: GesturePhysics.fromJson(m['physics']),
      bounds: r.e(GestureBounds.values, 'bounds', GestureBounds.none),
      minX: r.dn('minX'),
      maxX: r.dn('maxX'),
      minY: r.dn('minY'),
      maxY: r.dn('maxY'),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..e('axis', axis, DragAxis.free)
      ..e('release', release, DragRelease.snapBack);
    if (!jsonEquality.equals(directions, DragDirection.values)) j['directions'] = [for (final d in directions) d.name];
    j
      ..d('distanceThreshold', distanceThreshold, 0.35)
      ..dn('verticalThreshold', verticalThreshold)
      ..d('velocityThreshold', velocityThreshold, 800)
      ..d('rotateFactor', rotateFactor, 0)
      ..d('originX', originX, 0)
      ..d('originY', originY, 0)
      ..d('resistance', resistance, 0)
      ..i('snapBack', snapBack, 450)
      ..e('snapCurve', snapCurve, AnimationCurve.spring)
      ..i('flyOut', flyOut, 320)
      ..e('flyOutCurve', flyOutCurve, AnimationCurve.easeIn)
      ..dn('flyOutDistance', flyOutDistance)
      ..d('flyOutRotate', flyOutRotate, 0)
      ..b('enabled', enabled, true)
      ..b('shakeWhenDisabled', shakeWhenDisabled, false)
      ..d('disabledFollow', disabledFollow, 0)
      ..s('shareAs', shareAs)
      ..d('restX', restX, 0)
      ..d('restY', restY, 0);
    if (track != null) j['track'] = track!.toJson();
    j
      ..b('reorder', reorder, false)
      ..b('follow', follow, true)
      ..s('xVariable', xVariable)
      ..s('yVariable', yVariable);
    if (physics != null) j['physics'] = physics!.toJson();
    return j
      ..e('bounds', bounds, GestureBounds.none)
      ..dn('minX', minX)
      ..dn('maxX', maxX)
      ..dn('minY', minY)
      ..dn('maxY', maxY);
  }

  @override
  List<Object?> get props => [
    axis, release, directions, distanceThreshold, verticalThreshold, velocityThreshold, rotateFactor, originX, //
    originY, resistance, snapBack, snapCurve, flyOut, flyOutCurve, flyOutDistance, flyOutRotate, enabled,
    shakeWhenDisabled, disabledFollow, shareAs, restX, restY, track, reorder, follow, xVariable, yVariable, physics,
    bounds, minX, maxX, minY, maxY,
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
    this.zoomable = false,
    this.floating = false,
    this.hero,
    this.flightKey = '',
    this.flight,
    this.draggable,
    this.dropTarget,
    this.drag,
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

  /// Pinch, scroll and double-tap zoom and pan (Flutter's
  /// `InteractiveViewer`).
  final bool zoomable;

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
  final DragMotion? drag;
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

  /// Pinch, pan and rotate, with fling physics and optional handles (over
  /// [zoomable]: see [effectiveTransformGesture]).
  final TransformGesture? transformGesture;

  /// Pinned in its scrolling view while its parent is in view.
  final Sticky? sticky;

  /// `${view.progress}`: how far it has scrolled through the viewport.
  final ViewProgress? viewProgress;

  /// Its laid-out box, written to a variable.
  final Measure? measure;

  /// Flutter's `CustomPaint`: draw lists behind and over its content.
  final CustomPaint? customPaint;

  /// [transformGesture], or what [zoomable] amounts to.
  TransformGesture? get effectiveTransformGesture =>
      transformGesture ?? (zoomable ? TransformGesture.zoomable : null);

  /// The node JSON keys these are stored under.
  static const Set<String> keys = {
    'motion', 'scale', 'animations', 'transitions', 'shimmer', 'inkWell', 'states', 'tooltip', 'ignorePointer', //
    'zoomable', 'floating', 'hero', 'flightKey', 'flight', 'draggable', 'dropTarget', 'drag', 'reveal', 'strokePath', 'typewriter',
    'particles', 'textDirection', 'flip', 'tilt', 'transformGesture', 'sticky', 'viewProgress', 'measure',
    'customPaint',
  };

  /// Legacy keys the decoder still reads (and never writes): `loops` and
  /// `effectAnimations` become [animations].
  static const Set<String> legacyKeys = {'loops', 'effectAnimations'};

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
      zoomable: r.b('zoomable', false),
      floating: r.b('floating', false),
      hero: HeroTag.fromJson(m['hero']),
      flightKey: r.s('flightKey'),
      flight: Flight.fromJson(m['flight']),
      draggable: DragSource.fromJson(m['draggable']),
      dropTarget: DropTarget.fromJson(m['dropTarget']),
      drag: DragMotion.fromJson(m['drag']),
      reveal: Reveal.fromJson(m['reveal']),
      strokePath: StrokePath.fromJson(m['strokePath']),
      typewriter: Typewriter.fromJson(m['typewriter']),
      particles: ParticleEmitter.fromJson(m['particles']),
      textDirection: m['textDirection'] is String
          ? r.e(TextDirection.values, 'textDirection', TextDirection.ltr)
          : null,
      flip: FlipCard.fromJson(m['flip']),
      tilt: Tilt.fromJson(m['tilt']),
      transformGesture: TransformGesture.fromJson(m['transformGesture']),
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
      ..b('zoomable', zoomable, false)
      ..b('floating', floating, false);
    if (hero != null) j['hero'] = hero!.toJson();
    j.s('flightKey', flightKey);
    if (flight != null) j['flight'] = flight!.toJson();
    if (draggable != null) j['draggable'] = draggable!.toJson();
    if (dropTarget != null) j['dropTarget'] = dropTarget!.toJson();
    if (drag != null) j['drag'] = drag!.toJson();
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
    bool? zoomable,
    bool? floating,
    HeroTag? hero,
    String? flightKey,
    Flight? flight,
    DragSource? draggable,
    DropTarget? dropTarget,
    DragMotion? drag,
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
    zoomable: zoomable ?? this.zoomable,
    floating: floating ?? this.floating,
    hero: hero ?? this.hero,
    flightKey: flightKey ?? this.flightKey,
    flight: flight ?? this.flight,
    draggable: draggable ?? this.draggable,
    dropTarget: dropTarget ?? this.dropTarget,
    drag: drag ?? this.drag,
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
    motion, scale, animations, transitions, shimmer, inkWell, states, tooltip, ignorePointer, zoomable, floating, //
    hero, flightKey, flight, draggable, dropTarget, drag, reveal, strokePath, typewriter, particles,
    textDirection, flip, tilt, transformGesture, sticky, viewProgress, measure, customPaint,
  ];
}
