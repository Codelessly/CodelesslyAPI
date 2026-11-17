// Words defined in the notation itself (docs/design/20-defined-words.md): a
// word's signature (its strings, parameters with their defaults, flags and
// events) and the lines it stands for, read from a text in the notation's own
// grammar, and expanded where a page uses it, before the line is read.
//
//   // A note stuck on a board.
//   StickyNote "text" fill=#FFFDE68A w=180 selected=false onTap
//     Column w={w} pad=14 fill={fill} radius=4 onTap={onTap}
//       Text "{text}"
//
// A use's values are put in where the body reads them by name in braces; the
// lines written under a use go where the body has `...` (or `...Name` for the
// lines under a `Name` line). Nothing here knows the document: the expansion
// is plain lines, read as if the page had written them.
import '../catalog.dart' show Catalog;
import 'notation.dart';
import 'universal.dart';
import 'vocabulary.dart';

/// One definition of a word: its signature and the lines it stands for.
final class NotationDefinition {
  NotationDefinition._({
    required this.word,
    required this.file,
    required this.line,
    required this.signature,
    required this.doc,
    required this.name,
    required this.variants,
    required this.strings,
    required this.parameters,
    required this.required,
    required this.events,
    required this.bind,
    required this.body,
  });

  /// The word (`StickyNote`), and the name of this meaning when the word has
  /// several (`Timeline#route`: `route`).
  final String word;
  final String? name;

  /// Where it is written: the file's name (`StickyNote.txt`, or `page` for a
  /// `define` in a page) and the 1-based line of its signature.
  final String file;
  final int line;

  /// The signature as written, and the `//` lines above it (its purpose).
  final String signature, doc;

  /// The variants a use may write (`Timeline.vertical`).
  final List<String> variants;

  /// The names of its strings, in order (`"text"`).
  final List<String> strings;

  /// Its parameters by name, each with its default as written (null: none).
  /// A flag is a parameter whose default is `true` or `false`.
  final Map<String, String?> parameters;

  /// The parameters a use must give (`key!`).
  final Set<String> required;

  /// The events it gives (`onTap`, `onPick`).
  final List<String> events;

  /// `bind=name`: the name the body calls the variable it keeps its value in.
  final String? bind;

  /// The lines it stands for: each with its indent from the first (0), its
  /// text and its line in [file].
  final List<({int indent, String text, int line})> body;

  /// `StickyNote`, or `Timeline#route` for one of several meanings.
  String get label => name == null ? word : '$word#$name';

  /// Where it is written, for a message: `StickyNote.txt:3`.
  String at(int line) => '$file:$line';

  bool isFlag(String key) => parameters[key] == 'true' || parameters[key] == 'false';

  /// The names of its slots in body order (`''` the default slot).
  List<String> get slots => [
        for (final l in body)
          if (l.text.startsWith('...')) slotOf(l.text).name,
      ];

  @override
  String toString() => 'NotationDefinition($label, ${at(line)})';
}

/// The definitions in [texts] (each by its file name: `StickyNote.txt`), by
/// word, with what could not be read (`StickyNote.txt:3: …`). A word that
/// uses itself, directly or through others, is left out.
({Map<String, List<NotationDefinition>> words, List<String> problems}) readDefinitions(Map<String, String> texts) {
  final problems = <String>[];
  final words = <String, List<NotationDefinition>>{};
  for (final e in texts.entries) {
    for (final d in _read(e.key, e.value, problems)) {
      (words[d.word] ??= []).add(d);
    }
  }
  // A word that uses itself is refused, with every word on the way.
  final refused = <String>{};
  for (final w in words.keys) {
    final path = _cycle(w, words, [w]);
    if (path != null) {
      refused.add(w);
      final d = words[w]!.first;
      problems.add('${d.at(d.line)}: $w uses itself (${path.join(' > ')}): it is not read.');
    }
  }
  for (final w in refused) {
    words.remove(w);
  }
  return (words: words, problems: problems);
}

/// The words a text (a page, or an answer of several screens) defines with
/// `define Word …` at the margin, wherever they are written: a definition
/// holds for the whole text, before or after its uses. A `//` line directly
/// above a `define` is its purpose. A word defined twice is the later
/// definition, unless both name their meaning (`define Timeline#route`), when
/// the word has both. A word that uses itself, through these or [others]
/// (the design system's), is left out. What is wrong is in `problems`, each
/// with the 1-based line of [text] it is on; `signatures` are every `define`
/// line read, as written without `define` (what [DefinedWords.preread] skips).
({Map<String, List<NotationDefinition>> words, List<({int line, String message})> problems, Set<String> signatures}) readPageDefinitions(String text,
    {Map<String, List<NotationDefinition>> others = const {}}) {
  final words = <String, List<NotationDefinition>>{};
  final problems = <({int line, String message})>[];
  final signatures = <String>{};
  final lines = text.split(RegExp(r'\r?\n'));
  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i];
    if (!raw.startsWith('define ')) continue;
    // Its purpose: the `//` lines at the margin directly above it.
    final doc = <String>[];
    for (var k = i - 1; k >= 0 && lines[k].startsWith('//'); k--) {
      doc.insert(0, lines[k].substring(2).trim());
    }
    final head = i;
    signatures.add(raw.trim().substring(7).trim());
    final body = <({int indent, String text, int line})>[];
    while (i + 1 < lines.length) {
      final next = lines[i + 1];
      final nt = next.trim();
      if (nt.isNotEmpty && next.length - next.trimLeft().length == 0) break;
      i++;
      if (nt.isEmpty || nt.startsWith('//')) continue;
      body.add((indent: next.length - next.trimLeft().length, text: nt, line: i + 1));
    }
    final said = <String>[];
    final d = definitionOf('page', head + 1, raw.trim(), body, doc.join(' '), said);
    for (final p in said) {
      problems.add((line: int.tryParse(RegExp(r'^page:(\d+):').firstMatch(p)?[1] ?? '') ?? head + 1, message: p));
    }
    if (d == null) continue;
    final had = words[d.word];
    if (had != null && d.name != null && had.every((h) => h.name != null && h.name != d.name)) {
      had.add(d);
    } else {
      words[d.word] = [d];
    }
  }
  for (final w in words.keys.toList()) {
    final path = _cycle(w, {...others, ...words}, [w]);
    if (path != null) {
      final d = words.remove(w)!.first;
      problems.add((line: d.line, message: '${d.at(d.line)}: $w uses itself (${path.join(' > ')}): it is not read.'));
    }
  }
  return (words: words, problems: problems, signatures: signatures);
}

/// The way [word] reaches itself through the words its bodies use, or null.
List<String>? _cycle(String word, Map<String, List<NotationDefinition>> words, List<String> path) {
  for (final d in words[path.last] ?? const <NotationDefinition>[]) {
    for (final l in d.body) {
      final w = RegExp(r'^[A-Z][A-Za-z0-9]*').stringMatch(l.text);
      if (w == null || !words.containsKey(w)) continue;
      if (w == word) return [...path, w];
      if (path.contains(w)) continue;
      final found = _cycle(word, words, [...path, w]);
      if (found != null) return found;
    }
  }
  return null;
}

final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

