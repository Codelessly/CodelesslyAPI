// Animation as data (docs/design/02-animation.md): the one spring, the
// animation primitive and its presets, the animate action, the frame
// trigger and the timer that absorbed the clock; and every legacy shape
// read into them (old JSON in, new model out).
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

import 'legacy_support.dart';

Node _node(Json j) => migratedNode({'type': 'box', ...j}, id: 'n')!;

double _v(NodeAnimation a, String track, double t) =>
    readDouble(a.expanded.tracks.firstWhere((x) => x.id == track).valueAt(t))!;

// The legacy effect shapes (render/play.dart's effectTransformAt before
// this change), the reference the presets must reproduce.
({double dx, double dy, double sx, double sy, double rotation, double opacity}) _legacyEffect(
  String type,
  double t,
  double amount, {
  double cycles = 0,
}) {
  final decay = 1 - t;
  double swings(double usual) => cycles > 0 ? cycles : usual;
  switch (type) {
    case 'shake':
      return (dx: math.sin(t * math.pi * 2 * swings(4)) * 12 * amount * decay, dy: 0, sx: 1, sy: 1, rotation: 0, opacity: 1);
    case 'bounce':
      final hop = (math.sin(t * math.pi * 3) * decay).abs();
      final squash = t > 0.3 ? math.sin((t - 0.3) / 0.7 * math.pi * 3) * 0.08 * decay : 0.0;
      return (dx: 0, dy: -22 * amount * hop, sx: 1 + squash * amount, sy: 1 - squash * amount, rotation: 0, opacity: 1);
    case 'pop':
      final s = 1 + math.sin(t * math.pi) * 0.22 * amount * (1 - t / 2);
      return (dx: 0, dy: 0, sx: s, sy: s, rotation: 0, opacity: 1);
    case 'wiggle':
      return (dx: 0, dy: 0, sx: 1, sy: 1, rotation: math.sin(t * math.pi * 2 * swings(3)) * 0.14 * amount * decay, opacity: 1);
    case 'jelly':
      final w = math.sin(t * math.pi * 2 * swings(2)) * 0.16 * amount * decay;
      return (dx: 0, dy: 0, sx: 1 + w, sy: 1 - w, rotation: 0, opacity: 1);
    case 'flash':
      return (dx: 0, dy: 0, sx: 1, sy: 1, rotation: 0, opacity: 0.5 + math.cos(t * math.pi * 2 * swings(2)) * 0.5);
  }
  throw ArgumentError(type);
}

/// The pose an expanded preset's tracks give at [t], composed as the SDK
/// does (adds and multiplies on rest).
({double dx, double dy, double sx, double sy, double rotation, double opacity}) _pose(NodeAnimation a, double t) {
  var dx = 0.0, dy = 0.0, s = 1.0, sx = 1.0, sy = 1.0, rotate = 0.0, opacity = 1.0;
  for (final track in a.expanded.tracks) {
    final v = readDouble(track.valueAt(t))!;
    switch (track.path) {
      case 'motion.translateX':
        dx += v;
      case 'motion.translateY':
        dy += v;
      case 'motion.scale':
        s *= v;
      case 'motion.scaleX':
        sx *= v;
      case 'motion.scaleY':
        sy *= v;
      case 'motion.rotate':
        rotate += v;
      case 'opacity':
        opacity *= v;
    }
  }
  return (dx: dx, dy: dy, sx: s * sx, sy: s * sy, rotation: rotate * math.pi / 180, opacity: opacity);
}

