// The edit operations: six id-addressed changes to a layout document, as a
// model writes them in a `ui_apply` tool call, a person's editor makes them
// and code calls them. Each op is declared once ([EditOpSpec]), so the
// decoder's checks, the JSON Schema of the tool input and the reference
// read the same declaration (docs/design/08-ai-developer-experience.md §3).
//
// Decoding is total and lenient: anything decodes to ops plus diagnostics
// for what could not be read; nothing throws.
import 'package:meta/meta.dart';

import '../json.dart';
import 'diagnostics.dart';

/// The kind of value an op field holds (its JSON Schema type).
enum EditFieldKind { string, integer, boolean, object, strings }

/// One field of an op: its key, kind, whether the op needs it, and what it
/// means.
@immutable
final class EditOpField {
  const EditOpField(this.key, this.kind, {this.required = false, this.doc = ''});
  final String key;
  final EditFieldKind kind;
  final bool required;
  final String doc;
}

/// The declaration of one op: its name, fields, meaning and an example.
@immutable
final class EditOpSpec {
  const EditOpSpec(this.op, {required this.fields, required this.doc, required this.example, this.alternatives = const []});

  /// The JSON `op` (`set`, `patch`...).
  final String op;
  final List<EditOpField> fields;
  final String doc;

  /// One op as a model writes it.
  final Json example;

  /// Sets of fields one of which the op needs (`set`: `node` with `id`, or
  /// `nodes`), when [EditOpField.required] alone can't say it.
  final List<List<String>> alternatives;

  EditOpField? field(String key) {
    for (final f in fields) {
      if (f.key == key) return f;
    }
    return null;
  }
}

/// One edit operation on a layout document, addressed by node id.
///
/// JSON: `{"op": "set" | "patch" | "move" | "remove" | "vars" | "roots", ...}`.
/// [decodeOps] reads a batch; [toJson] writes one op.
@immutable
sealed class EditOp {
  const EditOp();

  /// The JSON `op`.
  String get op;

  Json toJson();

  /// Decodes one op; null (with [diagnostics] saying why) when [json] is
  /// not one. A `set` with a `nodes` map is several ops: use [decodeOps].
  static EditOp? fromJson(Object? json, {List<EditDiagnostic>? diagnostics}) {
    final out = _decodeOne(json, 0, diagnostics ?? []);
    return out.length == 1 ? out.first : null;
  }

  /// Every op's declaration, in the order the reference lists them.
  static const List<EditOpSpec> specs = [SetOp.spec, PatchOp.spec, MoveOp.spec, RemoveOp.spec, VarsOp.spec, RootsOp.spec];

  static EditOpSpec? specOf(String op) {
    for (final s in specs) {
      if (s.op == op) return s;
    }
    return null;
  }

  @override
  String toString() => 'EditOp(${toJson()})';
}

/// Create or replace node [id] with [node] (its JSON, as a document holds it
/// under `nodes`), and optionally place it under [parent] at [index] (or in
/// [slot]). Flutter: inserting a widget into the tree.
final class SetOp extends EditOp {
  const SetOp(this.id, this.node, {this.parent, this.index, this.slot, this.placeholders = const {}});

  static const opName = 'set';
  @override
  String get op => opName;

  final String id;

  /// The node's JSON (without `id`: the op's [id] is its address).
  final Json node;
  final String? parent;
  final int? index;
  final String? slot;

  /// Sizes to show for children [node] lists that have not arrived yet:
  /// child id → a `layout` fragment (`{"width": {"fill": 360}, "height": 200}`).
  /// Rendering only: not part of the document.
  final Map<String, Json> placeholders;

