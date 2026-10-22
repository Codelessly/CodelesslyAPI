import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('CornerRadius.fromJson', () {
    test('a bare number is a circular radius on every corner', () {
      final CornerRadius r = CornerRadius.fromJson(4);
      expect(r, CornerRadius.all(RadiusModel.circular(4), linked: true));
      expect(CornerRadius.fromJson(2.5).tl, RadiusModel.circular(2.5));
    });

    test('a node accepts a numeric cornerRadius', () {
      final node = RectangleNode.fromJson({
        'id': 'r',
        'name': 'Card',
        'type': 'rectangle',
        'basicBoxLocal': [0, 0, 100, 50],
        'cornerRadius': 6,
      });
      expect(node.cornerRadius.br, RadiusModel.circular(6));
    });

    test('the compact and map forms still decode', () {
      expect(CornerRadius.fromJson([8, false, 'circular']).tl,
          RadiusModel.circular(8));
      expect(
        CornerRadius.fromJson({
          'tl': {'x': 1, 'y': 1},
          'tr': {'x': 2, 'y': 2},
          'bl': {'x': 3, 'y': 3},
          'br': {'x': 4, 'y': 4},
        }).br,
        RadiusModel.circular(4),
      );
    });
  });
}
