import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('theme tokens round-trip and leave out what is unset', () {
    const ThemeTokens tokens = ThemeTokens(
      primary: ColorRGBA(r: 0, g: 0.4, b: 1, a: 1),
      fontFamily: 'Inter',
      buttonRadius: 12,
    );
    final Map json = jsonDecode(jsonEncode(tokens.toJson())) as Map;
    expect(
      json.keys,
      unorderedEquals(['primary', 'fontFamily', 'buttonRadius']),
    );
    expect(ThemeTokens.fromJson(json), tokens);
    expect(const ThemeTokens().isEmpty, isTrue);
    expect(tokens.isEmpty, isFalse);
  });
}
