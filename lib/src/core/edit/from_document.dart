// A whole document as the ops a model would write to build it, top-down:
// the roots, the variables, each canvas, its page container, then each
// section and everything in it before the next section. Generation is just
// the first batch of ops; this is that batch for a document that exists
// (to replay a page as a stream, or to send a document through a session).
import 'dart:convert';

import '../document.dart';
import '../json.dart';
import '../logic.dart';
import 'edit_ops.dart';

/// The ops that build [document] from nothing, in the order a model writes
/// them top-down: `roots`, one `vars` op per variable scope, then each
/// canvas's nodes depth-first (a node before its children, the first
/// section complete before the second). Nodes no root reaches come last.
List<EditOp> opsFromDocument(LayoutDocument document) {
  final out = <EditOp>[RootsOp(document.roots)];
  final scopes = readMap(document.extra[LayoutLogic.variablesKey]) ?? const {};
  final seen = <String>{};
  void visit(String id) {
    final n = document[id];
    if (n == null || !seen.add(id)) return;
    out.add(SetOp(id, n.toJson()..remove('id')));
    if (n.type == 'canvas' && out.whereType<VarsOp>().every((v) => v.scope != id) && scopes[id] != null) {
      out.add(_vars(id, scopes[id]));
    }
    for (final c in n.childIds) {
      visit(c);
    }
  }

  for (final e in scopes.entries) {
    if (e.key == 'page_variables') out.add(_vars(e.key, e.value));
  }
  for (final r in document.roots) {
    visit(r);
  }
  for (final id in document.nodes.keys) {
    if (!seen.contains(id) && document.parentOf(id) == null) visit(id);
  }
  // Scopes of canvases that are not roots, and anything else.
  for (final e in scopes.entries) {
    if (e.key != 'page_variables' && !out.whereType<VarsOp>().any((v) => v.scope == e.key)) out.add(_vars(e.key, e.value));
  }
  return out;
}

VarsOp _vars(String scope, Object? list) => VarsOp(scope, set: {
      for (final v in readList(list) ?? const [])
        if (readMap(v) case final Json m when m['name'] is String) m['name']! as String: {...m}..remove('name'),
    });

/// [ops] as a `ui_apply` tool input, the way a model streams it: compact
/// JSON, one op per line.
String toolInputText(List<EditOp> ops, {int? baseRev}) {
  final b = StringBuffer('{');
  if (baseRev != null) b.write('"baseRev":$baseRev,');
  b.write('"ops":[\n');
  for (var i = 0; i < ops.length; i++) {
    b.write(jsonEncode(ops[i].toJson()));
    b.write(i == ops.length - 1 ? '\n' : ',\n');
  }
  b.write(']}');
  return b.toString();
}
