import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('A radial gradient round-trips its radius and centre', () {
    final Map<String, dynamic> json = {
      'id': 'glow',
      'type': 'gradientRadial',
      'gradientStops': [
        {
          'position': 0,
          'color': {'r': 1, 'g': 1, 'b': 0, 'a': 1},
        },
        {
          'position': 1,
          'color': {'r': 1, 'g': 1, 'b': 0, 'a': 0},
        },
      ],
      'gradientRadius': 1.2,
      'gradientCenterX': 0.6,
      'gradientCenterY': -1,
    };
    final PaintModel paint = PaintModel.fromJson(json);
    expect(paint.gradientRadius, 1.2);
    expect(paint.gradientCenterX, 0.6);
    expect(paint.gradientCenterY, -1.0);
    final Map out = paint.toJson();
    expect(out['gradientRadius'], 1.2);
    expect(out['gradientCenterY'], -1.0);
    expect(PaintModel.fromJson(out), paint);
    expect(paint.sanitize(), paint);

    final RectangleNode node = RectangleNode.fromJson({
      'type': 'rectangle',
      'id': 'r',
      'name': 'Glow',
      'basicBoxLocal': [0, 0, 340, 214],
      'fills': [json],
    });
    final RectangleNode back = RectangleNode.fromJson(node.toJson());
    expect(back.fills.single.gradientRadius, 1.2);
    expect(back.fills.single.gradientCenterX, 0.6);
  });

  test('A paint without them omits them', () {
    final PaintModel paint = PaintModel.radialGradient(id: 'g');
    expect(paint.gradientRadius, 0.5);
    expect(paint.gradientCenterX, 0);
    final Map json = paint.toJson();
    expect(json.containsKey('gradientRadius'), isFalse);
    expect(json.containsKey('gradientCenterX'), isFalse);
    expect(paint.copyWith(gradientRadius: 0.8).isEquivalentTo(paint), isFalse);
    expect(
      paint
          .copyWith(gradientRadius: 0.8)
          .copyWith(clearGradientGeometry: true)
          .isEquivalentTo(paint),
      isTrue,
    );
  });

  test('A text field round-trips textCapitalization', () {
    final TextFieldNode node = TextFieldNode.fromJson({
      'type': 'textField',
      'id': 'ref',
      'name': 'Reference',
      'basicBoxLocal': [0, 0, 240, 48],
      'properties': {'textCapitalization': 'characters'},
      'variables': {'inputColor': r'${pal.ink}', 'hintColor': r'${pal.mute}'},
    });
    expect(node.properties.textCapitalization, TextCapitalizationC.characters);
    final TextFieldNode back = TextFieldNode.fromJson(node.toJson());
    expect(back.properties.textCapitalization, TextCapitalizationC.characters);
    expect(back.variables['inputColor'], r'${pal.ink}');
    expect(back.variables['hintColor'], r'${pal.mute}');
    expect(TextFieldProperties().textCapitalization, TextCapitalizationC.none);
    expect(
      TextFieldProperties()
          .copyWith(textCapitalization: TextCapitalizationC.words)
          .textCapitalization,
      TextCapitalizationC.words,
    );
  });
}