void main() {
  group('Spring', () {
    test('physical, or by duration and bounce (Flutter\'s formulas)', () {
      const physical = Spring.physical(stiffness: 200, damping: 30, mass: 2);
      expect((physical.effectiveStiffness, physical.effectiveDamping), (200, 30));
      const perceptual = Spring(duration: 500, bounce: 0.3);
      // SpringDescription.withDurationAndBounce: k = 4π²m/d², c = ζ·2√(mk).
      expect(perceptual.effectiveStiffness, closeTo(4 * math.pi * math.pi / 0.25, 1e-9));
      expect(perceptual.effectiveDamping, closeTo(0.7 * 2 * math.sqrt(perceptual.effectiveStiffness), 1e-9));
      expect(Spring.fromJson({'duration': 500, 'bounce': 0.3}), perceptual);
      expect(Spring.fromJson(perceptual.toJson()), perceptual);
      expect(const Spring().toJson(), isEmpty);
      expect(Spring.fromJson({'stiffness': 200, 'damping': 30, 'mass': 2}), physical);
    });

    test('a constant left out takes the owner\'s default; written sparse over it', () {
      final s = Spring.fromJson({'stiffness': 200}, fallback: FlipCard.defaultSpring)!;
      expect((s.stiffness, s.damping), (200, 36));
      expect(s.toJsonOver(FlipCard.defaultSpring), {'stiffness': 200});
    });

    test('the six legacy shapes read as it, with their defaults', () {
      // FlipSpring (380 / 36 / 1).
      expect(FlipCard.fromJson({'spring': {'damping': 20}})!.spring, const Spring.physical(stiffness: 380, damping: 20));
      expect(FlipCard.fromJson({})!.spring, const Spring.physical(stiffness: 380, damping: 36));
      // TransitionSpring (380 / 36 / 1).
      expect(RouteDismiss.fromJson({'spring': {'stiffness': 200}})!.spring, const Spring.physical(stiffness: 200, damping: 36));
      // Motion.springStiffness/Damping (380 / 20): the spring of its
      // transitions on the `spring` curve.
      final m = migratedBehaviors({'motion': {'curve': 'spring', 'springStiffness': 500}}).transitions.single;
      expect(m.spring, const Spring.physical(stiffness: 500, damping: 20));
      expect(m.toJson()['spring'], {'stiffness': 500, 'damping': 20});
      expect(Transition.fromJson(m.toJson()), m);
      // DragSource.springStiffness/Damping (260 / 14), now its returnSpring.
      final d = legacyDraggable({'springDamping': 9})!;
      expect(d.returnSpring, const Spring.physical(stiffness: 260, damping: 9));
      expect(d.toJson()['returnSpring'], {'damping': 9});
      expect(d.toJson().containsKey('springDamping'), isFalse);
      expect(d.effectivePhysics!.effectiveStiffness, 260);
      // Track.settleStiffness/Damping (380 / 20).
      final t = legacyTrack({'settleStiffness': 100, 'settleDamping': 10})!;
      expect(t.settleSpring, const Spring.physical(stiffness: 100, damping: 10));
      expect(t.toJson()['settleSpring'], {'stiffness': 100, 'damping': 10});
      expect(Track.fromJson(t.toJson())!.settleSpring, t.settleSpring);
      // GesturePhysics flat keys (380 / 32 / 1, or bounce + duration).
      expect(legacyPhysics({'stiffness': 200})!.spring, const Spring.physical(stiffness: 200, damping: 32));
      final b = legacyPhysics({'bounce': 0.12, 'duration': 420})!;
      expect(b.spring, const Spring(duration: 420, bounce: 0.12));
      expect(b.toJson(), {'spring': {'duration': 420, 'bounce': 0.12}});
      expect(GesturePhysics.fromJson(b.toJson()), b);
    });

    test('gesture physics presets keep their springs; flat keys under a preset as before', () {
      final gentle = GesturePhysics.fromJson({'preset': 'gentle'})!;
      expect(gentle.spring, const Spring(duration: 450));
      // A bounce preset ignored a flat stiffness, as the legacy reader did.
      expect(GesturePhysics.fromJson({'preset': 'gentle', 'stiffness': 999})!.spring, const Spring(duration: 450));
      expect(GesturePhysics.fromJson({'preset': 'heavy'})!.spring, const Spring.physical(stiffness: 200, damping: 30, mass: 2));
      // The legacy effective values: (2π/s)²·m and ζ·4π·m/s.
      final legacyK = math.pow(2 * math.pi / 0.45, 2), legacyC = 1 * 4 * math.pi / 0.45;
      expect(gentle.effectiveStiffness, closeTo(legacyK, 1e-9));
      expect(gentle.effectiveDamping, closeTo(legacyC, 1e-9));
    });
  });

  group('NodeAnimation', () {
    test('an animation with two tracks round-trips', () {
      const json = {
        'id': 'enter',
        'duration': 700,
        'tracks': [
          {'id': 'drop', 'path': 'motion.translateY', 'from': -260, 'curve': 'easeOutCubic'},
          {'id': 'fade', 'path': 'opacity', 'from': 0, 'interval': [0, 0.33], 'curve': 'easeOut'},
        ],
      };
      final n = _node({'animations': [json]});
      final a = n.behaviors.animations.single;
      expect(a.id, 'enter');
      expect(a.durationMs, 700);
      expect(a.tracks.map((t) => t.path), ['motion.translateY', 'opacity']);
      expect(n.toJson()['animations'], [json]);
      // Omitted ends are the property's own value.
      expect(a.tracks[0].valueAt(0, own: 12), -260);
      expect(a.tracks[0].valueAt(1, own: 12), 12);
      // Interval: done a third of the way through.
      expect(a.tracks[1].valueAt(0.33, own: 1), 1);
      expect(a.tracks[1].valueAt(0.5, own: 1), 1);
      expect(readDouble(a.tracks[1].valueAt(0.165, own: 1)), closeTo(AnimationCurve.easeOut.transform(0.5), 1e-9));
    });

    test('decoding is total and lenient; encoding sparse', () {
      final a = NodeAnimation.fromJson({'name': 'x', 'repeat': true, 'tracks': '[{"path": "opacity", "to": 0}]', 'paused': 'on'})!;
      expect(a.id, 'x');
      expect(a.repeat, AnimationRepeat.forever);
      expect(a.paused, isTrue);
      expect(a.tracks.single.to, 0);
      expect(a.toJson(), {'id': 'x', 'repeat': <String, Object?>{}, 'paused': true, 'tracks': [{'path': 'opacity', 'to': 0}]});
      expect(NodeAnimation.fromJson({'repeat': 3})!.repeat, const AnimationRepeat(count: 3));
      expect(NodeAnimation.fromJson(7), isNull);
      expect(const NodeAnimation(id: 'a').toJson(), {'id': 'a'});
    });

    test('keyframes are a TweenSequence; colors interpolate; other values switch at the end', () {
      const t = AnimationTrack(path: 'motion.rotate', from: 0, keyframes: [
        Keyframe(at: 0.5, value: 10, curve: AnimationCurve.easeIn),
        Keyframe(at: 1, value: 0),
      ]);
      expect(t.valueAt(0.5), 10);
      expect(readDouble(t.valueAt(0.25)), closeTo(10 * AnimationCurve.easeIn.transform(0.5), 1e-9));
      expect(readDouble(t.valueAt(0.75)), closeTo(5, 1e-9));
      expect(AnimationTrack.lerpValue('#FF000000', '#FFFFFFFF', 0.5), const Color(0xFF808080));
      expect(AnimationTrack.lerpValue('a', 'b', 0.5), 'a');
      expect(AnimationTrack.lerpValue('a', 'b', 1), 'b');
    });

    test('a preset stays short in JSON; expanded it is tracks, its fields over the preset\'s', () {
      final n = _node({
        'animations': [
          {'id': 'halo', 'preset': 'pulse', 'params': {'scaleTo': 1.4, 'opacityTo': 0}, 'duration': 1600},
        ],
      });
      final a = n.behaviors.animations.single;
      expect(n.toJson()['animations'], [
        {'id': 'halo', 'preset': 'pulse', 'params': {'scaleTo': 1.4, 'opacityTo': 0}, 'duration': 1600},
      ]);
      final e = a.expanded;
      expect(e.preset, isNull);
      expect(e.durationMs, 1600);
      expect(e.repeat, AnimationRepeat.forever);
      expect(e.previewAt, 0);
      expect([for (final t in e.tracks) (t.path, t.blend, t.from, t.to)], [
        ('motion.scale', TrackBlend.multiply, 1.0, 1.4),
        ('opacity', TrackBlend.multiply, 1.0, 0.0),
      ]);
      expect(AnimationPresets.names, containsAll(['pulse', 'fade', 'scale', 'spin', 'bob', 'sway', 'flicker', 'shake', 'enter']));
    });
  });

  group('legacy loops', () {
    test('each type expands to tracks giving its old pose', () {
      // LoopAnimation.poseAt: scale/opacity lerp, turns·c, sin(2πc)·angle,
      // -sin(πc)·distance.
      for (final c in [0.0, 0.1, 0.25, 0.4, 0.5, 0.77, 1.0]) {
        final pulse = legacyLoop({'type': 'pulse', 'scaleFrom': 0.5, 'scaleTo': 2, 'opacityFrom': 1.4, 'opacityTo': 0.2}, 0)!;
        expect(_v(pulse, 'scale', c), closeTo(0.5 + 1.5 * c, 1e-12));
        expect(_v(pulse, 'opacity', c), closeTo(1 + (0.2 - 1) * c, 1e-12));
        final spin = legacyLoop({'type': 'spin', 'turns': 2}, 0)!;
        expect(_v(spin, 'rotate', c), closeTo(720 * c, 1e-9));
        final sway = legacyLoop({'type': 'sway', 'angle': 6}, 0)!;
        expect(_v(sway, 'rotate', c), closeTo(math.sin(c * 2 * math.pi) * 6, 1e-9));
        final bob = legacyLoop({'type': 'bob', 'distance': 8}, 0)!;
        expect(_v(bob, 'translateY', c), closeTo(-math.sin(c * math.pi) * 8, 1e-9));
        final flicker = legacyLoop({'type': 'flicker', 'scaleFrom': 0.9, 'scaleTo': 1.1}, 0)!;
        expect(_v(flicker, 'scale', c), closeTo(0.9 + 0.2 * flickerAt(c), 1e-12));
      }
    });

    test('timing: duration, delay, curve, reverse, enabled, phase less lag', () {
      final a = legacyLoop(
          {'type': 'fade', 'duration': 500, 'delay': 30, 'curve': 'easeIn', 'reverse': true, 'enabled': false, 'phase': 0.3, 'lag': 100},
          2)!;
      expect(a.toJson(), {
        'id': 'loop2', 'preset': 'fade', 'enabled': false, 'duration': 500, 'delay': 30, 'curve': 'easeIn', //
        'repeat': {'reverse': true}, 'phase': 0.2,
      });
      final e = a.expanded;
      expect((e.durationMs, e.repeat, e.effectiveCurve, e.autoplays), (500, const AnimationRepeat(reverse: true), AnimationCurve.easeIn, true));
      expect(legacyLoop({'type': 'scale', 'lag': 250}, 0)!.phase, 0.75);
    });

    test('bindings into loops address the animation; phase and lag become one formula', () {
      final n = _node({
        'loops': [
          {'type': 'pulse', 'duration': 500, 'reverse': true},
          {'type': 'spin'},
        ],
        'bind': {
          'loops[0].lag': r'${= index * 160}',
          'loops[0].enabled': r'${on}',
          'loops[1].turns': r'${= speed}',
          'loops[1].reverse': r'${back}',
          'loops.*.delay': '20',
          'motion.pulseKey': r'${bump}',
          'opacity': r'${o}',
        },
      });
      expect(n.bind, {
        'animations.loop0.enabled': r'${on}',
        'animations.loop1.params.turns': r'${= speed}',
        'animations.loop1.repeat.reverse': r'${back}',
        'animations.loop0.delay': '20',
        'animations.loop1.delay': '20',
        'animations.pulse.playKey': r'${bump}',
        'opacity': r'${o}',
        'animations.loop0.phase': r'${= (0) - (index * 160) / 1000}',
      });
      // A binding path applies.
      final bound = BindPaths.apply(n, 'animations.loop1.params.turns', 3);
      expect(bound.behaviors.animations[1].params['turns'], 3);
      expect(BindPaths.apply(n, 'animations.loop0.enabled', false).behaviors.animations[0].enabled, isFalse);
    });
  });

  group('legacy effects', () {
    test('each type expands to tracks giving its old pose exactly', () {
      for (final type in ['shake', 'bounce', 'pop', 'wiggle', 'jelly', 'flash']) {
        for (final (amount, cycles) in [(1.0, 0.0), (1.7, 5.0)]) {
          final a = legacyEffect({'name': 'e', 'type': type, 'amount': amount, 'cycles': cycles}, 0)!;
          for (var i = 0; i <= 40; i++) {
            final t = i / 40;
            final want = _legacyEffect(type, t, amount, cycles: cycles), got = _pose(a, t);
            for (final (w, g, what) in [
              (want.dx, got.dx, 'dx'), (want.dy, got.dy, 'dy'), (want.sx, got.sx, 'sx'), (want.sy, got.sy, 'sy'), //
              (want.rotation, got.rotation, 'rotation'), (want.opacity, got.opacity, 'opacity'),
            ]) {
              expect(g, closeTo(w, 1e-9), reason: '$type x$amount c$cycles at $t: $what');
            }
          }
        }
      }
    });

    test('spin turns once on its curve; keyframes run from rest and back', () {
      final spin = legacyEffect({'name': 's', 'type': 'spin', 'amount': 2, 'duration': 600}, 0)!;
      final e = spin.expanded;
      expect((e.repeat, e.effectiveCurve, e.autoplays, e.durationMs), (AnimationRepeat.once, AnimationCurve.easeInOutCubic, false, 600));
      expect(_v(spin, 'rotate', 0.5), 360);
      final hop = legacyEffect({
        'name': 'hop',
        'type': 'keyframes',
        'curve': 'easeOut',
        'keyframes': [
          {'t': 0.5, 'translateY': -30, 'scaleY': 1.2},
          {'t': 0, 'translateY': 99},
        ],
      }, 0)!;
      expect(_v(hop, 'translateY', 0), 0);
      expect(_v(hop, 'translateY', 0.25), closeTo(-15, 1e-9));
      expect(_v(hop, 'translateY', 0.5), -30);
      expect(_v(hop, 'translateY', 1), 0);
      expect(_v(hop, 'scaleY', 0.5), 1.2);
      expect(hop.expanded.effectiveCurve, AnimationCurve.easeOut);
    });

    test('cue, appear, origin and delay carry over; bindings follow the name', () {
      final n = _node({
        'effectAnimations': [
          {'name': 'nudge', 'type': 'shake', 'playOnAppear': true, 'originX': -1, 'delay': 40, 'playKey': 'k'},
          {'type': 'pop'},
        ],
        'bind': {'effectAnimations[0].playKey': r'${tick}', 'effectAnimations[1].amount': '2'},
      });
      final [nudge, pop] = n.behaviors.animations;
      expect((nudge.id, nudge.autoplays, nudge.alignment, nudge.delay, nudge.playKey), ('nudge', true, const Alignment(-1, 0), 40, 'k'));
      expect((pop.id, pop.expanded.autoplays), ('effect1', false));
      expect(n.bind, {'animations.nudge.playKey': r'${tick}', 'animations.effect1.params.amount': '2'});
      expect(n.toJson().containsKey('effectAnimations'), isFalse);
    });
  });

  test('motion.pulseKey (never played before) is a play-key animation through the keyframes', () {
    final n = _node({
      'motion': {
        'duration': 280,
        'keyframes': [
          {'t': 0.5, 'scale': 1.28},
        ],
        'pulseKey': r'${bump}',
      },
    });
    final pulse = n.behaviors.animations.single;
    expect((pulse.id, pulse.autoplays, pulse.playKey, pulse.durationMs), ('pulse', false, r'${bump}', 280));
    final t = pulse.tracks.single;
    expect(t.path, 'motion.scale');
    expect(t.valueAt(0, own: 1), 1);
    expect(t.valueAt(0.5, own: 1), 1.28);
    expect(t.valueAt(1, own: 1), 1);
    expect((n.toJson()['motion']! as Map).containsKey('pulseKey'), isFalse);
  });

  group('animate action', () {
    test('reads playAnimation and every animateVariable mode', () {
      final play = legacyAction({'type': 'playAnimation', 'node': 'n', 'animation': 'pop', 'nonBlocking': true}) as AnimateAction;
      expect(play.toJson(), {'type': 'animate', 'node': 'n', 'animation': 'pop', 'from': '0', 'nonBlocking': true});
      AnimateAction v(Json j) => legacyAction({'type': 'animateVariable', 'variable': 't', ...j}) as AnimateAction;
      expect(v({'to': '5', 'durationMs': 800, 'curve': 'easeOut'}).toJson(), {
        'type': 'animate', 'variable': 't', 'command': 'animateTo', 'target': '5', 'duration': '800', 'curve': 'easeOut',
      });
      expect(v({'from': '0', 'duration': r'${ms}'}).toJson(), {
        'type': 'animate', 'variable': 't', 'command': 'animateTo', 'from': '0', 'target': '1', 'duration': r'${ms}',
      });
      expect(v({'mode': 'pause'}).command, AnimateCommand.stop);
      expect(v({'mode': 'stop'}).command, AnimateCommand.stop);
      expect(v({'mode': 'resume'}).command, AnimateCommand.forward);
      expect(v({'mode': 'seek', 'to': '0.5'}).command, AnimateCommand.set);
      expect(ActionDef.types, isNot(contains('playAnimation')));
    });
  });

  group('triggers', () {
    test('the clock is a timer: every → intervalMs, runWhen → when; lookaheadMs dropped', () {
      final t = legacyTrigger({'type': 'clock', 'every': 'period', 'runWhen': 'playing', 'lookaheadMs': 50});
      expect(t.type, TriggerType.timer);
      expect(t.intervalMs, const Expr<int>.source(r'${= period}'));
      expect(t.when, 'playing');
      expect(legacyTrigger({'type': 'clock', 'every': 100}).effectiveIntervalMs, 100);
      // A clock without `every` never ticked; neither does its timer.
      expect(legacyTrigger({'type': 'clock'}).effectiveIntervalMs, isNull);
    });

    test('timer intervals are numbers or expressions; a frame ticker has a guard', () {
      expect(Trigger.fromJson({'type': 'timer'})!.effectiveIntervalMs, 1000);
      expect(Trigger.fromJson({'type': 'timer', 'intervalMs': 5})!.effectiveIntervalMs, Trigger.minIntervalMs);
      final e = Trigger.fromJson({'type': 'timer', 'intervalMs': r'${= 60000 / bpm}'})!;
      expect(e.effectiveIntervalMs, isNull);
      expect(e.toJson(), {'type': 'timer', 'intervalMs': r'${= 60000 / bpm}'});
      expect(Trigger.intervalMsOf('250'), 250);
      final f = Trigger.fromJson({'type': 'frame', 'when': r'${playing}'})!;
      expect((f.type, f.when), (TriggerType.frame, r'${playing}'));
      expect(TriggerType.screen, contains(TriggerType.frame));
    });
  });

  test('the guide\'s JSON samples read and write back as shown', () {
    final text = File('docs/guide/08-animation.md').readAsStringSync();
    final blocks = RegExp(r'```json( legacy)?\n([\s\S]*?)```').allMatches(text).toList();
    expect(blocks.length, greaterThanOrEqualTo(10));
    // An old shape is migrated first.
    Json written(Json j, {bool legacy = false}) {
      if (j['type'] is String && j.length > 1 && !j.containsKey('animations') && !j.containsKey('bind')) {
        return (legacy ? legacyAction(j) : ActionDef.fromJson(j)!).toJson();
      }
      if (j.containsKey('trigger')) {
        return (legacy ? legacyNode({'actions': [j]}).actions.single : Reaction.fromJson(j)!).toJson();
      }
      return migratedNode({'type': 'box', ...j}, id: 'n')!.toJson()
        ..remove('id')
        ..remove('type')
        ..remove('layout');
    }

    for (var i = 0; i < blocks.length; i++) {
      final json = jsonDecode(blocks[i][2]!) as Json;
      if (blocks[i][1] != null) {
        // An old shape: it reads as the next sample.
        expect(written(json, legacy: true), jsonDecode(blocks[i + 1][2]!), reason: blocks[i][2]);
        continue;
      }
      expect(written(json), json, reason: blocks[i][2]);
      expect(written(json), isNot(contains('loops')));
    }
  });
}
