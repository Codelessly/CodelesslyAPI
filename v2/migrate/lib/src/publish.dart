// v1 publish data (the SDK 8.x `SDKPublishModel` / `SDKPublishLayout` JSON)
// → the v2 publish model and layouts (CodelesslyAPI/v2/lib/src/publish).
//
// A v1 layout keeps each canvas's nodes in its own map (`canvases`: canvas
// id → node id → node), gzipped into `compressedCanvases` when too large
// for one Firestore document. A v2 layout is one layout document whose
// roots are its canvases: the canvases merge into one stored page and go
// through [migrateDocument] together. Per-layout data the v1 model kept in
// lookup maps (`updates.layoutFonts`, `layoutApis`, `layoutCanvases`,
// `canvasPaths`, `variables`, `conditions`) moves next to the layout it
// belongs to.
//
// The result is written to the v2 storage paths (`publish_v2/...`), so apps
// on SDK 8.x keep reading the v1 publish.
import 'dart:convert';
import 'dart:io' show gzip;

import 'package:codelessly_api/codelessly_api.dart' show ThemeTokens, ColorRGBA;

import 'migrate.dart';

/// The v1 key a layout too large for one Firestore document keeps its
/// canvases under, gzipped and base64 encoded, in place of `canvases`.
const String compressedCanvasesKey = 'compressedCanvases';

/// The v2 publish schema written here.
const int publishSchema = 2;

/// Keys of v1 privacy data, kept on the model and each layout (security
/// rules read them).
const Set<String> privacyKeys = {'owner', 'teams', 'users', 'roles', 'public'};

/// [v1Layout] with its compressed canvases expanded into `canvases`.
Json expandCompressedCanvases(Json v1Layout) {
  final zipped = v1Layout[compressedCanvasesKey];
  if (zipped is! String) return v1Layout;
  return {
    for (final e in v1Layout.entries)
      if (e.key != compressedCanvasesKey) e.key: e.value,
    'canvases': jsonDecode(utf8.decode(gzip.decode(base64Decode(zipped)))),
  };
}

/// [v1Layout] with its `canvases` gzipped into [compressedCanvasesKey], as
/// the v1 publisher stores a large layout.
Json compressCanvases(Json v1Layout) {
  final canvases = v1Layout['canvases'];
  if (canvases == null) return v1Layout;
  return {
    for (final e in v1Layout.entries)
      if (e.key != 'canvases') e.key: e.value,
    compressedCanvasesKey: base64Encode(gzip.encode(utf8.encode(jsonEncode(canvases)))),
  };
}

