import 'package:meta/meta.dart';

import '../../core/catalog.dart';
import '../../core/document.dart';
import '../../core/json.dart';
import 'app_identity.dart';
import '../../core/breakpoints.dart';
import 'publish_component.dart';
import 'publish_layout.dart';
import '../../core/theme.dart';

/// The schema version of the publish model and bundle this package reads
/// and writes. Layouts carry the document schema ([kSchemaVersion]).
const int kPublishSchemaVersion = 2;

/// Upgrades of a publish model's (or bundle's) JSON for schemas after 2, by
/// the version they produce.
const Map<int, SchemaMigration> publishSchemaMigrations = {};

/// Where published data comes from. A project's
/// publish model is `publish/{projectId}` (a Firestore document), each
/// layout `publish/{projectId}/layouts/{layoutId}` and each component
/// `publish/{projectId}/components/{type}`, in the current format with
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

  /// The path of component [type] (its type name) of project [projectId]:
  /// a [PublishComponent].
  String componentPath(String projectId, String type) => '$collection/$projectId/components/$type';
}

/// A canvas (screen) of a published layout, as the model lists it: enough
/// to route to it before its layout is loaded.
@immutable
final class PublishCanvas {
  const PublishCanvas({required this.id, this.name = '', this.path, this.route = ScreenRoute.none});

  final String id;

  /// The screen's name (a screen can be opened by name, loosely matched).
  final String name;

  /// The screen's URL path pattern (`guide/:id`, `docs/*rest`), if it has one.
  final String? path;

  /// How the screen opens from a link: the screen beneath it, and whether
  /// it is drawn over that one (translucent).
  final ScreenRoute route;

  static PublishCanvas? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null) return null;
    final path = readString(m['path']);
    return PublishCanvas(
      id: id,
      name: readString(m['name']) ?? '',
      path: path == null || path.isEmpty ? null : path,
      route: ScreenRoute.fromJson(m) ?? ScreenRoute.none,
    );
  }

  Json toJson() => {'id': id, if (name.isNotEmpty) 'name': name, 'path': ?path, ...route.toJson()};

  @override
  bool operator ==(Object other) =>
      other is PublishCanvas && other.id == id && other.name == name && other.path == path && other.route == route;

  @override
  int get hashCode => Object.hash(id, name, path, route);
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
    this.components = const [],
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

  /// The component types it calls, directly or through others (its
  /// closure, `ComponentLibrary.closureOf`): loaded with it, before it
  /// shows.
  final List<String> components;

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
      components: readStrings(m['components']),
      lastUpdated: readTimestamp(m['lastUpdated']),
    );
  }

  Json toJson() => {
        if (pageId.isNotEmpty) 'pageId': pageId,
        if (canvases.isNotEmpty) 'canvases': [for (final c in canvases) c.toJson()],
        if (fonts.isNotEmpty) 'fonts': fonts,
        if (apis.isNotEmpty) 'apis': apis,
        if (components.isNotEmpty) 'components': components,
        'lastUpdated': ?lastUpdated?.let(writeTimestamp),
      };

  /// The entry listing a loaded [layout]; [components] is the closure of
  /// component types it calls (the publisher's to compute: the layout alone
  /// doesn't know which of its types are components).
  factory PublishLayoutInfo.of(PublishLayout layout, {List<String> components = const []}) => PublishLayoutInfo(
        id: layout.id,
        pageId: layout.pageId,
        canvases: [
          for (final c in layout.canvasIds)
            PublishCanvas(id: c, name: layout.document[c]?.name ?? '', path: layout.paths[c], route: layout.routes[c] ?? ScreenRoute.none),
        ],
        fonts: layout.fonts,
        apis: layout.apis,
        components: components,
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
      jsonEquality.equals(other.components, components) &&
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
    this.overlayLayoutIds = const [],
    this.backdropLayoutIds = const [],
    this.theme = ThemeTokens.none,
    this.fonts = const {},
    this.apis = const {},
    this.variables = const {},
    this.components = const {},
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

  /// The overlay screens ([CanvasProps.overlay]): layouts drawn above every
  /// screen of the app, outside navigation, in order (later on top). Listed
  /// so an app can show them without loading every layout.
  final List<String> overlayLayoutIds;

  /// [overlayLayoutIds] that are published and not disabled.
  List<String> get overlays => [
        for (final id in overlayLayoutIds)
          if (layouts.containsKey(id) && !disabledLayouts.contains(id)) id,
      ];

  /// The backdrop screens ([CanvasProps.backdrop]): layouts drawn once
  /// beneath every screen of the app, outside navigation, in order (later
  /// on top). A layout that is an overlay isn't a backdrop. Listed so an app
  /// can show them without loading every layout.
  final List<String> backdropLayoutIds;

  /// [backdropLayoutIds] that are published, not disabled and not overlays.
  List<String> get backdrops => [
        for (final id in backdropLayoutIds)
          if (layouts.containsKey(id) && !disabledLayouts.contains(id) && !overlayLayoutIds.contains(id)) id,
      ];

  /// The project's theme.
  final ThemeTokens theme;

  /// Every font the layouts use, by id.
  final Map<String, PublishFont> fonts;

  /// The APIs the layouts call, as published: api id → API.
  final Json apis;

  /// Variables shared by every screen of the app, as published: variable
  /// id → variable.
  final Json variables;

  /// The project's published component definitions, by type name: what
  /// the layouts' calls render (each layout lists the ones it needs,
  /// [PublishLayoutInfo.components]).
  final Map<String, PublishComponentInfo> components;

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

  /// The fonts layout [layoutId] uses: its own and those of the
  /// components it calls.
  List<PublishFont> fontsOf(String layoutId) => [
        for (final id in {
          ...?layouts[layoutId]?.fonts,
          for (final c in layouts[layoutId]?.components ?? const <String>[]) ...?components[c]?.fonts,
        })
          ?fonts[id],
      ];

  /// Decodes a publish model of any schema, upgrading it first. Never
  /// throws.
  static PublishModel fromJson(Object? json) {
    var m = readMap(json) ?? const {};
    m = migratePublishSchema(m);
    final layouts = readMap(m['layouts']) ?? const {};
    final fonts = readMap(m['fonts']) ?? const {};
    final components = readMap(m['components']) ?? const {};
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
      overlayLayoutIds: readStrings(m['overlayLayoutIds']),
      backdropLayoutIds: readStrings(m['backdropLayoutIds']),
      theme: ThemeTokens.fromJson(m['theme']),
      fonts: {
        for (final e in fonts.entries)
          if (PublishFont.fromJson(e.value, id: e.key) case final PublishFont f) e.key: f,
      },
      apis: readMap(m['apis']) ?? const {},
      variables: readMap(m['variables']) ?? const {},
      components: {
        for (final e in components.entries)
          if (PublishComponentInfo.fromJson(e.value, id: e.key) case final PublishComponentInfo c) e.key: c,
      },
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
    'layoutIDMap', 'disabledLayouts', 'overlayLayoutIds', 'backdropLayoutIds', 'theme', 'fonts', 'apis', 'variables', 'components', 'appIdentity', 'breakpoints', 'lastUpdated',
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
        if (overlayLayoutIds.isNotEmpty) 'overlayLayoutIds': overlayLayoutIds,
        if (backdropLayoutIds.isNotEmpty) 'backdropLayoutIds': backdropLayoutIds,
        if (!theme.isEmpty) 'theme': theme.toJson(),
        if (fonts.isNotEmpty) 'fonts': {for (final e in fonts.entries) e.key: e.value.toJson()},
        if (apis.isNotEmpty) 'apis': apis,
        if (variables.isNotEmpty) 'variables': variables,
        if (components.isNotEmpty) 'components': {for (final e in components.entries) e.key: e.value.toJson()},
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
    List<String>? overlayLayoutIds,
    List<String>? backdropLayoutIds,
    ThemeTokens? theme,
    Map<String, PublishFont>? fonts,
    Json? apis,
    Json? variables,
    Map<String, PublishComponentInfo>? components,
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
        overlayLayoutIds: overlayLayoutIds ?? this.overlayLayoutIds,
        backdropLayoutIds: backdropLayoutIds ?? this.backdropLayoutIds,
        theme: theme ?? this.theme,
        fonts: fonts ?? this.fonts,
        apis: apis ?? this.apis,
        variables: variables ?? this.variables,
        components: components ?? this.components,
        appIdentity: appIdentity ?? this.appIdentity,
        breakpoints: breakpoints ?? this.breakpoints,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        extra: extra ?? this.extra,
      );
}