/// A slot line of a body: `...` (the default slot) or `...Front` (the lines
/// under a `Front` line), then either `each <words>`, added to an `each` over
/// a variable written directly in the slot (`... each reorder`), or the words
/// of a column that holds the slot's lines (`...Front w=fill h=fill pad=20`),
/// joined by those the use writes on the slot's own line.
({String name, String each, String words}) slotOf(String text) {
  final m = RegExp(r'^\.\.\.\s*([A-Z][A-Za-z0-9]*)?\s*(.*)$').firstMatch(text.trim());
  final rest = (m?[2] ?? '').trim();
  final each = RegExp(r'^each\s+(.*)$').firstMatch(rest);
  return (name: m?[1] ?? '', each: each == null ? '' : each[1]!.trim(), words: each == null ? rest : '');
}
final _event = RegExp(r'^on[A-Z][A-Za-z0-9]*$');

/// A line of a body before its root: the word's own state and timers.
bool _preamble(String text) => RegExp(r'^(state|every|key)\s').hasMatch(text);

/// The definitions written in one text.
List<NotationDefinition> _read(String file, String text, List<String> problems) {
  final out = <NotationDefinition>[];
  final lines = text.split(RegExp(r'\r?\n'));
  final doc = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i];
    final t = raw.trim();
    if (t.isEmpty) continue;
    final indent = raw.length - raw.trimLeft().length;
    if (indent == 0 && t.startsWith('//')) {
      doc.add(t.substring(2).trim());
      continue;
    }
    if (indent > 0) {
      problems.add('$file:${i + 1}: a line under no signature (a definition starts with its word at the margin).');
      continue;
    }
    final head = i;
    final body = <({int indent, String text, int line})>[];
    while (i + 1 < lines.length) {
      final next = lines[i + 1];
      final nt = next.trim();
      if (nt.isNotEmpty && next.length - next.trimLeft().length == 0) break;
      i++;
      if (nt.isEmpty || nt.startsWith('//')) continue;
      body.add((indent: next.length - next.trimLeft().length, text: nt, line: i + 1));
    }
    final d = definitionOf(file, head + 1, t, body, doc.join(' '), problems);
    if (d != null) out.add(d);
    doc.clear();
  }
  return out;
}

/// The definition whose signature is [signature] (`define` before it is
/// read too) with [body] under it, or null with what is wrong in [problems].
NotationDefinition? definitionOf(String file, int line, String signature, List<({int indent, String text, int line})> body, String doc, List<String> problems) {
  var sig = signature.trim();
  if (sig.startsWith('define ')) sig = sig.substring(7).trim();
  final parts = LineParts.of(sig);
  if (parts == null || !RegExp(r'^[A-Z]').hasMatch(parts.word)) {
    problems.add('$file:$line: a signature starts with the word it defines, capitalised (StickyNote "text" fill=#FFFDE68A).');
    return null;
  }
  if (body.isEmpty) {
    problems.add('$file:$line: ${parts.word} stands for no lines: write them indented under its signature.');
    return null;
  }
  final strings = <String>[];
  final parameters = <String, String?>{};
  final required = <String>{};
  final events = <String>[];
  String? bind;
  for (final p in parts.parts) {
    switch (p.kind) {
      case 'string':
        final n = p.raw.replaceAll('"', '');
        if (!_identifier.hasMatch(n)) {
          problems.add('$file:$line: a string of a signature is named ("text", "detail"): ${p.raw} is not a name.');
          continue;
        }
        strings.add(n);
      case 'pair':
        if (p.key == 'bind') {
          if (!_identifier.hasMatch(p.value!)) {
            problems.add('$file:$line: bind= names the variable the body keeps its value in (bind=value).');
            continue;
          }
          bind = p.value;
        } else if (p.isEvent) {
          events.add(p.key!);
        } else {
          parameters[p.key!] = p.value;
        }
      case 'word':
        var w = p.raw;
        if (w.endsWith('!')) {
          w = w.substring(0, w.length - 1);
          required.add(w);
        }
        if (!_identifier.hasMatch(w)) {
          problems.add('$file:$line: "$w" is not a name of a parameter.');
          continue;
        }
        if (_event.hasMatch(w)) {
          events.add(w);
        } else {
          parameters[w] = null;
        }
      default:
        problems.add('$file:$line: a signature has no {…} at its end.');
    }
  }
  final min = body.map((l) => l.indent).reduce((a, b) => a < b ? a : b);
  var lines = [for (final l in body) (indent: l.indent - min, text: l.text, line: l.line)];
  // `if visible` over the one node it stands for: that node, shown while
  // the condition holds.
  final top = [for (final l in lines) if (l.indent == 0 && !_preamble(l.text)) l];
  final cond = top.length == 1 ? (RegExp(r'^if\s+(.+)$').firstMatch(top.single.text)?[1])?.trim() : null;
  if (cond != null) {
    final at = lines.indexOf(top.single);
    final under = lines.sublist(at + 1);
    final step = under.isEmpty ? 0 : under.first.indent;
    if (step > 0 && under.where((l) => l.indent == step).length == 1 && under.every((l) => l.indent >= step)) {
      final c = cond.startsWith('{') && cond.endsWith('}') ? cond.substring(1, cond.length - 1).trim() : cond;
      final rootLine = LineParts.of(under.first.text);
      final own = rootLine?.pair('visible')?.value;
      final shown = own == null ? '{$c}' : '{($c) && (${own.startsWith('{') && own.endsWith('}') ? own.substring(1, own.length - 1) : own})}';
      final root = DefinedWords._merged(under.first.text, [LinePart.pair('visible', shown)]);
      lines = [
        ...lines.sublist(0, at),
        (indent: 0, text: root, line: under.first.line),
        for (final l in under.skip(1)) (indent: l.indent - step, text: l.text, line: l.line),
      ];
    }
  }
  final roots = [
    for (final l in lines)
      if (l.indent == 0 && !_preamble(l.text)) l,
  ];
  if (roots.isEmpty || LineParts.of(roots.first.text) == null || const {'if', 'each', 'else', 'for', 'every', 'key', 'state', 'define'}.contains(LineParts.of(roots.first.text)!.word)) {
    problems.add('$file:${roots.isEmpty ? line : roots.first.line}: the first line ${parts.word} stands for is a node (Column, Row, Card…), with the others under it.');
    return null;
  }
  if (roots.length > 1) {
    problems.add('$file:${roots[1].line}: ${parts.word} stands for one line and the lines under it; this one is beside it (indent it under ${roots.first.text.split(' ').first}).');
    return null;
  }
  final names = [...strings, ...parameters.keys, ...events, ?bind];
  final seen = <String>{};
  for (final n in names) {
    if (!seen.add(n)) problems.add('$file:$line: "$n" is named twice.');
  }
  final variants = [
    for (final v in parts.variant.split('.'))
      if (v.isNotEmpty) v,
  ];
  return NotationDefinition._(
    word: parts.word,
    file: file,
    line: line,
    signature: sig,
    doc: doc,
    name: parts.id.isEmpty ? null : parts.id.substring(1),
    variants: variants,
    strings: strings,
    parameters: parameters,
    required: required,
    events: events,
    bind: bind,
    body: lines,
  );
}

