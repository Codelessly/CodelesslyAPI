// Hosted plugins: node types and action types declared and implemented as
// data, stored on Codelessly's hosting and downloaded by the SDK at run time
// (docs/design/05-plugins-and-layers.md §5). A shipped app can't download
// compiled Dart, so a hosted plugin's implementation is the model itself: a
// node type is a node tree whose bindings read the plugin node's props
// (`${props.value}`), an action type is an action chain reading its fields as
// `${params.*}`, formula functions are function variables, scripts keep
// their capability lists, and assets are URLs with digests.
//
// Versions, channels, rollouts and blocked versions are the managed
// components' (ManagedComponentMaster, Semver, sdkSatisfies, the digest of
// the stored payload): a plugin master lives at `plugins/{id}`, its versions
// at `plugins/{id}/versions/{n}`. A publish lists the plugins it uses
// ([PublishModelPlugins.plugins]).
//
// Trust: a hosted plugin is data and can do only what a document can do.
// [PluginPackage.problems] refuses a package whose trees or chains use a type
// the host's catalog doesn't declare, or an action needing a capability the
// package doesn't list in [PluginPackage.requires].
import 'dart:convert';

import 'package:meta/meta.dart';

import '../../core/actions.dart';
import '../../core/catalog.dart';
import '../../core/catalog_json.dart';
import '../../core/document.dart';
import '../../core/json.dart';
import '../../core/variables.dart';
import '../publish/publish_model.dart';
import 'managed_components.dart';

/// Where hosted plugin masters are stored (`plugins/{id}`).
const String kPluginsCollection = 'plugins';

/// What a project uses of a hosted plugin: the channel it follows, an
/// optional major pin, and the version (and its digest) the editor built
/// and previewed with. JSON: `{"id": "codelessly.charts", "channel":
/// "stable", "pin": 2, "version": 14, "semver": "2.3.1", "digest": "9f2c…"}`.
@immutable
final class PluginRef {
  const PluginRef({
    required this.id,
    this.channel = ManagedChannel.stable,
    this.pin,
    this.version = 0,
    this.semver = '',
    this.digest = '',
  });

  final String id;
  final ManagedChannel channel;

  /// A major the project stays on; null: the major of [semver].
  final int? pin;

  /// The version number (`plugins/{id}/versions/{n}`) and its semver and
  /// payload digest, as published.
  final int version;
  final String semver, digest;

  /// The type-name prefix this plugin's types share (`codelessly` for
  /// `codelessly.charts`): a node type `codelessly.sparkline` resolves to it.
  String get vendor => id.contains('.') ? id.substring(0, id.indexOf('.')) : id;

  static PluginRef? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null || id.isEmpty) return null;
    return PluginRef(
      id: id,
      channel: readEnum(ManagedChannel.values, m['channel'], ManagedChannel.stable),
      pin: readInt(m['pin']),
      version: readInt(m['version']) ?? 0,
      semver: readString(m['semver']) ?? '',
      digest: readString(m['digest']) ?? '',
    );
  }

  Json toJson() => {
    'id': id,
    if (channel != ManagedChannel.stable) 'channel': channel.name,
    'pin': ?pin,
    if (version != 0) 'version': version,
    if (semver.isNotEmpty) 'semver': semver,
    if (digest.isNotEmpty) 'digest': digest,
  };

  @override
  bool operator ==(Object other) => other is PluginRef && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => 'PluginRef(${toJson()})';
}

/// The version [ref] should run now by [master], under the managed
/// components' rules: same major (the pin, else the published semver's), the
/// channel's pointer raised by rollouts, newest not blocked that the SDK can
/// run. Null: run [PluginRef.version] (the published one).
int? pluginUpdateTarget(PluginRef ref, ManagedComponentMaster master, {String projectId = '', String? sdkVersion}) {
  final major = ref.pin ?? Semver.tryParse(ref.semver)?.major ?? master.versions[ref.version]?.major;
  if (major == null) return null;
  final target = master.resolve(major: major, channel: ref.channel, projectId: projectId, sdkVersion: sdkVersion);
  if (target == null || target == ref.version) return null;
  if (target > ref.version || master.blocked.contains(ref.version)) return target;
  return null;
}

