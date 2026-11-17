// Gradient fields as Flutter names them: begin/end (LinearGradient),
// center/radius (RadialGradient), declared and read.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  const stops = [
    {'position': 0, 'color': '#FFFF0000'},
    {'position': 1, 'color': '#00FF0000'},
  ];
  test('a gradient\'s center is read into its transform', () {
    final p = Paint.fromJson({'type': 'radial', 'center': [0, -1], 'stops': stops})!;
    // u = x + 0.5 - 0.5, v = y + 0.5 - 0: the top edge's middle maps to (0.5, 0.5).
    expect(p.transform, [1, 0, 0, 0, 1, 0.5]);
  });
}