/// Whether a use's key=value (or event) [key] goes on its root when the
/// definition does not name it: a word every line understands
/// (docs/design/21-universal-words.md, [notationUniversal]).
bool definedPassThrough(String key, [String? value]) {
  final u = notationUniversal[key];
  if (u == null) return false;
  if (u.kind != UniversalKind.flag) return true;
  // A flag written key=value: the grammar's that take one (grow=1,
  // sticky=0, hidden={…}); a universal flag set to true or worked out.
  if (u.grammar) return const {'grow', 'sticky', 'hidden'}.contains(key);
  return value == 'true' || (value?.startsWith('{') ?? false);
}

/// Whether a use's bare word goes on its root: a universal flag.
bool definedPassThroughWord(String word) => notationUniversal[word]?.kind == UniversalKind.flag;

const _statements = {'if', 'each', 'else', 'for', 'every', 'key', 'state', 'project', 'node', 'document', 'let', 'const', 'var', 'derived', 'computed'};

/// A line the expansion gives: its indent, its text, and where it was
/// written when it comes from a definition (`StickyNote.txt:3`; null: the
/// page's own line).
typedef DefinedLine = ({int indent, String text, String? from});

/// The defined words of a text being read, one line at a time: each line is
/// given to [rewrite] with its indent, and the lines it stands for come back
/// (itself, moved into the slot of a use it is under, or a use's expansion).
/// [finish] gives what is still open at the end.
final class DefinedWords {
  DefinedWords(
    this.definitions, {
    required this.open,
    this.record,
    this.issue,
    this.used,
    this.slot,
    this.ours,
    this.component,
    Map<String, int>? counts,
    this.context,
    this.within = const [],
    Map<String, List<NotationDefinition>>? page,
    this.variable,
  })  : counts = counts ?? {},
        page = page ?? {};

  /// The definitions by word.
  final Map<String, List<NotationDefinition>> definitions;

  /// With the open vocabulary a word a use writes that its definition does
  /// not have is recorded ([record]); without it, it is an [issue].
  final bool open;

  /// A word on a use its definition does not have (kind `parameter`, `flag`,
  /// `event`, `variant`, `children`, `missing`), as a stand-in's would be.
  final void Function(String kind, String word, String on, String? value, int column)? record;

  /// A problem, at a column of the line being read.
  final void Function(int column, String message)? issue;

  /// A use, read as [definition], whose root is the node [node].
  final void Function(NotationDefinition definition, LineParts parts, String node, int column)? used;

  /// A line under a use naming one of its slots (`Front`): a word of the
  /// definition, not drawn.
  final void Function(NotationDefinition definition, String word, int column)? slot;

  /// The words that are the notation's own (a core type, a catalog type, a
  /// page word, a component): never a defined word's.
  final bool Function(String word)? ours;

  /// The names a component of the design system takes (its props, its
  /// events, `bind` when it keeps a value), when [word] is one; null when it
  /// is not. A component's word may take further meanings from definitions
  /// that name theirs (`Stepper#steps`): a use is read as one of them only
  /// when it fits it better than the component (docs/design/20 section 5).
  final Set<String>? Function(String word)? component;

  /// Whether [name] is a variable of the page (its state, or the item of an
  /// `each` around the line): a use's `bpm=bpm` gives the value, not a word.
  final bool Function(String name)? variable;

  /// Whether [word] is a defined word here (a definition, or a `define` read
  /// in the text so far).
  bool has(String word) => (page.containsKey(word) || definitions.containsKey(word)) && !(ours?.call(word) ?? false);

  /// The meanings of [word] a use may be read with: all of a defined word's,
  /// or the named ones a component's word has (empty: none).
  List<NotationDefinition> meanings(String word) {
    if (has(word)) return _of(word) ?? const [];
    if (component?.call(word) == null) return const [];
    // A page's own unnamed definition of a component's word is not read, and does
    // not hide the design system's named meanings of it.
    final named = [for (final d in page[word] ?? const <NotationDefinition>[]) if (d.name != null) d];
    return named.isNotEmpty ? named : [for (final d in definitions[word] ?? const <NotationDefinition>[]) if (d.name != null) d];
  }

  /// The meanings of [word] here: the page's own, else the definitions'.
  List<NotationDefinition>? _of(String word) => page[word] ?? definitions[word];

  /// Inside a definition's body: where it is written (`StickyNote.txt:3`).
  /// What is wrong there is an issue that says so, whatever [open] is.
  final String? context;

  /// The words being expanded around this one (a word inside its own body
  /// is refused).
  final List<String> within;

  /// How many uses of each word have taken an id of their own so far.
  final Map<String, int> counts;
  final _uses = <_Use>[];

  /// A `define` being read in the page: its signature, and its body so far.
  ({int line, String signature, int indent})? _defining;
  final _definingBody = <({int indent, String text, int line})>[];
  int _line = 0;

  /// The words the text itself defines (`define Word …`), over [definitions]:
  /// a page's own definition of a word the design system defines wins there.
  /// Shared with the overlays written after the page.
  final Map<String, List<NotationDefinition>> page;

  /// The signatures read before the text was ([preread]): when the reader
  /// reaches one, its lines are skipped and it is not read again.
  final _preread = <String>{};

  /// The first line each word was met on while it was no defined word (a
  /// definition that comes after it, read as the text arrives, is too late
  /// for it).
  final _metBefore = <String, int>{};

  /// [words] (from [readPageDefinitions] of the whole text, or of the other
  /// screens of an answer) as the text's own, from its first line.
  void preread(Map<String, List<NotationDefinition>> words, {Iterable<String> signatures = const []}) {
    page.addAll(words);
    _preread.addAll(signatures);
  }

  Map<String, List<NotationDefinition>> get _all => page.isEmpty ? definitions : {...definitions, ...page};

  void _issue(int column, String message) => issue?.call(column, context == null ? message : '$context: $message');