/// One immutable release of a hosted plugin (`plugins/{id}/versions/{n}`),
/// stored as a managed component version is: `{"schema": 3, "id", "version",
/// "semver", "minSdk", "payload", "digest", "changelog", "createdAt"}`, where
/// `payload` is the package's JSON text and `digest` the sha256 hex of its
/// UTF-8 bytes.
@immutable
final class PluginVersion {
  const PluginVersion({
    required this.id,
    required this.version,
    required this.payload,
    this.semver = '',
    this.minSdk = '',
    this.digest = '',
    this.changelog = '',
    this.createdAt,
  });

  /// [package] as a release: its payload text encoded now ([digest] is the
  /// caller's to set, sha256 of [payload]).
  factory PluginVersion.of(PluginPackage package, {required int version, String digest = ''}) => PluginVersion(
    id: package.id,
    version: version,
    payload: jsonEncode(package.toJson()),
    semver: package.semver,
    minSdk: package.minSdk,
    digest: digest,
  );

  final String id;
  final int version;
  final String semver, minSdk, changelog;

  /// The package's JSON text: the bytes [digest] is over.
  final String payload;

  /// The sha256 hex digest of [payload]'s UTF-8 bytes.
  final String digest;
  final int? createdAt;

  int get major => Semver.tryParse(semver)?.major ?? 0;

  /// The package; null when the payload isn't one.
  PluginPackage? get package {
    try {
      return PluginPackage.fromJson(jsonDecode(payload));
    } catch (_) {
      return null;
    }
  }

  static PluginVersion? fromJson(Object? json, {String? id, int? version}) {
    final m = readMap(json);
    final pid = id ?? readString(m?['id']);
    final n = version ?? readInt(m?['version']);
    final payload = readString(m?['payload']) ?? (m?['package'] is Map ? jsonEncode(m!['package']) : null);
    if (m == null || pid == null || pid.isEmpty || n == null || payload == null) return null;
    return PluginVersion(
      id: pid,
      version: n,
      payload: payload,
      semver: readString(m['semver']) ?? '',
      minSdk: readString(m['minSdk']) ?? '',
      digest: readString(m['digest']) ?? '',
      changelog: readString(m['changelog']) ?? '',
      createdAt: readInt(m['createdAt']),
    );
  }

  Json toJson() => {
    'schema': kSchemaVersion,
    'id': id,
    'version': version,
    if (semver.isNotEmpty) 'semver': semver,
    if (minSdk.isNotEmpty) 'minSdk': minSdk,
    'payload': payload,
    if (digest.isNotEmpty) 'digest': digest,
    if (changelog.isNotEmpty) 'changelog': changelog,
    'createdAt': ?createdAt,
  };
}

/// A node type's implementation: a document with one root (as a component
/// definition's), the plugin node's slots grafted where [slots] says, and the
/// events its tree fires (`{"type": "componentEvent", "event": "onSelect"}`
/// runs the plugin node's reactions to that trigger).
@immutable
final class PluginWidget {
  const PluginWidget({required this.document, this.slots = const {}, this.events = const []});

  /// The tree, as JSON (`{"roots": ["root"], "nodes": {...}}`): decoded with
  /// the host's catalog when it is used ([decode]).
  final Json document;

  /// The plugin node's slot → the tree's node that hosts it.
  final Map<String, String> slots;

  /// The events it fires: `{"key": "onSelect", "payload": {...}}`.
  final List<Json> events;

  /// The tree decoded with [catalog].
  LayoutDocument decode(Catalog catalog) => LayoutDocument.fromJson(document, catalog: catalog);

  static PluginWidget? fromJson(Object? json) {
    final m = readMap(json);
    final doc = readMap(m?['document']);
    if (m == null || doc == null) return null;
    return PluginWidget(
      document: doc,
      slots: {
        for (final e in (readMap(m['slots']) ?? const {}).entries)
          if (e.value is String) e.key: e.value as String,
      },
      events: [...?readList(m['events'])?.map(readMap).nonNulls],
    );
  }

  Json toJson() => {
    'document': document,
    if (slots.isNotEmpty) 'slots': slots,
    if (events.isNotEmpty) 'events': events,
  };
}

