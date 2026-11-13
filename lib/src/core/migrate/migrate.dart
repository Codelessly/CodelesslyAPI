// The one-time upgrade of a schema-2 document to schema 3: pure JSON in, JSON
// out, composed of small named steps (steps.dart, then 30.1.0's one-way
// steps in steps_spellings.dart). The model's decoders know only the schema-3
// shape; a schema-2 document is migrated before it is decoded
// (LayoutDocument.fromJson does it), never written back by a loader.
import '../json.dart';
import 'report.dart';
import 'steps.dart';
import 'steps_spellings.dart';

export 'report.dart';
export 'legacy_paths.dart' show schema2PathHint, movedPathHint, olderSchemaPathHint;

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
/// through the [MigrationScope] it is given. A node step may read the
/// document it is in ([MigrationScope.document]) to see what other nodes do
/// to its node (a state style or a `setValue` that targets it).
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
  MigrationScope._(this._report, this.step, this.nodeId, {this.document});

  /// A scope that reports nothing (a step run to compute a value), on node
  /// [nodeId] of [document] when given.
  MigrationScope.silent(this.step, {this.nodeId = '', this.document}) : _report = null;

  final MigrationReport? _report;

  /// The step running.
  final MigrationStep step;

  /// The node it runs on; empty for a document step.
  final String nodeId;

  /// The document being migrated, as it was before this pass's steps ran
  /// (for the steps of 30.1.0, after schema 2's); null for a node given
  /// alone to a step. Read it, never write it.
  final Json? document;

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

/// The steps of [migrate2to3], in order: schema 2's ([migrationSteps2to3]),
/// then the one-way steps of 30.1.0 ([spellingMigrationSteps]).
List<MigrationStep> get schema3Steps => [...migrationSteps2to3, ...spellingMigrationSteps];

/// Upgrades a schema-2 layout document's JSON to schema 3: every legacy key
/// and deprecated field rewritten into the schema-3 form, or kept as
/// `legacy.<name>` and reported when it has none. Then the steps of 30.1.0,
/// which give each concept one spelling (the node's `scale` and
/// `layout.rotation` are its `motion`, `flightKey` and `flight` its `hero`,
/// `strokePath`, `subpathColors` and `gradientPerSubpath` `customPaint` path
/// ops, a box's `path` a path node), run on the result. A document already at
/// schema 3 (or later) is returned as given: it is read as current schema 3.
/// Never throws: a step that fails on a node leaves that node as it was
/// before the step and is reported. [report] collects what was done
/// ([MigrationReport.document] names the document). [steps], when given, are
/// run instead, in one pass.
Json migrate2to3(Json document, {MigrationReport? report, List<MigrationStep>? steps}) {
  if (schemaOf(document) >= 3) return document;
  if (steps != null) return _migrate(document, steps, report);
  final first = _migrate(document, migrationSteps2to3, report);
  return _migrate(first, spellingMigrationSteps, report, from: document);
}

/// [document] (a layout document of any schema; none reads as
/// [kOldestSchemaVersion]) at [kSchemaVersion] ([migrate2to3]). A document
/// at [kSchemaVersion] or later is returned as given.
Json migrateDocument(Json document, {MigrationReport? report}) => migrate2to3(document, report: report);