  /// The lines [text] at [indent] stands for. [from] is where it is written
  /// when it is not the page's own line.
  List<DefinedLine> rewrite(int indent, String text, {String? from, int? line}) {
    _line = line ?? _line + 1;
    // A `define` in the page: its lines are the definition's, not the page's.
    if (_defining case final d?) {
      if (indent > d.indent) {
        _definingBody.add((indent: indent, text: text, line: _line));
        return const [];
      }
      _endDefine();
    }
    if (indent == 0 && text.startsWith('define ') && context == null) {
      _defining = (line: _line, signature: text, indent: indent);
      return const [];
    }
    if (context == null) {
      final w = RegExp(r'^[A-Z][A-Za-z0-9]*').stringMatch(text);
      if (w != null && !has(w)) _metBefore.putIfAbsent(w, () => _line);
    }
    if (definitions.isEmpty && page.isEmpty && _uses.isEmpty) return [(indent: indent, text: text, from: from)];
    final out = <DefinedLine>[];
    while (_uses.isNotEmpty && _uses.last.indent >= indent) {
      out.addAll(_uses.removeLast().close());
    }
    var at = indent;
    if (_uses.isNotEmpty) {
      final placed = _uses.last.place(indent, text, out);
      if (placed == null) return out;
      at = placed.at;
      text = placed.text;
    }
    // `Track#{tr.id} name=…`, `Track#track-{tr.id}`: an id from data is its
    // fixed part, as on any line (none when it has none).
    if (RegExp(r'^([A-Z][A-Za-z0-9]*)((?:\.[A-Za-z][A-Za-z0-9]*)*)#([A-Za-z0-9_-]*)\{[^{}]*\}[A-Za-z0-9_-]*(?=\s|$)').firstMatch(text) case final m? when has(m[1]!)) {
      final fixed = m[3]!.replaceAll(RegExp(r'[-_]+$'), '');
      text = '${m[1]}${m[2]}${RegExp(r'^[A-Za-z_]').hasMatch(fixed) ? '#$fixed' : ''}${text.substring(m.end)}';
    }
    final parts = LineParts.of(text);
    var defs = parts == null || _statements.contains(parts.word) || !has(parts.word) ? null : _of(parts.word);
    // A component's word with named meanings defined (`Stepper#steps`): one
    // of them when the use fits it better than the component's own names.
    if (parts != null && defs == null && !_statements.contains(parts.word)) {
      final named = meanings(parts.word);
      if (named.isNotEmpty) {
        final best = _choose(named, parts);
        final takes = component!(parts.word)!;
        if (_score(best, parts) > _scoreOf(takes, const [], const [], parts)) defs = [best];
      }
    }
    if (defs != null && defs.isNotEmpty) {
      out.addAll(_openUse(at, indent, text, parts!, defs));
      return out;
    }
    out.add((indent: at, text: text, from: from));
    return out;
  }

  /// What is still open at the end of the text.
  List<DefinedLine> finish() {
    if (_defining != null) _endDefine();
    final out = <DefinedLine>[];
    while (_uses.isNotEmpty) {
      out.addAll(_uses.removeLast().close());
    }
    return out;
  }

  void _endDefine() {
    final d = _defining!;
    _defining = null;
    // Read with the whole text before it was read: its lines are skipped.
    if (_preread.contains(d.signature.substring(7).trim())) {
      _definingBody.clear();
      return;
    }
    final problems = <String>[];
    final def = definitionOf('page', d.line, d.signature, [..._definingBody], '', problems);
    _definingBody.clear();
    for (final p in problems) {
      issue?.call(1, p);
    }
    if (def != null) {
      final all = {..._all, def.word: [def]};
      final cycle = _cycle(def.word, all, [def.word]);
      if (cycle != null) {
        issue?.call(1, 'page:${d.line}: ${def.word} uses itself (${cycle.join(' > ')}): it is not read.');
      } else {
        // Read as the text arrives (NotationStream), a definition holds from
        // where it is written: a use above it was read without it.
        if (_metBefore[def.word] case final int at) {
          issue?.call(1,
              'page:${d.line}: ${def.word} is used on line $at, before this definition. Read as it arrives, a text applies a definition from where it is written on, so that use was read without it (it stands in, or is an issue). Read the whole text at once (parseNotation), or define a word before its first use.');
        }
        page[def.word] = [def];
      }
    }
  }

  /// The definition of [defs] that fits the use [p] best (docs/design/20
  /// section 5): one whose required parameters it gives; then the one whose
  /// signature names the most of what it gives, less what it does not; then
  /// the one that names the fewest things it was not given; then the first.
  NotationDefinition _choose(List<NotationDefinition> defs, LineParts p) {
    if (defs.length == 1) return defs.first;
    NotationDefinition? best;
    var bestScore = -1 << 30;
    for (final d in defs) {
      final score = _score(d, p);
      if (score > bestScore) {
        best = d;
        bestScore = score;
      }
    }
    return best!;
  }

  /// How well the use [p] fits [d] (higher: better).
  static int _score(NotationDefinition d, LineParts p) =>
      _scoreOf({...d.parameters.keys, ...d.events, ...d.strings, if (d.bind != null) 'bind'}, d.required, d.variants, p);

  /// How well the use [p] fits a meaning that takes [names], needs
  /// [required] and has [variants]: 20 for each word given that it names,
  /// less 10 for each it does not (the words every line has aside), 10 for
  /// each variant written that it has, less 10 for each it has not; less one
  /// for each name not given (of meanings that fit as well, the plainest).
  static int _scoreOf(Set<String> names, Iterable<String> required, Iterable<String> variants, LineParts p) {
    final given = <String>{
      for (final x in p.parts)
        if (x.kind == 'pair') x.key! else if (x.kind == 'word') x.raw,
    };
    var score = required.every(given.contains) ? 0 : -100000;
    for (final g in given) {
      if (names.contains(g)) {
        score += 20;
      } else if (!definedPassThrough(g) && !definedPassThroughWord(g)) {
        score -= 10;
      }
    }
    for (final v in [for (final v in p.variant.split('.')) if (v.isNotEmpty) v]) {
      score += variants.contains(v) ? 10 : -10;
    }
    return score - names.where((n) => !given.contains(n)).length;
  }

