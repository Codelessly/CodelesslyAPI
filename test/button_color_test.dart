import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

ButtonProperties roundTrip(ButtonProperties properties) =>
    ButtonProperties.fromJson(jsonDecode(jsonEncode(properties.toJson())));

void main() {
  group('ButtonProperties.buttonColor', () {
    test('is unset by default and left out of the JSON', () {
      final properties = ButtonProperties();
      expect(properties.buttonColor, isNull);
      expect(properties.toJson().containsKey('buttonColor'), isFalse);
      expect(roundTrip(properties).buttonColor, isNull);
    });

    test('keeps an explicit black', () {
      final properties = ButtonProperties(buttonColor: ColorRGBA.black);
      expect(properties.toJson()['buttonColor'], ColorRGBA.black.toJson());
      expect(roundTrip(properties).buttonColor, ColorRGBA.black);
    });

    test('reads old JSON: a missing key is unset, a written color is kept', () {
      final Map<String, dynamic> json = ButtonProperties(
        buttonType: ButtonTypeEnum.text,
      ).toJson();
      expect(ButtonProperties.fromJson(json).buttonColor, isNull);
      for (final ColorRGBA color in [
        ColorRGBA.black,
        const ColorRGBA(r: 0.2, g: 0.4, b: 0.8, a: 1),
      ]) {
        expect(
          ButtonProperties.fromJson({...json, 'buttonColor': color.toJson()})
              .buttonColor,
          color,
        );
      }
    });

    test('can be set and cleared through its field', () {
      final properties = ButtonProperties();
      final field = properties.fields['buttonColor']!;
      field.setValue(ColorRGBA.black);
      expect(properties.buttonColor, ColorRGBA.black);
      field.setValue(null);
      expect(properties.buttonColor, isNull);
    });
  });
}
