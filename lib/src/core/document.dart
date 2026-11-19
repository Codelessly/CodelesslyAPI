import 'package:meta/meta.dart';

import 'catalog.dart';
import 'json.dart';
import 'node.dart';

/// The schema version this package reads and writes: a document, publish
/// model, bundle or other stored JSON of any other schema is refused
/// ([UnsupportedSchemaException]).
const int kSchemaVersion = 3;

/// Thrown when JSON this package decodes is not of [kSchemaVersion]: its
/// `schema` is another number, or it has none. [message] names the schema
/// found and the one this package reads.
final class UnsupportedSchemaException implements FormatException {
  const UnsupportedSchemaException(this.schema, {this.what = 'The document'});

  /// The `schema` the JSON has: null when it has none.
  final Object? schema;

  /// What was being read, as the message starts: `The document`, `The publish model`.
  final String what;

  @override
  String get message => switch (schema) {
        null => '$what has no "schema"; codelessly_api reads schema $kSchemaVersion only ("schema": $kSchemaVersion).',
        final num n when n == n.toInt() => '$what is in schema ${n.toInt()}; codelessly_api reads schema $kSchemaVersion only.',
        final s => '$what has "schema": ${s is String ? '"$s"' : s}; codelessly_api reads schema $kSchemaVersion only.',
      };

  @override
  Object? get source => null;

  @override
  int? get offset => null;

  @override
  String toString() => 'UnsupportedSchemaException: $message';
}

/// Throws an [UnsupportedSchemaException] (naming [what]) unless [json]'s
/// `schema` is [version] (default [kSchemaVersion]).
void requireSchema(Json json, {String what = 'The document', int version = kSchemaVersion}) {
  final schema = json['schema'];
  if (schema is num && schema == version) return;
  throw UnsupportedSchemaException(schema, what: what);
}

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

  /// Decodes a document of schema [kSchemaVersion] with [catalog] (default:
  /// [Catalog.current]). A map of any other schema, or with no `schema`, is
  /// refused: it throws an [UnsupportedSchemaException] saying the schema
  /// found and the one read. Otherwise it never throws: JSON that is not a
  /// map is an empty document, entries that aren't nodes are dropped, and a
  /// node or action type the catalog doesn't declare is kept as it is.
  static LayoutDocument fromJson(Object? json, {Catalog? catalog}) {
    final c = catalog ?? Catalog.current;
    return identical(c, Catalog.current) ? _fromJson(json, c) : Catalog.run(c, () => _fromJson(json, c));
  }

  static LayoutDocument _fromJson(Object? json, Catalog catalog) {
    final m = readMap(json);
    if (m == null) return LayoutDocument(catalog: catalog);
    requireSchema(m);
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

  Json toJson() => {
        'schema': kSchemaVersion,
        if (id.isNotEmpty) 'id': id,
        'roots': roots,
        'nodes': {for (final e in nodes.entries) e.key: e.value.toJson()..remove('id')},
        ...extra,
      };
}