  List<DefinedLine> _openUse(int at, int indent, String text, LineParts p, List<NotationDefinition> defs) {
    final d = _choose(defs, p);
    final column = indent + 1;
    int col(LinePart x) => column + (x.at < 0 ? 0 : x.at);
    if (within.contains(d.label) || within.length >= 8) {
      _issue(column, '${d.word} is used inside itself (${[...within, d.label].join(' > ')}): it is left out.');
      return const [];
    }
    void unknown(String kind, String word, String? value, int c, String message) {
      if (open && context == null) {
        record?.call(kind, word, d.word, value, c);
      } else {
        _issue(c, message);
      }
    }

    String takes() => [
          ...d.strings.map((s) => '"$s"'),
          ...d.parameters.keys,
          if (d.bind != null) 'bind',
          ...d.events,
        ].join(', ');
    // The use's id, or one of its own: the root's, and what its state and
    // ids are made into.
    final uid = p.id.isNotEmpty ? p.id.substring(1) : '${d.word[0].toLowerCase()}${d.word.substring(1)}${counts[d.word] = (counts[d.word] ?? 0) + 1}';
    final values = <String, String?>{};
    final actions = <String, String>{};
    final root = <LinePart>[];
    // A universal word (note 21) the signature does not name: the root's,
    // when it is universal on the kind of line the root is (a container, a
    // text, an icon, a control; a list's words only on a container whose
    // use says reorder or selectable); else a word the definition does not
    // have.
    final rootText = d.body.firstWhere((b) => b.indent == 0 && !_preamble(b.text), orElse: () => d.body.first).text;
    final rootWord = RegExp(r'^[A-Z][A-Za-z0-9]*').stringMatch(rootText) ?? '';
    final rootKind = _all.containsKey(rootWord)
        ? ''
        : const {'Column', 'Row', 'Stack', 'Box', 'Card', 'Grid', 'List'}.contains(rootWord)
            ? 'container'
            : const {'Text', 'Heading', 'Link'}.contains(rootWord)
                ? 'text'
                : const {'Icon', 'IconButton'}.contains(rootWord)
                    ? 'icon'
                    : 'control';
    final listUse = const ['reorder', 'sortable', 'reorderable', 'selectable'].any(p.has);
    bool universal(LinePart x) {
      final word = x.kind == 'pair' ? x.key! : x.raw;
      final u = notationUniversal[word];
      if (u != null && !u.grammar) {
        final list = const {'reorder', 'sortable', 'reorderable', 'selectable', 'handle', 'onReorder', 'onSelect'}.contains(word);
        if (rootKind.isNotEmpty && ((list && (!listUse || rootKind != 'container')) || (u.on.isNotEmpty && !u.on.contains(rootKind)))) return false;
        if (open && context == null) record?.call('universal', word, d.word, x.kind == 'pair' ? x.value : null, col(x));
      }
      root.add(x);
      return true;
    }

    String? bound;
    var strings = 0;
    // `Pill {status}`: an expression where the first string goes, before any
    // string, is that string ("{status}"); the line goes on after it.
    final given = [...p.parts];
    final first = given.indexWhere((x) => x.kind == 'string' || x.kind == 'tail');
    if (first >= 0 && given[first].kind == 'tail' && d.strings.isNotEmpty && !given[first].raw.startsWith('{"')) {
      final raw = given[first].raw;
      final close = _braceEnd(raw, 0);
      final rest = LineParts.of('X ${raw.substring(close).trim()}');
      given.replaceRange(first, first + 1, [LinePart.string('"${raw.substring(0, close)}"'), ...?rest?.parts]);
    }
    for (final x in given) {
      switch (x.kind) {
        case 'string':
          if (strings < d.strings.length) {
            values[d.strings[strings]] = x.raw;
          } else {
            unknown('parameter', 'string${strings + 1}', x.raw, col(x), 'A ${d.word} takes ${d.strings.length} string${d.strings.length == 1 ? '' : 's'}. It takes: ${takes()}.');
          }
          strings++;
        case 'pair':
          final k = x.key!, v = x.value!;
          if (k == 'bind' && d.bind != null) {
            bound = v;
          } else if (x.isEvent && d.events.contains(k)) {
            actions[k] = v.startsWith('{') && v.endsWith('}') ? v.substring(1, v.length - 1).trim() : v;
          } else if (d.parameters.containsKey(k) || d.strings.contains(k)) {
            // `end=draft.end`, `bpm=bpm`: a path, or a variable of the page,
            // given to a plain parameter is the value it reads.
            final path = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)+$').hasMatch(v) ||
                (_identifier.hasMatch(v) && v != 'true' && v != 'false' && v != 'null' && (variable?.call(v) ?? false));
            values[k] = path ? '{$v}' : v;
          } else if (definedPassThrough(k, v) && (!const {'duration', 'delay', 'stagger'}.contains(k) || p.pair('animate') != null) && universal(x)) {
            // On its root.
          } else {
            unknown(x.isEvent ? 'event' : 'parameter', k, v, col(x), 'A ${d.word} has no "$k". It takes: ${takes()}.');
          }
        case 'word':
          if (d.parameters.containsKey(x.raw)) {
            values[x.raw] = 'true';
          } else if (definedPassThroughWord(x.raw) && universal(x)) {
            // On its root.
          } else if (num.tryParse(x.raw) != null && (strings < d.strings.length || (d.parameters.containsKey('value') && !values.containsKey('value')))) {
            // A bare number where the text goes (`CountUp 39`): the next
            // string, else the parameter named value; the number itself
            // where the body reads it in an expression, its digits in a text.
            if (strings < d.strings.length) {
              values[d.strings[strings]] = x.raw;
              strings++;
            } else {
              values['value'] = x.raw;
            }
          } else {
            unknown('flag', x.raw, null, col(x), 'A ${d.word} has no "${x.raw}". It takes: ${takes()}.');
          }
        case 'tail':
          root.add(x);
      }
    }
    for (final v in [for (final v in p.variant.split('.')) if (v.isNotEmpty) v]) {
      if (d.variants.contains(v)) {
        values['variant'] = '"$v"';
      } else {
        unknown('variant', '${d.word}.$v', null, column + d.word.length + 1, 'A ${d.word} has no variant "$v".${d.variants.isEmpty ? '' : ' Variants: ${d.variants.join(', ')}.'}');
      }
    }
    if (d.variants.isNotEmpty) values.putIfAbsent('variant', () => '""');
    for (final r in d.required) {
      if (values[r] == null) unknown('missing', r, null, column, 'A ${d.word} needs $r=: write $r=….');
    }
    used?.call(d, p, uid, column);

    // The names the body keeps of its own (its state, the items of its
    // loops, its ids) are made the use's.
    final renamed = <String, String>{};
    for (final l in d.body) {
      if (RegExp(r'^state\s+([A-Za-z_][A-Za-z0-9_]*)').firstMatch(l.text) case final m?) renamed[m[1]!] = '${m[1]}_$uid';
      if (RegExp(r'^each\s+([A-Za-z_][A-Za-z0-9_]*)\s+in\s').firstMatch(l.text) case final m?) renamed[m[1]!] = '${m[1]}_$uid';
      if (RegExp(r'^[A-Z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*#([A-Za-z_][A-Za-z0-9_]*)').firstMatch(l.text) case final m? when l != d.body.firstWhere((b) => b.indent == 0 && !_preamble(b.text))) {
        renamed[m[1]!] = '${m[1]}_$uid';
      }
    }
    if (d.bind != null) renamed[d.bind!] = bound ?? '${d.bind}_$uid';
    final sub = _Substitution(d, values, actions, renamed);

    // The body, with the use's values put in.
    final lines = <({int indent, String text, int line})>[];
    var rooted = false;
    for (final l in d.body) {
      // A use's bind=x is the page's x: the body's own state line is dropped,
      // unless the page has no x (an answer that binds a variable it never
      // declared), when it declares it, with the word's default.
      if (bound != null && RegExp('^state\\s+${d.bind}\\s*=').hasMatch(l.text) && (!_identifier.hasMatch(bound) || (variable?.call(bound) ?? true))) continue;
      var t = sub.line(l.text);
      if (t == null) continue;
      if (!rooted && l.indent == 0 && !_preamble(l.text)) {
        rooted = true;
        t = _rooted(t, uid, root);
      }
      lines.add((indent: l.indent, text: t, line: l.line));
    }
    // Its words expanded in turn, with the same definitions.
    final inner = DefinedWords(_all, open: open, issue: issue, ours: ours, component: component, counts: counts, context: d.at(d.line), within: [...within, d.label], variable: variable);
    final expanded = <DefinedLine>[];
    for (final l in lines) {
      expanded.addAll(inner.rewrite(l.indent, l.text, from: d.at(l.line)));
    }
    expanded.addAll(inner.finish());
    // Split at its slots.
    final segments = <List<DefinedLine>>[[]];
    final markers = <({String name, String each, String words, int indent})>[];
    for (final l in expanded) {
      if (l.text.startsWith('...')) {
        final slot = slotOf(l.text);
        markers.add((name: slot.name, each: slot.each, words: slot.words, indent: at + l.indent));
        segments.add([]);
      } else {
        segments.last.add((indent: at + l.indent, text: l.text, from: l.from));
      }
    }
    final use = _Use(this, d, indent, at, segments, markers, column);
    _uses.add(use);
    return segments.first;
  }

  /// The root line [t] with the use's id and the words it gives every line.
  static String _rooted(String t, String uid, List<LinePart> given) => _merged(t, given, id: uid);

  /// The line [t] with the words [given] over its own (an event's actions
  /// after its own), and with the id [id] when given.
  static String _merged(String t, List<LinePart> given, {String? id}) {
    final p = LineParts.of(t);
    if (p == null) return t;
    final parts = [...p.parts];
    for (final g in given) {
      if (g.kind == 'pair') {
        final i = parts.indexWhere((x) => x.kind == 'pair' && x.key == g.key);
        if (i >= 0 && g.isEvent && parts[i].value!.startsWith('{') && g.value!.startsWith('{')) {
          final a = parts[i].value!, b = g.value!;
          parts[i] = LinePart.pair(g.key!, '{${a.substring(1, a.length - 1).trim()}; ${b.substring(1, b.length - 1).trim()}}');
          continue;
        }
        if (i >= 0) parts.removeAt(i);
      } else if (g.kind == 'word' && parts.any((x) => x.kind == 'word' && x.raw == g.raw)) {
        continue;
      }
      final tail = parts.indexWhere((x) => x.kind == 'tail');
      parts.insert(tail < 0 || g.kind == 'tail' ? parts.length : tail, g);
    }
    return ['${p.word}${p.variant}${id == null ? p.id : '#$id'}', for (final x in parts) x.raw].join(' ');
  }
}

