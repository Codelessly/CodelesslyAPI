// A defined word's own design at a width (docs/design/24-a-design-at-a-
// width.md): an `at <condition>` block under a node line of a definition,
// read where the word is used, as a block of the page is (at_width.dart).
//
//   define Product title price
//     Column#card gap=8
//       Image#photo src={photo} h=160
//       Column#words gap=4
//         Text.strong "{title}"
//         Text.muted "{price}"
//         ...
//       at phone
//         Row gap=12 middle
//           ...#photo
//           ...#words
//
// The lines under `at` are the part's children where the condition holds,
// and its own lines show where no block holds: each use holds both, hidden
// by the rules a block of the page writes. In a block `...` is the part's
// own lines read again and `...#id` the one of them with that id, as on a
// page: the lines a use writes under the word are among the part's own
// lines where the definition has its slot (`...` among the part's own
// lines), so they come again with them. A slot is never written in a block.
//
// The lines are read as the words write them out: the names a use makes its
// own (its ids, its state) are already the use's, so a line read again
// keeps the use's state, and its id is `<id>_<condition>` (with a number
// after it where that is taken). A line read again brings the blocks
// written under it (a word in a word, each with a design at a width): a
// block is then inside a block, which the text itself never writes.
//
// A block the page writes under a use, in a part the word has a block of
// its own for, is the page's design of that use: where it holds, the
// word's block is hidden.
part of 'notation.dart';

/// A line as the defined words write it out, kept for a block's `...`.
final class _WordLine {
  _WordLine(this.indent, this.text, this.from, this.line, this.start, this.reading, this.paged);
  final int indent;
  final String text;

  /// Where it is written when it is a definition's line (`Product.txt:4`).
  final String? from;

  /// The line of the text being read, and how many nodes there were.
  final int line, start;
  int? end;

  /// Which reading of the lines it is of (0 the text's own, another for
  /// the lines each `...` reads again).
  final int reading;

  /// The block of the page it is a line of.
  final _AtBlock? paged;

  /// An `at` line: the part it is under (its index); `...` in a block.
  int at = -1;
  bool rest = false;
  bool get plain => at < 0 && !rest;
}

extension _AtDefined on _Parser {
  static final _id = RegExp(r'^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*(?:~[a-z]+)?#(' + notationId + r')(?=\s|$)');

  /// The lines [d] stands for once the blocks of the defined words are
  /// read: itself, moved into the block it is a line of; for an `at` line
  /// and at a block's end the mark that closes what is open deeper; for
  /// `...` the part's own lines again. Read one at a time: each is written
  /// before the next is asked for.
  Iterable<DefinedLine> _atWord(DefinedLine d) sync* {
    final at = _at;
    final indent = d.indent, text = d.text, from = d.from;
    if (text == _atMark) {
      // The mark of a block of the page: what is open at its place closes.
      while (at.wordOpen.isNotEmpty && indent <= at.wordOpen.last.indent) {
        yield* _atWordClose();
      }
      yield d;
      return;
    }
    if (at.wordLines.isNotEmpty) at.wordLines.last.end ??= nodes.length;
    if (at.wordSkip case final int s) {
      if (indent > s) return;
      at.wordSkip = null;
    }
    while (at.wordOpen.isNotEmpty && indent <= at.wordOpen.last.indent) {
      yield* _atWordClose();
    }
    if (at.wordOpen.isNotEmpty) at.wordOpen.last.first ??= indent;
    if (from != null && isAtLine(text)) {
      yield* _atWordOpen(indent, text, from);
      return;
    }
    final paged = at.feeding ? at.open : null;
    final l = _WordLine(indent, text, from, _line, nodes.length, at.wordReading, paged);
    at.wordLines.add(l);
    if (from != null && at.wordOpen.isNotEmpty && text.startsWith('...')) {
      l.rest = true;
      yield* _atWordAgain(at.wordOpen.last, indent, text, from);
      return;
    }
    yield (indent: _atWordOut(indent), text: text, from: from);
  }

  /// Where a line at [indent] goes: each block open moves its lines to
  /// where its `at` line is.
  int _atWordOut(int indent) {
    final open = _at.wordOpen;
    if (open.isEmpty) return indent;
    var out = indent;
    for (final b in open) {
      out -= (b.first ?? b.indent) - b.indent;
    }
    return math.max(open.last.out, out);
  }