  static const spec = EditOpSpec(
    opName,
    doc: 'Create node `id` (or replace it: the result says which), optionally placed under `parent` at `index` (default: '
        'last) or in `slot`. `node` is the node as the document holds it under "nodes": its `children` may list ids that '
        'arrive in later ops (pending until then). `nodes` sets several nodes at once (id → node), in order. '
        '`placeholders` gives a size (a layout fragment) to show for a pending child until it arrives.',
    fields: [
      EditOpField('op', EditFieldKind.string, required: true),
      EditOpField('id', EditFieldKind.string, doc: 'The node id: readable, unique (`heroTitle`).'),
      EditOpField('node', EditFieldKind.object, doc: 'The node: {"type", "layout", "props", "children"...}.'),
      EditOpField('nodes', EditFieldKind.object, doc: 'Several nodes, id → node, set in order (instead of id and node).'),
      EditOpField('parent', EditFieldKind.string, doc: 'Place it under this node (listed in its children).'),
      EditOpField('index', EditFieldKind.integer, doc: 'Its position among the parent\'s children (default: last).'),
      EditOpField('slot', EditFieldKind.string, doc: 'Place it in this slot of the parent instead (`body`, `appBar`).'),
      EditOpField('placeholders', EditFieldKind.object, doc: 'Pending child id → layout to reserve until it arrives.'),
    ],
    alternatives: [
      ['id', 'node'],
      ['nodes'],
    ],
    example: {
      'op': 'set',
      'id': 'faqTitle',
      'parent': 'faqSec',
      'index': 0,
      'node': {
        'type': 'text',
        'layout': {'width': {'hug': 120}, 'height': {'hug': 28}},
        'props': {'text': 'Questions', 'style': {'fontSize': 22, 'fontWeight': 700, 'color': '#FF111827'}},
      },
    },
  );

  @override
  Json toJson() => {
        'op': op,
        'id': id,
        'parent': ?parent,
        'index': ?index,
        'slot': ?slot,
        'node': node,
        if (placeholders.isNotEmpty) 'placeholders': placeholders,
      };
}

/// An RFC 7396 merge patch on node [id]: objects merge, arrays and scalars
/// replace, `null` deletes a key. It never changes `children`, `slots` or
/// `type` (`structural_key_in_patch`).
final class PatchOp extends EditOp {
  const PatchOp(this.id, this.patch);

  static const opName = 'patch';
  @override
  String get op => opName;
  final String id;
  final Json patch;

  static const spec = EditOpSpec(
    opName,
    doc: 'Merge `patch` into node `id` (RFC 7396): objects merge, arrays and scalars replace, null deletes a key. '
        'Shaped like the node (`{"props": {"text": "Book a demo"}}`). It cannot change `children`, `slots` or `type`.',
    fields: [
      EditOpField('op', EditFieldKind.string, required: true),
      EditOpField('id', EditFieldKind.string, required: true),
      EditOpField('patch', EditFieldKind.object, required: true, doc: 'RFC 7396 merge patch on the node; null deletes a key.'),
    ],
    example: {
      'op': 'patch',
      'id': 'heroTitle',
      'patch': {'props': {'text': 'Book a demo', 'style': {'color': '#FF0F766E'}}},
    },
  );

  @override
  Json toJson() => {'op': op, 'id': id, 'patch': patch};
}

/// Move node [id] under [parent] at [index] (or into [slot]); reordering is
/// a move within the same parent.
final class MoveOp extends EditOp {
  const MoveOp(this.id, this.parent, {this.index, this.slot});

  static const opName = 'move';
  @override
  String get op => opName;
  final String id;
  final String parent;
  final int? index;
  final String? slot;

  static const spec = EditOpSpec(
    opName,
    doc: 'Move node `id` (with its subtree) under `parent` at `index` (default: last), or into `slot`. Reorder: move '
        'within the same parent.',
    fields: [
      EditOpField('op', EditFieldKind.string, required: true),
      EditOpField('id', EditFieldKind.string, required: true),
      EditOpField('parent', EditFieldKind.string, required: true),
      EditOpField('index', EditFieldKind.integer),
      EditOpField('slot', EditFieldKind.string),
    ],
    example: {'op': 'move', 'id': 'faqSec', 'parent': 'page', 'index': 2},
  );

  @override
  Json toJson() => {'op': op, 'id': id, 'parent': parent, 'index': ?index, 'slot': ?slot};
}

/// Remove nodes [ids] and their subtrees, detaching them from their parents.
final class RemoveOp extends EditOp {
  const RemoveOp(this.ids);

