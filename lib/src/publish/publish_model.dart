import 'package:meta/meta.dart';

import '../document.dart';
import '../json.dart';
import 'app_identity.dart';
import 'breakpoints.dart';
import 'publish_layout.dart';
import 'theme.dart';

/// The schema version of the publish model and bundle this package reads
/// and writes. Layouts carry the document schema ([kSchemaVersion]).
const int kPublishSchemaVersion = 2;

/// Upgrades of a publish model's (or bundle's) JSON for schemas after 2, by
/// the version they produce. 10.x publish data isn't read here: it was
/// converted once.
const Map<int, SchemaMigration> publishSchemaMigrations = {};

/// Where published data comes from: the existing publish paths (owner
/// decision: the format replaced 10.x's publish in place). A converted project's
/// publish model is `publish/{projectId}` (a Firestore document) and each
/// layout `publish/{projectId}/layouts/{layoutId}`, in the current format with
/// `schema: 2`; the preview's and the templates' the same under
/// `publish_preview` and `templates`. A slug's bundle is the storage file
/// `publish/{slug}.json`.
enum PublishSource {
  /// What the project published.
  publish('publish'),

  /// The editor's preview of unpublished changes.
  preview('publish_preview'),

  /// The template gallery.
  template('templates');

  const PublishSource(this.collection);

  /// The root collection (or storage folder) of this source.
  final String collection;

  /// The path of project [projectId]'s publish model.
  String modelPath(String projectId) => '$collection/$projectId';

  /// The path of layout [layoutId] of project [projectId].
  String layoutPath(String projectId, String layoutId) => '$collection/$projectId/layouts/$layoutId';

  /// The path of the bundle (model and every layout, one file) published for
  /// [slug] (or a project id).
  String bundlePath(String slug) => '$collection/$slug.json';
}

/// A canvas (screen) of a published layout, as the model lists it: enough
/// to route to it before its layout is loaded.
@immutable
final class PublishCanvas {
  const PublishCanvas({required this.id, this.name = '', this.path});

  final String id;

  /// The screen's name (a screen can be opened by name, loosely matched).
  final String name;

  /// The screen's URL path pattern (`guide/:id`, `docs/*rest`), if it has one.
  final String? path;

  static PublishCanvas? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null) return null;
    final path = readString(m['path']);
    return PublishCanvas(id: id, name: readString(m['name']) ?? '', path: path == null || path.isEmpty ? null : path);
  }

  Json toJson() => {'id': id, if (name.isNotEmpty) 'name': name, 'path': ?path};

  @override
  bool operator ==(Object other) => other is PublishCanvas && other.id == id && other.name == name && other.path == path;

  @override
  int get hashCode => Object.hash(id, name, path);
}

/// What the publish model knows of one layout without loading it.
@immutable
final class PublishLayoutInfo {
  const PublishLayoutInfo({
    required this.id,
    this.pageId = '',
    this.canvases = const [],
    this.fonts = const [],
    this.apis = const [],
    this.lastUpdated,
  });

  final String id;
  final String pageId;

  /// Its canvases, in order.
  final List<PublishCanvas> canvases;

  /// Ids of the fonts it uses: loaded with it.
  final List<String> fonts;

  /// Ids of the APIs it calls.
  final List<String> apis;

  /// When it was last published; a cached layout older than this is stale.
  final DateTime? lastUpdated;

  bool hasCanvas(String canvasId) => canvases.any((c) => c.id == canvasId);

  static PublishLayoutInfo? fromJson(Object? json, {String? id}) {
    final m = readMap(json);
    final key = id ?? readString(m?['id']);
    if (m == null || key == null) return null;
    return PublishLayoutInfo(
      id: key,
      pageId: readString(m['pageId']) ?? '',
      canvases: [...?readList(m['canvases'])?.map(PublishCanvas.fromJson).nonNulls],
      fonts: readStrings(m['fonts']),
      apis: readStrings(m['apis']),
      lastUpdated: readTimestamp(m['lastUpdated']),
    );
  }

  Json toJson() => {
        if (pageId.isNotEmpty) 'pageId': pageId,
        if (canvases.isNotEmpty) 'canvases': [for (final c in canvases) c.toJson()],
        if (fonts.isNotEmpty) 'fonts': fonts,
        if (apis.isNotEmpty) 'apis': apis,
        'lastUpdated': ?lastUpdated?.let(writeTimestamp),
      };