  /// Says [message] of a definition's line written at [from].
  void _atWordSay(String from, String message) {
    final saved = _from;
    _from = from;
    _issue(1, message);
    _from = saved;
  }

  /// A definition's line `at …` at [indent]: the block it opens, or why it
  /// is not read (its lines are then passed over).
  Iterable<DefinedLine> _atWordOpen(int indent, String text, String from) sync* {
    final at = _at;
    final words = text.substring(2).trim();
    final said = words.isEmpty ? 'at' : 'at $words';
    final part = at.wordLines.lastIndexWhere((l) => l.plain && l.indent < indent);
    if (part < 0) {
      _atWordSay(from, '$said is under no line: write it under the line whose lines it changes, after that line\'s own lines.');
      at.wordSkip = indent;
      return;
    }
    final head = at.wordLines[part];
    final read = _atHead(said, words, head.text);
    if (read.refused case final String r) {
      _atWordSay(from, r);
      at.wordSkip = indent;
      return;
    }
    final out = _atWordOut(indent);
    final b = _AtBlock(-1 - part, indent, _line, read.condition!, read.words)
      ..out = out
      ..from = from;
    for (final e in at.blocks[b.part] ?? const <_AtBlock>[]) {
      if (atCovers(b.condition, e.condition)) {
        _atWordSay(from, 'at ${e.words} is never shown: at ${b.words} after it holds wherever it does. Write the wider first.');
      }
    }
    // The page words pass the block by, as they do a block of the page.
    final pass = _pages.passBy(out, phone: atHolds(b.condition, 390, 844) || atHolds(b.condition, 390, 300), holds: (w, h) => atHolds(b.condition, w, h));
    if (pass.refused case final String r) {
      _atWordSay(from, '$said: $r');
      at.wordSkip = indent;
      return;
    }
    for (final l in pass.lines) {
      _lineAt(l.indent, l.text, l.indent + 1);
    }
    // Where its lines go: what the mark reads (a block of the page may be
    // reading its own mark around this one).
    final marking = at.marking, anchored = at.anchored, around = at.anchor;
    at
      ..anchor = null
      ..anchored = false
      ..marking = true;
    yield (indent: out, text: _atMark, from: from);
    final anchor = at.anchor;
    at
      ..marking = marking
      ..anchored = anchored
      ..anchor = around;
    if (_atAnchor(said, anchor) case final String r) {
      _atWordSay(from, r);
      at.wordSkip = indent;
      return;
    }
    final first = !at.blocks.containsKey(b.part);
    _atUnder(b, anchor!.id, head.end, pass.wholeFrame);
    // (A block the page wrote under the use, in the same part, is not one
    // of the part's own lines: it is the page's design there, below.)
    if (first) at.defaults[b.part]!.removeWhere(at.tops.contains);
    at.wordOpen.add(b);
    at.wordLines.add(_WordLine(indent, text, from, _line, nodes.length, at.wordReading, at.feeding ? at.open : null)..at = part);
  }

  /// The innermost block open is read: what is open deeper in it closes, in
  /// it, and its rules are written.
  Iterable<DefinedLine> _atWordClose() sync* {
    final at = _at;
    final b = at.wordOpen.last;
    final marking = at.marking;
    at.marking = false;
    yield (indent: b.out, text: _atMark, from: b.from);
    at.marking = marking;
    at.wordOpen.remove(b);
    _atClosed(b);
    // Where the page wrote a block of its own under the use, in the same
    // part, the page's holds: the word's is hidden there.
    for (final e in at.blocks.entries) {
      if (e.key < 0) continue;
      for (final paged in e.value) {
        if (paged.holder != b.holder) continue;
        final hide = atHidden(paged.condition);
        for (final id in b.tops) {
          if (_atRule(id, hide) && _canvas) ops.add({'op': 'patch', 'id': id, 'patch': {'media': nodes[id]!['media']}});
        }
      }
    }
  }

  /// The end of the text: the blocks still open are read.
  Iterable<DefinedLine> _atWordEnd() sync* {
    while (_at.wordOpen.isNotEmpty) {
      yield* _atWordClose();
    }
    _at.wordSkip = null;
  }