/// Converts one v1 published layout to a v2 publish layout (a layout
/// document with the layout's keys beside it).
///
/// [variables] and [conditions] are the layout's entries of the v1 model's
/// `variables` / `conditions` (`{id, variables: {canvas: {id: var}}}`), and
/// [fonts] / [apis] the font and API ids the v1 model listed for it.
Json migratePublishLayout(
  Json v1Layout, {
  Object? variables,
  Object? conditions,
  Iterable<String> fonts = const [],
  Iterable<String> apis = const [],
  MigrationReport? report,
}) {
  final layout = expandCompressedCanvases(v1Layout);
  final id = layout['id'] is String ? layout['id'] as String : '';
  final canvases = _map(layout['canvases']);
  final breakpoints = [
    for (final b in (layout['breakpoints'] is List ? layout['breakpoints'] as List : const []))
      if (b is Map && b['nodeId'] is String) b,
  ]..sort((a, b) => _num(a['lowerBound'], 0).compareTo(_num(b['lowerBound'], 0)));

  // Canvases in breakpoint order (narrowest first), then the rest.
  final order = <String>[
    for (final b in breakpoints)
      if (canvases.containsKey(b['nodeId'])) b['nodeId'] as String,
  ];
  for (final c in canvases.keys) {
    if (!order.contains(c)) order.add(c);
  }

  final page = <String, Object?>{
    'rootNode': {'children': order},
  };
  final paths = <String, String>{};
  for (final c in order) {
    final nodes = _map(canvases[c]);
    for (final e in nodes.entries) {
      if (e.value is Map) page[e.key] = e.value;
    }
    final path = _map(_map(nodes[c])['properties'])['path'];
    if (path is String && path.trim().isNotEmpty) paths[c] = path.trim();
  }

  final out = migrateDocument(page, id: id, report: report);
  void putString(String key) {
    final v = layout[key];
    if (v is String && v.isNotEmpty) out[key] = v;
  }

  putString('pageId');
  putString('projectId');
  final v2Breakpoints = [
    for (final b in breakpoints)
      if (canvases.containsKey(b['nodeId']))
        {
          'canvas': b['nodeId'],
          if (_num(b['lowerBound'], 0) case final lo when lo > 0) 'minWidth': roundNum(lo),
          if (_num(b['upperBound'], double.infinity) case final hi when hi.isFinite && hi < 1e9) 'maxWidth': roundNum(hi),
        },
  ];
  // A layout of one canvas needs none.
  if (order.length > 1 && v2Breakpoints.isNotEmpty) out['breakpoints'] = v2Breakpoints;
  if (paths.isNotEmpty) out['paths'] = paths;
  final vars = _map(_map(variables)['variables']);
  if (vars.isNotEmpty) out['variables'] = vars;
  final conds = _map(_map(conditions)['conditions']);
  if (conds.isNotEmpty) out['conditions'] = conds;
  final fontIds = {...fonts};
  if (fontIds.isNotEmpty) out['fonts'] = [...fontIds];
  final apiIds = {...apis};
  if (apiIds.isNotEmpty) out['apis'] = [...apiIds];
  final theme = migrateTheme(layout['theme']);
  if (theme != null) out['theme'] = theme;
  if (layout['lastUpdated'] is num) out['lastUpdated'] = (layout['lastUpdated'] as num).round();
  if (layout['hidden'] == true) out['hidden'] = true;
  for (final k in privacyKeys) {
    if (layout.containsKey(k)) out[k] = layout[k];
  }
  return out;
}

/// Converts a v1 publish model, with the layouts it holds (its full JSON:
/// `SDKPublishModel.toFullJson`) and any [layouts] passed beside it (v1
/// layout JSON by id, as stored in `publish/<project>/layouts`), to a v2
/// publish bundle: `{"schema": 2, "model": {...}, "layouts": {...}}`.
///
/// Layouts the model lists but neither holds keep their entry (canvases,
/// paths, fonts) in the model, to be migrated when their v1 layout is.
Json migratePublishModel(Json v1Model, {Map<String, Json> layouts = const {}, MigrationReport? report}) {
  final updates = _map(v1Model['updates']);
  final layoutFonts = _map(updates['layoutFonts']);
  final layoutApis = _map(updates['layoutApis']);
  final layoutCanvases = _map(updates['layoutCanvases']);
  final canvasPaths = _map(updates['canvasPaths']);
  final layoutTimes = _map(updates['layouts']);
  final variables = _map(v1Model['variables']);
  final conditions = _map(v1Model['conditions']);

  final v1Layouts = <String, Json>{
    for (final e in _map(v1Model['layouts']).entries)
      if (e.value is Map) e.key: _map(e.value),
    ...layouts,
  };
  final v2Layouts = <String, Json>{
    for (final e in v1Layouts.entries)
      e.key: migratePublishLayout(
        {'id': e.key, ...e.value},
        variables: variables[e.key],
        conditions: conditions[e.key],
        fonts: _strings(layoutFonts[e.key]),
        apis: _strings(layoutApis[e.key]),
        report: report,
      ),
  };

  final ids = <String>{...v1Layouts.keys, ...layoutTimes.keys, ...layoutCanvases.keys};
  final entries = <String, Object?>{};
  for (final id in ids) {
    final l = v2Layouts[id];
    final List<Json> canvases;
    if (l != null) {
      final nodes = _map(l['nodes']);
      final paths = _map(l['paths']);
      canvases = [
        for (final c in _strings(l['roots']))
          {
            'id': c,
            if (_map(nodes[c])['name'] case final String name when name.isNotEmpty) 'name': name,
            if (paths[c] case final String p) 'path': p,
          },
      ];
    } else {
      canvases = [
        for (final c in _strings(layoutCanvases[id]))
          {'id': c, if (canvasPaths[c] case final String p when p.isNotEmpty) 'path': p},
      ];
    }
    final page = l?['pageId'] ?? _map(v1Layouts[id])['pageId'];
    final time = layoutTimes[id] ?? l?['lastUpdated'];
    entries[id] = {
      if (page is String && page.isNotEmpty) 'pageId': page,
      if (canvases.isNotEmpty) 'canvases': canvases,
      if (_strings(layoutFonts[id]) case final f when f.isNotEmpty) 'fonts': f,
      if (_strings(layoutApis[id]) case final a when a.isNotEmpty) 'apis': a,
      if (time is num) 'lastUpdated': time.round(),
    };
  }

  Object? theme;
  for (final l in v1Layouts.values) {
    theme = migrateTheme(l['theme']);
    if (theme != null) break;
  }

  final model = <String, Object?>{
    'schema': publishSchema,
    'projectId': v1Model['projectId'] is String ? v1Model['projectId'] : '',
    for (final k in const ['entryLayoutId', 'entryPageId', 'entryCanvasId'])
      if (v1Model[k] case final String v when v.isNotEmpty) k: v,
    if (_strings(v1Model['pages']) case final p when p.isNotEmpty) 'pages': p,
    'layouts': entries,
    if (_map(v1Model['layoutIDMap']) case final m when m.isNotEmpty) 'layoutIDMap': m,
    if (_strings(v1Model['disabledLayouts']) case final d when d.isNotEmpty) 'disabledLayouts': d,
    'theme': ?theme,
    if (_map(v1Model['fonts']) case final f when f.isNotEmpty)
      'fonts': {
        for (final e in f.entries)
          if (migrateFont(e.value) case final font?) e.key: font,
      },
    if (_map(v1Model['apis']) case final a when a.isNotEmpty) 'apis': a,
    if (v1Model['lastUpdated'] is num) 'lastUpdated': (v1Model['lastUpdated'] as num).round(),
    for (final k in privacyKeys)
      if (v1Model.containsKey(k)) k: v1Model[k],
  };
  return {'schema': publishSchema, 'model': model, 'layouts': v2Layouts};
}

