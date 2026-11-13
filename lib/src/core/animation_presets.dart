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

  static double _restOf(String key) => key == 'opacity' ? 1 : Motion.restOf(key);

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

  /// The legacy temporal keys of a node's motion JSON [motion] (with the
  /// node's [bind] map, and whether its state styles set the motion's
  /// opacity or blur, [patchesOpacity], [patchesBlur]) as what they are
  /// now:
  ///
  /// * `duration`, `delay`, `curve` (and `spring` for the `spring` curve)
  ///   → a `motion` [Transition], `rotateCurve` → a `motion.rotate` one;
  ///   `opacity` and `blur` changes keep easing (`opacity`, the layer
  ///   blur's radius), the opacity in the first `fadeShare`; `keyframes`
  ///   are passed through; `arc` is kept (deprecated).
  /// * `enter`, `enterFrom`, `replayKey`, `enterHeld`, `revealOnScroll`,
  ///   `revealFraction` (and `keyframes` replayed by a key) → the animation
  ///   `enter` (preset `enter`): autoplaying, `playKey` the replay key,
  ///   `paused` the hold, `visibleFraction` the reveal.
  /// * `loop`, `repeat`, `phase`, `paused` → the animation `loop` (preset
  ///   `loop`); a counted loop replays when a bound motion value changes.
  /// * `spin`, `spinRamp`, `paused` → the animation `spin` (preset `spin`,
  ///   its `ramp`).
  /// * `shimmer` → the [Shimmer] and the animation `shimmer`.
  ///
  /// Their bound keys are rewritten by [Behaviors.migrateBind], which also
  /// adds [bind]'s entries (what replays a counted loop).
  static ({List<NodeAnimation> animations, List<Transition> transitions, Shimmer? shimmer, Map<String, String> bind})
      fromMotion(
    Json motion, {
    Map<String, String> bind = const {},
    bool patchesOpacity = false,
    bool patchesBlur = false,
  }) {
    final r = _R(motion);
    final duration = r.ms('duration', 0), delay = r.ms('delay', 0);
    final curve = r.curve('curve', AnimationCurve.easeInOut);
    final springy = curve == AnimationCurve.spring;
    final spring = Spring.fromJson(motion['spring'], fallback: legacyMotionSpring) ??
        Spring.legacy(motion, 'springStiffness', 'springDamping', fallback: legacyMotionSpring) ??
        legacyMotionSpring;
    final timed = duration > 0 || springy;
    final rotateCurve = springy ? null : AnimationCurve.parse(motion['rotateCurve']);
    final fadeShare = springy ? 1.0 : r.d('fadeShare', 1).clamp(0.01, 1.0).toDouble();
    final perTrack = rotateCurve != null || fadeShare < 1;
    bool bound(String key) => bind.containsKey('motion.$key');
    double own(String key) => readDouble(motion[key]) ?? _restOf(key);
    bool moves(String key) => own(key) != _restOf(key) || bound(key);
    final hasPath = (motion['path'] is String && (motion['path'] as String).trim().isNotEmpty) || bound('path');
    final frames = readList(_jsonText(motion['keyframes'])) ?? const [];
    final frameMaps = [...frames.map(readMap).nonNulls];
    bool keyed(String key) => frameMaps.any((f) => readDouble(f[key]) != null);
    final framesBound = bound('keyframes');
    final enterFrom = readMap(motion['enterFrom']);
    final enter = _loose(motion['enter']) ?? false;
    final reveal = r.b('revealOnScroll', false);
    final hasEntrance = enter || enterFrom != null || reveal;
    final loopMode = legacyLoopMode(motion['loop'], bind['motion.loop']);
    final loops = loopMode != null && duration > 0;
    final replays = motion['replayKey'] != null || bound('replayKey');
    final animations = <NodeAnimation>[];
    final transitions = <Transition>[];
    final extraBind = <String, String>{};
    Shimmer? shimmer;

    // Where an entrance or a loop starts.
    Map<String, Object?> starts({required bool entrance}) {
      final from = <String, Object?>{};
      if (enterFrom != null) {
        for (final key in legacyMotionProperties) {
          final v = readDouble(enterFrom[key]);
          // An entrance starts at every value its enterFrom names; a loop
          // at those away from rest.
          if (v != null && (entrance || v != _restOf(key))) from[key] = _num(v);
        }
        if (hasPath && !from.containsKey('pathProgress')) from['pathProgress'] = 0;
      } else {
        for (final key in legacyMotionProperties) {
          if (moves(key)) from[key] = _num(_restOf(key));
        }
        if (entrance && reveal && !enter && !bound('enter')) from['opacity'] = 0;
      }
      // A start the node already has (and no binding moves) changes nothing.
      from.removeWhere((k, v) => readDouble(v) == own(k) && !bound(k) && !keyed(k));
      return from;
    }

    Json timing(Json params) => {
          ...params,
          if (frames.isNotEmpty) 'frames': frames,
          if (perTrack) 'curve': curve.name,
          if (rotateCurve != null) 'rotateCurve': rotateCurve.name,
          if (fadeShare < 1) 'fadeShare': _num(fadeShare),
        };

    if (timed && loops) {
      final from = starts(entrance: false);
      final count = math.max(0, r.i('repeat', 0));
      final reverse = loopMode == 'reverse';
      final phase = r.d('phase', 0);
      // A counted loop that's done plays again when a bound value moves.
      final movedBy = [
        for (final key in legacyMotionProperties)
          if (bind['motion.$key'] case final String e) Behaviors._formula(e) ?? '',
      ]..removeWhere((f) => f.isEmpty);
      animations.add(NodeAnimation(
        id: 'loop',
        preset: 'loop',
        params: timing({'from': from, if (loopMode == 'swing') 'mode': 'swing'}),
        duration: duration,
        delay: delay,
        curve: loopMode == 'swing' || perTrack ? AnimationCurve.linear : curve,
        repeat: AnimationRepeat(reverse: reverse, count: count),
        enabled: bind['motion.loop'] == null || legacyLoopMode(motion['loop'], null) != null,
        paused: _loose(motion['paused']) ?? false,
        // A reverse loop's phase was a share of one way.
        phase: reverse ? phase / 2 : phase,
      ));
      if (count > 0 && movedBy.isNotEmpty) {
        extraBind['animations.loop.playKey'] = "\${= 'loop|' + ${movedBy.map((f) => '($f)').join(" + '|' + ")}}";
      }
    } else if (timed && (hasEntrance || bound('enter') || (replays && (frames.isNotEmpty || framesBound)))) {
      final from = starts(entrance: true);
      if (from.isNotEmpty || frames.isNotEmpty || framesBound) {
        animations.add(NodeAnimation(
          id: 'enter',
          preset: 'enter',
          params: timing({'from': from}),
          enabled: hasEntrance || !bound('enter'),
          duration: duration == 0 ? null : duration,
          delay: delay,
          curve: springy ? AnimationCurve.linear : (perTrack ? AnimationCurve.linear : curve),
          spring: springy ? spring : null,
          autoplay: hasEntrance || bound('enter'),
          playKey: motion['replayKey']?.toString(),
          paused: hasEntrance && (_loose(motion['enterHeld']) ?? false),
          visibleFraction: reveal && hasEntrance ? r.d('revealFraction', 0.15).clamp(0.0, 1.0).toDouble() : null,
        ));
      }
    }

    final spin = r.d('spin', 0);
    if (spin != 0 || bound('spin')) {
      final origin = Alignment(r.d('originX', 0), r.d('originY', 0));
      animations.add(NodeAnimation(
        id: 'spin',
        preset: 'spin',
        params: {'perSecond': _num(spin)},
        ramp: r.ms('spinRamp', 800),
        paused: _loose(motion['paused']) ?? false,
        alignment: origin == Alignment.center ? null : origin,
      ));
    }

    if (readMap(motion['shimmer']) case final Json sm) {
      final old = _R(sm);
      shimmer = Shimmer(
        color: old.color('color') ?? Color.white,
        strength: old.d('strength', 0.8),
        width: old.d('width', 0.44),
        angle: old.d('angle', 0),
      );
      final ms = old.ms('duration', 1400);
      animations.add(NodeAnimation(id: 'shimmer', preset: 'shimmer', duration: ms == 1400 ? null : ms));
    }

    if (timed) {
      const pose = [
        'translateX', 'translateY', 'scale', 'scaleX', 'scaleY', 'rotate', 'rotateX', 'rotateY', 'pathProgress', //
      ];
      final poseFrames = <Keyframe>[
        for (final f in frameMaps)
          if ({
            for (final key in pose)
              if (!(key == 'rotate' && rotateCurve != null))
                if (readDouble(f[key]) case final double v when v.isFinite) key == 'pathProgress' ? 'path.progress' : key: _num(v),
          } case final Json values when values.isNotEmpty)
            Keyframe(at: (readDouble(f['t']) ?? 0).clamp(0.0, 1.0), value: values),
      ];
      Transition of(String property, {int? ms, AnimationCurve? ease, List<Keyframe> keyframes = const [], double arc = 0}) =>
          Transition(
            property: property,
            duration: ms ?? duration,
            delay: delay,
            curve: springy ? AnimationCurve.linear : (ease ?? curve),
            spring: springy ? spring : null,
            keyframes: keyframes,
            interpolation: keyframes.isEmpty ? KeyframeInterpolation.linear : KeyframeInterpolation.monotoneCubic,
            arc: arc,
          );
      transitions.add(of('motion', keyframes: poseFrames, arc: r.d('arc', 0)));
      if (rotateCurve != null) transitions.add(of('motion.rotate', ease: rotateCurve));
      if (motion.containsKey('opacity') || bound('opacity') || keyed('opacity') || patchesOpacity) {
        final opacityFrames = fadeShare < 1
            ? const <Keyframe>[]
            : [
                for (final f in frameMaps)
                  if (readDouble(f['opacity']) case final double v when v.isFinite)
                    Keyframe(at: (readDouble(f['t']) ?? 0).clamp(0.0, 1.0), value: _num(v)),
              ];
        transitions.add(fadeShare < 1
            ? of('opacity', ms: (duration * fadeShare).round(), ease: AnimationCurve.easeOut)
            : of('opacity', keyframes: opacityFrames));
      }
      if (motion.containsKey('blur') || bound('blur') || patchesBlur) transitions.add(of(legacyMotionPath('blur')));
    }
    return (animations: animations, transitions: transitions, shimmer: shimmer, bind: extraBind);
  }

  /// A legacy motion's `loop` mode (`restart`, `reverse`, `swing`), or the
  /// one a bound expression [bound] names; null for none.
  static String? legacyLoopMode(Object? value, String? bound) {
    const modes = ['restart', 'reverse', 'swing'];
    if (value is String && modes.contains(value)) return value;
    if (bound != null) {
      final named = [for (final m in modes) if (bound.contains(m)) m];
      if (named.length == 1) return named.single;
    }
    return null;
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
