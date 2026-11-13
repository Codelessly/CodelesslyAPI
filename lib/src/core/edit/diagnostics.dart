// What applying edit operations reports: per op, a code, where (a JSON
// pointer into the document), a message, what was expected and a
// suggestion. The codes of the edit layer are declared here; a check run
// on what an op touched (the strict validator, or the core's catalog check)
// reports its own codes through the same type.
import 'package:meta/meta.dart';

import '../json.dart';

/// One diagnostic code of the edit layer: its name, whether it rejects the
/// op, and what it means.
@immutable
final class EditCode {
  const EditCode(this.name, this.meaning, {this.error = true});

  /// As written in an [EditDiagnostic] (`unknown_id`).
  final String name;

  /// Whether an op that has it is rejected (not applied).
  final bool error;

  /// One sentence: what it reports.
  final String meaning;

  @override
  String toString() => name;
}

/// The codes the edit layer itself reports. A check of the nodes an op
/// touched adds the validator's codes (`unknown_prop`, `wrong_type`,
/// `invalid_enum`...), listed with strict validation.
abstract final class EditCodes {
  static const invalidOp = EditCode('invalid_op', 'An op that is not an object, or names no known "op" (set, patch, move, remove, vars, roots).');
  static const missingField = EditCode('missing_field', 'An op without a field it needs ("id", "node", "patch", "parent", "ids", "scope", "roots").');
  static const wrongType = EditCode('wrong_type', 'A field of an op with the wrong JSON type (an id that is not text, a node that is not an object).');
  static const unknownId = EditCode('unknown_id', 'A patch, move or remove of a node the document does not have, or a set or move under a parent it does not have.');
  static const structuralKeyInPatch = EditCode('structural_key_in_patch',
      'A patch that changes "children" or "slots" (or "type"): child lists change only through set, move and remove; a type through set.');
  static const staleRev = EditCode('stale_rev',
      'The op changes a field another author changed after the batch\'s "baseRev": re-read the node (ui_read) and decide.');
  static const wouldOrphan = EditCode('would_orphan',
      'A set that replaces a node and drops children it had: they would be left under no parent. Keep them in "children", move or remove them first, or use patch.');
  static const multipleParents = EditCode('multiple_parents',
      'The op would list a node under a second parent (or twice in one): a node has one parent. Use move to change its parent.');
  static const cycle = EditCode('cycle', 'The op would put a node inside its own subtree.');
  static const canvasAsChild = EditCode('canvas_as_child', 'The op would place a canvas under a parent: canvases are only roots.');
  static const invalidParent = EditCode('invalid_parent',
      'A set or move under a parent that takes no children there: a type without children, or a slot the type does not have.');
  static const danglingChild = EditCode('dangling_child',
      'At the end of the stream, a child or slot id that names no node (it was pending and never arrived).');
  static const unreachableNode = EditCode('unreachable_node',
      'At the end of the stream, a node no root reaches (nothing lists it as a child or slot).', error: false);
  static const pendingChild = EditCode('pending_child',
      'A child or slot id the op lists that has not arrived yet: accepted while streaming, an error (dangling_child) if it never comes.',
      error: false);
  static const capabilityNotAllowed = EditCode('capability_not_allowed',
      'The op uses a node type, action, script, link, image host or navigation target the session\'s trust profile does not allow.');
  static const limitExceeded = EditCode('limit_exceeded',
      'The op would exceed a limit of the trust profile (nodes, depth, text length, ops per call).');
  static const truncatedOp = EditCode('truncated_op', 'The stream ended inside an op: what arrived of it was not applied.');
  static const invalidJson = EditCode('invalid_json', 'The tool input is not JSON where an op was expected.');
  static const invalidVariable = EditCode('invalid_variable', 'A vars op that declares a variable without a name, or sets one with a value its type cannot hold.');
  static const unknownVariable = EditCode('unknown_variable',
      'A vars op that sets (or removes) a variable the scope does not declare: declare it with a full variable object.', error: false);

  static const malformedInput = EditCode(
      'malformed_input',
      'The tool input\'s JSON was not well formed at a character offset (a stray or missing brace or bracket, a '
          'trailing or missing comma, an op that began before the previous one closed): the decoder repaired it '
          'and read the ops around it. Write balanced JSON: one closing brace per opening brace.',
      error: false);
  static const misplacedField = EditCode('misplaced_field',
      'A node field ("bind", "props", "actions"...) written on a set op instead of inside its "node": it was moved into the node.',
      error: false);
  static const startOver = EditCode('start_over',
      'A batch that rebuilds a UI that already exists (new roots, a new canvas) instead of patching it: fix the '
          'existing document with patch, set (same ids) and remove; never start over.');