  /// The entry listing a loaded [layout].
  factory PublishLayoutInfo.of(PublishLayout layout) => PublishLayoutInfo(
        id: layout.id,
        pageId: layout.pageId,
        canvases: [
          for (final c in layout.canvasIds)
            PublishCanvas(id: c, name: layout.document[c]?.name ?? '', path: layout.paths[c]),
        ],
        fonts: layout.fonts,
        apis: layout.apis,
        lastUpdated: layout.lastUpdated,
      );

  @override
  bool operator ==(Object other) =>
      other is PublishLayoutInfo &&
      other.id == id &&
      other.pageId == pageId &&
      jsonEquality.equals(other.canvases, canvases) &&
      jsonEquality.equals(other.fonts, fonts) &&
      jsonEquality.equals(other.apis, apis) &&
      other.lastUpdated == lastUpdated;

  @override
  int get hashCode => Object.hash(id, pageId, Object.hashAll(canvases), lastUpdated);
}

/// A font a published layout uses. Fonts of one family register together,
/// so text picks a file by its weight and style.
@immutable
final class PublishFont {
  const PublishFont({required this.id, required this.family, this.weight = 400, this.italic = false, this.url});

  final String id;
  final String family;

  /// 100–900.
  final int weight;
  final bool italic;

  /// Where the font file is (an uploaded font). Null for a font the runtime
  /// fetches by family (Google Fonts).
  final String? url;

  static PublishFont? fromJson(Object? json, {String? id}) {
    final m = readMap(json);
    final key = id ?? readString(m?['id']);
    final family = readString(m?['family']);
    if (m == null || key == null || family == null) return null;
    final url = readString(m['url']);
    return PublishFont(
      id: key,
      family: family,
      weight: (readInt(m['weight']) ?? 400).clamp(100, 900),
      italic: readBool(m['italic']) ?? false,
      url: url == null || url.isEmpty ? null : url,
    );
  }

  Json toJson() => {
        'family': family,
        if (weight != 400) 'weight': weight,
        if (italic) 'italic': true,
        'url': ?url,
      };

  @override
  bool operator ==(Object other) =>
      other is PublishFont &&
      other.id == id &&
      other.family == family &&
      other.weight == weight &&
      other.italic == italic &&
      other.url == url;

  @override
  int get hashCode => Object.hash(id, family, weight, italic, url);

  @override
  String toString() => 'PublishFont($family $weight${italic ? ' italic' : ''})';
}

/// A published project: its layouts (by id, loaded on their own), entry
/// screen, fonts, theme and APIs.
@immutable
final class PublishModel {
  PublishModel({
    required this.projectId,
    this.slug,
    this.entryLayoutId,
    this.entryPageId,
    this.entryCanvasId,
    this.pages = const [],
    this.layouts = const {},
    this.layoutIDMap = const {},
    this.disabledLayouts = const [],
    this.theme = ThemeTokens.none,
    this.fonts = const {},
    this.apis = const {},
    this.variables = const {},
    this.appIdentity,
    Breakpoints? breakpoints,
    this.lastUpdated,
    this.extra = const {},
  }) : breakpoints = breakpoints ?? Breakpoints.defaults;

  final String projectId;

  /// The project's public slug, if it has one.
  final String? slug;

  /// The screen an app opens first when no layout is named.
  final String? entryLayoutId;
  final String? entryPageId;
  final String? entryCanvasId;

  /// The editor pages the layouts come from.
  final List<String> pages;

  /// Every published layout, by id.
  final Map<String, PublishLayoutInfo> layouts;

  /// Custom (developer-friendly) layout ids → layout ids. A layout can be
  /// named by either.
  final Map<String, String> layoutIDMap;

  /// Layouts turned off from the server: not shown.
  final List<String> disabledLayouts;

  /// The project's theme.
  final ThemeTokens theme;

  /// Every font the layouts use, by id.
  final Map<String, PublishFont> fonts;

  /// The APIs the layouts call, as published: api id → API.
  final Json apis;

  /// Variables shared by every screen of the app, as published: variable
  /// id → variable.
  final Json variables;

  /// The app's name, screen titles and description, icons, social card,
  /// manifest and splash; null when it has none.
  final AppIdentity? appIdentity;

