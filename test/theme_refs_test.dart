// Named colors and text styles: a document names the project's theme
// (`"color": "ember"`, `"style": "title"`, `{"from": "title", ...}`), keeps
// the names through a decode and encode, and resolves them against the
// theme (its media rules and dark colors included).
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

ThemeTokens theme([Json extra = const {}]) => ThemeTokens.fromJson({
      'colors': {'ink': '#FF111111', 'ember': '#FFE4572E', 'accent': 'ember'},
      'textStyles': {
        'body': {'fontFamily': 'DM Sans', 'fontSize': 16, 'color': 'ink', 'height': 1.5},
        'title': {'from': 'body', 'fontSize': 32, 'fontWeight': 700},
        'loop': {'from': 'loop'},
      },
      'media': [
        {
          'minWidth': 1024,
          'patch': {
            'textStyles': {'title': {'fontSize': 48}},
          },
        },
      ],
      ...extra,
    });

LayoutDocument doc() => LayoutDocument.fromJson({
      'schema': 3,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas', 'slots': {'body': 'col'}, 'layout': {'width': 390, 'height': 800}},
        'col': {
          'type': 'column',
          'children': ['t1', 't2', 'plain'],
          'layout': {'width': {'fill': 390}, 'height': {'fill': 800}},
          'decoration': {'fills': [{'color': 'accent'}]},
        },
        't1': {
          'type': 'text',
          'layout': {'width': {'hug': 10}, 'height': {'hug': 10}},
          'props': {'text': 'A', 'style': 'title'},
          'media': [
            {'maxWidth': 599, 'patch': {'props': {'style': 'body'}}},
          ],
        },
        't2': {
          'type': 'text',
          'layout': {'width': {'hug': 10}, 'height': {'hug': 10}},
          'props': {'text': 'B', 'style': {'from': 'body', 'color': 'ember', 'fontSize': 12}},
        },
        'plain': {
          'type': 'text',
          'layout': {'width': {'hug': 10}, 'height': {'hug': 10}},
          'props': {'text': 'C', 'style': {'fontSize': 10, 'color': '#FF000000'}},
        },
      },
    });

