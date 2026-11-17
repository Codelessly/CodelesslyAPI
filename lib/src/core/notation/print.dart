// Prints a document in the compact notation (design 13, principle 6): what
// an agent reads is in the form it writes, and parsing the print gives the
// same document.
//
// This file is the walk (design 22, section 4: the document family): the
// state lines, the tree with its `each` and `if`/`else` lines, a component's
// head, the screen's own events (`every`, `key`), and which ids are written.
// Each node is one line ([printNodeLine]); whatever the words do not say
// exactly is added as the line's `{…}` tail, worked out by parsing the print
// and comparing: the round trip is exact by construction, not by a second
// table kept in step with the parser. What is not a node of the tree (the
// canvas's own size and fill, what no word says of the variables) goes on a
// last `document {…}` line.
import 'dart:convert';

import '../behaviors.dart' show diffPatch, mergePatch;
import '../catalog.dart';
import '../json.dart';
import 'declared.dart';
import 'notation.dart';
import 'print_events.dart' show printCanvasEvents;
import 'print_fields.dart';

/// [document] in the notation. Parse it back with [notationOptionsFor].
///
/// [whole], when given, is told why a document had to be printed whole as
/// data (a single `document {…}` line): the measure's breakdown.
String printNotation(Json document, {required Catalog catalog, void Function(String why)? whole}) {
  final options = notationOptionsFor(document);
  final context = PrintContext(document: document, catalog: catalog, options: options);
  String? why;
  for (final plan in _Plan.values) {
    final printer = _Printer(document, context, plan);
    final out = printer.run();
    if (out != null) return out;
    why = printer.why;
  }
  whole?.call(why ?? 'the print does not read back');
  // A document the tree's words cannot carry: the whole of it as data.
  final empty = parseNotation('', catalog: catalog, options: options).document;
  return 'document ${jsonEncode(diffPatch(empty, document) ?? const {})}';
}

/// The options [printNotation]'s output is parsed with: the document's
/// canvas id and width, and no reflow: a document printed is as it is, its
/// media rules written on its lines. A component's document has no canvas: its screen is
/// a name none of its nodes has.
NotationOptions notationOptionsFor(Json document) {
  final roots = readStrings(document['roots']);
  final nodes = readMap(document['nodes']) ?? const {};
  final first = roots.isEmpty ? 'screen' : roots.first;
  final canvas = readMap(nodes[first]);
  if (canvas != null && canvas['type'] != 'canvas') {
    var screen = 'screen';
    for (var i = 2; nodes.containsKey(screen); i++) {
      screen = 'screen$i';
    }
    return NotationOptions(screen: screen, reflow: false);
  }
  final width = readMap(canvas?['layout'])?['width'];
  return NotationOptions(screen: first, width: width is num ? width.toDouble() : 390, reflow: false);
}

/// How much the walk says in words, tried in order until the print reads
/// back: everything ([full]); with every id written ([ids]); with no `each`
/// or `if` lines either, every node a line of its own ([plain]).
enum _Plan { full, ids, plain }

/// One line of the print: a node's ([id]) or a line of the walk's own
/// (`state`, `each`, `if`, a component's head).
final class _Line {
  _Line(this.indent, this.text, [this.id]);
  final int indent;
  final String text;
  final String? id;
}

final class _Printer {
  _Printer(this.document, this.context, this.plan);

  final Json document;
  final PrintContext context;
  final _Plan plan;

  /// Why this plan could not print the document.
  String? why;

  Json get nodes => context.nodes;
  Catalog get catalog => context.catalog;
  NotationOptions get options => context.options;

  final _lines = <_Line>[];
  final _seen = <String>{};

  /// The ids the parser gives so far, by type (`text` → 3): a node whose id
  /// is the next one is written without it.
  final _counts = <String, int>{};

  /// The lists printed as `each` and the item each wraps its lines in:
  /// nodes with no line of their own, that must read back as they are.
  final _structure = <String>{};

  /// The lists not to print as `each` (they did not read back as one).
  final _noEach = <String>{};

  // An id the parser reads after `#`: a name, its parts joined by `-` (`m-logo`).
  static final _idForm = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(-[A-Za-z0-9_]+)*$');
  static final _printable = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  String? run() {
    for (var attempt = 0; attempt < 8; attempt++) {
      final before = _noEach.length;
      final out = _once();
      if (out != null || _noEach.length == before) return out;
    }
    return null;
  }

