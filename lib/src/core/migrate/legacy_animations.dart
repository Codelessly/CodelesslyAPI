// The schema-2 readers of a node's animation keys, moved out of the model:
// `loops`, `effectAnimations`, the temporal keys of `motion` (timing,
// entrance, loop, spin, keyframes, shimmer, `pulseKey`) and the binding paths
// that address them. They build the schema-3 values ([NodeAnimation],
// [Transition], [Shimmer]) exactly as the schema-2 decoders did; the steps in
// steps_behaviors.dart write those values' JSON.
import 'dart:math' as math;

import '../behaviors.dart';
import '../json.dart';
import '../values/color.dart';
import '../values/geometry.dart';
import 'legacy_read.dart';
import 'legacy_track.dart';

/// A legacy flat spring (`springStiffness`, `springDamping` on the owner's
/// own JSON [m]): null when [m] gives neither key.
Spring? legacySpring(Json m, String stiffnessKey, String dampingKey, {required Spring fallback}) {
  final s = readDouble(m[stiffnessKey]), d = readDouble(m[dampingKey]);
  if (s == null && d == null) return null;
  return Spring(stiffness: s ?? fallback.effectiveStiffness, damping: d ?? fallback.effectiveDamping, mass: fallback.mass);
}

String _type(Object? v, List<String> names, String fallback) => v is String && names.contains(v) ? v : fallback;

double _restOf(String key) => key == 'opacity' ? 1 : Motion.restOf(key);

/// The schema-2 animation readers.
abstract final class LegacyAnimations {
  /// The spring of a legacy motion's `spring` curve.
  static const Spring legacyMotionSpring = Spring.physical(stiffness: 380, damping: 20);
  // --- legacy keys -------------------------------------------------------------

  /// The legacy loop types, which are preset names.
  static const loopTypes = ['pulse', 'fade', 'scale', 'spin', 'bob', 'sway', 'flicker'];

  /// The legacy one-shot effect types (`spin` plays the `spin` preset once).
  static const effectTypes = ['shake', 'bounce', 'pop', 'wiggle', 'jelly', 'flash', 'spin', 'keyframes'];

