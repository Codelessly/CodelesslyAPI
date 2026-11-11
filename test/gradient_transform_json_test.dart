import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A gradient's transform is a 2x3 affine matrix; JSON may give it as rows
/// (`[[a, b, c], [d, e, f]]`) or flat (`[a, b, c, d, e, f]`, as stored).
/// Rows threw "'List<dynamic>' is not a subtype of type 'num'" wherever a
/// paint was read outside the node shorthands (states, text styles).
void main() {
  Map<String, dynamic> gradient(Object transform) => {
    'id': 'g',
    'type': 'gradientLinear',
    'gradientTransform': transform,
    'gradientStops': [
      {'position': 0, 'color': '#000000'},
      {'position': 1, 'color': '#FFFFFF'},
    ],
  };

  test('rows and the flat list read the same', () {
    final PaintModel rows = PaintModel.fromJson(
      gradient([
        [0, 1, 0],
        [-1, 0, 1],
      ]),
    );
    final PaintModel flat = PaintModel.fromJson(gradient([0, 1, 0, -1, 0, 1]));
    expect(rows.gradientTransform, [0, 1, 0, -1, 0, 1]);
    expect(flat.gradientTransform, rows.gradientTransform);
    expect(rows.toJson()['gradientTransform'], [0, 1, 0, -1, 0, 1]);
  });

  test('rows inside a text style read too', () {
    final TextProp prop = TextProp.fromJson({
      'start': 0,
      'end': 4,
      'fills': [
        gradient([
          [1, 0, 0],
          [0, 1, 0],
        ]),
      ],
    });
    expect(prop.fills.single.gradientTransform, [1, 0, 0, 0, 1, 0]);
  });
}
