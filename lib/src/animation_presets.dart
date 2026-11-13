// The short forms of [NodeAnimation] (`{"preset": "pulse"}`), each a pure
// function of its params to tracks, and the readers that turn the legacy
// keys (`loops`, `effectAnimations`, `motion.pulseKey`) into animations.
// Shared by the editor and the SDK: the SDK plays only the expanded form.
part of 'behaviors.dart';

/// A named short form of a [NodeAnimation]: its default timing, and the
/// tracks it stands for as a function of its params.
@immutable
final class AnimationPreset {
  const AnimationPreset({
    required this.name,
    required this.defaults,
    required this.tracks,
    this.duration,
    this.curve,
    this.repeat,
    this.autoplay,
    this.previewAt,
  });

  final String name;

  /// The params it reads, with their defaults.
  final Json defaults;

  /// The tracks for params (over [defaults]).
  final List<AnimationTrack> Function(Json params) tracks;

  final int? duration;
  final AnimationCurve? curve;
  final AnimationRepeat? repeat;
  final bool? autoplay;
  final double? previewAt;
}

/// The presets an animation's `preset` names. Loops (`pulse`, `fade`,
/// `scale`, `spin`, `bob`, `sway`, `flicker`) repeat for a second and rest
/// (on the design canvas) at their start; one-shot effects (`shake`,
/// `bounce`, `pop`, `wiggle`, `jelly`, `flash`, `keyframes`) wait for a cue
/// and last 520 ms; `enter` plays once from its `from` values to the node's
/// own. Their tracks add to or multiply the node's own pose
/// ([TrackBlend]), as a Flutter `ScaleTransition` or `RotationTransition`
/// wrapped around it would.
abstract final class AnimationPresets {
  static double _p(Json p, String k, double fallback) => readDouble(p[k]) ?? fallback;
  static double _unit(Json p, String k) => _p(p, k, 1).clamp(0.0, 1.0);

  static AnimationTrack _scale(Json p) => AnimationTrack(
      id: 'scale', path: 'motion.scale', blend: TrackBlend.multiply, from: _p(p, 'scaleFrom', 1), to: _p(p, 'scaleTo', 1));
  static AnimationTrack _opacity(Json p) => AnimationTrack(
      id: 'opacity', path: 'opacity', blend: TrackBlend.multiply, from: _unit(p, 'opacityFrom'), to: _unit(p, 'opacityTo'));

  static const _loopDefaults = {'scaleFrom': 1, 'scaleTo': 1, 'opacityFrom': 1, 'opacityTo': 1};

  /// The flicker's three detuned waves (3, 7 and 17 a run) around the
  /// middle of [from]–[to]: exactly [flickerAt].
  static List<Wave> _flicker(double from, double to) {
    final k = (to - from) / 1.5;
    return [
      Wave(cycles: 3, amplitude: 0.35 * k),
      Wave(cycles: 7, amplitude: 0.25 * k, phase: 1.3 / (2 * math.pi)),
      Wave(cycles: 17, amplitude: 0.15 * k, phase: 0.4 / (2 * math.pi)),
    ];
  }

  static AnimationPreset _loop(String name, Json defaults, List<AnimationTrack> Function(Json p) tracks) =>
      AnimationPreset(
        name: name,
        defaults: defaults,
        tracks: tracks,
        duration: 1000,
        curve: AnimationCurve.linear,
        repeat: AnimationRepeat.forever,
        autoplay: true,
        previewAt: 0,
      );

  static AnimationPreset _effect(String name, Json defaults, List<AnimationTrack> Function(Json p) tracks) =>
      AnimationPreset(name: name, defaults: defaults, tracks: tracks, duration: 520, curve: AnimationCurve.linear, autoplay: false);

