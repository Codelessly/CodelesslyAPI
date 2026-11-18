// The closure test of track B (step B2, docs/design/23-base-and-dictionary.md):
// a word the expander writes out in Dart code (App, Sidebar, NavItem, Table…)
// written instead as a definition in the notation's own `define` form
// (docs/design/20-defined-words.md), and the two expansions compared node by
// node.
//
// The expander's built-in words win over a definition of the same name (the
// owner's decision of 2026-11-18, notationBuiltInWord), so a definition is
// tested under a name of its own: the word with `Dict` after it
// ([dictName]), in the definition's signature and in the uses, and nothing
// in the expander is changed.
//
// Shared by tool/dictionary_closure.dart (the report), the test
// (test/notation_dictionary_test.dart) and tool/vocabulary_inventory.dart.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';

typedef Json = Map<String, Object?>;

/// The words of the page frames, renamed together as one family: each reads
/// the frame it is in, so a word renamed alone changes its children too.
const frameFamily = {'App', 'Page', 'Section', 'Footer', 'Nav', 'Sidebar', 'Main', 'Pane', 'NavItem', 'NavSection', 'Brand', 'Heading', 'Link', 'IconTile'};

/// The uses of [word] the dictionary has: `dictionary/uses/<word>.txt` (taken
/// from the corpora) and `<word>.extra.txt` (written for a shape they lack).
List<({String from, String text})> usesOf(String word, {String dir = 'dictionary/uses'}) => [
      for (final suffix in const ['.txt', '.extra.txt'])
        if (File('$dir/$word$suffix') case final f when f.existsSync()) ...readUses(f.readAsStringSync()),
    ];

/// What is wrong in the dictionary's definitions, read together.
List<String> readDefinitionsProblems(Iterable<DictionaryFile> files) => readDefinitions({for (final f in files) f.name: f.text}).problems;

/// The name a dictionary word is tested under: a built-in word wins over a
/// definition of its own name.
String dictName(String word) => '${word}Dict';

/// The page [text] expanded as a site page is (open vocabulary, so that a
/// word no definition has stands in the same way on both sides), at [width].
Json expandPage(String text, {double width = 1440, Map<String, String> definitions = const {}, NotationOptions? base}) {
  var options = base ?? NotationOptions(width: width);
  options = options.open();
  if (definitions.isNotEmpty) options = options.define(definitions);
  return Catalog.run(standardCatalog, () => parseNotation(text, options: options).document);
}

/// The issues of the page [text] with [definitions] (a definition's own
/// problems are said against its file).
List<String> pageIssues(String text, {double width = 1440, Map<String, String> definitions = const {}}) {
  var options = NotationOptions(width: width).open();
  if (definitions.isNotEmpty) options = options.define(definitions);
  return Catalog.run(standardCatalog, () => [for (final i in parseNotation(text, options: options).issues) '$i']);
}

/// One dictionary file: its words (the signatures at its margin) and its text.
final class DictionaryFile {
  /// A file whose definitions are all refused is still its word's (its file
  /// name): its uses are tested, and fail as the refusal says.
  DictionaryFile(this.name, this.text)
      : words = {
          ...readDefinitions({name: text}).words.keys,
        }.ifEmpty(name.replaceAll(RegExp(r'\.txt$'), ''));

  final String name, text;
  final Set<String> words;
}

extension on Set<String> {
  Set<String> ifEmpty(String word) => isEmpty ? {word} : this;
}

/// The definitions of [dir] (`*.txt`), by file name.
Map<String, DictionaryFile> readDictionary(String dir) => {
      for (final f in (Directory(dir).listSync().whereType<File>().where((f) => f.path.endsWith('.txt')).toList()..sort((a, b) => a.path.compareTo(b.path))))
        f.uri.pathSegments.last: DictionaryFile(f.uri.pathSegments.last, f.readAsStringSync().replaceAll('\r\n', '\n')),
    };

/// [text] with each of [words] written as a line's first word (a use, or a
/// definition's signature or body line) renamed to its [dictName].
String renameWords(String text, Set<String> words) {
  if (words.isEmpty) return text;
  final alt = (words.toList()..sort((a, b) => b.length.compareTo(a.length))).map(RegExp.escape).join('|');
  final head = RegExp('^(\\s*(?:define\\s+|primitive\\s+)?)($alt)(?=[\\s.#]|\$)', multiLine: true);
  return text.replaceAllMapped(head, (m) => '${m[1]}${dictName(m[2]!)}');
}

/// The definitions of [files], each renamed ([renameWords]) for the words
/// [words] (every word of the dictionary under test, so that one definition
/// using another reads the renamed one), by file name (renamed too).
Map<String, String> renamedDefinitions(Iterable<DictionaryFile> files, Set<String> words) => {
      for (final f in files) f.name.replaceAllMapped(RegExp(r'^([A-Za-z0-9]+)\.txt$'), (m) => '${words.contains(m[1]) ? dictName(m[1]!) : m[1]}.txt'): renameWords(f.text, words),
    };