void main() {
  test('a color name decodes, keeps its name through encode, and is not a hex color', () {
    expect(Color.fromJson('ember'), const Color.named('ember'));
    expect(Color.fromJson('ember')!.toJson(), 'ember');
    expect(Color.fromJson('#FF000000'), const Color(0xFF000000));
    expect(Color.fromJson('FFAA00'), const Color(0xFFFFAA00));
    expect(Color.fromHex('ember'), isNull);
    expect(Color.fromJson('not a name'), isNull);
  });

  test('a colour name given by a binding keeps its name, so it resolves against the theme as a written one does', () {
    // A model that styles a selected chip binds its fill to a colour name
    // (`"${= selected ? 'primary' : 'surface'}"`), as it writes one.
    final box = Node.fromJson({
      'type': 'box',
      'decoration': {'fills': [{'color': '#FFFFFFFF'}]},
    }, id: 'b')!;
    final bound = BindPaths.apply(box, 'decoration.fills[0].color', 'ember');
    expect(bound.decoration.fills.single.color, const Color.named('ember'));
    final resolved = ThemeRefs(theme()).node(bound.toJson(), bound.spec);
    expect(readList(readMap(resolved['decoration'])?['fills'])?.single, {'color': '#FFE4572E'});
    // A hex colour still reads as one; text that is no colour still leaves the node as it was.
    expect(BindPaths.apply(box, 'decoration.fills[0].color', '#FF000000').decoration.fills.single.color, const Color(0xFF000000));
    expect(identical(BindPaths.apply(box, 'decoration.fills[0].color', 'not a colour'), box), isTrue);
  });

  test('a text style written as a name is a style starting from it', () {
    expect(TextStyle.fromJson('title'), const TextStyle(from: 'title'));
    expect(TextStyle.fromJson('title').toJson(), {'from': 'title'});
    expect(TextStyle.fromJson({'from': 'title', 'fontSize': 12}).toJson(), {'from': 'title', 'fontSize': 12});
  });

  test('the theme resolves its styles: from chains, color names, aliases, cycles', () {
    final t = theme();
    expect(t.color('accent'), const Color(0xFFE4572E));
    final title = t.textStyle('title')!;
    expect(title.fontFamily, 'DM Sans');
    expect(title.fontSize, 32);
    expect(title.color, const Color(0xFF111111));
    expect(title.from, isNull);
    expect(t.textStyle('loop'), isNull);
    expect(t.textStyle('nope'), isNull);
    expect(t.atScreen(1440, 900, Breakpoints.defaults).textStyle('title')!.fontSize, 48);
    expect(t.atScreen(390, 844, Breakpoints.defaults).textStyle('title')!.fontSize, 32);
    final dark = ThemeTokens.fromJson({
      ...theme().toJson(),
      'dark': {'colors': {'ink': '#FFEEEEEE'}},
    }).forBrightness(dark: true);
    expect(dark.textStyle('body')!.color, const Color(0xFFEEEEEE));
  });

  test('a document resolves against its theme; nodes naming nothing stay the same objects', () {
    final d = doc();
    final r = resolveThemeRefs(d, theme());
    expect(identical(r['plain'], d['plain']), isTrue);
    expect(r['col']!.decoration.fills.single.color, const Color(0xFFE4572E));
    final t1 = r['t1']!.prop(TextProps.style);
    expect([t1.fontSize, t1.fontWeight, t1.color, t1.fontFamily], [32, 700, const Color(0xFF111111), 'DM Sans']);
    final t2 = r['t2']!.prop(TextProps.style);
    expect([t2.fontSize, t2.color, t2.height], [12, const Color(0xFFE4572E), 1.5]);
    // The unresolved document keeps its names.
    expect(d['t2']!.toJson()['props'], {'text': 'B', 'style': {'from': 'body', 'fontSize': 12, 'color': 'ember'}});
    // A media rule switching the style replaces it as a whole.
    final narrow = r['t1']!.atScreen(390, 844, Breakpoints.defaults).prop(TextProps.style);
    expect([narrow.fontSize, narrow.fontWeight], [16, null]);
  });

  test('a patch changing some fields of a named style merges into it', () {
    final base = {'type': 'text', 'props': {'style': 'title'}};
    final merged = mergeNodePatch(base, {'props': {'style': {'fontSize': 20}}}, props: TextProps.spec.props);
    expect(merged['props'], {'style': {'from': 'title', 'fontSize': 20}});
  });

  test('changing a named style changes only the nodes that use it', () {
    final d = doc();
    final before = resolveThemeRefs(d, theme());
    final after = resolveThemeRefs(d, theme({'textStyles': {
      'body': {'fontFamily': 'DM Sans', 'fontSize': 16, 'color': 'ink', 'height': 1.5},
      'title': {'from': 'body', 'fontSize': 36, 'fontWeight': 700},
    }}));
    final changed = [for (final id in d.nodes.keys) if (before[id] != after[id]) id];
    expect(changed, ['t1']);
  });

  test('the site manifest holds the theme', () {
    final m = SiteManifest.fromJson({'theme': theme().toJson()});
    expect(m.theme.textStyle('title')!.fontSize, 32);
    expect(SiteManifest.fromJson(m.toJson()).theme, m.theme);
  });

  test('validation reports unknown names with suggestions, and accepts known ones', () {
    final page = doc().toJson();
    final nodes = page['nodes'] as Map;
    (nodes['t2'] as Map)['props'] = {'text': 'B', 'style': {'from': 'bdy', 'color': 'embr'}};
    final ds = validateProject({'p.json': page}, manifest: SiteManifest.fromJson({'theme': theme().toJson()}));
    final names = [for (final d in ds) if (d.code == Codes.unknownThemeName) (d.path, d.suggestion)];
    expect(names, [('/nodes/t2/props/style/from', 'body'), ('/nodes/t2/props/style/color', 'ember')]);
    // Without a theme, a name is reported (it would draw transparent).
    final none = validateProject({'p.json': doc().toJson()});
    expect(none.where((d) => d.code == Codes.unknownThemeName), isNotEmpty);
  });

  test('the theme itself is checked', () {
    final ds = validateTheme({
      'colors': {'ink': '#FF111111', 'bad': 'nope', 'short': '#FFF'},
      'textStyles': {'body': {'from': 'missing', 'fontSize': 'big'}, 'x': 3},
      'media': [{'minWidth': 1024, 'patch': {'textStyles': {'body': {'fontSize': 20}}}}, {'patch': {}}],
      'colours': {},
    });
    expect([for (final d in ds) d.path], unorderedEquals([
      '/theme/colors/bad', '/theme/colors/short', '/theme/textStyles/body/from', '/theme/textStyles/body/fontSize',
      '/theme/textStyles/x', '/theme/media/1', '/theme/colours',
    ]));
  });

  test('the guide\'s theme example is a valid site', () {
    const dir = 'tool/reference/examples/theme';
    final manifest = jsonDecode(File('$dir/site.json').readAsStringSync());
    expect(validateTheme((manifest as Map)['theme']), isEmpty);
    final ds = validateProject({'home.json': jsonDecode(File('$dir/home.json').readAsStringSync())},
        manifest: SiteManifest.fromJson(manifest));
    expect(ds.map((d) => '$d'), isEmpty);
  });

  test('a role that names a theme colour resolves to that colour, in light and dark, through a chain of names', () {
    final t = ThemeTokens.fromJson({
      'primary': 'forest',
      'onPrimary': 'paper',
      'error': 'missing',
      'colors': {'forest': 'pine', 'pine': '#FF1F6F4A', 'paper': '#FFFFFFFF', 'night': '#FF7FD1A6'},
      'dark': {'primary': 'night'},
    });
    final roles = t.resolvedRoles();
    expect(roles.primary, const Color(0xFF1F6F4A));
    expect(roles.onPrimary, const Color(0xFFFFFFFF));
    expect(roles.error, isNull, reason: 'a name the theme does not have is no colour');
    expect(t.forBrightness(dark: true).resolvedRoles().primary, const Color(0xFF7FD1A6));
    final plain = ThemeTokens.fromJson({'primary': '#FF000000'});
    expect(identical(plain.resolvedRoles(), plain), isTrue);
  });
}
