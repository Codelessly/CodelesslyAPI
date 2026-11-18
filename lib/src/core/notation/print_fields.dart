// A node's line in the notation, for printNotation (print.dart): the words
// for its type, text, props, layout, decoration, node fields and bindings.
//
// What a word says is what the parser reads, so the parser is the table: the
// word for a type, whether a variant or a short name is plain, what a line
// gives with nothing written and whether `key=value` reads back as that prop
// are found by reading short lines ([_Probes]), not kept here a second time.
// The sizes a line is given by its parent follow the parser's one rule per
// parent (design 13, section 3), read from the document. Every field the
// words leave different is then written by its key (keys.dart: the shortest
// key that means its path, design 22 section 2.1), checked by reading the
// line under its parent's. What is still unsaid or said wrongly, printNotation
// adds as the line's `{…}` tail.
import 'dart:convert';

import '../behavior_fields.dart' show BehaviorFields;
import '../behaviors.dart' show diffPatch;
import '../catalog.dart';
import '../json.dart';
import '../props.dart';
import '../value_fields.dart' show NodeFields;
import 'keys.dart';
import 'notation.dart';
import 'print_events.dart';
import 'print_media.dart';
import 'print_paint.dart';
import 'print_states.dart';
import 'vocabulary.dart' show LinePart, LineParts;

/// What a line is printed with: the whole document (a node's parent, its
/// variables), the catalog its types come from and the options the print is
/// parsed back with.
final class PrintContext {
  PrintContext({required this.document, required this.catalog, required this.options});

  final Json document;
  final Catalog catalog;
  final NotationOptions options;

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

  /// The key that means [path] on [type] (keys.dart's shortest), or null
  /// when none reads back as it.
  String? _keyFor(String path, String type) {
    final at = '$type\u0000$path', keys = _probes.keys;
    if (keys.containsKey(at)) return keys[at];
    final key = notationKeyFor(path, type, catalog: catalog);
    return keys[at] = notationKeyPath(key, type, catalog: catalog) == path ? key : null;
  }

  /// The parent of node [id] by its id, as the document holds it.
  String? _parentId(String id) => _parents[id];

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
  final all = [...line.words];
  for (final words in [printStates(id, n, context), printEvents(id, n, context), printMedia(id, n, context), printPaint(id, n, context)]) {
    for (final w in words) {
      // A word the line already says (a chart's list by its name) once.
      if (!line.words.contains(w)) all.add(w);
    }
  }
  final b = StringBuffer(line.head)..write('#$id');
  for (final w in _onceEach(all, '${n['type']}', context.catalog)) {
    b.write(' $w');
  }
  return b.toString();
}

/// What a line's marks say (design 13, section 3.1): the [word] written
/// (`@vol`, `@lo @hi`, `@row.done`, `@v direction=@dir`), the [paths] it
/// binds (a binding's, or a design system control's variable parameter,
/// `props.value`), and the [index] of the reaction it writes in the node's
/// `actions` (-1: none, as on a design system's control).
typedef PrintedBind = ({String word, int index, List<String> paths});

/// The reaction of node [n] that its line's `@name` writes (a control's
/// value kept in a variable: the binding and the `changed` reaction that
/// stores it, design 13 section 3.1), as its index in `n['actions']`; null
/// when the line writes no mark, or one that writes no reaction. The events'
/// words leave that reaction out.
int? printedBindReaction(String id, Json n, PrintContext context) => switch (context._line(id, n).twoWay?.index) {
      final int i when i >= 0 => i,
      _ => null,
    };

