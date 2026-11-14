// The strict validator run incrementally on what an edit op touched: the
// nodes it created, changed or re-parented, validated in a small document
// made of them, their parents and their children (so placement fields are
// checked against the real parent) with the document's variables. The tree
// checks the edit layer does itself (pending children, one parent, cycles,
// reachability) are left out.
import '../core/document.dart';
import '../core/edit/apply.dart';
import '../core/edit/diagnostics.dart';
import 'diagnostic.dart';
import 'validator.dart';

/// Codes the edit layer reports itself, or that mean nothing for a part of
/// a document.
/// References to what may arrive later in a stream.
const Set<String> _references = {'unknown_target_node', 'unknown_screen', 'unknown_variable', 'unknown_name'};

const Set<String> _structural = {
  'dangling_child', 'dangling_slot', 'unreachable_node', 'multiple_parents', 'cycle', 'canvas_as_child', 'no_roots', //
  'dangling_root', 'root_not_canvas', 'schema_version', 'unknown_scope', 'duplicate_id',
};

/// An [EditCheck] that runs [validateDocument] on the nodes an op touched
/// (with [options]: formulas, the project's screens, variables, components
/// and theme). Its
/// diagnostics keep the validator's codes, paths and suggestions; an error
/// rejects the op.
EditCheck strictEditCheck([ValidateOptions options = const ValidateOptions()]) => (input) {
      final doc = input.document;
      final ids = <String>{...input.nodes.keys};
      final around = <String>{};
      for (final id in ids) {
        final p = doc.parentOf(id);
        if (p != null) around.add(p);
        for (final c in doc[id]?.childIds ?? const <String>[]) {
          if (doc[c] != null) around.add(c);
        }
      }
      // The rest of the document as stubs: what states, actions and
      // navigation name exists.
      final nodes = <String, Object?>{
        for (final n in doc.nodes.values)
          if (!ids.contains(n.id) && !around.contains(n.id)) n.id: {'type': n.type},
        for (final id in around)
          if (!ids.contains(id)) id: doc[id]!.toJson()..remove('id'),
        for (final e in input.nodes.entries) e.key: e.value,
      };
      final mini = <String, Object?>{
        'schema': kSchemaVersion,
        'roots': [for (final r in doc.roots) if (nodes.containsKey(r)) r],
        'nodes': nodes,
        ...{
          for (final e in doc.extra.entries)
            if (documentKeys.contains(e.key)) e.key: e.value,
        },
      };
      final o = ValidateOptions(
        screens: {...options.screens, ...input.screens, for (final n in doc.nodes.values) if (n.type == 'canvas') n.id},
        variables: options.variables,
        formulas: options.formulas,
        breakpoints: options.breakpoints,
        components: options.components,
        theme: options.theme,
      );
      final out = <EditDiagnostic>[];
      for (final d in validateDocument(mini, options: o)) {
        if (_structural.contains(d.code.name)) continue;
        final id = d.nodeId ?? _nodeOf(d.path);
        if (id == null || !ids.contains(id)) continue;
        final later = input.incomplete && _references.contains(d.code.name);
        out.add(EditDiagnostic(
          op: input.op,
          code: d.code.name,
          error: d.isError && !later,
          path: d.path,
          message: later ? '${d.message} (Accepted while the UI streams in: it must exist when the stream ends.)' : d.message,
          nodeId: id,
          suggestion: d.suggestion,
        ));
      }
      return out;
    };

String? _nodeOf(String path) {
  final m = RegExp(r'^/nodes/([^/]+)').firstMatch(path);
  return m?[1]?.replaceAll('~1', '/').replaceAll('~0', '~');
}

/// The document [ops] build, checked as a whole by [validateDocument] (what
/// a stream produced, once it ended).
List<Diagnostic> validateEdited(LayoutDocument document, {ValidateOptions options = const ValidateOptions()}) =>
    validateDocument(document.toJson(), options: options);
