// A design at a width (docs/design/24-a-design-at-a-width.md): a line
// `at <condition>` under a part, after the part's own lines, whose lines are
// the part's children where the condition holds.
//
//   Row#bar w=fill between middle
//     Text#brand "Acme"
//     Row#links gap=24
//       Button.ghost "Pricing" onTap={scroll pricing}
//     at phone
//       Row w=fill between middle
//         ...#brand
//         IconButton "menu" onTap={navMenu=!navMenu}
//
// The condition is anything a key's prefix takes (`at tablet`, `at max899`,
// `at min700.tablet`, `at portrait`). In a block, `...` is the part's own
// lines and `...#id` the one of them with that id, with the lines under it,
// read again where it is written. The part's own line holds at every width.
//
// It is written out as what the base renders, twins: each line the part
// has of its own is hidden where a block holds, each block's lines are
// hidden where it does not hold (or where a later block does: blocks hold
// in the order written, the later winning), and the first line of each
// block is named `at <condition>`, which the printer reads back
// (print_at.dart). A line brought by `...` is a second node, its id
// `<id>_<condition>` (`links_phone`), and an action that names the id
// (`focus`, `scroll`) is written once for each.
part of 'notation.dart';

/// The line the parser reads, through the defined words and the page words,
/// to find where a block's lines go (and to close what is open deeper):
/// never written, and no node.
const _atMark = '\u0001';

/// A line of the text as read: its indent, its words, its line number, and
/// how many nodes there were before it and after it.
final class _AtLine {
  _AtLine(this.indent, this.text, this.line, this.start);
  final int indent;
  final String text;
  final int line;
  final int start;
  int? end;
}

/// An `at` block being read or read: the part it is under (its line's index
/// among the lines read), where it is written, its condition and its words.
final class _AtBlock {
  _AtBlock(this.part, this.indent, this.line, this.condition, this.words);
  final int part, indent, line;
  final Json condition;

  /// The condition as the notation says it (`phone`, `min700.tablet`).
  final String words;

  /// What a copy's id ends with (`links_phone`).
  String get suffix => words.replaceAll('.', '_');

  /// The node its lines go in, and how many nodes there were before them.
  String? holder;
  int start = 0;

  /// The indent of its first line, and of a line inside it whose lines are
  /// passed over (an `at` inside it).
  int? first, skipAbove;

  /// Its first lines: the nodes under [holder] it made.
  final tops = <String>[];
}

/// What the parser keeps of the `at` blocks of a text.
final class _AtWidths {
  /// The lines read (not those of a block, read again).
  final lines = <_AtLine>[];

  /// The block whose lines are being read, and one whose lines are passed
  /// over (it was said why).
  _AtBlock? open;
  int? skip;

  /// Each part's blocks (by its line's index), and the lines it had of its
  /// own (the nodes under its holder hidden where a block holds).
  final blocks = <int, List<_AtBlock>>{};
  final defaults = <int, List<String>>{};

  /// The part whose blocks were read last, and their indent: a line written
  /// after them, at their indent, is said.
  ({int part, int indent})? after;

  /// The ids read again in a block (`links` → `links_phone`).
  final copies = <String, List<String>>{};

  /// The first lines of every block, and the rules this added to each node
  /// (the hide rules of a part's own lines and of earlier blocks).
  final tops = <String>{};
  final ours = <String, List<Json>>{};

  /// While a block's line is read again through [_Parser.line].
  bool feeding = false;

  /// Set while the mark is read: where the block's lines go.
  bool marking = false;
  _Open? anchor;
  bool anchored = false;

  /// In a defined word's lines: the indent of an `at` whose lines are
  /// passed over.
  int? definedSkip;
}

extension _AtRead on _Parser {
  static final _head = RegExp(r'^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*#(' + notationId + r')(?=\s|$)');
  static final _statement = RegExp(r'^(each|if|else|for)\b');

  static bool _isAt(String text) => text == 'at' || text.startsWith('at ');

  /// A line of the text, before anything else reads it: an `at` line and
  /// the lines of its block are read here (true); every other line is kept,
  /// for a block's `...` to read again, and read as before (false).
  bool _atLine(String raw) {
    final at = _at;
    final text = raw.trim();
    if (at.feeding || text == _atMark) return false;
    final indent = raw.length - raw.trimLeft().length;
    if (at.lines.isNotEmpty) at.lines.last.end ??= nodes.length;
    if (at.skip case final int s) {
      if (indent > s) return true;
      at.skip = null;
    }
    if (at.open case final _AtBlock b) {
      if (indent > b.indent) {
        _atBlockLine(b, indent, text);
        return true;
      }
      _atClose(b);
    }
    // A definition's lines are the definition's: an `at` there is said
    // where the word is used (stage 2 of the design reads it there).
    final margin = at.lines.lastWhere((l) => l.indent == 0, orElse: () => _AtLine(0, '', 0, 0));
    final inDefinition = indent > 0 && isDeclaration(margin.text);
    if (_isAt(text) && !inDefinition) {
      _atOpen(indent, text);
      return true;
    }
    if (at.after case final a?) {
      if (indent == a.indent && !inDefinition) {
        final b = at.blocks[a.part]!.last;
        _issue(indent + 1,
            'This line comes after the at block${at.blocks[a.part]!.length > 1 ? 's' : ''} of the line it is under (line ${at.lines[a.part].line}), so it is read as a line of that part at every width. A part\'s own lines come first, then its at blocks: move it above "at ${b.words}".');
        at.after = null;
      } else if (indent < a.indent) {
        at.after = null;
      }
    }
    at.lines.add(_AtLine(indent, text, _line, nodes.length));
    return false;
  }