/// A publish model with its layouts and components in one piece: what a
/// slug serves, an app bundles as an asset to run offline.
///
/// JSON: `{"schema": 2, "model": {...}, "layouts": {"id": {...}}, "components":
/// {"PlanCard": {...}}}`, each component as stored at
/// [PublishSource.componentPath] ([PublishComponent]).
@immutable
final class PublishBundle {
  const PublishBundle({required this.model, this.layouts = const {}, this.components = const {}, this.extra = const {}});

  final PublishModel model;
  final Map<String, PublishLayout> layouts;

  /// The published component definitions, by type name.
  final Map<String, PublishComponent> components;

  /// Keys this version doesn't model, kept (the managed library's embedded
  /// plugin versions, `plugins`).
  final Json extra;

  static const Set<String> _keys = {'schema', 'model', 'layouts', 'components'};

  /// Its layouts and components decode with [catalog] (default:
  /// `Catalog.current`).
  static PublishBundle fromJson(Object? json, {Catalog? catalog}) {
    var m = readMap(json) ?? const {};
    m = PublishModel.migratePublishSchema(m);
    final layouts = readMap(m['layouts']) ?? const {};
    final components = readMap(m['components']) ?? const {};
    return PublishBundle(
      model: PublishModel.fromJson(m['model']),
      layouts: {
        for (final e in layouts.entries)
          e.key: PublishLayout.fromJson(e.value, catalog: catalog).let((l) => l.id.isEmpty ? l.copyWith(document: l.document.copyWith(id: e.key)) : l),
      },
      components: {
        for (final e in components.entries) e.key: PublishComponent.fromJson(e.value, catalog: catalog, id: e.key),
      },
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
        'schema': kPublishSchemaVersion,
        'model': model.toJson(),
        'layouts': {for (final e in layouts.entries) e.key: e.value.toJson()},
        if (components.isNotEmpty) 'components': {for (final e in components.entries) e.key: e.value.toJson()},
        ...extra,
      };
}