  String? _once() {
    _lines.clear();
    _seen.clear();
    _counts.clear();
    _structure.clear();
    why = null;
    final roots = readStrings(document['roots']);
    final screen = roots.isEmpty ? 'screen' : roots.first;
    final first = readMap(nodes[screen]);
    final String root;
    String scope = screen;
    if (first == null) {
      why = 'no root node';
      return null;
    }
    if (first['type'] != 'canvas') {
      // A component: its head, then its tree, the root its first line.
      // With no declaration, a tree with no canvas: `canvas none`.
      _lines.addAll(readMap(document['widget']) == null ? [_Line(0, 'canvas none')] : _componentHead());
      root = screen;
    } else {
      final body = readString(readMap(first['slots'])?['body']);
      if (body == null) {
        why = 'a canvas with no body';
        return null;
      }
      root = body;
      final vars = readMap(document['variables']);
      if (vars != null && vars[screen] == null && vars['page_variables'] != null) scope = 'page_variables';
    }
    _lines.addAll(_stateLines(scope));
    _canvasAt = _lines.length;
    _screen = first['type'] == 'canvas' ? screen : null;
    if (!_walk(root, 0)) return null;
    for (final l in printCanvasEvents(document, context)) {
      _lines.add(_Line(0, l));
    }
    return _readBack();
  }

  // --- the canvas --------------------------------------------------------

  /// The screen's canvas, and where its `canvas` line goes (after the
  /// state lines).
  String? _screen;
  int _canvasAt = 0;

  /// `canvas "Trip" path="/trip" h=844 fill=paper`: what [patch] (the
  /// canvas as the document has it, over what the parser gives) says, its
  /// name in quotes, `w`, `h` and `fill` for its size and plain fill, any
  /// other field by its path from the canvas. Its events are the events
  /// family's ([printCanvasEvents]); a key that is no plain path is left to
  /// the document line.
  static String? _canvasLine(Json? patch) {
    if (patch == null) return null;
    final words = <String>[];
    final name = patch['name'];
    if (name is String) words.add(jsonEncode(name));
    void add(String path, Object? value) {
      final key = switch (path) { 'layout.width' => 'w', 'layout.height' => 'h', _ => path };
      if (path == 'decoration.fills' && value is List && value.length == 1 && value.single is Map && (value.single as Map).length == 1 && (value.single as Map)['color'] is String) {
        words.add('fill=${(value.single as Map)['color']}');
        return;
      }
      words.add('$key=${jsonEncode(value)}');
    }

    void walk(Json m, String at) {
      for (final e in m.entries) {
        final path = at.isEmpty ? e.key : '$at.${e.key}';
        if (!_printable.hasMatch(e.key) || (at.isEmpty && (e.key == 'name' && name is String || e.key == 'actions' || e.key == 'type' || e.key == 'slots'))) continue;
        final v = e.value;
        if (v is Map && v.isNotEmpty) {
          walk(v.cast<String, Object?>(), path);
        } else {
          add(path, v);
        }
      }
    }

    walk(patch, '');
    return words.isEmpty ? null : 'canvas ${words.join(' ')}';
  }

  // --- state -------------------------------------------------------------

  /// `state name=value` for each variable of the screen, its type written
  /// where the value does not say it (`state count:decimal=2`), a formula
  /// variable as `state total:decimal={price*qty}`, a function as
  /// `state clamp(v):decimal={min(1, max(0, v))}`, one kept on the device
  /// with `saved`.
  List<_Line> _stateLines(String scope) => [
        for (final v in readList(readMap(document['variables'])?[scope]) ?? const [])
          if (readMap(v) case final Json v when v['name'] is String && _printable.hasMatch(v['name'] as String)) _Line(0, _stateLine(v)),
      ];

  String _stateLine(Json v) {
    final b = StringBuffer('state ${v['name']}');
    final type = readString(v['type']);
    final formula = readString(v['formula']);
    if (formula != null && formula.trim().isNotEmpty && type != null) {
      final params = readStrings(v['parameters']);
      if (params.isNotEmpty) b.write('(${params.join(', ')})');
      b.write(':$type={$formula}');
    } else {
      final value = v['value'];
      final has = v.containsKey('value') && value != null;
      final inferred = notationVariableTypeOf(value);
      if (type != null && (type != inferred || !has)) b.write(':$type');
      if (has) b.write('=${jsonEncode(value)}');
      if (!has && type == null) b.write(':text');
    }
    if (v['persist'] == true) b.write(' saved');
    return b.toString();
  }

