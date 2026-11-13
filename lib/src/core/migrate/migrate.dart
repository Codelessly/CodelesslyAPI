// The one-time upgrade of a schema-2 document to schema 3: pure JSON in, JSON
// out, composed of small named steps (steps.dart). The model's decoders know
// only the schema-3 shape; a schema-2 document is migrated before it is
// decoded (LayoutDocument.fromJson does it), never written back by a loader.
import '../json.dart';
import 'report.dart';
import 'steps.dart';

export 'report.dart';

/// The schema version this package reads and writes.
const int kSchemaVersion = 3;

/// The oldest schema this package migrates. Anything older (and a document
/// with no `schema`) is read as this one.
const int kOldestSchemaVersion = 2;

/// The schema of document (or publish model, bundle, manifest, package)
/// JSON [json]: its `schema`, or [kOldestSchemaVersion] when it has none.
int schemaOf(Object? json) => readInt(readMap(json)?['schema']) ?? kOldestSchemaVersion;

/// A named, separately tested step of a migration. It changes a node's JSON
/// ([node]) or a document's ([document]) in place, and says what it did
/// through the [MigrationScope] it is given.
final class MigrationStep {
  const MigrationStep({required this.id, required this.description, this.node, this.document});

  /// Stable id, as the report names it (`drag.split`, `action.playAnimation`).
  final String id;
  final String description;

  /// Applied to every node of a document (and to a node given alone).
  final void Function(Json node, MigrationScope scope)? node;

  /// Applied to the document once, before the nodes. Not run for a node
  /// given alone.
  final void Function(Json document, MigrationScope scope)? document;
}

/// What a step reports through, while it runs on one node or document.
final class MigrationScope {
  MigrationScope._(this._report, this.step, this.nodeId);

  /// A scope that reports nothing (a step run to compute a value).
  MigrationScope.silent(this.step)
      : _report = null,
        nodeId = '';

  final MigrationReport? _report;

  /// The step running.
  final MigrationStep step;

  /// The node it runs on; empty for a document step.
  final String nodeId;

  void _add(MigrationEntryKind kind, String path, Object? old, Object? value, String message, String instead) =>
      _report?.add(MigrationEntry(
        kind: kind,
        step: step.id,
        document: _report.document,
        node: nodeId,
        path: path,
        old: old,
        value: value,
        message: message,
        instead: instead,
      ));

  /// A value at [path] rewritten from [old] to [value].
  void rewrite(String path, Object? old, Object? value, [String message = '']) =>
      _add(MigrationEntryKind.rewrite, path, old, value, message.isEmpty ? step.description : message, '');

  /// A value with no schema-3 form: kept in [node] as `legacy.<name>` (no
  /// longer read) and reported with what to write [instead].
  void unconvertible(Json node, String name, Object? value, {required String instead, String path = '', String message = ''}) {
    node['legacy.$name'] = value;
    _add(MigrationEntryKind.unconvertible, path.isEmpty ? '/$name' : path, value, null,
        message.isEmpty ? '`$name` has no schema-3 form; kept as `legacy.$name`.' : message, instead);
  }

  /// A behaviour that renders or acts differently after the migration.
  void behaviourChange(String message, {String path = '', Object? old, Object? value, String instead = ''}) =>
      _add(MigrationEntryKind.behaviourChange, path, old, value, message, instead);
}

/// [json] deep-copied (maps and lists; other values are shared).
Object? copyJson(Object? json) => switch (json) {
      final Map m => <String, Object?>{for (final e in m.entries) '${e.key}': copyJson(e.value)},
      final List l => [for (final v in l) copyJson(v)],
      _ => json,
    };

/// The steps of [migrate2to3], in order.
List<MigrationStep> get schema3Steps => migrationSteps2to3;

