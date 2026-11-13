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
/// them top-down: `roots`, then each canvas's nodes depth-first (its
/// state variables right after it, a large data variable just before the
/// first node that reads it) (a node before its children, the first
/// section complete before the second). Nodes no root reaches come last.
List<EditOp> opsFromDocument(LayoutDocument document) {
  final out = <EditOp>[RootsOp(document.roots)];
  final scopes = readMap(document.extra[LayoutLogic.variablesKey]) ?? const {};
  // Small variables (state: a tab, a toggle) come with their canvas; a large
  // one (a list of data) just before the first node that reads it, as a
  // model writes the data where it needs it, so the first section paints
  // before the data of the last.
  final late = <String, (String, Json)>{};
  final early = <String, List<Json>>{};
  for (final e in scopes.entries) {
    for (final v in readList(e.value) ?? const []) {
      final m = readMap(v);
      if (m == null || m['name'] is! String) continue;
      if (jsonEncode(m).length > _largeVariable) {
        late[m['name']! as String] = (e.key, m);
      } else {
        (early[e.key] ??= []).add(m);
      }
    }
  }
  final seen = <String>{};
  void declare(String scope, List<Json> vars) {
    if (vars.isNotEmpty) out.add(_vars(scope, vars));
  }

  void visit(String id) {
    final n = document[id];
    if (n == null || !seen.add(id)) return;
    final json = n.toJson()..remove('id');
    if (late.isNotEmpty) {
      final text = jsonEncode(json);
      for (final name in [...late.keys]) {
        if (RegExp('\\b${RegExp.escape(name)}\\b').hasMatch(text)) {
          final (scope, v) = late.remove(name)!;
          declare(scope, [v]);
        }
      }
    }
    out.add(SetOp(id, json));
    if (n.type == 'canvas') declare(id, early.remove(id) ?? const []);
    for (final c in n.childIds) {
      visit(c);
    }
  }

  declare('page_variables', early.remove('page_variables') ?? const []);
  for (final r in document.roots) {
    visit(r);
  }
  for (final id in document.nodes.keys) {
    if (!seen.contains(id) && document.parentOf(id) == null) visit(id);
  }
  // What nothing read, and scopes of canvases that are not roots.
  for (final e in early.entries) {
    declare(e.key, e.value);
  }
  for (final e in late.values) {
    declare(e.$1, [e.$2]);
  }
  return out;
}

/// The JSON size above which a variable is declared where it is first read.
const int _largeVariable = 400;

VarsOp _vars(String scope, List<Json> vars) => VarsOp(scope, set: {
      for (final m in vars) m['name']! as String: {...m}..remove('name'),
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
