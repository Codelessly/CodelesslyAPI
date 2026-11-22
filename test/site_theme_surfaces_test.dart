// A site's surface and ink under a design system: every neutral the design
// system draws its own parts in (a chrome, a band, a card, a field, a
// hairline, its second and third inks) is made from them, a dark surface
// written as the light one takes the design system's dark colors, and what
// is drawn in or on the accent reads.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A design system as Desk is: a white work surface, a chrome a step off it,
/// zinc inks and lines, status tints, an indigo accent; and its dark side.
final _desk = ThemeTokens.fromJson({
  'primary': '#FF4F46E5',
  'onPrimary': '#FFFFFFFF',
  'surface': '#FFFFFFFF',
  'onSurface': '#FF18181B',
  'error': '#FFDC2626',
  'colors': {
    'primaryBackground': '#FFFFFFFF',
    'pageFill': '#FFFFFFFF',
    'card': '#FFFFFFFF',
    'chrome': '#FFFAFAFB',
    'band': '#FFFAFAFB',
    'well': '#FFF4F4F6',
    'primaryText': '#FF18181B',
    'secondaryText': '#FF52525B',
    'tertiaryText': '#FF71717A',
    'line': '#FFE4E4E7',
    'hoverOverlay': '#0A18181B',
    'onAccent': '#FFFFFFFF',
    'accent': '#FF4F46E5',
    'accentText': '#FF4338CA',
    'accentTint': '#FFEEF0FE',
    'successTint': '#FFEDFAF2',
    'successInk': '#FF15803D',
    'scrim': '#6618181B',
  },
  'shadows': {
    'level1': [
      {'type': 'dropShadow', 'color': '#0A18181B', 'offset': [0, 1], 'blurRadius': 2},
    ],
  },
  'dark': {
    'primary': '#FF6D70F0',
    'surface': '#FF141417',
    'onSurface': '#FFF4F4F5',
    'error': '#FFF87171',
    'colors': {
      'primaryBackground': '#FF18181C',
      'pageFill': '#FF18181C',
      'card': '#FF1E1E23',
      'chrome': '#FF141417',
      'band': '#FF1C1C21',
      'well': '#FF111114',
      'primaryText': '#FFF4F4F5',
      'secondaryText': '#FFB4B4BC',
      'tertiaryText': '#FF8A8A94',
      'line': '#FF2C2C33',
      'hoverOverlay': '#0FFFFFFF',
      'accent': '#FF7C7FF7',
      'accentText': '#FFA5A8FA',
      'accentTint': '#FF24244A',
      'successTint': '#FF132A1E',
      'successInk': '#FF86EFAC',
      'scrim': '#99000000',
    },
    'shadows': {
      'level1': [
        {'type': 'dropShadow', 'color': '#33000000', 'offset': [0, 1], 'blurRadius': 2},
      ],
    },
  },
});

Color _c(ThemeTokens t, String name, {bool dark = false}) => t.forBrightness(dark: dark).color(name)!;
String _h(ThemeTokens t, String name, {bool dark = false}) => _c(t, name, dark: dark).toJson();
double _luma(Color c) => (0.2126 * c.red + 0.7152 * c.green + 0.0722 * c.blue) / 255;

