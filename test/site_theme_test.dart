// A site's theme over a design system's tokens: what the design system
// makes from its accent follows the site's accent, light and dark.
import 'package:codelessly_api/codelessly_api.dart';
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
}
