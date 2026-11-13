// What makes a site look like itself, as data: its theme mode (Flutter's
// ThemeMode, set by a setThemeMode action), the fonts it ships beside
// site.json (a pubspec's fonts: section) and how they publish.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

void main() {
  group('theme mode', () {
    test('a theme starts in system mode and keeps a light or dark mode it is given', () {
      expect(ThemeTokens.fromJson({'colors': {'ink': '#FF111111'}}).mode, ThemeMode.system);
      final dark = ThemeTokens.fromJson({'mode': 'dark', 'colors': {'ink': '#FF111111'}});
      expect(dark.mode, ThemeMode.dark);
      expect(dark.toJson()['mode'], 'dark');
      expect(ThemeTokens.fromJson(dark.toJson()), dark);
      // The dark colors keep the site's mode.
      expect(dark.forBrightness(dark: true).mode, ThemeMode.dark);
    });

    test('system mode follows the device and light or dark ignore it', () {
      expect(ThemeMode.system.isDark(platformDark: true), isTrue);
      expect(ThemeMode.system.isDark(platformDark: false), isFalse);
      expect(ThemeMode.light.isDark(platformDark: true), isFalse);
      expect(ThemeMode.dark.isDark(platformDark: false), isTrue);
      expect(ThemeMode.tryParse(' Dark '), ThemeMode.dark);
      expect(ThemeMode.tryParse('night'), isNull);
    });

    test('a theme mode that is not system, light or dark is reported with the nearest one', () {
      final d = validateTheme({'mode': 'darkk'});
      expect(d.single.code.name, 'invalid_theme');
      expect(d.single.suggestion, 'dark');
      expect(validateTheme({'mode': 'light'}), isEmpty);
    });

    test('a mode inside the dark colors is reported: the mode belongs to the whole theme', () {
      final d = validateTheme({'dark': {'mode': 'dark'}});
      expect(d.single.code.name, 'invalid_theme');
      expect(d.single.path, '/theme/dark/mode');
    });

    test('setThemeMode reads its mode as an expression and persists unless told not to', () {
      final a = ActionDef.fromJson({'type': 'setThemeMode', 'mode': r"${= theme.isDark ? 'light' : 'dark'}"});
      expect(a, isA<SetThemeModeAction>());
      final set = a! as SetThemeModeAction;
      expect(set.mode, r"${= theme.isDark ? 'light' : 'dark'}");
      expect(set.persist, isTrue);
      final once = ActionDef.fromJson({'type': 'setThemeMode', 'mode': 'light', 'persist': false})! as SetThemeModeAction;
      expect(once.persist, isFalse);
      expect(once.toJson(), {'type': 'setThemeMode', 'mode': 'light', 'persist': false});
    });

    test('a page whose button sets the theme mode validates, and a misspelt key is named', () {
      Json page(Json action) => {
            'schema': 3,
            'roots': ['home'],
            'nodes': {
              'home': {'type': 'canvas', 'slots': {'body': 'toggle'}, 'layout': {'width': 390, 'height': 844}},
              'toggle': {
                'type': 'box',
                'layout': {'width': 44, 'height': 44},
                'actions': [
                  {'trigger': {'type': 'click'}, 'actions': [action]},
                ],
              },
            },
          };
      expect(validateDocument(page({'type': 'setThemeMode', 'mode': 'dark'})).where((d) => d.isError), isEmpty);
      final bad = validateDocument(page({'type': 'setThemeMode', 'themeMode': 'dark'}));
      expect(bad.map((d) => d.code.name), contains('unknown_action_key'));
    });
  });

  group('site fonts', () {
    final manifest = {
      'schema': 3,
      'pages': ['home.json'],
      'fonts': [
        {
          'family': 'Fraunces',
          'fonts': [
            {'asset': 'fonts/Fraunces-Regular.ttf'},
            {'asset': 'fonts/Fraunces-Bold.woff', 'weight': 700},
            {'asset': 'fonts/Fraunces-Italic.otf', 'style': 'italic'},
          ],
        },
      ],
    };

    test('a site declares its font families in the shape of a pubspec fonts section', () {
      final site = SiteManifest.fromJson(manifest);
      expect(site.fonts.single.family, 'Fraunces');
      expect([for (final f in site.fonts.single.fonts) (f.asset, f.weight, f.italic)], [
        ('fonts/Fraunces-Regular.ttf', 400, false),
        ('fonts/Fraunces-Bold.woff', 700, false),
        ('fonts/Fraunces-Italic.otf', 400, true),
      ]);
      expect(site.extra.containsKey('fonts'), isFalse);
      expect(SiteManifest.fromJson(site.toJson()).fonts, site.fonts);
      expect(validateSiteFonts(manifest['fonts']), isEmpty);
    });

    test('declared fonts publish one font per file, read from the site by relative path', () {
      final fonts = PublishFont.ofFamilies(SiteManifest.fromJson(manifest).fonts);
      expect(fonts.map((f) => f.id), ['Fraunces/400/false', 'Fraunces/700/false', 'Fraunces/400/true']);
      expect(fonts[1].url, 'fonts/Fraunces-Bold.woff');
      expect(fonts.every((f) => f.isSiteFile), isTrue);
      expect(const PublishFont(id: 'x', family: 'X', url: 'https://cdn.example.com/x.ttf').isSiteFile, isFalse);
    });

    test('a WOFF2 file is reported as not read, naming the .woff or .ttf to use instead', () {
      final d = validateSiteFonts([
        {
          'family': 'Inter',
          'fonts': [
            {'asset': 'fonts/inter-latin-400.woff2'},
          ],
        },
      ]);
      expect(d.single.code.name, 'font_format');
      expect(d.single.path, '/fonts/0/fonts/0/asset');
      expect(d.single.message, contains('WOFF2'));
      expect(d.single.message, contains('.woff or .ttf'));
    });

    test('a family without files, a bad weight and an unknown key are each reported', () {
      final d = validateSiteFonts([
        {'family': 'Inter'},
        {
          'family': 'Lora',
          'fonts': [
            {'asset': 'fonts/Lora.ttf', 'weight': 450, 'syle': 'italic'},
          ],
        },
        {'fonts': []},
      ]);
      expect(d.map((x) => x.path), containsAll(['/fonts/0/fonts', '/fonts/1/fonts/0/weight', '/fonts/1/fonts/0/syle', '/fonts/2']));
      expect(d.firstWhere((x) => x.path.endsWith('syle')).suggestion, 'style');
    });

    test('a font named by URL or absolute path is not a file beside the site', () {
      expect(isRelativeAssetPath('fonts/a.ttf'), isTrue);
      expect(isRelativeAssetPath('./images/hero.jpg'), isTrue);
      expect(isRelativeAssetPath('https://x.com/a.ttf'), isFalse);
      expect(isRelativeAssetPath('data:image/png;base64,AAAA'), isFalse);
      expect(isRelativeAssetPath('/abs/a.png'), isFalse);
      expect(isRelativeAssetPath(r'images/${id}.jpg'), isFalse);
      expect(validateSiteFonts([
        {
          'family': 'X',
          'fonts': [
            {'asset': 'https://x.com/x.ttf'},
          ],
        },
      ]).single.code.name, 'invalid_fonts');
    });
  });
}