  // --- a component's head ------------------------------------------------

  /// `component Name "doc"`, and under it a line per parameter, event, slot
  /// and preview (design 22, section 4.5).
  List<_Line> _componentHead() {
    final w = readMap(document['widget'])!;
    final head = StringBuffer('component ${w['type']}');
    if (readString(w['doc']) case final String doc when doc.isNotEmpty) head.write(' ${jsonEncode(doc)}');
    if (readString(w['children']) case final String c) head.write(' children=$c');
    return [
      _Line(0, head.toString()),
      for (final p in readList(w['props']) ?? const [])
        if (readMap(p) case final Json p when p['key'] is String) _Line(1, _param(p)),
      for (final e in readList(w['events']) ?? const [])
        if (readMap(e) case final Json e when e['key'] is String) _Line(1, _event(e)),
      for (final s in readStrings(w['slots'])) _Line(1, 'slot $s'),
      for (final pv in readList(document['previews']) ?? const [])
        if (readMap(pv) case final Json pv) _Line(1, _preview(pv)),
    ];
  }

  String _param(Json p) {
    final b = StringBuffer('param ${p['key']}');
    final value = p['default'];
    final word = notationTypeWord(readMap(p['type']));
    if (word != null && word != notationTypeOf(value)) b.write(':$word');
    if (value != null) b.write('=${jsonEncode(value)}');
    if (p['required'] == true) b.write(' required');
    if (readString(p['doc']) case final String doc when doc.isNotEmpty) b.write(' doc=${jsonEncode(doc)}');
    return b.toString();
  }

  String _event(Json e) {
    final b = StringBuffer('event ${e['key']}');
    if (notationTypeWord(readMap(e['payload'])) case final String word) b.write(':$word');
    if (readString(e['doc']) case final String doc when doc.isNotEmpty) b.write(' doc=${jsonEncode(doc)}');
    return b.toString();
  }

  String _preview(Json pv) {
    final b = StringBuffer('preview ${jsonEncode(pv['name'] ?? '')}');
    final size = readList(pv['size']);
    if (size != null && size.length == 2 && size.every((s) => s is num)) b.write(' ${_number(size[0] as num)}x${_number(size[1] as num)}');
    for (final e in (readMap(pv['props']) ?? const {}).entries) {
      if (_printable.hasMatch(e.key)) b.write(' ${e.key}=${jsonEncode(e.value)}');
    }
    return b.toString();
  }

  static String _number(num n) => n is double && n == n.roundToDouble() && n.abs() < 1e15 ? '${n.toInt()}' : '$n';

  // --- the tree ----------------------------------------------------------

  /// Node [id]'s line at [depth] and the lines under it; false when the
  /// tree cannot be said (a node missing, reached twice, an id the notation
  /// cannot write).
  bool _walk(String id, int depth, {String? condition}) {
    final n = readMap(nodes[id]);
    if (n == null) {
      why = 'a node missing';
      return false;
    }
    if (!_seen.add(id)) {
      why = 'a node reached twice';
      return false;
    }
    if (!_idForm.hasMatch(id)) {
      why = 'an id the printer refuses';
      return false;
    }
    var text = printNodeLine(id, n, context);
    // Under an `if`, the line's own `visible` is the if's.
    if (condition != null) text = text.replaceFirst(' visible={$condition}', '');
    _lines.add(_Line(depth, _withoutId(text, id, '${n['type']}'), id));
    return _under(n, depth + 1);
  }

  /// [text] without `#id` when the parser gives the line that id anyway.
  String _withoutId(String text, String id, String type) {
    if (plan != _Plan.full) return text;
    final key = type == 'grid' || text.startsWith('Grid') ? 'grid' : type;
    if (id != '$key${(_counts[key] ?? 0) + 1}') return text;
    final mark = RegExp('^([A-Za-z][A-Za-z0-9.]*)#${RegExp.escape(id)}(?=\\s|\$)');
    if (!mark.hasMatch(text)) return text;
    _counts[key] = (_counts[key] ?? 0) + 1;
    return text.replaceFirstMapped(mark, (m) => m[1]!);
  }

