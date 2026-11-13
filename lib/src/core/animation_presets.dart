// The short forms of [NodeAnimation] (`{"preset": "pulse"}`), each a pure
// function of its params to tracks. (Schema 2's `loops`, `effectAnimations`
// and motion keys are turned into animations by the schema-3 migration.)
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
    this.durationOf,
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

  /// The duration for params (over [defaults]), when it depends on them
  /// (a spin's turns per second); null: [duration].
  final int? Function(Json params)? durationOf;
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
      AnimationPreset(
        name: 'spin',
        defaults: const {'turns': 1},
        duration: 1000,
        curve: AnimationCurve.linear,
        repeat: AnimationRepeat.forever,
        autoplay: true,
        previewAt: 0,
        // `perSecond` turns a second: one turn a run, a run 1000 / |perSecond|
        // ms; 0 holds still (a repeat with no duration).
        durationOf: (p) => switch (readDouble(p['perSecond'])) {
          null => null,
          final double s => s == 0 ? 0 : math.max(1, (1000 / s.abs()).round()),
        },
        tracks: (p) {
          final perSecond = readDouble(p['perSecond']);
          final turns = perSecond != null ? (perSecond < 0 ? -1.0 : 1.0) : _p(p, 'turns', 1);
          return [AnimationTrack(id: 'rotate', path: 'motion.rotate', blend: TrackBlend.add, from: 0, to: 360 * turns)];
        },
      ),
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
        tracks: (p) => _poseTracks(p, swing: false),
      ),
      AnimationPreset(
        name: 'loop',
        defaults: const {'from': <String, Object?>{}},
        duration: 1000,
        curve: AnimationCurve.linear,
        repeat: AnimationRepeat.forever,
        autoplay: true,
        // The design canvas draws the node's own values (a motion's loop
        // ran from its start to them).
        tracks: (p) => _poseTracks(p, swing: p['mode'] == 'swing'),
      ),
      AnimationPreset(
        name: 'shimmer',
        defaults: const {},
        duration: 1400,
        curve: AnimationCurve.linear,
        repeat: AnimationRepeat.forever,
        autoplay: true,
        tracks: (p) => const [AnimationTrack(id: 'position', path: 'shimmer.position', from: 0, to: 1)],
      ),
    ])
      p.name: p,
  };

  /// The tracks of the `enter` and `loop` presets: one per property its
  /// `from` names (from that value to the node's own) or its `frames`
  /// name (legacy motion keyframes, `{"t": 0.5, "scale": 1.2}`: through
  /// them on one monotone cubic). Property names are a motion's (`opacity`
  /// is the node's, `blur` its `motionBlur` layer blur, `pathProgress` its
  /// path's progress), or binding paths. With `curve` given, each track
  /// eases on it, except the rotation on `rotateCurve` and the opacity on
  /// `easeOut` in the first `fadeShare` of the run. A `swing` rocks each
  /// `from` property around it on a sine, to its own value and as far the
  /// other way, one swing a run.
  static List<AnimationTrack> _poseTracks(Json p, {required bool swing}) {
    final from = readMap(_jsonText(p['from'])) ?? const <String, Object?>{};
    final frames = [...?readList(_jsonText(p['frames']))?.map(readMap).nonNulls];
    final curve = AnimationCurve.parse(p['curve']);
    final rotateCurve = AnimationCurve.parse(p['rotateCurve']);
    final share = (readDouble(p['fadeShare']) ?? 1).clamp(0.01, 1.0);
    List<Keyframe> keyframesOf(String key) => [
          for (final f in frames)
            if (readDouble(f[key]) case final double v when v.isFinite)
              Keyframe(at: (readDouble(f['t']) ?? readDouble(f['at']) ?? 0).clamp(0.0, 1.0), value: v),
        ];
    final keys = <String>[
      ...from.keys,
      if (!swing)
        for (final k in legacyKeyframeProperties)
          if (!from.containsKey(k) && keyframesOf(k).isNotEmpty) k,
    ];
    return [
      for (final key in keys)
        () {
          final fades = key == 'opacity' && share < 1 && curve != null;
          final turns = key == 'rotate' && rotateCurve != null && curve != null;
          final keyframes = swing || fades || turns ? const <Keyframe>[] : keyframesOf(key);
          return AnimationTrack(
            id: key,
            path: legacyMotionPath(key),
            from: from[key],
            keyframes: keyframes,
            wave: swing ? const [Wave()] : const [],
            interpolation: keyframes.isEmpty ? KeyframeInterpolation.linear : KeyframeInterpolation.monotoneCubic,
            interval: fades ? [0, share] : const [0, 1],
            curve: fades ? AnimationCurve.easeOut : (turns ? rotateCurve : (swing ? null : curve)) ?? AnimationCurve.linear,
          );
        }(),
    ];
  }

  /// The properties a legacy motion keyframe could name.
  static const legacyKeyframeProperties = [
    'translateX', 'translateY', 'scale', 'scaleX', 'scaleY', 'opacity', 'rotate', 'rotateX', 'rotateY', 'pathProgress', //
  ];

  /// The properties of a legacy motion that animated.
  static const legacyMotionProperties = [
    'translateX', 'translateY', 'scale', 'shiftX', 'shiftY', 'scaleX', 'scaleY', 'opacity', 'rotate', 'rotateX', //
    'rotateY', 'pathProgress', 'blur',
  ];

  /// The id of the layer blur a legacy `motion.blur` became.
  static const motionBlurId = 'motionBlur';

  /// The binding path of legacy motion property [key] now: `opacity` is the
  /// node's, `blur` its [motionBlurId] layer blur's radius, `pathProgress`
  /// its path's progress, the rest `motion.<key>`; a key with a dot is a
  /// binding path already.
  static String legacyMotionPath(String key) => switch (key) {
        'opacity' => 'opacity',
        'blur' => 'decoration.effects.$motionBlurId.blurRadius',
        'pathProgress' => 'motion.path.progress',
        _ when key.contains('.') => key,
        _ => 'motion.$key',
      };

  /// The spring of a legacy motion's `spring` curve.
  static const Spring legacyMotionSpring = Spring.physical(stiffness: 380, damping: 20);

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
}