  static const List<EditCode> all = [
    invalidOp, missingField, wrongType, unknownId, structuralKeyInPatch, staleRev, wouldOrphan, multipleParents, cycle, //
    canvasAsChild, invalidParent, danglingChild, unreachableNode, pendingChild, capabilityNotAllowed, limitExceeded,
    truncatedOp, invalidJson, invalidVariable, unknownVariable, malformedInput, misplacedField, startOver,
  ];
}

/// One problem with one op of a batch.
@immutable
final class EditDiagnostic {
  const EditDiagnostic({
    required this.op,
    required this.code,
    required this.message,
    this.path = '',
    this.error = true,
    this.nodeId,
    this.expected,
    this.suggestion,
  });

  /// The index of the op in its batch; -1 for the batch as a whole (the end
  /// of a stream, a malformed tool input).
  final int op;

  /// The code (`unknown_id`, `unknown_prop`...).
  final String code;

  /// Whether the op was rejected for it. A warning (false) is reported and
  /// the op applies.
  final bool error;

  /// A JSON pointer into the document (`/nodes/heroCta/props/style`), or
  /// into the op (`/ops/3/id`) when the op itself is malformed.
  final String path;
  final String message;
  final String? nodeId;

  /// What would have been accepted there (field names, enum values), when
  /// the declarations say.
  final List<String>? expected;

  /// The nearest accepted value, when one is close.
  final String? suggestion;

  /// From an [EditCode].
  factory EditDiagnostic.of(EditCode code, int op, String message,
          {String path = '', String? nodeId, List<String>? expected, String? suggestion}) =>
      EditDiagnostic(
          op: op, code: code.name, error: code.error, message: message, path: path, nodeId: nodeId, expected: expected, suggestion: suggestion);

  EditDiagnostic atOp(int index) => EditDiagnostic(
      op: index, code: code, error: error, message: message, path: path, nodeId: nodeId, expected: expected, suggestion: suggestion);

  /// As the tool result carries it (`{"op": 1, "code": ..., "path": ..., "message": ...}`).
  Json toJson() => {
        'op': op,
        'code': code,
        if (!error) 'severity': 'warning',
        if (path.isNotEmpty) 'path': path,
        'message': message,
        'nodeId': ?nodeId,
        'expected': ?expected,
        'suggestion': ?suggestion,
      };

  static EditDiagnostic fromJson(Json json) => EditDiagnostic(
        op: readInt(json['op']) ?? -1,
        code: readString(json['code']) ?? '',
        error: json['severity'] != 'warning',
        path: readString(json['path']) ?? '',
        message: readString(json['message']) ?? '',
        nodeId: readString(json['nodeId']),
        expected: json['expected'] == null ? null : readStrings(json['expected']),
        suggestion: readString(json['suggestion']),
      );

  @override
  String toString() => '${error ? 'error' : 'warning'} $code op $op${path.isEmpty ? '' : ' $path'}: $message'
      '${suggestion == null ? '' : ' (did you mean "$suggestion"?)'}';
}

/// [path] extended by [key], escaped as a JSON pointer token.
String editPointer(String path, Object key) => '$path/${'$key'.replaceAll('~', '~0').replaceAll('/', '~1')}';

/// The candidate nearest to [word] (case-insensitive edit distance), or
/// null when none is close.
String? nearestName(String word, Iterable<String> candidates) {
  String? best;
  var bestScore = 1 << 30;
  final w = word.toLowerCase();
  for (final c in candidates) {
    final l = c.toLowerCase();
    if (l == w) return c;
    var d = _distance(w, l);
    if (w.length >= 3 && (l.startsWith(w) || w.startsWith(l) || l.contains(w))) d = d < 1 ? d : 1;
    if (d < bestScore) {
      bestScore = d;
      best = c;
    }
  }
  if (best == null) return null;
  final limit = word.length <= 4 ? 1 : (word.length <= 8 ? 2 : 3);
  return bestScore <= limit ? best : null;
}

int _distance(String a, String b) {
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0);
    cur[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      final x = prev[j] + 1, y = cur[j - 1] + 1, z = prev[j - 1] + cost;
      cur[j] = x < y ? (x < z ? x : z) : (y < z ? y : z);
    }
    prev = cur;
  }
  return prev[b.length];
}
