// Published components (docs/design/06-sections-and-components.md §4.7): a
// project's component definitions published beside its layouts, each its own
// document at `publish/{projectId}/components/{type}`, listed by the publish
// model with its version and digest, so an app loads the components a screen
// calls with the screen, caches each on its own and follows a republished one
// without reloading the pages that call it.
//
// The stored shape:
//
// ```json
// {"schema": 2, "id": "PlanCard", "version": 3, "digest": "9f2c…", "lastUpdated": 1731456000000,
//  "fonts": ["Inter/600/false"], "document": {"schema": 2, "id": "PlanCard", "roots": ["card"], "widget": {...}, "nodes": {...}}}
// ```
//
// `digest` is the sha256 hex of the UTF-8 bytes of [canonicalJson] of
// `document`: the same definition gives the same digest whatever order a
// store keeps its keys in. A model lists each as
// `"components": {"PlanCard": {"version": 3, "digest": "9f2c…", "lastUpdated": …, "fonts": [...]}}`
// and each layout entry the closure it calls (`"components": ["PlansSection", "PlanCard"]`).
import 'package:meta/meta.dart';

import '../../core/catalog.dart';
import '../../core/document.dart';
import '../../core/json.dart';
import '../../core/sections.dart';
import 'publish_layout.dart' show readTimestamp, writeTimestamp;

/// What a publish model knows of one published component without loading
/// it: its version and digest (a cached copy with another digest is stale),
/// when it was published and the fonts its text uses (loaded with the
/// screens that call it).
@immutable
final class PublishComponentInfo {
  const PublishComponentInfo({
    required this.id,
    this.version = 0,
    this.digest = '',
    this.lastUpdated,
    this.fonts = const [],
  });

  /// The component's type name (`PlanCard`).
  final String id;

  /// Its publish count: raised by every publish that changed it.
  final int version;

  /// The sha256 hex of its document's [canonicalJson].
  final String digest;
  final DateTime? lastUpdated;

  /// Ids of the fonts its own text uses (`PublishModel.fonts`).
  final List<String> fonts;

  static PublishComponentInfo? fromJson(Object? json, {String? id}) {
    final m = readMap(json);
    final key = id ?? readString(m?['id']);
    if (m == null || key == null || key.isEmpty) return null;
    return PublishComponentInfo(
      id: key,
      version: readInt(m['version']) ?? 0,
      digest: readString(m['digest']) ?? '',
      lastUpdated: readTimestamp(m['lastUpdated']),
      fonts: readStrings(m['fonts']),
    );
  }

  Json toJson() => {
    if (version != 0) 'version': version,
    if (digest.isNotEmpty) 'digest': digest,
    'lastUpdated': ?lastUpdated?.let(writeTimestamp),
    if (fonts.isNotEmpty) 'fonts': fonts,
  };

  /// The entry listing [component].
  factory PublishComponentInfo.of(PublishComponent component) => PublishComponentInfo(
    id: component.id,
    version: component.version,
    digest: component.digest,
    lastUpdated: component.lastUpdated,
    fonts: component.fonts,
  );

  @override
  bool operator ==(Object other) =>
      other is PublishComponentInfo &&
      other.id == id &&
      other.version == version &&
      other.digest == digest &&
      other.lastUpdated == lastUpdated &&
      jsonEquality.equals(other.fonts, fonts);

  @override
  int get hashCode => Object.hash(id, version, digest, lastUpdated);

  @override
  String toString() =>
      'PublishComponentInfo($id v$version ${digest.isEmpty ? '-' : digest.substring(0, digest.length.clamp(0, 8))})';
}

/// One published component definition (`publish/{p}/components/{id}`): its
/// [document] (a component document: one root, a `widget` declaration) with
/// its version and digest.
@immutable
final class PublishComponent {
  PublishComponent({
    required this.document,
    String? id,
    this.version = 0,
    this.digest = '',
    this.lastUpdated,
    this.fonts = const [],
    this.extra = const {},
  }) : id = id ?? document.componentType ?? document.id,
       _documentJson = null;

  PublishComponent._stored({
    required this.document,
    required this.id,
    required this.version,
    required this.digest,
    required this.lastUpdated,
    required this.fonts,
    required this.extra,
    required Json documentJson,
    // ignore: prefer_initializing_formals
  }) : _documentJson = documentJson;

  /// The document's JSON as stored, when decoded from it: written back as it
  /// was, so the digest stays over the publisher's bytes.
  final Json? _documentJson;

  /// The component's type name.
  final String id;
  final LayoutDocument document;
  final int version;

  /// The sha256 hex of [canonicalJson] of the stored `document` (the
  /// publisher's; [digestInput] is what it is over).
  final String digest;
  final DateTime? lastUpdated;

  /// Ids of the fonts its text uses.
  final List<String> fonts;

  /// Keys this version doesn't model (privacy fields...), kept.
  final Json extra;

  /// Whether [document] is a component definition.
  bool get isComponent => document.isComponent;

  /// The text [digest] is over: [canonicalJson] of the document's JSON (as
  /// stored, when it was decoded from a store).
  String get digestInput => canonicalJson(_documentJson ?? document.toJson());

  static const Set<String> _keys = {'schema', 'id', 'version', 'digest', 'lastUpdated', 'fonts', 'document'};

  /// Decodes a stored component: the document goes through
  /// [LayoutDocument.fromJson] (its schema migrations included) with
  /// [catalog]. Never throws; [id] fills a missing `id`.
  static PublishComponent fromJson(Object? json, {Catalog? catalog, String? id}) {
    final m = readMap(json) ?? const {};
    final raw = readMap(m['document']) ?? const {};
    final document = LayoutDocument.fromJson(raw, catalog: catalog);
    final key = readString(m['id']) ?? id;
    return PublishComponent._stored(
      document: document,
      documentJson: raw,
      id: key == null || key.isEmpty ? (document.componentType ?? document.id) : key,
      version: readInt(m['version']) ?? 0,
      digest: readString(m['digest']) ?? '',
      lastUpdated: readTimestamp(m['lastUpdated']),
      fonts: readStrings(m['fonts']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
    'schema': kSchemaVersion,
    'id': id,
    if (version != 0) 'version': version,
    if (digest.isNotEmpty) 'digest': digest,
    'lastUpdated': ?lastUpdated?.let(writeTimestamp),
    if (fonts.isNotEmpty) 'fonts': fonts,
    'document': _documentJson ?? document.toJson(),
    ...extra,
  };

  PublishComponent copyWith({
    LayoutDocument? document,
    int? version,
    String? digest,
    DateTime? lastUpdated,
    List<String>? fonts,
    Json? extra,
  }) => document == null && _documentJson != null
      ? PublishComponent._stored(
          document: this.document,
          documentJson: _documentJson,
          id: id,
          version: version ?? this.version,
          digest: digest ?? this.digest,
          lastUpdated: lastUpdated ?? this.lastUpdated,
          fonts: fonts ?? this.fonts,
          extra: extra ?? this.extra,
        )
      : PublishComponent(
          document: document ?? this.document,
          id: id,
          version: version ?? this.version,
          digest: digest ?? this.digest,
          lastUpdated: lastUpdated ?? this.lastUpdated,
          fonts: fonts ?? this.fonts,
          extra: extra ?? this.extra,
        );
}
