// What strict validation reports: a code, a severity, where (a JSON
// pointer into the document) and a message, with a suggestion when one
// can be made from the declarations.
import 'package:meta/meta.dart';

import '../core/json.dart';

/// How bad a [Diagnostic] is.
enum Severity {
  /// The document doesn't mean what it says: decoding drops or replaces the
  /// value, or a reference names nothing.
  error,

  /// Legal, but probably not what was meant (a value the renderer ignores,
  /// a node nothing shows).
  warning,
}

/// One diagnostic code: its name, severity and what it means.
@immutable
final class DiagnosticCode {
  const DiagnosticCode(this.name, this.severity, this.meaning);

  /// The code as written in a [Diagnostic] (`unknown_prop`).
  final String name;
  final Severity severity;

  /// One sentence: what it reports.
  final String meaning;

  @override
  String toString() => name;
}

/// Every code [validateDocument] reports.
abstract final class Codes {
  // --- document shape ---------------------------------------------------------
  static const invalidDocument = DiagnosticCode('invalid_document', Severity.error,
      'The document is not a JSON object, or a top-level key has the wrong shape (nodes not an object, roots not a list).');
  static const schemaVersion = DiagnosticCode('schema_version', Severity.warning,
      'The document has no "schema": 2, or another version.');
  static const unknownDocumentKey = DiagnosticCode('unknown_document_key', Severity.error,
      'A top-level key of the document that nothing reads.');
  static const danglingRoot = DiagnosticCode('dangling_root', Severity.error, 'A root id that names no node.');
  static const rootNotCanvas = DiagnosticCode('root_not_canvas', Severity.warning,
      'A root that is not a canvas: it is never shown as a screen.');
  static const noRoots = DiagnosticCode('no_roots', Severity.error, 'The document has no roots, so nothing is shown.');

  // --- nodes -----------------------------------------------------------------
  static const invalidNode = DiagnosticCode('invalid_node', Severity.error,
      'A node that is not an object or has no "type": decoding drops it.');
  static const unknownNodeType = DiagnosticCode('unknown_node_type', Severity.error,
      'A node type no declaration knows: it renders as an empty box.');
  static const unknownNodeKey = DiagnosticCode('unknown_node_key', Severity.error,
      'A key on a node that is neither a node field nor a behavior: it is kept but does nothing.');
  static const unknownProp = DiagnosticCode('unknown_prop', Severity.error,
      'A key in "props" that the node type does not declare: it does nothing.');
  static const unknownLayoutKey = DiagnosticCode('unknown_layout_key', Severity.error,
      'A key in "layout" that layout does not read.');
  static const unknownDecorationKey = DiagnosticCode('unknown_decoration_key', Severity.error,
      'A key in "decoration" that decoration does not read.');
  static const unknownField = DiagnosticCode('unknown_field', Severity.error,
      'A key inside a value (a paint, a text style, a behavior model...) that its type does not read.');
  static const wrongType = DiagnosticCode('wrong_type', Severity.error,
      'A value of the wrong JSON type or shape: decoding ignores it and uses the default.');
  static const looseValue = DiagnosticCode('loose_value', Severity.warning,
      'A value of another JSON type that decoding converts (the text "12" for a number): write the type itself.');
  static const invalidEnum = DiagnosticCode('invalid_enum', Severity.error,
      'A value that is not one of the allowed names: decoding uses the default.');
  static const outOfRange = DiagnosticCode('out_of_range', Severity.error,
      'A number outside its declared bounds: decoding clamps it.');
  static const decorationIgnored = DiagnosticCode('decoration_ignored', Severity.warning,
      'Fills, strokes, radius or shadows on a type without a box decoration: only blur effects are kept.');

