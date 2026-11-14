// Animation as data (docs/design/02-animation.md): Flutter's
// `AnimationController` + `Tween`/`TweenSequence`/`Interval`/`CurveTween`
// as [NodeAnimation]s with [AnimationTrack]s on any binding path, one
// [Spring] (`SpringDescription`) used everywhere a spring is, and the
// presets the short forms (`{"preset": "pulse"}`) expand to.
part of 'behaviors.dart';

// --- spring -------------------------------------------------------------------

/// Flutter's `SpringDescription`: either the physical triple
/// (`SpringDescription(mass:, stiffness:, damping:)`, when [stiffness] and
/// [damping] are both given) or `SpringDescription.withDurationAndBounce`
/// ([duration] ms, [bounce]). The one spring value of the model: transitions,
/// animations, gestures, a flip card's settle and a route's dismiss all take
/// it. JSON: `{"stiffness": 380, "damping": 36}` or `{"duration": 500,
/// "bounce": 0.3}` (sparse; `{}` is `withDurationAndBounce()`'s defaults).
@immutable
final class Spring extends _Value {
  const Spring({this.stiffness, this.damping, this.mass = 1, this.duration = 500, this.bounce = 0});

  /// `SpringDescription(mass:, stiffness:, damping:)`.
  const Spring.physical({required double this.stiffness, required double this.damping, this.mass = 1})
      : duration = 500,
        bounce = 0;

  /// The physical spring's constants; both null: [duration] and [bounce].
  final double? stiffness, damping;
  final double mass;

  /// `withDurationAndBounce(duration:, bounce:)`: the perceptual settle
  /// time (ms) and the bounce (0 none, up to 1 wobbly; negative sluggish).
  final int duration;
  final double bounce;

  /// Given as the physical triple.
  bool get isPhysical => stiffness != null && damping != null;

  /// The stiffness in effect (`withDurationAndBounce`'s formula when not
  /// [isPhysical]).
  double get effectiveStiffness {
    if (isPhysical) return stiffness!;
    final seconds = math.max(1, duration) / 1000;
    return 4 * math.pi * math.pi * mass / (seconds * seconds);
  }

  /// The damping coefficient in effect.
  double get effectiveDamping {
    if (isPhysical) return damping!;
    final b = bounce.clamp(-0.95, 1.0);
    final ratio = b > 0 ? 1 - b : 1 / (1 + b);
    return ratio * 2 * math.sqrt(mass * effectiveStiffness);
  }

  /// [json] as a spring; a physical spring missing one constant takes
  /// [fallback]'s. Null when [json] isn't an object.
  static Spring? fromJson(Object? json, {Spring? fallback}) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final s = r.dn('stiffness'), d = r.dn('damping');
    final mass = r.d('mass', fallback?.mass ?? 1);
    if (s != null || d != null) {
      return Spring(
        stiffness: s ?? fallback?.effectiveStiffness ?? 380,
        damping: d ?? fallback?.effectiveDamping ?? 36,
        mass: mass > 0 ? mass : 1,
      );
    }
    if (m.containsKey('duration') || m.containsKey('bounce') || fallback == null || !fallback.isPhysical) {
      return Spring(duration: math.max(1, r.i('duration', 500)), bounce: r.d('bounce', 0), mass: mass > 0 ? mass : 1);
    }
    return Spring(stiffness: fallback.stiffness, damping: fallback.damping, mass: mass > 0 ? mass : 1);
  }

  Json toJson() {
    final j = <String, Object?>{};
    if (isPhysical) {
      j['stiffness'] = writeDouble(stiffness!);
      j['damping'] = writeDouble(damping!);
    } else {
      j
        ..i('duration', duration, 500)
        ..d('bounce', bounce, 0);
    }
    return j..d('mass', mass, 1);
  }

  /// [toJson] without what [base] (the owner's default) already says: a
  /// physical spring over a physical default writes only the constants
  /// that differ (`{"stiffness": 200}`), as [fromJson] reads them back.
  Json toJsonOver(Spring base) {
    if (!isPhysical || !base.isPhysical) return toJson();
    return <String, Object?>{}
      ..d('stiffness', stiffness!, base.stiffness!)
      ..d('damping', damping!, base.damping!)
      ..d('mass', mass, base.mass);
  }

  @override
  List<Object?> get props => [stiffness, damping, mass, isPhysical ? null : duration, isPhysical ? null : bounce];
}