  static const opName = 'remove';
  @override
  String get op => opName;
  final List<String> ids;

  static const spec = EditOpSpec(
    opName,
    doc: 'Remove the nodes `ids` and everything under them; their parents stop listing them.',
    fields: [
      EditOpField('op', EditFieldKind.string, required: true),
      EditOpField('ids', EditFieldKind.strings, required: true),
    ],
    example: {
      'op': 'remove',
      'ids': ['promoBanner'],
    },
  );

  @override
  Json toJson() => {'op': op, 'ids': ids};
}

/// Set variable values, declare variables (a full variable object as the
/// value) or remove them, in [scope] (a canvas id or `page_variables`).
final class VarsOp extends EditOp {
  const VarsOp(this.scope, {this.set = const {}, this.remove = const []});

  static const opName = 'vars';
  @override
  String get op => opName;
  final String scope;

  /// Name → value; or name → `{"type", "value", ...}` to declare it.
  final Json set;
  final List<String> remove;

  static const spec = EditOpSpec(
    opName,
    doc: 'Variables of `scope` (a canvas id, or "page_variables"): `set` maps a name to its new value, or to a full '
        'variable object (`{"type": "boolean", "value": false}`) to declare it; `remove` lists names to remove. '
        'Bindings that read them update at once.',
    fields: [
      EditOpField('op', EditFieldKind.string, required: true),
      EditOpField('scope', EditFieldKind.string, required: true),
      EditOpField('set', EditFieldKind.object, doc: 'Variable name → value, or → a full variable object to declare it.'),
      EditOpField('remove', EditFieldKind.strings),
    ],
    example: {
      'op': 'vars',
      'scope': 'pricing',
      'set': {'annual': true},
    },
  );

  @override
  Json toJson() => {'op': op, 'scope': scope, if (set.isNotEmpty) 'set': set, if (remove.isNotEmpty) 'remove': remove};
}

/// Set the document's canvases ([roots]).
final class RootsOp extends EditOp {
  const RootsOp(this.roots);

  static const opName = 'roots';
  @override
  String get op => opName;
  final List<String> roots;

  static const spec = EditOpSpec(
    opName,
    doc: 'Set the document\'s canvases, in order. A root may name a canvas that arrives in a later op.',
    fields: [
      EditOpField('op', EditFieldKind.string, required: true),
      EditOpField('roots', EditFieldKind.strings, required: true),
    ],
    example: {
      'op': 'roots',
      'roots': ['home'],
    },
  );

  @override
  Json toJson() => {'op': op, 'roots': roots};
}

/// A batch of ops read from a tool input: each op with the index of the
/// input op it came from (a `set` with `nodes` gives several), and what
/// could not be read.
@immutable
final class DecodedOps {
  const DecodedOps(this.ops, {this.diagnostics = const [], this.baseRev, this.atomic = false});

  /// Each op and the index of the input op it came from.
  final List<(int, EditOp)> ops;
  final List<EditDiagnostic> diagnostics;
  final int? baseRev;
  final bool atomic;

  /// The number of input ops (including ones that could not be read).
  int get inputCount => ops.isEmpty && diagnostics.isEmpty ? 0 : _inputCount;
  int get _inputCount {
    var n = 0;
    for (final (i, _) in ops) {
      if (i + 1 > n) n = i + 1;
    }
    for (final d in diagnostics) {
      if (d.op + 1 > n) n = d.op + 1;
    }
    return n;
  }
}