/// A use of a defined word that is still open: the rest of its body, and
/// where the lines written under it go.
final class _Use {
  _Use(this.words, this.definition, this.indent, this.at, this.segments, this.markers, this.column);
  final DefinedWords words;
  final NotationDefinition definition;

  /// The use's indent as written, and where its root is.
  final int indent, at, column;

  /// Its body cut at its slots: [segments] has one more than [markers].
  final List<List<DefinedLine>> segments;
  final List<({String name, String each, String words, int indent})> markers;

  /// The slots whose holding column has been written.
  final _held = <int>{};

  /// The column that holds slot [k]'s lines, when the body or the slot's line
  /// gives it words: written once, and how much further in its lines go.
  int _hold(int k, List<LinePart> given, List<DefinedLine> out) {
    final m = markers[k - 1];
    if (m.words.isEmpty && given.isEmpty) return 0;
    if (_held.add(k) || given.isNotEmpty) {
      out.add((indent: m.indent, text: DefinedWords._merged('Column ${m.words.isEmpty ? 'w=fill' : m.words}', given), from: null));
    }
    return 2;
  }

  /// The next segment to give (the first is given when the use is read).
  int _next = 1;

  /// The indent of the lines directly under the use, and how far the lines
  /// of the one being read move.
  int? _level;
  int _shift = 0;

  /// The lines under a named slot's line: that slot (1-based), and whether
  /// the first of them has set [_shift].
  int? _slot;
  bool _slotShifted = false;

  /// How much further in a named slot's lines go (2 when its line gave
  /// words of its own, held by a column).
  int _slotLift = 0;
  bool _toldChildren = false;

  List<DefinedLine> _advance(int to) {
    final out = <DefinedLine>[];
    while (_next < to && _next < segments.length) {
      out.addAll(segments[_next++]);
    }
    return out;
  }

  /// Where a line under the use goes (its indent there), or null when the
  /// line is a slot's name (it is not drawn). Lines of the body passed on the
  /// way are added to [out].
  ({int at, String text})? place(int i, String text, List<DefinedLine> out) {
    final level = _level ??= i;
    final name = definition.word;
    if (i <= level) {
      _slot = null;
      final head = LineParts.of(text.trim());
      final k = head == null || head.variant.isNotEmpty || head.id.isNotEmpty ? 0 : markers.indexWhere((m) => m.name.isNotEmpty && m.name == head.word) + 1;
      if (k > 0) {
        if (k < _next) {
          words._issue(i + 1, '${head!.word} is written after a slot that comes later in $name: write the slots in the order ${markers.where((m) => m.name.isNotEmpty).map((m) => m.name).join(', ')}.');
        }
        if (words.context == null) words.slot?.call(definition, head!.word, i + 1);
        out.addAll(_advance(k));
        _slot = k;
        _slotShifted = false;
        // `Front fill=#FF6D28D9`: what the slot's line gives every line
        // joins what the body gives the column that holds its lines.
        _slotLift = _hold(k, head!.parts, out);
        return null;
      }
      final d = markers.indexWhere((m) => m.name.isEmpty) + 1;
      if (d > 0) {
        if (d < _next) {
          words._issue(i + 1, 'A line under $name after its named slots: lines that are in none go where $name has "...", before them.');
        }
        out.addAll(_advance(d));
        _shift = markers[d - 1].indent + _hold(d, const [], out) - i;
        return (at: i + _shift, text: _each(text, markers[d - 1].each));
      }
      // No slot for it: under the root, at its end.
      if (!_toldChildren) {
        _toldChildren = true;
        final slots = [for (final m in markers) m.name];
        if (slots.isEmpty) {
          if (words.open && words.context == null) {
            words.record?.call('children', name, name, null, i + 1);
          } else {
            words._issue(i + 1, 'A $name takes no lines under it: they are drawn at its end.');
          }
        } else {
          words._issue(i + 1, 'The lines under $name go under ${slots.join(' or ')}.');
        }
      }
      out.addAll(_advance(segments.length));
      _shift = at + 2 - i;
      return (at: i + _shift, text: text);
    }
    if (_slot case final int k) {
      if (!_slotShifted) {
        _slotShifted = true;
        _shift = markers[k - 1].indent + _slotLift - i;
        return (at: i + _shift, text: _each(text, markers[k - 1].each));
      }
    }
    return (at: i + _shift, text: text);
  }

  /// A line put directly in a slot: an `each` over a variable takes the
  /// words the slot adds to one.
  static String _each(String text, String words) {
    if (words.isEmpty || !RegExp(r'^each\s+[A-Za-z_][A-Za-z0-9_]*\s+in\s+[A-Za-z_][A-Za-z0-9_]*$').hasMatch(text.trim())) return text;
    return '$text $words';
  }

  /// The rest of the body.
  List<DefinedLine> close() => _advance(segments.length);
}

/// A use's values put into its definition's body.
final class _Substitution {
  _Substitution(this.d, this.values, this.actions, this.renamed);
  final NotationDefinition d;

  /// The use's values as written, by parameter (strings by their names).
  final Map<String, String?> values;

  /// The use's actions, by event, without their braces.
  final Map<String, String> actions;

  /// The body's own names, made the use's.
  final Map<String, String> renamed;

  bool _isParameter(String n) => d.parameters.containsKey(n) || d.strings.contains(n) || n == 'variant';

  /// The value of [n] as written, its default when the use gives none.
  String? _value(String n) => values.containsKey(n) ? values[n] : (n == 'variant' ? null : d.parameters[n]);