// --- the animation primitive -----------------------------------------------------

/// `controller.repeat(reverse:, count:)`. [count] 0 repeats forever; a
/// count ends at the end of its last run. JSON: `{}` (forever),
/// `{"reverse": true, "count": 3}`; `true` and a bare count read too.
@immutable
final class AnimationRepeat extends _Value {
  const AnimationRepeat({this.reverse = false, this.count = 0});

  static const AnimationRepeat forever = AnimationRepeat();

  /// Plays once: `repeat(count: 1)`, a preset's loop turned into one run.
  static const AnimationRepeat once = AnimationRepeat(count: 1);

  final bool reverse;
  final int count;

  static AnimationRepeat? fromJson(Object? json) {
    if (json == true) return forever;
    if (json is num) return AnimationRepeat(count: math.max(0, json.round()));
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return AnimationRepeat(reverse: r.b('reverse', false), count: math.max(0, r.i('count', 0)));
  }

  Json toJson() => <String, Object?>{}
    ..b('reverse', reverse, false)
    ..i('count', count, 0);

  @override
  List<Object?> get props => [reverse, count];
}

/// One stop of a `TweenSequence`: the track's [value] at [at] (0–1 of the
/// track's run), reached on [curve] from the stop before it.
@immutable
final class Keyframe extends _Value {
  const Keyframe({required this.at, required this.value, this.curve = AnimationCurve.linear});

  final double at;
  final Object? value;
  final AnimationCurve curve;

  static Keyframe? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Keyframe(at: (r.dn('at') ?? r.d('t', 0)).clamp(0, 1).toDouble(), value: m['value'], curve: r.curve('curve', AnimationCurve.linear));
  }

  Json toJson() => <String, Object?>{'at': writeDouble(at), 'value': value}..e('curve', curve, AnimationCurve.linear);

  @override
  List<Object?> get props => [at, value, curve];
}

/// A sine added to a track's value: `amplitude * sin(2π(cycles·t + phase))`,
/// fading by `1 − decay·t` (a shake dies out with decay 1), folded to its
/// absolute value with [rectify] (a ball's hops). Flutter has no
/// counterpart; a list of them is a Fourier series: a wobble, a sway, a
/// flame's flicker.
@immutable
final class Wave extends _Value {
  const Wave({this.cycles = 1, this.amplitude = 1, this.phase = 0, this.decay = 0, this.rectify = false});

  final double cycles, amplitude, phase, decay;
  final bool rectify;

  /// Its value at [t] (0–1).
  double at(double t) {
    final s = math.sin(2 * math.pi * (cycles * t + phase));
    return amplitude * (rectify ? s.abs() : s) * (1 - decay * t);
  }

  static Wave? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Wave(
      cycles: r.d('cycles', 1),
      amplitude: r.d('amplitude', 1),
      phase: r.d('phase', 0),
      decay: r.d('decay', 0),
      rectify: r.b('rectify', false),
    );
  }

  Json toJson() => <String, Object?>{}
    ..d('cycles', cycles, 1)
    ..d('amplitude', amplitude, 1)
    ..d('phase', phase, 0)
    ..d('decay', decay, 0)
    ..b('rectify', rectify, false);

  @override
  List<Object?> get props => [cycles, amplitude, phase, decay, rectify];
}

/// How a track's value meets the property's own.
enum TrackBlend {
  /// The value is the property's (a `Tween` driving it).
  replace,

  /// Added to the property's own: a translation or rotation nested inside
  /// the node's (`SlideTransition`, `RotationTransition` around it).
  add,

  /// Multiplies the property's own: a scale or opacity nested inside the
  /// node's (`ScaleTransition`, `FadeTransition` around it).
  multiply;

