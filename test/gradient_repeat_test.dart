import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final PaintModel stripes = PaintModel.linearGradient(
    id: 'p',
    gradientStops: const [
      ColorStop(position: 0, color: ColorRGBA(r: 1, g: 0.76, b: 0.05, a: 1)),
      ColorStop(position: 0.5, color: ColorRGBA(r: 1, g: 0.76, b: 0.05, a: 1)),
      ColorStop(position: 0.5, color: ColorRGBA.black),
      ColorStop(position: 1, color: ColorRGBA.black),
    ],
    gradientRepeatEvery: 16,
  );

  test('gradientRepeatEvery survives JSON, copies and sanitizing', () {
    final PaintModel decoded = PaintModel.fromJson(stripes.toJson());
    expect(decoded.gradientRepeatEvery, 16);
    expect(stripes.sanitize().gradientRepeatEvery, 16);
    expect(stripes.copyWith(opacity: 0.5).gradientRepeatEvery, 16);
    expect(
      stripes.copyWith(clearGradientRepeat: true).gradientRepeatEvery,
      isNull,
    );
  });

  test('a stretched gradient omits it from JSON', () {
    expect(
      PaintModel.linearPaint.toJson().containsKey('gradientRepeatEvery'),
      isFalse,
    );
    expect(stripes.toJson()['gradientRepeatEvery'], 16);
  });
}
