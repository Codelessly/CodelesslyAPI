// Applying edit operations to a layout document: each op is applied, its
// structure checked (one parent, no cycle, nothing orphaned), its nodes
// checked by an [EditCheck] (the strict validator restricted to what the op
// touched, or the core's catalog check) and by the trust profile; a
// rejected op leaves the document as it was. The result carries the new
// document, per-op diagnostics, the inverse ops and the revision.
//
// A document being built is incomplete by nature: a child id an op lists
// before its node arrives is *pending*, not an error, until the stream ends
// ([endOfStream]); then what is still dangling is a diagnostic.
import 'package:meta/meta.dart';

import '../catalog.dart';
import '../document.dart';
import '../behaviors.dart' show mergePatch;
import '../json.dart';
import '../logic.dart';
import '../node.dart';
import '../props.dart';
import '../variables.dart';
import '../widgets/canvas.dart';
import 'catalog_check.dart';
import 'diagnostics.dart';
import 'edit_ops.dart';
import 'explain.dart';
import 'trust.dart';

/// What an [EditCheck] is asked to check: the nodes an op touched, as JSON
/// (as written: a set's node, a patched node's merged JSON), in the
/// document after the op.
@immutable
final class EditCheckInput {
  const EditCheckInput(
      {required this.document, required this.nodes, required this.op, required this.catalog, this.screens = const {}, this.incomplete = false});

  /// The document after the op.
  final LayoutDocument document;

  /// Node id → its JSON, for every node the op created, changed, moved or
  /// re-parented (a parent whose child list changed).
  final Map<String, Json> nodes;

  /// The op's index in its batch (diagnostics carry it).
  final int op;
  final Catalog catalog;

  /// The canvases of the document and the ids still pending (navigation may
  /// name a screen that has not arrived yet).
  final Set<String> screens;

  /// Whether the document is still being built (a stream): a reference to a
  /// node, screen or variable that has not arrived yet is a warning, not an
  /// error ([endOfStream] and a whole-document validation report what never
  /// came).
  final bool incomplete;
}

/// Checks the nodes an op touched; errors reject the op. [catalogCheck] is
/// the core's; `strictEditCheck` (package:codelessly_api/validate.dart) runs
/// the strict validator on them.
typedef EditCheck = List<EditDiagnostic> Function(EditCheckInput input);

/// The revision of every field changed through ops, and by whom: what
/// `baseRev` is compared with.
@immutable
final class EditRevisions {
  const EditRevisions({this.rev = 0, this.fields = const {}});

  /// The document's revision: the number of batches that changed it.
  final int rev;

  /// Node id → field path (`props.text`; `*` for the whole node) → the
  /// revision and author of its last change.
  final Map<String, Map<String, (int, String)>> fields;

  /// The changes to node [id] after [baseRev] by an author other than
  /// [author]: path → revision.
  Map<String, int> changedSince(String id, int baseRev, String author) => {
        for (final e in (fields[id] ?? const {}).entries)
          if (e.value.$1 > baseRev && e.value.$2 != author) e.key: e.value.$1,
      };
}

/// The outcome of [applyOps].
@immutable
final class EditResult {
  const EditResult({
    required this.document,
    required this.applied,
    required this.rejected,
    required this.appliedOps,
    required this.inverse,
    required this.diagnostics,
    required this.pending,
    required this.rev,
    required this.revisions,
    required this.changed,
    this.created = const {},
  });

  /// The document after the ops that applied.
  final LayoutDocument document;

  /// Indices (in the batch) of the ops that applied, and of those rejected.
  final List<int> applied, rejected;

  /// The ops that applied, in order.
  final List<EditOp> appliedOps;

  /// Applying these (atomically) undoes [appliedOps].
  final List<EditOp> inverse;

  /// Errors (of rejected ops) and warnings, per op.
  final List<EditDiagnostic> diagnostics;

  /// Ids referenced (as children, slots or roots) but not yet defined.
  final Set<String> pending;

  /// The document's revision after the batch (unchanged when nothing
  /// applied).
  final int rev;
  final EditRevisions revisions;

  /// Node ids whose node was created, changed or removed.
  final Set<String> changed;

  /// Of [changed], the ids a set created (rather than replaced).
  final Set<String> created;

  bool get ok => rejected.isEmpty;
  List<EditDiagnostic> get errors => [for (final d in diagnostics) if (d.error) d];
  List<EditDiagnostic> get warnings => [for (final d in diagnostics) if (!d.error) d];

