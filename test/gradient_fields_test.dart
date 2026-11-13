// Gradient fields as Flutter names them: begin/end (LinearGradient),
// center/radius (RadialGradient), declared, validated and read; a
// transform that collapses the box is reported.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

Json doc(Json paint) => {
      'schema': 3,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'b'}},
        'b': {'type': 'box', 'layout': {'width': 100, 'height': 100}, 'decoration': {'fills': [paint]}},
      },
    };

List<String> codes(Json d) => [for (final x in validateDocument(d)) '${x.code.name} ${x.path}'];

void main() {
  const stops = [
    {'position': 0, 'color': '#FFFF0000'},
    {'position': 1, 'color': '#00FF0000'},
  ];
  test('a gradient\'s begin, end, center and radius validate', () {
    expect(codes(doc({'type': 'linear', 'begin': [-1, 0], 'end': [-0.9, 0], 'tileMode': 'repeated', 'stops': stops})), isEmpty);
    expect(codes(doc({'type': 'radial', 'center': 'topCenter', 'radius': 0.8, 'stops': stops})), isEmpty);
  });
  test('a gradient\'s center is read into its transform', () {
    final p = Paint.fromJson({'type': 'radial', 'center': [0, -1], 'stops': stops})!;
    // u = x + 0.5 - 0.5, v = y + 0.5 - 0: the top edge's middle maps to (0.5, 0.5).
    expect(p.transform, [1, 0, 0, 0, 1, 0.5]);
  });
  test('a transform that collapses the box is out_of_range, with the matrix explained', () {
    final c = validateDocument(doc({'type': 'linear', 'transform': [0.05, 0, 0, 1, 0, 0], 'tileMode': 'repeated', 'stops': stops}));
    expect(c.map((d) => '${d.code.name} ${d.path}'), ['out_of_range /nodes/b/decoration/fills/0/transform']);
    expect(c.single.message, contains('[20, 0, 0, 0, 1, 0]'));
  });
}