  // --- tree ------------------------------------------------------------------
  static const danglingChild = DiagnosticCode('dangling_child', Severity.error, 'A child id that names no node.');
  static const danglingSlot = DiagnosticCode('dangling_slot', Severity.error, 'A slot whose id names no node.');
  static const multipleParents = DiagnosticCode('multiple_parents', Severity.error,
      'A node listed as a child (or slot) of more than one parent, or twice in one parent.');
  static const cycle = DiagnosticCode('cycle', Severity.error, 'A node that contains itself.');
  static const unreachableNode = DiagnosticCode('unreachable_node', Severity.warning,
      'A node no root reaches: it is never shown.');
  static const unknownSlot = DiagnosticCode('unknown_slot', Severity.error, 'A slot name the node type does not have.');
  static const childrenNotAllowed = DiagnosticCode('children_not_allowed', Severity.error,
      'A "children" list on a type that takes none (or takes slots only): they are never shown.');
  static const slotsNotAllowed = DiagnosticCode('slots_not_allowed', Severity.error,
      'A "slots" map on a type that has no slots.');
  static const canvasAsChild = DiagnosticCode('canvas_as_child', Severity.error,
      'A canvas used as the child of another node: canvases are screens, only roots.');
  static const layoutFieldIgnored = DiagnosticCode('layout_field_ignored', Severity.warning,
      'A layout field the node\'s parent does not read (x/y outside a stack, flex/align outside a row or column).');
  static const fitNotAllowed = DiagnosticCode('fit_not_allowed', Severity.warning,
      'A width or height mode the parent cannot honor (fill along a scrolling axis, flexible outside a row/column).');
  static const zeroSize = DiagnosticCode('zero_size', Severity.warning,
      'A fixed width or height of 0 (often a missing "width"/"height"): the node is invisible.');

  // --- bindings and expressions -------------------------------------------
  static const unknownBindPath = DiagnosticCode('unknown_bind_path', Severity.error,
      'A "bind" key that names no bindable field of the node.');
  static const reservedBindPath = DiagnosticCode('reserved_bind_path', Severity.warning,
      'A binding path that is kept but not applied yet.');
  static const expressionSyntax = DiagnosticCode('expression_syntax', Severity.error,
      'A "\${" that is not closed, or an empty \${}.');
  static const unknownName = DiagnosticCode('unknown_name', Severity.error,
      'An expression reads a name that is neither a declared variable nor a scope the runtime provides.');

  // --- reactions and actions ------------------------------------------------
  static const unknownTrigger = DiagnosticCode('unknown_trigger', Severity.error,
      'A reaction whose trigger type is unknown or missing: the reaction is dropped.');
  static const unknownTriggerKey = DiagnosticCode('unknown_trigger_key', Severity.error,
      'A key of a trigger that triggers do not read.');
  static const unknownActionType = DiagnosticCode('unknown_action_type', Severity.error,
      'An action type no declaration knows: the runtime skips it.');
  static const unknownActionKey = DiagnosticCode('unknown_action_key', Severity.error,
      'A key of an action that its type does not read.');
  static const unknownTargetNode = DiagnosticCode('unknown_target_node', Severity.error,
      'An action or condition names a node id that is not in the document.');
  static const unknownScreen = DiagnosticCode('unknown_screen', Severity.error,
      'A navigate or openModal names a screen (canvas or layout id) that does not exist.');
  static const unknownVariable = DiagnosticCode('unknown_variable', Severity.error,
      'An action or trigger names a variable that is not declared.');
  static const invalidReaction = DiagnosticCode('invalid_reaction', Severity.error,
      'A reaction or action that is not an object, or an action list that is not a list.');