/// An action type's implementation: a chain of actions reading the plugin
/// action's fields as `${params.<key>}`.
@immutable
final class PluginAction {
  const PluginAction({required this.chain});

  /// The chain, as JSON: decoded with the host's catalog ([decode]).
  final List<Json> chain;

  List<ActionDef> decode(Catalog catalog) => ActionDef.listFromJson(chain, catalog: catalog);

  static PluginAction? fromJson(Object? json) {
    final m = readMap(json);
    final chain = readList(m?['chain']);
    if (m == null || chain == null) return null;
    return PluginAction(chain: [...chain.map(readMap).nonNulls]);
  }

  Json toJson() => {'chain': chain};
}

/// A file a plugin uses (`${assets.<name>}`): its URL and the sha256 of its
/// bytes.
@immutable
final class PluginAsset {
  const PluginAsset({required this.url, this.digest = ''});
  final String url, digest;

  static PluginAsset? fromJson(Object? json) {
    final m = readMap(json);
    final url = readString(m?['url']);
    if (m == null || url == null || url.isEmpty) return null;
    return PluginAsset(url: url, digest: readString(m['digest']) ?? '');
  }

  Json toJson() => {'url': url, if (digest.isNotEmpty) 'digest': digest};
}

/// A hosted plugin's payload (§5.1): its declarations ([catalog], JSON in
/// `Catalog.toJson`'s form) and their implementation as data.
///
/// ```json
/// {"schema": 3, "id": "acme.stars", "semver": "1.0.0", "minSdk": "25.0.0", "requires": [],
///  "catalog": {"widgets": [{"type": "acme.rating", "props": [...]}], "actions": [...]},
///  "implementation": {
///    "widgets": {"acme.rating": {"document": {"roots": ["root"], "nodes": {...}}}},
///    "actions": {"acme.cheer": {"chain": [{"type": "setVariable", "variable": "${params.variable}", ...}]}},
///    "formulas": [{"name": "clamp01", "parameters": ["v"], "formula": "min(1, max(0, v))"}],
///    "scripts": [{"name": "qr", "source": "...", "capabilities": []}],
///    "assets": {"chime": {"url": "https://.../chime.mp3", "digest": "ab12…"}}}}
/// ```
@immutable
final class PluginPackage {
  const PluginPackage({
    required this.id,
    this.semver = '',
    this.minSdk = '',
    this.requires = const [],
    this.catalogJson = const {},
    this.widgets = const {},
    this.actions = const {},
    this.formulas = const [],
    this.scripts = const [],
    this.assets = const {},
    this.extra = const {},
  });

  final String id, semver, minSdk;

  /// The capabilities its implementation uses (`api`, `cloud`, `auth`,
  /// `storage`, `sound`...): a host refuses a plugin asking more than it
  /// allows.
  final List<String> requires;

  /// Its declarations as JSON.
  final Json catalogJson;
  final Map<String, PluginWidget> widgets;
  final Map<String, PluginAction> actions;

  /// Formula functions: function variables (a formula and parameters).
  final List<Variable> formulas;

  /// Scripts (`ScriptDef` JSON, with their capability lists).
  final List<Json> scripts;
  final Map<String, PluginAsset> assets;
  final Json extra;

  /// Its declarations: node types and action types with their fields. Its
  /// action types have no Dart class: they decode as [DeclaredAction]s.
  Catalog get catalog => _catalogs[this] ??= catalogFromJson({...catalogJson, 'id': id});
  static final Expando<Catalog> _catalogs = Expando();