  /// The value that changes nothing: 0 to add, 1 to multiply; null to
  /// replace.
  double? get identity => switch (this) {
        replace => null,
        add => 0,
        multiply => 1,
      };
}

/// How a track's [AnimationTrack.keyframes] are joined.
enum KeyframeInterpolation {
  /// Straight segments, each on its keyframe's curve (`TweenSequence`).
  linear,

  /// One smooth curve through every keyframe that never overshoots one
  /// (monotone cubic, Fritsch–Carlson): a lift that swells and settles. The
  /// keyframes' own curves are not used.
  monotoneCubic,
}

/// One tween a [NodeAnimation] drives: a property at a binding [path] of a
/// node, or a [variable].
///
/// The value at the controller's value `v` (after the animation's curve):
/// `u` is `v` inside [interval] (`Interval(begin, end)`), eased by [curve]
/// (`CurveTween`); then [wave]s added to [from], else the [keyframes]
/// (`TweenSequence`), else `Tween(begin: from, end: to)` at `u`. A missing
/// [from] or [to] is the property's own value (an entrance gives only
/// `from`), or [blend]'s identity when the track adds or multiplies.
/// Numbers interpolate and, as `Tween<double>` does, carry on past the ends
/// on a curve that overshoots (`elasticOut`); colors interpolate; any other
/// value switches at the end.
///
/// On a replacing track a wave's amplitude is a share of the way from
/// [from] to [to] (the property's own value when [to] is omitted):
/// `{"from": 0, "wave": [{}]}` swings a property between its own value and
/// as far the other way, once a run (a pendulum). On an adding or
/// multiplying track it is in the property's own units.
@immutable
final class AnimationTrack extends _Value {
  const AnimationTrack({
    this.id = '',
    this.path = '',
    this.node = '',
    this.variable = '',
    this.from,
    this.to,
    this.keyframes = const [],
    this.wave = const [],
    this.interval = const [0, 1],
    this.curve = AnimationCurve.linear,
    this.blend = TrackBlend.replace,
    this.interpolation = KeyframeInterpolation.linear,
  });

  /// Stable within its animation, so an edit can address it
  /// (`animations.enter.tracks.fade.from`). Optional.
  final String id;

  /// A binding path ([BindPaths]): `motion.rotate`, `opacity`,
  /// `decoration.fills[0].color`, `layout.width`, `props.value`.
  final String path;

  /// The target node's id or key; empty: the node the animation is on.
  final String node;

  /// Instead of [path]: a number variable the value is written to.
  final String variable;

  /// `Tween(begin:, end:)`: numbers, colors, or `${...}` expressions read
  /// when a play starts.
  final Object? from, to;
  final List<Keyframe> keyframes;
  final List<Wave> wave;

  /// `Interval(begin, end)`: the part of the run this track plays in
  /// (`[begin]` alone ends at 1).
  final List<double> interval;
  final AnimationCurve curve;
  final TrackBlend blend;

  /// How [keyframes] are joined.
  final KeyframeInterpolation interpolation;

  /// [interval]'s begin and end, kept in order inside 0–1.
  (double, double) get span {
    final b = interval.isNotEmpty ? interval.first.clamp(0.0, 1.0) : 0.0;
    final e = interval.length > 1 ? interval[1].clamp(b, 1.0) : 1.0;
    return (b, e);
  }

  /// `u`: the controller's value [v] inside [interval], eased by [curve].
  double local(double v) {
    final (b, e) = span;
    final u = e <= b ? (v >= e ? 1.0 : 0.0) : ((v - b) / (e - b)).clamp(0.0, 1.0);
    return curve.transform(u);
  }

