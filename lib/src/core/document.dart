import 'package:meta/meta.dart';

import 'catalog.dart';
import 'json.dart';
import 'migrate/migrate.dart';
import 'node.dart';

export 'migrate/migrate.dart' show kSchemaVersion, kOldestSchemaVersion, schemaOf;

/// One step that upgrades a document's JSON from schema `n - 1` to `n`.
typedef SchemaMigration = Json Function(Json document, {MigrationReport? report});

/// Upgrades by the version they produce: 3 is [migrate2to3].
const Map<int, SchemaMigration> schemaMigrations = {3: migrate2to3};

/// A layout: a set of node trees (one per canvas/screen) in one flat map.
@immutable
final class LayoutDocument {
  LayoutDocument({
    this.id = '',
    this.roots = const [],
    Map<String, Node> nodes = const {},
    this.extra = const {},
    this.catalog,
  }) : nodes = Map.unmodifiable(nodes);

  final String id;

  /// Top-level nodes (canvases), in order.
  final List<String> roots;
  final Map<String, Node> nodes;

  /// Keys this version doesn't model (variables, conditions...), kept.
  final Json extra;

  /// The catalog the document was decoded with; null for one built in code.
  /// Not part of its value.
  final Catalog? catalog;

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
        catalog: catalog,
      );

  /// Decodes a document of any schema with [catalog] (default:
  /// [Catalog.current]), upgrading it first: a schema-2 document (or one
  /// with no `schema`) is migrated in memory ([migrate2to3]). Never throws:
  /// entries that aren't nodes are dropped; a node or action type the
  /// catalog doesn't declare is kept as it is.
  static LayoutDocument fromJson(Object? json, {Catalog? catalog}) {
    final c = catalog ?? Catalog.current;
    return identical(c, Catalog.current) ? _fromJson(json, c) : Catalog.run(c, () => _fromJson(json, c));
  }

  static LayoutDocument _fromJson(Object? json, Catalog catalog) {
    var m = readMap(json) ?? const {};
    m = migrateSchema(m);
    final raw = readMap(m['nodes']) ?? const {};
    final nodes = <String, Node>{
      for (final e in raw.entries)
        if (Node.fromJson(e.value, id: e.key, catalog: catalog) case final Node n) e.key: n,
    };
    return LayoutDocument(
      id: readString(m['id']) ?? '',
      roots: [...readStrings(m['roots']).where(nodes.containsKey)],
      nodes: nodes,
      extra: {
        for (final e in m.entries)
          if (!const {'schema', 'id', 'roots', 'nodes'}.contains(e.key)) e.key: e.value,
      },
      catalog: catalog,
    );
  }

  /// [json] upgraded to [kSchemaVersion] (a document with no `schema` is
  /// read as [kOldestSchemaVersion]); [report] collects what changed.
  static Json migrateSchema(Json json, {MigrationReport? report}) {
    var version = schemaOf(json);
    var out = json;
    while (version < kSchemaVersion) {
      version++;
      final step = schemaMigrations[version];
      if (step != null) out = step(out, report: report);
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