  /// The tool result a model reads (`ui_apply`'s): the revision, the ops
  /// that applied (by index, and the node ids they set, patched, moved and
  /// removed), the rejected ones with their codes, paths, what was expected
  /// and a suggestion, warnings (at most [maxWarnings]), the pending ids,
  /// the document's roots and size, and, when anything was rejected or is
  /// pending, `next`: how to fix it (patch the document as it is now; never
  /// start over).
  Json toModelJson({int maxWarnings = 20}) {
    final warnings = [for (final d in diagnostics) if (!d.error) d.toJson()];
    final rejected = [for (final d in diagnostics) if (d.error) d.toJson()];
    final ids = <String, List<String>>{};
    void add(String kind, String id) => (ids[kind] ??= []).contains(id) ? null : ids[kind]!.add(id);
    for (final op in appliedOps) {
      switch (op) {
        case SetOp(:final id):
          add('set', id);
        case PatchOp(:final id):
          add('patched', id);
        case MoveOp(:final id):
          add('moved', id);
        case RemoveOp(:final ids):
          for (final id in ids) {
            add('removed', id);
          }
        case VarsOp(:final scope):
          add('vars', scope);
        case RootsOp():
          break;
      }
    }
    return {
      'rev': rev,
      'applied': applied,
      if (ids.isNotEmpty) 'ids': ids,
      'rejected': rejected,
      'warnings': warnings.length > maxWarnings
          ? [...warnings.take(maxWarnings), {'code': 'more', 'message': '${warnings.length - maxWarnings} more warnings not listed.'}]
          : warnings,
      if (pending.isNotEmpty) 'pending': [...pending],
      'document': {'roots': document.roots, 'nodes': document.nodes.length},
      if (rejected.isNotEmpty || pending.isNotEmpty) 'next': fixInstruction(rev: rev, pending: pending),
    };
  }

  /// This result with [extra] diagnostics (render-time ones a host adds).
  EditResult withDiagnostics(List<EditDiagnostic> extra) => extra.isEmpty
      ? this
      : EditResult(
          document: document,
          applied: applied,
          rejected: rejected,
          appliedOps: appliedOps,
          inverse: inverse,
          diagnostics: [...diagnostics, ...extra],
          pending: pending,
          rev: rev,
          revisions: revisions,
          changed: changed,
          created: created,
        );
}

/// What a tool result tells a model to do about rejected ops and pending
/// ids: fix the document as it is now, by patching it.
String fixInstruction({required int rev, Set<String> pending = const {}}) =>
    'The UI exists as described (rev $rev): fix it by patching it, in one ui_apply call. Resend only the rejected '
    'ops, corrected, with the same ids; '
    '${pending.isEmpty ? '' : 'send a set for each pending id (${pending.take(12).join(', ')}${pending.length > 12 ? '...' : ''}) under the node that lists it, or drop it from that node\'s children; '}'
    'patch fields of nodes that exist. Never start over: no new roots, no new canvas, no re-sending nodes that applied.';

/// Applies [ops] to [document] in order and returns the result. Never
/// throws.
///
/// Each op is applied and checked on its own (with [atomic], all or none):
/// its structure, [profile] (node and action types, links, navigation,
/// limits), and [check] on the nodes it touched (default [catalogCheck]:
/// types, keys and values against [catalog]). A rejected op leaves the
/// document unchanged. [baseRev] with [revisions]: a patch of a field, or a
/// set of a node, another author changed after [baseRev] is `stale_rev`.
/// [ops] is a list of [EditOp]s or the tool input JSON ([decodeOps]).
/// [incomplete]: the document is still streaming in (see
/// [EditCheckInput.incomplete]).
EditResult applyOps(
  LayoutDocument document,
  Object? ops, {
  Catalog? catalog,
  TrustProfile profile = TrustProfile.none,
  EditCheck? check = catalogCheck,
  bool atomic = false,
  EditRevisions revisions = const EditRevisions(),
  int? baseRev,
  String author = 'agent',
  bool incomplete = false,
  bool protectRoots = false,
}) {
  final List<(int, EditOp)> list;
  final decodeProblems = <EditDiagnostic>[];
  if (ops is List<EditOp>) {
    list = [for (var i = 0; i < ops.length; i++) (i, ops[i])];
  } else if (ops is EditOp) {
    list = [(0, ops)];
  } else {
    final d = decodeOps(ops);
    list = d.ops;
    decodeProblems.addAll(d.diagnostics);
    baseRev ??= d.baseRev;
    atomic = atomic || d.atomic;
  }
  final c = catalog ?? document.catalog ?? Catalog.current;
  return _Batch(document, c, profile, check, revisions, baseRev, author, atomic, incomplete, protectRoots).run(list, decodeProblems);
}

