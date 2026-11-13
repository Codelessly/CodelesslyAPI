import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a style sheet round-trips, keeps unknown keys and gives each theme by name', () {
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

  test('a color style with a dark paint gives the dark theme its color', () {
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

  test('themes and color styles saved by older versions read and write unchanged', () {
    const old = {'primary': '#FF2F6BFF', 'radius': 12};
    expect(ThemeTokens.fromJson(old).toJson(), old);
    const style = {'id': 'c1', 'name': 'Primary', 'paint': {'color': '#FF2F6BFF'}};
    expect(NamedColorStyle.fromJson(style)!.toJson(), {...style, 'paint': NamedColorStyle.fromJson(style)!.paint.toJson()});
    expect(NamedColorStyle.fromJson(style)!.dark, isNull);
    expect(ThemeTokens.fromJson(old).forBrightness(dark: true).primary, const Color(0xFF2F6BFF));
  });

  test('a style sheet saved with schema 2\'s natural line height keeps it unread, and the migration drops and reports it', () {
    final sheet = StyleSheet.fromJson({'schema': 2, 'naturalLineHeight': true});
    expect(sheet.extra['naturalLineHeight'], isTrue);
    expect(sheet.theme, ThemeTokens.fromJson(sheet.theme.toJson()));
    expect(ThemeTokens.fromJson({'naturalLineHeight': true}), ThemeTokens.none);
    final report = MigrationReport();
    final out = migrateJson2to3({'schema': 2, 'naturalLineHeight': true, 'textStyles': [
      {'id': 't', 'name': 'Title', 'style': {'fontSize': 20, 'naturalHeight': true}},
    ]}, report: report) as Map;
    expect(out.containsKey('naturalLineHeight'), isFalse);
    expect((((out['textStyles'] as List).single as Map)['style'] as Map), {'fontSize': 20});
    expect(report.behaviourChanges.map((e) => e.path), ['/naturalLineHeight', '/textStyles/0/style/naturalHeight']);
    final model = migratePublish2to3({'schema': 2, 'theme': {'naturalLineHeight': true, 'primary': '#FF000000'}}, report: report);
    expect(model['theme'], {'primary': '#FF000000'});
  });
}