  /// The lines under a node: its children, sibling lines that share a
  /// condition under an `if` (and `else`), a list over data as `each`; then
  /// its slots.
  bool _under(Json n, int depth) {
    final kids = readStrings(n['children']);
    for (var i = 0; i < kids.length;) {
      final cond = _condition(kids[i]);
      if (cond != null) {
        var j = i + 1;
        while (j < kids.length && _condition(kids[j]) == cond) {
          j++;
        }
        final not = '\${= !($cond)}';
        var k = j;
        while (k < kids.length && _condition(kids[k]) == '!($cond)' && readMap(readMap(nodes[kids[k]])?['bind'])?['visible'] == not) {
          k++;
        }
        if (j - i >= 2 || k > j) {
          _lines.add(_Line(depth, 'if $cond'));
          for (final c in kids.sublist(i, j)) {
            if (!_child(c, depth + 1, condition: cond)) return false;
          }
          if (k > j) {
            _lines.add(_Line(depth, 'else'));
            for (final c in kids.sublist(j, k)) {
              if (!_child(c, depth + 1, condition: '!($cond)')) return false;
            }
          }
          i = k;
          continue;
        }
      }
      if (!_child(kids[i], depth)) return false;
      i++;
    }
    for (final c in (readMap(n['slots']) ?? const {}).values) {
      if (c is String && !_walk(c, depth)) return false;
    }
    return true;
  }

  /// The expression of node [id]'s bound `visible`, when it is one an `if`
  /// line gives (`${= expr}`), and the plan says conditions.
  String? _condition(String id) {
    if (plan == _Plan.plain) return null;
    final v = readMap(readMap(nodes[id])?['bind'])?['visible'];
    if (v is! String || !v.startsWith(r'${= ') || !v.endsWith('}')) return null;
    final expr = v.substring(4, v.length - 1).trim();
    // One line of the text: an expression over several does not fit.
    return expr.isEmpty || expr.contains('\n') ? null : expr;
  }

  bool _child(String id, int depth, {String? condition}) {
    final n = readMap(nodes[id]);
    if (n != null && _each(id, n, depth, condition)) return true;
    return _walk(id, depth, condition: condition);
  }