/// What is wrong with [document] once a stream has ended: every child,
/// slot or root id that still names no node (`dangling_child`, an error)
/// and every node no root reaches (`unreachable_node`, a warning).
List<EditDiagnostic> endOfStream(LayoutDocument document) {
  final out = <EditDiagnostic>[];
  for (final n in document.nodes.values) {
    var i = 0;
    for (final c in n.children) {
      if (!document.nodes.containsKey(c)) {
        out.add(EditDiagnostic.of(EditCodes.danglingChild, -1, 'Child "$c" of "${n.id}" never arrived: send its set op, or remove it from the children.',
            path: editPointer(editPointer(editPointer('/nodes', n.id), 'children'), i), nodeId: n.id));
      }
      i++;
    }
    for (final e in n.slots.entries) {
      if (!document.nodes.containsKey(e.value)) {
        out.add(EditDiagnostic.of(EditCodes.danglingChild, -1, 'Slot "${e.key}" of "${n.id}" names "${e.value}", which never arrived.',
            path: editPointer(editPointer(editPointer('/nodes', n.id), 'slots'), e.key), nodeId: n.id));
      }
    }
  }
  for (var i = 0; i < document.roots.length; i++) {
    if (!document.nodes.containsKey(document.roots[i])) {
      out.add(EditDiagnostic.of(EditCodes.danglingChild, -1, 'Root "${document.roots[i]}" never arrived.', path: editPointer('/roots', i)));
    }
  }
  final reached = <String>{};
  void visit(String id) {
    if (!reached.add(id)) return;
    for (final c in document.nodes[id]?.childIds ?? const <String>[]) {
      visit(c);
    }
  }

  for (final r in document.roots) {
    visit(r);
  }
  for (final id in document.nodes.keys) {
    if (reached.contains(id) || document.parentOf(id) != null) continue;
    out.add(EditDiagnostic.of(EditCodes.unreachableNode, -1, 'Node "$id" is under no root: nothing lists it as a child or slot, so it is not shown.',
        path: editPointer('/nodes', id), nodeId: id));
  }
  return out;
}

/// Ids [document] references (children, slots, roots) that it does not
/// define.
Set<String> pendingIds(LayoutDocument document) => {
      for (final n in document.nodes.values)
        for (final c in n.childIds)
          if (!document.nodes.containsKey(c)) c,
      for (final r in document.roots)
        if (!document.nodes.containsKey(r)) r,
    };

// --- the batch ----------------------------------------------------------------

class _Batch {
  _Batch(this.start, this.catalog, this.profile, this.check, this.revisions, this.baseRev, this.author, this.atomic, this.incomplete,
      this.protectRoots)
      : nodes = {...start.nodes},
        roots = [...start.roots],
        extra = {...start.extra} {
    for (final n in nodes.values) {
      for (final c in n.childIds) {
        (listers[c] ??= {}).add(n.id);
      }
    }
    startListed = {for (final e in listers.entries) if (e.value.isNotEmpty) e.key};
    fields = {for (final e in revisions.fields.entries) e.key: {...e.value}};
  }

  final LayoutDocument start;
  final Catalog catalog;
  final TrustProfile profile;
  final EditCheck? check;
  final EditRevisions revisions;
  final int? baseRev;
  final String author;

  /// All or none; the structure is checked once, at the end.
  final bool atomic;
  final bool incomplete;

  /// The document's existing roots may not be replaced, nor a new canvas
  /// created: an edit patches what is there ([EditCodes.startOver]).
  final bool protectRoots;

  final Map<String, Node> nodes;
  List<String> roots;
  Json extra;

  /// Child id → the nodes that list it (as a child or slot).
  final Map<String, Set<String>> listers = {};

  /// Ids listed by some node at the start of the batch.
  late final Set<String> startListed;
  late Map<String, Map<String, (int, String)>> fields;

  // Per op.
  final Map<String, Node?> _before = {};
  final Map<String, Json> _touched = {};
  final Set<String> _lostLister = {};
  final List<EditDiagnostic> _diags = [];
  int _op = 0;

  int get _rev => revisions.rev + 1;

  void _put(String id, Node? n) {
    _before.putIfAbsent(id, () => nodes[id]);
    final old = nodes[id];
    if (old != null) {
      for (final c in old.childIds) {
        final l = listers[c];
        if (l != null && l.remove(id)) _lostLister.add(c);
      }
    }
    if (n == null) {
      nodes.remove(id);
    } else {
      nodes[id] = n;
      for (final c in n.childIds) {
        (listers[c] ??= {}).add(id);
      }
    }
  }

  void _error(EditCode code, String message, {String path = '', String? nodeId, List<String>? expected, String? suggestion}) =>
      _diags.add(EditDiagnostic.of(code, _op, message, path: path, nodeId: nodeId, expected: expected, suggestion: suggestion));

  bool get _failed => _diags.any((d) => d.error);

  Node? _decode(String id, Json json) => Node.fromJson(json, id: id, catalog: catalog);

  Json _json(Node n) => n.toJson()..remove('id');

  /// [id]'s ancestors (through any lister).
  bool _isWithin(String id, String ancestor) {
    final seen = <String>{};
    final stack = [id];
    while (stack.isNotEmpty) {
      final x = stack.removeLast();
      if (x == ancestor) return true;
      if (!seen.add(x)) continue;
      stack.addAll(listers[x] ?? const {});
    }
    return false;
  }

  Set<String> get _screens => {
        for (final n in nodes.values) if (n.type == CanvasProps.spec.type) n.id,
        ...roots,
      };

