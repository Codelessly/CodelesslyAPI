import 'package:codelessly_api_v2/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a style sheet round-trips, keeps unknown keys, and gives the theme by name', () {
    final json = {
      'schema': 2,
      'owner': 'u',
      'textStyles': [
        {'id': 't1', 'name': 'Body', 'style': {'fontFamily': 'Inter', 'fontSize': 14}},
        {'id': 't2', 'name': 'Heading', 'style': {'fontFamily': 'Poppins', 'fontWeight': 700}},
      ],
      'colorStyles': [
        {'id': 'c1', 'name': 'Primary', 'paint': {'color': '#FF2F6BFF'}},
        {'id': 'c2', 'name': 'On Primary', 'paint': {'color': '#FFFFFFFF', 'opacity': 0.5}},
      ],
      'defaultTextStyle': 't1',
    };
    final sheet = StyleSheet.fromJson(json);
    expect(StyleSheet.isV2(json), isTrue);
    expect(sheet.textStyles.map((s) => s.name), ['Body', 'Heading']);
    expect(sheet.toJson()['owner'], 'u');
    expect(StyleSheet.fromJson(sheet.toJson()).toJson(), sheet.toJson());
    final theme = sheet.theme;
    expect(theme.primary, Color(0xFF2F6BFF));
    expect(theme.onPrimary!.alpha, 128);
    expect(theme.fontFamily, 'Inter');
    expect(theme.titleFontFamily, 'Poppins');
  });
}
