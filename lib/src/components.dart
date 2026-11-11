// Components: a node tree saved to a project's library, placed as
// instances. DESIGN.md §4.2.
//
// A component is a [ComponentDefinition]: its own small layout document (one
// root, its nodes, variables and conditions), stored in the library, not in a
// page. A page holds the node it was made from (its main node) and the
// instances placed from it: each a full copy of the component's nodes with
// their own ids, whose top node carries a [ComponentLink]. Edits to an
// instance's nodes are its overrides; the editor replaces an instance's nodes
// with the component's when the component's version moves on.
import 'package:meta/meta.dart';

import 'document.dart';
import 'json.dart';
import 'managed_components.dart';

/// What a node is to its component.
enum ComponentRole {
  /// The node the component was made from.
  main,

  /// A copy placed from the component.
  instance,
}

/// A node's link to a component (`Node.component`): the component's main
/// node, or the top node of an instance of it.
///
/// JSON (sparse): `{"id": "cmp1", "role": "main", "version": 3,
/// "settings": [...]}`; `role` defaults to `instance`, `version` to 1.
///
/// A linked, Codelessly-managed instance also has [managed] (`"managed":
/// {...}`, [ManagedComponentRef]): [id] is then the managed component's id
/// and [version] the version its nodes (the snapshot) were built from.
@immutable
final class ComponentLink {
  const ComponentLink({
    required this.id,
    this.role = ComponentRole.instance,
    this.version = 1,
    this.settings = const [],
    this.managed,
  });

  /// The component's id (its [ComponentDefinition.id]).
  final String id;
  final ComponentRole role;

  /// The component's version this node was made from or last updated to:
  /// an instance below [ComponentDefinition.version] has an update.
  final int version;

  /// What the component lets an instance customize, aimed at this node's
  /// tree (an instance's targets are its own copies' ids).
  final List<ComponentSetting> settings;

  /// What a managed instance customizes and follows (channel, pin, setting
  /// values by key, slots, events, theme tokens); null for a project
  /// component's link.
  final ManagedComponentRef? managed;

  bool get isMain => role == ComponentRole.main;
  bool get isInstance => role == ComponentRole.instance;

  /// Whether this is an instance of a Codelessly-managed component.
  bool get isManaged => managed != null && isInstance;

  ComponentLink copyWith({
    String? id,
    ComponentRole? role,
    int? version,
    List<ComponentSetting>? settings,
    ManagedComponentRef? managed,
  }) => ComponentLink(
    id: id ?? this.id,
    role: role ?? this.role,
    version: version ?? this.version,
    settings: settings ?? this.settings,
    managed: managed ?? this.managed,
  );

  /// The link with every setting target's node id mapped by [ids] (a copy
  /// of the tree with new ids). Ids [ids] doesn't have are kept.
  ComponentLink remapped(Map<String, String> ids) =>
      copyWith(settings: [for (final s in settings) s.remapped(ids)], managed: managed?.remapped(ids));

  /// Null without an id. Also reads the marker the editor kept in a
  /// node's `extra` before this model (`{"id", "marker": "component" |
  /// "instance", "version"}`).
  static ComponentLink? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null || id.isEmpty) return null;
    final role = switch (m['role'] ?? m['marker']) {
      'main' || 'component' => ComponentRole.main,
      _ => ComponentRole.instance,
    };
    return ComponentLink(
      id: id,
      role: role,
      version: readInt(m['version']) ?? 1,
      settings: ComponentSetting.listFromJson(m['settings']),
      managed: ManagedComponentRef.fromJson(m['managed']),
    );
  }

  Json toJson() => {
    'id': id,
    if (role != ComponentRole.instance) 'role': role.name,
    if (version != 1) 'version': version,
    if (settings.isNotEmpty) 'settings': [for (final s in settings) s.toJson()],
    if (managed != null) 'managed': managed!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is ComponentLink &&
      other.id == id &&
      other.role == role &&
      other.version == version &&
      jsonEquality.equals(other.settings, settings) &&
      other.managed == managed;

  @override
  int get hashCode => Object.hash(id, role, version, Object.hashAll(settings), managed);

  @override
  String toString() => 'ComponentLink(${toJson()})';
}