  EditResult run(List<(int, EditOp)> ops, List<EditDiagnostic> decodeProblems) {
    final all = <EditDiagnostic>[...decodeProblems];
    final applied = <int>{}, rejected = <int>{};
    for (final d in decodeProblems) {
      if (d.error && d.op >= 0) rejected.add(d.op);
    }
    final appliedOps = <EditOp>[];
    final created = <String>{};
    // Atomic: changes accumulate; checks run once at the end.
    final batchTouched = <String, Json>{};
    final batchLost = <String>{};
    for (final (index, op) in ops) {
      _op = index;
      if (rejected.contains(index) && !atomic) continue;
      if (profile.maxOpsPerCall != null && index >= profile.maxOpsPerCall!) {
        _error(EditCodes.limitExceeded, 'At most ${profile.maxOpsPerCall} ops per call.', path: '/ops/$index');
        all.addAll(_diags);
        _diags.clear();
        rejected.add(index);
        continue;
      }
      _before.clear();
      _touched.clear();
      _lostLister.clear();
      final savedRoots = roots, savedExtra = extra, savedFields = fields;
      fields = {for (final e in fields.entries) e.key: {...e.value}};
      final wasNew = op is SetOp && !nodes.containsKey(op.id);
      _applyOp(op);
      if (!atomic && !_failed) _checkOp(_touched, _lostLister);
      if (atomic) {
        batchTouched.addAll(_touched);
        batchLost.addAll(_lostLister);
      }
      if (_failed && !atomic) {
        // Roll back: the nodes as they were, in reverse.
        for (final e in _before.entries.toList().reversed) {
          _put(e.key, e.value);
        }
        roots = savedRoots;
        extra = savedExtra;
        fields = savedFields;
        rejected.add(index);
      } else if (_failed) {
        rejected.add(index);
      } else {
        applied.add(index);
        appliedOps.add(op);
        if (wasNew) created.add(op.id);
      }
      all.addAll(_diags);
      _diags.clear();
    }
    if (atomic) {
      _op = -1;
      if (rejected.isEmpty) {
        _checkOp({for (final id in batchTouched.keys) if (nodes[id] != null) id: _json(nodes[id]!)}..addAll(batchTouched), batchLost,
            batchStart: true);
        all.addAll(_diags);
        if (_failed) rejected.addAll(applied);
        _diags.clear();
      }
      if (rejected.isNotEmpty) {
        // All or none.
        final kept = [for (final d in all) d];
        return _result(start, [], {...rejected, ...applied}.toList()..sort(), [], kept, revisions, const {});
      }
    }
    final changed = <String>{
      for (final id in {...nodes.keys, ...start.nodes.keys})
        if (!identical(nodes[id], start.nodes[id]) && nodes[id] != start.nodes[id]) id,
    };
    final rootsChanged = !jsonEquality.equals(roots, start.roots);
    final extraChanged = !jsonEquality.equals(extra, start.extra);
    if (changed.isEmpty && !rootsChanged && !extraChanged) {
      return _result(start, applied.toList()..sort(), rejected.toList()..sort(), appliedOps, all, revisions, const {}, created: created);
    }
    final doc = LayoutDocument(id: start.id, roots: roots, nodes: nodes, extra: extra, catalog: start.catalog ?? catalog);
    final next = EditRevisions(rev: _rev, fields: fields);
    return _result(doc, applied.toList()..sort(), rejected.toList()..sort(), appliedOps, all, next, changed,
        created: created, inverse: _inverse(start, doc));
  }

  EditResult _result(LayoutDocument doc, List<int> applied, List<int> rejected, List<EditOp> ops, List<EditDiagnostic> diags,
          EditRevisions revs, Set<String> changed,
          {Set<String> created = const {}, List<EditOp> inverse = const []}) =>
      EditResult(
        document: doc,
        applied: applied,
        rejected: rejected,
        appliedOps: ops,
        inverse: inverse,
        diagnostics: diags,
        pending: pendingIds(doc),
        rev: revs.rev,
        revisions: revs,
        changed: changed,
        created: created,
      );

  // --- one op -------------------------------------------------------------------

  /// The roots of the document being edited, when [protectRoots] holds and
  /// it has any.
  List<String> get _protected => protectRoots ? [for (final r in start.roots) if (start.nodes.containsKey(r)) r] : const [];

  void _startOver(String what) {
    final roots = _protected;
    _error(EditCodes.startOver,
        '$what, but the UI already exists: root ${roots.map((r) => '"$r"').join(', ')} with ${start.nodes.length} nodes (rev ${revisions.rev}). '
        'Do not start over: fix the existing document by patching it (patch fields, set missing nodes under their existing parents '
        'with the same ids, remove what is wrong).',
        path: '/ops/$_op');
  }

  void _applyOp(EditOp op) {
    final protected = _protected;
    if (protected.isNotEmpty) {
      if (op is RootsOp && protected.any((r) => !op.roots.contains(r))) {
        return _startOver('This roots op replaces ${protected.map((r) => '"$r"').join(', ')}');
      }
      if (op is SetOp && !nodes.containsKey(op.id) && readString(op.node['type']) == CanvasProps.spec.type) {
        return _startOver('This set creates a new canvas "${op.id}"');
      }
    }
    switch (op) {
      case SetOp():
        _set(op);
      case PatchOp():
        _patch(op);
      case MoveOp():
        _move(op);
      case RemoveOp():
        _remove(op);
      case VarsOp():
        _vars(op);
      case RootsOp():
        roots = [...op.roots];
    }
  }

