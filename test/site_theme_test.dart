// A site's theme over a design system's tokens: what the design system
// makes from its accent follows the site's accent, light and dark.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation_site.dart';
import 'package:test/test.dart';

final _base = ThemeTokens.fromJson({
  'primary': '#FF2563EB',
  'surface': '#FFFFFFFF',
  'colors': {
    'accent': '#FF2563EB',
    'accentDeep': '#FF1D4ED8',
    'accentTint': '#FFF3F4F6',
    'activeTint': '#242563EB',
    'focusBorder': '#802563EB',
    'info': '#FF0891B2',
    'infoTint': '#1A0891B2',
    'skyA': '#FF38BDF8',
    'ink': '#FF111827',
  },
  'dark': {
    'primary': '#FF3B82F6',
    'surface': '#FF141414',
    'colors': {
      'accent': '#FF3B82F6',
      'accentDeep': '#FF60A5FA',
      'accentTint': '#FF262626',
      'activeTint': '#383B82F6',
      'focusBorder': '#803B82F6',
      'info': '#FF06B6D4',
      'infoTint': '#2906B6D4',
      'ink': '#FFFFFFFF',
    },
  },
});

String? _c(ThemeTokens t, String name, {bool dark = false}) => t.forBrightness(dark: dark).color(name)?.toJson();

