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

  void walk(String id, int d, Set<String> seen) {
    final n = readMap(nodes[id]);
    if (n == null || !seen.add(id) || !printable.hasMatch(id)) {
      whole = true;
      return;
    }
    ids.add(id);
    depth[id] = d;
    sugar[id] = _line(id, n);
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
  return NotationOptions(screen: screen, width: width is num ? width.toDouble() : 390);
}

const _words = {
  'text': 'Text',
  'column': 'Column',
  'row': 'Row',
  'textField': 'Input',
  'switch': 'Toggle',
  'dropdown': 'Select',
  'filledButton': 'Button',
  'outlinedButton': 'Button.outline',
  'textButton': 'Button.ghost',
  'slider': 'Slider',
  'checkbox': 'Checkbox',
  'icon': 'Icon',
  'divider': 'Divider',
};

String _line(String id, Json n) {
  final type = '${n['type']}';
  final props = readMap(n['props']) ?? const {};
  final layout = readMap(n['layout']) ?? const {};
  final decoration = readMap(n['decoration']) ?? const {};
  var word = _words[type] ?? type;
  // A text in one of the named looks is that variant.
  if (type == 'text' && props['style'] is Map) {
    for (final v in defaultTextVariants.entries) {
      if (v.key != 'body' && jsonEncode(v.value) == jsonEncode(props['style'])) word = 'Text.${v.key}';
    }
  }
  final b = StringBuffer(word)..write('#$id');
  // The main string, when it reads back as written: plain text with no
  // braces, quotes or dollars to mistake.
  final main = switch (type) {
    'text' => props['text'],
    'filledButton' || 'outlinedButton' || 'textButton' || 'checkbox' || 'switch' => props['label'],
    'icon' => props['icon'],
    'textField' => readMap(props['decoration'])?['labelText'],
    _ => null,
  };
  if (main is String && main.isNotEmpty && !RegExp(r'[{}$\\"]').hasMatch(main) && !main.contains('\n')) b.write(' ${jsonEncode(main)}');
  if ((type == 'row' || type == 'column') && props['spacing'] is num) b.write(' gap:${props['spacing']}');
  if (type == 'row' || type == 'column') {
    const main = {'center': 'center', 'end': 'end', 'spaceBetween': 'between'};
    if (main[props['mainAxisAlignment']] case final String w) b.write(' $w');
  }
  if (layout['padding'] is num) b.write(' pad:${layout['padding']}');
  final fills = decoration['fills'];
  if (fills is List && fills.length == 1 && fills.single is Map && (fills.single as Map).length == 1 && (fills.single as Map)['color'] is String) {
    b.write(' fill:${(fills.single as Map)['color']}');
  }
  if (decoration['radius'] is num) b.write(' radius:${decoration['radius']}');
  if (layout['width'] is num) b.write(' w:${layout['width']}');
  if (layout['height'] is num) b.write(' h:${layout['height']}');
  return b.toString();
}

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      // 390 and 390.0 are one number in JSON.
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };
