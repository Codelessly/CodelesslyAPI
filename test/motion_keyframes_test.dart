import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('keyframes', () {
    test('round-trip and leave unkeyed values out of JSON', () {
      const motion = MotionModel(
        durationMs: 240,
        keyframes: [MotionKeyframe(t: 0.4, scale: 1.25)],
        pulseKey: '3',
      );
      final Map json = motion.toJson();
      expect(json['keyframes'], [
        {'t': 0.4, 'scale': 1.25},
      ]);
      expect(json['pulseKey'], '3');
      expect(MotionModel.fromJson(json), motion);
      expect(MotionModel.none.toJson().containsKey('keyframes'), isFalse);
      expect(MotionModel.none.hasKeyframes, isFalse);
    });

    test('a keyframe sets and clears one value', () {
      const keyframe = MotionKeyframe(t: 0.5, scale: 1.1);
      final MotionKeyframe next = keyframe
          .withValue('rotate', 4)
          .withValue('scale', null);
      expect(next.values, {'rotate': 4});
      expect(next.atTime(0.25).t, 0.25);
      expect(next.atTime(0.25).rotate, 4);
    });

    test('an unkeyed value follows the transition', () {
      expect(
        MotionModel.keyframedValue(
          const [MotionKeyframe(t: 0.5, scale: 1.25)],
          'rotate',
          0,
          90,
          0.5,
        ),
        isNull,
      );
      expect(MotionModel.keyframedValue(const [], 'scale', 1, 1, 0.5), isNull);
    });

    test('one keyframe makes a hump through it, without overshoot', () {
      const frames = [MotionKeyframe(t: 0.5, scale: 1.25)];
      double at(double t) =>
          MotionModel.keyframedValue(frames, 'scale', 1, 1, t)!;
      expect(at(0), 1);
      expect(at(0.5), closeTo(1.25, 1e-9));
      expect(at(1), 1);
      for (double t = 0; t <= 1; t += 0.05) {
        expect(at(t), inInclusiveRange(1, 1.25));
        // Close to sin(πt): the star sticker's arc.
        expect(at(t), closeTo(1 + 0.25 * math.sin(math.pi * t), 0.05));
      }
      expect(at(0.25), closeTo(at(0.75), 1e-9));
    });

    test('keyframes run from the start value to the end value', () {
      const frames = [
        MotionKeyframe(t: 0.5, scale: 1.1),
        MotionKeyframe(t: 0, scale: 9),
        MotionKeyframe(t: 1, scale: 9),
      ];
      expect(MotionModel.keyframedValue(frames, 'scale', 0.95, 1, 0), 0.95);
      expect(MotionModel.keyframedValue(frames, 'scale', 0.95, 1, 1), 1);
      expect(
        MotionModel.keyframedValue(frames, 'scale', 0.95, 1, 0.5),
        closeTo(1.1, 1e-9),
      );
    });
  });

  group('bindable settings', () {
    test('durationMs and delayMs read numbers and text', () {
      expect(MotionModel.none.withSetting('durationMs', 380).durationMs, 380);
      expect(
        MotionModel.none.withSetting('durationMs', '160.4').durationMs,
        160,
      );
      expect(MotionModel.none.withSetting('delayMs', -5).delayMs, 0);
      expect(
        const MotionModel(durationMs: 200).withSetting('durationMs', 'x'),
        const MotionModel(durationMs: 200),
      );
    });

    test('curve reads names and displayed names', () {
      expect(MotionModel.parseCurve('elasticOut'), MotionCurve.elasticOut);
      expect(MotionModel.parseCurve('ease_in'), MotionCurve.easeIn);
      expect(MotionModel.parseCurve('Overshoot'), MotionCurve.easeOutBack);
      expect(MotionModel.parseCurve('wobbly'), isNull);
      expect(
        MotionModel.none.withSetting('curve', 'spring').curve,
        MotionCurve.spring,
      );
      expect(MotionModel.settings, containsAll(['durationMs', 'curve']));
    });
  });

  group('enterFrom on a path', () {
    const String path = 'M0 0 C 80 -160 240 -200 300 -40';

    test('starts at its pathProgress even when it is 0', () {
      const motion = MotionModel(
        path: path,
        pathProgress: 1,
        durationMs: 700,
        enterFrom: MotionModel(scale: 0.7),
      );
      expect(motion.entranceStart.pathProgress, 0);
      expect(motion.entranceStart.scale, 0.7);
    });

    test('writes pathProgress 0 and reads it back', () {
      const motion = MotionModel(
        path: path,
        pathProgress: 1,
        enterFrom: MotionModel(scale: 0.7),
      );
      final Map json = motion.toJson();
      expect(json['enterFrom'], {'scale': 0.7, 'pathProgress': 0.0});
      final MotionModel read = MotionModel.fromJson(json);
      expect(read, motion);
      expect(read.entranceStart.pathProgress, 0);
    });

    test('a node without a path keeps its own progress', () {
      const motion = MotionModel(
        pathProgress: 0.5,
        enterFrom: MotionModel(opacity: 0),
      );
      expect(motion.entranceStart.pathProgress, 0.5);
      expect(motion.toJson()['enterFrom'], {'opacity': 0.0});
    });
  });
}
