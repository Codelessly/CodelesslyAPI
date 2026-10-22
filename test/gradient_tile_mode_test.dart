import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a repeating gradient round trips through JSON', () {
    final PaintModel paint = PaintModel.linearGradient(
      id: 'stripes',
      gradientTransform: const [0.7071, 0.7071, 0, -0.7071, 0.7071, 0],
      gradientStops: const [
        ColorStop(color: ColorRGBA(r: 1, g: 0.8, b: 0, a: 1), position: 0),
        ColorStop(color: ColorRGBA(r: 1, g: 0.8, b: 0, a: 1), position: 0.5),
        ColorStop(color: ColorRGBA.black, position: 0.5),
        ColorStop(color: ColorRGBA.black, position: 1),
      ],
      tileMode: GradientTileMode.repeated,
      gradientExtent: 20,
    );

    final Map json = jsonDecode(jsonEncode(paint.toJson()));
    expect(json['tileMode'], 'repeated');
    expect(json['gradientExtent'], 20);

    final PaintModel decoded = PaintModel.fromJson(json);
    expect(decoded, paint);
    expect(decoded.sanitize(), paint);
  });

  test('a gradient without tile settings clamps and omits them', () {
    final Map<String, dynamic> json = {
      'id': 'g',
      'type': 'gradientLinear',
      'gradientStops': [
        {'color': '#FF000000', 'position': 0},
        {'color': '#FFFFFFFF', 'position': 1},
      ],
    };
    final PaintModel paint = PaintModel.fromJson(json);
    expect(paint.tileMode, GradientTileMode.clamp);
    expect(paint.gradientExtent, isNull);
    expect(paint.toJson().containsKey('tileMode'), isFalse);
    expect(paint.toJson().containsKey('gradientExtent'), isFalse);
  });

  test('an unknown tile mode falls back to clamp', () {
    final PaintModel paint = PaintModel.fromJson({
      'id': 'g',
      'type': 'gradientLinear',
      'tileMode': 'decal',
    });
    expect(paint.tileMode, GradientTileMode.clamp);
  });

  test('copyWith can clear the gradient extent', () {
    final PaintModel paint = PaintModel.linearPaint.copyWith(
      gradientExtent: 12,
    );
    expect(paint.gradientExtent, 12);
    expect(paint.copyWith().gradientExtent, 12);
    expect(paint.copyWith(clearGradientExtent: true).gradientExtent, isNull);
  });
}