void main() {
  test('a cream surface and a brown ink: the card, the chrome, the band, the lines and the inks are made from them', () {
    final t = _desk.withSiteTheme(ThemeTokens.fromJson({'surface': '#FFFAF4E6', 'onSurface': '#FF2A2620'}));
    expect(_h(t, 'pageFill'), '#FFFAF4E6');
    expect(_h(t, 'card'), '#FFFAF4E6', reason: 'the design system\'s card is its ground: the site\'s ground, not white');
    for (final name in ['chrome', 'band', 'well', 'line', 'secondaryText', 'tertiaryText']) {
      final c = _c(t, name);
      expect(c.red, greaterThan(c.blue), reason: '$name is in the site\'s warm tone: ${c.toJson()}');
      expect(c.toJson(), isNot(_h(_desk, name)), reason: name);
    }
    // Each keeps its place: a band a step off the ground, the well a step further, the line darker, the inks darker.
    final order = ['pageFill', 'band', 'well', 'line', 'tertiaryText', 'secondaryText', 'primaryText'];
    for (var k = 1; k < order.length; k++) {
      expect(_luma(_c(t, order[k])), lessThan(_luma(_c(t, order[k - 1]))), reason: '${order[k]} is darker than ${order[k - 1]}');
    }
    expect(_h(t, 'primaryText'), '#FF2A2620');
    expect(_h(t, 'hoverOverlay'), '#0A2A2620', reason: 'an overlay of the ink is of the site\'s ink, at its own opacity');
    expect(ThemeTokens.contrastOf(_c(t, 'secondaryText'), _c(t, 'pageFill')), greaterThan(4.5));
    // Hues, what is drawn on the accent, a scrim: not tones of the ground.
    expect(_h(t, 'successTint'), '#FFEDFAF2');
    expect(_h(t, 'successInk'), '#FF15803D');
    expect(_h(t, 'onAccent'), '#FFFFFFFF');
    expect(_h(t, 'scrim'), '#6618181B');
    // The dark side, of which the site says nothing, is the design system's.
    expect(_h(t, 'card', dark: true), '#FF1E1E23');
    expect(_h(t, 'secondaryText', dark: true), '#FFB4B4BC');
  });

  test('a surface alone: the design system\'s ink stays, the neutrals move to the ground', () {
    final t = _desk.withSiteTheme(ThemeTokens.fromJson({'surface': '#FFFAF4E6'}));
    expect(_h(t, 'primaryText'), '#FF18181B');
    expect(_h(t, 'card'), '#FFFAF4E6');
    expect(_c(t, 'band').red, greaterThan(_c(t, 'band').blue));
  });

  test('the design system\'s own surface, or none: nothing is made again', () {
    for (final site in [
      {'primary': '#FF4F46E5'},
      {'surface': '#FFFFFFFF', 'radius': 12},
      {'colors': {'brand': '#FF123456'}},
    ]) {
      final t = _desk.withSiteTheme(ThemeTokens.fromJson(site));
      for (final name in ['card', 'chrome', 'band', 'line', 'secondaryText', 'onAccent', 'accentText']) {
        expect(_h(t, name), _h(_desk, name), reason: '$name under $site');
        expect(_h(t, name, dark: true), _h(_desk, name, dark: true), reason: 'dark $name under $site');
      }
    }
  });

  test('a near-black surface written as the light one: the light side takes the design system\'s dark colors, on that ground', () {
    final t = _desk.withSiteTheme(ThemeTokens.fromJson({'primary': '#FF3DFFB0', 'surface': '#FF0A0B0E', 'onSurface': '#FFE6E8EC'}));
    expect(t.mode, ThemeMode.system);
    expect(_h(t, 'pageFill'), '#FF0A0B0E');
    expect(_h(t, 'primaryText'), '#FFE6E8EC');
    final card = _c(t, 'card');
    expect(_luma(card), inExclusiveRange(_luma(_c(t, 'pageFill')), 0.2), reason: 'a card a little lighter than the ground: ${card.toJson()}');
    expect(_luma(_c(t, 'well')), lessThanOrEqualTo(_luma(_c(t, 'pageFill'))), reason: 'the well is under the ground');
    expect(ThemeTokens.contrastOf(_c(t, 'secondaryText'), card), greaterThan(4.5), reason: 'the second ink reads on a card');
    expect(ThemeTokens.contrastOf(_c(t, 'primaryText'), _c(t, 'band')), greaterThan(7));
    // The dark side's hues, status inks, error and shadows.
    expect(_h(t, 'successTint'), '#FF132A1E');
    expect(_h(t, 'successInk'), '#FF86EFAC');
    expect(_h(t, 'error'), '#FFF87171');
    expect(_h(t, 'scrim'), '#99000000');
    expect(t.shadows['level1']!.single.toJson()['color'], '#33000000');
    // The site's accent, and what is on it reads.
    expect(_h(t, 'primary'), '#FF3DFFB0');
    expect(_h(t, 'accent'), '#FF3DFFB0');
    expect(_h(t, 'onPrimary'), '#FF111111');
    expect(_h(t, 'onAccent'), '#FF111111');
    expect(_luma(_c(t, 'accentTint')), lessThan(0.4), reason: 'a dark tint of the accent');
  });

  test('a dark surface with no ink given: the ink is one that reads', () {
    final t = _desk.withSiteTheme(ThemeTokens.fromJson({'surface': '#FF101418'}));
    expect(ThemeTokens.contrastOf(_c(t, 'primaryText'), _c(t, 'pageFill')), greaterThan(7));
    expect(ThemeTokens.contrastOf(t.color('onSurface')!, t.color('surface')!), greaterThan(7));
  });

  test('a site\'s dark surface: the dark neutrals are made from it', () {
    final t = _desk.withSiteTheme(ThemeTokens.fromJson({
      'dark': {'surface': '#FF120E0B', 'onSurface': '#FFF5E6C8'},
    }));
    expect(_h(t, 'card'), '#FFFFFFFF', reason: 'the light side is the design system\'s');
    expect(_h(t, 'pageFill', dark: true), '#FF120E0B');
    final line = _c(t, 'line', dark: true);
    expect(line.red, greaterThan(line.blue), reason: 'a warm hairline: ${line.toJson()}');
    expect(_h(t, 'primaryText', dark: true), '#FFF5E6C8');
  });

  test('a light accent: the text on it is dark, and text in the accent reads on the ground', () {
    final lime = _desk.withSiteTheme(ThemeTokens.fromJson({'primary': '#FFC6F432'}));
    expect(_h(lime, 'onPrimary'), '#FF111111');
    expect(_h(lime, 'onAccent'), '#FF111111');
    expect(ThemeTokens.contrastOf(_c(lime, 'accentText'), _c(lime, 'pageFill')), greaterThanOrEqualTo(4.5), reason: _h(lime, 'accentText'));
    // An accent that carries white keeps it; one the site gives is the site's.
    final teal = _desk.withSiteTheme(ThemeTokens.fromJson({'primary': '#FF0D9488'}));
    expect(_h(teal, 'onPrimary'), '#FFFFFFFF');
    final own = _desk.withSiteTheme(ThemeTokens.fromJson({'primary': '#FFC6F432', 'onPrimary': '#FF334400'}));
    expect(_h(own, 'onPrimary'), '#FF334400');
  });

  test('a color the site names itself is the site\'s', () {
    final t = _desk.withSiteTheme(ThemeTokens.fromJson({
      'surface': '#FFFAF4E6',
      'colors': {'card': '#FFFFFFFF', 'line': '#FF000000'},
    }));
    expect(_h(t, 'card'), '#FFFFFFFF');
    expect(_h(t, 'line'), '#FF000000');
  });

  test('a design system whose page is a grey its white cards are on: the card stays lighter than the site\'s ground', () {
    final cards = ThemeTokens.fromJson({
      'surface': '#FFFFFFFF',
      'onSurface': '#FF111827',
      'colors': {'page': '#FFF3F4F6', 'pageFill': '#FFFFFFFF', 'card': '#FFFFFFFF', 'primaryText': '#FF111827'},
    });
    final t = cards.withSiteTheme(ThemeTokens.fromJson({'surface': '#FFF6EFE1'}));
    expect(_h(t, 'page'), '#FFF6EFE1');
    expect(_h(t, 'card'), '#FFFFFFFF');
  });
}
