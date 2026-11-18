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
import '../migrate/migrate.dart' show kOldestSchemaVersion;
import 'declared.dart';
import 'media_words.dart' show mediaConditionWords;
import 'notation.dart';
import 'print_events.dart' show printCanvasBlockEvents, printCanvasEvents, printComponentScreenEvents, printNormalized;
import 'print_fields.dart';
import 'print_paint.dart' show printPaintLines;

/// [document] in the notation. Parse it back with [notationOptionsFor].
///
/// [whole], when given, is told why a document had to be printed whole as
/// data (a single `document {…}` line): the measure's breakdown.
String printNotation(Json document, {required Catalog catalog, void Function(String why)? whole}) {
  document = printNormalized(document, catalog); // one spelling of what the API reads in two (print_events.dart)
  document = _componentNormalized(document);
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
  return 'document ${jsonEncode(_sorted(diffPatch(empty, document) ?? const {}))}';
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

/// A document in the parser's spelling of what the API reads two ways
/// (design 22, 4.9): a declaration's empty parameter list (`"widget":
/// {"props": []}`) is none, as `widgetSpecFromJson` reads it; a preview with
/// no `props` has empty ones, as `ComponentPreview` reads it; a document with
/// no `schema` is of the oldest (`schemaOf`), written `document schema=2`.
/// [document] itself when it has none of them.
Json _componentNormalized(Json document) {
  final widget = readMap(document['widget']);
  final previews = readList(document['previews']);
  final emptyProps = widget != null && widget['props'] is List && (widget['props']! as List).isEmpty;
  final bare = previews != null && previews.any((p) => p is Map && !p.containsKey('props'));
  final schema = !document.containsKey('schema');
  if (!emptyProps && !bare && !schema) return document;
  return {
    ...document,
    if (schema) 'schema': kOldestSchemaVersion,
    if (emptyProps) 'widget': {...widget}..remove('props'),
    if (bare) 'previews': [for (final p in previews) p is Map && !p.containsKey('props') ? {...p, 'props': <String, Object?>{}} : p],
  };
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
  String text;
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

  /// The nodes whose id is written though the parser would give it (the
  /// line read otherwise without it), and those left out this time.
  final _keepId = <String>{}, _dropped = <String>{};

  /// The nodes whose slots are written as `slot name` lines (their lines
  /// under them read back into other slots, or into their children).
  final _slotLines = <String>{};

  // An id the parser reads after `#` (design 13, section 3): letters, digits
  // and `_`, its parts joined by hyphens (`m-logo`).
  static final _idForm = RegExp('^$notationId\$');
  static final _printable = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  String? run() {
    for (var attempt = 0; attempt < 24; attempt++) {
      final before = _noEach.length + _keepId.length + _slotLines.length + _typedState.length + _noOverlay.length;
      final out = _once();
      if (out != null || _noEach.length + _keepId.length + _slotLines.length + _typedState.length + _noOverlay.length == before) return out;
    }
    return null;
  }

  String? _once() {
    _lines.clear();
    _seen.clear();
    _counts.clear();
    _structure.clear();
    _dropped.clear();
    _handEach.clear();
    _dialogParts.clear();
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
    }
    // Where the parser keeps the state lines: the page's canvas, or with
    // other canvases or overlays every canvas's (`page_variables`); a
    // component's on its root. The document's one scope, where it has one.
    final fallback = first['type'] == 'canvas' && roots.length > 1 ? 'page_variables' : screen;
    final vars = readMap(document['variables']);
    if (vars != null && vars.length == 1) {
      scope = vars.keys.single;
    } else if (vars != null && vars[screen] == null && vars['page_variables'] != null) {
      scope = 'page_variables';
    }
    final head = _documentWords(scope: scope != fallback && vars?[scope] != null ? scope : null);
    if (head != null) _lines.add(_Line(0, head));
    _lines.addAll(_stateLines(scope));
    _canvases.clear();
    // The overlays printed as a `Dialog#id` head, known before the page is
    // printed: an `open` of one reads as the dialog's (print_events.dart).
    context.overlayHeads
      ..clear()
      ..addAll({
        for (final other in roots.skip(1))
          if (_dialogOf(other) != null) other: 'Dialog#$other',
      });
    // What the screen does that is neither a timer nor a shortcut (`onLoad`,
    // `onBackPressed`): words of its canvas line, before its `every` and
    // `key` lines.
    // One printed form (design 22, 4.3): the screen's reactions
    // are `on` lines after the tree; `canvas onLoad={…}` still reads.
    const said = 0;
    if (first['type'] == 'canvas') {
      _canvasEvents = '';
      final line = _Line(0, _canvasEvents.isEmpty ? '' : 'canvas$_canvasEvents');
      _canvases[screen] = (line: line, head: 'canvas');
      _lines.add(line);
    }
    if (!_walk(root, 0)) return null;
    for (final l in printCanvasEvents(document, context, from: said)) {
      _lines.add(_Line(0, l));
    }
    // A component's key, every and on lines: after its tree, as written.
    if (first['type'] != 'canvas') {
      for (final l in printComponentScreenEvents(document, context)) {
        _lines.add(_Line(0, l));
      }
    }
    // Every other canvas: a `Canvas#id` block, its tree under it.
    for (final other in roots.skip(1)) {
      final n = readMap(nodes[other]);
      final body = readString(readMap(n?['slots'])?['body']);
      if (n?['type'] != 'canvas' || body == null || !_idForm.hasMatch(other) || _seen.contains(body)) continue;
      if (context.overlayHeads.containsKey(other)) {
        if (!_dialog(other)) return null;
        continue;
      }
      final line = _Line(0, 'Canvas#$other');
      _canvases[other] = (line: line, head: 'Canvas#$other');
      _lines.add(line);
      if (!_walk(body, 1)) return null;
      // Its own reactions (`on backPressed={…}`): lines under it.
      for (final l in printCanvasBlockEvents(context, other) ?? const <String>[]) {
        _lines.add(_Line(1, l));
      }
    }
    return _readBack();
  }

  // --- overlays ----------------------------------------------------------

  /// The overlays not to print as a `Dialog` head (they did not read back as
  /// one), and for each printed so the nodes it makes with no line of their
  /// own (the canvas, its column, the title's row, text and close button, the
  /// actions' row), which must read back as they are.
  final _noOverlay = <String>{};
  final _dialogParts = <String, List<String>>{};

  /// Canvas [id] as `Dialog#id "Title"` makes it (page_words.dart): a canvas
  /// whose body is a column, its first child the title's row (a text and a
  /// close button) where it has a title, its last the row of its buttons
  /// (`<column>Actions`) where it has them. Null: not one, or it did not
  /// read back as one.
  ({String body, String? row, String? text, String? close, String? title, String? actions})? _dialogOf(String id) {
    if (plan != _Plan.full || _noOverlay.contains(id) || !_idForm.hasMatch(id)) return null;
    final n = readMap(nodes[id]);
    if (n == null || n['type'] != 'canvas') return null;
    final body = readString(readMap(n['slots'])?['body']);
    final b = body == null ? null : readMap(nodes[body]);
    if (body == null || b == null || b['type'] != 'column' || b['slots'] != null) return null;
    final kids = readStrings(b['children']);
    String? row, text, close, title, actions;
    if (kids.isNotEmpty) {
      final r = readMap(nodes[kids.first]);
      final rk = readStrings(r?['children']);
      if (r?['type'] == 'row' && r?['slots'] == null && rk.length == 2 && readMap(nodes[rk[0]])?['type'] == 'text' && readMap(nodes[rk[1]])?['type'] == 'iconButton') {
        final t = readMap(readMap(nodes[rk[0]])!['props'])?['text'];
        if (t is String && !t.contains('{') && !t.contains('}')) {
          row = kids.first;
          text = rk[0];
          close = rk[1];
          title = t;
        }
      }
    }
    final last = kids.isEmpty ? null : readMap(nodes[kids.last]);
    if (kids.length > (row == null ? 0 : 1) && kids.last == '${body}Actions' && last?['type'] == 'row' && last?['slots'] == null) actions = kids.last;
    return (body: body, row: row, text: text, close: close, title: title, actions: actions);
  }

  /// `Dialog#id "Title"` and its lines under it: the column's lines after
  /// the title's row, then its buttons. False when the walk cannot go on
  /// (a part of it has an id the parser would not give it: printed as a
  /// `Canvas#id` block instead).
  bool _dialog(String id) {
    final d = _dialogOf(id)!;
    // The parts the head makes, in the order the parser makes them, take the
    // ids it gives.
    for (final (part, type) in [(d.body, 'column'), if (d.row != null) (d.row!, 'row'), if (d.text != null) (d.text!, 'text'), if (d.close != null) (d.close!, 'iconButton')]) {
      if (part != '$type${(_counts[type] ?? 0) + 1}' || _seen.contains(part)) {
        _noOverlay.add(id);
        why = 'a dialog whose parts have ids of their own';
        return false;
      }
      _counts[type] = (_counts[type] ?? 0) + 1;
    }
    final n = readMap(nodes[id])!, b = readMap(nodes[d.body])!;
    // The column's words, less what the head gives (`pad=24 gap=16`).
    final words = printNodeLine(d.body, b, context).replaceFirst(RegExp('^Column(#$notationId)?'), '').split(' ').where((w) => w.isNotEmpty && w != 'pad=24' && w != 'gap=16').join(' ');
    final w = readMap(n['layout'])?['width'];
    _lines.add(_Line(0, ['Dialog#$id', if (d.title != null) jsonEncode(d.title), if (w is num && w != 480) 'w=${_number(w)}', if (words.isNotEmpty) words].join(' ')));
    final parts = [id, d.body, ?d.row, ?d.text, ?d.close, ?d.actions];
    _seen.addAll(parts);
    _dialogParts[id] = parts;
    final kids = [
      for (final k in readStrings(b['children']))
        if (k != d.row && k != d.actions) k,
      if (d.actions != null) ...readStrings(readMap(nodes[d.actions])!['children']),
    ];
    return _under({'children': kids}, 1);
  }

  // --- the canvas --------------------------------------------------------

  /// Each canvas printed, by id: its line (`canvas …` above the page's
  /// tree, empty while it says nothing; `Canvas#id …` heading another's).
  final _canvases = <String, ({_Line line, String head})>{};

  /// The page canvas's reactions said on its line (` onLoad={…}`).
  String _canvasEvents = '';

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
      words.add('$key=${value is num ? _number(value) : jsonEncode(value)}');
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

    // A prop of the canvas worked out (`blockBack={dirty}`): in braces.
    final rest = {...patch};
    if (readMap(patch['bind']) case final Json bind) {
      final left = <String, Object?>{};
      for (final e in bind.entries) {
        final v = e.value;
        final prop = e.key.startsWith('props.') ? e.key.substring(6) : null;
        final expr = v is! String || v.contains('\n')
            ? null
            : v.startsWith(r'${= ') && v.endsWith('}')
                ? v.substring(4, v.length - 1).trim()
                : RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_.]*)\}$').firstMatch(v)?[1];
        if (prop != null && _printable.hasMatch(prop) && expr != null && expr.isNotEmpty) {
          words.add('$prop={$expr}');
        } else {
          left[e.key] = v;
        }
      }
      if (left.isEmpty) {
        rest.remove('bind');
      } else {
        rest['bind'] = left;
      }
    }
    walk(rest, '');
    // Its name, path, size and fill first, the rest as the canvas has them.
    int rank(String w) => switch (w.split('=').first) { 'path' => 1, 'w' => 2, 'h' => 3, 'fill' => 4, _ when w.startsWith('"') => 0, _ => 5 };
    final order = [for (var i = 0; i < words.length; i++) i]..sort((a, b) => rank(words[a]) != rank(words[b]) ? rank(words[a]) - rank(words[b]) : a - b);
    return words.isEmpty ? null : [for (final i in order) words[i]].join(' ');
  }

  // --- the document's own fields ------------------------------------------

  /// `document id="checkout" schema=2 scope=page_variables`: the document's
  /// id where the parser gives another (a page has none, a component's is
  /// its name), a schema other than 3, the scope of its state lines where
  /// the parser would keep them elsewhere ([scope]), and its `conditions`
  /// as their JSON (`conditions={"plans":[…]}`).
  String? _documentWords({String? scope}) {
    final words = <String>[];
    final id = document['id'];
    final given = readMap(document['widget'])?['type'];
    if (id is String && id != given) words.add('id=${jsonEncode(id)}');
    final schema = document['schema'];
    if (schema is int && schema != 3) words.add('schema=$schema');
    if (scope != null && RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(scope)) words.add('scope=$scope');
    final conditions = document['conditions'];
    if (conditions is Map || conditions is List) words.add('conditions=${jsonEncode(_sorted(conditions))}');
    return words.isEmpty ? null : 'document ${words.join(' ')}';
  }

  // --- state -------------------------------------------------------------

  /// `state name=value` for each variable of the screen, its type written
  /// where the value does not say it (`state count:decimal=2`), a formula
  /// variable as `state total:decimal={price*qty}`, a function as
  /// `state clamp01(v):decimal={min(1, max(0, v))}`, one kept on the device
  /// with `saved`. A variable named as the runtime names a scope (`storage`,
  /// `theme`: notationRefusedState) has no state line (34: one is an issue):
  /// it stays on the `document {…}` line.
  List<_Line> _stateLines(String scope) => [
        for (final v in readList(readMap(document['variables'])?[scope]) ?? const [])
          if (readMap(v) case final Json v when v['name'] is String && _printable.hasMatch(v['name'] as String) && !notationRefusedState(v['name'] as String))
            _Line(0, _stateLine(v)),
      ];

  /// The state whose type its value says but the print read back gives
  /// another (a whole number a Pages or a number control widens to a
  /// decimal): written with its type, which is then kept.
  final _typedState = <String>{};

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
      if (type != null && (type != inferred || !has || _typedState.contains(v['name']))) b.write(':$type');
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
    // A page view not printed as `Pages` is printed as written.
    if (n['type'] == 'pageView' && _pagesOf(id, n) == null) context.printPagesAsWritten(id);
    var text = printNodeLine(id, n, context);
    // The grid a `Grid` line of cells written one by one makes, with its
    // columns at other widths: the Grid line and its cells.
    if (_literalGridOf(n) case final lit? when condition == null) {
      _lines.add(_Line(depth, _withoutId(_gridLine(text, lit.grid), id, '${n['type']}'), id));
      _seen
        ..add(lit.list)
        ..add(lit.item);
      _structure
        ..add(lit.list)
        ..add(lit.item);
      for (var k = 0; k < lit.cells.length; k++) {
        if (!_walk(lit.cells[k], depth + 1, condition: lit.hidden.contains(k) ? null : 'item == $k')) return false;
      }
      return true;
    }
    // The column a `Grid` line makes around the grid of its `each`: the Grid.
    if (_gridOfEach(n) case final grid?) text = _gridLine(text, grid);
    // Under an `if`, the line's own `visible` is the if's.
    // (`visible="${= ready}"` is the binding as written, design 22, 4.8.)
    if (condition != null) text = text.replaceFirst(' visible={$condition}', '').replaceFirst(' visible=${jsonEncode('\${= $condition}')}', '');
    // A list written with an `each` under it: the each says its data.
    if (_handList(id, n) != null) text = _withoutData(text);
    // A page view as `Pages` makes it: its one page, `<id>Page`, is no
    // line; the page's lines are under `Pages`, each shown at its position
    // (or under an `each` for one page per element).
    final page = _pagesOf(id, n);
    if (page != null) {
      text = text.replaceFirst(RegExp(r'^(pageView|PageView)(?=[#\s]|$)'), 'Pages');
      if (page.list != null) text = _withoutData(text);
      // `Pages` turns its pages across, which the catalog's word does not
      // say: a page view that has no direction of its own says so.
      if (!(readMap(n['props'])?.containsKey('scrollDirection') ?? false) && !text.contains(' scrollDirection=')) {
        text = _withWord(text, n['props'] == null ? 'props=null' : 'scrollDirection=null');
      }
      // (Its count is the lines under it.)
      final count = readStrings(readMap(nodes[page.id])?['children']).length;
      if (page.list == null) text = text.replaceFirst(' itemCount=$count', '');
    }
    _lines.add(_Line(depth, _withoutId(text, id, '${n['type']}'), id));
    // Its ordered records (paint ops, animations, transitions): lines of
    // their own under it, before its children.
    for (final record in printPaintLines(id, n, context, depth).split('\n')) {
      if (record.trim().isNotEmpty) _lines.add(_Line(0, record));
    }
    if (page != null) {
      _seen.add(page.id);
      _structure.add(page.id);
      final pn = readMap(nodes[page.id])!;
      final kids = readStrings(pn['children']);
      if (page.list case final String list) {
        _lines.add(_Line(depth + 1, 'each ${_eachName(pn)} in $list'));
        for (final c in kids) {
          if (!_child(c, depth + 2)) return false;
        }
        return true;
      }
      for (var i = 0; i < kids.length; i++) {
        if (!_walk(kids[i], depth + 1, condition: 'index == $i')) return false;
      }
      return true;
    }
    // A list of its own line repeating its one child over data: the child
    // under `each item in list` (design 22, 4.5).
    if (_handList(id, n) case final ({String list, String template}) each) {
      _handEach.add(id);
      _lines.add(_Line(depth + 1, 'each ${_eachName(n)} in ${each.list}${_staggerWord(each.template)}'));
      return _child(each.template, depth + 2);
    }
    return _under(n, depth + 1, id);
  }

  /// The grid of an `each` that node [n] is the `Grid` line of, as the parser
  /// makes it from `Grid cols=3` with an `each` under it: a column whose one
  /// child is a gridView over data whose one child is its `<id>Item`. Null:
  /// not one (or it did not read back, [_noEach], and prints as nodes).
  Json? _gridOfEach(Json n) {
    if (plan != _Plan.full || n['type'] != 'column') return null;
    final kids = readStrings(n['children']);
    if (kids.length != 1 || _noEach.contains(kids.single)) return null;
    final g = readMap(nodes[kids.single]);
    if (g == null || g['type'] != 'gridView' || readMap(g['bind'])?['data'] is! String) return null;
    final gk = readStrings(g['children']);
    return gk.length == 1 && gk.single == '${kids.single}Item' ? g : null;
  }

  /// The grid the parser makes of a `Grid` line over cells written one by one
  /// with columns at other widths (`Grid cols=4 phone.cols=2`): a column
  /// whose one child is `<id>Cells`, a gridView over `range(n)` whose one
  /// copy holds the n cells, cell k shown in copy k (`visible={item == k}`,
  /// or hidden as written). Null: not one, or it did not read back.
  ({Json grid, String list, String item, List<String> cells, Set<int> hidden})? _literalGridOf(Json n) {
    if (plan != _Plan.full || n['type'] != 'column') return null;
    final kids = readStrings(n['children']);
    if (kids.length != 1 || !kids.single.endsWith('Cells') || _noEach.contains(kids.single) || _seen.contains(kids.single)) return null;
    final g = readMap(nodes[kids.single]);
    final bind = readMap(g?['bind']);
    final count = RegExp(r'^\$\{= range\((\d+)\)\}$').firstMatch('${bind?['data']}');
    if (g == null || g['type'] != 'gridView' || bind!.length != 1 || count == null || readList(g['media'])?.isNotEmpty != true) return null;
    final item = '${kids.single}Item';
    final itemNode = readMap(nodes[item]);
    if (!jsonEquality.equals(g['children'], [item]) || itemNode == null || itemNode['type'] != 'column') return null;
    final cells = readStrings(itemNode['children']);
    if (cells.length != int.parse(count[1]!)) return null;
    final hidden = <int>{};
    for (var k = 0; k < cells.length; k++) {
      final c = readMap(nodes[cells[k]]);
      final shown = readMap(c?['bind'])?['visible'];
      if (shown == '\${= item == $k}') continue;
      if (shown == null && c?['visible'] == false) {
        hidden.add(k);
        continue;
      }
      return null;
    }
    return (grid: g, list: kids.single, item: item, cells: cells, hidden: hidden);
  }

  /// The column's line [text] as the `Grid` line that makes it and [grid]:
  /// `cols=` the grid's columns, `gap=` its spacing (8 unless written), and
  /// `tablet.cols=2` for each of the grid's rules that changes its columns
  /// alone (another rule leaves the grid printed as nodes).
  String _gridLine(String text, Json grid) {
    final head = RegExp(r'^Column(?=[#\s]|$)');
    if (!head.hasMatch(text)) return text;
    final props = readMap(grid['props']) ?? const {};
    final gap = props['mainAxisSpacing'];
    final words = [
      if (props['crossAxisCount'] is num) 'cols=${_number(props['crossAxisCount'] as num)}',
      if (gap is num && gap != 8) 'gap=${_number(gap)}',
      for (final r in readList(grid['media']) ?? const [])
        if (readMap(r) case final Json rule)
          if ((mediaConditionWords(rule), readMap(readMap(rule['patch'])?['props'])) case (final String at, final Json p)
              when readMap(rule['patch'])!.length == 1 && p.length == 1 && p['crossAxisCount'] is int)
            '$at.cols=${p['crossAxisCount']}',
    ];
    final rest = text.replaceFirst(head, '').split(' ').where((w) => !w.startsWith('gap=')).join(' ');
    final at = rest.startsWith('#') ? rest.indexOf(' ') : 0;
    final id = at < 0 ? rest : rest.substring(0, at);
    final after = at < 0 ? '' : rest.substring(at).trim();
    return ['Grid$id', ...words, if (after.isNotEmpty) after].join(' ');
  }

  /// [text] with [word] after its fields, before its marks and events.
  static String _withWord(String text, String word) {
    final at = RegExp(r' (@|on[A-Z][A-Za-z]*[=(])').firstMatch(text)?.start;
    return at == null ? '$text $word' : '${text.substring(0, at)} $word${text.substring(at)}';
  }

  /// [text] without its ` data={…}`: an `each` under the line says it.
  static String _withoutData(String text) {
    final at = text.indexOf(' data={');
    if (at < 0) return text;
    var depthOf = 0, end = at + 6;
    for (; end < text.length; end++) {
      if (text[end] == '{') depthOf++;
      if (text[end] == '}' && --depthOf == 0) break;
    }
    return end < text.length ? text.substring(0, at) + text.substring(end + 1) : text;
  }

  /// The page of page view [id] as `Pages` makes it, its one child column
  /// `<id>Page` with no slots, and the list its data is when it is bound
  /// (one page per element, `each`); null when it is not one, or did not
  /// read back as one.
  ({String id, String? list})? _pagesOf(String id, Json n) {
    if (plan != _Plan.full || n['type'] != 'pageView' || _noEach.contains(id)) return null;
    final page = '${id}Page';
    final kids = readStrings(n['children']);
    final pn = readMap(nodes[page]);
    if (kids.length != 1 || kids.single != page || pn?['type'] != 'column' || pn?['slots'] != null || n['slots'] != null) return null;
    final data = readMap(n['bind'])?['data'];
    if (data == null) return (id: page, list: null);
    final list = data is String ? _eachList(data) : null;
    return list == null ? null : (id: page, list: list);
  }

  /// The lists printed as their own line with an `each` under it.
  final _handEach = <String>{};

  /// What `each` says of list [id] written as its own line: the list its
  /// data is, and its one child, the template; null when it is not one
  /// (not a listView or gridView, no data, other children, slots).
  ({String list, String template})? _handList(String id, Json n) {
    if (plan != _Plan.full || _noEach.contains(id) || (n['type'] != 'listView' && n['type'] != 'gridView' && n['type'] != 'pageView')) return null;
    if (n['slots'] != null || readMap(n['props'])?['layout'] != null) return null;
    final kids = readStrings(n['children']);
    final data = readMap(n['bind'])?['data'];
    if (kids.length != 1 || data is! String) return null;
    final list = _eachList(data);
    return list == null ? null : (list: list, template: kids.single);
  }

  /// The list an `each` line names for the data binding [data]: a name or
  /// a path (`${rows}`), or a formula (`${= filter(…)}`).
  static String? _eachList(String data) {
    final bare = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_.]*)\}$').firstMatch(data)?[1];
    return bare ?? (data.startsWith(r'${= ') && data.endsWith('}') && !data.contains('\n') ? data.substring(4, data.length - 1).trim() : null);
  }

  /// ` stagger=80` when node [id], the first line under an `each`, starts
  /// each copy that much after the one before (`animations[0].delay` bound
  /// to `index*80`, plus its own delay).
  String _staggerWord(String id) {
    final n = readMap(nodes[id]);
    final delay = readMap(n?['bind'])?['animations[0].delay'];
    if (delay is! String || readList(n?['animations'])?.isEmpty != false) return '';
    final m = RegExp(r'^\$\{= index\*([0-9]+)(?:\+([0-9]+))?\}$').firstMatch(delay);
    if (m == null) return '';
    final own = readMap(readList(n!['animations'])!.first)?['delay'];
    if (m[2] != null && own != int.parse(m[2]!)) return '';
    return ' stagger=${m[1]}';
  }

  /// [text] without `#id` when the parser gives the line that id anyway.
  String _withoutId(String text, String id, String type) {
    if (plan != _Plan.full || _keepId.contains(id)) return text;
    final key = type == 'grid' || text.startsWith('Grid') ? 'grid' : type;
    if (id != '$key${(_counts[key] ?? 0) + 1}') return text;
    final mark = RegExp('^([A-Za-z][A-Za-z0-9.]*)#${RegExp.escape(id)}(?=\\s|\$)');
    if (!mark.hasMatch(text)) return text;
    _counts[key] = (_counts[key] ?? 0) + 1;
    _dropped.add(id);
    return text.replaceFirstMapped(mark, (m) => m[1]!);
  }

  /// The lines under a node: its children, sibling lines that share a
  /// condition under an `if` (and `else`), a list over data as `each`; then
  /// its slots.
  bool _under(Json n, int depth, [String? id]) {
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
    final slots = readMap(n['slots']) ?? const {};
    final named = id != null && _slotLines.contains(id);
    for (final e in slots.entries) {
      final c = e.value;
      if (c is! String) continue;
      if (named && _printable.hasMatch(e.key)) {
        _lines.add(_Line(depth, 'slot ${e.key}'));
        if (!_walk(c, depth + 1)) return false;
      } else if (!_walk(c, depth)) {
        return false;
      }
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
    if (plan != _Plan.full || _noEach.contains(id) || (n['type'] != 'listView' && n['type'] != 'gridView')) return false;
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
    final list = bare ?? (data.startsWith(r'${= ') && data.endsWith('}') && !data.contains('\n') ? data.substring(4, data.length - 1).trim() : null);
    if (list == null) return false;
    // A gridView is the each of a Grid line: the line it is under says so.
    final kind = '${n['type']}';
    if (kind == 'gridView' && !(_lines.lastWhere((l) => l.indent < depth && l.id != null, orElse: () => _Line(0, '')).text.startsWith('Grid'))) return false;
    if (id != '$kind${(_counts[kind] ?? 0) + 1}') return false;
    _counts[kind] = (_counts[kind] ?? 0) + 1;
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
    final first = readStrings(itemNode['children']).firstOrNull;
    if (first != null) words.write(_staggerWord(first));
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
        if ((cn['type'] == 'listView' || cn['type'] == 'gridView') && readMap(cn['bind'])?['data'] != null) return true;
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
          for (final l in _lines)
            if (l.text.isNotEmpty) '${'  ' * l.indent}${l.text}${l.id == null ? '' : tails[l.id] ?? ''}',
          ?last,
        ].join('\n');
    try {
      // What the words did not say, per node (after the fields' words for
      // what a line still differs in where it is: print_fields.dart).
      final first = printFieldsRefine(_parse(text(const {}, null)), [for (final l in _lines) if (l.id != null) (id: l.id!, get: () => l.text, set: (String t) => l.text = t)], () => _parse(text(const {}, null)), context);
      final parsed = readMap(first['nodes']) ?? const {};
      // A variable read back with another type than its value says: its
      // state line writes the type.
      final widened = <String>[];
      for (final e in (readMap(document['variables']) ?? const {}).entries) {
        final got = {for (final v in readList(readMap(first['variables'])?[e.key]) ?? const []) if (readMap(v) case final Json m) m['name']: m['type']};
        for (final v in readList(e.value) ?? const []) {
          if (readMap(v) case final Json m when m['name'] is String && got.containsKey(m['name']) && got[m['name']] != m['type'] && !_typedState.contains(m['name'])) widened.add(m['name']! as String);
        }
      }
      if (widened.isNotEmpty) {
        _typedState.addAll(widened);
        why = 'a state read back with another type';
        return null;
      }
      final tails = <String, String>{};
      for (final l in _lines) {
        final id = l.id;
        if (id == null) continue;
        final got = readMap(parsed[id]);
        if (got == null) {
          // Read without its id it is something else (a page word): with it.
          if (_dropped.contains(id)) {
            _keepId.add(id);
            why = 'a line read otherwise without its id';
            return null;
          }
          final type = '${readMap(nodes[id])!['type']}';
          why = catalog.widget(type) == null
              ? 'a type the catalog does not have (a component of a design system not given) — $type'
              : 'a node the print does not give back — $id: ${l.text}';
          return null;
        }
        final patch = diffPatch(got, readMap(nodes[id])!);
        if (patch != null) tails[id] = ' ${jsonEncode(_sorted(patch))}';
      }
      // A dialog printed as its head whose parts do not read back as they
      // are: printed as a `Canvas#id` block.
      final unreadDialogs = [
        for (final e in _dialogParts.entries)
          if (e.value.any((p) => readMap(parsed[p]) == null || diffPatch(readMap(parsed[p])!, readMap(nodes[p])!) != null)) e.key,
      ];
      if (unreadDialogs.isNotEmpty) {
        _noOverlay.addAll(unreadDialogs);
        why = 'a dialog that does not read back';
        return null;
      }
      // A node whose slots do not read back from the lines under it: its
      // slots written as `slot name` lines.
      final slotted = [
        for (final l in _lines)
          if (l.id case final String id
              when !_slotLines.contains(id) &&
                  readMap(readMap(nodes[id])?['slots'])?.isNotEmpty == true &&
                  readMap(parsed[id]) != null &&
                  !jsonEquality.equals(readMap(parsed[id])!['slots'], readMap(nodes[id])!['slots']))
            id,
      ];
      // A list printed with an `each` under its line reads back with its
      // data and its one child, or is printed as nodes.
      final unread = [
        for (final id in _handEach)
          if (readMap(parsed[id]) case final got?)
            if (!jsonEquality.equals(got['children'], readMap(nodes[id])!['children']) || readMap(got['bind'])?['data'] != readMap(readMap(nodes[id])!['bind'])?['data']) id,
      ];
      if (unread.isNotEmpty) {
        _noEach.addAll(unread);
        why = 'an each that does not read back';
        return null;
      }
      if (slotted.isNotEmpty) {
        _slotLines.addAll(slotted);
        why = 'slots that do not read back';
        return null;
      }
      // A list printed as `each` reads back as it is, or is printed as nodes.
      var unreadStructure = false;
      for (final id in _structure) {
        final got = readMap(parsed[id]);
        if (got == null || diffPatch(got, readMap(nodes[id])!) != null) {
          unreadStructure = true;
          _noEach.add(id.endsWith('Item') && !nodes.containsKey('${id}Item')
              ? id.substring(0, id.length - 4)
              // A page view's page that does not read back: the page view printed as written.
              : id.endsWith('Page') && readMap(nodes[id.substring(0, id.length - 4)])?['type'] == 'pageView'
                  ? id.substring(0, id.length - 4)
                  : id);
        }
      }
      if (unreadStructure) {
        why = 'an each that does not read back';
        return null;
      }
      // A tail can change how the lines after it read (a parent's alignment,
      // its children's sizes, the canvas's height): read again, and add to
      // the tails, and to the `canvas` line, what still differs, until
      // nothing does.
      final patches = {for (final e in tails.entries) e.key: jsonDecode(e.value.substring(1)) as Json};
      final canvas = <String, Json>{};
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
            tails[id] = ' ${jsonEncode(_sorted(patches[id]))}';
            changed = true;
          }
        }
        // What each canvas has that the parser does not give it.
        for (final e in _canvases.entries) {
          final want = readMap(nodes[e.key]), now = readMap(got[e.key]);
          final d = want == null || now == null ? null : diffPatch(now, want);
          if (d == null) continue;
          final next = mergePatch(canvas[e.key] ?? const {}, d, keepNulls: true);
          final words = _canvasLine(next);
          final more = e.value.head == 'canvas' ? _canvasEvents : '';
          final line = words == null ? (e.value.head == 'canvas' && more.isEmpty ? '' : '${e.value.head}$more') : '${e.value.head} $words$more';
          if (line != e.value.line.text) {
            e.value.line.text = line;
            canvas[e.key] = next;
            changed = true;
          }
        }
        if (!changed && round > 0) break;
        second = _parse(text(tails, null));
      }
      // A line's media rules in its tail because its words, read with no tail,
      // gave other rules (a rule that hides a node whose `visible` the tail
      // binds drops that binding): with the tail, the words may say them.
      final ruled = [
        for (final e in patches.entries)
          if (e.value.containsKey('media') && RegExp(r'\s(hide|show)=|\s[A-Za-z0-9]+\.[A-Za-z]').hasMatch(_lines.firstWhere((l) => l.id == e.key).text)) e.key,
      ];
      final unpruned = {...tails}, unprunedSecond = second;
      if (ruled.isNotEmpty) {
        final trial = {...tails};
        for (final id in ruled) {
          final p = {...patches[id]!}..remove('media');
          if (p.isEmpty) {
            trial.remove(id);
          } else {
            trial[id] = ' ${jsonEncode(_sorted(p))}';
          }
        }
        final got = readMap(_parse(text(trial, null))['nodes']) ?? const {};
        final kept = [
          for (final id in ruled)
            if (diffPatch(readMap(got[id]) ?? const {}, readMap(nodes[id])!) == null) id,
        ];
        for (final id in kept) {
          if (trial.containsKey(id)) {
            tails[id] = trial[id]!;
          } else {
            tails.remove(id);
          }
        }
        if (kept.isNotEmpty) second = _parse(text(tails, null));
      }
      final rest = diffPatch(second, document);
      final out = text(tails, rest == null ? null : 'document ${jsonEncode(_sorted(rest))}');
      if (jsonEncode(_sorted(_parse(out))) == jsonEncode(_sorted(document))) return out;
      if (ruled.isNotEmpty) {
        final rest = diffPatch(unprunedSecond, document);
        final out = text(unpruned, rest == null ? null : 'document ${jsonEncode(_sorted(rest))}');
        if (jsonEncode(_sorted(_parse(out))) == jsonEncode(_sorted(document))) return out;
      }
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
