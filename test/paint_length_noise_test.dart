// A gradient with a length in pixels (CSS repeating-linear-gradient(...,
// 80px)) and the noise paint (SVG feTurbulence): decode, round trip, and
// validation of their declared shapes.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

void main() {
  test('length round-trips; a non-positive one is unset', () {
    final p = Paint.fromJson({'type': 'linear', 'begin': 'topCenter', 'end': 'bottomCenter', 'length': 80, 'tileMode': 'repeated',
      'stops': [{'position': 0, 'color': '#FF000000'}, {'position': 1, 'color': '#00000000'}]})!;
    expect(p.length, 80);
    expect(Paint.fromJson(p.toJson()), p);
    expect(Paint.fromJson({'type': 'linear', 'length': 0})!.length, isNull);
  });

  test('a noise paint: feTurbulence parameters, defaults, type inferred from "noise"', () {
    final p = Paint.fromJson({'noise': {'baseFrequency': 0.9, 'numOctaves': 2, 'seed': 7, 'type': 'turbulence'}, 'opacity': 0.08, 'blendMode': 'overlay'})!;
    expect(p.type, PaintType.noise);
    expect(p.noise, const NoisePaint(baseFrequency: 0.9, numOctaves: 2, seed: 7, type: NoiseType.turbulence));
    expect(p.isGradient, isFalse);
    expect(Paint.fromJson(p.toJson()), p);
    expect(Paint.fromJson({'type': 'noise'})!.noise, const NoisePaint());
    expect(Paint.fromJson({'type': 'noise', 'noise': {'numOctaves': 40}})!.noise!.numOctaves, 8);
  });

  test('validation reads both as declared', () {
    Json doc(Json paint) => {
          'schema': 3,
          'roots': ['c'],
          'nodes': {
            'c': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'b'}},
            'b': {'type': 'box', 'layout': {'width': {'fill': 390}, 'height': {'fill': 844}}, 'decoration': {'fills': [paint]}},
          },
        };
    expect(validateDocument(doc({'type': 'noise', 'noise': {'baseFrequency': 0.8, 'seed': 3}, 'color': '#FF000000', 'opacity': 0.1})), isEmpty);
    expect(validateDocument(doc({'type': 'linear', 'length': 80, 'tileMode': 'repeated', 'begin': 'topCenter', 'end': 'bottomCenter',
      'stops': [{'position': 0, 'color': '#FF000000'}, {'position': 1, 'color': '#00000000'}]})), isEmpty);
    expect(validateDocument(doc({'type': 'noise', 'noise': {'baseFrequncy': 0.8}})).map((d) => d.code.name), ['unknown_field']);
  });
}