  void _stale(String id, Iterable<String> paths) {
    final b = baseRev;
    if (b == null) return;
    final changed = EditRevisions(rev: revisions.rev, fields: fields).changedSince(id, b, author);
    for (final p in paths) {
      for (final e in changed.entries) {
        if (p == '*' || e.key == '*' || p == e.key || p.startsWith('${e.key}.') || e.key.startsWith('$p.')) {
          final current = nodes[id] == null ? null : _valueAt(_json(nodes[id]!), e.key == '*' ? p : e.key);
          _error(EditCodes.staleRev, 'Node "$id" ${e.key == '*' ? 'was replaced' : 'field ${e.key} was changed'} at rev ${e.value}, after baseRev $b.',
              path: editPointer('/nodes', id), nodeId: id, expected: current == null ? null : ['$current']);
          return;
        }
      }
    }
  }

  void _record(String id, Iterable<String> paths) {
    final m = fields[id] = {...?fields[id]};
    for (final p in paths) {
      m[p] = (_rev, author);
    }
  }

  void _set(SetOp op) {
    final id = op.id;
    final at = editPointer('/nodes', id);
    if (id.isEmpty) return _error(EditCodes.missingField, 'A set op needs a non-empty "id".', path: '/ops/$_op/id');
    if (op.node['children'] case final Object c when c is! List) {
      return _error(EditCodes.wrongType, '"children" is a list of node ids.', path: editPointer(at, 'children'), nodeId: id);
    }
    final n = _decode(id, op.node);
    if (n == null) {
      return _error(EditCodes.missingField, 'The node needs a "type" (one of the node types, such as "column" or "text").',
          path: editPointer(at, 'type'), nodeId: id);
    }
    final existing = nodes[id];
    _stale(id, const ['*']);
    if (profile.maxNodes != null && existing == null && nodes.length >= profile.maxNodes!) {
      _error(EditCodes.limitExceeded, 'At most ${profile.maxNodes} nodes.', path: at, nodeId: id);
    }
    // Children it drops.
    if (existing != null && !atomic) {
      final kept = n.childIds.toSet();
      final dropped = [for (final c in existing.childIds) if (!kept.contains(c) && nodes.containsKey(c)) c];
      if (dropped.isNotEmpty) {
        _error(EditCodes.wouldOrphan,
            'Replacing "$id" drops its children ${dropped.map((c) => '"$c"').join(', ')}, which exist: they would be left under no parent. '
            'To change "$id", patch it ({"op": "patch", "id": "$id", "patch": {...}}: it keeps its children); to replace it, '
            'keep them in "children" (or move or remove them first).',
            path: editPointer(at, 'children'), nodeId: id, expected: dropped);
      }
    }
    if (_failed) return;
    _put(id, n);
    _touched[id] = op.node;
    _record(id, const ['*']);
    final parent = op.parent;
    if (parent != null) {
      _place(id, parent, op.index, op.slot);
    } else if (existing == null && op.index != null) {
      _error(EditCodes.missingField, '"index" places the node under "parent": add "parent".', path: '/ops/$_op/parent', nodeId: id);
    }
  }

  /// Places [id] under [parentId] (at [index] or in [slot]), detaching it
  /// from where it was.
  void _place(String id, String parentId, int? index, String? slot) {
    final p = nodes[parentId];
    final at = editPointer('/nodes', id);
    if (p == null) {
      return _error(EditCodes.unknownId, 'No node "$parentId" to place "$id" under${_pendingNote(parentId)}.',
          path: '/ops/$_op/parent', nodeId: id, suggestion: nearestName(parentId, nodes.keys));
    }
    if (nodes[id]?.type == CanvasProps.spec.type) {
      return _error(EditCodes.canvasAsChild,
          'Canvas "$id" cannot be placed under "$parentId": a canvas is a screen, only ever a root. Put content in a column (or row, stack) instead.',
          path: at, nodeId: id);
    }
    final spec = p.spec;
    if (slot != null) {
      if (spec != null && !spec.slots.contains(slot)) {
        return _error(EditCodes.invalidParent, 'A ${p.type} has no slot "$slot"${spec.slots.isEmpty ? '' : '. Its slots: ${spec.slots.join(', ')}'}.',
            path: '/ops/$_op/slot', nodeId: parentId, expected: spec.slots, suggestion: nearestName(slot, spec.slots));
      }
    } else if (spec != null && spec.children != ChildModel.list) {
      return _error(EditCodes.invalidParent,
          spec.slots.isNotEmpty
              ? 'A ${p.type} takes no children list: give a "slot" (${spec.slots.join(', ')}).'
              : 'A ${p.type} takes no children: place "$id" under a ${containerTypes(catalog).take(4).join(', ')}. For a filled box with '
                  'content (a button, a tag), make the box a row or column with the decoration and padding.',
          path: '/ops/$_op/parent', nodeId: parentId, expected: spec.slots.isEmpty ? null : spec.slots);
    }
    // Where it is now.
    for (final l in [...?listers[id]]) {
      if (l == parentId) continue;
      final o = nodes[l]!;
      _put(l, _detached(o, id));
      _touched.putIfAbsent(l, () => _json(nodes[l]!));
    }
    final cur = nodes[parentId]!;
    Node next;
    if (slot != null) {
      final old = cur.slots[slot];
      if (old != null && old != id && nodes.containsKey(old) && !atomic) {
        return _error(EditCodes.wouldOrphan, 'Slot "$slot" of "$parentId" holds "$old": remove or move it first.',
            path: editPointer(editPointer(editPointer('/nodes', parentId), 'slots'), slot), nodeId: parentId, expected: [old]);
      }
      next = _detached(cur, id);
      next = next.copyWith(slots: {...next.slots, slot: id});
    } else {
      final list = [...cur.children];
      final was = list.indexOf(id);
      if (was >= 0 && (index == null || index == was)) {
        next = cur;
      } else {
        if (was >= 0) list.removeAt(was);
        final i = index == null ? list.length : index.clamp(0, list.length);
        list.insert(i, id);
        next = cur.copyWith(children: list);
        // A slot of the same parent that held it.
        if (next.slots.containsValue(id)) next = next.copyWith(slots: {for (final e in next.slots.entries) if (e.value != id) e.key: e.value});
      }
    }
    if (!identical(next, cur)) {
      _put(parentId, next);
      _touched[parentId] = _json(next);
      _record(parentId, const ['children']);
    }
    // Moving under its own subtree.
    if (_isWithin(parentId, id) && parentId != id || parentId == id) {
      _error(EditCodes.cycle, 'Placing "$id" under "$parentId" puts it inside itself.', path: at, nodeId: id);
    }
  }

  String _pendingNote(String id) => {for (final l in listers[id] ?? const <String>{}) l}.isNotEmpty
      ? ' (it is listed by "${listers[id]!.first}" but has not arrived: set it first)'
      : '';

  Node _detached(Node n, String id) => n.copyWith(
        children: n.children.contains(id) ? [for (final c in n.children) if (c != id) c] : null,
        slots: n.slots.containsValue(id) ? {for (final e in n.slots.entries) if (e.value != id) e.key: e.value} : null,
      );

  void _patch(PatchOp op) {
    final id = op.id;
    final n = nodes[id];
    final at = editPointer('/nodes', id);
    if (n == null) {
      return _error(EditCodes.unknownId, 'No node "$id" to patch${_pendingNote(id)}.',
          path: '/ops/$_op/id', nodeId: id, suggestion: nearestName(id, nodes.keys));
    }
    for (final k in const ['children', 'slots', 'type', 'id']) {
      if (op.patch.containsKey(k)) {
        _error(EditCodes.structuralKeyInPatch,
            k == 'type'
                ? 'A patch cannot change "type": set the node again.'
                : k == 'id'
                    ? 'A patch cannot change a node\'s id: it is its address.'
                    : 'A patch cannot change "$k": use set (with parent), move and remove.',
            path: editPointer(at, k), nodeId: id);
      }
    }
    if (_failed) return;
    final paths = _leafPaths(op.patch, '').toList();
    _stale(id, paths);
    if (_failed) return;
    final merged = mergePatch(_json(n), op.patch);
    final next = _decode(id, merged) ?? n;
    _put(id, next);
    _touched[id] = merged;
    _record(id, paths);
  }

  void _move(MoveOp op) {
    if (!nodes.containsKey(op.id)) {
      return _error(EditCodes.unknownId, 'No node "${op.id}" to move.', path: '/ops/$_op/id', nodeId: op.id, suggestion: nearestName(op.id, nodes.keys));
    }
    _place(op.id, op.parent, op.index, op.slot);
    if (!_failed) {
      _touched.putIfAbsent(op.id, () => _json(nodes[op.id]!));
      _record(op.id, const ['parent']);
    }
  }

  void _remove(RemoveOp op) {
    for (var i = 0; i < op.ids.length; i++) {
      final id = op.ids[i];
      if (!nodes.containsKey(id)) {
        // Already gone: a warning, the rest are removed.
        _diags.add(EditDiagnostic(op: _op, code: EditCodes.unknownId.name, error: false, path: '/ops/$_op/ids/$i', nodeId: id,
            message: 'No node "$id" to remove (already removed?).'));
        continue;
      }
      // Detach from its parents.
      for (final l in [...?listers[id]]) {
        final o = nodes[l];
        if (o == null) continue;
        _put(l, _detached(o, id));
        _touched[l] = _json(nodes[l]!);
        _record(l, const ['children']);
      }
      final sub = <String>[];
      final stack = [id];
      while (stack.isNotEmpty) {
        final x = stack.removeLast();
        if (sub.contains(x) || !nodes.containsKey(x)) continue;
        sub.add(x);
        stack.addAll(nodes[x]!.childIds);
      }
      for (final x in sub) {
        _put(x, null);
        _touched.remove(x);
        _record(x, const ['*']);
      }
      roots = [for (final r in roots) if (!sub.contains(r)) r];
    }
  }