  /// The value of [n] in an expression.
  String _expression(String n) {
    final v = _value(n);
    if (v == null || v.isEmpty) return 'null';
    // A record written as JSON (`center={"lat":44.9,"lng":-93.1}`) is that
    // record, not an expression in braces.
    if (RegExp(r'^\{\s*"').hasMatch(v) && v.endsWith('}')) return v;
    if (v.startsWith('{') && v.endsWith('}')) return '(${v.substring(1, v.length - 1).trim()})';
    if (v.startsWith('"')) {
      if (!v.contains('{')) return v;
      // A string with an expression in it: its parts joined.
      final inner = v.substring(1, v.length - 1);
      final out = <String>[];
      var last = 0;
      for (final m in RegExp(r'\{([^{}]*)\}').allMatches(inner)) {
        if (m.start > last) out.add('"${inner.substring(last, m.start)}"');
        out.add('(${m[1]!.trim()})');
        last = m.end;
      }
      if (last < inner.length) out.add('"${inner.substring(last)}"');
      if (out.length == 1) return out.first;
      if (out.first.startsWith('(')) out.insert(0, '""');
      return '(${out.join(' + ')})';
    }
    if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(v) || v == 'true' || v == 'false' || v.startsWith('#') || v.startsWith('[')) return v;
    return '"${v.replaceAll('"', r'\"')}"';
  }

  /// The value of [n] spliced into a string.
  String _inString(String n) {
    final v = _value(n);
    if (v == null) return '';
    if (v.startsWith('"') && v.endsWith('"') && v.length >= 2) return v.substring(1, v.length - 1);
    return v;
  }

  /// [text] (an expression or actions) with the parameters and the body's
  /// own names put in. A string in it keeps its words; its `{…}` are read.
  String expression(String text) {
    final b = StringBuffer();
    var i = 0;
    while (i < text.length) {
      final c = text[i];
      if (c == '"' || c == "'") {
        final end = _stringEnd(text, i);
        b.write(_string(text.substring(i, end)));
        i = end;
        continue;
      }
      if (RegExp(r'[0-9]').hasMatch(c)) {
        final m = RegExp(r'[0-9][A-Za-z0-9_.]*').matchAsPrefix(text, i)!;
        b.write(m[0]);
        i = m.end;
        continue;
      }
      if (c == '#') {
        final m = RegExp(r'#[A-Za-z0-9_]*').matchAsPrefix(text, i)!;
        b.write(m[0]);
        i = m.end;
        continue;
      }
      final m = RegExp(r'[A-Za-z_][A-Za-z0-9_]*').matchAsPrefix(text, i);
      if (m == null) {
        b.write(c);
        i++;
        continue;
      }
      final word = m[0]!;
      final before = i == 0 ? '' : text[i - 1];
      final call = m.end < text.length && text[m.end] == '(';
      i = m.end;
      if (before == '.' || call) {
        b.write(word);
      } else if (renamed[word] case final String to) {
        b.write(to);
      } else if (d.events.contains(word)) {
        // An event in an expression: whether the use gave it.
        b.write(actions.containsKey(word) ? 'true' : 'false');
      } else if (_isParameter(word)) {
        b.write(_expression(word));
      } else {
        b.write(word);
      }
    }
    return b.toString();
  }

  /// A string `"…"`: its `{p}` the use's value, its other `{…}` read.
  String _string(String s) {
    final q = s[0];
    final b = StringBuffer(q);
    var i = 1;
    final end = s.length > 1 && s.endsWith(q) ? s.length - 1 : s.length;
    while (i < end) {
      final c = s[i];
      if (c == r'\' && i + 1 < end) {
        b.write(s.substring(i, i + 2));
        i += 2;
        continue;
      }
      if (c == '{') {
        final close = _braceEnd(s, i);
        final inner = s.substring(i + 1, close - 1 < i + 1 ? i + 1 : close - 1);
        final n = inner.trim();
        if (_identifier.hasMatch(n) && renamed[n] == null && _isParameter(n)) {
          b.write(_inString(n));
        } else {
          b.write('{${expression(inner)}}');
        }
        i = close;
        continue;
      }
      b.write(c);
      i++;
    }
    if (end < s.length) b.write(q);
    return b.toString();
  }

  /// [inner] (the actions of an event, without braces) with the use's
  /// actions where the body names its events (`onPick`, `onPick(c)`).
  String actionsOf(String inner) {
    final put = <String>[];
    final b = StringBuffer();
    var i = 0;
    for (final m in RegExp(r'(?<![.A-Za-z0-9_])(on[A-Z][A-Za-z0-9]*)').allMatches(inner)) {
      if (m.start < i || !d.events.contains(m[1])) continue;
      var end = m.end;
      String? arg;
      if (end < inner.length && inner[end] == '(') {
        final close = _parenEnd(inner, end);
        arg = inner.substring(end + 1, close - 1);
        end = close;
      }
      var given = actions[m[1]] ?? '';
      if (arg != null && given.isNotEmpty) {
        final value = '(${expression(arg)})';
        given = given.replaceAllMapped(RegExp(r'(?<![.A-Za-z0-9_])result(?![A-Za-z0-9_])'), (_) => value);
      }
      put.add(given);
      b
        ..write(inner.substring(i, m.start))
        ..write('\u0000${put.length - 1}\u0000');
      i = end;
    }
    b.write(inner.substring(i));
    final done = expression(b.toString()).replaceAllMapped(RegExp('\u0000(\\d+)\u0000'), (m) => put[int.parse(m[1]!)]);
    return [
      for (final a in _actionList(done))
        if (a.trim().isNotEmpty) a.trim(),
    ].join('; ');
  }

  /// One line of the body with the use's values put in (null: nothing left).
  String? line(String text) {
    if (text.startsWith('...')) {
      // A slot's holding column reads the use's values too.
      final slot = slotOf(text);
      if (slot.words.isEmpty) return text;
      return '...${slot.name} ${line('X ${slot.words}')!.substring(2)}';
    }
    if (RegExp(r'^state\s+([A-Za-z_][A-Za-z0-9_]*)\s*=(.*)$').firstMatch(text) case final m?) {
      return 'state ${renamed[m[1]!] ?? m[1]}=${expression(m[2]!.trim())}';
    }
    if (RegExp(r'^(if|else if)\s+(.*)$').firstMatch(text) case final m?) return '${m[1]} ${_braced(m[2]!)}';
    if (RegExp(r'^each\s+([A-Za-z_][A-Za-z0-9_]*)\s+in\s+(.*?)(\s+reorder(?:=\S+)?)?$').firstMatch(text) case final m?) {
      var list = _braced(m[2]!);
      if (RegExp(r'^\(([A-Za-z_][A-Za-z0-9_]*)\)$').firstMatch(list) case final p?) list = p[1]!;
      // `each it in items reorder` with items a list worked out (a filter):
      // there is no variable to write the order to, so it is shown in order.
      final reorder = m[3] != null && _identifier.hasMatch(list) ? m[3]! : '';
      return 'each ${renamed[m[1]!] ?? m[1]} in $list$reorder';
    }
    if (RegExp(r'^(every|key)\s+(.*?)\s+(on[A-Z][A-Za-z0-9]*)=\{(.*)\}\s*$').firstMatch(text) case final m?) {
      return '${m[1]} ${expression(m[2]!)} ${m[3]}={${actionsOf(m[4]!)}}';
    }
    final p = LineParts.of(text);
    if (p == null || _statements.contains(p.word)) return expression(text);
    final parts = <String>[];
    for (final x in p.parts) {
      switch (x.kind) {
        case 'string':
          parts.add(_string(x.raw));
        case 'pair':
          final k = x.key!, v = x.value!;
          final whole = v.startsWith('{') && v.endsWith('}') ? v.substring(1, v.length - 1).trim() : null;
          if (x.isEvent && whole != null) {
            final a = actionsOf(whole);
            if (a.isNotEmpty) parts.add('$k={$a}');
          } else if (whole != null && _identifier.hasMatch(whole) && renamed[whole] == null && _isParameter(whole)) {
            var given = _value(whole);
            // A string that is one value read from the state is that value.
            if (given != null && RegExp(r'^"\{[^{}"]*\}"$').hasMatch(given)) given = given.substring(1, given.length - 1);
            if (given != null && given.isNotEmpty) parts.add('$k=$given');
          } else if (whole != null) {
            parts.add('$k={${expression(whole)}}');
          } else if (v.startsWith('"')) {
            parts.add('$k=${_string(v)}');
          } else if (v.startsWith('[')) {
            parts.add('$k=${expression(v)}');
          } else if ((k.startsWith('bind') || k == 'menu') && renamed[v] != null) {
            parts.add('$k=${renamed[v]}');
          } else {
            parts.add(x.raw);
          }
        case 'tail' when !x.raw.startsWith('{"'):
          // A value where the text goes (`Ring {share} w=40`), and the line
          // after it.
          final close = _braceEnd(x.raw, 0);
          final inner = x.raw.substring(1, close - 1).trim();
          if (_identifier.hasMatch(inner) && renamed[inner] == null && _isParameter(inner)) {
            final v = _value(inner);
            if (v != null && v.isNotEmpty) parts.add(v.startsWith('{') ? v : '{${_expression(inner)}}');
          } else {
            parts.add('{${expression(inner)}}');
          }
          final rest = x.raw.substring(close).trim();
          if (rest.isNotEmpty) parts.add(line('X $rest')!.substring(2));
        default:
          parts.add(x.raw);
      }
    }
    var id = p.id;
    final to = id.isEmpty ? null : renamed[id.substring(1)];
    if (to != null) id = '#$to';
    return ['${p.word}${p.variant}$id', ...parts].join(' ');
  }

  /// A statement's expression (`if p > 0`, `each x in p`), braced or not.
  String _braced(String e) {
    final t = e.trim();
    if (t.startsWith('{') && t.endsWith('}') && _braceEnd(t, 0) == t.length) {
      final inner = t.substring(1, t.length - 1).trim();
      if (_identifier.hasMatch(inner) && renamed[inner] == null && _isParameter(inner)) {
        final v = _value(inner);
        if (v != null && v.startsWith('{') && v.endsWith('}')) return v.substring(1, v.length - 1).trim();
        return _expression(inner);
      }
      return expression(inner);
    }
    return expression(t);
  }
}

