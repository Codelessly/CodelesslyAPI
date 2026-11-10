import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('thumb glow and active track fade round-trip', () {
    final props = SliderProperties.fromJson({
      'thumbGlowColor': {'r': 0.4, 'g': 0.8, 'b': 1, 'a': 0.4},
      'thumbGlowBlur': 10,
      'thumbGlowSpread': 4,
      'activeTrackStartOpacity': 0.5,
    });
    expect(
      props.thumbGlowColor,
      const ColorRGBA(r: 0.4, g: 0.8, b: 1, a: 0.4),
    );
    expect(props.thumbGlowBlur, 10);
    expect(props.thumbGlowSpread, 4);
    expect(props.activeTrackStartOpacity, 0.5);
    final Map json = props.toJson();
    expect(json['activeTrackStartOpacity'], 0.5);
    expect(json['thumbGlowBlur'], 10);
    expect(SliderProperties.fromJson(json), props);
  });

  test('defaults keep today\'s slider and stay out of JSON', () {
    final props = SliderProperties();
    expect(props.thumbGlowColor, isNull);
    expect(props.thumbGlowBlur, kSliderDefaultThumbGlowBlur);
    expect(props.thumbGlowSpread, kSliderDefaultThumbGlowSpread);
    expect(props.activeTrackStartOpacity, 1);
    final Map json = props.toJson();
    for (final key in [
      'thumbGlowColor',
      'thumbGlowBlur',
      'thumbGlowSpread',
      'activeTrackStartOpacity',
    ]) {
      expect(json.containsKey(key), isFalse, reason: key);
    }
    expect(SliderProperties.fromJson(<String, dynamic>{}), props);
  });

  test('copyWith carries the new fields', () {
    final props = SliderProperties().copyWith(
      thumbGlowColor: ColorRGBA.white,
      thumbGlowBlur: 12,
      thumbGlowSpread: 3,
      activeTrackStartOpacity: 0.25,
    );
    expect(props.thumbGlowColor, ColorRGBA.white);
    expect(props.thumbGlowBlur, 12);
    expect(props.thumbGlowSpread, 3);
    expect(props.activeTrackStartOpacity, 0.25);
    expect(props.copyWith(), props);
  });

  test('glow colour, thumb colour and start opacity are settable values', () {
    final node = SliderNode.empty();
    final names = node.propertyVariables.map((v) => v.name).toSet();
    expect(
      names,
      containsAll(<String>[
        'activeTrackColor',
        'inactiveTrackColor',
        'thumbColor',
        'thumbGlowColor',
        'activeTrackStartOpacity',
      ]),
    );
  });
}
