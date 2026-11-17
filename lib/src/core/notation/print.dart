// Prints a document in the compact notation (design 13, principle 6): what
// an agent reads is in the form it writes, and parsing the print gives the
// same document.
//
// Each node is one line in the words the notation has for it (its type, id,
// main string, gap and fixed size); whatever those words do not say exactly
// is added as the line's `{…}` tail, worked out by parsing the print and
// comparing: the round trip is exact by construction, not by a second table
// kept in step with the parser. What is not a node of the tree (the canvas's
// own size and fill, variables' declared types) goes on a last
// `document {…}` line.
import 'dart:convert';

import '../behaviors.dart' show diffPatch;
import '../catalog.dart';
import '../json.dart';
import 'notation.dart';
import 'print_fields.dart';

/// [document] in the notation. Parse it back with [notationOptionsFor].
String printNotation(Json document, {required Catalog catalog}) {
  final nodes = readMap(document['nodes']) ?? const {};
  final roots = readStrings(document['roots']);
  final screen = roots.isEmpty ? 'screen' : roots.first;
  final options = notationOptionsFor(document);
  final canvas = readMap(nodes[screen]);
  final rootId = readString(readMap(canvas?['slots'])?['body']);
  final state = <String>[
    for (final v in readList(readMap(document['variables'])?[screen]) ?? const [])
      if (v is Map && v['name'] is String) 'state ${v['name']}=${jsonEncode(v['value'])}',
  ];
  final ids = <String>[], sugar = <String, String>{}, depth = <String, int>{};
  final printable = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
  var whole = rootId == null;
  final context = PrintContext(document: document, catalog: catalog, options: options);

  void walk(String id, int d, Set<String> seen) {
    final n = readMap(nodes[id]);
    if (n == null || !seen.add(id) || !printable.hasMatch(id)) {
      whole = true;
      return;
    }
    ids.add(id);
    depth[id] = d;
    sugar[id] = printNodeLine(id, n, context);
    for (final c in readStrings(n['children'])) {
      walk(c, d + 1, seen);
    }
    for (final c in (readMap(n['slots']) ?? const {}).values) {
      if (c is String) walk(c, d + 1, seen);
    }
  }

  if (rootId != null) walk(rootId, 0, {screen});
  String text(Map<String, String> tails, String? last) => [
        ...state,
        for (final id in ids) '${'  ' * depth[id]!}${sugar[id]}${tails[id] ?? ''}',
        ?last,
      ].join('\n');

  if (!whole) {
    // What the words did not say, per node.
    final first = parseNotation(text(const {}, null), catalog: catalog, options: options).document;
    final parsed = readMap(first['nodes']) ?? const {};
    final tails = <String, String>{};
    for (final id in ids) {
      final got = readMap(parsed[id]);
      if (got == null) {
        whole = true;
        break;
      }
      final patch = diffPatch(got, readMap(nodes[id])!);
      if (patch != null) tails[id] = ' ${jsonEncode(patch)}';
    }
    if (!whole) {
      final second = parseNotation(text(tails, null), catalog: catalog, options: options).document;
      final rest = diffPatch(second, document);
      final out = text(tails, rest == null ? null : 'document ${jsonEncode(rest)}');
      if (jsonEncode(_sorted(parseNotation(out, catalog: catalog, options: options).document)) == jsonEncode(_sorted(document))) return out;
    }
  }
  // A document the tree's words cannot carry (a node id with other
  // characters, a node outside the body): the whole of it as data.
  final empty = parseNotation('', catalog: catalog, options: options).document;
  return 'document ${jsonEncode(diffPatch(empty, document) ?? const {})}';
}

/// The options [printNotation]'s output is parsed with: the document's
/// canvas id and width.
NotationOptions notationOptionsFor(Json document) {
  final roots = readStrings(document['roots']);
  final screen = roots.isEmpty ? 'screen' : roots.first;
  final width = readMap(readMap(readMap(document['nodes'])?[screen])?['layout'])?['width'];
  return NotationOptions(screen: screen, width: width is num ? width.toDouble() : 390, reflow: false);
}

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      // 390 and 390.0 are one number in JSON.
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };
