// The roles the notation draws its own parts in with no design system
// (ThemeTokens.notationRoles): a light value that is what it always wrote,
// a dark one made from the theme's ink and ground, written by name for a
// site's theme so a site with light and dark colors switches them.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

void main() {
  const light = {
    'primary': '#FF4F46E5',
    'colors': {'paper': '#FFFFFFFF', 'ink': '#FF111827'},
    'dark': {
      'colors': {'paper': '#FF14161C', 'ink': '#FFE8EAF0'},
    },
  };

  test('each role is its old literal on a light ground, and made from the ink and the ground on a dark one', () {
    final t = ThemeTokens.fromJson(light);
    expect(t.groundIsDark, isFalse);
    for (final e in ThemeTokens.notationRoles.entries) {
      expect(t.notationRole(e.key), Color(e.value), reason: e.key);
    }
    final d = t.forBrightness(dark: true);
    expect(d.groundIsDark, isTrue);
    expect(d.notationRole('line')!.toJson(), '#29E8EAF0');
    expect(d.notationRole('subtleFill')!.toJson(), '#1AE8EAF0');
    expect(d.notationRole('quietText')!.toJson(), '#CCE8EAF0');
    expect(d.notationRole('headingText')!.toJson(), '#FFE8EAF0');
    // A card a little lighter than the ground.
    expect(d.notationRole('card')!.toJson(), '#FF22242A');
    expect(t.notationRole('nothing'), isNull);
  });

  test('a document color named for a role resolves to it in the mode shown; a color the theme names wins', () {
    final t = ThemeTokens.fromJson(light);
    final refs = ThemeRefs(t.forBrightness(dark: true));
    expect(refs.value(const PropType.value('Color'), 'line'), '#29E8EAF0');
    expect(ThemeRefs(t).value(const PropType.value('Color'), 'line'), '#FFE5E7EB');
    final own = ThemeTokens.fromJson({
      ...light,
      'colors': {'paper': '#FFFFFFFF', 'ink': '#FF111827', 'line': '#FFAABBCC'},
    });
    expect(ThemeRefs(own).value(const PropType.value('Color'), 'line'), '#FFAABBCC');
    // With no theme, a panel in `surface` is white, as before.
    expect(ThemeRefs(ThemeTokens.none).value(const PropType.value('Color'), 'surface'), '#FFFFFFFF');
  });

  test('a site with no design system writes the roles by name; with a design system, or unnamed, their values', () {
    const text = '''
state tab="a"
state rows=[{"name":"Ada"}]
App
  Sidebar
    NavItem#home "Home" icon="home" selected={tab == "a"}
  Main
    Card#card
      Text.title#title "Overview"
    Table r in rows columns=["Name"]
''';
    Map<String, Object?> nodes(NotationOptions o) =>
        (parseNotation(text, catalog: standardCatalog, options: o).document['nodes'] as Map).cast<String, Object?>();
    final named = nodes(NotationOptions.fromTheme(light, width: 1280, named: true, roles: true));
    final card = named['card']! as Map;
    expect(((card['decoration'] as Map)['fills'] as List).first, {'color': 'card'});
    expect(((card['decoration'] as Map)['strokes'] as List).first, {'color': 'line'});
    expect((((named['title']! as Map)['props'] as Map)['style'] as Map)['color'], 'headingText');
    final all = named.toString();
    expect(all, contains('hoverFill'));
    expect(all, contains('quietText'));
    expect(all, contains('band'));
    // Unnamed (and so with a design system): the light values, as written before.
    final plain = nodes(NotationOptions.fromTheme(light, width: 1280));
    final plainCard = plain['card']! as Map;
    expect(((plainCard['decoration'] as Map)['fills'] as List).first, {'color': '#FFFFFFFF'});
    expect((((plain['title']! as Map)['props'] as Map)['style'] as Map)['color'], '#FF111827');
    expect(plain.toString(), isNot(contains('hoverFill')));
  });
}