/// One thing a component lets an instance customize, or a group of them.
///
/// JSON: `{"key": "title", "label": "Title", "type": "string", "value": "Hi",
/// "targets": [{"node": "t1", "path": "props.text"}]}`; a group is
/// `{"type": "group", "label": ..., "settings": [...]}`. The editor's
/// control options (`min`, `max`, `fractionDigits`, `options`,
/// `insetType`...) and unknown keys are kept in [extra].
@immutable
final class ComponentSetting {
  const ComponentSetting({
    this.key = '',
    this.label = '',
    this.type = 'string',
    this.description,
    this.targets = const [],
    this.value,
    this.settings = const [],
    this.extra = const {},
  });

  /// The setting's stable name: what an instance's value is stored under
  /// ([ManagedComponentRef.values]), kept across versions while the label
  /// changes. Empty: [effectiveKey] falls back to the label's slug.
  final String key;

  final String label;

  /// [key], or the slug of [label] (`"Button label"` → `button_label`).
  String get effectiveKey => key.isNotEmpty ? key : settingSlug(label);

  /// The control: `string`, `number` (`int`, `double`), `bool`, `color`,
  /// `radius`, `spacing`, `options`, `icon`..., or `group`.
  final String type;
  final String? description;

  /// The node properties the setting writes (one value, several places).
  final List<SettingTarget> targets;

  /// The component's value (JSON), what resetting an instance restores.
  final Object? value;

  /// A group's settings.
  final List<ComponentSetting> settings;
  final Json extra;

  bool get isGroup => type == 'group';

  ComponentSetting remapped(Map<String, String> ids) => ComponentSetting(
    key: key,
    label: label,
    type: type,
    description: description,
    targets: [for (final t in targets) t.remapped(ids)],
    value: value,
    settings: [for (final s in settings) s.remapped(ids)],
    extra: extra,
  );

  static const _keys = {'key', 'label', 'type', 'description', 'targets', 'value', 'settings'};