  /// A legacy `loops[index]` entry as the animation `loop<index>`.
  static NodeAnimation? fromLoop(Object? json, int index) {
    final m = readMap(json);
    if (m == null) return null;
    final r = LegacyReader(m);
    final type = _type(m['type'], loopTypes, 'pulse');
    final duration = r.ms('duration', 1000);
    final reverse = r.b('reverse', false);
    final cycle = (reverse ? 2 : 1) * math.max(1, duration);
    final raw = r.d('phase', 0) - r.i('lag', 0) / cycle;
    final phase = raw.isFinite ? writeDouble(raw - raw.floorToDouble()).toDouble() : 0.0;
    const keys = {'scaleFrom': 1.0, 'scaleTo': 1.0, 'opacityFrom': 1.0, 'opacityTo': 1.0, 'turns': 1.0, 'distance': 10.0, 'angle': 4.0};
    final params = <String, Object?>{
      for (final e in keys.entries)
        if (readDouble(m[e.key]) case final double v when v != e.value) e.key: jsonNum(v),
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
    final r = LegacyReader(m);
    final type = _type(m['type'], effectTypes, 'shake');
    final name = r.s('name');
    final amount = r.d('amount', 1), cycles = math.max(0.0, r.d('cycles', 0));
    final duration = r.ms('duration', 520);
    final ox = r.d('originX', 0), oy = r.d('originY', 0);
    final spin = type == 'spin';
    final frames = readList(jsonText(m['keyframes']));
    return NodeAnimation(
      id: name.isEmpty ? 'effect$index' : name,
      preset: type,
      params: {
        if (spin) 'turns': jsonNum(amount) else if (amount != 1) 'amount': jsonNum(amount),
        if (cycles > 0) 'cycles': jsonNum(cycles),
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
    final r = LegacyReader(motion);
    final duration = r.ms('duration', 0), delay = r.ms('delay', 0);
    final curve = r.curve('curve', AnimationCurve.easeInOut);
    final springy = curve == AnimationCurve.spring;
    final spring = Spring.fromJson(motion['spring'], fallback: legacyMotionSpring) ??
        legacySpring(motion, 'springStiffness', 'springDamping', fallback: legacyMotionSpring) ??
        legacyMotionSpring;
    final timed = duration > 0 || springy;
    final rotateCurve = springy ? null : AnimationCurve.parse(motion['rotateCurve']);
    final fadeShare = springy ? 1.0 : r.d('fadeShare', 1).clamp(0.01, 1.0).toDouble();
    final perTrack = rotateCurve != null || fadeShare < 1;
    bool bound(String key) => bind.containsKey('motion.$key');
    double own(String key) => readDouble(motion[key]) ?? _restOf(key);
    bool moves(String key) => own(key) != _restOf(key) || bound(key);
    final hasPath = (motion['path'] is String && (motion['path'] as String).trim().isNotEmpty) || bound('path');
    final frames = readList(jsonText(motion['keyframes'])) ?? const [];
    final frameMaps = [...frames.map(readMap).nonNulls];
    bool keyed(String key) => frameMaps.any((f) => readDouble(f[key]) != null);
    final framesBound = bound('keyframes');
    final enterFrom = readMap(motion['enterFrom']);
    final enter = loose(motion['enter']) ?? false;
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
        for (final key in AnimationPresets.legacyMotionProperties) {
          final v = readDouble(enterFrom[key]);
          // An entrance starts at every value its enterFrom names; a loop
          // at those away from rest.
          if (v != null && (entrance || v != _restOf(key))) from[key] = jsonNum(v);
        }
        if (hasPath && !from.containsKey('pathProgress')) from['pathProgress'] = 0;
      } else {
        for (final key in AnimationPresets.legacyMotionProperties) {
          if (moves(key)) from[key] = jsonNum(_restOf(key));
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
          if (fadeShare < 1) 'fadeShare': jsonNum(fadeShare),
        };

    if (timed && loops) {
      final from = starts(entrance: false);
      final count = math.max(0, r.i('repeat', 0));
      final reverse = loopMode == 'reverse';
      final phase = r.d('phase', 0);
      // A counted loop that's done plays again when a bound value moves.
      final movedBy = [
        for (final key in AnimationPresets.legacyMotionProperties)
          if (bind['motion.$key'] case final String e) formulaOf(e) ?? '',
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
        paused: loose(motion['paused']) ?? false,
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
          paused: hasEntrance && (loose(motion['enterHeld']) ?? false),
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
        params: {'perSecond': jsonNum(spin)},
        ramp: r.ms('spinRamp', 800),
        paused: loose(motion['paused']) ?? false,
        alignment: origin == Alignment.center ? null : origin,
      ));
    }

    if (readMap(motion['shimmer']) case final Json sm) {
      final old = LegacyReader(sm);
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
                if (readDouble(f[key]) case final double v when v.isFinite) key == 'pathProgress' ? 'path.progress' : key: jsonNum(v),
          } case final Json values when values.isNotEmpty)
            Keyframe(at: (readDouble(f['t']) ?? 0).clamp(0.0, 1.0), value: values),
      ];
      Transition of(String property, {int? ms, AnimationCurve? ease, List<Keyframe> keyframes = const []}) =>
          Transition(
            property: property,
            duration: ms ?? duration,
            delay: delay,
            curve: springy ? AnimationCurve.linear : (ease ?? curve),
            spring: springy ? spring : null,
            keyframes: keyframes,
            interpolation: keyframes.isEmpty ? KeyframeInterpolation.linear : KeyframeInterpolation.monotoneCubic,
          );
      // (`arc` is kept on the `motion` transition's JSON by the step.)
      transitions.add(of('motion', keyframes: poseFrames));
      if (rotateCurve != null) transitions.add(of('motion.rotate', ease: rotateCurve));
      if (motion.containsKey('opacity') || bound('opacity') || keyed('opacity') || patchesOpacity) {
        final opacityFrames = fadeShare < 1
            ? const <Keyframe>[]
            : [
                for (final f in frameMaps)
                  if (readDouble(f['opacity']) case final double v when v.isFinite)
                    Keyframe(at: (readDouble(f['t']) ?? 0).clamp(0.0, 1.0), value: jsonNum(v)),
              ];
        transitions.add(fadeShare < 1
            ? of('opacity', ms: (duration * fadeShare).round(), ease: AnimationCurve.easeOut)
            : of('opacity', keyframes: opacityFrames));
      }
      if (motion.containsKey('blur') || bound('blur') || patchesBlur) transitions.add(of(AnimationPresets.legacyMotionPath('blur')));
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
    final frames = [...?readList(jsonText(motion['keyframes']))?.map(readMap).nonNulls];
    const props = [
      'translateX', 'translateY', 'scale', 'scaleX', 'scaleY', 'rotate', 'rotateX', 'rotateY', 'shiftX', 'shiftY', //
    ];
    final r = LegacyReader(motion);
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

  /// [bind] (a node's binding paths) with the legacy behavior paths
  /// rewritten to the animations they now address, read against the node's
  /// JSON [m]: `loops[i].<key>` → `animations.loop<i>.<key>` (a loop's
  /// `phase` and `lag` → one `phase` formula), `effectAnimations[i].<key>`
  /// → `animations.<its id>.<key>`, `motion.pulseKey` →
  /// `animations.pulse.playKey`. A key it can't rewrite is kept as given.
  static Map<String, String> migrateBind(Map<String, String> bind, Json m) {
    final motion = readMap(m['motion']);
    if (motion != null && (bind.keys.any((k) => k.startsWith('motion.')) || _legacyMotionKeys.any(motion.containsKey))) {
      bind = migrateMotionBind(bind, m, motion);
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
          final a = fromEffect(list[i], i);
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
      final r = LegacyReader(readMap(loops[i]) ?? const {});
      final cycle = (r.b('reverse', false) ? 2 : 1) * math.max(1, r.ms('duration', 1000));
      final phase = p == null ? writeDouble(r.d('phase', 0)).toString() : formulaOf(p);
      final lag = l == null ? writeDouble(r.d('lag', 0)).toString() : formulaOf(l);
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
  static Map<String, String> migrateMotionBind(Map<String, String> bind, Json m, Json motion) {
    final legacy = legacyMotion(m)!;
    final ids = {for (final a in legacy.animations) a.id};
    final played = [for (final id in const ['enter', 'loop']) if (ids.contains(id)) id];
    final all = transitions(m, legacy.transitions);
    final legacyTransitions = {for (final t in legacy.transitions) t.property};
    final timed = [
      for (final (i, t) in all.indexed)
        if (legacyTransitions.contains(t.property)) (i, t),
    ];
    final share = (readDouble(motion['fadeShare']) ?? 1).clamp(0.01, 1.0);
    final reverse = legacyLoopMode(motion['loop'], bind['motion.loop']) == 'reverse';
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
            final f = formulaOf(value);
            out['transitions[$i].$rest'] = rest == 'duration' && t.property == 'opacity' && share < 1 && f != null
                ? '\${= ($f) * ${writeDouble(share)}}'
                : value;
          }
        case 'paused':
          for (final id in const ['loop', 'spin']) {
            if (ids.contains(id)) out['animations.$id.paused'] = value;
          }
        case 'phase' when ids.contains('loop'):
          final f = formulaOf(value);
          if (reverse && f != null) {
            out['animations.loop.phase'] = '\${= ($f) / 2}';
          } else if (!reverse) {
            out['animations.loop.phase'] = value;
          }
        case 'repeat' when ids.contains('loop'):
          out['animations.loop.repeat.count'] = value;
        case 'loop' when ids.contains('loop'):
          final mode = legacyLoopMode(motion['loop'], value);
          final f = formulaOf(value);
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

  /// The legacy keys of [m] as animations, after [m]'s own `animations`; a
  /// legacy one replaces an animation of the same id.
  static List<NodeAnimation> animations(Json m, List<NodeAnimation> fromMotion) {
    final own = [...?readList(jsonText(m['animations']))?.map(NodeAnimation.fromJson).nonNulls];
    final legacy = <NodeAnimation>[
      for (final (i, l) in (readList(m['loops']) ?? const []).indexed) ?fromLoop(l, i),
      for (final (i, e) in (readList(m['effectAnimations']) ?? const []).indexed) ?fromEffect(e, i),
      if (readMap(m['motion']) case final Json motion)
        ?fromPulseKey(motion, bound: readMap(m['bind'])?.containsKey('motion.pulseKey') ?? false),
      ...fromMotion,
    ];
    if (legacy.isEmpty) return own;
    final ids = {for (final a in legacy) a.id};
    return [...own.where((a) => !ids.contains(a.id)), ...legacy];
  }

  /// [m]'s own `transitions`, then those its legacy motion timing gives (a
  /// legacy one replaces one for the same property).
  static List<Transition> transitions(Json m, List<Transition> fromMotion) {
    final own = LegacyTransitions.read(m['transitions']) ?? Transition.listFromJson(m['transitions']);
    if (fromMotion.isEmpty) return own;
    final props = {for (final t in fromMotion) t.property};
    return [...own.where((t) => !props.contains(t.property)), ...fromMotion];
  }

  /// The legacy temporal keys of [m]'s motion, read
  /// ([AnimationPresets.fromMotion]); null without a motion.
  static ({List<NodeAnimation> animations, List<Transition> transitions, Shimmer? shimmer, Map<String, String> bind})?
      legacyMotion(Json m) {
    final motion = readMap(m['motion']);
    if (motion == null) return null;
    final bind = {
      for (final e in (readMap(m['bind']) ?? const <String, Object?>{}).entries)
        if (e.value is String) e.key: e.value as String,
    };
    bool patches(String key) =>
        (readMap(m['states'])?.values ?? const []).any((state) => (readMap(state)?.values ?? const []).any((patch) => readMap(readMap(patch)?['motion'])?.containsKey(key) ?? false));
    return fromMotion(motion, bind: bind, patchesOpacity: patches('opacity'), patchesBlur: patches('blur'));
  }
  /// [bind] with the legacy `drag.*` paths rewritten to the behavior the
  /// node's `drag` became: `drag.track.<k>` → `track.<k>`, and for a drag
  /// that follows the pointer `drag.<k>` → `dismissible.<k>` or `pan.<k>`
  /// under their new names (`drag.restX` → `pan.x`, `drag.flyOut` →
  /// `dismissible.movementDuration`...; `drag.distanceThreshold` binds each
  /// direction's `dismissible.dismissThresholds`). `drag.enabled` →
  /// `<behavior>.enabled`. A path it can't rewrite is kept as given.
  static Map<String, String> migrateDragBind(Map<String, String> bind, Json m) {
    // A track that only shows its variable (`write: false`) binds its value.
    final legacyTrack = readMap(m['track']) ?? readMap(readMap(m['drag'])?['track']);
    if (legacyTrack != null && LegacyTrack.readsOnly(legacyTrack) && !bind.containsKey('track.value') &&
        !bind.containsKey('drag.track.value')) {
      bind = {...bind, 'track.value': '\${${readString(legacyTrack['variable'])!.trim()}}'};
    }
    if (!bind.keys.any((k) => k.startsWith('drag.'))) return bind;
    final d = readMap(m['drag']) ?? const <String, Object?>{};
    final isTrack = readMap(d['track']) != null || bind.keys.any((k) => k.startsWith('drag.track.'));
    final isHandle = !isTrack && (readBool(d['reorder']) ?? false);
    final isDismiss = !isTrack && !isHandle && d['release'] == 'dismiss';
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
