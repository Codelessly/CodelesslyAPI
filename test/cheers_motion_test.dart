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
}