  static ComponentSetting? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return ComponentSetting(
      key: readString(m['key']) ?? '',
      label: readString(m['label']) ?? '',
      type: readString(m['type']) ?? 'string',
      description: readString(m['description']),
      targets: [...?readList(m['targets'])?.map(SettingTarget.fromJson).nonNulls],
      value: m['value'],
      settings: listFromJson(m['settings']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  static List<ComponentSetting> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() => {
    if (key.isNotEmpty) 'key': key,
    if (label.isNotEmpty) 'label': label,
    'type': type,
    'description': ?description,
    if (targets.isNotEmpty) 'targets': [for (final t in targets) t.toJson()],
    'value': ?value,
    if (settings.isNotEmpty) 'settings': [for (final s in settings) s.toJson()],
    ...extra,
  };

  @override
  bool operator ==(Object other) => other is ComponentSetting && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// [label] as a setting key: lower case, runs of other characters as `_`.
String settingSlug(String label) =>
    label.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');

/// Where a [ComponentSetting] writes: a node and a binding path into it
/// (DESIGN.md §5.1), as a condition's `set` entries. A field path in the
/// older `properties.*` form that has no binding path is kept as [v1] (the
/// stored key's name).
@immutable
final class SettingTarget {
  const SettingTarget(this.node, this.path, {this.v1});

  final String node;

  /// The binding path (`props.text`, `decoration.fills[0]`), or null when
  /// only [v1] is known.
  final String? path;

  /// A field path in the older `properties.*` form (`properties.label`), kept
  /// when it has no binding path.
  final String? v1;

  SettingTarget remapped(Map<String, String> ids) => SettingTarget(ids[node] ?? node, path, v1: v1);

  static SettingTarget? fromJson(Object? json) {
    final m = readMap(json);
    final node = readString(m?['node']);
    if (m == null || node == null) return null;
    final path = readString(m['path']), v1 = readString(m['v1']);
    return path == null && v1 == null ? null : SettingTarget(node, path, v1: v1);
  }

  Json toJson() => {'node': node, 'path': ?path, 'v1': ?v1};

  @override
  bool operator ==(Object other) =>
      other is SettingTarget && other.node == node && other.path == path && other.v1 == v1;

  @override
  int get hashCode => Object.hash(node, path, v1);

  @override
  String toString() => 'SettingTarget($node, ${path ?? 'v1: $v1'})';
}

/// A component in a project's library: its nodes
/// as a layout document with one root, its design size, and where it was
/// made from.
///
/// JSON: `{"schema": 2, "id", "name", "version", "size": [w, h],
/// "document": {LayoutDocument}, "preview": {"url", "blurhash"},
/// "source": {"project", "page", "node"}, "createdAt": ms}`.
@immutable
final class ComponentDefinition {
  const ComponentDefinition({
    required this.id,
    this.name = '',
    this.version = 1,
    required this.document,
    this.width = 0,
    this.height = 0,
    this.previewUrl,
    this.blurhash = '',
    this.projectId = '',
    this.pageId = '',
    this.sourceNodeId = '',
    this.createdAt,
    this.extra = const {},
  });

  final String id;
  final String name;

  /// Bumped on every update; instances below it have an update.
  final int version;

  /// The component's nodes, its root first in `roots`, with its variables
  /// and conditions.
  final LayoutDocument document;

  /// The design size of the root.
  final double width, height;
  final String? previewUrl;
  final String blurhash;

  /// Where it was made: project, page and the node it was made from.
  final String projectId, pageId, sourceNodeId;

  /// Milliseconds since the epoch, UTC.
  final int? createdAt;
  final Json extra;

  /// The root node's id.
  String? get rootId => document.roots.firstOrNull;

  /// What an instance can customize: the root's settings.
  List<ComponentSetting> get settings => document[rootId ?? '']?.component?.settings ?? const [];

  static const _keys = {'schema', 'id', 'name', 'version', 'size', 'document', 'preview', 'source', 'createdAt'};

  /// Null without an id.
  static ComponentDefinition? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null || id.isEmpty) return null;
    final size = readList(m['size']);
    final preview = readMap(m['preview']) ?? const {};
    final source = readMap(m['source']) ?? const {};
    return ComponentDefinition(
      id: id,
      name: readString(m['name']) ?? '',
      version: readInt(m['version']) ?? 1,
      document: LayoutDocument.fromJson(m['document']),
      width: size != null && size.length == 2 ? readDouble(size[0]) ?? 0 : 0,
      height: size != null && size.length == 2 ? readDouble(size[1]) ?? 0 : 0,
      previewUrl: readString(preview['url']),
      blurhash: readString(preview['blurhash']) ?? '',
      projectId: readString(source['project']) ?? '',
      pageId: readString(source['page']) ?? '',
      sourceNodeId: readString(source['node']) ?? '',
      createdAt: readInt(m['createdAt']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
    'schema': kSchemaVersion,
    'id': id,
    if (name.isNotEmpty) 'name': name,
    if (version != 1) 'version': version,
    if (width != 0 || height != 0) 'size': [writeDouble(width), writeDouble(height)],
    'document': document.toJson(),
    if (previewUrl != null || blurhash.isNotEmpty)
      'preview': {'url': ?previewUrl, if (blurhash.isNotEmpty) 'blurhash': blurhash},
    if (projectId.isNotEmpty || pageId.isNotEmpty || sourceNodeId.isNotEmpty)
      'source': {
        if (projectId.isNotEmpty) 'project': projectId,
        if (pageId.isNotEmpty) 'page': pageId,
        if (sourceNodeId.isNotEmpty) 'node': sourceNodeId,
      },
    'createdAt': ?createdAt,
    ...extra,
  };

  @override
  bool operator ==(Object other) => other is ComponentDefinition && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => Object.hash(id, version);
}