  /// What keeps a host with [host] (its catalog, without this plugin) from
  /// running this package, as messages; empty: it can. A tree may use the
  /// host's node and action types and this plugin's own; an action's
  /// declared capabilities must be among [requires], and [requires] among
  /// [allowed] (null: any).
  List<String> problems(Catalog host, {Set<String>? allowed}) {
    final out = <String>[];
    final all = host + catalog;
    if (allowed != null) {
      for (final r in requires) {
        if (!allowed.contains(r)) out.add('$id requires "$r", which the app does not allow');
      }
    }
    void action(ActionDef a, String where) {
      final spec = all.action(a.type);
      if (a is UnknownAction || spec == null) {
        out.add('$where: action type "${a.type}" is not in the app\'s catalog');
        return;
      }
      for (final r in spec.requires) {
        if (!requires.contains(r)) out.add('$where: ${a.type} needs "$r", which $id does not list in requires');
      }
    }

    for (final s in catalog.widgets) {
      if (!widgets.containsKey(s.type)) out.add('$id declares node type ${s.type} without an implementation');
    }
    for (final s in catalog.actions) {
      if (!actions.containsKey(s.type)) out.add('$id declares action type ${s.type} without an implementation');
    }
    for (final e in widgets.entries) {
      final doc = e.value.decode(all);
      if (doc.roots.length != 1) out.add('${e.key}: its document has ${doc.roots.length} roots, not one');
      for (final n in doc.nodes.values) {
        if (all.widget(n.type) == null) out.add('${e.key}: node type "${n.type}" is not in the app\'s catalog');
        if (n.type == e.key) out.add('${e.key}: contains itself');
        for (final r in n.actions) {
          for (final a in r.allActions) {
            if (a.type != kComponentEventAction) action(a, e.key);
          }
        }
      }
    }
    for (final e in actions.entries) {
      for (final a in e.value.decode(all)) {
        for (final n in a.selfAndNested) {
          action(n, e.key);
        }
      }
    }
    return out;
  }

  static const _keys = {'schema', 'id', 'semver', 'minSdk', 'requires', 'catalog', 'implementation'};

  /// Null without an id.
  static PluginPackage? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null || id.isEmpty) return null;
    final impl = readMap(m['implementation']) ?? const {};
    return PluginPackage(
      id: id,
      semver: readString(m['semver']) ?? '',
      minSdk: readString(m['minSdk']) ?? '',
      requires: readStrings(m['requires']),
      catalogJson: readMap(m['catalog']) ?? const {},
      widgets: {
        for (final e in (readMap(impl['widgets']) ?? const {}).entries)
          if (PluginWidget.fromJson(e.value) case final PluginWidget w) e.key: w,
      },
      actions: {
        for (final e in (readMap(impl['actions']) ?? const {}).entries)
          if (PluginAction.fromJson(e.value) case final PluginAction a) e.key: a,
      },
      formulas: [
        for (final f in readList(impl['formulas']) ?? const [])
          if (readMap(f) case final Json fm)
            if (Variable.fromJson({'type': 'text', ...fm, 'name': fm['name']}) case final Variable v) v,
      ],
      scripts: [...?readList(impl['scripts'])?.map(readMap).nonNulls],
      assets: {
        for (final e in (readMap(impl['assets']) ?? const {}).entries)
          if (PluginAsset.fromJson(e.value) case final PluginAsset a) e.key: a,
      },
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
    'schema': kSchemaVersion,
    'id': id,
    if (semver.isNotEmpty) 'semver': semver,
    if (minSdk.isNotEmpty) 'minSdk': minSdk,
    if (requires.isNotEmpty) 'requires': requires,
    'catalog': catalogJson,
    'implementation': {
      if (widgets.isNotEmpty) 'widgets': {for (final e in widgets.entries) e.key: e.value.toJson()},
      if (actions.isNotEmpty) 'actions': {for (final e in actions.entries) e.key: e.value.toJson()},
      if (formulas.isNotEmpty) 'formulas': [for (final f in formulas) f.toJson()],
      if (scripts.isNotEmpty) 'scripts': scripts,
      if (assets.isNotEmpty) 'assets': {for (final e in assets.entries) e.key: e.value.toJson()},
    },
    ...extra,
  };
}

/// The hosted plugins a publish uses (its model's `plugins` key, kept in
/// [PublishModel.extra] so a model without any is unchanged).
extension PublishModelPlugins on PublishModel {
  static const key = 'plugins';

  List<PluginRef> get plugins => [...?readList(extra[key])?.map(PluginRef.fromJson).nonNulls];

  PublishModel withPlugins(List<PluginRef> plugins) => copyWith(extra: {
    for (final e in extra.entries)
      if (e.key != key) e.key: e.value,
    if (plugins.isNotEmpty) key: [for (final p in plugins) p.toJson()],
  });
}
