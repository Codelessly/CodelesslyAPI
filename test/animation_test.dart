// Animation as data (docs/design/02-animation.md): the one spring, the
// animation primitive and its presets, the frame trigger and the timer.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Node _node(Json j) => Node.fromJson({'type': 'box', ...j}, id: 'n')!;

void main() {
  group('springs', () {
    test('a spring is set by its physical constants or by duration and bounce, with Flutter\'s formulas', () {
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

    test('a spring constant left out takes its owner\'s default and is not written', () {
      final s = Spring.fromJson({'stiffness': 200}, fallback: FlipCard.defaultSpring)!;
      expect((s.stiffness, s.damping), (200, 36));
      expect(s.toJsonOver(FlipCard.defaultSpring), {'stiffness': 200});
    });

    test('a flip card and a route dismiss spring default to 380 / 36', () {
      expect(FlipCard.fromJson({'spring': {'damping': 20}})!.spring, const Spring.physical(stiffness: 380, damping: 20));
      expect(FlipCard.fromJson({})!.spring, const Spring.physical(stiffness: 380, damping: 36));
      expect(RouteDismiss.fromJson({'spring': {'stiffness': 200}})!.spring, const Spring.physical(stiffness: 200, damping: 36));
    });

    test('gesture physics presets keep their springs, and a preset still ignores flat spring keys', () {
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

  group('node animations', () {
    test('an animation\'s tracks run between their ends over their intervals, and round-trip', () {
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

    test('an animation with bad or loosely written values still loads, and writes only what is set', () {
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

    test('keyframes play in sequence, colors blend, and other values switch at the end', () {
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

    test('a preset is written short and expands to tracks, its own values over the preset\'s', () {
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

  group('triggers', () {
    test('a timer\'s interval is a number or a formula with a lower limit, and a frame trigger can be guarded', () {
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
    final blocks = RegExp(r'```json\n([\s\S]*?)```').allMatches(text).toList();
    expect(blocks.length, greaterThanOrEqualTo(10));
    Json written(Json j) {
      if (j['type'] is String && j.length > 1 && !j.containsKey('animations') && !j.containsKey('bind')) {
        return ActionDef.fromJson(j)!.toJson();
      }
      if (j.containsKey('trigger')) return Reaction.fromJson(j)!.toJson();
      return Node.fromJson({'type': 'box', ...j}, id: 'n')!.toJson()
        ..remove('id')
        ..remove('type')
        ..remove('layout');
    }

    for (final b in blocks) {
      final json = jsonDecode(b[1]!) as Json;
      expect(written(json), json, reason: b[1]);
    }
  });
}