/// Runs [steps] over a copy of [document] and marks it schema 3. The steps'
/// [MigrationScope.document] is [document] as given. [from] is the
/// document a migration started from (its report's document list).
Json _migrate(Json document, List<MigrationStep> steps, MigrationReport? report, {Json? from}) {
  if (report != null && from == null && (report.documents.isEmpty || report.documents.last != report.document)) {
    report.documents.add(report.document);
  }
  final out = copyJson(document) as Json;
  final raw = readMap(out['nodes']);
  final nodes = raw == null ? null : <String, Object?>{for (final e in raw.entries) e.key: e.value};
  if (nodes != null) out['nodes'] = nodes;
  for (final step in steps) {
    if (step.document != null) _guarded(out, step, '', report, step.document!, document);
    if (step.node != null && nodes != null) {
      for (final e in nodes.entries) {
        // Every map in [out] is a fresh Map<String, Object?> ([copyJson]).
        if (readMap(e.value) case final Json node) _guarded(node, step, e.key, report, step.node!, document);
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
  final out = readMap(readMap(doc['nodes'])?[key]) ?? copyJson(node) as Json;
  // A node alone is not where a document starts: it inherits the default
  // text style of the document it is put in (step text.lineHeight writes
  // schema 2's on a document's top-level nodes).
  if (!node.containsKey('defaultTextStyle') && jsonEquality.equals(out['defaultTextStyle'], {'height': 1.33})) {
    out.remove('defaultTextStyle');
    report?.entries.removeWhere((e) => e.step == 'text.lineHeight' && e.node.isEmpty && e.path == '/nodes/$key/defaultTextStyle');
  }
  return out;
}

/// A node's JSON alone, written in schema [from], upgraded to
/// [kSchemaVersion] ([migrateNode2to3]). Returns a new map; never throws.
Json migrateNode(Json node, {int from = kOldestSchemaVersion, MigrationReport? report, String id = ''}) =>
    from < 3 ? migrateNode2to3(node, report: report, id: id) : copyJson(node) as Json;

/// Runs [apply] on [json]; on an exception restores it and reports the step
/// as unable to convert.
void _guarded(Json json, MigrationStep step, String nodeId, MigrationReport? report,
    void Function(Json, MigrationScope) apply, Json document) {
  final before = copyJson(json) as Json;
  final scope = MigrationScope._(report, step, nodeId, document: document);
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
/// Text that holds a document (a stored payload) and a stored published
/// component (a `document` with a `digest`) are left as they are: the digest
/// covers what was stored, so they are migrated when they are read. Never
/// throws.
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
      // A stored published component: its digest is over its document as
      // stored, so it is migrated when it is read, not here.
      if (m['digest'] is String && isLayoutDocumentJson(m['document'])) return m;
      final carrier = m.containsKey('schema') && schemaOf(m) < 3;
      return <String, Object?>{
        for (final e in m.entries)
          if (!_naturalFlag(e.key, e.value, '$at/${e.key}', report))
            e.key: e.key == 'schema' && carrier ? 3 : walk(e.value, '$at/${e.key}'),
      };
    }
    if (v is List) return [for (var i = 0; i < v.length; i++) walk(v[i], '$at/$i')];
    return v;
  }

  return walk(json, '');
}

/// Any JSON that carries documents at [kSchemaVersion] ([migrateJson2to3]).
Object? migrateJson(Object? json, {MigrationReport? report}) => migrateJson2to3(json, report: report);

/// Whether [key] is one of schema 2's natural line height flags outside a
/// document (a theme's `naturalLineHeight`, a theme style's
/// `naturalHeight`), dropped by [migrateJson2to3] and `migratePublish2to3`
/// and reported: a document migrated on its own can't see its project's
/// theme, so it keeps 1.33 (step `text.lineHeight`).
bool _naturalFlag(String key, Object? value, String at, MigrationReport? report) {
  if (key != 'naturalLineHeight' && key != 'naturalHeight') return false;
  if (value == true) {
    report?.add(MigrationEntry(
      kind: MigrationEntryKind.behaviourChange,
      step: 'text.lineHeight',
      document: report.document,
      path: at,
      old: value,
      message: key == 'naturalLineHeight'
          ? 'The theme\'s naturalLineHeight is gone: the project\'s schema-2 documents keep 1.33 after the migration.'
          : 'A theme style\'s naturalHeight is gone: a text naming it takes its document\'s line height (1.33 in a migrated one).',
      instead: key == 'naturalLineHeight'
          ? 'Remove "defaultTextStyle" from the top-level nodes of the project\'s migrated documents (the font\'s own line height).'
          : 'Remove "defaultTextStyle" from the document, or put "defaultTextStyle": {} on the texts that name the style.',
    ));
  }
  return true;
}

/// [json] without schema 2's natural line height flags ([_naturalFlag]),
/// for a carrier migrated by hand (a publish model).
Object? dropNaturalLineHeightFlags(Object? json, {MigrationReport? report, String at = ''}) => switch (json) {
      final Map m => <String, Object?>{
          for (final e in m.entries)
            if (!_naturalFlag('${e.key}', e.value, '$at/${e.key}', report))
              '${e.key}': dropNaturalLineHeightFlags(e.value, report: report, at: '$at/${e.key}'),
        },
      final List l => [for (var i = 0; i < l.length; i++) dropNaturalLineHeightFlags(l[i], report: report, at: '$at/$i')],
      _ => json,
    };