  /// The track's value at controller value [v], with [own] the property's
  /// value, and [begin]/[end] standing in for [from]/[to] (resolved
  /// expressions). [text]: the value is a text's (a number in it counts,
  /// [lerpValue]).
  Object? valueAt(double v, {Object? own, Object? begin, Object? end, bool text = false}) {
    final u = local(v);
    final identity = blend.identity;
    final start = begin ?? from ?? identity ?? own;
    final stop = end ?? to ?? identity ?? own;
    if (wave.isNotEmpty) {
      final base = readDouble(start) ?? 0;
      var sum = 0.0;
      for (final w in wave) {
        sum += w.at(u);
      }
      final span = blend == TrackBlend.replace ? readDouble(stop) : null;
      return base + (span == null ? sum : (span - base) * sum);
    }
    if (keyframes.isNotEmpty) {
      return interpolation == KeyframeInterpolation.monotoneCubic ? monotoneAt(u, start, stop) : sequenceAt(u, start, stop, text: text);
    }
    return lerpValue(start, stop, u, text: text);
  }

  /// `TweenSequence` through [keyframes] from [start] at 0 to [stop] at 1;
  /// a keyframe at 0 or 1 gives that end.
  Object? sequenceAt(double u, Object? start, Object? stop, {bool text = false}) {
    final points = <(double, Object?, AnimationCurve)>[(0, start, AnimationCurve.linear)];
    final sorted = [...keyframes]..sort((a, b) => a.at.compareTo(b.at));
    var end = (1.0, stop, AnimationCurve.linear);
    for (final k in sorted) {
      if (k.at <= 0) {
        points[0] = (0, k.value, AnimationCurve.linear);
      } else if (k.at >= 1) {
        end = (1, k.value, k.curve);
      } else {
        points.add((k.at, k.value, k.curve));
      }
    }
    points.add(end);
    if (u <= 0) return points.first.$2;
    for (var i = 1; i < points.length; i++) {
      final (t1, v1, c) = points[i];
      if (u <= t1) {
        final (t0, v0, _) = points[i - 1];
        final s = t1 <= t0 ? 1.0 : (u - t0) / (t1 - t0);
        return lerpValue(v0, v1, c.transform(s), text: text);
      }
    }
    return points.last.$2;
  }

  /// The number keyframes [keyframes] give through [start] (at 0) and
  /// [stop] (at 1) at [u], on one monotone cubic (it never overshoots a
  /// keyframe); a keyframe at 0 or 1 gives that end. [start] or [stop] that
  /// isn't a number: [sequenceAt].
  Object? monotoneAt(double u, Object? start, Object? stop) {
    var from = readDouble(start), to = readDouble(stop);
    if (from == null || to == null) return sequenceAt(u, start, stop);
    final points = <(double, double)>[];
    final sorted = [...keyframes]..sort((a, b) => a.at.compareTo(b.at));
    for (final k in sorted) {
      final v = readDouble(k.value);
      if (v == null || !v.isFinite) continue;
      if (k.at <= 0) {
        from = v;
      } else if (k.at >= 1) {
        to = v;
      } else if (points.isNotEmpty && points.last.$1 == k.at) {
        points[points.length - 1] = (k.at, v);
      } else {
        points.add((k.at, v));
      }
    }
    return monotoneCubic([(0, from!), ...points, (1, to!)], u);
  }

  /// The monotone cubic (Fritsch–Carlson) through [points] (times 0–1 in
  /// order, the first at 0 and the last at 1) at [t].
  static double monotoneCubic(List<(double, double)> points, double t) {
    final n = points.length;
    if (t <= 0) return points.first.$2;
    if (t >= 1) return points.last.$2;
    final slopes = [
      for (var i = 0; i < n - 1; i++) (points[i + 1].$2 - points[i].$2) / (points[i + 1].$1 - points[i].$1),
    ];
    final tangents = List<double>.filled(n, 0);
    tangents[0] = slopes.first;
    tangents[n - 1] = slopes.last;
    for (var i = 1; i < n - 1; i++) {
      final a = slopes[i - 1], b = slopes[i];
      tangents[i] = a * b <= 0 ? 0 : (a + b) / 2;
    }
    for (var i = 0; i < n - 1; i++) {
      if (slopes[i] == 0) {
        tangents[i] = 0;
        tangents[i + 1] = 0;
        continue;
      }
      final alpha = tangents[i] / slopes[i], beta = tangents[i + 1] / slopes[i];
      final sum = alpha * alpha + beta * beta;
      if (sum > 9) {
        final tau = 3 / math.sqrt(sum);
        tangents[i] = tau * alpha * slopes[i];
        tangents[i + 1] = tau * beta * slopes[i];
      }
    }
    var i = 0;
    while (i < n - 2 && t > points[i + 1].$1) {
      i++;
    }
    final (t0, v0) = points[i];
    final (t1, v1) = points[i + 1];
    final h = t1 - t0, s = (t - t0) / h, s2 = s * s, s3 = s2 * s;
    return (2 * s3 - 3 * s2 + 1) * v0 +
        (s3 - 2 * s2 + s) * h * tangents[i] +
        (-2 * s3 + 3 * s2) * v1 +
        (s3 - s2) * h * tangents[i + 1];
  }

  /// [a] to [b] at [t]: numbers interpolate, past the ends too when [t]
  /// overshoots (`Tween<double>`); colors interpolate within them
  /// (`ColorTween`); anything else switches at the end.
  ///
  /// A text that holds a number at the end ([b]: "1,204", "\$12.50", "87%";
  /// a bare number written as text, "1204", only when [text]: the value is
  /// a text's) counts: the number goes from [a]'s (a number, or the first
  /// number in a text) to its own, written as [b] writes it (the characters
  /// around it, its decimals, its thousands separators), at every [t], 0
  /// too ([NumberInText]). A transition or a track on a text's
  /// `props.text` counts its number up to each new value.
  static Object? lerpValue(Object? a, Object? b, double t, {bool text = false}) {
    if (b is String && (a is num || a is String) && (text || double.tryParse(b.trim()) == null)) {
      final end = NumberInText.parse(b), start = a is num ? a.toDouble() : NumberInText.parse(a as String)?.value;
      if (end != null && start != null && start.isFinite) return t == 1 ? b : end.format(start + (end.value - start) * t);
    }
    final x = readDouble(a), y = readDouble(b);
    if (x != null && y != null) return t == 0 ? a : (t == 1 ? b : x + (y - x) * t);
    if (t <= 0 && a != null) return a;
    if (t >= 1 && b != null) return b;
    final ca = a is Color ? a : Color.fromHex(a), cb = b is Color ? b : Color.fromHex(b);
    if (ca != null && cb != null) {
      int ch(int p, int q) => (p + (q - p) * t).round().clamp(0, 255);
      return Color.fromARGB(ch(ca.alpha, cb.alpha), ch(ca.red, cb.red), ch(ca.green, cb.green), ch(ca.blue, cb.blue));
    }
    return t < 1 ? (a ?? b) : (b ?? a);
  }

  static AnimationTrack? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final interval = r.doubles('interval');
    return AnimationTrack(
      id: r.s('id'),
      path: r.s('path'),
      node: r.s('node'),
      variable: r.s('variable'),
      from: m['from'],
      to: m['to'],
      keyframes: [...?readList(_jsonText(m['keyframes']))?.map(Keyframe.fromJson).nonNulls],
      wave: [
        ...?switch (m['wave']) {
          final List<Object?> l => l.map(Wave.fromJson).nonNulls,
          final Object w => [?Wave.fromJson(w)],
          null => null,
        },
      ],
      interval: interval.isEmpty ? const [0, 1] : interval,
      curve: r.curve('curve', AnimationCurve.linear),
      blend: r.e(TrackBlend.values, 'blend', TrackBlend.replace),
      interpolation: r.e(KeyframeInterpolation.values, 'interpolation', KeyframeInterpolation.linear),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..s('id', id)
      ..s('path', path)
      ..s('node', node)
      ..s('variable', variable);
    if (from != null) j['from'] = from is Color ? (from as Color).toJson() : from;
    if (to != null) j['to'] = to is Color ? (to as Color).toJson() : to;
    if (keyframes.isNotEmpty) j['keyframes'] = [for (final k in keyframes) k.toJson()];
    if (wave.isNotEmpty) j['wave'] = [for (final w in wave) w.toJson()];
    if (interval.length != 2 || interval[0] != 0 || interval[1] != 1) j['interval'] = interval.map(writeDouble).toList();
    return j
      ..e('curve', curve, AnimationCurve.linear)
      ..e('blend', blend, TrackBlend.replace)
      ..e('interpolation', interpolation, KeyframeInterpolation.linear);
  }

  @override
  List<Object?> get props => [id, path, node, variable, from, to, keyframes, wave, interval, curve, blend, interpolation];
}

/// One `AnimationController` on a node and the tweens it drives (behavior
/// key `animations`, a list). A screen-wide one sits on the canvas node.
///
/// Its value runs 0 → 1 over [duration] (back over [reverseDuration]),
/// after [delay], eased by [curve] (`CurvedAnimation`), [repeat]ed or once;
/// on a [spring] instead of the clock; or follows [progress] (an
/// expression) with no clock at all. Each track maps that value to its
/// property ([AnimationTrack]).
///
/// [preset] names a short form (`pulse`, `shake`, `spin`... see
/// [AnimationPresets]) whose tracks and timing it stands for, with
/// [params]; fields given here override the preset's ([expanded]).
///
/// Read as `${animation.<id>.value}` (after [curve]), `.status`
/// (`dismissed`, `forward`, `reverse`, `completed`) and `.isAnimating` by
/// the node and the nodes inside it; driven by the `animate` action.
@immutable
final class NodeAnimation extends _Value {
  const NodeAnimation({
    required this.id,
    this.preset,
    this.params = const {},
    this.enabled = true,
    this.duration,
    this.reverseDuration,
    this.delay = 0,
    this.curve,
    this.repeat,
    this.autoplay,
    this.playKey,
    this.paused = false,
    this.phase = 0,
    this.spring,
    this.progress,
    this.alignment,
    this.tracks = const [],
    this.previewAt,
    this.ramp = 0,
    this.visibleFraction,
  });

  /// Unique on the node: `${animation.<id>.*}`, the `animate` action's
  /// `animation`, and the key a binding addresses it by
  /// (`animations.<id>.paused`). JSON reads `name` too. Empty: it plays,
  /// but nothing can name it.
  final String id;

  final String? preset;
  final Json params;

  /// Off, it applies nothing and doesn't run (the node shows its own
  /// values). Bindable.
  final bool enabled;

  /// `AnimationController.duration` / `reverseDuration` (ms); null: the
  /// preset's, else 300.
  final int? duration, reverseDuration;

  /// Waits this long (ms) before each play starts; the value holds at its
  /// start meanwhile.
  final int delay;

  /// Applied to the controller's value before every track; null: the
  /// preset's, else linear.
  final AnimationCurve? curve;

  /// `repeat(reverse:, count:)`; null: the preset's, else plays once.
  final AnimationRepeat? repeat;

  /// Plays when the node appears; false waits for [playKey] or an action.
  /// Null: the preset's, else true.
  final bool? autoplay;

  /// A change of this value to one that isn't empty, `0`, `false` or
  /// `null` plays it from the start (`forward(from: 0)`); not when the node
  /// first shows. Bindable.
  final String? playKey;

  /// Holds the controller where it is (`stop()`) while true; it carries on
  /// when false. Held before it starts, it waits at its start. Bindable.
  final bool paused;

  /// Where a play starts, as a share (0–1) of one cycle: `forward(from:
  /// phase)`; a run there and back when [repeat] reverses. Bindable
  /// (`${= index / count}` staggers copies).
  final double phase;

  /// Runs on this spring instead of [duration] and [curve]:
  /// `animateWith(SpringSimulation(spring, 0, 1, 0))`.
  final Spring? spring;

  /// An expression giving the value (0–1) directly: `${view.progress}`, a
  /// variable. The animation then has no clock ([spring], when set, eases
  /// toward each new value).
  final String? progress;

