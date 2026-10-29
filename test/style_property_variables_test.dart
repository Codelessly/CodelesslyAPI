import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('A shape offers its effects, stroke weight and corner radius to set '
      'value actions', () {
    final RectangleNode node = RectangleNode(
      id: 'chip',
      name: 'Chip',
      basicBoxLocal: NodeBox(0, 0, 80, 32),
      strokeWeight: 2,
      cornerRadius: const CornerRadius.all(RadiusModel.circular(6)),
      effects: [
        Effect.dropShadow(
          id: 'shadow',
          visible: false,
          radius: 0,
          color: ColorRGBA.black,
          offset: const Vec(2, 2),
          spread: 0,
        ),
      ],
    );
    final Map<String, Object?> values = {
      for (final ValueModel value in node.propertyVariables)
        value.name: value.value,
    };
    expect(values['effectsVisible'], isFalse);
    expect(values['strokeWeight'], 2);
    expect(values['cornerRadius'], 6);
  });

  test('A text offers its font weight as a number', () {
    final TextNode node = TextNode(
      id: 'text',
      name: 'Text',
      basicBoxLocal: NodeBox(0, 0, 80, 20),
      data: 'Oat',
      textMixedProps: [
        StartEndProp(
          start: 0,
          end: 3,
          fontName: const FontName(
            family: 'Roboto',
            weight: FontWeightNumeric.w700,
          ),
        ),
      ],
    );
    final ValueModel weight = node.propertyVariables.firstWhere(
      (value) => value.name == 'fontWeight',
    );
    expect(weight.value, 700);
  });
}