  void _vars(VarsOp op) {
    final scope = op.scope;
    final known = scope == 'page_variables' || nodes[scope]?.type == CanvasProps.spec.type || roots.contains(scope);
    if (!known) {
      return _error(EditCodes.unknownId, 'Variables are kept per canvas id or "page_variables"; "$scope" is neither.',
          path: '/ops/$_op/scope', suggestion: nearestName(scope, [..._screens, 'page_variables']));
    }
    final all = {...?readMap(extra[LayoutLogic.variablesKey])};
    final list = [...?readList(all[scope])?.map(readMap).nonNulls];
    int find(String name) => list.indexWhere((v) => v['name'] == name);
    for (final e in op.set.entries) {
      final p = editPointer(editPointer('/ops/$_op', 'set'), e.key);
      final v = e.value;
      final i = find(e.key);
      const varKeys = {'id', 'type', 'value', 'formula', 'parameters', 'options', 'persist'};
      final holdsMap = i >= 0 && list[i]['type'] == VariableType.map.name;
      final declares = v is Map &&
          v.isNotEmpty &&
          v.keys.every(varKeys.contains) &&
          (v.containsKey('type') || v.containsKey('formula') || (!holdsMap && v.containsKey('value')));
      if (declares) {
        final decl = <String, Object?>{...readMap(v)!, 'name': e.key};
        final parsed = Variable.fromJson(decl);
        if (parsed == null) {
          _error(EditCodes.invalidVariable, 'Variable "${e.key}" could not be read.', path: p);
          continue;
        }
        final raw = decl['value'];
        if (raw != null && parsed.type.coerce(raw) == null) {
          _error(EditCodes.invalidVariable, 'A ${parsed.type.name} variable cannot hold $raw.', path: editPointer(p, 'value'));
          continue;
        }
        if (i >= 0) {
          list[i] = decl;
        } else {
          list.add(decl);
        }
      } else if (i >= 0) {
        final type = readEnum(VariableType.values, list[i]['type'], VariableType.text);
        if (v != null && type.coerce(v) == null) {
          _error(EditCodes.invalidVariable, 'Variable "${e.key}" is ${type.name}: it cannot hold ${v is String ? '"$v"' : v}.',
              path: p, expected: [type.name]);
          continue;
        }
        list[i] = {...list[i], 'value': v};
      } else {
        final type = switch (v) {
          bool _ => VariableType.boolean,
          int _ => VariableType.integer,
          num _ => VariableType.decimal,
          List _ => VariableType.list,
          Map _ => VariableType.map,
          _ => VariableType.text,
        };
        _diags.add(EditDiagnostic(op: _op, code: EditCodes.unknownVariable.name, error: false, path: p,
            message: '"${e.key}" was not declared in "$scope": declared it as ${type.name}.'));
        list.add({'name': e.key, if (type != VariableType.text) 'type': type.name, 'value': v});
      }
    }
    for (final name in op.remove) {
      final i = find(name);
      if (i < 0) {
        _diags.add(EditDiagnostic(op: _op, code: EditCodes.unknownVariable.name, error: false, path: '/ops/$_op/remove',
            message: 'No variable "$name" in "$scope" to remove.'));
      } else {
        list.removeAt(i);
      }
    }
    if (_failed) return;
    all[scope] = list;
    extra = {...extra, LayoutLogic.variablesKey: all};
  }

  // --- checks ---------------------------------------------------------------------

