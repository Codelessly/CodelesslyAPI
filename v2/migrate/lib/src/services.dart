// v1 service data → v2 JSON: HTTP APIs (SDK 8.x's `HttpApiData`), the publish
// model's `apis`, data rules and paywall setup. v1's HTTP API model lives in
// the SDK, which this package can't depend on, so it's read as plain JSON
// here, with the same defaults v1's decoder applies.
import 'migrate.dart' show Json;

/// v1 HTTP API keys that are editor or storage metadata: dropped (privacy,
/// project) or kept under `v1` for the editor (folder, timestamps).
const _droppedApiKeys = {'owner', 'teams', 'users', 'roles', 'public', 'privacy', 'project', 'deleted', 'isDraft'};
const _editorApiKeys = {'directory', 'created', 'lastUpdated'};

/// A v1 `HttpApiData` JSON as a v2 `HttpApi` JSON, or null for a deleted
/// API. Unknown keys are kept, so nothing is lost.
Json? migrateHttpApi(Map<Object?, Object?> v1) {
  final m = {for (final e in v1.entries) '${e.key}': e.value};
  if (m['deleted'] == true) return null;
  final out = <String, Object?>{};
  void put(String key, Object? value) {
    if (value != null) out[key] = value;
  }

  if (_string(m['id']) case final String id when id.isNotEmpty) put('id', id);
  if (_string(m['name']) case final String name when name.isNotEmpty) put('name', name);
  final method = _string(m['method']);
  if (method != null && method != 'get' && const {'post', 'put', 'delete', 'patch'}.contains(method)) {
    put('method', method);
  }
  if (_string(m['url']) case final String url when url.isNotEmpty) put('url', url);
  for (final (from, to) in const [('headers', 'headers'), ('queryParams', 'query'), ('formFields', 'form')]) {
    final pairs = _pairs(m[from]);
    if (pairs.isNotEmpty) put(to, pairs);
  }
  if (m['bodyType'] == 'form') put('bodyType', 'form');
  if (_string(m['body']) case final String body when body.isNotEmpty) put('body', body);
  final contentType = _string(m['requestBodyContentType']);
  if (contentType != null && contentType != 'json' && const {'text', 'xml', 'html'}.contains(contentType)) {
    put('contentType', contentType);
  }
  final inputs = [
    for (final v in (m['variables'] is List ? m['variables'] as List : const []))
      if (v is Map && v['name'] is String && (v['name'] as String).isNotEmpty)
        {
          'name': v['name'],
          if (_text(v['value']) case final String d when d.isNotEmpty) 'default': d,
        },
  ];
  if (inputs.isNotEmpty) put('inputs', inputs);

  const consumed = {
    'id', 'name', 'method', 'url', 'headers', 'queryParams', 'formFields', 'bodyType', 'body', //
    'requestBodyContentType', 'variables',
  };
  final editor = <String, Object?>{
    for (final k in _editorApiKeys)
      if (m[k] != null && m[k] != '') k: m[k],
  };
  if (editor.isNotEmpty) out['v1'] = editor;
  for (final e in m.entries) {
    if (consumed.contains(e.key) || _droppedApiKeys.contains(e.key) || _editorApiKeys.contains(e.key)) continue;
    out[e.key] = e.value;
  }
  return out;
}

/// The `services` of a v2 publish model from a v1 `SDKPublishModel` JSON:
/// its `apis` (deleted ones dropped; each keyed by id, without it) and a
/// `paywall` setup when it has one. Empty when there's nothing to carry.
Json migrateServices(Map<Object?, Object?> v1PublishModel) {
  final apis = <String, Object?>{};
  final raw = v1PublishModel['apis'];
  if (raw is Map) {
    for (final e in raw.entries) {
      if (e.value is! Map) continue;
      final api = migrateHttpApi(e.value as Map);
      if (api == null) continue;
      api.remove('id');
      apis['${e.key}'] = api;
    }
  }
  final paywall = v1PublishModel['paywall'] is Map ? migratePaywall(v1PublishModel['paywall'] as Map) : const {};
  return {
    if (apis.isNotEmpty) 'apis': apis,
    if (paywall.isNotEmpty) 'paywall': paywall,
  };
}

/// A v1 paywall setup (`products` / `slots` of `ProductSlot`s, `placements`
/// of `PaywallPlacement`s, legal links) as v2 `PaywallConfig` JSON. The
/// shapes match; empty ids are dropped.
Json migratePaywall(Map<Object?, Object?> v1) {
  List<Json> entries(Object? list, List<String> keys) => [
        for (final e in (list is List ? list : const []))
          if (e is Map && e['id'] is String && (e['id'] as String).isNotEmpty)
            {
              for (final k in keys)
                if (e[k] != null && e[k] != '' && !(e[k] is List && (e[k] as List).isEmpty)) k: e[k],
            },
      ];
  final products = entries(v1['products'] ?? v1['slots'], const ['id', 'iosProductId', 'androidProductId']);
  final placements = entries(v1['placements'], const ['id', 'layoutId', 'productSlots']);
  return {
    if (products.isNotEmpty) 'products': products,
    if (placements.isNotEmpty) 'placements': placements,
    for (final k in const ['termsUrl', 'privacyUrl'])
      if (_string(v1[k]) case final String url when url.isNotEmpty) k: url,
  };
}

/// A v1 data rules document (`data_rules/{projectId}`) as v2 `DataRules`
/// JSON: schemas lose their redundant `name` and default `type`/`required`;
/// empty sections go.
Json migrateDataRules(Map<Object?, Object?> v1) {
  Map<Object?, Object?> map(Object? v) => v is Map ? v : const {};
  final schemas = <String, Object?>{
    for (final e in map(v1['schemas']).entries)
      if (e.value is Map)
        '${e.key}': {
          if (_schemaFields(map(e.value)['fields']) case final List<Json> f when f.isNotEmpty) 'fields': f,
        },
  };
  final collections = {
    for (final e in map(v1['collections']).entries)
      if (e.value is String && e.value != 'app') '${e.key}': e.value,
  };
  final indexes = {
    for (final e in map(v1['indexes']).entries)
      if (e.value is List && (e.value as List).isNotEmpty) '${e.key}': [for (final k in e.value as List) '$k'],
  };
  final roles = {
    for (final e in map(v1['roles']).entries)
      if (e.value is String) '${e.key}': e.value,
  };
  return {
    if (collections.isNotEmpty) 'collections': collections,
    if (schemas.isNotEmpty) 'schemas': schemas,
    if (indexes.isNotEmpty) 'indexes': indexes,
    if (roles.isNotEmpty) 'roles': roles,
  };
}

List<Json> _schemaFields(Object? fields) => [
      for (final f in (fields is List ? fields : const []))
        if (f is Map && f['name'] is String)
          {
            'name': f['name'],
            if (f['type'] is String && f['type'] != 'text') 'type': f['type'],
            if (f['required'] == true) 'required': true,
            if (f['defaultValue'] is String) 'defaultValue': f['defaultValue'],
            if (f['referenceCollection'] is String) 'referenceCollection': f['referenceCollection'],
          },
    ];

List<Json> _pairs(Object? v) => [
      for (final p in (v is List ? v : const []))
        if (p is Map)
          {
            'key': _text(p['key']),
            'value': _text(p['value']),
            if (p['isUsed'] == false) 'enabled': false,
          },
    ];

String? _string(Object? v) => v is String ? v : null;

String _text(Object? v) => v == null ? '' : (v is String ? v : '$v');
