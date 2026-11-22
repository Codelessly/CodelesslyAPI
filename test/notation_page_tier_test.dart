// A theme's styles for a website's page: a design system made for an app's
// window names, beside a look (`heading1`, `lead`, `body`), the style the
// look has on a page (`heading1Page`...). A text under a `Page` takes it;
// under an `App`, in a page's bar and in its foot the look is the app's.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

const _theme = <String, Object?>{
  'fontFamily': 'Inter',
  'textStyles': {
    'body': {'fontFamily': 'Inter', 'fontSize': 13},
    'muted': {'fontFamily': 'Inter', 'fontSize': 13},
    'lead': {'fontFamily': 'Inter', 'fontSize': 15},
    'caption': {'fontFamily': 'Inter', 'fontSize': 12},
    'heading1': {'fontFamily': 'Inter', 'fontSize': 30, 'fontWeight': 700},
    'heading2': {'fontFamily': 'Inter', 'fontSize': 24, 'fontWeight': 700},
    'bodyPage': {'fontFamily': 'Inter', 'fontSize': 16, 'height': 1.6},
    'leadPage': {'fontFamily': 'Inter', 'fontSize': 19},
    'heading1Page': {'fontFamily': 'Inter', 'fontSize': 60, 'fontWeight': 700, 'letterSpacing': -1.7},
    'heading2Page': {'fontFamily': 'Inter', 'fontSize': 36, 'fontWeight': 700},
  },
};

NotationResult _parse(String text, {Map<String, Object?> theme = _theme, double width = 1440}) =>
    parseNotation(text, catalog: standardCatalog, options: withTestWords(NotationOptions.fromTheme(theme, named: true, width: width)));

Map<String, Object?> _text(NotationResult r, String text) => (r.document['nodes'] as Map)
    .values
    .cast<Map>()
    .firstWhere((n) => n['type'] == 'text' && (n['props'] as Map)['text'] == text, orElse: () => throw StateError('no text "$text": ${r.issues}'))
    .cast<String, Object?>();

Object? _from(NotationResult r, String text) => ((_text(r, text)['props'] as Map)['style'] as Map)['from'];

void main() {
  const page = '''
Page
  Nav
    Text.heading2 "Brand"
    Text "Link"
  Section
    Text.heading1 "Head"
    Text.lead "Lead"
    Text "Body"
    Text.heading2#second "Two"
    Text.caption "Small print"
    Text.heading1 "Sized" size=40
    Card
      Text "In a card"
  Footer
    Text "Foot"
''';

  test('under a Page: each look that has a page style takes it; the others, the bar and the foot keep the app\'s', () {
    final r = _parse(page);
    expect(r.issues, isEmpty);
    expect(_from(r, 'Head'), 'heading1Page');
    expect(_from(r, 'Lead'), 'leadPage');
    expect(_from(r, 'Body'), 'bodyPage');
    expect(_from(r, 'Two'), 'heading2Page');
    expect((r.document['nodes'] as Map).containsKey('second'), isTrue, reason: 'the line keeps its id');
    expect(_from(r, 'In a card'), 'bodyPage');
    expect(_from(r, 'Small print'), 'caption', reason: 'the theme has no captionPage');
    expect(_from(r, 'Brand'), 'heading2', reason: 'a bar is the app\'s size');
    expect(_from(r, 'Link'), isNot('bodyPage'));
    expect(_from(r, 'Foot'), isNot('bodyPage'), reason: 'a foot keeps the small type');
    // A size written on the line is the line's.
    expect(((_text(r, 'Sized')['props'] as Map)['style'] as Map)['fontSize'], 40);
  });

  test('under an App nothing changes: the app\'s scale', () {
    final r = _parse('App\n  Main\n    Text.heading1 "Head"\n    Text.lead "Lead"\n    Text "Body"\n    Card\n      Text.heading2 "Two"\n');
    expect(_from(r, 'Head'), 'heading1');
    expect(_from(r, 'Lead'), 'lead');
    expect(_from(r, 'Two'), 'heading2');
    expect(_from(r, 'Body'), isNot('bodyPage'));
  });

  test('the headline is smaller on a tablet and a phone', () {
    final r = _parse(page);
    final media = (_text(r, 'Head')['media'] as List).cast<Map>();
    final sizes = [for (final m in media) (((m['patch'] as Map)['props'] as Map)['style'] as Map)['fontSize'] as num];
    expect(sizes, hasLength(2));
    expect(sizes.every((s) => s < 60 && s >= 40), isTrue, reason: '$sizes');
  });

  test('a theme with no page styles: the notation\'s own sizes for a website, as before', () {
    final r = parseNotation('Page\n  Section\n    Text.heading1 "Head"\n', catalog: standardCatalog, options: withTestWords(const NotationOptions(width: 1440)));
    expect(((_text(r, 'Head')['props'] as Map)['style'] as Map)['fontSize'], 64);
  });

  test('what a site says of a look it says of the page\'s style too', () {
    final ds = ThemeTokens.fromJson(_theme);
    final t = ds.withSiteTheme(ThemeTokens.fromJson({
      'titleFontFamily': 'Georgia',
      'textStyles': {
        'heading2': {'fontWeight': 400},
        'lead': {'fontSize': 22},
      },
    }));
    expect(t.textStyles['heading1Page']!.fontFamily, 'Georgia');
    expect(t.textStyles['heading2Page']!.fontWeight, 400);
    expect(t.textStyles['heading2Page']!.fontSize, 36, reason: 'the page\'s size stays where the site gives none');
    expect(t.textStyles['leadPage']!.fontSize, 22);
  });
}