  // --- variables, conditions, breakpoints -------------------------------
  static const invalidVariable = DiagnosticCode('invalid_variable', Severity.error,
      'A variable without a name, with an unknown type, or whose value its type cannot hold.');
  static const duplicateVariable = DiagnosticCode('duplicate_variable', Severity.error,
      'Two variables of the same name in one scope.');
  static const unknownScope = DiagnosticCode('unknown_scope', Severity.error,
      'Variables or conditions keyed by an id that is not a canvas of the document (nor page_variables).');
  static const invalidCondition = DiagnosticCode('invalid_condition', Severity.error,
      'A condition, branch, predicate or set entry of the wrong shape.');
  static const unknownBreakpoint = DiagnosticCode('unknown_breakpoint', Severity.error,
      'A canvas or variant names a breakpoint id the project does not define.');
  static const duplicateBreakpointCanvas = DiagnosticCode('duplicate_breakpoint_canvas', Severity.error,
      'Two canvases of one screen are the design for the same breakpoint.');
  static const screenWithoutBreakpoint = DiagnosticCode('screen_without_breakpoint', Severity.warning,
      'A canvas grouped into a screen (props.screen) that names no breakpoint: it shows only below the narrowest.');
  static const duplicateId = DiagnosticCode('duplicate_id', Severity.warning,
      'The same node id in two documents of one project: each document keeps its own, but reports and the render command\'s steps name nodes by id.');

  /// Every code, in the order above.
  static const List<DiagnosticCode> all = [
    invalidDocument, schemaVersion, unknownDocumentKey, danglingRoot, rootNotCanvas, noRoots, //
    invalidNode, unknownNodeType, unknownNodeKey, unknownProp, unknownLayoutKey, unknownDecorationKey, unknownField,
    wrongType, looseValue, invalidEnum, outOfRange, decorationIgnored,
    danglingChild, danglingSlot, multipleParents, cycle, unreachableNode, unknownSlot, childrenNotAllowed, slotsNotAllowed,
    canvasAsChild, layoutFieldIgnored, fitNotAllowed, zeroSize,
    unknownBindPath, reservedBindPath, expressionSyntax, unknownName,
    unknownTrigger, unknownTriggerKey, unknownActionType, unknownActionKey, unknownTargetNode, unknownScreen,
    unknownVariable, invalidReaction,
    invalidVariable, duplicateVariable, unknownScope, invalidCondition, unknownBreakpoint, duplicateBreakpointCanvas,
    screenWithoutBreakpoint, duplicateId,
  ];
}

/// One problem found in a document.
@immutable
final class Diagnostic {
  const Diagnostic(this.code, this.path, this.message, {this.nodeId, this.suggestion, this.file});

  final DiagnosticCode code;

  /// A JSON pointer into the document (`/nodes/title/props/style/fontSize`).
  final String path;
  final String message;

  /// The node it concerns, when there is one.
  final String? nodeId;

  /// A replacement the declarations suggest ("did you mean").
  final String? suggestion;

  /// The document it was found in, when several were checked.
  final String? file;

  Severity get severity => code.severity;
  bool get isError => severity == Severity.error;

  Diagnostic withFile(String file) => Diagnostic(code, path, message, nodeId: nodeId, suggestion: suggestion, file: file);

  Json toJson() => {
        'code': code.name,
        'severity': severity.name,
        'path': path,
        'message': message,
        'nodeId': ?nodeId,
        'suggestion': ?suggestion,
        'file': ?file,
      };

  @override
  String toString() =>
      '${severity.name} ${code.name}${file == null ? '' : ' $file'} $path: $message${suggestion == null ? '' : ' (did you mean "$suggestion"?)'}';
}

/// [path] extended by [key], escaped as a JSON pointer token.
String pointer(String path, Object key) => '$path/${'$key'.replaceAll('~', '~0').replaceAll('/', '~1')}';

/// The candidate nearest to [word] (case-insensitive edit distance), or
/// null when none is close.
String? nearest(String word, Iterable<String> candidates) {
  String? best;
  var bestScore = 1 << 30;
  final w = word.toLowerCase();
  for (final c in candidates) {
    final l = c.toLowerCase();
    if (l == w) return c;
    var d = _distance(w, l);
    // A prefix or containment is close whatever its length.
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
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost].reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return prev[b.length];
}