int _stringEnd(String text, int open) {
  final q = text[open];
  var depth = 0;
  for (var k = open + 1; k < text.length; k++) {
    final c = text[k];
    if (c == r'\') {
      k++;
    } else if (c == '{') {
      depth++;
    } else if (c == '}' && depth > 0) {
      depth--;
    } else if (c == q && depth == 0) {
      return k + 1;
    }
  }
  return text.length;
}

/// The end of the call whose `(` is at [open] (past its `)`).
int _parenEnd(String text, int open) {
  var depth = 0;
  for (var k = open; k < text.length; k++) {
    final c = text[k];
    if (c == '"' || c == "'") {
      k = _stringEnd(text, k) - 1;
      continue;
    }
    if (c == '(') depth++;
    if (c == ')' && --depth == 0) return k + 1;
  }
  return text.length;
}

/// Actions split at the `;` between them (not in a string, a call or braces).
List<String> _actionList(String actions) {
  final out = <String>[];
  var depth = 0, from = 0;
  for (var k = 0; k < actions.length; k++) {
    final c = actions[k];
    if (c == '"' || c == "'") {
      k = _stringEnd(actions, k) - 1;
      continue;
    }
    if ('([{'.contains(c)) depth++;
    if (')]}'.contains(c)) depth--;
    if (c == ';' && depth == 0) {
      out.add(actions.substring(from, k));
      from = k + 1;
    }
  }
  out.add(actions.substring(from));
  return out;
}

int _braceEnd(String text, int open) {
  var depth = 0;
  for (var k = open; k < text.length; k++) {
    final c = text[k];
    if (c == '"' || c == "'") {
      k = _stringEnd(text, k) - 1;
      continue;
    }
    if (c == '{') depth++;
    if (c == '}' && --depth == 0) return k + 1;
  }
  return text.length;
}

/// Each definition expanded once with its defaults (and a line in each
/// slot), as the parser reads it with the vocabulary closed: what is wrong,
/// each as `file:line: message`. With [validate] (the document's problems,
/// each a message) what does not validate is said too, against the
/// definition's signature. A design system's folder is checked with this
/// before a page uses it.
List<String> checkDefinitions(NotationVocabulary vocabulary,
    {required Catalog catalog, NotationOptions options = const NotationOptions(), List<String> Function(Map<String, Object?> document)? validate}) {
  final out = <String>[];
  for (final defs in vocabulary.definitions.values) {
    for (final d in defs) {
      final use = [
        // Its strings left out (a string may be a colour or a name, which
        // no sample text is): what reads one reads nothing.
        '${d.word}${d.variants.isEmpty ? '' : '.${d.variants.first}'}',
        for (final r in d.required) '$r="x"',
      ].join(' ');
      final lines = ['Column', '  $use'];
      for (final s in d.slots) {
        if (s.isEmpty) {
          lines.add('    Text "in the slot"');
        } else {
          lines
            ..add('    $s')
            ..add('      Text "in $s"');
        }
      }
      // The other meanings of the word may fit this use better: each is
      // checked alone.
      final alone = NotationVocabulary(
        types: vocabulary.types,
        parameters: vocabulary.parameters,
        flags: vocabulary.flags,
        events: vocabulary.events,
        verbs: vocabulary.verbs,
        definitions: {...vocabulary.definitions, d.word: [d]},
      );
      final r = parseNotation(lines.join('\n'), catalog: catalog, options: options.open(openVocabulary: false, vocabulary: alone));
      for (final i in r.issues) {
        final m = RegExp(r'^([^\s:]+:\d+): (.*)$').firstMatch(i.message);
        out.add(m != null ? '${m[1]}: ${m[2]}' : '${d.at(d.line)}: ${i.message}');
      }
      for (final p in validate?.call(r.document) ?? const <String>[]) {
        out.add('${d.at(d.line)}: ${d.label}: $p');
      }
    }
  }
  return out;
}

/// The signature lines of [vocabulary]'s definitions, with their purposes,
/// as the taught prompt lists a design system's components.
List<String> definitionLines(NotationVocabulary vocabulary) => [
      for (final defs in vocabulary.definitions.values)
        for (final d in defs) '${d.signature.replaceFirst(RegExp(r'^([A-Z][A-Za-z0-9.]*)#[A-Za-z_][A-Za-z0-9_]*'), r'$1')}${d.slots.isEmpty ? '' : ' (children${d.slots.where((s) => s.isNotEmpty).map((s) => ': $s').join()})'}${d.doc.isEmpty ? '' : ' : ${d.doc}'}',
    ];