  /// The point the scale and rotation of its adding and multiplying tracks
  /// are about (`ScaleTransition(alignment:)`); null: the preset's, else
  /// the center.
  final Alignment? alignment;

  final List<AnimationTrack> tracks;

  /// Where the design canvas draws it, as a share of one cycle after its
  /// [phase]; null: not applied there (the node shows its own values, which
  /// is an entrance's end). Null takes the preset's.
  final double? previewAt;

  /// A repeating animation speeds up from still to its full pace over this
  /// many ms when it starts or resumes, slows to a stop over it when
  /// [paused], and eases to a new pace when its [duration] changes (a fan,
  /// a turntable spinning up). 0: at once, as `repeat()` does.
  final int ramp;

  /// With it, an autoplaying animation waits until this share (0–1) of the
  /// node is visible in its view before it starts (a scroll reveal: the
  /// share a `enterViewport` trigger's `visibleFraction` counts). Null: it
  /// starts when the node appears.
  final double? visibleFraction;

  /// The JSON key on a node.
  static const String key = 'animations';

  int get durationMs => math.max(0, duration ?? 300);
  AnimationCurve get effectiveCurve => curve ?? AnimationCurve.linear;
  bool get autoplays => autoplay ?? true;
  Alignment get effectiveAlignment => alignment ?? Alignment.center;

  /// Whether it repeats (forever or a count).
  bool get repeats => repeat != null;

  /// One cycle in ms: a run, or a run there and back.
  int get cycleMs => (repeat?.reverse ?? false ? 2 : 1) * math.max(1, durationMs);

  /// The primitive form: [preset] expanded into tracks and timing, this
  /// animation's own fields over the preset's. Itself without a preset (or
  /// with one [AnimationPresets] doesn't know).
  NodeAnimation get expanded {
    final name = preset;
    if (name == null) return this;
    final p = AnimationPresets.of(name);
    if (p == null) return this;
    final params = {...p.defaults, ...this.params};
    return NodeAnimation(
      id: id,
      enabled: enabled,
      duration: duration ?? p.durationOf?.call(params) ?? p.duration,
      reverseDuration: reverseDuration,
      delay: delay,
      curve: curve ?? p.curve,
      repeat: repeat ?? p.repeat,
      autoplay: autoplay ?? p.autoplay,
      playKey: playKey,
      paused: paused,
      phase: phase,
      spring: spring,
      progress: progress,
      alignment: alignment,
      tracks: [...p.tracks(params), ...tracks],
      previewAt: previewAt ?? p.previewAt,
      ramp: ramp,
      visibleFraction: visibleFraction,
    );
  }