void main() {
  test('a site that gives only its primary: the accent, its tints and the info color follow it', () {
    final t = _base.withSiteTheme(ThemeTokens.fromJson({'primary': '#FFB45309'}));
    expect(_c(t, 'primary'), '#FFB45309');
    expect(_c(t, 'accent'), '#FFB45309');
    expect(_c(t, 'activeTint'), '#24B45309', reason: 'a selected row: the accent at the opacity the design system gives it');
    expect(_c(t, 'focusBorder'), '#80B45309');
    expect(_c(t, 'info'), '#FFB45309');
    expect(_c(t, 'infoTint'), '#1AB45309');
    // What is not made from the accent stays.
    // A shade of the accent is in the site's hue, at its own lightness.
    final deep = t.color('accentDeep')!;
    expect(deep.red, greaterThan(deep.blue), reason: 'no longer blue: ${deep.toJson()}');
    expect(deep.alpha, 0xFF);
    expect(_c(t, 'accentTint'), '#FFF3F4F6');
    expect(_c(t, 'skyA'), '#FF38BDF8');
    expect(_c(t, 'ink'), '#FF111827');
  });

  test('the roles made from the accent under names of their own (Desk\'s focus border, a selected row) follow a site\'s primary', () {
    final desk = ThemeTokens.fromJson({
      'primary': '#FF4F46E5',
      'colors': {
        'accent': '#FF4F46E5',
        'focusBorder': '#FF818CF8',
        'selectedRow': '#FFF5F5FF',
        'selection': '#FFE0E7FF',
        'accentText': '#FF4338CA',
        'success': '#FF16A34A',
      },
    });
    final t = desk.withSiteTheme(ThemeTokens.fromJson({'primary': '#FF0D9488'}));
    // The text shade, a little darker than the indigo, is a little darker than the teal (it was a bright cyan at
    // the indigo's lightness); the selection, near white, stays near white.
    int sum(Color c) => c.red + c.green + c.blue;
    expect(sum(t.color('accentText')!), lessThan(sum(t.color('primary')!)), reason: t.color('accentText')!.toJson());
    expect(sum(t.color('selection')!), greaterThan(600), reason: t.color('selection')!.toJson());
    for (final name in ['focusBorder', 'selectedRow', 'selection']) {
      final c = t.color(name)!;
      expect(c.green, greaterThan(c.red), reason: '$name is teal now: ${c.toJson()}');
    }
    expect(_c(t, 'success'), '#FF16A34A', reason: 'another hue stays');
  });

  test('dark mode: an accent the design system gives apart from its dark primary follows the site\'s primary too (Desk)', () {
    // Desk's dark `accent` is a lighter indigo than its dark `primary`; under a site's green it stayed indigo (the
    // SideButton, the brand tile, the chosen view: support desk, test 11), with `dark.primary` named or not.
    final desk = ThemeTokens.fromJson({
      'primary': '#FF4F46E5',
      'colors': {'accent': '#FF4F46E5', 'success': '#FF16A34A'},
      'dark': {
        'primary': '#FF6D70F0',
        'colors': {'accent': '#FF7C7FF7', 'success': '#FF22C55E'},
      },
    });
    for (final site in [
      {'primary': '#FF16804A'},
      {'primary': '#FF16804A', 'dark': {'primary': '#FF34B26F'}},
    ]) {
      final dark = desk.withSiteTheme(ThemeTokens.fromJson(site)).forBrightness(dark: true);
      final accent = dark.color('accent')!;
      expect(accent.green, greaterThan(accent.blue), reason: 'green now: ${accent.toJson()} ($site)');
      expect(_c(dark, 'success'), '#FF22C55E', reason: 'another hue stays');
    }
    // A site that names the dark accent keeps its own.
    final own = desk.withSiteTheme(ThemeTokens.fromJson({
      'primary': '#FF16804A',
      'dark': {
        'colors': {'accent': '#FFFF0000'},
      },
    }));
    expect(_c(own.forBrightness(dark: true), 'accent'), '#FFFF0000');
  });

  test('dark mode: the accent is made from the override, not left the design system\'s blue', () {
    final t = _base.withSiteTheme(ThemeTokens.fromJson({
      'primary': '#FFB45309',
      'colors': {'accent': '#FFB45309', 'accentDeep': '#FF92400E'},
    }));
    final dark = _c(t, 'primary', dark: true)!;
    expect(dark, isNot('#FF3B82F6'));
    final c = t.forBrightness(dark: true).color('primary')!;
    expect([c.red, c.green, c.blue], [0xBF, 0x6D, 0x2E], reason: 'the site\'s primary, a little lighter: $dark');
    expect(_c(t, 'accent', dark: true), dark);
    expect(_c(t, 'activeTint', dark: true), '#38${dark.substring(3)}');
    expect(_c(t, 'focusBorder', dark: true), '#80${dark.substring(3)}');
    expect(_c(t, 'infoTint', dark: true), '#29${dark.substring(3)}');
    // A shade the site set for light is in its hue in dark too, at the
    // lightness the design system's dark shade has.
    final deep = t.forBrightness(dark: true).color('accentDeep')!;
    expect(deep.red, greaterThan(deep.blue), reason: 'no longer blue: ${deep.toJson()}');
    // Neutrals and the surface are the design system's.
    expect(_c(t, 'accentTint', dark: true), '#FF262626');
    expect(_c(t, 'surface', dark: true), '#FF141414');
    expect(_c(t, 'ink', dark: true), '#FFFFFFFF');
  });

  test('what the site names itself is the site\'s, light and dark', () {
    final t = _base.withSiteTheme(ThemeTokens.fromJson({
      'primary': '#FFB45309',
      'colors': {'activeTint': '#33000000', 'info': '#FF0000FF'},
      'dark': {
        'primary': '#FFF59E0B',
        'colors': {'focusBorder': '#80FFFFFF'},
      },
    }));
    expect(_c(t, 'activeTint'), '#33000000');
    expect(_c(t, 'info'), '#FF0000FF');
    expect(_c(t, 'infoTint'), '#1A0891B2', reason: 'the site has its own info color: its tints are not the accent\'s');
    expect(_c(t, 'primary', dark: true), '#FFF59E0B');
    expect(_c(t, 'accent', dark: true), '#FFF59E0B');
    expect(_c(t, 'activeTint', dark: true), '#38F59E0B');
    expect(_c(t, 'focusBorder', dark: true), '#80FFFFFF');
  });

  test('only colors.accent given, where the accent is the primary: the primary follows', () {
    final t = _base.withSiteTheme(ThemeTokens.fromJson({
      'colors': {'accent': '#FF047857'},
    }));
    expect(_c(t, 'primary'), '#FF047857');
    expect(_c(t, 'activeTint'), '#24047857');
    expect(_c(t, 'primary', dark: true), isNot('#FF3B82F6'));
  });

  test('a site that changes no accent gets the plain merge', () {
    final site = ThemeTokens.fromJson({
      'colors': {'ink': '#FF000000'},
    });
    expect(_base.withSiteTheme(site).toJson(), _base.mergedWith(site).toJson());
    expect(_base.withSiteTheme(ThemeTokens.none).toJson(), _base.toJson());
  });

  test('a site fontFamily: the styles of the design system in its default family follow it', () {
    final base = ThemeTokens.fromJson({
      'fontFamily': 'Inter',
      'textStyles': {
        'body': {'fontFamily': 'Inter', 'fontSize': 14},
        'caption': {'fontFamily': 'Inter', 'fontSize': 12},
        'number': {'fontFamily': 'Inter Display', 'fontSize': 28},
        'code': {'fontFamily': 'JetBrains Mono', 'fontSize': 13},
      },
    });
    final t = base.withSiteTheme(ThemeTokens.fromJson({
      'fontFamily': 'Lora',
      'textStyles': {
        'caption': {'fontFamily': 'Karla'},
        'number': {'fontFamily': 'Fraunces'},
      },
    }));
    expect(t.fontFamily, 'Lora');
    expect(t.textStyles['body']!.fontFamily, 'Lora');
    expect(t.textStyles['body']!.fontSize, 14);
    expect(t.textStyles['caption']!.fontFamily, 'Karla', reason: 'the one the site gives the style');
    expect(t.textStyles['number']!.fontFamily, 'Fraunces', reason: 'another family is changed by naming the style');
    expect(t.textStyles['code']!.fontFamily, 'JetBrains Mono');
  });

  // Round 16: four sites set "surface" (cream, a hex) under Cards and every
  // page stayed white: Cards draws its ground under names of its own.
  group('the roles a site gives reach what the design system names itself', () {
    final cards = ThemeTokens.fromJson({
      'primary': '#FF2563EB',
      'surface': '#FFFFFFFF',
      'onSurface': '#FF111827',
      'fontFamily': 'Inter',
      'radius': 12,
      'colors': {
        'page': '#FFF3F4F6',
        'pageFill': '#FFFFFFFF',
        'primaryBackground': '#FFFFFFFF',
        'card': '#FFFFFFFF',
        'onAccent': '#FFFFFFFF',
        'primaryText': '#FF111827',
        'ink': '#FF111827',
        'tooltipBackground': '#FF111827',
        'secondaryText': '#FF4B5563',
      },
      'radii': {'control': 12, 'card': 26, 'chip': 999},
      'textStyles': {
        'body': {'fontFamily': 'Inter', 'fontSize': 14},
        'heading1': {'fontFamily': 'Inter', 'fontSize': 30},
        'pageTitle': {'fontFamily': 'Inter', 'fontSize': 22},
        'code': {'fontFamily': 'JetBrains Mono', 'fontSize': 13},
      },
      'dark': {
        'surface': '#FF141414',
        'colors': {'page': '#FF0A0A0A', 'pageFill': '#FF141414', 'card': '#FF1F1F1F'},
      },
    });

    test('surface: the ground a page is drawn on, not a card or the text on the accent', () {
      final t = cards.withSiteTheme(ThemeTokens.fromJson({'surface': '#FFF6EFE1'}));
      expect(_c(t, 'surface'), '#FFF6EFE1');
      expect(_c(t, 'pageFill'), '#FFF6EFE1', reason: 'a website\'s page');
      expect(_c(t, 'page'), '#FFF6EFE1', reason: 'an app\'s page');
      expect(_c(t, 'primaryBackground'), '#FFF6EFE1');
      expect(_c(t, 'card'), '#FFFFFFFF');
      expect(_c(t, 'onAccent'), '#FFFFFFFF');
      expect(t.ground?.toJson(), '#FFF6EFE1');
      // Dark mode keeps the design system's dark ground: the site gave none.
      expect(_c(t, 'pageFill', dark: true), '#FF141414');
      // The design system's own surface written again changes nothing: its
      // page stays the grey its white panes are drawn on.
      final same = cards.withSiteTheme(ThemeTokens.fromJson({'surface': '#FFFFFFFF', 'primary': '#FF00A3AD'}));
      expect(_c(same, 'page'), '#FFF3F4F6');
    });

    test('surface by a name the site\'s colors define; a ground name the site gives is the site\'s', () {
      final t = cards.withSiteTheme(ThemeTokens.fromJson({
        'surface': 'cream',
        'colors': {'cream': '#FFF8F0E3', 'page': '#FFEEE0C8'},
        'dark': {'surface': '#FF1E1914'},
      }));
      expect(_c(t, 'pageFill'), '#FFF8F0E3');
      expect(_c(t, 'page'), '#FFEEE0C8');
      expect(_c(t, 'pageFill', dark: true), '#FF1E1914');
      expect(_c(t, 'page', dark: true), '#FF1E1914');
      // A card keeps its place over the ground: a little lighter than the site's dark surface.
      final card = t.forBrightness(dark: true).color('card')!;
      expect(card.red, inInclusiveRange(0x1F, 0x40), reason: card.toJson());
      expect(card.red, greaterThan(card.blue), reason: 'in the warm ground\'s tone: ${card.toJson()}');
    });

    test('onSurface: the ink where the design system\'s is its onSurface', () {
      final t = cards.withSiteTheme(ThemeTokens.fromJson({'onSurface': '#FF2A2620'}));
      expect(_c(t, 'primaryText'), '#FF2A2620');
      expect(_c(t, 'ink'), '#FF2A2620');
      // The second ink keeps its place between the ground and the ink: in the site's warm tone now.
      final second = t.color('secondaryText')!;
      expect(second.red, greaterThan(second.blue), reason: second.toJson());
      expect(second.red, inInclusiveRange(0x48, 0x70), reason: second.toJson());
      expect(_c(t, 'tooltipBackground'), '#FF2A2620', reason: 'a tooltip is drawn in the ink');
    });

    test('titleFontFamily: the title and heading styles; fontFamily: the rest', () {
      final t = cards.withSiteTheme(ThemeTokens.fromJson({'titleFontFamily': 'Georgia', 'fontFamily': 'Lora'}));
      expect(t.textStyles['heading1']!.fontFamily, 'Georgia');
      expect(t.textStyles['pageTitle']!.fontFamily, 'Georgia');
      expect(t.textStyles['body']!.fontFamily, 'Lora');
      expect(t.textStyles['code']!.fontFamily, 'JetBrains Mono');
      final own = cards.withSiteTheme(ThemeTokens.fromJson({
        'titleFontFamily': 'Georgia',
        'textStyles': {
          'heading1': {'fontFamily': 'Fraunces'},
        },
      }));
      expect(own.textStyles['heading1']!.fontFamily, 'Fraunces');
      expect(own.textStyles['body']!.fontFamily, 'Inter');
    });

    test('radius: the design system\'s scale in its proportion; a pill stays one', () {
      final t = cards.withSiteTheme(ThemeTokens.fromJson({'radius': 3}));
      expect(t.radius, 3);
      expect(t.radii['control'], 3);
      expect(t.radii['card'], 6.5);
      expect(t.radii['chip'], 999);
      final square = cards.withSiteTheme(ThemeTokens.fromJson({'radius': 0, 'radii': {'card': 4}}));
      expect(square.radii['control'], 0);
      expect(square.radii['card'], 4, reason: 'the site\'s own');
    });
  });

  group('themeProblems: what of a theme is not read is said', () {
    List<String> said(Object? theme, {List<String> colors = const []}) =>
        [for (final p in themeProblems(theme, colors: colors)) '${p.path.join('.')}: ${p.message}'];

    test('a theme that is read says nothing', () {
      expect(
          said({
            'primary': 'green',
            'onPrimary': 'cream',
            'surface': 'cream',
            'titleFontFamily': 'Georgia',
            'radius': 4,
            'mode': 'dark',
            'colors': {'cream': '#FFF8F0E3', 'green': '#2F4A3A', 'ink': 'green'},
            'textStyles': {
              'heading1': {'fontFamily': 'Georgia', 'fontSize': 52, 'color': 'green'},
            },
            'dark': {
              'surface': 'ink',
              'colors': {'night': '#FF000000'},
            },
          }),
          isEmpty);
      expect(said(null), isEmpty);
      expect(said({'primary': 'accent', 'onPrimary': 'surface'}, colors: ['accent']), isEmpty, reason: 'a name of the design system it is laid over');
    });

    test('a color name nothing defines, and a value that is no color', () {
      final out = said({
        'primary': 'sepia',
        'surface': 'rgb(1,2,3)',
        'colors': {'cream': '#FFF', 'ink': '#FF111827'},
      });
      expect(out, hasLength(3));
      expect(out[0], startsWith('primary: no color of the theme is named "sepia", so it is not read. Write its value, "#AARRGGBB" (or "#RRGGBB"), or define it: "colors": {"sepia": "#AARRGGBB"} (here: cream, ink).'));
      expect(out[1], startsWith('surface: "rgb(1,2,3)" is not a color, so it is not read. Write "#AARRGGBB" (or "#RRGGBB"), or the name of a color'));
      expect(out[2], startsWith('colors.cream: "#FFF" is not a color'));
    });

    test('a key a theme does not have names the key that is meant', () {
      final out = said({'background': '#FFF6EFE1', 'headingFont': 'Georgia', 'cream': '#FFF8F0E3', 'radius': '8px', 'mode': 'night'});
      expect(out[0], startsWith('background: a theme has no "background", so it is not read. Write "surface" (the ground a page is drawn on). A theme\'s keys: primary, onPrimary, surface,'));
      expect(out[1], contains('Write "titleFontFamily"'));
      expect(out[2], contains('A color of the site\'s own goes in "colors": {"cream": "#FFF8F0E3"}.'));
      expect(out[3], 'radius: "8px" is not read: write a number (8).');
      expect(out[4], 'mode: "night" is not a mode: write "system", "light" or "dark".');
      expect(said('dark').single, startsWith(': not read: it is an object'));
      expect(said({'dark': {'surface': 'coal'}}).single, startsWith('dark.surface: no color of the theme is named "coal"'));
    });

    test('a site\'s manifest: each is a problem of site.json at its line', () {
      const manifest = '{\n  "pages": ["home.json"],\n  "theme": {\n    "primary": "sepia",\n    "colors": {\n      "cream": "#FFF8F0E3"\n    },\n    "accent": "#FF7A4A2A"\n  }\n}\n';
      final site = NotationSiteFiles({'pages/home.txt': 'Text "Hi"', 'site.json': manifest}, catalog: standardCatalog);
      expect([for (final p in site.problems) '${p.path}:${p.line}'], ['site.json:4', 'site.json:8']);
      expect(site.problems.first.message, startsWith('site.json theme.primary: no color of the theme is named "sepia"'));
      expect(site.problems.last.message, startsWith('site.json theme.accent: a theme has no "accent", so it is not read. Write "primary" (the accent).'));
      // Under a design system that has the name, it is one.
      final under = NotationSiteFiles({'pages/home.txt': 'Text "Hi"', 'site.json': '{"theme": {"primary": "sepia"}}'}, catalog: standardCatalog, themeColors: const ['sepia']);
      expect(under.problems, isEmpty);
    });
  });
}
