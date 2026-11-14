// A design system as data: what an app's or a generated UI's default look is
// made of, with nothing taken from a host app. It is a component library
// (definitions by reference, doc 06) plus a theme (the tokens) plus the two
// documents an author reads before composing a screen: DESIGN.md (the
// principles) and PATTERNS.md (how screens are put together).
//
// A site names one in its manifest (`"designSystem": "../design_systems/ssui"`):
// its tokens are the site's base theme (the site's own theme is merged over
// them) and its components are callable by type, as the site's own are. A
// generative-UI session is given one: its runtime prompt is generated from
// it ([designSystemPrompt]) and its catalog includes the components.
//
// Flutter: a package of widgets with its `ThemeData` and `ThemeExtension`s
// (shadcn_ui, fluent_ui, macos_ui), plus its README.
import 'dart:convert';

import 'package:meta/meta.dart';

import 'catalog.dart';
import 'props.dart';
import 'document.dart';
import 'json.dart';
import 'sections.dart';
import 'site_fonts.dart';
import 'theme.dart';

/// A design system's manifest (`design_system.json`), loader-agnostic like
/// [SiteManifest]: its id and name, references to its two documents and
/// its component definitions (paths relative to the manifest, or publish
/// ids), its tokens (a theme, the shape of `site.json`'s `theme`), the
/// fonts it ships and the base node types its components stand in for.
///
/// ```json
/// {"schema": 3, "id": "ssui", "name": "Soft SaaS UI", "version": "1.0.0",
///  "design": "DESIGN.md", "patterns": "PATTERNS.md",
///  "theme": {"primary": "#FF2563EB", "colors": {...}, "textStyles": {...}, "spacing": {...}, "radii": {...}},
///  "components": ["components/Button.json", "components/TextInput.json"],
///  "replaces": ["filledButton", "outlinedButton", "textButton", "textField"],
///  "examples": ["examples/gallery.json"]}
/// ```
@immutable
final class DesignSystemManifest {
  const DesignSystemManifest({
    required this.id,
    this.name = '',
    this.version = '',
    this.description = '',
    this.design,
    this.patterns,
    this.theme = ThemeTokens.none,
    this.components = const [],
    this.fonts = const [],
    this.replaces = const [],
    this.examples = const [],
    this.extra = const {},
  });

  /// The file name a design system's folder has its manifest under.
  static const String fileName = 'design_system.json';

  /// Its id (`ssui`): what a site's `designSystem` names when it is
  /// published, and the prefix of its components' publish paths.
  final String id;
  final String name, version;

  /// One sentence: what it looks like and what it is for.
  final String description;

  /// A reference to its principles (`DESIGN.md`): the look, the tokens'
  /// roles, do and don't. Null: none.
  final String? design;

  /// A reference to its patterns (`PATTERNS.md`): how screens are composed
  /// of its components (forms, lists, cards, empty, loading and error
  /// states, density). Null: none.
  final String? patterns;

  /// Its tokens: colors light and dark, text styles, and the named scales
  /// (spacing, radii, sizes, shadows, durations, curves). A site's theme is
  /// merged over them.
  final ThemeTokens theme;

  /// References to its component definitions, in the order its list shows
  /// them.
  final List<String> components;

  /// The font families it ships, files relative to the manifest.
  final List<FontFamily> fonts;

  /// The base node types its components stand in for (`filledButton`,
  /// `textField`): a prompt generated from it lists its components instead of
  /// them. They stay valid in documents.
  final List<String> replaces;

  /// References to example documents (a gallery, sample screens).
  final List<String> examples;

  /// Keys it doesn't model, kept.
  final Json extra;

  static const Set<String> keys = {
    'schema', 'id', 'name', 'version', 'description', 'design', 'patterns', 'theme', 'components', 'fonts', //
    'replaces', 'examples',
  };

  static DesignSystemManifest fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return DesignSystemManifest(
      id: readString(m['id']) ?? '',
      name: readString(m['name']) ?? '',
      version: readString(m['version']) ?? '',
      description: readString(m['description']) ?? '',
      design: readString(m['design']),
      patterns: readString(m['patterns']),
      theme: ThemeTokens.fromJson(m['theme']),
      components: readStrings(m['components']),
      fonts: FontFamily.listFromJson(m['fonts']),
      replaces: readStrings(m['replaces']),
      examples: readStrings(m['examples']),
      extra: {
        for (final e in m.entries)
          if (!keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
        'schema': kSchemaVersion,
        'id': id,
        if (name.isNotEmpty) 'name': name,
        if (version.isNotEmpty) 'version': version,
        if (description.isNotEmpty) 'description': description,
        'design': ?design,
        'patterns': ?patterns,
        if (!theme.isEmpty) 'theme': theme.toJson(),
        if (components.isNotEmpty) 'components': components,
        if (fonts.isNotEmpty) 'fonts': [for (final f in fonts) f.toJson()],
        if (replaces.isNotEmpty) 'replaces': replaces,
        if (examples.isNotEmpty) 'examples': examples,
        ...extra,
      };
}

/// A design system in memory: its manifest, its two documents' text and its
/// component library, whatever loaded them ([load]: a folder, a publish, an
/// asset bundle; [fromJson]: one bundle).
@immutable
final class DesignSystem {
  DesignSystem({
    required this.manifest,
    this.design = '',
    this.patterns = '',
    ComponentLibrary? components,
  }) : components = components ?? ComponentLibrary.empty;

  final DesignSystemManifest manifest;

  /// DESIGN.md's text: its principles.
  final String design;

  /// PATTERNS.md's text: how screens are composed.
  final String patterns;

  /// Its component definitions by type.
  final ComponentLibrary components;

  String get id => manifest.id;
  String get name => manifest.name.isEmpty ? manifest.id : manifest.name;

  /// Its tokens (the theme a site starts from).
  ThemeTokens get tokens => manifest.theme;

  /// The theme of a site that uses it: [site]'s own theme merged over its
  /// tokens (the site's colors, styles and scales win, key by key).
  ThemeTokens themeUnder(ThemeTokens site) => tokens.mergedWith(site);

  /// The component library of a site that uses it: its components and
  /// [site]'s (the site's own of a type wins).
  ComponentLibrary libraryUnder(ComponentLibrary site) =>
      site.isEmpty ? components : ComponentLibrary({...components.definitions, ...site.definitions});

  /// [base] with its components' declarations over it: what documents that
  /// call them decode with.
  Catalog catalogOver(Catalog base) => components.isEmpty ? base : base + components.catalog;

  /// Its components in the manifest's order (then any others), each with
  /// its declaration, one-line purpose and first preview.
  List<DesignSystemComponent> get list {
    final order = [
      for (final ref in manifest.components) _stem(ref),
      for (final t in components.definitions.keys) t,
    ];
    final seen = <String>{};
    return [
      for (final t in order)
        if (seen.add(t))
          if (components[t] case final LayoutDocument d) DesignSystemComponent(d),
    ];
  }

  /// Reads a design system from its manifest's folder (or publish path):
  /// [read] gives the text of a reference relative to it (null when there is
  /// none). The manifest is [DesignSystemManifest.fileName]; its documents
  /// and components are read by their references. [problems] collects
  /// references that could not be read or are not component documents.
  static Future<DesignSystem> load(Future<String?> Function(String ref) read, {List<String>? problems}) async {
    final text = await read(DesignSystemManifest.fileName);
    if (text == null) throw StateError('No ${DesignSystemManifest.fileName}.');
    final manifest = DesignSystemManifest.fromJson(jsonDecode(text));
    Future<String> doc(String? ref) async {
      if (ref == null) return '';
      final t = await read(ref);
      if (t == null) problems?.add('$ref: not found');
      return t ?? '';
    }

    final docs = <LayoutDocument>[];
    for (final ref in manifest.components) {
      final t = await read(ref);
      if (t == null) {
        problems?.add('$ref: not found');
        continue;
      }
      final d = LayoutDocument.fromJson(jsonDecode(t));
      if (!d.isComponent) {
        problems?.add('$ref: not a component document (a "widget" declaration and one root)');
        continue;
      }
      docs.add(d);
    }
    return DesignSystem(
      manifest: manifest,
      design: await doc(manifest.design),
      patterns: await doc(manifest.patterns),
      components: ComponentLibrary.of(docs),
    );
  }

  /// One bundle: `{"manifest": {...}, "design": "...", "patterns": "...",
  /// "components": {"Button": {...document...}}}`, the form a design system
  /// is published and shipped as an asset in.
  static DesignSystem fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    final docs = readMap(m['components']) ?? const {};
    return DesignSystem(
      manifest: DesignSystemManifest.fromJson(m['manifest']),
      design: readString(m['design']) ?? '',
      patterns: readString(m['patterns']) ?? '',
      components: ComponentLibrary.of([
        for (final d in docs.values)
          if (readMap(d) != null) LayoutDocument.fromJson(d),
      ]),
    );
  }

  Json toJson() => {
        'manifest': manifest.toJson(),
        if (design.isNotEmpty) 'design': design,
        if (patterns.isNotEmpty) 'patterns': patterns,
        'components': {for (final e in components.definitions.entries) e.key: e.value.toJson()},
      };

  static String _stem(String ref) {
    final name = ref.split('/').last;
    return name.endsWith('.json') ? name.substring(0, name.length - 5) : name;
  }
}

/// One component of a design system as its list shows it.
@immutable
final class DesignSystemComponent {
  const DesignSystemComponent(this.document);

  /// The definition.
  final LayoutDocument document;

  WidgetSpec get spec => document.widget!;
  String get type => spec.type;

  /// Its purpose: the declaration's first sentence.
  String get purpose {
    final doc = spec.doc.trim();
    final end = RegExp(r'[.!?](\s|$)').firstMatch(doc);
    return end == null ? doc : doc.substring(0, end.start + 1);
  }

  /// A minimal call to it: its first preview's parameters (else its
  /// required ones at their defaults), at its root's design size.
  Json get example {
    final previews = document.previews;
    final props = previews.isNotEmpty
        ? previews.first.props
        : {
            for (final p in spec.props)
              if (p.required) p.key: p.encode(p.defaultValue),
          };
    // A variable parameter is called with the name of a variable (a
    // preview gives its value): the example names one after the parameter.
    final call = {
      for (final e in props.entries) e.key: spec.prop(e.key)?.type.isVariable ?? false ? e.key : e.value,
    };
    final root = document[document.componentRoot!];
    return {
      'type': type,
      if (call.isNotEmpty) 'props': call,
      if (root != null) 'layout': {'width': root.layout.width.toJson(), 'height': root.layout.height.toJson()},
    };
  }
}