  static NodeAnimation? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final id = r.sn('id') ?? r.sn('name') ?? '';
    return NodeAnimation(
      id: id,
      preset: r.sn('preset'),
      params: readMap(m['params']) ?? const {},
      enabled: _loose(m['enabled']) ?? true,
      duration: readInt(m['duration'])?.let((d) => math.max(0, d)),
      reverseDuration: readInt(m['reverseDuration'])?.let((d) => math.max(0, d)),
      delay: r.ms('delay', 0),
      curve: AnimationCurve.parse(m['curve']),
      repeat: AnimationRepeat.fromJson(m['repeat']),
      autoplay: _loose(m['autoplay']),
      playKey: m['playKey']?.toString(),
      paused: _loose(m['paused']) ?? false,
      phase: r.d('phase', 0),
      spring: Spring.fromJson(m['spring']),
      progress: r.sn('progress'),
      alignment: Alignment.fromJson(m['alignment']),
      tracks: [...?readList(_jsonText(m['tracks']))?.map(AnimationTrack.fromJson).nonNulls],
      previewAt: r.dn('previewAt'),
      ramp: r.ms('ramp', 0),
      visibleFraction: r.dn('visibleFraction'),
    );
  }

  Json toJson() {
    final j = <String, Object?>{'id': id}..s('preset', preset);
    if (params.isNotEmpty) j['params'] = params;
    j.b('enabled', enabled, true);
    if (duration != null) j['duration'] = duration;
    if (reverseDuration != null) j['reverseDuration'] = reverseDuration;
    j.i('delay', delay, 0);
    if (curve != null) j['curve'] = curve!.name;
    if (repeat != null) j['repeat'] = repeat!.toJson();
    if (autoplay != null) j['autoplay'] = autoplay;
    j
      ..s('playKey', playKey)
      ..b('paused', paused, false)
      ..d('phase', phase, 0);
    if (spring != null) j['spring'] = spring!.toJson();
    j.s('progress', progress);
    if (alignment != null) j['alignment'] = alignment!.toJson();
    if (tracks.isNotEmpty) j['tracks'] = [for (final t in tracks) t.toJson()];
    j
      ..dn('previewAt', previewAt)
      ..i('ramp', ramp, 0)
      ..dn('visibleFraction', visibleFraction);
    return j;
  }

  NodeAnimation copyWith({
    bool? enabled,
    int? duration,
    AnimationRepeat? repeat,
    bool? autoplay,
    String? playKey,
    double? phase,
    List<AnimationTrack>? tracks,
    double? previewAt,
    bool? paused,
  }) =>
      NodeAnimation(
        id: id,
        preset: preset,
        params: params,
        enabled: enabled ?? this.enabled,
        duration: duration ?? this.duration,
        reverseDuration: reverseDuration,
        delay: delay,
        curve: curve,
        repeat: repeat ?? this.repeat,
        autoplay: autoplay ?? this.autoplay,
        playKey: playKey ?? this.playKey,
        paused: paused ?? this.paused,
        phase: phase ?? this.phase,
        spring: spring,
        progress: progress,
        alignment: alignment,
        tracks: tracks ?? this.tracks,
        previewAt: previewAt ?? this.previewAt,
        ramp: ramp,
        visibleFraction: visibleFraction,
      );

  @override
  List<Object?> get props => [
        id, preset, params, enabled, duration, reverseDuration, delay, curve, repeat, autoplay, playKey, paused, //
        phase, spring, progress, alignment, tracks, previewAt, ramp, visibleFraction,
      ];
}

// --- a number in a text -----------------------------------------------------------

/// The first number in a text ("1,204", "-3.5", "\$12.50" → 12.50) and how
/// it is written: what is around it, its decimals and whether its thousands
/// are grouped. A text's number counts ([AnimationTrack.lerpValue]): each
/// value between is written the same way ([format]).
@immutable
final class NumberInText {
  const NumberInText(this.prefix, this.value, this.suffix, {required this.decimals, required this.grouped});

  final String prefix, suffix;
  final double value;
  final int decimals;
  final bool grouped;

  static final _pattern = RegExp(r'-?\d{1,3}(?:,\d{3})+(?:\.\d+)?|-?\d+(?:\.\d+)?');

  /// The number in [text], or null when it has none.
  static NumberInText? parse(String text) {
    final m = _pattern.firstMatch(text);
    if (m == null) return null;
    final raw = m[0]!;
    final value = double.tryParse(raw.replaceAll(',', ''));
    if (value == null || !value.isFinite) return null;
    final dot = raw.indexOf('.');
    return NumberInText(text.substring(0, m.start), value, text.substring(m.end),
        decimals: dot < 0 ? 0 : raw.length - dot - 1, grouped: raw.contains(','));
  }

  /// The text with [v] in place of the number, written the same way.
  String format(double v) {
    final fixed = v.abs().toStringAsFixed(decimals);
    final dot = fixed.indexOf('.');
    var whole = dot < 0 ? fixed : fixed.substring(0, dot);
    final fraction = dot < 0 ? '' : fixed.substring(dot);
    if (grouped) {
      final b = StringBuffer();
      for (var i = 0; i < whole.length; i++) {
        if (i > 0 && (whole.length - i) % 3 == 0) b.write(',');
        b.write(whole[i]);
      }
      whole = b.toString();
    }
    final negative = v < 0 && (whole + fraction).contains(RegExp('[1-9]'));
    return '$prefix${negative ? '-' : ''}$whole$fraction$suffix';
  }
}