  /// A line `at …` at [indent]: the block it opens, or why it is not read
  /// (its lines are then passed over).
  void _atOpen(int indent, String text) {
    final at = _at;
    final words = text.substring(2).trim();
    final said = words.isEmpty ? 'at' : 'at $words';
    void refuse(String message) {
      _issue(indent + 1, message);
      at.skip = indent;
    }

    final part = at.lines.lastIndexWhere((l) => l.indent < indent);
    if (indent == 0 || part < 0) {
      return refuse('$said at the margin is under no line: write it under the line whose lines it changes (the page\'s root line, for the whole page), after that line\'s own lines.');
    }
    final head = at.lines[part];
    if (_statement.firstMatch(head.text)?[1] case final String s) {
      return refuse('$said is under an ${s == 'for' ? 'each' : s}, which is not a part of its own: write the block under the line ${s == 'each' || s == 'for' ? 'the each repeats (each row\'s design at that width)' : 'the if is in'}.');
    }
    if (!RegExp(r'^[A-Z]').hasMatch(head.text)) {
      return refuse('$said goes under a node line (a Row, a Column, a Nav…), after that line\'s own lines: its lines are that line\'s children at that width.');
    }
    if (words.isEmpty) return refuse('at names a width: at phone, at tablet, at desktop, at max899, at min700.tablet, at portrait.');
    final read = mediaCondition('$words.x');
    if (read == null || read.length != words.length + 1) {
      return refuse('$said: "$words" is not a width. A block is written at phone, at tablet, at desktop, at max899, at min700.tablet or at portrait.');
    }
    if (read.problem case final String p) return refuse('$said: $p');
    if (read.condition.values.any((v) => v is String && v != 'portrait' && v != 'landscape')) {
      return refuse('$said names a breakpoint, which a block does not read yet: write its width in pixels (at min600, at max1023).');
    }
    final word = RegExp(r'^[A-Z][A-Za-z0-9]*').stringMatch(head.text)!;
    if (const {'App', 'AppShell', 'Window'}.contains(word) && catalog.widget(word) == null && !_defined.has(word)) {
      return refuse(
          '$said under $word is not read yet: an App\'s panes and its drawer are its own at every width. Write the block under the pane whose lines change (Main, a Sidebar, a Pane), or write the window as a Row of your own panes with the block under it.');
    }
    final b = _AtBlock(part, indent, _line, read.condition, mediaConditionWords(read.condition) ?? words);
    final earlier = at.blocks[part] ?? const <_AtBlock>[];
    for (final e in earlier) {
      if (atCovers(b.condition, e.condition)) {
        _issue(indent + 1, 'at ${e.words} (line ${e.line}) is never shown: at ${b.words} after it holds wherever it does. Write the wider first.');
      }
    }
    // The page words pass the block by (a Table's cells, a Nav's menu, a
    // Sidebar's drawer): what they still had to write first.
    final pass = _pages.passBy(indent, phone: atHolds(b.condition, 390, 844) || atHolds(b.condition, 390, 300));
    if (pass.refused case final String r) return refuse('$said: $r');
    if (pass.lines.isNotEmpty) {
      final before = nodes.length;
      for (final l in pass.lines) {
        _lineAt(l.indent, l.text, l.indent + 1);
      }
      nodes.keys.skip(before).toList().forEach(_emit);
    }
    // Where its lines go: what the mark reads.
    _atMarkAt(indent, anchor: true);
    final anchor = at.anchor;
    if (anchor == null) return refuse('$said: the line it is under holds no lines.');
    final holderId = anchor.id;
    if (anchor.leaf) {
      return refuse('$said: a ${anchor.written ?? anchor.type} takes no lines under it, so it has no design at a width (its values at a width are keys: phone.w=fill).');
    }
    if (anchor.grid != null) {
      return refuse('$said: a Grid lays the lines under it out in its cells. Write its columns at that width (phone.cols=1), or write the block under a Column around the Grid.');
    }
    if (anchor.pages != null || anchor.slot != null || anchor.slots.isNotEmpty) {
      return refuse('$said: the lines under a ${anchor.written ?? anchor.type} are its ${anchor.pages != null ? 'pages' : 'slots'}, not its children: write the block under a Column inside it.');
    }
    // The part's own lines: the nodes under the holder its lines made after
    // its own line (a page word's frame of its own, a Nav's menu button,
    // stays), or for a Table all of them (its header and its rows).
    if (!at.blocks.containsKey(part)) {
      final kids = [...readStrings(nodes[holderId]?['children'])];
      final made = head.end == null ? const <String>{} : nodes.keys.skip(head.end!).toSet();
      at.defaults[part] = [
        for (final k in kids)
          if (pass.wholeFrame || made.contains(k)) k,
      ];
    }
    b
      ..holder = holderId
      ..start = nodes.length;
    (at.blocks[part] ??= []).add(b);
    at.open = b;
  }

  /// Reads the mark at [indent]: what is open deeper closes, and with
  /// [anchor] the node a line there goes in is kept.
  void _atMarkAt(int indent, {required bool anchor}) {
    final at = _at;
    final saved = _line;
    at
      ..anchor = null
      ..anchored = false
      ..marking = anchor
      ..feeding = true;
    _line--;
    line('${' ' * indent}$_atMark');
    _line = saved;
    at
      ..feeding = false
      ..marking = false;
  }

  /// [_lineAt] met the mark: the node a line at its place goes in.
  void _atMarked() {
    final at = _at;
    if (!at.marking || at.anchored) return;
    at.anchored = true;
    at.anchor = _stack.lastOrNull;
  }

  /// A line of block [b], at [indent] as written.
  void _atBlockLine(_AtBlock b, int indent, String text) {
    final at = _at;
    if (b.skipAbove case final int s) {
      if (indent > s) return;
      b.skipAbove = null;
    }
    b.first ??= indent;
    final to = math.max(b.indent, indent - (b.first! - b.indent));
    if (_isAt(text)) {
      _issue(indent + 1, '${text.trim()} inside the at ${b.words} block is not read: write each block under the part itself, the wider first (where two hold, the later wins).');
      b.skipAbove = indent;
      return;
    }
    if (text.startsWith('...')) return _atReplay(b, to, indent, text);
    _atFeed('${' ' * to}$text');
    at.after = null;
  }

  /// [raw] read as a line of the page, at the line being read.
  void _atFeed(String raw) {
    final saved = _line;
    _at.feeding = true;
    _line--;
    line(raw);
    _line = saved;
    _at.feeding = false;
  }

  /// `...` or `...#id` in block [b]: the part's own lines (or the one with
  /// that id, with the lines under it) read again at [to], their ids and
  /// those of the lines under them `<id>_<condition>`.
  void _atReplay(_AtBlock b, int to, int indent, String text) {
    final at = _at;
    final part = at.lines[b.part];
    final own = <_AtLine>[];
    for (var i = b.part + 1; i < at.lines.length && at.lines[i].indent > part.indent; i++) {
      own.add(at.lines[i]);
    }
    final form = RegExp(r'^\.\.\.(?:#(' + notationId + r'))?(.*)$').firstMatch(text)!;
    final rest = form[2]!.trim();
    if (rest.isNotEmpty) {
      if (form[1] == null && RegExp(r'^[A-Za-z]').hasMatch(rest) && !rest.contains(' ')) {
        return _issue(indent + 1, 'In an at block, ... stands for the part\'s own lines and ...#id for one of them by its id: "$text" is neither (a slot by name is a definition\'s).');
      }
      return _issue(indent + 1,
          'Nothing is written on a ... line (here "$rest"): what differs at the width is written on the part\'s own line with a prefix (phone.gap=4), or the line is written out in the block.');
    }
    var lines = own;
    if (form[1] case final String id) {
      final i = own.indexWhere((l) => _head.firstMatch(l.text)?[1] == id);
      if (i < 0) {
        final ids = [for (final l in own) ?_head.firstMatch(l.text)?[1]];
        final word = RegExp(r'^[A-Z][A-Za-z0-9]*(?:#' + notationId + r')?').stringMatch(part.text) ?? part.text;
        return _issue(indent + 1,
            '...#$id: no line under $word (line ${part.line}) has the id "$id"${ids.isEmpty ? ', and none of its lines has an id: give the line one (Row#$id) to name it here' : ' (its lines with ids: ${ids.join(', ')})'}. A block names a line of the part by its id.');
      }
      lines = [own[i]];
      for (var j = i + 1; j < own.length && own[j].indent > own[i].indent; j++) {
        lines.add(own[j]);
      }
    }
    if (lines.isEmpty) return;
    final base = lines.map((l) => l.indent).reduce(math.min);
    final issuesBefore = issues.length, wordsBefore = vocabulary.length, nodesBefore = nodes.length;
    final variablesBefore = variables.keys.toSet();
    final renamed = <String, String>{};
    for (final l in lines) {
      var t = l.text;
      final m = _head.firstMatch(t);
      if (m != null && !t.contains('#{')) {
        final id = m[1]!;
        renamed[id] = '${id}_${b.suffix}';
        final from = m.start + m[0]!.lastIndexOf('#') + 1;
        t = t.replaceRange(from, from + id.length, renamed[id]!);
      } else if (RegExp(r'^[A-Z][A-Za-z0-9]*').stringMatch(t) case final String w when _defined.has(w) && l.end != null && l.end! > l.start && !t.contains('#')) {
        // A defined word's use without an id: the copy is the same use, its
        // state the same (its names are made from the use's id).
        final first = nodes.keys.elementAtOrNull(l.start);
        if (first != null) {
          renamed[first] = '${first}_${b.suffix}';
          t = t.replaceFirst(RegExp(r'^[A-Z][A-Za-z0-9]*(\.[A-Za-z][A-Za-z0-9]*)*'), '${RegExp(r'^[A-Z][A-Za-z0-9]*(\.[A-Za-z][A-Za-z0-9]*)*').stringMatch(t)}#${renamed[first]}');
        }
      }
      _atFeed('${' ' * (to + l.indent - base)}$t');
    }
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
    // A defined word's own state: the copy keeps the use's (a card turned
    // over on a desktop is turned over on a phone).
    final made = nodes.keys.skip(nodesBefore).toList();
    final suffix = '_${b.suffix}';
    final shared = <String, String>{
      for (final v in variables.keys)
        if (!variablesBefore.contains(v) && v.endsWith(suffix) && variables.containsKey(v.substring(0, v.length - suffix.length))) v: v.substring(0, v.length - suffix.length),
    };
    if (shared.isEmpty) return;
    final names = RegExp('(?<![A-Za-z0-9_])(${shared.keys.map(RegExp.escape).join('|')})(?![A-Za-z0-9_])');
    for (final id in made) {
      final before = nodes[id]!;
      final text = jsonEncode(before);
      final now = text.replaceAllMapped(names, (m) => shared[m[1]]!);
      if (now == text) continue;
      final after = (jsonDecode(now) as Map).cast<String, Object?>();
      nodes[id] = after;
      if (_canvas) {
        final d = diffPatch(before, after);
        if (d != null) ops.add({'op': 'patch', 'id': id, 'patch': d..remove('children')..remove('slots')});
      }
    }
    final sent = [for (final v in shared.keys) if (_declared.remove(v)) v];
    shared.keys.forEach(variables.remove);
    if (_canvas && sent.isNotEmpty) ops.add({'op': 'vars', 'scope': _scope, 'remove': sent});
  }

  /// Block [b] is read: its first lines are hidden where it does not hold
  /// (and where a later block holds, when that one is read), the part's own
  /// lines and the earlier blocks' where it holds.
  void _atClose(_AtBlock b) {
    final at = _at;
    at.open = null;
    // What is open deeper in it closes, in it.
    _atMarkAt(b.indent, anchor: false);
    final holder = b.holder!;
    for (final k in nodes.keys.skip(b.start)) {
      if (_parentOf[k] == holder && !at.tops.contains(k)) b.tops.add(k);
    }
    final hide = atHidden(b.condition);
    final changed = <String>{};
    for (final id in [...?at.defaults[b.part], for (final e in at.blocks[b.part]!) if (!identical(e, b)) ...e.tops]) {
      if (_atRule(id, hide)) changed.add(id);
    }
    for (final id in b.tops) {
      for (final r in atOutside(b.condition)) {
        if (_atRule(id, r)) changed.add(id);
      }
      final n = nodes[id];
      if (n != null && n['name'] == null) {
        n['name'] = 'at ${b.words}';
        changed.add(id);
      }
      at.tops.add(id);
    }
    if (_canvas) {
      for (final id in changed) {
        final n = nodes[id];
        if (n == null) continue;
        ops.add({
          'op': 'patch',
          'id': id,
          'patch': {'media': n['media'], if (b.tops.contains(id)) 'name': n['name']},
        });
      }
    }
    at.after = (part: b.part, indent: b.indent);
  }

  /// Adds [rule] to node [id]'s media rules, unless it has it: whether it did.
  bool _atRule(String id, Json rule) {
    final n = nodes[id];
    if (n == null) return false;
    final media = [...?(n['media'] as List?)];
    if (media.any((r) => jsonEquality.equals(r, rule))) return false;
    n['media'] = media..add(rule);
    (_at.ours[id] ??= []).add(rule);
    return true;
  }

  /// [raw], before anything reads it (an overlay's head at the margin
  /// among them): the block open ends when it is not indented past it.
  void _atBefore(String raw) {
    final b = _at.open!;
    final t = raw.trimLeft();
    if (t.isEmpty || t.startsWith('//') || t == _atMark) return;
    if (raw.length - t.length <= b.indent) _atClose(b);
  }

  /// The end of the text: a block still open is read.
  void _atEnd() {
    if (_at.open case final _AtBlock b) _atClose(b);
    _at.skip = null;
  }

  /// In the lines a defined word stands for, an `at` line is not read yet
  /// (stage 2 reads it there): said, and its lines passed over. Whether
  /// [l] is passed over.
  bool _atInDefinition(PageLine l, String? from) {
    final at = _at;
    if (from == null) {
      at.definedSkip = null;
      return false;
    }
    if (at.definedSkip case final int s) {
      if (l.indent > s) return true;
      at.definedSkip = null;
    }
    if (!_isAt(l.text)) return false;
    _issue(1, '${l.text} in a definition is not read yet (a word\'s own design at a width): write the block on the page, under the line that uses the word.');
    at.definedSkip = l.indent;
    return true;
  }

  /// Each action that names an id read again in a block (`focus search`,
  /// `scroll pricing`), written once more for each copy, after it: the one
  /// that is shown is the one it reaches.
  void _atActions() {
    final copies = {
      for (final p in [this, ..._overlays]) ...p._at.copies,
    };
    if (copies.isEmpty) return;
    List<Object?>? spread(Object? list) {
      if (list is! List) return null;
      var changed = false;
      final out = <Object?>[];
      for (var i = 0; i < list.length; i++) {
        final a = list[i];
        Object? e = a;
        if (a is Map) {
          final inner = a.cast<String, Object?>();
          Json? copy;
          for (final k in inner.keys) {
            if (spread(inner[k]) case final List s) {
              (copy ??= {...inner})[k] = s;
            }
          }
          if (copy != null) {
            e = copy;
            changed = true;
          }
        }
        out.add(e);
        final made = e is Map && (e['type'] == 'scrollTo' || e['type'] == 'focus') ? copies[e['node']] : null;
        if (made != null) {
          final each = [for (final c in made) <String, Object?>{...(e as Map).cast<String, Object?>(), 'node': c}];
          // Written already (a print read again): not twice.
          var j = 0;
          while (j < each.length && i + 1 + j < list.length && jsonEquality.equals(list[i + 1 + j], each[j])) {
            j++;
          }
          if (j == each.length) {
            out.addAll(each);
            i += j;
            continue;
          }
          out.addAll(each);
          changed = true;
        }
      }
      return changed ? out : null;
    }

    for (final p in [this, ..._overlays]) {
      for (final e in p.nodes.entries) {
        if (spread(e.value['actions']) case final List s) {
          e.value['actions'] = s;
          if (_canvas) ops.add({'op': 'patch', 'id': e.key, 'patch': {'actions': s}});
        }
      }
      if (spread(p._timers) case final List s) {
        p._timers
          ..clear()
          ..addAll(s.cast<Json>());
        if (_canvas) ops.add({'op': 'patch', 'id': p.options.screen, 'patch': {'actions': [...p._timers]}});
      }
    }
  }

  /// The parts with blocks, which the reflow gives no rule of their own
  /// (their lines and their blocks' are laid out as written), but for the
  /// panes of a window (a Sidebar that is a drawer on a phone is hidden
  /// there).
  Set<String> _atAlone() => {
        for (final e in _at.blocks.values)
          if (e.first.holder case final String h when !const {'sidebar', 'main', 'pane'}.contains(_roles[h])) h,
      };

  /// The nodes as the reflow reads them: a block's lines are not there (it
  /// leaves them as written: they are [_AtWidths.tops], kept), and the hide
  /// rules this gave a part's own lines are not theirs, so that the reflow
  /// still fits them where no block holds.
  Map<String, Json> _atReflowView() {
    final at = _at;
    if (at.tops.isEmpty && at.ours.isEmpty) return nodes;
    final out = {...nodes};
    for (final e in nodes.entries) {
      final kids = e.value['children'];
      if (kids is List && kids.any(at.tops.contains)) out[e.key] = {...e.value, 'children': [for (final k in kids) if (!at.tops.contains(k)) k]};
    }
    for (final e in at.ours.entries) {
      final n = out[e.key];
      if (n == null || at.tops.contains(e.key)) continue;
      final media = [...?(n['media'] as List?)];
      for (final r in e.value) {
        final i = media.indexWhere((m) => jsonEquality.equals(m, r));
        if (i >= 0) media.removeAt(i);
      }
      out[e.key] = {...n}..remove('media');
      if (media.isNotEmpty) out[e.key]!['media'] = media;
    }
    return out;
  }
}