  /// The project's breakpoints (DESIGN.md §5.3): which canvas of a screen
  /// shows, which variant a responsive layout shows, and `${screen}`.
  final Breakpoints breakpoints;

  final DateTime? lastUpdated;

  /// Keys this version doesn't model (privacy fields...), kept.
  final Json extra;

  /// The layout [id] names: a layout id, a custom id ([layoutIDMap]) or the
  /// id of a canvas in a layout (a link opens a screen by its canvas). Null
  /// when [id] names none, or names a disabled layout.
  String? resolveLayoutId(String? id) {
    if (id == null || id.isEmpty) return null;
    final mapped = layoutIDMap[id] ?? id;
    String? found;
    if (layouts.containsKey(mapped)) {
      found = mapped;
    } else {
      found = layoutIdForCanvas(id);
    }
    if (found == null || disabledLayouts.contains(found)) return null;
    return found;
  }

  /// The layout holding canvas [canvasId].
  String? layoutIdForCanvas(String canvasId) {
    for (final l in layouts.values) {
      if (l.hasCanvas(canvasId)) return l.id;
    }
    return null;
  }

  /// Canvas [canvasId] as listed.
  PublishCanvas? canvas(String canvasId) {
    for (final l in layouts.values) {
      for (final c in l.canvases) {
        if (c.id == canvasId) return c;
      }
    }
    return null;
  }

  /// The layout holding the screen [screen] names: a canvas or layout id, or
  /// a canvas name compared without case, spaces, dashes or underscores (so
  /// `record-form` opens the screen named "Record form"). Null when it names
  /// none.
  String? layoutIdForScreen(String? screen) {
    if (screen == null || screen.trim().isEmpty) return null;
    final byId = resolveLayoutId(screen);
    if (byId != null) return byId;
    String normalize(String v) => v.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    String decoded;
    try {
      decoded = Uri.decodeComponent(screen);
    } on ArgumentError {
      decoded = screen;
    }
    final wanted = normalize(decoded);
    for (final l in layouts.values) {
      if (disabledLayouts.contains(l.id)) continue;
      for (final c in l.canvases) {
        if (normalize(c.name) == wanted) return l.id;
      }
    }
    return null;
  }

  /// The fonts layout [layoutId] uses.
  List<PublishFont> fontsOf(String layoutId) => [
        for (final id in layouts[layoutId]?.fonts ?? const <String>[]) ?fonts[id],
      ];