/// [doc] with every node id replaced by its place in the tree (`r0` a root,
/// `r0.2` its third child, `r0.body` what its slot `body` holds), everywhere
/// it is written: as a value, and inside a text (an expression, a variable
/// named after the node) where it stands as a name. Two expansions that
/// differ only in their generated ids are then equal, and a node one of them
/// has more moves only its later siblings' names.
///
/// With [spelling], an expression (`${= …}`) is also written without the
/// spaces outside its strings and without parentheses around the whole of
/// it: `(tab=="home")` and `tab == "home"` are one expression.
Json canonical(Json doc, {bool spelling = false}) {
  final nodes = (doc['nodes'] as Map?)?.cast<String, Object?>() ?? const {};
  final names = <String, String>{};
  void visit(String id, String name) {
    if (names.containsKey(id)) return;
    names[id] = name;
    final n = nodes[id];
    if (n is! Map) return;
    var i = 0;
    for (final c in (n['children'] as List?) ?? const []) {
      if (c is String) visit(c, '$name.${i++}');
    }
    final slots = (n['slots'] as Map?)?.cast<String, Object?>() ?? const {};
    for (final k in slots.keys.toList()..sort()) {
      final s = slots[k];
      if (s is String) visit(s, '$name.$k');
      if (s is List) {
        var j = 0;
        for (final x in s) {
          if (x is String) visit(x, '$name.$k${j++}');
        }
      }
    }
  }

  var r = 0;
  for (final root in (doc['roots'] as List?) ?? const []) {
    if (root is String) visit(root, 'r${r++}');
  }
  for (final id in nodes.keys.toList()..sort()) {
    visit(id, 'x:$id');
  }
  final byLength = names.keys.where((k) => k.length >= 3).toList()..sort((a, b) => b.length.compareTo(a.length));
  final inText = byLength.isEmpty ? null : RegExp('(?<![A-Za-z0-9_])(${byLength.map(RegExp.escape).join('|')})(?![0-9])');
  String spelt(String s) => spelling ? s.replaceAllMapped(RegExp(r'\$\{=\s*([\s\S]*)\}$'), (m) => '\${= ${_plainExpression(m[1]!)}}') : s;
  Object? walk(Object? v) => switch (v) {
        final String s when names.containsKey(s) => names[s],
        final String s when inText != null => spelt(s.replaceAllMapped(inText, (m) => names[m[1]]!)),
        final String s => spelt(s),
        // Keys in order: the order a map was filled in is not a difference.
        final Map m => Map.fromEntries([
            for (final e in m.entries)
              MapEntry(names[e.key] ?? (inText == null ? '${e.key}' : '${e.key}'.replaceAllMapped(inText, (x) => names[x[1]]!)), walk(e.value)),
          ]..sort((a, b) => a.key.compareTo(b.key))),
        final List l => [for (final x in l) walk(x)],
        _ => v,
      };
  return (walk(doc)! as Map).cast<String, Object?>();
}

/// [e] without the spaces outside its strings, and without parentheses
/// around the whole of it.
String _plainExpression(String e) {
  final out = StringBuffer();
  String? quote;
  for (var i = 0; i < e.length; i++) {
    final c = e[i];
    if (quote != null) {
      out.write(c);
      if (c == r'\' && i + 1 < e.length) {
        out.write(e[++i]);
      } else if (c == quote) {
        quote = null;
      }
      continue;
    }
    if (c == '"' || c == "'") quote = c;
    if (c.trim().isEmpty) continue;
    out.write(c);
  }
  var s = out.toString();
  bool wraps(String t) {
    if (!t.startsWith('(') || !t.endsWith(')')) return false;
    var depth = 0;
    for (var i = 0; i < t.length; i++) {
      if (t[i] == '(') depth++;
      if (t[i] == ')' && --depth == 0 && i < t.length - 1) return false;
    }
    return true;
  }

  while (wraps(s)) {
    s = s.substring(1, s.length - 1);
  }
  return s;
}

/// Two documents compared node by node, after [canonical] (with
/// [spelling]: expressions compared as [_plainExpression]s).
final class Comparison {
  Comparison(Json a, Json b, {this.spelling = false}) {
    final ca = canonical(a, spelling: spelling), cb = canonical(b, spelling: spelling);
    final na = (ca['nodes'] as Map).cast<String, Object?>(), nb = (cb['nodes'] as Map).cast<String, Object?>();
    nodesA = na.length;
    nodesB = nb.length;
    for (final k in {...na.keys, ...nb.keys}) {
      if (!na.containsKey(k)) {
        onlyB.add(k);
      } else if (!nb.containsKey(k)) {
        onlyA.add(k);
      } else if (jsonEncode(na[k]) != jsonEncode(nb[k])) {
        differing.add(k);
        if (samples.length < 6) samples.add(_diff(k, na[k], nb[k]));
      }
    }
    for (final k in {...ca.keys, ...cb.keys}) {
      if (k == 'nodes') continue;
      if (jsonEncode(ca[k]) != jsonEncode(cb[k])) {
        other.add(k);
        if (samples.length < 6) samples.add(_diff(k, ca[k], cb[k]));
      }
    }
    if (onlyA.isNotEmpty && samples.length < 6) samples.add('only in the code\'s: ${onlyA.take(4).map((k) => '$k ${_type(na[k])}').join(', ')}');
    if (onlyB.isNotEmpty && samples.length < 6) samples.add('only in the definition\'s: ${onlyB.take(4).map((k) => '$k ${_type(nb[k])}').join(', ')}');
  }