  /// `...` or `...#id` in block [b] of a definition, at [indent]: the
  /// part's own lines (or the one with that id, with the lines under it)
  /// again, their ids `<id>_<condition>`. A line under them with blocks of
  /// its own brings them.
  Iterable<DefinedLine> _atWordAgain(_AtBlock b, int indent, String text, String from) sync* {
    final at = _at;
    final form = RegExp(r'^\.\.\.(?:#(' + notationId + r'))?(.*)$').firstMatch(text)!;
    if (form[2]!.trim().isNotEmpty) {
      // (Said where the definition is written, when it is read.)
      _atWordSay(from, 'In an at block, ... stands for the part\'s own lines and ...#id for one of them by its id: "$text" is neither.');
      return;
    }
    final p = -1 - b.part;
    final part = at.wordLines[p];
    // The part's own lines, as first read: not its blocks, nor what a
    // `...` under it read again; a block of the page written under one of
    // them is not read again (its lines are the page's, read once).
    final own = <_WordLine>[];
    int? over;
    for (var i = p + 1; i < at.wordLines.length; i++) {
      final l = at.wordLines[i];
      if (l.indent <= part.indent) break;
      if (over != null) {
        if (l.indent > over) continue;
        over = null;
      }
      if (l.reading != part.reading) continue;
      if (l.at == p) {
        over = l.indent;
        continue;
      }
      // (The word's own state is declared once.)
      if (l.plain && RegExp(r'^state\s').hasMatch(l.text)) continue;
      own.add(l);
    }
    var lines = own;
    if (form[1] case final String id) {
      final i = own.indexWhere((l) => l.plain && _id.firstMatch(l.text)?[1] == id);
      if (i < 0) {
        _atWordSay(from, '...#$id: no line under the line this block is under has the id "$id" here. A block names a line of the part by its id.');
        return;
      }
      lines = [own[i]];
      for (var j = i + 1; j < own.length && own[j].indent > own[i].indent; j++) {
        lines.add(own[j]);
      }
    }
    final passed = {
      for (final l in lines)
        if (!identical(l.paged, part.paged)) ?l.paged,
    };
    for (final x in passed) {
      _atWordSay(from, '$text brings the lines of this part again without the at ${x.words} block written among them (line ${x.line}): a block inside a block is not read. What the line that block is under shows at this width is its own lines.');
    }
    lines = [
      for (final l in lines)
        if (identical(l.paged, part.paged)) l,
    ];
    if (lines.isEmpty) return;
    final base = lines.map((l) => l.indent).reduce(math.min);
    final issuesBefore = issues.length, wordsBefore = vocabulary.length, nodesBefore = nodes.length;
    final variablesBefore = variables.keys.toSet();
    final renamed = <String, String>{};
    final depth = at.wordOpen.length, reading = at.wordReading;
    at.wordReading = ++at.wordReadings;
    for (final l in lines) {
      var t = l.text;
      if (l.plain) {
        final m = _id.firstMatch(t);
        if (m != null && !t.contains('#{')) {
          // (A line a block under it read again has that name already: a
          // word in a word, both with a design at this width.)
          final id = m[1]!;
          var to = '${id}_${b.suffix}';
          for (var n = 2; _taken(to) || renamed.containsValue(to); n++) {
            to = '${id}_${b.suffix}_$n';
          }
          renamed[id] = to;
          final hash = m[0]!.lastIndexOf('#') + 1;
          t = t.replaceRange(hash, hash + id.length, renamed[id]!);
        }
      } else if (l.rest) {
        // A line a block under them names is the one read again here.
        final m = RegExp(r'^\.\.\.#(' + notationId + r')$').firstMatch(t);
        if (m != null && renamed[m[1]] != null) t = '...#${renamed[m[1]]}';
      }
      yield* _atWord((indent: indent + l.indent - base, text: t, from: l.from));
    }
    // The blocks read with them end with them.
    while (at.wordOpen.length > depth) {
      yield* _atWordClose();
    }
    at.wordReading = reading;
    // What was wrong in them was said on their own lines; what is recorded
    // of them is the lines' (an id taken twice is said here too).
    final added = issues.sublist(issuesBefore).where((i) => i.message.contains('is used twice')).toList();
    issues
      ..removeRange(issuesBefore, issues.length)
      ..addAll(added);
    vocabulary.removeRange(wordsBefore, vocabulary.length);
    for (final e in renamed.entries) {
      if (_taken(e.key) && _taken(e.value)) (at.copies[e.key] ??= []).add(e.value);
    }
    _atShare(b, nodesBefore, variablesBefore);
  }
}
