import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('easing curves', () {
    test('the overshoot curve goes past its end further than ease-out-back and settles on it', () {
      expect(AnimationCurve.parse('overshoot'), AnimationCurve.overshoot);
      final peak = [for (var i = 1; i < 100; i++) AnimationCurve.overshoot.transform(i / 100)].reduce(math.max);
      final back = [for (var i = 1; i < 100; i++) AnimationCurve.easeOutBack.transform(i / 100)].reduce(math.max);
      expect(peak, greaterThan(back));
      expect(peak, closeTo(1.1, 0.01));
      expect(AnimationCurve.overshoot.transform(1), 1);
    });

    test('the emphasized curve starts fast and settles gently, as Material 3\'s does', () {
      const c = AnimationCurve.emphasized;
      expect(AnimationCurve.parse('emphasized'), c);
      expect(c.transform(0), 0);
      expect(c.transform(1), 1);
      // Quick start, gentle settle: well past halfway at a quarter of the time.
      expect(c.transform(.25), greaterThan(.6));
      expect(c.transform(.5), closeTo(.89, .02));
    });
  });
}
