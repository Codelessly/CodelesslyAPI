import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a rectangular slider thumb round-trips; defaults stay out', () {
    final props = SliderProperties.fromJson({
      'thumbShape': 'rectangle',
      'thumbWidth': 18,
      'thumbHeight': 24,
      'thumbCornerRadius': 2,
      'thumbBorderColor': {'r': 0, 'g': 0, 'b': 0, 'a': 1},
      'thumbGripColor': {'r': 1, 'g': 1, 'b': 1, 'a': 1},
    });
    expect(props.thumbShape, SliderThumbShapeEnum.rectangle);
    expect(props.thumbCornerRadius, 2);
    expect(SliderProperties.fromJson(props.toJson()), props);
    final Map defaults = SliderProperties().toJson();
    for (final key in ['thumbShape', 'thumbWidth', 'thumbGripColor']) {
      expect(defaults.containsKey(key), isFalse, reason: key);
    }
  });
}