/// Reads a batch of ops: the `ui_apply` tool input (`{"ops": [...],
/// "baseRev": 42, "atomic": false}`), a bare list of ops, or one op. Total:
/// what is not an op becomes a diagnostic with its index.
DecodedOps decodeOps(Object? input) {
  final diagnostics = <EditDiagnostic>[];
  Object? list = input;
  int? baseRev;
  var atomic = false;
  final m = readMap(input);
  if (m != null && !m.containsKey('op')) {
    list = m['ops'];
    baseRev = readInt(m['baseRev']);
    atomic = readBool(m['atomic']) ?? false;
    if (list == null) {
      diagnostics.add(EditDiagnostic.of(EditCodes.missingField, -1, 'The tool input is {"ops": [...]}: a list of ops, got no "ops".', path: '/ops'));
      return DecodedOps(const [], diagnostics: diagnostics, baseRev: baseRev, atomic: atomic);
    }
  } else if (m != null) {
    list = [m];
  }
  final items = readList(list);
  if (items == null) {
    diagnostics.add(EditDiagnostic.of(EditCodes.wrongType, -1, '"ops" is a list of op objects, got ${_describe(list)}.', path: '/ops'));
    return DecodedOps(const [], diagnostics: diagnostics, baseRev: baseRev, atomic: atomic);
  }
  final ops = <(int, EditOp)>[];
  for (var i = 0; i < items.length; i++) {
    for (final op in _decodeOne(items[i], i, diagnostics)) {
      ops.add((i, op));
    }
  }
  return DecodedOps(ops, diagnostics: diagnostics, baseRev: baseRev, atomic: atomic);
}