  final bool spelling;
  int nodesA = 0, nodesB = 0;
  final onlyA = <String>[], onlyB = <String>[], differing = <String>[], other = <String>[];
  final samples = <String>[];

  bool get equal => onlyA.isEmpty && onlyB.isEmpty && differing.isEmpty && other.isEmpty;

  /// Nodes the same in both, of the code's.
  int get same => nodesA - onlyA.length - differing.length;

  static String _type(Object? n) => n is Map ? '${n['type']}' : '';

  /// The first paths at which [a] and [b] differ under [key].
  static String _diff(String key, Object? a, Object? b) {
    final out = <String>[];
    void go(String path, Object? x, Object? y) {
      if (out.length >= 3) return;
      if (x is Map && y is Map) {
        for (final k in {...x.keys, ...y.keys}) {
          go('$path.$k', x[k], y[k]);
        }
        return;
      }
      if (jsonEncode(x) != jsonEncode(y)) out.add('$path: ${_short(x)} / ${_short(y)}');
    }

    go(key, a, b);
    return out.join('; ');
  }

  static String _short(Object? v) {
    final s = v == null ? '(none)' : jsonEncode(v);
    return s.length > 90 ? '${s.substring(0, 87)}...' : s;
  }

  String get summary => equal
      ? 'equal ($nodesA nodes)'
      : '$same of $nodesA nodes the same; ${differing.length} differ, ${onlyA.length} only in the code\'s, ${onlyB.length} only in the definition\'s${other.isEmpty ? '' : '; document keys ${other.join(', ')}'}';
}

/// The uses of a word: pages, each after a `### <where it is from>` line.
List<({String from, String text})> readUses(String text) {
  final out = <({String from, String text})>[];
  String? from;
  final lines = <String>[];
  void flush() {
    if (from != null && lines.any((l) => l.trim().isNotEmpty)) out.add((from: from, text: '${lines.join('\n').trimRight()}\n'));
    lines.clear();
  }

  for (final l in text.replaceAll('\r\n', '\n').split('\n')) {
    if (l.startsWith('### ')) {
      flush();
      from = l.substring(4).trim();
    } else {
      lines.add(l);
    }
  }
  flush();
  return out;
}

/// The widths a use is expanded at: a website or an app window, a tablet, a
/// phone (the page words change at 700: the drawer, the phone menu).
const closureWidths = [1440.0, 834.0, 390.0];

/// A word's uses expanded once through the expander's code and once through
/// its definition (renamed), at each of [closureWidths].
final class WordClosure {
  WordClosure(this.word, this.results);

  final String word;
  final List<({String from, double width, Comparison comparison, Comparison spelt, List<String> issues})> results;

  /// Every use's two documents are equal, and the definition says nothing
  /// the code does not.
  bool get closes => results.isNotEmpty && results.every((r) => r.comparison.equal && r.issues.isEmpty);

  /// The same, with expressions compared as [_plainExpression]s: what
  /// differs is how an expression is spelt (the code writes `(a==b)`, a
  /// definition the use's `a == b`), not what it says.
  bool get closesUpToSpelling => results.isNotEmpty && results.every((r) => r.spelt.equal && r.issues.isEmpty);
}

/// [word]'s closure over [uses], with the dictionary's [files] (every word of
/// them renamed, so that its definitions read each other). [renamed] is what
/// is renamed in the uses: [word] alone, or a family of words at once.
WordClosure closure(String word, List<({String from, String text})> uses, Iterable<DictionaryFile> files, {Set<String>? renamed}) {
  final all = {for (final f in files) ...f.words};
  final defs = renamedDefinitions(files, all);
  final which = renamed ?? {word};
  return WordClosure(word, [
    for (final u in uses)
      for (final w in closureWidths)
        () {
          final viaDefinition = renameWords(u.text, which);
          final code = expandPage(u.text, width: w);
          final defined = expandPage(viaDefinition, width: w, definitions: defs);
          // The issues the definition's side has that the code's has not
          // (by message: a renamed word is longer, so columns move).
          String plain(String i) => i.replaceAll(RegExp(r'line \d+:\d+: '), '').replaceAll('Dict', '');
          final before = {for (final i in pageIssues(u.text, width: w)) plain(i)};
          final issues = [
            for (final i in pageIssues(viaDefinition, width: w, definitions: defs))
              if (!before.contains(plain(i))) i,
          ];
          return (from: u.from, width: w, comparison: Comparison(code, defined), spelt: Comparison(code, defined, spelling: true), issues: issues);
        }(),
  ]);
}
