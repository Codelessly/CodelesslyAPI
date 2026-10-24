import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('an image paint keeps its saturation through JSON', () {
    final paint = PaintModel.image(
      id: 'plate',
      downloadUrl: 'https://example.com/star.png',
      fit: Fit.cover,
      sourceWidth: 100,
      sourceHeight: 100,
      saturation: 0,
    );
    final json = paint.toJson();
    expect(json['saturation'], 0);
    expect(PaintModel.fromJson(json).saturation, 0);
    expect(paint.isEquivalentTo(paint.copyWith(saturation: 1)), isFalse);
  });

  test('full saturation is the default and is left out', () {
    final paint = PaintModel.fromJson({'id': 'a', 'type': 'solid'});
    expect(paint.saturation, 1);
    expect(paint.toJson().containsKey('saturation'), isFalse);
  });
}