/// The print's lines (each node's [id], its text to [get] and [set]) after
/// the words for what each still differs in where it is: [parsed] is the
/// print read, [read] reads it again. A line written alone is read under
/// its parent's ([printNodeLine]); where the print puts it (under an `each`,
/// in a grid, in a page) it may read otherwise. Each line's fields are
/// written by their keys again against what it gives there, and kept where
/// its node is closer to the document's. Returns the print read last.
Json printFieldsRefine(Json parsed, List<({String id, String Function() get, void Function(String) set})> lines, Json Function() read, PrintContext context) {
  for (var round = 0; round < 3; round++) {
    final got = readMap(parsed['nodes']) ?? const {};
    final before = <int, String>{};
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i], want = readMap(context.nodes[l.id]), now = readMap(got[l.id]);
      if (want == null || now == null) continue;
      final more = context._line(l.id, want)._more(now, l.get());
      if (more.isEmpty) continue;
      before[i] = l.get();
      l.set(_joinOnce(l.get(), more, '${want['type']}', context.catalog));
    }
    if (before.isEmpty) break;
    final next = read();
    final after = readMap(next['nodes']) ?? const {};
    var kept = 0;
    for (final e in before.entries) {
      final l = lines[e.key], line = context._lines[l.id]!;
      final now = readMap(after[l.id]);
      if (now != null && _NodeLine._better(line._score(now), line._score(readMap(got[l.id])!))) {
        kept++;
      } else {
        l.set(e.value);
      }
    }
    if (kept == 0) break;
    parsed = kept == before.length ? next : read();
  }
  return parsed;
}

final _keyed = RegExp(r'^([A-Za-z_][A-Za-z0-9_.\[\]]*)=(.*)$', dotAll: true);

/// A key is written once on a line (design 13: a key written twice is an
/// issue, one of the two lost). Of a field's value and a binding of it
/// (`radius=8 radius={…}`), the value is written by the field's path
/// (`decoration.radius=8`) where that is another key that reads it, else
/// left to the line's tail. [words] in that form.
List<String> _onceEach(List<String> words, String type, Catalog catalog) {
  final out = [...words];
  for (var j = out.length - 1; j > 0; j--) {
    final b = _keyed.firstMatch(out[j]);
    if (b == null) continue;
    for (var i = 0; i < j; i++) {
      final a = _keyed.firstMatch(out[i]);
      if (a == null || a[1] != b[1]) continue;
      final aBound = a[2]!.startsWith('{'), bBound = b[2]!.startsWith('{');
      if (aBound == bBound) break;
      final (at, value) = aBound ? (j, b) : (i, a);
      final path = _valuePath(value[1]!, type, catalog);
      if (path != null) {
        out[at] = '$path=${value[2]}';
      } else {
        out.removeAt(at);
      }
      break;
    }
  }
  return out;
}

/// Another key that means [key]'s field on [type] (its path, `layout.height`
/// for `h`), or null.
String? _valuePath(String key, String type, Catalog catalog) {
  final path = notationKeyPath(key, type, catalog: catalog);
  return path != null && path != key && notationKeyPath(path, type, catalog: catalog) == path ? path : null;
}

/// [line] with [more] after it, each key once ([_onceEach]): a word of
/// [more] whose key the line has already is written by its path, or the
/// line's own value of it is.
String _joinOnce(String line, List<String> more, String type, Catalog catalog) {
  var text = line;
  final add = <String>[];
  for (final w in more) {
    final b = _keyed.firstMatch(w);
    final parts = b == null ? null : LineParts.of(text.trimLeft());
    final indent = text.length - text.trimLeft().length;
    LinePart? had;
    for (final p in parts?.parts ?? const <LinePart>[]) {
      final a = p.kind == 'pair' || p.kind == 'word' ? _keyed.firstMatch(p.raw) : null;
      if (a != null && a[1] == b![1]) had = p;
    }
    if (b == null || had == null || had.at < 0) {
      add.add(w);
      continue;
    }
    final a = _keyed.firstMatch(had.raw)!;
    final aBound = a[2]!.startsWith('{'), bBound = b[2]!.startsWith('{');
    if (aBound == bBound) {
      add.add(w);
      continue;
    }
    final path = _valuePath(b[1]!, type, catalog);
    if (aBound) {
      // The word added is the value.
      if (path != null) add.add('$path=${b[2]}');
    } else {
      // The line's own word is the value.
      final start = indent + had.at;
      final end = start + had.raw.length;
      text = path == null ? '${text.substring(0, start).trimRight()}${text.substring(end)}' : '${text.substring(0, start)}$path=${a[2]}${text.substring(end)}';
      add.add(w);
    }
  }
  return add.isEmpty ? text : '$text ${add.join(' ')}';
}

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
final _name = RegExp(r'^[A-Za-z_](?:[A-Za-z0-9_.]|\[[0-9]+\])*$');

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
      if (s.contains('{') || s.contains(r'\$')) return _verbatim(s);
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
  // (A `\n` written in it is read as written; a line break is no one line.)
  if (e == null || e.contains('\n')) return null;
  if (RegExp(r'^\s*[A-Za-z_]\w*\s*:\s|^\s+[A-Za-z_]\w*\s+$').hasMatch(e)) return null;
  return e;
}

