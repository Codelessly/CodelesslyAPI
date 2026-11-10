import 'package:meta/meta.dart';

import 'json.dart';
import 'node.dart';

/// The schema version this package reads and writes.
const int kSchemaVersion = 2;

/// One step that upgrades a document's JSON from schema `n - 1` to `n`.
typedef SchemaMigration = Json Function(Json document);

/// Upgrades for schemas after 2, by the version they produce. 10.x (API 6.x)
/// data isn't read here: it was converted once.
const Map<int, SchemaMigration> schemaMigrations = {};

/// A layout: a set of node trees (one per canvas/screen) in one flat map.
@immutable
final class LayoutDocument {
  LayoutDocument({
    this.id = '',
    this.roots = const [],
    Map<String, Node> nodes = const {},
    this.extra = const {},
  }) : nodes = Map.unmodifiable(nodes);

  final String id;

  /// Top-level nodes (canvases), in order.
  final List<String> roots;
  final Map<String, Node> nodes;

  /// Keys this version doesn't model (variables, conditions...), kept.
  final Json extra;

  late final Map<String, String> _parents = {
    for (final n in nodes.values)
      for (final c in n.childIds) c: n.id,
  };

  Node? operator [](String id) => nodes[id];

  /// The parent of [id] (derived from children and slots; never stored).
  String? parentOf(String id) => _parents[id];
  Node? parentNodeOf(String id) => _parents[id]?.let((p) => nodes[p]);

  /// [id] and its descendants, depth first.
  Iterable<Node> subtree(String id) sync* {
    final n = nodes[id];
    if (n == null) return;
    yield n;
    for (final c in n.childIds) {
      yield* subtree(c);
    }
  }

  LayoutDocument copyWith({String? id, List<String>? roots, Map<String, Node>? nodes, Json? extra}) => LayoutDocument(
        id: id ?? this.id,
        roots: roots ?? this.roots,
        nodes: nodes ?? this.nodes,
        extra: extra ?? this.extra,
      );

  /// Decodes a document of any schema, upgrading it first. Never throws:
  /// entries that aren't nodes are dropped.
  static LayoutDocument fromJson(Object? json) {
    var m = readMap(json) ?? const {};
    m = migrateSchema(m);
    final raw = readMap(m['nodes']) ?? const {};
    final nodes = <String, Node>{
      for (final e in raw.entries)
        if (Node.fromJson(e.value, id: e.key) case final Node n) e.key: n,
    };
    return LayoutDocument(
      id: readString(m['id']) ?? '',
      roots: [...readStrings(m['roots']).where(nodes.containsKey)],
      nodes: nodes,
      extra: {
        for (final e in m.entries)
          if (!const {'schema', 'id', 'roots', 'nodes'}.contains(e.key)) e.key: e.value,
      },
    );
  }

  /// [json] upgraded to [kSchemaVersion].
  static Json migrateSchema(Json json) {
    var version = readInt(json['schema']) ?? kSchemaVersion;
    var out = json;
    while (version < kSchemaVersion) {
      version++;
      final step = schemaMigrations[version];
      if (step != null) out = step(out);
    }
    return out;
  }

  Json toJson() => {
        'schema': kSchemaVersion,
        if (id.isNotEmpty) 'id': id,
        'roots': roots,
        'nodes': {for (final e in nodes.entries) e.key: e.value.toJson()..remove('id')},
        ...extra,
      };
}