  /// The structure around [touched] (one parent each, no cycle, no canvas
  /// as a child, nothing orphaned: [lost] lost a parent), the trust
  /// profile, and [check] on the touched nodes.
  void _checkOp(Map<String, Json> touched, Set<String> lost, {bool batchStart = false}) {
    for (final id in touched.keys) {
      final n = nodes[id];
      if (n == null) continue;
      final at = editPointer('/nodes', id);
      final seen = <String>{};
      for (final c in n.childIds) {
        if (!seen.add(c)) {
          _error(EditCodes.multipleParents, '"$c" is listed twice in "$id".', path: at, nodeId: id);
          continue;
        }
        final l = listers[c] ?? const {};
        if (l.length > 1) {
          _error(EditCodes.multipleParents,
              '"$c" would be a child of ${l.map((p) => '"$p"').join(' and ')}: a node has one parent. Use move to change its parent.',
              path: at, nodeId: c);
        }
        if (nodes[c]?.type == CanvasProps.spec.type) {
          _error(EditCodes.canvasAsChild,
              'Canvas "$c" cannot be a child (or slot) of "$id": a canvas is a screen, only ever a root. ${n.type == CanvasProps.spec.type ? 'Canvases do not nest: give "$id" a column as its body and put the content there.' : 'Use a column (or row, stack) for content.'}',
              path: at, nodeId: c);
        }
        if (c == id || (nodes.containsKey(c) && _isWithin(id, c))) {
          _error(EditCodes.cycle, '"$c" would contain itself (through "$id").', path: at, nodeId: c);
        }
      }
      if (n.type == CanvasProps.spec.type && (listers[id]?.isNotEmpty ?? false)) {
        _error(EditCodes.canvasAsChild,
            'Canvas "$id" cannot be a child (or slot) of "${listers[id]!.first}": a canvas is a screen, only ever a root. Make "$id" a column (or row, stack) instead.',
            path: at, nodeId: id);
      }
    }
    for (final c in lost) {
      if (!nodes.containsKey(c)) continue;
      if ((listers[c]?.isNotEmpty ?? false) || roots.contains(c)) continue;
      if (batchStart && !startListed.contains(c)) continue;
      _error(EditCodes.wouldOrphan, '"$c" would be left under no parent: move it somewhere, or remove it.', path: editPointer('/nodes', c), nodeId: c);
    }
    if (profile.maxDepth != null) {
      for (final id in touched.keys) {
        var d = 0;
        String? x = id;
        final seen = <String>{};
        while (x != null && seen.add(x)) {
          d++;
          x = listers[x]?.firstOrNull;
        }
        if (d > profile.maxDepth!) {
          _error(EditCodes.limitExceeded, '"$id" is $d levels deep: at most ${profile.maxDepth}.', path: editPointer('/nodes', id), nodeId: id);
          break;
        }
      }
    }
    final screens = {..._screens, for (final e in listers.keys) if (!nodes.containsKey(e)) e};
    for (final e in touched.entries) {
      if (!nodes.containsKey(e.key)) continue;
      _diags.addAll(profile.checkNode(e.key, e.value,
          op: _op, catalog: catalog, screens: profile.navigation == NavigationLimit.withinDocument ? screens : null));
    }
    final ch = check;
    if (ch != null) {
      final live = {for (final e in touched.entries) if (nodes.containsKey(e.key)) e.key: e.value};
      if (live.isEmpty) return;
      final doc = LayoutDocument(id: start.id, roots: roots, nodes: nodes, extra: extra, catalog: start.catalog ?? catalog);
      _diags.addAll([
        for (final d in ch(EditCheckInput(document: doc, nodes: live, op: _op, catalog: catalog, screens: screens, incomplete: incomplete)))
          explainDiagnostic(d.atOp(_op), catalog: catalog, node: d.nodeId == null ? null : live[d.nodeId]),
      ]);
    }
  }
}

/// The ops that turn [after] back into [before] (apply them with `atomic:
/// true`): what [EditResult.inverse] holds for one batch, for any two
/// documents (a whole stream of batches).
List<EditOp> inverseOps(LayoutDocument before, LayoutDocument after) => _inverse(before, after);

/// The ops that turn [after] back into [before]: removes for nodes added,
/// sets (whole node, children lists included) for nodes changed or removed,
/// and the roots and variables as they were. Applied atomically (the
/// structure is checked at the end, when it is [before]'s again).
List<EditOp> _inverse(LayoutDocument before, LayoutDocument after) {
  final out = <EditOp>[];
  final added = [for (final id in after.nodes.keys) if (!before.nodes.containsKey(id)) id];
  Json j(Node n) => n.toJson()..remove('id');
  // An added node first lets go of children that were there before (a
  // remove takes the whole subtree).
  for (final id in added) {
    final n = after.nodes[id]!;
    if (n.childIds.any(before.nodes.containsKey)) out.add(SetOp(id, j(n)..remove('children')..remove('slots')));
  }
  if (added.isNotEmpty) out.add(RemoveOp(added));
  for (final e in before.nodes.entries) {
    final a = after.nodes[e.key];
    if (a == null || a != e.value) out.add(SetOp(e.key, j(e.value)));
  }
  if (!jsonEquality.equals(before.roots, after.roots)) out.add(RootsOp(before.roots));
  final bv = readMap(before.extra[LayoutLogic.variablesKey]) ?? const {};
  final av = readMap(after.extra[LayoutLogic.variablesKey]) ?? const {};
  for (final scope in {...bv.keys, ...av.keys}) {
    if (jsonEquality.equals(bv[scope], av[scope])) continue;
    final b = [...?readList(bv[scope])?.map(readMap).nonNulls];
    final a = [...?readList(av[scope])?.map(readMap).nonNulls];
    final bNames = {for (final v in b) v['name']};
    out.add(VarsOp(scope,
        set: {for (final v in b) '${v['name']}': {...v}..remove('name')},
        remove: [for (final v in a) if (!bNames.contains(v['name'])) '${v['name']}']));
  }
  return out;
}

Iterable<String> _leafPaths(Object? v, String at) sync* {
  if (v is Map && v.isNotEmpty) {
    for (final e in v.entries) {
      yield* _leafPaths(e.value, at.isEmpty ? '${e.key}' : '$at.${e.key}');
    }
  } else if (at.isNotEmpty) {
    yield at;
  }
}

Object? _valueAt(Json json, String path) {
  Object? v = json;
  for (final p in path.split('.')) {
    if (v is Map) {
      v = v[p];
    } else {
      return null;
    }
  }
  return v;
}

/// The declared prop keys of [type] in [catalog] (for messages).
List<String> declaredProps(Catalog catalog, String type) => [for (final p in catalog.widget(type)?.props ?? const <PropDef<Object?>>[]) p.key];
