import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a flight style round-trips and stays sparse', () {
    const f = Flight(duration: 720, curve: AnimationCurve.easeInOutCubic, lift: 110, liftShare: 0.55, swell: 1.75, turns: 0.6, trail: 4);
    final j = f.toJson();
    expect(j, {'duration': 720, 'curve': 'easeInOutCubic', 'lift': 110, 'liftShare': 0.55, 'swell': 1.75, 'turns': 0.6, 'trail': 4});
    expect(Flight.fromJson(j), f);
    expect(const Flight().toJson(), isEmpty);
    final b = Behaviors.fromJson({'flightKey': 'react-🔥', 'flight': j});
    expect(b.flight, f);
    final out = <String, Object?>{};
    b.writeTo(out);
    expect(out['flight'], j);
  });

  test('paper confetti and emoji particles round-trip', () {
    const e = ParticleEmitter(
      count: 105,
      shapes: [ParticleShape.strip, ParticleShape.circle, ParticleShape.triangle, ParticleShape.squiggle, ParticleShape.emoji],
      delay: 350,
      drag: 1.9,
      terminalVelocity: 135,
      sway: 18,
      flutter: 11,
      spin: 340,
      fadeOut: 700,
      mirror: true,
      glyph: '🔥',
    );
    final j = e.toJson();
    expect(j['shapes'], ['strip', 'circle', 'triangle', 'squiggle', 'emoji']);
    expect(j['glyph'], '🔥');
    expect(j['mirror'], true);
    expect(ParticleEmitter.fromJson(j), e);
    // Defaults keep old JSON as it was.
    expect(const ParticleEmitter().toJson(), isEmpty);
    // An unknown shape is skipped, not misread.
    expect(ParticleEmitter.fromJson({'shapes': ['circle', 'hexagon']})!.shapes, [ParticleShape.circle]);
  });

  test('a masonry grid can place items in the shortest lane', () {
    expect(GridViewProps.masonryPlacement.defaultValue, MasonryPlacement.cycle);
    expect(GridViewProps.spec.props, contains(GridViewProps.masonryPlacement));
  });

  test('a fill with an image and no type is an image paint, tiled as it says', () {
    final p = Paint.fromJson({'image': {'url': 'https://x/dot.png', 'repeat': 'repeat', 'fit': 'none', 'scale': 2}})!;
    expect(p.type, PaintType.image);
    expect(p.image!.repeat, ImageRepeat.repeat);
    expect(Paint.fromJson({'color': '#FFFFFFFF'})!.type, PaintType.solid);
  });

  test('a motion can time its rotation and its fade on their own', () {
    // The legacy rotateCurve and fadeShare: a transition of the rotation on
    // its own curve, the opacity in the first share, easing out.
    final b = Behaviors.fromJson({
      'motion': {'duration': 600, 'rotateCurve': 'elasticOut', 'fadeShare': 0.35, 'opacity': 0.5},
    });
    expect(Transition.of(b.transitions, 'motion.rotate')!.curve, AnimationCurve.elasticOut);
    expect(Transition.of(b.transitions, 'motion.scale')!.curve, AnimationCurve.easeInOut);
    final fade = Transition.of(b.transitions, 'opacity')!;
    expect((fade.duration, fade.curve), (210, AnimationCurve.easeOut));
    // In an entrance: that track's curve and interval.
    final enter = Behaviors.fromJson({
      'motion': {'duration': 600, 'rotateCurve': 'elasticOut', 'fadeShare': 0.35, 'enterFrom': {'rotate': 8, 'opacity': 0}},
    }).animations.single.expanded;
    expect(enter.curve, AnimationCurve.linear);
    final rotate = enter.tracks.firstWhere((t) => t.id == 'rotate'), opacity = enter.tracks.firstWhere((t) => t.id == 'opacity');
    expect(rotate.curve, AnimationCurve.elasticOut);
    expect(opacity.interval, [0, 0.35]);
    expect(opacity.curve, AnimationCurve.easeOut);
    expect(Behaviors.fromJson({'motion': {'duration': 600}}).transitions.single.toJson(),
        {'property': 'motion', 'duration': 600, 'curve': 'easeInOut'});
  });

  test('overshoot is the web ease-out-back, past easeOutBack', () {
    expect(AnimationCurve.parse('overshoot'), AnimationCurve.overshoot);
    final peak = [for (var i = 1; i < 100; i++) AnimationCurve.overshoot.transform(i / 100)].reduce(math.max);
    final back = [for (var i = 1; i < 100; i++) AnimationCurve.easeOutBack.transform(i / 100)].reduce(math.max);
    expect(peak, greaterThan(back));
    expect(peak, closeTo(1.1, 0.01));
    expect(AnimationCurve.overshoot.transform(1), 1);
  });
}
