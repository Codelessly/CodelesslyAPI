import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('A value bound to a fill', () {
    test('an image link becomes an image that covers the node', () {
      final PaintModel? paint = 'https://example.com/a.png'
          .typedValue<PaintModel>();
      expect(paint?.type, PaintType.image);
      expect(paint?.downloadUrl, 'https://example.com/a.png');
      expect(paint?.fit, Fit.cover);
    });

    test('a data URL is an image too', () {
      expect(
        'data:image/png;base64,AAAA'.typedValue<PaintModel>()?.type,
        PaintType.image,
      );
    });

    test('a hex color is a solid paint', () {
      final PaintModel? paint = '#FF0000'.typedValue<PaintModel>();
      expect(paint?.type, PaintType.solid);
      expect(paint?.color?.r, 1);
    });

    test('a paint as JSON is that paint', () {
      final PaintModel solid = ColorRGBA.fromHex('#00FF00')!.toPaint('p');
      expect(solid.toJson().typedValue<PaintModel>(), solid);
    });

    test('anything else is no paint', () {
      expect('hello'.typedValue<PaintModel>(), isNull);
      expect(42.typedValue<PaintModel>(), isNull);
    });
  });
}