  /// Decodes a publish model of any schema, upgrading it first. Never
  /// throws.
  static PublishModel fromJson(Object? json) {
    var m = readMap(json) ?? const {};
    m = migratePublishSchema(m);
    final layouts = readMap(m['layouts']) ?? const {};
    final fonts = readMap(m['fonts']) ?? const {};
    return PublishModel(
      projectId: readString(m['projectId']) ?? '',
      slug: readString(m['slug']),
      entryLayoutId: readString(m['entryLayoutId']),
      entryPageId: readString(m['entryPageId']),
      entryCanvasId: readString(m['entryCanvasId']),
      pages: readStrings(m['pages']),
      layouts: {
        for (final e in layouts.entries)
          if (PublishLayoutInfo.fromJson(e.value, id: e.key) case final PublishLayoutInfo l) e.key: l,
      },
      layoutIDMap: {
        for (final e in (readMap(m['layoutIDMap']) ?? const {}).entries)
          if (e.value is String) e.key: e.value as String,
      },
      disabledLayouts: readStrings(m['disabledLayouts']),
      theme: ThemeTokens.fromJson(m['theme']),
      fonts: {
        for (final e in fonts.entries)
          if (PublishFont.fromJson(e.value, id: e.key) case final PublishFont f) e.key: f,
      },
      apis: readMap(m['apis']) ?? const {},
      variables: readMap(m['variables']) ?? const {},
      appIdentity: AppIdentity.fromJson(m['appIdentity']),
      breakpoints: Breakpoints.fromJson(m['breakpoints']),
      lastUpdated: readTimestamp(m['lastUpdated']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  static const Set<String> _keys = {
    'schema', 'projectId', 'slug', 'entryLayoutId', 'entryPageId', 'entryCanvasId', 'pages', 'layouts', //
    'layoutIDMap', 'disabledLayouts', 'theme', 'fonts', 'apis', 'variables', 'appIdentity', 'breakpoints', 'lastUpdated',
  };

  /// [json] (a publish model or bundle) upgraded to [kPublishSchemaVersion].
  static Json migratePublishSchema(Json json) {
    var version = readInt(json['schema']) ?? kPublishSchemaVersion;
    var out = json;
    while (version < kPublishSchemaVersion) {
      version++;
      final step = publishSchemaMigrations[version];
      if (step != null) out = step(out);
    }
    return out;
  }

  Json toJson() => {
        'schema': kPublishSchemaVersion,
        'projectId': projectId,
        'slug': ?slug,
        'entryLayoutId': ?entryLayoutId,
        'entryPageId': ?entryPageId,
        'entryCanvasId': ?entryCanvasId,
        if (pages.isNotEmpty) 'pages': pages,
        'layouts': {for (final e in layouts.entries) e.key: e.value.toJson()},
        if (layoutIDMap.isNotEmpty) 'layoutIDMap': layoutIDMap,
        if (disabledLayouts.isNotEmpty) 'disabledLayouts': disabledLayouts,
        if (!theme.isEmpty) 'theme': theme.toJson(),
        if (fonts.isNotEmpty) 'fonts': {for (final e in fonts.entries) e.key: e.value.toJson()},
        if (apis.isNotEmpty) 'apis': apis,
        if (variables.isNotEmpty) 'variables': variables,
        'appIdentity': ?appIdentity?.toJson(),
        if (!breakpoints.isDefault) 'breakpoints': breakpoints.toJson(),
        'lastUpdated': ?lastUpdated?.let(writeTimestamp),
        ...extra,
      };

  PublishModel copyWith({
    String? projectId,
    String? slug,
    String? entryLayoutId,
    String? entryPageId,
    String? entryCanvasId,
    List<String>? pages,
    Map<String, PublishLayoutInfo>? layouts,
    Map<String, String>? layoutIDMap,
    List<String>? disabledLayouts,
    ThemeTokens? theme,
    Map<String, PublishFont>? fonts,
    Json? apis,
    Json? variables,
    AppIdentity? appIdentity,
    Breakpoints? breakpoints,
    DateTime? lastUpdated,
    Json? extra,
  }) =>
      PublishModel(
        projectId: projectId ?? this.projectId,
        slug: slug ?? this.slug,
        entryLayoutId: entryLayoutId ?? this.entryLayoutId,
        entryPageId: entryPageId ?? this.entryPageId,
        entryCanvasId: entryCanvasId ?? this.entryCanvasId,
        pages: pages ?? this.pages,
        layouts: layouts ?? this.layouts,
        layoutIDMap: layoutIDMap ?? this.layoutIDMap,
        disabledLayouts: disabledLayouts ?? this.disabledLayouts,
        theme: theme ?? this.theme,
        fonts: fonts ?? this.fonts,
        apis: apis ?? this.apis,
        variables: variables ?? this.variables,
        appIdentity: appIdentity ?? this.appIdentity,
        breakpoints: breakpoints ?? this.breakpoints,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        extra: extra ?? this.extra,
      );
}

/// A publish model with its layouts in one piece: what a slug serves, an
/// app bundles as an asset to run offline, and the migration writes.
///
/// JSON: `{"schema": 2, "model": {...}, "layouts": {"id": {...}}}`.
@immutable
final class PublishBundle {
  const PublishBundle({required this.model, this.layouts = const {}});

  final PublishModel model;
  final Map<String, PublishLayout> layouts;

  static PublishBundle fromJson(Object? json) {
    var m = readMap(json) ?? const {};
    m = PublishModel.migratePublishSchema(m);
    final layouts = readMap(m['layouts']) ?? const {};
    return PublishBundle(
      model: PublishModel.fromJson(m['model']),
      layouts: {
        for (final e in layouts.entries)
          e.key: PublishLayout.fromJson(e.value).let((l) => l.id.isEmpty ? l.copyWith(document: l.document.copyWith(id: e.key)) : l),
      },
    );
  }

  Json toJson() => {
        'schema': kPublishSchemaVersion,
        'model': model.toJson(),
        'layouts': {for (final e in layouts.entries) e.key: e.value.toJson()},
      };
}