/// A v1 publish font (`{id, url, family, weight: "w700", style: "Italic"}`)
/// as a v2 one (`{family, weight: 700, italic: true, url}`).
Json? migrateFont(Object? v1Font) {
  final f = _map(v1Font);
  final family = f['family'];
  if (family is! String || family.isEmpty) return null;
  final w = f['weight'];
  final weight = switch (w) {
    final num n => n.round(),
    final String s => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 400,
    _ => 400,
  };
  final style = f['style'];
  final url = f['url'];
  return {
    'family': family,
    if (weight != 400) 'weight': weight.clamp(100, 900),
    if (style is String && style.toLowerCase().contains('italic')) 'italic': true,
    if (url is String && url.isNotEmpty) 'url': url,
  };
}

/// v1 theme tokens (colors as `{r, g, b, a}`) as v2 ones (`#AARRGGBB`); null
/// when there are none.
Json? migrateTheme(Object? v1Theme) {
  final raw = _map(v1Theme);
  if (raw.isEmpty) return null;
  final ThemeTokens t;
  try {
    t = ThemeTokens.fromJson(raw);
  } catch (_) {
    return null;
  }
  String? c(ColorRGBA? v) => v == null ? null : V1Node.rgba(v);
  final out = <String, Object?>{
    'primary': ?c(t.primary),
    'onPrimary': ?c(t.onPrimary),
    'surface': ?c(t.surface),
    'onSurface': ?c(t.onSurface),
    'error': ?c(t.error),
    'success': ?c(t.success),
    'warning': ?c(t.warning),
    'fontFamily': ?t.fontFamily,
    'titleFontFamily': ?t.titleFontFamily,
    'radius': ?t.radius?.let(roundNum),
    'buttonRadius': ?t.buttonRadius?.let(roundNum),
  };
  return out.isEmpty ? null : out;
}

Json _map(Object? v) => v is Map ? {for (final e in v.entries) '${e.key}': e.value} : <String, Object?>{};

List<String> _strings(Object? v) => [if (v is Iterable) ...v.whereType<String>()];

num _num(Object? v, num fallback) => v is num ? v : (v is String ? num.tryParse(v) ?? fallback : fallback);

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
