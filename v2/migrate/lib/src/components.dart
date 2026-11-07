// v1 components → v2 (DESIGN.md §4.2): a node's component marker
// (`componentId`, `markerType`, `componentVersion`, `componentSchema`) becomes
// its `component` link, and a stored `CustomComponent` / `PublicComponent`
// becomes a `ComponentDefinition`.
import 'package:codelessly_api/codelessly_api.dart';

import 'migrate.dart';
import 'types/registry.dart';
import 'bindings.dart';

/// [m]'s component link as v2 JSON (`Node.component`), or null when it's
/// not linked; takes the v1 keys.
Json? migrateComponentLink(V1Node m) {
  for (final k in const ['componentId', 'markerType', 'componentVersion', 'componentSchema']) {
    m.take(k);
  }
  final n = m.n;
  final id = n.componentId;
  if (id == null || id.isEmpty || n.markerType == null) return null;
  final settings = migrateComponentSchema(n.componentSchema, m.nodes, m.report);
  return {
    'id': id,
    if (n.markerType == ComponentMarkerType.component) 'role': 'main',
    if (n.componentVersion != 1) 'version': n.componentVersion,
    if (settings.isNotEmpty) 'settings': settings,
  };
}

/// A v1 `componentSchema` (`{"properties": [...]}`) as v2 settings: each
/// property's `path`/`paths` (`nodeId.field.sub`, v1 field paths) become
/// targets on binding paths, a `group` keeps its own.
List<Json> migrateComponentSchema(Object? schema, Map<String, BaseNode> nodes, MigrationReport report) {
  final props = schema is Map ? schema['properties'] : schema;
  return [
    if (props is List)
      for (final p in props)
        if (p is Map) _setting(p.cast<String, Object?>(), nodes, report),
  ];
}

const _settingKeys = {'label', 'type', 'description', 'path', 'paths', 'value', 'properties'};

Json _setting(Map<String, Object?> p, Map<String, BaseNode> nodes, MigrationReport report) {
  final type = p['type'] is String ? p['type'] as String : 'string';
  final paths = [
    if (p['path'] case final String path) path,
    if (p['paths'] case final List paths) ...paths.whereType<String>(),
  ];
  final settings = type == 'group' ? migrateComponentSchema(p, nodes, report) : const <Json>[];
  return {
    if (p['label'] case final Object label) 'label': '$label',
    'type': type,
    if (p['description'] case final String d) 'description': d,
    if (paths.isNotEmpty) 'targets': [for (final path in paths) settingTarget(path, nodes, report)],
    if (p.containsKey('value') && p['value'] != null) 'value': p['value'],
    if (settings.isNotEmpty) 'settings': settings,
    for (final e in p.entries)
      if (!_settingKeys.contains(e.key)) e.key: e.value,
  };
}

/// A v1 setting path (`nodeId.properties.label`, `nodeId.cornerRadius`,
/// `nodeId.fills.0.color`) as a v2 target `{node, path}` on the node's
/// binding paths (§5.1); one without a v2 path keeps it as `v1`.
Json settingTarget(String v1Path, Map<String, BaseNode> nodes, MigrationReport report) {
  final segments = v1Path.split('.');
  final id = segments.removeAt(0);
  final n = nodes[id];
  String? path;
  if (n != null && segments.isNotEmpty) {
    final own = segments.first == 'properties' && segments.length > 1;
    final key = own ? segments[1] : segments.first;
    final rest = segments.skip(own ? 2 : 1);
    final v2Type = typeMigrations[n.type]?.type(n) ?? v2TypeOf(n);
    final base = switch (key) {
      'characters' when n is TextNode => 'props.text',
      'fills' when rest.isNotEmpty && n is! TextNode => 'decoration.fills',
      'strokes' when rest.isNotEmpty => 'decoration.strokes',
      _ => v2BindPath(n, v2Type, key),
    };
    if (base != null) {
      path = base + rest.map((s) => int.tryParse(s) != null ? '[$s]' : '.$s').join();
    }
  }
  if (path == null) {
    report.unmappedSettings.update('${n?.type ?? '?'}.${segments.join('.')}', (v) => v + 1, ifAbsent: () => 1);
    return {'node': id, 'v1': segments.join('.')};
  }
  return {'node': id, 'path': path};
}

/// A stored v1 component (`CustomComponent` / `PublicComponent` JSON: `id`,
/// `name`, `version`, `data: {width, height, nodes, variables, conditions,
/// parentId, originalParentId}`, `previewUrl`, `blurhash`, `projectId`,
/// `pageId`, `createdAt`) as a v2 `ComponentDefinition`. Its nodes migrate
/// as a document whose root is the component's top node; other keys (a
/// public component's privacy, tags...) are kept under `v1`.
Json migrateComponent(Map<String, Object?> v1, {MigrationReport? report}) {
  final data = (v1['data'] as Map?)?.cast<String, Object?>() ?? const {};
  final nodes = (data['nodes'] as Map?)?.cast<String, Object?>() ?? const {};
  final root = data['parentId'] is String ? data['parentId'] as String : '';
  final document = migrateDocument(
    {
      'rootNode': {
        'children': [root],
      },
      ...nodes,
    },
    report: report,
    variables: data['variables'],
    conditions: data['conditions'],
  )..remove('schema');
  num n(Object? v) => v is num ? roundNum(v) : 0;
  const known = {'id', 'name', 'version', 'data', 'previewUrl', 'blurhash', 'projectId', 'pageId', 'createdAt'};
  final leftover = {
    for (final e in v1.entries)
      if (!known.contains(e.key)) e.key: e.value,
  };
  return {
    'schema': 2,
    'id': v1['id'],
    if (v1['name'] case final String name when name.isNotEmpty) 'name': name,
    if (v1['version'] case final int version when version != 1) 'version': version,
    if (data['width'] != null || data['height'] != null) 'size': [n(data['width']), n(data['height'])],
    'document': {'schema': 2, ...document},
    if (v1['previewUrl'] != null || (v1['blurhash'] is String && (v1['blurhash'] as String).isNotEmpty))
      'preview': {
        'url': ?v1['previewUrl'],
        if (v1['blurhash'] case final String b when b.isNotEmpty) 'blurhash': b,
      },
    'source': {
      if (v1['projectId'] case final String p when p.isNotEmpty) 'project': p,
      if (v1['pageId'] case final String p when p.isNotEmpty) 'page': p,
      if (data['originalParentId'] case final String p when p.isNotEmpty) 'node': p,
    },
    if (v1['createdAt'] case final int t) 'createdAt': t,
    if (leftover.isNotEmpty) 'v1': leftover,
  }..removeWhere((k, v) => v is Map && v.isEmpty);
}
