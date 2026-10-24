import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  MaterialIcon read(String name, [String style = 'filled']) =>
      MaterialIcon.fromJson({
        'codepoint': 0xf2c7,
        'name': name,
        'style': style,
        'type': 'MATERIAL_ICON',
      });

  test('a style suffix in the name becomes the style', () {
    final MaterialIcon icon = read('precision_manufacturing_outlined');
    expect(icon.name, 'precision_manufacturing');
    expect(icon.style, MaterialIconStyle.outlined);
    expect(read('home_rounded').style, MaterialIconStyle.rounded);
    expect(read('home_sharp').style, MaterialIconStyle.sharp);
  });

  test('names without a style suffix stay as they are', () {
    final MaterialIcon icon = read('person_outline');
    expect(icon.name, 'person_outline');
    expect(icon.style, MaterialIconStyle.filled);
    expect(read('home_outlined', 'rounded').name, 'home_outlined');
  });
}
