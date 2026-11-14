import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

/// A small design system as files: a manifest, its two documents and one
/// component.
final Map<String, String> _files = {
  'design_system.json': jsonEncode({
    'schema': 3,
    'id': 'acme',
    'name': 'Acme',
    'description': 'Flat and dense.',
    'design': 'DESIGN.md',
    'patterns': 'PATTERNS.md',
    'theme': {
      'primary': '#FF2563EB',
      'onSurface': '#FF111827',
      'colors': {'border': '#FFE5E7EB'},
      'dark': {
        'colors': {'border': '#FF383838'},
        'shadows': {
          'level1': [
            {'type': 'dropShadow', 'color': '#4D000000', 'offset': [0, 1], 'radius': 2},
          ],
        },
      },
      'textStyles': {
        'body': {'fontSize': 13, 'color': 'onSurface'},
      },
      'spacing': {'2': 8, '3': 12},
      'radii': {'control': 7, 'panel': 8},
      'sizes': {'compact': 28},
      'shadows': {
        'level1': [
          {'type': 'dropShadow', 'color': '#0D000000', 'offset': [0, 1], 'radius': 2},
        ],
      },
      'durations': {'fast': 150},
      'curves': {'standard': 'easeInOut'},
    },
    'components': ['components/Button.json', 'components/Toggle.json'],
    'replaces': ['filledButton', 'textButton'],
  }),
  'DESIGN.md': '# Acme\n\nLong prose.\n\n## In brief\n\nHairlines, not shadows. One radius per role.\n\n## Color\n\nMore.',
  'PATTERNS.md': '# Patterns\n\n## In brief\n\nA form is a column of fields 12 apart.\n',
  'components/Toggle.json': jsonEncode({
    'schema': 3,
    'id': 'Toggle',
    'roots': ['t'],
    'widget': {
      'type': 'Toggle',
      'doc': 'An on/off switch kept in your variable.',
      'props': [
        {'key': 'value', 'type': {'kind': 'variable', 'of': {'kind': 'boolean', 'flutter': 'bool'}}, 'default': ''},
      ],
    },
    'previews': [
      {'name': 'On', 'size': [36, 20], 'props': {'value': true}},
    ],
    'nodes': {
      't': {'type': 'box', 'layout': {'width': 36, 'height': 20}},
    },
  }),
  'components/Button.json': jsonEncode({
    'schema': 3,
    'id': 'Button',
    'roots': ['b'],
    'widget': {
      'type': 'Button',
      'doc': 'A pressable label. It fires onPressed.',
      'props': [
        {'key': 'label', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': 'Button', 'required': true},
        {
          'key': 'variant',
          'type': {'kind': 'enumeration', 'flutter': 'String', 'values': ['primary', 'ghost']},
          'default': 'primary',
        },
      ],
      'events': [{'key': 'onPressed'}],
    },
    'previews': [
      {'name': 'Primary', 'size': [96, 28], 'props': {'label': 'Save'}},
    ],
    'nodes': {
      'b': {
        'type': 'row',
        'children': ['t'],
        'layout': {'width': {'hug': 72}, 'height': 28, 'padding': [8, 0, 8, 0]},
        'decoration': {'fills': [{'color': 'primary'}]},
        'actions': [
          {'trigger': {'type': 'click'}, 'actions': [{'type': 'componentEvent', 'event': 'onPressed'}]},
        ],
      },
      't': {'type': 'text', 'props': {'text': r'${props.label}', 'style': 'body'}, 'layout': {'width': {'hug': 40}, 'height': {'hug': 16}}},
    },
  }),
};

Future<DesignSystem> _load([List<String>? problems]) => DesignSystem.load((ref) async => _files[ref], problems: problems);

void main() {
  test('a design system loads from its folder: documents, tokens and components', () async {
    final problems = <String>[];
    final ds = await _load(problems);
    expect(problems, isEmpty);
    expect(ds.id, 'acme');
    expect(ds.design, contains('Hairlines'));
    expect(ds.patterns, contains('12 apart'));
    expect(ds.components['Button'], isNotNull);
    expect(ds.tokens.radii['control'], 7);
    expect(ds.tokens.spacing['3'], 12);
    expect(ds.tokens.durations['fast'], 150);
    expect(ds.tokens.curves['standard'], 'easeInOut');
    expect(ds.list.first.purpose, 'A pressable label.');
    expect(ds.list.first.example, {
      'type': 'Button',
      'props': {'label': 'Save'},
      'layout': {'width': {'hug': 72}, 'height': 28},
    });
  });

  test('a missing component file is reported, not thrown', () async {
    final problems = <String>[];
    final ds = await DesignSystem.load(
        (ref) async => ref == 'components/Button.json' ? null : _files[ref], problems: problems);
    expect(ds.components.definitions.keys, ['Toggle']);
    expect(problems.single, contains('components/Button.json'));
  });

  test('one bundle round-trips: what is published is what loads', () async {
    final ds = await _load();
    final again = DesignSystem.fromJson(jsonDecode(jsonEncode(ds.toJson())));
    expect(again.manifest.toJson(), ds.manifest.toJson());
    expect(again.design, ds.design);
    expect(again.components.definitions.keys, ['Button', 'Toggle']);
  });

  test('a site\'s theme is merged over the tokens, key by key', () async {
    final ds = await _load();
    final site = ThemeTokens.fromJson({
      'primary': '#FF7C3AED',
      'spacing': {'3': 16},
    });
    final theme = ds.themeUnder(site);
    expect(theme.primary, const Color(0xFF7C3AED));
    expect(theme.onSurface, const Color(0xFF111827));
    expect(theme.spacing, {'2': 8.0, '3': 16.0});
    expect(theme.radii['panel'], 8);
  });

  test('dark shadows replace the light ones in dark mode', () async {
    final ds = await _load();
    expect(ds.tokens.shadows['level1']!.single.color, const Color(0x0D000000));
    expect(ds.tokens.forBrightness(dark: true).shadows['level1']!.single.color, const Color(0x4D000000));
  });

  test('the named scales round-trip through the theme\'s JSON and are read as theme values', () {
    final t = ThemeTokens.fromJson(jsonDecode(_files['design_system.json']!)['theme']);
    expect(ThemeTokens.fromJson(t.toJson()), t);
    expect(t.toJson()['radii'], {'control': 7, 'panel': 8});
  });

  test('a site names its design system in site.json', () {
    final m = SiteManifest.fromJson({'schema': 3, 'pages': ['home.json'], 'designSystem': '../design_systems/acme'});
    expect(m.designSystem, '../design_systems/acme');
    expect(m.toJson()['designSystem'], '../design_systems/acme');
    expect(m.extra, isEmpty);
  });

  group('validation', () {
    test('a theme\'s scales must be numbers, shadows lists of effects and curves Flutter\'s', () {
      final problems = validateTheme({
        'spacing': {'md': 'big'},
        'curves': {'standard': 'bouncy'},
        'shadows': {'level1': 'soft'},
      });
      expect(problems.map((d) => d.path), containsAll(['/theme/spacing/md', '/theme/curves/standard', '/theme/shadows/level1']));
    });

    test('a binding naming a scale step the theme does not have is unknown_theme_name, with the nearest', () async {
      final ds = await _load();
      final page = {
        'schema': 3,
        'roots': ['c'],
        'nodes': {
          'c': {'type': 'canvas', 'slots': {'body': 'col'}, 'layout': {'width': 390, 'height': 844}},
          'col': {
            'type': 'column',
            'layout': {'width': {'fill': 390}, 'height': {'fill': 844}},
            'bind': {'layout.padding': r'${theme.spacing.3}', 'props.spacing': r'${theme.spacing.4}'},
          },
        },
      };
      final d = validateDocument(page, options: ValidateOptions(theme: ds.tokens, components: ds.components));
      final unknown = d.where((x) => x.code.name == 'unknown_theme_name').toList();
      expect(unknown, hasLength(1));
      expect(unknown.single.message, contains('"4"'));
    });

    test('a call to a design system component is checked against its declaration', () async {
      final ds = await _load();
      final page = {
        'schema': 3,
        'roots': ['c'],
        'nodes': {
          'c': {'type': 'canvas', 'slots': {'body': 'ok'}, 'layout': {'width': 390, 'height': 844}},
          'ok': {'type': 'Button', 'props': {'variant': 'loud'}, 'layout': {'width': 96, 'height': 28}},
        },
      };
      final d = validateDocument(page, options: ValidateOptions(theme: ds.tokens, components: ds.components));
      expect(d.map((x) => x.code.name), containsAll(['missing_prop', 'invalid_enum']));
    });

    test('the strict edit check of a session with a design system knows its tokens and its components', () async {
      final ds = await _load();
      final check = strictEditCheck(ValidateOptions(theme: ds.tokens, components: ds.components));
      final catalog = ds.catalogOver(Catalog.core);
      final r = applyOps(LayoutDocument(catalog: catalog), [
        {'op': 'roots', 'roots': ['c']},
        {'op': 'set', 'id': 'c', 'node': {'type': 'canvas', 'slots': {'body': 'col'}, 'layout': {'width': 390, 'height': {'hug': 200}}}},
        {
          'op': 'set',
          'id': 'col',
          'node': {
            'type': 'column',
            'children': ['save', 'title'],
            'layout': {'width': {'fill': 390}, 'height': {'hug': 200}},
            'decoration': {'fills': [{'color': 'border'}]},
          },
        },
        {'op': 'set', 'id': 'save', 'node': {'type': 'Button', 'props': {'label': 'Save'}, 'layout': {'width': 96, 'height': 28}}},
        {'op': 'set', 'id': 'title', 'node': {'type': 'text', 'props': {'text': 'Hi', 'style': 'body'}, 'layout': {'width': 40, 'height': 16}}},
        {'op': 'set', 'id': 'bad', 'node': {'type': 'text', 'props': {'text': 'No', 'style': {'color': 'nope'}}}, 'parent': 'col'},
      ], catalog: catalog, check: check);
      expect(r.errors.map((d) => '${d.op} ${d.code}'), ['5 unknown_theme_name']);
      expect(r.applied, [0, 1, 2, 3, 4]);
    });

    test('an agent session with a design system may call its components (the trust profile allows them)', () async {
      final ds = await _load();
      final catalog = ds.catalogOver(Catalog.core);
      final ops = [
        {'op': 'roots', 'roots': ['c']},
        {'op': 'set', 'id': 'c', 'node': {'type': 'canvas', 'slots': {'body': 'save'}, 'layout': {'width': 390, 'height': 100}}},
        {'op': 'set', 'id': 'save', 'node': {'type': 'Button', 'props': {'label': 'Save'}, 'layout': {'width': 96, 'height': 28}}},
      ];
      final plain = applyOps(LayoutDocument(catalog: catalog), ops, catalog: catalog, profile: TrustProfile.agent);
      expect(plain.errors.map((d) => d.code), ['capability_not_allowed']);
      final profile = TrustProfile.agent.withComponents(ds.components);
      final r = applyOps(LayoutDocument(catalog: catalog), ops, catalog: catalog, profile: profile);
      expect(r.errors, isEmpty);
      // The catalog an agent is described with keeps them too.
      expect(profile.restrict(catalog).widgets.map((w) => w.type), containsAll(['Button', 'Toggle', 'text']));
      // A profile that allows every type stays as it is.
      expect(identical(TrustProfile.none.withComponents(ds.components), TrustProfile.none), isTrue);
    });
  });

  group('the prompt generated from it', () {
    test('lists its principles in brief, its tokens by name and its components with a call', () async {
      final ds = await _load();
      final prompt = runtimeStarter(designSystem: ds);
      expect(prompt, contains('## The design system: Acme'));
      expect(prompt, contains('Hairlines, not shadows.'));
      expect(prompt, isNot(contains('Long prose.')));
      expect(prompt, contains('`radii.control`'.replaceAll('radii.', '')));
      expect(prompt, contains(r'${theme.spacing.2}'));
      // A step is shown as the binding to write: models wrote the bare
      // `${theme.radii.panel}` as a radius's value, which is rejected.
      expect(prompt, contains(r'bound, not written: `"bind": {"decoration.radius": "${theme.radii.'));
      expect(prompt, contains('**`Button`**: A pressable label.'));
      expect(prompt, contains('{"type":"Button","props":{"label":"Save"}'));
      expect(prompt, contains('A form is a column of fields 12 apart.'));
    });

    test('a variable parameter is described and called with the name of a variable, not a value', () async {
      final ds = await _load();
      final prompt = runtimeStarter(designSystem: ds);
      expect(prompt, contains('`value` the name of your bool variable'));
      expect(prompt, contains('{"type":"Toggle","props":{"value":"value"}'));
    });

    test('drops the base controls its components replace, and says so', () async {
      final ds = await _load();
      final without = runtimeStarter();
      final withDs = runtimeStarter(designSystem: ds);
      expect(without, contains('[`filledButton`]'.replaceAll('[', '').replaceAll(']', '')));
      expect(RegExp(r'^\| `filledButton`', multiLine: true).hasMatch(withDs), isFalse);
      expect(RegExp(r'^\| `outlinedButton`', multiLine: true).hasMatch(withDs), isTrue);
      expect(withDs, contains('Acme\'s components stand in for `filledButton`, `textButton`'));
      expect(without, isNot(contains('The design system')));
    });

    test('ui_docs answers its documents and each component in full', () async {
      final ds = await _load();
      expect(docsTopic('design', designSystem: ds), contains('Long prose.'));
      expect(docsTopic('patterns', designSystem: ds), contains('12 apart'));
      final button = docsTopic('Button', designSystem: ds);
      expect(button, contains('| `variant` | primary|ghost | `"primary"` |'));
      expect(button, contains('Events: `onPressed`'));
      // Everything else is the reference, as before.
      expect(docsTopic('forms', designSystem: ds), docsTopic('forms'));
    });
  });
}
