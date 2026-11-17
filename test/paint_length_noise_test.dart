// A gradient with a length in pixels (CSS repeating-linear-gradient(...,
// 80px)) and the noise paint (SVG feTurbulence): decode and round trip.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {

  test('a noise paint: feTurbulence parameters, defaults, type inferred from "noise"', () {
    final p = Paint.fromJson({'noise': {'baseFrequency': 0.9, 'numOctaves': 2, 'seed': 7, 'type': 'turbulence'}, 'opacity': 0.08, 'blendMode': 'overlay'})!;
    expect(p.type, PaintType.noise);
    expect(p.noise, const NoisePaint(baseFrequency: 0.9, numOctaves: 2, seed: 7, type: NoiseType.turbulence));
    expect(p.isGradient, isFalse);
    expect(Paint.fromJson(p.toJson()), p);
    expect(Paint.fromJson({'type': 'noise'})!.noise, const NoisePaint());
    expect(Paint.fromJson({'type': 'noise', 'noise': {'numOctaves': 40}})!.noise!.numOctaves, 8);
  });
}
