import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('Empty text variables', () {
    test('a text variable created with "" keeps "" as its value', () {
      final variable = VariableData(id: 'a', name: 'x', value: '');
      expect(variable.value, '');
      expect(variable.getValue(), '');
    });

    test('"" survives a JSON round trip', () {
      final variable = VariableData(id: 'a', name: 'x', value: '');
      final decoded = VariableData.fromJson(
        jsonDecode(jsonEncode(variable.toJson())),
      );
      expect(decoded.value, '');
      expect(decoded.getValue(), '');
    });

    test('copyWith to "" keeps an empty string', () {
      final variable = VariableData(id: 'a', name: 'x', value: 'hi');
      expect(variable.copyWith(value: '').getValue(), '');
    });

    test('a null value is stored as "" rather than "null"', () {
      final variable = VariableData(id: 'a', name: 'x', value: null);
      expect(variable.value, '');
      expect(variable.getValue(), '');
      final number = VariableData(
        id: 'b',
        name: 'n',
        value: 'abc',
        type: VariableType.integer,
      );
      expect(number.value, '');
      expect(number.getValue(), isNull);
    });

    test('an empty image variable still has no value', () {
      final variable = VariableData(
        id: 'a',
        name: 'img',
        value: '',
        type: VariableType.image,
      );
      expect(variable.getValue(), isNull);
    });
  });
}