/// Upgrades a schema-2 layout document's JSON to schema 3: every legacy key
/// and deprecated field rewritten into the schema-3 form, or kept as
/// `legacy.<name>` and reported when it has none. A document already at
/// schema 3 (or later) is returned as given. Never throws: a step that fails
/// on a node leaves that node as it was before the step and is reported.
/// [report] collects what was done ([MigrationReport.document] names the
/// document).
Json migrate2to3(Json document, {MigrationReport? report, List<MigrationStep>? steps}) {
  if (schemaOf(document) >= 3) return document;
  if (report != null && (report.documents.isEmpty || report.documents.last != report.document)) {
    report.documents.add(report.document);
  }
  final out = copyJson(document) as Json;
  final raw = readMap(out['nodes']);
  final nodes = raw == null ? null : <String, Object?>{for (final e in raw.entries) e.key: e.value};
  if (nodes != null) out['nodes'] = nodes;
  for (final step in steps ?? migrationSteps2to3) {
    if (step.document != null) _guarded(out, step, '', report, step.document!);
    if (step.node != null && nodes != null) {
      for (final e in nodes.entries) {
        // Every map in [out] is a fresh Map<String, Object?> ([copyJson]).
        if (readMap(e.value) case final Json node) _guarded(node, step, e.key, report, step.node!);
      }
    }
  }
  out['schema'] = kSchemaVersion;
  return out;
}

/// A node's JSON alone (outside a document) upgraded as [migrate2to3]
/// upgrades the nodes of a document (its state and media patches on
/// itself included). Returns a new map; never throws.
Json migrateNode2to3(Json node, {MigrationReport? report, String id = ''}) {
  final key = id.isEmpty ? (readString(node['id']) ?? 'node') : id;
  final doc = migrate2to3({
    'schema': kOldestSchemaVersion,
    'nodes': {key: node},
  }, report: report);
  return readMap(readMap(doc['nodes'])?[key]) ?? copyJson(node) as Json;
}

/// Runs [apply] on [json]; on an exception restores it and reports the step
/// as unable to convert.
void _guarded(Json json, MigrationStep step, String nodeId, MigrationReport? report,
    void Function(Json, MigrationScope) apply) {
  final before = copyJson(json) as Json;
  final scope = MigrationScope._(report, step, nodeId);
  try {
    apply(json, scope);
  } catch (e) {
    json
      ..clear()
      ..addAll(before);
    report?.add(MigrationEntry(
      kind: MigrationEntryKind.unconvertible,
      step: step.id,
      document: report.document,
      node: nodeId,
      message: 'The step could not run here ($e); left as it was.',
      instead: 'Rewrite it by hand in the schema-3 form (docs/guide/12-migrating-to-schema-3.md).',
    ));
  }
}

/// Whether [json] is a layout document: a `nodes` map holding a typed node.
bool isLayoutDocumentJson(Object? json) {
  final nodes = readMap(readMap(json)?['nodes']);
  return nodes != null && nodes.values.any((n) => readMap(n)?['type'] is String);
}

/// Any JSON that carries documents (a document, a publish model or bundle,
/// a component definition, a site manifest, a plugin package, or a file
/// holding several) with every schema-2 document in it migrated
/// ([migrate2to3]) and every other `"schema": 2` (the carriers') set to 3.
/// Text that holds a document (a stored payload) is left as it is: its
/// digest covers the text, so it is migrated when it is read. Never throws.
Object? migrateJson2to3(Object? json, {MigrationReport? report}) {
  Object? walk(Object? v, String at) {
    if (v is Map) {
      final m = <String, Object?>{for (final e in v.entries) '${e.key}': e.value};
      if (isLayoutDocumentJson(m)) {
        if (report == null) return migrate2to3(m);
        final before = report.document;
        report.document = '$before${at.isEmpty ? '' : '#$at'}';
        try {
          return migrate2to3(m, report: report);
        } finally {
          report.document = before;
        }
      }
      final carrier = m.containsKey('schema') && schemaOf(m) < kSchemaVersion;
      return <String, Object?>{
        for (final e in m.entries) e.key: e.key == 'schema' && carrier ? kSchemaVersion : walk(e.value, '$at/${e.key}'),
      };
    }
    if (v is List) return [for (var i = 0; i < v.length; i++) walk(v[i], '$at/$i')];
    return v;
  }

  return walk(json, '');
}
