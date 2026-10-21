import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

TextFieldProperties roundTrip(TextFieldProperties properties) =>
    TextFieldProperties.fromJson(jsonDecode(jsonEncode(properties.toJson())));

void main() {
  group('TextFieldProperties.maxLines', () {
    test('default of 1 is left out and reads back as 1', () {
      final properties = TextFieldProperties();
      expect(properties.toJson().containsKey('maxLines'), isFalse);
      expect(roundTrip(properties).maxLines, 1);
    });

    test('null (unlimited) is written and survives a round trip', () {
      final properties = TextFieldProperties(maxLines: null, minLines: 3);
      final json = properties.toJson();
      expect(json.containsKey('maxLines'), isTrue);
      expect(json['maxLines'], isNull);

      final decoded = roundTrip(properties);
      expect(decoded.maxLines, isNull);
      expect(decoded.minLines, 3);
    });

    test('other values survive a round trip', () {
      expect(roundTrip(TextFieldProperties(maxLines: 5)).maxLines, 5);
    });

    test('stored designs without the key keep reading as 1', () {
      expect(TextFieldProperties.fromJson({}).maxLines, 1);
      expect(TextFieldProperties.fromJson({'minLines': 3}).maxLines, 1);
      expect(TextFieldProperties.fromJson({'maxLines': 4.0}).maxLines, 4);
    });

    test('an explicit null in stored JSON reads as unlimited', () {
      expect(TextFieldProperties.fromJson({'maxLines': null}).maxLines, isNull);
    });
  });
}