/// The ops of one input op [json] (index [i]); problems go to [out].
List<EditOp> _decodeOne(Object? json, int i, List<EditDiagnostic> out) {
  final at = '/ops/$i';
  final m = readMap(json);
  if (m == null) {
    out.add(EditDiagnostic.of(EditCodes.invalidOp, i, 'An op is an object {"op": ..., ...}, got ${_describe(json)}.', path: at));
    return const [];
  }
  final names = [for (final s in EditOp.specs) s.op];
  var name = readString(m['op'])?.trim();
  // Lenient: a type-less op that carries a node is a set.
  if (name == null && m['op'] == null && (m['node'] is Map || m['nodes'] is Map)) name = SetOp.opName;
  if (name == null) {
    out.add(EditDiagnostic.of(EditCodes.invalidOp, i, 'Each op names its kind in "op": ${names.join(', ')}.',
        path: editPointer(at, 'op'), expected: names));
    return const [];
  }
  final lower = name.toLowerCase();
  final spec = EditOp.specOf(lower) ?? EditOp.specOf(_aliases[lower] ?? '');
  if (spec == null) {
    out.add(EditDiagnostic.of(EditCodes.invalidOp, i, '"$name" is not an op. Ops: ${names.join(', ')}.',
        path: editPointer(at, 'op'), expected: names, suggestion: nearestName(name, names)));
    return const [];
  }
  var ok = true;
  void problem(EditCode code, String key, String message, {List<String>? expected, String? suggestion}) {
    ok = false;
    out.add(EditDiagnostic.of(code, i, message, path: editPointer(at, key), expected: expected, suggestion: suggestion));
  }

  // Keys the op does not read.
  for (final k in m.keys) {
    if (spec.field(k) != null || (spec.op == RemoveOp.opName && k == 'id')) continue;
    final known = [for (final f in spec.fields) f.key];
    final s = nearestName(k, known);
    // A misspelt field is an error only when it hides a required one.
    out.add(EditDiagnostic(
        op: i,
        code: 'unknown_field',
        error: false,
        path: editPointer(at, k),
        message: 'A ${spec.op} op has no "$k" (ignored). It takes: ${known.join(', ')}.',
        expected: known,
        suggestion: s));
  }

  String? str(String key) {
    final v = m[key];
    if (v == null) return null;
    if (v is String) return v;
    if (v is num) return '$v';
    problem(EditCodes.wrongType, key, '"$key" is text, got ${_describe(v)}.');
    return null;
  }

  int? integer(String key) {
    final v = m[key];
    if (v == null) return null;
    final n = readInt(v);
    if (n == null) problem(EditCodes.wrongType, key, '"$key" is a whole number, got ${_describe(v)}.');
    return n;
  }

  Json? object(String key) {
    final v = m[key];
    if (v == null) return null;
    final o = readMap(v);
    if (o == null) problem(EditCodes.wrongType, key, '"$key" is an object, got ${_describe(v)}.');
    return o;
  }

  List<String>? strings(String key) {
    final v = m[key];
    if (v == null) return null;
    if (v is String) return [v];
    final l = readList(v);
    if (l == null || l.any((e) => e is! String)) {
      problem(EditCodes.wrongType, key, '"$key" is a list of ids (text), got ${_describe(v)}.');
      return l?.whereType<String>().toList();
    }
    return l.cast<String>();
  }

  String? need(String key, String? v, String what) {
    if (v == null && m[key] == null) problem(EditCodes.missingField, key, 'A ${spec.op} op needs "$key": $what.');
    return v;
  }

  switch (spec.op) {
    case SetOp.opName:
      final parent = str('parent'), slot = str('slot'), index = integer('index');
      final placeholders = <String, Json>{
        for (final e in (object('placeholders') ?? const {}).entries)
          if (readMap(e.value) case final Json l) e.key: l,
      };
      final bulk = object('nodes');
      final node = object('node');
      if (bulk != null && node == null) {
        final ops = <EditOp>[];
        for (final e in bulk.entries) {
          final n = readMap(e.value);
          if (n == null) {
            problem(EditCodes.wrongType, 'nodes', 'nodes["${e.key}"] is a node object, got ${_describe(e.value)}.');
            continue;
          }
          ops.add(SetOp(e.key, _withoutId(n), placeholders: placeholders));
        }
        return ok ? ops : const [];
      }
      final id = str('id') ?? readString(node?['id']);
      need('id', id, 'the node\'s id (its key in the document)');
      if (node == null && m['node'] == null) problem(EditCodes.missingField, 'node', 'A set op needs "node": the node object, or "nodes": id → node.');
      if (!ok || id == null || node == null) return const [];
      return [SetOp(id, _withoutId(node), parent: parent, index: index, slot: slot, placeholders: placeholders)];
    case PatchOp.opName:
      final id = need('id', str('id'), 'the id of the node to change');
      final patch = object('patch');
      if (patch == null && m['patch'] == null) problem(EditCodes.missingField, 'patch', 'A patch op needs "patch": the merge patch, shaped like the node.');
      if (!ok || id == null || patch == null) return const [];
      return [PatchOp(id, patch)];
    case MoveOp.opName:
      final id = need('id', str('id'), 'the id of the node to move');
      final parent = need('parent', str('parent'), 'the id of its new parent');
      final index = integer('index'), slot = str('slot');
      if (!ok || id == null || parent == null) return const [];
      return [MoveOp(id, parent, index: index, slot: slot)];
    case RemoveOp.opName:
      // Lenient: `id` for one.
      var ids = strings('ids');
      if (ids == null && m['id'] is String) ids = [m['id']! as String];
      if (ids == null && m['ids'] == null && m['id'] == null) problem(EditCodes.missingField, 'ids', 'A remove op needs "ids": the ids to remove.');
      if (!ok || ids == null) return const [];
      return [RemoveOp(ids)];
    case VarsOp.opName:
      final scope = need('scope', str('scope'), 'a canvas id or "page_variables"');
      final set = object('set') ?? const {};
      final remove = strings('remove') ?? const [];
      if (!ok || scope == null) return const [];
      return [VarsOp(scope, set: set, remove: remove)];
    case RootsOp.opName:
      final roots = strings('roots');
      if (roots == null && m['roots'] == null) problem(EditCodes.missingField, 'roots', 'A roots op needs "roots": the canvas ids, in order.');
      if (!ok || roots == null) return const [];
      return [RootsOp(roots)];
  }
  return const [];
}

/// Names models write for an op, read as it.
const Map<String, String> _aliases = {
  'add': 'set', 'upsert': 'set', 'create': 'set', 'replace': 'set', 'update': 'patch', 'merge': 'patch', //
  'delete': 'remove', 'variables': 'vars', 'setvars': 'vars',
};

Json _withoutId(Json node) => node.containsKey('id') ? ({...node}..remove('id')) : node;

String _describe(Object? v) => switch (v) {
      null => 'null',
      String s => 'the text "${s.length > 40 ? '${s.substring(0, 40)}...' : s}"',
      bool b => '$b',
      num n => 'the number $n',
      List _ => 'a list',
      Map _ => 'an object',
      _ => '$v',
    };