  static final Map<String, AnimationPreset> _all = {
    for (final p in <AnimationPreset>[
      _loop('pulse', _loopDefaults, (p) => [_scale(p), _opacity(p)]),
      _loop('fade', const {'opacityFrom': 1, 'opacityTo': 1}, (p) => [_opacity(p)]),
      _loop('scale', const {'scaleFrom': 1, 'scaleTo': 1}, (p) => [_scale(p)]),
      _loop('spin', const {'turns': 1}, (p) {
        final perSecond = readDouble(p['perSecond']);
        final turns = perSecond != null && perSecond != 0 ? perSecond.sign : _p(p, 'turns', 1);
        return [AnimationTrack(id: 'rotate', path: 'motion.rotate', blend: TrackBlend.add, from: 0, to: 360 * turns)];
      }),
      _loop('bob', const {'distance': 10}, (p) => [
            AnimationTrack(
                id: 'translateY', path: 'motion.translateY', blend: TrackBlend.add, wave: [Wave(cycles: 0.5, amplitude: -_p(p, 'distance', 10))]),
          ]),
      _loop('sway', const {'angle': 4}, (p) => [
            AnimationTrack(id: 'rotate', path: 'motion.rotate', blend: TrackBlend.add, wave: [Wave(amplitude: _p(p, 'angle', 4))]),
          ]),
      _loop('flicker', _loopDefaults, (p) {
        final s0 = _p(p, 'scaleFrom', 1), s1 = _p(p, 'scaleTo', 1);
        final o0 = _unit(p, 'opacityFrom'), o1 = _unit(p, 'opacityTo');
        return [
          AnimationTrack(id: 'scale', path: 'motion.scale', blend: TrackBlend.multiply, from: (s0 + s1) / 2, wave: _flicker(s0, s1)),
          AnimationTrack(id: 'opacity', path: 'opacity', blend: TrackBlend.multiply, from: (o0 + o1) / 2, wave: _flicker(o0, o1)),
        ];
      }),
      _effect('shake', const {'amount': 1, 'cycles': 4}, (p) => [
            AnimationTrack(
              id: 'translateX',
              path: 'motion.translateX',
              blend: TrackBlend.add,
              wave: [Wave(cycles: _cycles(p, 4), amplitude: 12 * _p(p, 'amount', 1), decay: 1)],
            ),
          ]),
      _effect('bounce', const {'amount': 1}, (p) {
        final a = _p(p, 'amount', 1);
        return [
          AnimationTrack(
              id: 'hop', path: 'motion.translateY', blend: TrackBlend.add, wave: [Wave(cycles: 1.5, amplitude: -22 * a, decay: 1, rectify: true)]),
          // The squash as it lands: from 30% of the run.
          AnimationTrack(
              id: 'squashX', path: 'motion.scaleX', blend: TrackBlend.multiply, interval: const [0.3, 1], wave: [Wave(cycles: 1.5, amplitude: 0.056 * a, decay: 1)]),
          AnimationTrack(
              id: 'squashY', path: 'motion.scaleY', blend: TrackBlend.multiply, interval: const [0.3, 1], wave: [Wave(cycles: 1.5, amplitude: -0.056 * a, decay: 1)]),
        ];
      }),
      _effect('pop', const {'amount': 1}, (p) => [
            AnimationTrack(
                id: 'scale', path: 'motion.scale', blend: TrackBlend.multiply, wave: [Wave(cycles: 0.5, amplitude: 0.22 * _p(p, 'amount', 1), decay: 0.5)]),
          ]),
      _effect('wiggle', const {'amount': 1, 'cycles': 3}, (p) => [
            AnimationTrack(
              id: 'rotate',
              path: 'motion.rotate',
              blend: TrackBlend.add,
              wave: [Wave(cycles: _cycles(p, 3), amplitude: 0.14 * _p(p, 'amount', 1) * 180 / math.pi, decay: 1)],
            ),
          ]),
      _effect('jelly', const {'amount': 1, 'cycles': 2}, (p) {
        final w = 0.16 * _p(p, 'amount', 1), c = _cycles(p, 2);
        return [
          AnimationTrack(id: 'scaleX', path: 'motion.scaleX', blend: TrackBlend.multiply, wave: [Wave(cycles: c, amplitude: w, decay: 1)]),
          AnimationTrack(id: 'scaleY', path: 'motion.scaleY', blend: TrackBlend.multiply, wave: [Wave(cycles: c, amplitude: -w, decay: 1)]),
        ];
      }),
      _effect('flash', const {'cycles': 2}, (p) => [
            AnimationTrack(
                id: 'opacity', path: 'opacity', blend: TrackBlend.multiply, from: 0.5, wave: [Wave(cycles: _cycles(p, 2), amplitude: 0.5, phase: 0.25)]),
          ]),
      _effect('keyframes', const {'amount': 1, 'frames': <Object?>[]}, _keyframeTracks),
      AnimationPreset(
        name: 'enter',
        defaults: const {'from': <String, Object?>{}},
        duration: 300,
        curve: AnimationCurve.easeOutCubic,
        autoplay: true,
        tracks: (p) => [
          for (final e in (readMap(p['from']) ?? const <String, Object?>{}).entries)
            AnimationTrack(id: e.key, path: e.key == 'opacity' ? 'opacity' : 'motion.${e.key}', from: e.value),
        ],
      ),
    ])
      p.name: p,
  };

  static double _cycles(Json p, double usual) {
    final c = _p(p, 'cycles', 0);
    return c > 0 ? c : usual;
  }

  /// A `keyframes` effect: each property from rest through the frames that
  /// give it (`t` 0–1, values as [Motion]'s: pixels, degrees, factors) back
  /// to rest, linearly; `amount` scales the moves, turns and the scales'
  /// distance from 1.
  static List<AnimationTrack> _keyframeTracks(Json p) {
    final amount = _p(p, 'amount', 1);
    final frames = [...?readList(_jsonText(p['frames']))?.map(readMap).nonNulls];
    const props = {
      'translateX': TrackBlend.add, 'translateY': TrackBlend.add, 'rotate': TrackBlend.add, //
      'scale': TrackBlend.multiply, 'scaleX': TrackBlend.multiply, 'scaleY': TrackBlend.multiply, 'opacity': TrackBlend.multiply,
    };
    return [
      for (final e in props.entries)
        if (frames.any((f) => readDouble(f[e.key]) != null))
          AnimationTrack(
            id: e.key,
            path: e.key == 'opacity' ? 'opacity' : 'motion.${e.key}',
            blend: e.value,
            keyframes: [
              for (final f in frames)
                if (readDouble(f[e.key]) case final double v)
                  if ((readDouble(f['t']) ?? readDouble(f['at']) ?? 0) case final double t when t > 0)
                    Keyframe(
                      at: math.min(1, t),
                      value: switch (e.key) {
                        'opacity' => v.clamp(0.0, 1.0),
                        'scale' || 'scaleX' || 'scaleY' => 1 + (v - 1) * amount,
                        _ => v * amount,
                      },
                    ),
            ],
          ),
    ];
  }

  /// The preset named [name], or null.
  static AnimationPreset? of(String name) => _all[name];

  static Iterable<String> get names => _all.keys;

  // --- legacy keys -------------------------------------------------------------

  /// The legacy loop types, which are preset names.
  static const loopTypes = ['pulse', 'fade', 'scale', 'spin', 'bob', 'sway', 'flicker'];

  /// The legacy one-shot effect types (`spin` plays the `spin` preset once).
  static const effectTypes = ['shake', 'bounce', 'pop', 'wiggle', 'jelly', 'flash', 'spin', 'keyframes'];

  /// A legacy `loops[index]` entry as the animation `loop<index>`.
  static NodeAnimation? fromLoop(Object? json, int index) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final type = _type(m['type'], loopTypes, 'pulse');
    final duration = r.ms('duration', 1000);
    final reverse = r.b('reverse', false);
    final cycle = (reverse ? 2 : 1) * math.max(1, duration);
    final raw = r.d('phase', 0) - r.i('lag', 0) / cycle;
    final phase = raw.isFinite ? writeDouble(raw - raw.floorToDouble()).toDouble() : 0.0;
    const keys = {'scaleFrom': 1.0, 'scaleTo': 1.0, 'opacityFrom': 1.0, 'opacityTo': 1.0, 'turns': 1.0, 'distance': 10.0, 'angle': 4.0};
    final params = <String, Object?>{
      for (final e in keys.entries)
        if (readDouble(m[e.key]) case final double v when v != e.value) e.key: _num(v),
    };
    return NodeAnimation(
      id: 'loop$index',
      preset: type,
      params: params,
      enabled: r.b('enabled', true),
      duration: duration == 1000 ? null : duration,
      delay: r.ms('delay', 0),
      curve: AnimationCurve.parse(m['curve']).let((c) => c == AnimationCurve.linear ? null : c),
      repeat: reverse ? const AnimationRepeat(reverse: true) : null,
      phase: phase,
    );
  }

  /// A legacy `effectAnimations[index]` entry: an animation named after it
  /// (`effect<index>` when it has no name) that waits for its cue.
  static NodeAnimation? fromEffect(Object? json, int index) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final type = _type(m['type'], effectTypes, 'shake');
    final name = r.s('name');
    final amount = r.d('amount', 1), cycles = math.max(0.0, r.d('cycles', 0));
    final duration = r.ms('duration', 520);
    final ox = r.d('originX', 0), oy = r.d('originY', 0);
    final spin = type == 'spin';
    final frames = readList(_jsonText(m['keyframes']));
    return NodeAnimation(
      id: name.isEmpty ? 'effect$index' : name,
      preset: type,
      params: {
        if (spin) 'turns': _num(amount) else if (amount != 1) 'amount': _num(amount),
        if (cycles > 0) 'cycles': _num(cycles),
        if (type == 'keyframes' && frames != null) 'frames': frames,
      },
      // A spin effect turns once, on a cue, easing in and out.
      duration: spin || duration != 520 ? duration : null,
      delay: r.ms('delay', 0),
      curve: spin
          ? AnimationCurve.easeInOutCubic
          : type == 'keyframes'
              ? AnimationCurve.parse(m['curve']).let((c) => c == AnimationCurve.linear ? null : c)
              : null,
      repeat: spin ? AnimationRepeat.once : null,
      autoplay: r.b('playOnAppear', false) ? true : (spin ? false : null),
      playKey: m['playKey']?.toString(),
      alignment: ox != 0 || oy != 0 ? Alignment(ox, oy) : null,
    );
  }

  /// A motion's `pulseKey`, which no player ever read: now an animation
  /// `pulse` that plays the motion's keyframes from its values and back to
  /// them (rest → pose → rest) each time the key changes.
  static NodeAnimation? fromPulseKey(Json motion, {bool bound = false}) {
    final key = motion['pulseKey']?.toString() ?? (bound ? '' : null);
    if (key == null) return null;
    final frames = [...?readList(_jsonText(motion['keyframes']))?.map(readMap).nonNulls];
    const props = [
      'translateX', 'translateY', 'scale', 'scaleX', 'scaleY', 'rotate', 'rotateX', 'rotateY', 'shiftX', 'shiftY', //
    ];
    final r = _R(motion);
    return NodeAnimation(
      id: 'pulse',
      autoplay: false,
      playKey: key.isEmpty ? null : key,
      duration: r.ms('duration', 0) > 0 ? r.ms('duration', 0) : 300,
      curve: AnimationCurve.parse(motion['curve']) ?? AnimationCurve.easeInOut,
      tracks: [
        for (final p in [...props, 'opacity'])
          if (frames.any((f) => readDouble(f[p]) != null))
            AnimationTrack(
              id: p,
              path: 'motion.$p',
              keyframes: [
                for (final f in frames)
                  if (readDouble(f[p]) case final double v)
                    Keyframe(at: (readDouble(f['t']) ?? 0).clamp(0.0, 1.0), value: v),
              ],
            ),
      ],
    );
  }
}

/// [v] for a params map: whole numbers as ints, others unrounded.
num _num(double v) => v == v.roundToDouble() && v.abs() < 1e15 ? v.toInt() : v;

String _type(Object? v, List<String> names, String fallback) => v is String && names.contains(v) ? v : fallback;
