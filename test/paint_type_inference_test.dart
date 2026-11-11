import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a paint without a type is an image when it has an image, a gradient when it has stops', () {
    final img = Paint.fromJson({'image': {'url': 'https://example.com/a.png', 'fit': 'fill'}})!;
    expect(img.type, PaintType.image);
    expect(img.image!.url, 'https://example.com/a.png');
    expect(img.image!.fit, BoxFit.fill);
    // The settings may sit beside the image (the form the editor API documents).
    final beside = Paint.fromJson({'image': {'url': 'u'}, 'fit': 'contain', 'repeat': 'repeat'})!;
    expect(beside.image!.fit, BoxFit.contain);
    expect(beside.image!.repeat, ImageRepeat.repeat);
    final grad = Paint.fromJson({
      'stops': [
        {'position': 0, 'color': '#FF000000'},
        {'position': 1, 'color': '#00000000'},
      ],
    })!;
    expect(grad.type, PaintType.linear);
    expect(Paint.fromJson({'color': '#FF112233'})!.type, PaintType.solid);
    // An explicit type still wins, and stored paints are unchanged.
    expect(Paint.fromJson({'type': 'radial', 'stops': grad.toJson()['stops']})!.type, PaintType.radial);
    expect(Paint.fromJson(img.toJson()), img);
  });
}
