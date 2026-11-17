// A node's line in the notation, for printNotation (print.dart): the words
// for its type, text, props, layout, decoration, node fields and bindings.
//
// What a word says is what the parser reads, so the parser is the table: the
// word for a type, whether a variant or a short name is plain, what a line
// gives with nothing written and whether `key=value` reads back as that prop
// are found by reading short lines ([_Probes]), not kept here a second time.
// The sizes a line is given by its parent follow the parser's one rule per
// parent (design 13, section 3), read from the document. What the words leave
// unsaid or say wrongly, printNotation adds as the line's `{…}` tail.
import 'dart:convert';

import '../behavior_fields.dart' show BehaviorFields;
import '../behaviors.dart' show diffPatch;
import '../catalog.dart';
import '../json.dart';
import '../props.dart';
import '../value_fields.dart' show DecorationFields, LayoutFields, NodeFields;
import 'notation.dart';
import 'print_events.dart';
import 'print_media.dart';
import 'print_paint.dart';
import 'print_states.dart';

/// Whether a node's line also writes, by the field's own name or its dotted
/// path (docs/design/22, section 2.1), the fields the parser has no word for
/// yet: a text's `letterSpacing=` and `from=`, `squeezable=`, `columnSpan=`,
/// `strokeSides=`, `dashPattern=`, a behavior (`inkWell={…}`, `states={…}`),
/// a binding of any path (`motion.scale={…}`).
///
/// Off until the parser reads every catalog field by name (the Keys family
/// of design 22): until then such a word would be read as an unknown prop,
/// and the field is left to the line's `{…}` tail. Turned on, the tests in
/// test/notation/fields_test.dart marked "needs the Keys family" run.
const bool notationFieldNames = false;

/// What a line is printed with: the whole document (a node's parent, its
/// variables), the catalog its types come from and the options the print is
/// parsed back with.
final class PrintContext {
  PrintContext({required this.document, required this.catalog, required this.options, this.fieldNames = notationFieldNames});

  final Json document;
  final Catalog catalog;
  final NotationOptions options;

  /// [notationFieldNames] for this print.
  final bool fieldNames;

  Json get nodes => readMap(document['nodes']) ?? const {};

  /// Each node's parent (by children or a slot).
  late final Map<String, String> _parents = () {
    final out = <String, String>{};
    for (final e in nodes.entries) {
      final n = readMap(e.value);
      if (n == null) continue;
      for (final c in readStrings(n['children'])) {
        out[c] = e.key;
      }
      for (final c in (readMap(n['slots']) ?? const {}).values) {
        if (c is String) out[c] = e.key;
      }
    }
    return out;
  }();

  /// The parent of node [id], as the document holds it.
  Json? parentOf(String id) => readMap(nodes[_parents[id]]);

  /// The names of the document's variables (a bare word of one of them is
  /// read as a mistake for its value, so it is quoted).
  late final Set<String> variableNames = {
    for (final list in (readMap(document['variables']) ?? const {}).values)
      for (final v in readList(list) ?? const [])
        if (readMap(v)?['name'] case final String name) name,
  };

  late final _Probes _probes = _Probes.of(catalog, options);
  final Map<String, _NodeLine> _lines = {};

  _NodeLine _line(String id, Json n) => _lines[id] ??= (_NodeLine(id, n, this)..write());
}

/// The line of node [id] in the notation's words: its type, id, main string
/// and every field the words can say, then what its events, media rules and
/// paint say ([printEvents], [printMedia], [printPaint]). What the words leave
/// unsaid or say wrongly, [printNotation] finds by parsing the line back and
/// adds as the line's `{…}` tail, so a word written here never has to be
/// exact to be safe: it has to be right to be counted.
String printNodeLine(String id, Json n, PrintContext context) {
  final line = context._line(id, n);
  final b = StringBuffer(line.head)..write('#$id');
  for (final w in line.words) {
    b.write(' $w');
  }
  for (final words in [printStates(id, n, context), printEvents(id, n, context), printMedia(id, n, context), printPaint(id, n, context)]) {
    for (final w in words) {
      b.write(' $w');
    }
  }
  return b.toString();
}

/// The reaction of node [n] that its line's `bind=name` writes (a control's
/// value kept in a variable: the binding and the `changed` reaction that
/// stores it, design 13 section 3), as its index in `n['actions']`; null when
/// the line writes no `bind=`. The events' words leave that reaction out.
int? printedBindReaction(String id, Json n, PrintContext context) => context._line(id, n).twoWay?.index;

/// A size as `w=`/`h=` write it: a number, `fill` or `hug`, or the size's
/// own JSON when it carries a design size (`{"fill":390}`).
String? _sizeWord(Object? v) {
  if (v is num) return jsonEncode(v);
  if (v is Map && v.length == 1 && v.values.single == 0 && (v.containsKey('fill') || v.containsKey('hug'))) return '${v.keys.single}';
  if (v is Map) return _json(v);
  return null;
}

/// [v] as JSON, unless a text in it would be read as a value worked out
/// (`"{n} left"`).
String? _json(Object? v) => _hasBrace(v) ? null : jsonEncode(v);

bool _hasBrace(Object? v) => switch (v) {
      final String s => s.contains('{') || s.contains('}'),
      final List l => l.any(_hasBrace),
      final Map m => m.values.any(_hasBrace),
      _ => false,
    };

final _bare = RegExp(r'^[A-Za-z#][A-Za-z0-9_#-]*$');
final _name = RegExp(r'^[A-Za-z_][A-Za-z0-9_.]*$');

/// [v] as a value after `key=`: a number, a bare word (an enum's name, a
/// color), a quoted string, JSON for a list or a map; null when no value
/// written reads back as it ([names]: the document's variables, which a bare
/// word would be read as).
String? _value(Object? v, Set<String> names) {
  switch (v) {
    case null:
      return null;
    case bool() || num():
      return jsonEncode(v);
    case final String s:
      if (_bare.hasMatch(s) && !const {'true', 'false', 'null', 'item', 'index'}.contains(s) && !names.contains(s)) return s;
      if (s.contains('{') || s.contains(r'\$')) return null;
      return jsonEncode(s);
    case List() || Map():
      return _json(v);
  }
  return null;
}

/// Where the `{` at [open] of [s] closes, double quotes paired as the
/// parser pairs them; -1: never.
int _close(String s, int open) {
  var depth = 0, quoted = false;
  for (var i = open; i < s.length; i++) {
    final c = s[i];
    if (c == '"' && (i == 0 || s[i - 1] != r'\')) quoted = !quoted;
    if (quoted) continue;
    if (c == '{') depth++;
    if (c == '}' && --depth == 0) return i;
  }
  return -1;
}

/// What goes in the braces for the read `${inner}`: the name, or the
/// formula; null when braces would read it otherwise (`${= name}` reads back
/// as `${name}`; a brace of code is text).
String? _braced(String inner) {
  String? e;
  if (inner.startsWith('=')) {
    e = inner.substring(1).trim();
    if (e.isEmpty || (_name.hasMatch(e) && !const {'true', 'false', 'null'}.contains(e))) return null;
  } else {
    e = _name.hasMatch(inner) ? inner : null;
  }
  if (e == null || e.contains('\n') || e.contains(r'\n')) return null;
  if (RegExp(r'^\s*[A-Za-z_]\w*\s*:\s|^\s+[A-Za-z_]\w*\s+$').hasMatch(e)) return null;
  return e;
}

/// A binding's value as `key={expression}` writes it: `{name}` or
/// `{formula}`; null when it is a text with values in it (or reads back
/// otherwise).
String? _expression(Object? v) {
  if (v is! String || !v.startsWith(r'${') || _close(v, 1) != v.length - 1) return null;
  final e = _braced(v.substring(2, v.length - 1));
  return e == null || _requoted('{$e}') ? null : '{$e}';
}

/// Whether the line reads [written] with a 'single-quoted' text in it as
/// "double-quoted" (page_words.dart reads one so after `=`, `(`, `,`, an
/// operator or a space), so it never reads back as written.
bool _requoted(String written) {
  var inDouble = false;
  for (var i = 0; i < written.length; i++) {
    final c = written[i];
    if (inDouble) {
      if (c == r'\') {
        i++;
      } else if (c == '"') {
        inDouble = false;
      }
      continue;
    }
    if (c == '"') {
      inDouble = true;
    } else if (c == "'") {
      final end = written.indexOf("'", i + 1);
      if (end > i && !written.substring(i + 1, end).contains('"') && '=(,?:[!<>+&| '.contains(written[i - 1])) return true;
    }
  }
  return false;
}

/// A binding's value as a key that always reads a formula writes it
/// (`selected={done}` is `${= done}`); null for any other value.
String? _formulaOf(Object? v) {
  if (v is! String || !v.startsWith(r'${=') || _close(v, 1) != v.length - 1) return null;
  final e = v.substring(3, v.length - 1).trim();
  if (e.isEmpty || e.contains('\n') || _requoted('{$e}')) return null;
  return '{$e}';
}

/// [s], a text that may read values (`Total: ${total}`), as the quoted
/// string that reads back as it (`"Total: {total}"`); null when none does.
String? _quoted(String s) {
  final parts = <(String, bool)>[]; // (text, is an expression)
  final literal = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == r'$' && i + 1 < s.length && s[i + 1] == '{') {
      final end = _close(s, i + 1);
      final e = end < 0 ? null : _braced(s.substring(i + 2, end));
      if (e == null) return null;
      parts
        ..add((literal.toString(), false))
        ..add((e, true));
      literal.clear();
      i = end;
      continue;
    }
    if (c == '{' || (c == r'\' && i + 1 < s.length && s[i + 1] == r'$')) return null;
    literal.write(c);
  }
  parts.add((literal.toString(), false));
  // An expression with quotes of its own is read as written, the text
  // around it unescaped; any other string as JSON.
  if (parts.any((p) => p.$2 && p.$1.contains('"'))) {
    final out = StringBuffer('"');
    for (final (text, expression) in parts) {
      if (expression) {
        if (text.contains(r'\')) return null;
        out.write('{$text}');
      } else {
        if (text.contains('\n')) return null;
        out.write(text.replaceAll(r'\', r'\\').replaceAll('"', r'\"'));
      }
    }
    return (out..write('"')).toString();
  }
  return jsonEncode(parts.map((p) => p.$2 ? '{${p.$1}}' : p.$1).join());
}

/// The lines the parser is asked about: what a line gives with nothing
/// written but its type, which word writes a type, and whether a key reads
/// back as the prop of that name. Read once per catalog and canvas width.
final class _Probes {
  _Probes(this.catalog, this.options);

  final Catalog catalog;
  final NotationOptions options;

  static final _all = Expando<Map<double, _Probes>>();

  static _Probes of(Catalog catalog, NotationOptions options) =>
      (_all[catalog] ??= {})[options.width] ??= _Probes(catalog, NotationOptions(width: options.width));

  final _read = <String, ({Json? node, Json document, bool clean})>{};

  /// [text] read: its root node, the whole document, and whether it read
  /// with no issue.
  ({Json? node, Json document, bool clean}) read(String text) => _read[text] ??= () {
        final r = parseNotation(text, catalog: catalog, options: options);
        final nodes = readMap(r.document['nodes']) ?? const {};
        final screen = readStrings(r.document['roots']).firstOrNull ?? 'screen';
        final body = readString(readMap(readMap(nodes[screen])?['slots'])?['body']);
        return (node: readMap(nodes[body]), document: r.document, clean: r.issues.isEmpty);
      }();

  final _lines = <String, ({Json? node, bool clean})>{};

  /// [text] read as a line in a column (where most lines are): its node,
  /// and whether it read with no issue.
  ({Json? node, bool clean}) line(String text) => _lines[text] ??= () {
        final r = read('Column\n  $text');
        final nodes = readMap(r.document['nodes']) ?? const {};
        final first = readStrings(r.node?['children']).firstOrNull;
        return (node: readMap(nodes[first]), clean: r.clean);
      }();

  /// The node a line of [text] gives in a column.
  Json node(String text) => line(text).node ?? const {};

  final _words = <String, String>{};

  /// The word a node of [type] is written with: its one short name that
  /// says nothing more (`Input`, `Toggle`, `Button`), else a button's look
  /// that says nothing more (`Button.outline`), else its own name
  /// capitalised (`ListView`), else as the catalog spells it (`box`, which
  /// `Box` is not).
  String word(String type) => _words[type] ??= () {
        final own = this.own(type);
        if (own == type && !read(type).clean) return type;
        final plain = [
          for (final e in notationTypes.entries)
            if (e.value.type == type && _plain(e.key, own, type)) e.key,
        ];
        if (plain.length == 1) return plain.single;
        if (type[0].toLowerCase() == type[0]) {
          for (final v in buttonVariants.entries) {
            if (v.value.type == type && v.value.props.isEmpty && _plain('Button.${v.key}', own, type)) return 'Button.${v.key}';
          }
        }
        return own;
      }();

  final _own = <String, String>{};

  /// A type's own word: its name capitalised when that reads as it does
  /// (`ListView`; `Barcode` is the bars, `Box` a column), else its name.
  String own(String type) => _own[type] ??= () {
        final r = read(type);
        if (!r.clean || r.node?['type'] != type) return type;
        final cap = '${type[0].toUpperCase()}${type.substring(1)}';
        return _same(cap, type) ? cap : type;
      }();

  /// Whether a line of [a] and one of [b], each with [rest] after it, read
  /// the same (not kept: each node's line is its own).
  bool sameLine(String a, String b, String rest) {
    Object? read(String head) {
      final r = parseNotation('Column\n  $head $rest', catalog: catalog, options: options);
      return r.issues.isEmpty ? _sorted(r.document) : null;
    }

    final x = read(a);
    return x != null && jsonEncode(x) == jsonEncode(read(b));
  }

  /// Whether [a] and [b] read the same, alone and in a column.
  bool _same(String a, String b) {
    for (final before in ['', 'Column\n  ']) {
      final x = read('$before$a'), y = read('$before$b');
      if (!x.clean || !y.clean || jsonEncode(_sorted(x.document)) != jsonEncode(_sorted(y.document))) return false;
    }
    return true;
  }

  /// Whether the short name [short] says no more than [own], the type's own
  /// word: alone, in a column, with a line under it and with each of the
  /// type's props written (`AreaChart values=[…]` is a filled chart,
  /// `Pages` makes its lines pages).
  bool _plain(String short, String own, String type) {
    if (!_same(short, own)) return false;
    final spec = catalog.widget(type);
    final tries = [
      '\n    Text "a"',
      // A chart's points as the notation writes them.
      ' values=[1,2]',
      for (final p in spec?.props ?? const <PropDef<Object?>>[])
        for (final v in switch (p.type.kind) {
          PropKind.number || PropKind.integer => ['2'],
          PropKind.boolean => ['true'],
          PropKind.string => ['"a"'],
          // A list of values, and one of records (a chart's series).
          PropKind.list => ['[1,2]', '[{"name":"a","values":[1,2]}]'],
          PropKind.enumeration when p.type.values.isNotEmpty => [p.type.values.first],
          _ => const <String>[],
        })
          ' ${p.key}=$v',
    ];
    for (final t in tries) {
      final x = read('Column\n  $short$t'), y = read('Column\n  $own$t');
      if (x.clean != y.clean) return false;
      if (x.clean && jsonEncode(_sorted(x.document)) != jsonEncode(_sorted(y.document))) return false;
    }
    return true;
  }

  final _says = <String, bool>{};

  /// Whether `[head] [written]` reads back with no issue, as a node of the
  /// head's type (a text with a fill is a tag around it) and as [check]
  /// says, asked once per [tag].
  bool says(String head, String written, String tag, bool Function(Json node) check) =>
      _says['$head\u0000$tag'] ??= () {
        final r = line('$head $written');
        return r.clean && r.node != null && r.node!['type'] == node(head)['type'] && check(r.node!);
      }();
}

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

bool _equal(Object? a, Object? b) => jsonEncode(_sorted(a)) == jsonEncode(_sorted(b));

/// Whether every field of [part] is in [whole] with the same value.
bool _within(Object? part, Object? whole) {
  if (part is Map && whole is Map) return part.entries.every((e) => whole.containsKey(e.key) && _within(e.value, whole[e.key]));
  return _equal(part, whole);
}

int _leaves(Object? v) => switch (v) {
      final Map m => m.values.fold<int>(0, (s, x) => s + _leaves(x)),
      _ => 1,
    };

/// The keys the parser reads into a text's style, by the style's field.
const _textWords = {'fontSize': 'size', 'fontWeight': 'weight', 'color': 'color', 'fontFamily': 'fontFamily', 'height': 'lineHeight'};

/// …and into the style of an Input's typed text.
const _fieldWords = {
  'fontSize': 'size', 'fontWeight': 'weight', 'color': 'color', 'fontFamily': 'fontFamily', 'height': 'lineHeight', //
  'letterSpacing': 'letterSpacing',
};

/// The same, for a value bound to the field (`size=` with braces is not
/// the Input's text size).
const _fieldBound = {
  'fontSize': 'fontSize', 'fontWeight': 'weight', 'color': 'color', 'fontFamily': 'fontFamily', 'height': 'lineHeight', //
  'letterSpacing': 'letterSpacing',
};

/// An Input's decoration fields by the words that write them.
const _fieldDecoration = {'hintText': 'hint', 'helperText': 'helper', 'errorText': 'error', 'labelText': 'label'};

const _mainWords = {'start': 'start', 'end': 'end', 'spaceBetween': 'between', 'spaceAround': 'around', 'spaceEvenly': 'evenly'};
const _places = {'topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight', 'bottomLeft', 'bottomCenter', 'bottomRight'};
const _buttons = {'filledButton', 'outlinedButton', 'textButton', 'elevatedButton'};

/// The node keys other families write (events, media, paint and motion) or
/// that are the tree itself.
const _notFields = {'type', 'id', 'children', 'slots', 'layout', 'decoration', 'props', 'bind', 'actions', 'media', 'animations', 'transitions', 'customPaint'};

/// One node's line: its head (type word and variant) and its words.
final class _NodeLine {
  _NodeLine(this.id, this.n, this.c)
      : type = '${n['type']}',
        props = readMap(n['props']) ?? const {},
        layout = readMap(n['layout']) ?? const {},
        decoration = readMap(n['decoration']) ?? const {},
        bind = readMap(n['bind']) ?? const {},
        spec = c.catalog.widget('${n['type']}');

  final String id;
  final Json n;
  final PrintContext c;
  final String type;
  final Json props, layout, decoration, bind;
  final WidgetSpec? spec;

  /// The type's word and variant (`Text.title`, `Button.outline`, `Input`).
  String head = '';

  final words = <String>[];

  /// What the head alone gives.
  Json probe = const {};

  /// The props, bindings and node keys a word was written for, or that
  /// words were found for already.
  final doneProps = <String>{}, doneBind = <String>{}, doneNode = <String>{};

  /// The words of a text's or an Input's style, chosen with its variant.
  final _style = <String>[];

  ({String name, int index, String path})? twoWay;

  _Probes get _probes => c._probes;
  bool get _names => c.fieldNames;
  Set<String> get _vars => c.variableNames;
  Json get _probeProps => readMap(probe['props']) ?? const {};
  bool _hasProp(String key) => spec?.props.any((p) => p.key == key) ?? false;

  void write() {
    _writeAs(_head());
    // A short name says no more than the type's own word with nothing
    // written; with this line's words it may (`AreaChart` fills under a
    // line chart's series): then the own word.
    final own = _probes.own(type);
    if (head == _probes.word(type) && head != own && !_probes.sameLine(head, own, words.join(' '))) {
      words.clear();
      doneProps.clear();
      doneBind.clear();
      doneNode.clear();
      _style.clear();
      _writeAs(own);
    }
  }

  void _writeAs(String head) {
    this.head = head;
    probe = _probes.node(head);
    twoWay = _twoWay();
    if (twoWay case final t?) doneBind.add(t.path);
    _main();
    _typeWords();
    _layout();
    _decoration();
    _props();
    _nodeFields();
    _bindings();
    if (twoWay case final t?) words.add('bind=${t.name}');
  }

  // --- the head --------------------------------------------------------------

  String _head() {
    final word = _probes.word(type);
    if (word == 'Text') return _textHead();
    if (type == 'box' && _image() != null) return 'Image';
    if (_buttons.contains(type)) {
      // A button's look with props of its own (Button.secondary is tonal):
      // the one that says the most of this button.
      String? best;
      var most = 0;
      for (final v in buttonVariants.entries) {
        if (v.value.type != type || v.value.props.isEmpty || !_within(v.value.props, props)) continue;
        if (!_probes.read('Button.${v.key}').clean) continue;
        if (_leaves(v.value.props) > most) {
          most = _leaves(v.value.props);
          best = 'Button.${v.key}';
        }
      }
      if (best != null) return best;
    }
    return word;
  }

  /// A text's variant: the named style (or none: the body) its style needs
  /// the fewest words from; ties to the later name, so the notation's short
  /// words win over the design system's (`title` over `pageTitle`).
  String _textHead() {
    final style = props['style'];
    if (style is! Map) return 'Text';
    final styles = c.options.textStyles;
    final body = styles['body'];
    var best = (variant: '', cost: 1 << 30, words: <String>[]);
    for (final (name, base) in [('', body), for (final e in styles.entries) if (e.key != 'body') (e.key, e.value)]) {
      if (base is! Map) continue;
      final plan = _stylePlan(style, base, _textWords, text: true);
      if (plan == null) continue;
      final cost = plan.length + (name.isEmpty ? 0 : 1);
      if (cost <= best.cost) best = (variant: name, cost: cost, words: plan);
    }
    if (best.cost == 1 << 30) return 'Text';
    _style.addAll(best.words);
    doneProps.add('style');
    return best.variant.isEmpty ? 'Text' : 'Text.${best.variant}';
  }

  /// The words that make [base] (what the line starts from) into [style];
  /// null when one cannot (a field [base] has that [style] lacks; a field
  /// with no word, unless [_names]).
  List<String>? _stylePlan(Map style, Map base, Map<String, String> wordOf, {bool text = false}) {
    if (base.keys.any((k) => !style.containsKey(k))) return null;
    final out = <String>[];
    for (final e in style.entries) {
      final k = '${e.key}', v = e.value;
      if (base.containsKey(k) && _equal(base[k], v)) continue;
      if (wordOf[k] case final String w) {
        final value = _value(v, _vars);
        if (value == null) return null;
        out.add('$w=$value');
      } else if (text && k == 'fontStyle' && v == 'italic') {
        out.add('italic');
      } else if (text && k == 'decoration' && v is String) {
        out.add(switch (v) { 'underline' => 'underline', 'lineThrough' => 'strike', _ => 'decoration=$v' });
      } else if (_names && _value(v, _vars) != null) {
        // A field of the text's style by its own name (design 22, 2.1).
        out.add('$k=${_value(v, _vars)}');
      } else {
        return null;
      }
    }
    return out;
  }

  /// A box that shows one picture: its url and fit (`Image "…" fit=contain`).
  Json? _image() {
    final fills = decoration['fills'];
    if (fills is! List || fills.length != 1) return null;
    final fill = readMap(fills.single);
    final image = readMap(fill?['image']);
    if (fill == null || fill.length != 1 || image == null || image['url'] is! String) return null;
    if (image.keys.any((k) => k != 'url' && k != 'fit')) return null;
    if (!const {'cover', 'contain', 'fill', 'fitWidth', 'fitHeight', 'none', 'scaleDown'}.contains(image['fit'])) return null;
    return image;
  }

  // --- a control's two-way binding ------------------------------------------

  /// `bind=name`: the control's value bound to a declared variable and its
  /// first reaction the change stored in it, as `bind=` writes them.
  ({String name, int index, String path})? _twoWay() {
    final actions = readList(n['actions']);
    if (actions == null || actions.isEmpty || _hasProp('bind')) return null;
    final r = _probes.line('$head bind=__v');
    final pb = readMap(r.node?['bind']);
    final pa = readList(r.node?['actions']);
    if (!r.clean || pb == null || pb.length != 1 || pa == null || pa.isEmpty) return null;
    final path = pb.keys.single;
    final template = '${pb[path]}';
    final at = template.indexOf('__v');
    final value = bind[path];
    if (at < 0 || value is! String || !value.startsWith(template.substring(0, at)) || !value.endsWith(template.substring(at + 3))) return null;
    final name = value.substring(at, value.length - (template.length - at - 3));
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(name) || !_vars.contains(name)) return null;
    final reaction = jsonDecode(jsonEncode(pa.first).replaceAll('__v', name));
    if (!_equal(reaction, actions.first)) return null;
    return (name: name, index: 0, path: path);
  }

  // --- the main string -------------------------------------------------------

  /// The prop the line's string fills (`Text "…"`: text; `Button "…"`:
  /// label; `Input "…"`: its field's label).
  String? _mainKey() {
    final spec = this.spec;
    if (spec == null) return null;
    if (type == 'textField') return 'decoration.labelText';
    if (const {'datePicker', 'timePicker', 'dateTimeInput'}.contains(type)) return _hasProp('decoration') ? 'decoration.labelText' : null;
    if (const {'accordion', 'expansionTile', 'listTile', 'column', 'row', 'stack'}.contains(type)) return null;
    if (type == 'box') return 'text';
    if (type == 'dropdown') return 'hint';
    if (type == 'barcode') return 'data';
    if (type[0].toUpperCase() == type[0]) return notationStrings(spec).firstOrNull;
    for (final k in const ['text', 'label', 'title', 'icon', 'hint']) {
      if (_hasProp(k)) return k;
    }
    return null;
  }

  void _main() {
    if (head == 'Image') {
      final image = _image()!;
      final q = _quoted('${image['url']}');
      if (q != null) {
        words.add(q);
        if (image['fit'] != 'cover') words.add('fit=${image['fit']}');
      }
      return;
    }
    final key = _mainKey();
    if (key == null) return;
    final nested = key.contains('.');
    final holder = nested ? readMap(props[key.substring(0, key.indexOf('.'))]) : props;
    final leaf = nested ? key.substring(key.indexOf('.') + 1) : key;
    final fixed = holder?[leaf];
    // An Input whose decoration has more than its words say is written whole.
    if (type == 'textField' && _fieldDecorationWhole()) return;
    final reads = type == 'text' || type == 'box';
    if (fixed is String && (reads || !fixed.contains(r'${'))) {
      final q = _quoted(fixed);
      if (q == null) return;
      words.add(q);
      doneProps.add(key);
    } else if (fixed == null && type != 'text' && bind['props.$key'] is String) {
      final q = _quoted(bind['props.$key']! as String);
      if (q == null) return;
      words.add(q);
      doneBind.add('props.$key');
    }
  }

  // --- what a type has words of its own for -------------------------------

  void _typeWords() {
    if (type == 'row' || type == 'column') _box();
    if (type == 'stack' && props['clipBehavior'] == 'antiAlias' && _probeProps['clipBehavior'] != 'antiAlias') {
      words.add('clip');
      doneProps.add('clipBehavior');
    }
    if (type == 'text') _text();
    if (type == 'textField') _input();
    if (_buttons.contains(type)) _button();
    if (type == 'iconButton') _iconButton();
  }

  void _box() {
    final row = type == 'row';
    if (props['spacing'] is num && !_equal(props['spacing'], _probeProps['spacing'])) {
      words.add('gap=${jsonEncode(props['spacing'])}');
    }
    doneProps.add('spacing');
    final main = props['mainAxisAlignment'], cross = props['crossAxisAlignment'];
    if (!_equal(main, _probeProps['mainAxisAlignment'])) {
      final w = main == 'center' ? (row ? 'center' : 'middle') : _mainWords[main];
      if (w != null) {
        words.add(w);
        doneProps.add('mainAxisAlignment');
      }
    } else {
      doneProps.add('mainAxisAlignment');
    }
    if (!_equal(cross, _probeProps['crossAxisAlignment'])) {
      final w = switch (cross) {
        'start' => row ? 'top' : 'left',
        'center' => row ? 'middle' : 'center',
        'end' => row ? 'bottom' : 'right',
        'stretch' => 'stretch',
        _ => null,
      };
      if (w != null) {
        words.add(w);
        doneProps.add('crossAxisAlignment');
      }
    } else {
      doneProps.add('crossAxisAlignment');
    }
    // `scroll`: a column scrolls down, a row sideways.
    if (props['scrollable'] == true && (!row || props['scrollDirection'] == 'horizontal')) {
      words.add('scroll');
      doneProps.addAll(['scrollable', if (row) 'scrollDirection']);
    }
    if (props['clipBehavior'] == 'antiAlias' && _probeProps['clipBehavior'] != 'antiAlias') {
      words.add('clip');
      doneProps.add('clipBehavior');
    }
  }

  void _text() {
    words.addAll(_style);
    final align = props['textAlign'];
    if (const {'center', 'right', 'left'}.contains(align)) {
      words.add('$align');
      doneProps.add('textAlign');
    }
    doneProps.add('text');
  }

  void _input() {
    // Its typed text's style, over the field's own (none, unless the
    // design system says).
    final style = props['style'];
    final own = c.options.fieldText;
    final base = own is Map ? own : own is String ? {'from': own} : const {};
    if (style is Map && !_equal(style, _probeProps['style'])) {
      final plan = _stylePlan(style, base, _fieldWords);
      if (plan != null) {
        words.addAll(plan);
        doneProps.add('style');
      }
    }
    if (props['obscureText'] == true) {
      words.add('password');
      doneProps.add('obscureText');
    }
    final d = readMap(props['decoration']);
    if (d == null) return;
    if (_fieldDecorationWhole()) {
      if (_json(d) case final String j) words.add('decoration=$j');
      doneProps.add('decoration');
      return;
    }
    for (final e in _fieldDecoration.entries) {
      if (e.key == 'labelText' && doneProps.contains('decoration.labelText')) continue;
      if (d[e.key] case final String v when !v.contains(r'${')) {
        if (_value(v, _vars) case final String w) words.add('${e.value}=$w');
      }
    }
    if (readMap(d['prefixIcon']) case final Json icon when icon['size'] == 18 && icon.length == 2) {
      if (_value(icon['icon'], _vars) case final String w) words.add('icon=$w');
    }
    if (d['affixesAlwaysVisible'] == true) {
      for (final k in const ['prefix', 'suffix']) {
        if (d['${k}Text'] case final String v) {
          if (_value(v, _vars) case final String w) words.add('$k=$w');
        }
      }
    }
    if (_names) {
      for (final e in d.entries) {
        if (_fieldDecorationSaid(e.key, d)) continue;
        if (_value(e.value, _vars) case final String w) words.add('decoration.${e.key}=$w');
      }
    }
    doneProps.add('decoration');
  }

  /// Whether an Input's decoration field [key] has a word of its own.
  bool _fieldDecorationSaid(String key, Json d) =>
      _fieldDecoration.containsKey(key) ||
      (key == 'prefixIcon' && readMap(d['prefixIcon'])?['size'] == 18 && readMap(d['prefixIcon'])!.length == 2) ||
      ((key == 'prefixText' || key == 'suffixText' || key == 'affixesAlwaysVisible') && d['affixesAlwaysVisible'] == true);

  /// Whether an Input's decoration is written whole, as its JSON: it has a
  /// field no word says, and fields are not written by name.
  bool _fieldDecorationWhole() {
    final d = readMap(props['decoration']);
    if (d == null || _names) return false;
    return d.keys.any((k) => !_fieldDecorationSaid(k, d));
  }

  void _button() {
    final style = props['style'];
    if (style is! Map) return;
    final base = readMap(_probeProps['style']) ?? const {};
    final key = type == 'filledButton' || type == 'elevatedButton' ? 'backgroundColor' : 'foregroundColor';
    final differ = [for (final e in style.entries) if (!base.containsKey(e.key) || !_equal(base[e.key], e.value)) '${e.key}'];
    doneProps.add('style');
    if (differ.isEmpty && base.length == style.length) return;
    final color = base.keys.every(style.containsKey) && differ.length == 1 && differ.single == key ? _value(style[key], _vars) : null;
    if (color != null) {
      words.add('color=$color');
    } else if (_json(style) case final String j) {
      words.add('style=$j');
    }
  }

  void _iconButton() {
    final style = props['style'];
    if (style is! Map) return;
    final rest = {for (final e in style.entries) if (e.key != 'iconColor' && e.key != 'iconSize') '${e.key}': e.value};
    if (rest.isNotEmpty) {
      final j = _json(rest);
      if (j == null) return;
      words.add('style=$j');
    }
    if (_value(style['iconColor'], _vars) case final String w) words.add('color=$w');
    if (style['iconSize'] is num) words.add('size=${jsonEncode(style['iconSize'])}');
    doneProps.add('style');
  }

  // --- layout ----------------------------------------------------------------

  void _layout() {
    final pad = layout['padding'];
    if (pad != null && !_equal(pad, readMap(probe['layout'])?['padding'])) {
      if (_value(pad, _vars) case final String w) words.add('pad=$w');
    }
    _sizes();
    final flex = layout['flex'];
    if (flex is num) words.add(flex == 1 ? 'grow' : 'grow=${jsonEncode(flex)}');
    for (final k in const ['margin', 'x', 'y', 'align', 'order', 'basis', 'aspectRatio']) {
      if (!layout.containsKey(k)) continue;
      if (_value(layout[k], _vars) case final String w) words.add('$k=$w');
    }
    if (readMap(layout['constraints']) case final Json box when box.isNotEmpty) {
      if (box.length == 1 && box['maxWidth'] is num) {
        words.add('maxWidth=${jsonEncode(box['maxWidth'])}');
      } else if (_names) {
        // Each limit by its own name (design 22, 2.1).
        for (final e in box.entries) {
          if (_value(e.value, _vars) case final String w) words.add('${e.key}=$w');
        }
      } else if (_json(box) case final String j) {
        words.add('constraints=$j');
      }
    }
    if (_names) {
      // The rest of the layout's fields by their own names.
      const said = {'width', 'height', 'padding', 'flex', 'margin', 'x', 'y', 'align', 'order', 'basis', 'aspectRatio', 'constraints', 'squeezable'};
      for (final f in LayoutFields.all) {
        if (said.contains(f.key) || !layout.containsKey(f.key)) continue;
        if (_value(layout[f.key], _vars) case final String w) words.add('${f.key}=$w');
      }
    }
  }

  /// `w=` and `h=`, where the size is not the one the line gets from its
  /// parent: in a column a child fills the width and hugs its height, in a
  /// row it hugs both, `grow` fills, a control hugs (design 13, section 3).
  void _sizes() {
    final parent = c.parentOf(id);
    final ptype = parent?['type'];
    final playout = readMap(parent?['layout']) ?? const {};
    final pprops = readMap(parent?['props']) ?? const {};
    final inGrid = ptype == 'gridView', inRow = ptype == 'row', inTile = ptype == 'listTile';
    final pw = playout['width'], pc = pprops['crossAxisAlignment'];
    final inHug = ptype == 'column' && (pw is Map && pw.containsKey('hug') || pc == 'center' || pc == 'end');
    final flex = layout.containsKey('flex');
    bool fit(Object? v, String k) => v is Map && v.length == 1 && v[k] == 0;
    final probeW = readMap(probe['layout'])?['width'], probeH = readMap(probe['layout'])?['height'];
    Object? width;
    if (inGrid) {
      width = const {'fill': 0};
    } else if (fit(probeW, 'fill') || fit(probeW, 'hug')) {
      final spread = type == 'row' && !inRow && !inTile && const {'spaceBetween', 'spaceAround', 'spaceEvenly'}.contains(props['mainAxisAlignment']);
      width = flex || spread || (!inRow && !inTile && !inHug && fit(probeW, 'fill')) ? const {'fill': 0} : const {'hug': 0};
    } else {
      width = probeW;
    }
    // A spacer that grows in a column takes the height left, whatever is written.
    final spacer = type == 'spacer' && flex && ptype == 'column';
    final height = spacer ? const {'fill': 0} : probeH ?? const {'hug': 0};
    // A text in a row, and on a page a column in a row, may shrink when no
    // width is written: one that may not says its width.
    final squeezes = inRow && (type == 'text' || (type == 'column' && !flex && c.options.width >= 700 && head != 'Card'));
    var wroteWidth = false;
    if (!inGrid && !bind.containsKey('layout.width') && layout['width'] != null) {
      final w = layout['width'];
      if (!_equal(w, width) || (squeezes && layout['squeezable'] != true)) {
        if (_sizeWord(w) case final String s) {
          words.add('w=$s');
          wroteWidth = true;
        }
      }
    }
    if (!spacer && !bind.containsKey('layout.height') && layout['height'] != null && !_equal(layout['height'], height)) {
      if (_sizeWord(layout['height']) case final String s) words.add('h=$s');
    }
    final given = squeezes && !wroteWidth ? true : null;
    if (layout['squeezable'] != given && _names && layout['squeezable'] is bool) words.add('squeezable=${layout['squeezable']}');
  }

  // --- decoration ------------------------------------------------------------

  void _decoration() {
    final fills = decoration['fills'];
    final boundFill = bind['decoration.fills[0].color'];
    final fillExpression = _expression(boundFill);
    if (head == 'Image') {
      // Written by the head and its string.
    } else if (fills is List && fills.isNotEmpty && !_equal(fills, readMap(probe['decoration'])?['fills'])) {
      final single = fills.length == 1 ? readMap(fills.single) : null;
      final gradient = single == null ? null : _gradient(single);
      if (single != null && single.length == 1 && single['color'] is String && _says('fill')) {
        if (!(fillExpression != null && single['color'] == '#00000000')) {
          if (_value(single['color'], _vars) case final String w) words.add('fill=$w');
        }
      } else if (gradient != null) {
        words.add('gradient=$gradient');
      } else if (_json(fills) case final String j) {
        words.add('fills=$j');
      }
    }
    if (fillExpression != null) {
      words.add('fill=$fillExpression');
      doneBind.add('decoration.fills[0].color');
    }
    final strokes = decoration['strokes'];
    final boundStroke = _expression(bind['decoration.strokes[0].color']);
    final sides = decoration['strokeSides'];
    var sided = false;
    if (strokes is List && strokes.isNotEmpty) {
      final single = strokes.length == 1 ? readMap(strokes.single) : null;
      if (single != null && single.length == 1 && single['color'] is String && _says('border')) {
        if (const {'top', 'bottom', 'left', 'right'}.contains(sides) && boundStroke == null) {
          if (_value(single['color'], _vars) case final String w) words.add('border-$sides=$w');
          sided = true;
        } else if (!(boundStroke != null && single['color'] == '#00000000')) {
          if (_value(single['color'], _vars) case final String w) words.add('border=$w');
        }
      } else if (_json(strokes) case final String j) {
        words.add('strokes=$j');
      }
    }
    if (boundStroke != null) {
      words.add('border=$boundStroke');
      doneBind.add('decoration.strokes[0].color');
    }
    if (decoration['strokeWidth'] is num && (strokes is List && strokes.isNotEmpty)) {
      words.add('strokeWidth=${jsonEncode(decoration['strokeWidth'])}');
    }
    final radius = decoration['radius'];
    if (radius != null && !_equal(radius, readMap(probe['decoration'])?['radius'])) {
      if (_value(radius, _vars) case final String w) words.add('radius=$w');
    }
    for (final k in const ['effects', 'clip', 'shape']) {
      if (!decoration.containsKey(k)) continue;
      if (_value(decoration[k], _vars) case final String w) words.add('$k=$w');
    }
    if (_names) {
      const said = {'fills', 'strokes', 'strokeWidth', 'radius', 'effects', 'clip', 'shape'};
      for (final f in DecorationFields.all) {
        if (said.contains(f.key) || !decoration.containsKey(f.key) || (f.key == 'strokeSides' && sided)) continue;
        if (_value(decoration[f.key], _vars) case final String w) words.add('${f.key}=$w');
      }
    }
  }

  /// Whether `fill=` (`border=`) on this line is its first fill's (its
  /// border's) color: on a text it is not (a text with a fill is a tag).
  bool _says(String word) {
    final at = word == 'fill' ? 'fills' : 'strokes';
    return _probes.says(head, '${type == 'text' ? '"a" ' : ''}$word=#FF0A0B0C', word, (node) => _equal(readMap(node['decoration'])?[at], [
          {'color': '#FF0A0B0C'},
        ]));
  }

  /// A fill `gradient=` writes: a linear one with its stops spread evenly,
  /// corner to corner or between two places.
  String? _gradient(Json fill) {
    if (fill['type'] != 'linear' || fill.keys.any((k) => !const {'type', 'begin', 'end', 'stops'}.contains(k))) return null;
    final stops = readList(fill['stops']);
    if (stops == null || stops.length < 2 || !_places.contains(fill['begin']) || !_places.contains(fill['end'])) return null;
    final colors = <String>[];
    for (var i = 0; i < stops.length; i++) {
      final s = readMap(stops[i]);
      final p = s?['position'];
      if (s == null || s.length != 2 || s['color'] is! String || p is! num || (p - i / (stops.length - 1)).abs() > 1e-9) return null;
      colors.add(s['color']! as String);
    }
    if (fill['begin'] == 'topLeft' && fill['end'] == 'bottomRight') return _json(colors);
    return _json({'colors': colors, 'begin': fill['begin'], 'end': fill['end']});
  }

  // --- props by their own names ---------------------------------------------

  void _props() {
    // What the line gives with its flags written (a row that scrolls fades
    // at its ends).
    final flags = [for (final w in words) if (!w.contains('=') && !w.startsWith('"')) w];
    final given = flags.isEmpty ? _probeProps : readMap(_probes.node('$head ${flags.join(' ')}')['props']) ?? const {};
    for (final e in props.entries) {
      final k = e.key, v = e.value;
      if (doneProps.contains(k) || !_hasProp(k)) continue;
      if (given.containsKey(k) && _equal(v, given[k])) continue;
      if (v is String && v.contains(r'${') && type != 'text') continue;
      final w = _value(v, _vars);
      if (w == null) continue;
      // `gap` is a list's spacing as it is a column's (a grid's gap is both
      // of its spacings).
      final key = k == 'spacing' && type != 'gridView' ? 'gap' : k;
      final kind = switch (v) { String() => _bare.hasMatch(w) ? 'word' : 'string', _ => v.runtimeType.toString() };
      if (_probes.says(head, '$key=$w', '$k=$kind', (node) => _equal(readMap(node['props'])?[k], v) && readMap(node['bind'])?['props.$k'] == null)) {
        words.add('$key=$w');
      } else if (_names) {
        // Its name is a word of the notation's (`animate=`): the full path.
        words.add('props.$k=$w');
      }
    }
  }

  // --- the node's own fields and its behaviors ------------------------------

  void _nodeFields() {
    if (n['visible'] == false && probe['visible'] != false) words.add('hidden');
    if (n['opacity'] is num && !bind.containsKey('opacity')) words.add('opacity=${jsonEncode(n['opacity'])}');
    final tooltip = n['tooltip'];
    if (tooltip is String && tooltip != probe['tooltip']) {
      final w = _expression(tooltip) ?? _quoted(tooltip);
      if (w != null) words.add('tooltip=$w');
    }
    doneNode.addAll(['visible', 'opacity', 'tooltip']);
    if (readMap(n['sticky']) case final Json s when s.length == 1 && s['offset'] is num) {
      words.add(s['offset'] == 16 ? 'sticky' : 'sticky=${jsonEncode(s['offset'])}');
      doneNode.add('sticky');
    }
    if (n['ignorePointer'] == true && probe['ignorePointer'] != true) {
      if (_probes.says(head, 'readOnly', 'readOnly', (node) => node['ignorePointer'] == true && diffPatch(probe, node)?.keys.join() == 'ignorePointer')) {
        words.add('readOnly');
        doneNode.add('ignorePointer');
      }
    }
    if (readMap(n['draggable']) case final Json d when d['group'] is String && RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(d['group']! as String)) {
      final data = d['data'];
      final carried = data == null ? '' : _expression(data);
      if (d.keys.every((k) => k == 'group' || k == 'data') && carried != null) {
        words.add('drag=${d['group']}${carried.isEmpty ? '' : '(${carried.substring(1, carried.length - 1)})'}');
        doneNode.add('draggable');
      }
    }
    if (readMap(n['dropTarget']) case final Json d when d.length == 1) {
      final accepts = readList(d['accepts']);
      if (accepts != null && accepts.isNotEmpty && accepts.every((g) => g is String && RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(g))) {
        words.add('drop=${accepts.join(',')}');
        doneNode.add('dropTarget');
      }
    }
    if (!_names) return;
    // Every other field of the node and its behaviors by its own name.
    for (final f in [...NodeFields.all, ...BehaviorFields.all]) {
      final k = f.key;
      if (doneNode.contains(k) || _notFields.contains(k) || !n.containsKey(k) || _equal(n[k], probe[k])) continue;
      if (_value(n[k], _vars) case final String w) words.add('$k=$w');
    }
  }

  // --- bindings --------------------------------------------------------------

  void _bindings() {
    for (final e in bind.entries) {
      final path = e.key, v = e.value;
      if (doneBind.contains(path)) continue;
      // `selected={…}` is always a formula (`{done}` is `${= done}`).
      final exp = path == 'selected' ? _formulaOf(v) : _expression(v);
      final key = _bindKey(path, v);
      if (key == null) continue;
      final written = exp ?? (v is String && _templates(path, key, v) ? _quoted(v) : null);
      if (written != null) words.add('$key=$written');
    }
  }

  /// Whether [v], bound to [path], is a text with values in it that
  /// `key="…{x}…"` binds: a prop's, where the parser binds such a text,
  /// and text around its values (a value alone is `key={…}`).
  bool _templates(String path, String key, String v) {
    if (!path.startsWith('props.') || path.startsWith('props.style.') || (type == 'text' && path == 'props.text')) return false;
    if (v.startsWith(r'${') && _close(v, 1) == v.length - 1) return false;
    const probe = r'${__b} x';
    return _probes.says(head, '$key="{__b} x"', 'text:$path', (node) => readMap(node['bind'])?[path] == probe);
  }

  /// The key that binds [path] (`fill` for the first fill's color, `color`
  /// for a text's style's, a prop by its name); null for one with none.
  String? _bindKey(String path, Object? v) {
    switch (path) {
      case 'visible' || 'opacity':
        return path;
      case 'data' || 'disabled':
        return null; // an each (print.dart), and the inverse of enabled=
      case 'selected':
        if (_hasProp('selected') || const {'chip', 'checkbox', 'switch'}.contains(type)) return null;
        // On a box, `selected=` also draws it in the theme's selected fill.
        final box = const {'row', 'column', 'stack'}.contains(type);
        final fillsBound = bind.keys.any((k) => k.startsWith('decoration.fills'));
        final look = {
          id: {
            'decoration': {
              'fills': [
                {'color': c.options.selectedFill},
              ],
            },
          },
        };
        // …in place of every state look the node has.
        return !box || fillsBound || _equal(n['states'], {'selected': look}) ? 'selected' : null;
      case 'layout.width':
        return 'w';
      case 'layout.height':
        return 'h';
      case 'layout.padding':
        return 'pad';
      case 'layout.flex':
        return 'grow';
      case 'layout.x' || 'layout.y' || 'layout.margin':
        return path.substring(7);
      case 'decoration.radius' || 'decoration.strokeWidth' || 'decoration.effects':
        return path.substring(11);
    }
    if (path.startsWith('props.')) {
      final p = path.substring(6);
      if (p.startsWith('style.') && !p.substring(6).contains('.')) {
        final f = p.substring(6);
        if (type == 'text' && _textWords[f] != null) return _textWords[f];
        if (type == 'textField' && _fieldBound[f] != null) return _fieldBound[f];
        if ((type == 'filledButton' || type == 'elevatedButton') && f == 'backgroundColor') return 'color';
        if ((type == 'outlinedButton' || type == 'textButton') && f == 'foregroundColor') return 'color';
        if (type == 'iconButton' && (f == 'iconColor' || f == 'iconSize')) return f == 'iconColor' ? 'color' : 'size';
      }
      if (type == 'textField' && p.startsWith('decoration.') && _fieldDecoration[p.substring(11)] != null) return _fieldDecoration[p.substring(11)];
      if (!p.contains('.') && !p.contains('[') && _hasProp(p)) {
        final key = p == 'spacing' && type != 'gridView' ? 'gap' : p;
        const probeV = r'${__b}';
        if (_probes.says(head, '$key={__b}', 'bind:$p', (node) => readMap(node['bind'])?[path] == probeV)) return key;
        return null;
      }
      // A field inside a prop, by its path from the props (design 22, 2.1).
      return _names ? p : null;
    }
    if (!_names) return null;
    // Any other path: a layout or decoration field by its own name, else
    // the whole path (design 22, 2.1).
    final at = path.indexOf('.');
    final rest = at < 0 ? path : path.substring(at + 1);
    if ((path.startsWith('layout.') || path.startsWith('decoration.')) && _name.hasMatch(rest) && !rest.contains('.')) return rest;
    return path;
  }
}