/// A binding's value as `key={expression}` writes it: `{name}` or
/// `{formula}`; null when it is a text with values in it (or reads back
/// otherwise).
String? _expression(Object? v) {
  if (v is! String || !v.startsWith(r'${') || _close(v, 1) != v.length - 1) return null;
  final e = _braced(v.substring(2, v.length - 1));
  return e == null ? null : '{$e}';
}

/// A binding's value as a key that always reads a formula writes it
/// (`selected={done}` is `${= done}`); null for any other value.
String? _formulaOf(Object? v) {
  if (v is! String || !v.startsWith(r'${=') || _close(v, 1) != v.length - 1) return null;
  final e = v.substring(3, v.length - 1).trim();
  if (e.isEmpty || e.contains('\n')) return null;
  return '{$e}';
}

/// [s] as a quoted string kept as written (design 22, 4.8): a string with
/// the document's formula `${= …}` in it reads back as it is
/// (`"${= theme.colors.ink}"`); null when [s] has none (its `{…}` would be
/// read) or has a `\$`.
String? _verbatim(String s) => _writtenRead.hasMatch(s) && !s.contains(r'\$') ? jsonEncode(s) : null;

final _writtenRead = RegExp(r'(?<!\\)\$\{=');

/// [s], a text that may read values (`Total: ${total}`), as the quoted
/// string that reads back as it (`"Total: {total}"`), else as written
/// ([_verbatim]: `"${= theme.colors.ink}"`); null when none does.
String? _quoted(String s) {
  final parts = <(String, bool)>[]; // (text, is an expression)
  final literal = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == r'$' && i + 1 < s.length && s[i + 1] == '{') {
      final end = _close(s, i + 1);
      final e = end < 0 ? null : _braced(s.substring(i + 2, end));
      // A read braces cannot say: the string as written.
      if (e == null) return _verbatim(s);
      parts
        ..add((literal.toString(), false))
        ..add((e, true));
      literal.clear();
      i = end;
      continue;
    }
    if (c == '{') return _verbatim(s);
    if (c == r'\' && i + 1 < s.length && s[i + 1] == r'$') return null;
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

  /// [PrintContext._keyFor], by type and path.
  final keys = <String, String?>{};

  /// [text] read: its root node, the whole document, and whether it read
  /// with no issue.
  ({Json? node, Json document, bool clean}) read(String text) => _read[text] ??= () {
        final r = parseNotation(text, catalog: catalog, options: options);
        final nodes = readMap(r.document['nodes']) ?? const {};
        final screen = readStrings(r.document['roots']).firstOrNull ?? 'screen';
        final body = readString(readMap(readMap(nodes[screen])?['slots'])?['body']);
        // (A mark the probe binds, `@__v`, is declared by no state line: said, and still read.)
        return (node: readMap(nodes[body]), document: r.document, clean: r.issues.every((i) => _probeMark.hasMatch(i.message)));
      }();

  static final _probeMark = RegExp(r'^@__[vw] binds a variable nothing declares');

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

/// The order a text style's words are written in: the short words
/// (`size weight color fontFamily lineHeight`), then `letterSpacing`, the
/// flags (`italic`, `underline`), then any other field by name, A to Z.
const _styleOrder = ['fontSize', 'fontWeight', 'color', 'fontFamily', 'height', 'letterSpacing', 'fontStyle', 'decoration'];

String _styleRank(String key) {
  final i = _styleOrder.indexOf(key);
  return i < 0 ? '9$key' : '$i';
}

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

  /// The line's marks (`@vol`, `@lo @hi`, `@v direction=@dir`), what they
  /// bind and the reaction they write ([PrintedBind]).
  PrintedBind? twoWay;

  _Probes get _probes => c._probes;
  Set<String> get _vars => c.variableNames;
  Json get _probeProps => readMap(probe['props']) ?? const {};
  bool _hasProp(String key) => spec?.props.any((p) => p.key == key) ?? false;

  /// Whether the line names its type (`Button "Save" type=Button`): a design
  /// system's component whose name a word of the notation has too.
  bool _typed = false;

  /// The head as the parser is asked about it (with `type=` when [_typed]).
  String get _asked => _typed ? '$head type=$type' : head;

  void write() {
    var first = _head();
    if (type[0] != type[0].toLowerCase() && _probes.node(first)['type'] != type && _probes.node('$type type=$type')['type'] == type) {
      _typed = true;
      first = type;
    }
    _writeAs(first);
    // A short name says no more than the type's own word with nothing
    // written; with this line's words it may (`AreaChart` fills under a
    // line chart's series): then the own word.
    final own = _probes.own(type);
    // (The marks are left out: under an each or of a record's field they read only where the line is.)
    if (!_typed && head == _probes.word(type) && head != own && !_probes.sameLine(head, own, words.where((w) => w != twoWay?.word).join(' '))) {
      words.clear();
      doneProps.clear();
      doneBind.clear();
      doneNode.clear();
      _style.clear();
      _writeAs(own);
    }
    _residual();
    _oneKeyEach();
  }

  void _writeAs(String head) {
    this.head = head;
    probe = _probes.node(_asked);
    twoWay = _twoWay() ?? printBind(id, n, head, c);
    for (final path in twoWay?.paths ?? const <String>[]) {
      bind.containsKey(path) ? doneBind.add(path) : doneProps.add(path.substring('props.'.length));
    }
    _main();
    if (_typed) words.add('type=$type');
    _typeWords();
    _layout();
    _decoration();
    _nodeFields();
    if (twoWay case final t?) words.add(t.word);
  }

  void _oneKeyEach() {
    final once = _onceEach(words, type, c.catalog);
    words
      ..clear()
      ..addAll(once);
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
    // In one order whatever the JSON's key order (design 22, 4.8).
    for (final e in style.entries.toList()..sort((a, b) => _styleRank('${a.key}').compareTo(_styleRank('${b.key}')))) {
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
      } else if (_value(v, _vars) case final String value when _keyFor('props.style.$k') != null) {
        // A field of the text's style by its own name (design 22, 2.1).
        out.add('${_keyFor('props.style.$k')}=$value');
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

  /// `@name` (design 13, section 3.1): the control's value bound to a
  /// declared variable and its first reaction the change stored in it, as
  /// the mark writes them; `@low @high` for a control with two ends (a
  /// slider's range, a calendar's days), one change storing both.
  PrintedBind? _twoWay() {
    final actions = readList(n['actions']);
    if (actions == null || actions.isEmpty) return null;
    for (final marks in const [
      ['__v'],
      ['__v', '__w'],
    ]) {
      final r = _probes.line('$_asked ${marks.map((m) => '@$m').join(' ')}');
      final pb = readMap(r.node?['bind']);
      final pa = readList(r.node?['actions']);
      if (!r.clean || pb == null || pb.length != marks.length || pa == null || pa.isEmpty) continue;
      final names = <String, String>{};
      for (final path in pb.keys) {
        final template = '${pb[path]}';
        final mark = marks.where(template.contains).firstOrNull;
        final at = mark == null ? -1 : template.indexOf(mark);
        final value = bind[path];
        if (mark == null || value is! String || !value.startsWith(template.substring(0, at)) || !value.endsWith(template.substring(at + mark.length))) break;
        final name = value.substring(at, value.length - (template.length - at - mark.length));
        if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(name) || !_vars.contains(name)) break;
        names[mark] = name;
      }
      if (names.length != marks.length) continue;
      var written = jsonEncode(pa.first);
      for (final e in names.entries) {
        written = written.replaceAll(e.key, e.value);
      }
      if (!_equal(jsonDecode(written), actions.first)) continue;
      return (word: [for (final m in marks) '@${names[m]}'].join(' '), index: 0, paths: [...pb.keys]);
    }
    return null;
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
    // A box has no text: its string is an Image's url (`_main`), nothing else.
    if (type == 'box') return null;
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
    // Its other fields are written by name (`decoration.isDense=true`).
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
      // Each limit by its own name (`maxWidth=720`, design 22, 2.1).
      for (final e in box.entries) {
        if (e.value is num && notationKeyPath(e.key, type, catalog: c.catalog) == 'layout.constraints.${e.key}') words.add('${e.key}=${jsonEncode(e.value)}');
      }
    }
    // The rest of the layout's fields are written by name (`columnSpan=2`).
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
    // A size bound is 0 unless a number is written beside it (`h=24 h={…}`).
    bool free(String k) => !bind.containsKey('layout.$k') || (layout[k] is num && layout[k] != 0);
    if (!inGrid && free('width') && layout['width'] != null) {
      final w = layout['width'];
      if (!_equal(w, width) || (squeezes && layout['squeezable'] != true)) {
        if (_sizeWord(w) case final String s) words.add('w=$s');
      }
    }
    // A height a rule would change (a spacer's in a column, a column's of a
    // given height with a text under it, which makes it a least height) is
    // written by its full path: that height exactly (design 22, 4.8).
    final h = layout['height'];
    final textUnder = type == 'column' &&
        h is num &&
        h > 0 &&
        props['scrollable'] != true &&
        readStrings(n['children']).any((k) => readMap(c.nodes[k])?['type'] == 'text');
    if (spacer && h != null && !_equal(h, height)) {
      if (_sizeWord(h) case final String s) words.add('layout.height=$s');
    } else if (!spacer && free('height') && h != null && !_equal(h, height)) {
      if (_sizeWord(h) case final String s) words.add(textUnder ? 'layout.height=$s' : 'h=$s');
    }
    // A fit beside a bound size (a bound size alone is 0): by its full path,
    // that size exactly (design 22, 4.8).
    for (final k in const ['width', 'height']) {
      if (bind.containsKey('layout.$k') && layout[k] is Map && !(inGrid && k == 'width')) {
        if (_sizeWord(layout[k]) case final String s) words.add('layout.$k=$s');
      }
    }
    // `squeezable` otherwise is written by name.
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
        if (fillExpression != null && single['color'] != '#00000000') {
          // (`fill=` is the binding's: the color under it is the fill's whole value.)
          if (_json(fills) case final String j) words.add('fills=$j');
        } else if (fillExpression == null) {
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
    if (strokes is List && strokes.isNotEmpty) {
      final single = strokes.length == 1 ? readMap(strokes.single) : null;
      if (single != null && single.length == 1 && single['color'] is String && _says('border')) {
        if (const {'top', 'bottom', 'left', 'right'}.contains(sides) && boundStroke == null) {
          if (_value(single['color'], _vars) case final String w) words.add('border-$sides=$w');
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
    // The other decoration fields are written by name (`strokeSides=topBottom`).
  }

  /// Whether `fill=` (`border=`) on this line is its first fill's (its
  /// border's) color: on a text it is not (a text with a fill is a tag).
  bool _says(String word) {
    final at = word == 'fill' ? 'fills' : 'strokes';
    return _probes.says(_asked, '${type == 'text' ? '"a" ' : ''}$word=#FF0A0B0C', word, (node) => _equal(readMap(node['decoration'])?[at], [
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
      if (_probes.says(_asked, 'readOnly', 'readOnly', (node) => node['ignorePointer'] == true && diffPatch(probe, node)?.keys.join() == 'ignorePointer')) {
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
    // Every other field of the node and its behaviors is written by name.
  }

  // --- every other field, by its key -----------------------------------------

  /// The node keys the other families write (events, media, states, paint and
  /// motion) or that are the tree itself: no field of this line's.
  static const _others = {'type', 'id', 'children', 'slots', 'actions', 'media', 'states', 'animations', 'transitions', 'customPaint'};

  /// …and of those, the keys a line's read is not compared on (what this
  /// line's words never give: its lines under it, its events, its rules).
  static const _unread = {'children', 'slots', 'actions', 'media', 'animations', 'transitions', 'customPaint'};

  /// The key that means [path] on this line's type, or null.
  String? _keyFor(String path) => c._keyFor(path, type);

  /// Every field the words written so far leave other than the document has
  /// it, written by its key (design 22, 2.1 and 2.5): `crossAxisAlignment=null`
  /// for one the line gives that the node has not, `squeezable=true`,
  /// `strokeSides=topBottom`, `style.letterSpacing=0.4`, `visible={…}`. Each
  /// is checked by reading the line under its parent's, and kept where it
  /// leaves fewer fields other than the node has them.
  void _residual() {
    final parent = _parentLine();
    final said = printPaintSays(id, n, c);
    // The bindings first: a size bound is 0 whatever is written before it.
    for (final binds in [true, false]) {
      _settle(parent, (got) => _candidates(got, said, binds: binds));
    }
  }

  /// [_residual]'s one pass: the [candidates] for what the line read under
  /// [parent] still differs in, all at once or one field at a time, again
  /// while that settles more (a word may make the line give a field the
  /// node has not: the next round writes it out).
  void _settle(String? parent, List<({String target, List<List<String>> forms})> Function(Json got) candidates) {
    Json? read(List<String> extra) => _readUnder(parent, [...words, ...extra]);
    var got = read(const []);
    if (got == null) return;
    var kept = <String>[];
    var score = _score(got);
    for (var round = 0; round < 4 && score.fields.isNotEmpty; round++) {
      final slots = candidates(got!);
      if (slots.isEmpty) break;
      var progressed = false;
      final all = [...kept, for (final s in slots) ...s.forms.first];
      final both = read(all);
      if (both != null && _better(_score(both), score)) {
        kept = all;
        got = both;
        score = _score(both);
        continue;
      }
      for (final s in slots) {
        for (final form in s.forms) {
          final next = read([...kept, ...form]);
          if (next == null || !_better(_score(next), score)) continue;
          kept = [...kept, ...form];
          got = next;
          score = _score(next);
          progressed = true;
          break;
        }
      }
      if (!progressed) break;
    }
    words.addAll(kept);
  }

  /// What [got] differs from the node in: the fields (`props.style`,
  /// `bind.visible`, `states.hovered.row`) and the number of leaves.
  ({Set<String> fields, int leaves}) _score(Json got) {
    final leaves = _differ(got);
    String field(String leaf) {
      final parts = leaf.split('.');
      final take = switch (parts.first) { 'props' || 'layout' || 'decoration' => 2, 'states' => 3, _ => 1 };
      if (parts.first == 'bind') return leaf;
      return parts.take(take).join('.').replaceFirst(RegExp(r'\[.*$'), '');
    }

    return (fields: {for (final l in leaves) field(l)}, leaves: leaves.length);
  }

  /// Whether [a] is closer to the node than [b]: fewer fields other, or no
  /// field more and fewer leaves.
  static bool _better(({Set<String> fields, int leaves}) a, ({Set<String> fields, int leaves}) b) =>
      a.fields.length < b.fields.length || (a.fields.difference(b.fields).isEmpty && a.leaves < b.leaves);

  /// The words for what [got] (this line read where the print puts it,
  /// [text] as written there) still differs in: each field's first form,
  /// none already on the line; a field its binding sets is the binding's.
  List<String> _more(Json got, String text) {
    final said = printPaintSays(id, n, c);
    final binds = _candidates(got, said, binds: true);
    final fields = [
      for (final s in _candidates(got, said, binds: false))
        if (!binds.any((b) => b.target == 'bind.${s.target}')) s,
    ];
    return [
      for (final s in [...binds, ...fields])
        for (final w in s.forms.first)
          if (!text.contains(' $w')) w,
    ];
  }

  /// The parent's line as its words write it (`Row#bar gap=8 middle`), what
  /// this line is read under; null for the root of a page or a component.
  String? _parentLine() {
    final pid = c._parentId(id);
    final p = pid == null ? null : readMap(c.nodes[pid]);
    if (pid == null || p == null || p['type'] == 'canvas') return null;
    final line = c._line(pid, p);
    return ['${line.head}#$pid', ...line.words].join(' ');
  }

  /// This line with [written] read under [parent] (or alone): the node it
  /// gives, or null when the line does not read as this node.
  Json? _readUnder(String? parent, List<String> written) {
    // Its states as they are (the states' words are another family's): what
    // a word adds to them is seen.
    final states = n['states'] == null ? null : jsonEncode({'states': n['states']});
    final self = ['$head#$id', ...written, ?states].join(' ');
    try {
      final r = parseNotation(parent == null ? self : '$parent\n  $self', catalog: c.catalog, options: c.options);
      return readMap(readMap(r.document['nodes'])?[id]);
    } on Object {
      return null;
    }
  }

  /// The leaves (`props.style.color`, `bind.visible`, `layout.width`) where
  /// [got] is not the document's node.
  Set<String> _differ(Json got) {
    final out = <String>{};
    void walk(Object? a, Object? b, String at) {
      if (a is Map && b is Map) {
        for (final k in {...a.keys, ...b.keys}) {
          if (at.isEmpty && _unread.contains(k)) continue;
          final path = at.isEmpty ? '$k' : '$at.$k';
          // A field there as null is not a field not there; a map on one
          // side only is each of its fields.
          if (a.containsKey(k) != b.containsKey(k)) {
            final there = a.containsKey(k) ? a[k] : b[k];
            if (there is Map && there.isNotEmpty) {
              walk(a[k] ?? const {}, b[k] ?? const {}, path);
            } else {
              out.add(path);
            }
          } else {
            walk(a[k], b[k], path);
          }
        }
      } else if (!_equal(a, b)) {
        out.add(at);
      }
    }

    walk(got, n, '');
    return out;
  }

  /// What may write each field this line's read leaves other than the node
  /// has it: per field, its forms in the order they are tried (its parts by
  /// their keys, then the whole value).
  List<({String target, List<List<String>> forms})> _candidates(Json got, Set<String> said, {required bool binds}) {
    final out = <({String target, List<List<String>> forms})>[];
    if (binds) {
      final given = readMap(got['bind']) ?? const {};
      for (final e in bind.entries) {
        final path = e.key;
        if ((twoWay?.paths.contains(path) ?? false) || said.contains('bind.$path') || _equal(given[path], e.value)) continue;
        final forms = [
          for (final w in _bindWords(path, e.value)) [w],
        ];
        if (forms.isNotEmpty) out.add((target: 'bind.$path', forms: forms));
      }
      return out;
    }
    // `props=null` (no props at all), `props={}` (an empty record of them):
    // the section whole, where the line gives another (design 22, 4.8).
    for (final section in const ['props', 'decoration']) {
      if (said.contains(section)) continue;
      final g = got[section], w = n[section];
      // (Where each field has a key, `key=null` says it: `Row crossAxisAlignment=null`.)
      final unkeyed = g is Map && g.keys.any((k) => _keyFor('$section.$k') == null);
      if (!n.containsKey(section) && g is Map && unkeyed) {
        out.add((target: section, forms: [
          ['$section=null'],
        ]));
      } else if (w is Map && w.isEmpty && !(g is Map && g.isEmpty)) {
        out.add((target: section, forms: [
          ['$section={}'],
        ]));
      }
    }
    for (final section in const ['layout', 'decoration', 'props']) {
      final g = readMap(got[section]) ?? const {}, w = readMap(n[section]) ?? const {};
      for (final k in {...g.keys, ...w.keys}) {
        final path = '$section.$k';
        if (said.contains(path) || said.contains(section)) continue;
        final forms = _forms(path, g[k], w[k]);
        if (forms.isNotEmpty) out.add((target: path, forms: forms));
      }
    }
    for (final f in [...NodeFields.all, ...BehaviorFields.all]) {
      final k = f.key;
      if (_others.contains(k) || said.contains(k) || printStatesKeys.contains(k)) continue;
      final forms = _forms(k, got[k], n[k]);
      if (forms.isNotEmpty) out.add((target: k, forms: forms));
    }
    return out;
  }

  /// The forms that write [want] at [path] where the line gives [got]:
  /// `key=null` for a field the node has not; a record's or a list's parts
  /// that differ by their own keys (`style.letterSpacing=0.4`,
  /// `fills[0].color=…`), then the whole (`style={…}`); a value by its key.
  List<List<String>> _forms(String path, Object? got, Object? want) {
    if (_equal(got, want)) return const [];
    final key = _keyFor(path);
    final whole = key == null
        ? null
        : want == null
            ? '$key=null'
            : switch (_value(want, _vars)) { final String v => '$key=$v', _ => null };
    final declared = notationKey(path, type, catalog: c.catalog)?.type;
    final parts = <String>[];
    var split = false;
    if (want is Map && got is Map && declared != null && declared.kind == PropKind.object && declared.fields.isNotEmpty) {
      split = true;
      for (final k in {...got.keys, ...want.keys}) {
        final inner = _forms('$path.$k', got[k], want[k]);
        if (inner.isEmpty) continue;
        parts.addAll(inner.first);
      }
    } else if (want is List && got is List && want.length == got.length && declared?.kind == PropKind.list) {
      split = true;
      for (var i = 0; i < want.length; i++) {
        final inner = _forms('$path[$i]', got[i], want[i]);
        if (inner.isEmpty) continue;
        parts.addAll(inner.first);
      }
    }
    // The full path, which always reads, where the short key is a word the
    // line reads otherwise (`props.size=48` on an Avatar).
    final full = const {'props', 'layout', 'decoration'}.contains(path.split(RegExp(r'[.\[]')).first) ? path : 'node.$path';
    final fullWord = full == key || notationKeyPath(full, type, catalog: c.catalog) != path
        ? null
        : want == null
            ? '$full=null'
            : switch (_value(want, _vars)) { final String v => '$full=$v', _ => null };
    return [
      if (split && parts.isNotEmpty) parts,
      if (whole != null) [whole],
      if (fullWord != null) [fullWord],
    ];
  }

  /// The words that bind [path] to [v]: `key={expression}`, `key="…{x}…"`
  /// for a text with values in it; `selected={…}` always reads a formula.
  List<String> _bindWords(String path, Object? v) {
    if (path == 'disabled') {
      // `enabled={x}` is disabled `${= !x}` (`!(x)` for more than a name).
      // `node.disabled={…}`, the state as bound (design 22, 4.8), where
      // `enabled=` is the type's own prop.
      final node = switch (v) {
        final String s => switch (_expression(s) ?? _quoted(s)) { final String w => 'node.disabled=$w', _ => null },
        _ => null,
      };
      final own = _hasProp('enabled') || _hasProp('isEnabled') || _hasProp('disabled');
      final e = v is String && v.startsWith(r'${= !') && _close(v, 1) == v.length - 1 ? v.substring(5, v.length - 1).trim() : null;
      final inner = e == null
          ? null
          : e.startsWith('(') && e.endsWith(')') && _close(e.replaceAll('(', '{').replaceAll(')', '}'), 0) == e.length - 1
              ? e.substring(1, e.length - 1)
              : e;
      return [
        if (!own && inner != null && !inner.contains('\n')) 'enabled={$inner}',
        if (node != null) node,
      ];
    }
    final key = _bindKey(path);
    if (key == null || v is! String) return const [];
    final expression = path == 'selected' ? _formulaOf(v) : _expression(v);
    final text = _quoted(v);
    final verbatim = _verbatim(v);
    return {
      if (expression != null) '$key=$expression',
      if (text != null && text != '"$expression"') '$key=$text',
      // The binding as written (design 22, 4.8); a field that holds its
      // expression as written (a text's text, a validator) is bound by the
      // quoted string in braces.
      if (verbatim != null) '$key=$verbatim',
      if (text != null && expression == null) '$key={$text}',
      if (verbatim != null) '$key={$verbatim}',
    }.toList();
  }

  /// The key that binds [path] (`fill` for the first fill's color, `color`
  /// for a text's style's, `data` for a list's data, a field by its key);
  /// null for one with none.
  String? _bindKey(String path) {
    switch (path) {
      case 'data':
        return path;
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
        return !box || fillsBound || _equal(n['states'], {'selected': look}) || printStatesSelected(n) ? 'selected' : null;
    }
    if (path.startsWith('props.style.') && !path.substring(12).contains('.')) {
      final f = path.substring(12);
      if (type == 'text' && _textWords[f] != null) return _textWords[f];
      if (type == 'textField' && _fieldBound[f] != null) return _fieldBound[f];
      if ((type == 'filledButton' || type == 'elevatedButton') && f == 'backgroundColor') return 'color';
      if ((type == 'outlinedButton' || type == 'textButton') && f == 'foregroundColor') return 'color';
      if (type == 'iconButton' && (f == 'iconColor' || f == 'iconSize')) return f == 'iconColor' ? 'color' : 'size';
    }
    if (path == 'decoration.fills[0].color') return 'fill';
    if (path == 'decoration.strokes[0].color') return 'border';
    // A word of the notation that sets more where it is written as a value
    // binds its one path (`strokeWidth={…}`).
    if (path == 'decoration.strokeWidth') return 'strokeWidth';
    return _keyFor(path);
  }
}
