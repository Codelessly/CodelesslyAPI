import 'package:codelessly_api/codelessly_api.dart';
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
    expect(StyleSheet.isCurrentSchema(json), isTrue);
    expect(sheet.textStyles.map((s) => s.name), ['Body', 'Heading']);
    expect(sheet.toJson()['owner'], 'u');
    expect(StyleSheet.fromJson(sheet.toJson()).toJson(), sheet.toJson());
    final theme = sheet.theme;
    expect(theme.primary, const Color(0xFF2F6BFF));
    expect(theme.onPrimary!.alpha, 128);
    expect(theme.fontFamily, 'Inter');
    expect(theme.titleFontFamily, 'Poppins');
  });

  test('a color style can have a dark paint; the theme carries every style by key and the dark colors', () {
    final json = {
      'schema': 2,
      'textStyles': [
        {'id': 't1', 'name': 'Title / Large', 'style': {'fontFamily': 'Inter', 'fontSize': 28}},
      ],
      'colorStyles': [
        {'id': 'c1', 'name': 'Surface', 'paint': {'color': '#FFFFFFFF'}, 'dark': {'color': '#FF121212'}},
        {'id': 'c2', 'name': 'Brand Blue', 'paint': {'color': '#FF2F6BFF'}},
        {'id': 'c3', 'name': 'Muted text', 'paint': {'color': '#FF666666'}, 'dark': {'color': '#FFAAAAAA'}},
      ],
    };
    final sheet = StyleSheet.fromJson(json);
    expect(StyleSheet.fromJson(sheet.toJson()).toJson(), sheet.toJson());
    expect(sheet.colorStyles.first.darkColor, const Color(0xFF121212));
    expect(sheet.colorStyles[1].toJson().containsKey('dark'), isFalse, reason: 'no dark paint, no key');

    final theme = sheet.theme;
    expect(theme.surface, const Color(0xFFFFFFFF));
    expect(theme.colors, {
      'surface': const Color(0xFFFFFFFF),
      'brandBlue': const Color(0xFF2F6BFF),
      'mutedText': const Color(0xFF666666),
    });
    expect(theme.textStyles['titleLarge']!.fontSize, 28);
    expect(theme.hasDark, isTrue);
    expect(theme.dark!.surface, const Color(0xFF121212));
    expect(theme.dark!.colors, {'surface': const Color(0xFF121212), 'mutedText': const Color(0xFFAAAAAA)});

    final dark = theme.forBrightness(dark: true);
    expect(dark.surface, const Color(0xFF121212));
    expect(dark.colors['brandBlue'], const Color(0xFF2F6BFF), reason: 'no dark value: the light one');
    expect(dark.colors['mutedText'], const Color(0xFFAAAAAA));
    expect(identical(theme.forBrightness(dark: false), theme), isTrue);

    expect(ThemeTokens.fromJson(theme.toJson()), theme);
    expect(theme.toJson()['dark'], {
      'surface': '#FF121212',
      'colors': {'surface': '#FF121212', 'mutedText': '#FFAAAAAA'},
    });
  });

  test('old themes and color styles read and write as before', () {
    const old = {'primary': '#FF2F6BFF', 'radius': 12};
    expect(ThemeTokens.fromJson(old).toJson(), old);
    const style = {'id': 'c1', 'name': 'Primary', 'paint': {'color': '#FF2F6BFF'}};
    expect(NamedColorStyle.fromJson(style)!.toJson(), {...style, 'paint': NamedColorStyle.fromJson(style)!.paint.toJson()});
    expect(NamedColorStyle.fromJson(style)!.dark, isNull);
    expect(ThemeTokens.fromJson(old).forBrightness(dark: true).primary, const Color(0xFF2F6BFF));
  });

  test('theme keys', () {
    expect(ThemeTokens.themeKey('On Primary'), 'onPrimary');
    expect(ThemeTokens.themeKey('Brand Blue 500'), 'brandBlue500');
    expect(ThemeTokens.themeKey('H1'), 'h1');
    expect(ThemeTokens.themeKey('brandBlue'), 'brandBlue');
    expect(ThemeTokens.themeKey('UI accent'), 'uiAccent');
    expect(ThemeTokens.themeKey(' / '), '');
  });
}