  /// A list over data (`bind.data`) as the parser makes it from
  /// `each item in list`: a listView of one column, `<id>Item`, whose
  /// children are the lines under the `each`.
  bool _each(String id, Json n, int depth, String? condition) {
    if (plan != _Plan.full || _noEach.contains(id) || n['type'] != 'listView') return false;
    final bind = readMap(n['bind']) ?? const {};
    final data = bind['data'];
    final props = readMap(n['props']) ?? const {};
    if (data is! String || props['layout'] != null) return false;
    final item = '${id}Item';
    final kids = readStrings(n['children']);
    final itemNode = readMap(nodes[item]);
    if (kids.length != 1 || kids.single != item || itemNode?['type'] != 'column' || itemNode?['slots'] != null) return false;
    if (n['slots'] != null || _seen.contains(id) || _seen.contains(item)) return false;
    final bare = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_.]*)\}$').firstMatch(data)?[1];
    final list = bare ??(data.startsWith(r'${= ') && data.endsWith('}') && !data.contains('\n') ? data.substring(4, data.length - 1).trim() : null);
    if (list == null) return false;
    if (id != 'listView${(_counts['listView'] ?? 0) + 1}') return false;
    _counts['listView'] = (_counts['listView'] ?? 0) + 1;
    _seen
      ..add(id)
      ..add(item);
    _structure
      ..add(id)
      ..add(item);
    final words = StringBuffer();
    final reorder = readMap(props['reorder']);
    if (reorder != null) words.write(' reorder');
    if (props['stickToEnd'] == true && readMap(n['layout'])?['height'] is num) words.write(' follow h=${_number(readMap(n['layout'])!['height'] as num)}');
    // Inside it the element is `item`; an each inside an each calls the
    // outer one's `parent.item`, so an outer each names its element with a
    // word its lines do not use.
    final name = _eachName(itemNode!);
    _lines.add(_Line(depth, 'each $name in $list$words'));
    return _under(itemNode, depth + 1);
  }

  /// The name an `each` calls its element: `item`, or for an each with an
  /// each inside it, a name no line under it uses (`row`, `row2`…) so that
  /// its `parent.item` stays as written.
  String _eachName(Json item) {
    bool nested(Json n, int depth) {
      if (depth > 64) return false;
      for (final c in readStrings(n['children'])) {
        final cn = readMap(nodes[c]);
        if (cn == null) continue;
        if (cn['type'] == 'listView' && readMap(cn['bind'])?['data'] != null) return true;
        if (nested(cn, depth + 1)) return true;
      }
      return false;
    }

    if (!nested(item, 0)) return 'item';
    final text = jsonEncode(item);
    for (var i = 1;; i++) {
      final name = i == 1 ? 'row' : 'row$i';
      if (!RegExp('\\b$name\\b').hasMatch(text)) return name;
    }
  }

  // --- reading back ------------------------------------------------------

  Json _parse(String text) => parseNotation(text, catalog: catalog, options: options).document;

  String? _readBack() {
    String text(Map<String, String> tails, String? last) => [
          for (final l in _lines) '${'  ' * l.indent}${l.text}${l.id == null ? '' : tails[l.id] ?? ''}',
          ?last,
        ].join('\n');
    try {
      // What the words did not say, per node.
      final first = _parse(text(const {}, null));
      final parsed = readMap(first['nodes']) ?? const {};
      final tails = <String, String>{};
      for (final l in _lines) {
        final id = l.id;
        if (id == null) continue;
        final got = readMap(parsed[id]);
        if (got == null) {
          final type = '${readMap(nodes[id])!['type']}';
          why = catalog.widget(type) == null
              ? 'a type the catalog does not have (a component of a design system not given) — $type'
              : 'a node the print does not give back — $id: ${l.text}';
          return null;
        }
        final patch = diffPatch(got, readMap(nodes[id])!);
        if (patch != null) tails[id] = ' ${jsonEncode(patch)}';
      }
      // A list printed as `each` reads back as it is, or is printed as nodes.
      for (final id in _structure) {
        final got = readMap(parsed[id]);
        if (got == null || diffPatch(got, readMap(nodes[id])!) != null) {
          _noEach.add(id.endsWith('Item') && !nodes.containsKey('${id}Item') ? id.substring(0, id.length - 4) : id);
        }
      }
      if (_noEach.any(_structure.contains)) {
        why = 'an each that does not read back';
        return null;
      }
      // A tail can change how the lines after it read (a parent's alignment,
      // its children's sizes, the canvas's height): read again, and add to
      // the tails, and to the `canvas` line, what still differs, until
      // nothing does.
      final patches = {for (final e in tails.entries) e.key: jsonDecode(e.value.substring(1)) as Json};
      Json? canvas;
      var second = first;
      for (var round = 0; round < 5; round++) {
        final got = readMap(second['nodes']) ?? const {};
        var changed = false;
        if (round > 0) {
          for (final l in _lines) {
            final id = l.id, now = id == null ? null : readMap(got[id]);
            if (id == null || now == null) continue;
            final d = diffPatch(now, readMap(nodes[id])!);
            if (d == null) continue;
            patches[id] = mergePatch(patches[id] ?? const {}, d, keepNulls: true);
            tails[id] = ' ${jsonEncode(patches[id])}';
            changed = true;
          }
        }
        // What the screen's canvas has that the parser does not give it.
        if (_screen case final String screen) {
          final want = readMap(nodes[screen]), now = readMap(got[screen]);
          final d = want == null || now == null ? null : diffPatch(now, want);
          final next = d == null ? canvas : mergePatch(canvas ?? const {}, d, keepNulls: true);
          final before = canvas == null ? null : _canvasLine(canvas);
          final line = next == null ? null : _canvasLine(next);
          if (line != null && line != before) {
            if (before == null) {
              _lines.insert(_canvasAt, _Line(0, line));
            } else {
              _lines[_canvasAt] = _Line(0, line);
            }
            canvas = next;
            changed = true;
          }
        }
        if (!changed && round > 0) break;
        second = _parse(text(tails, null));
      }
      final rest = diffPatch(second, document);
      final out = text(tails, rest == null ? null : 'document ${jsonEncode(rest)}');
      if (jsonEncode(_sorted(_parse(out))) == jsonEncode(_sorted(document))) return out;
      why = 'the print does not read back';
      return null;
    } on Object catch (e, st) {
      why = 'the parser fails (${e.runtimeType}) — $e ${st.toString().split('\n').take(3).join(' | ')}';
      return null;
    }
  }
}

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      // 390 and 390.0 are one number in JSON.
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };
