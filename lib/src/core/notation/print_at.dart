// A design at a width printed back (docs/design/24-a-design-at-a-width.md):
// a part whose children are an `at` block's twins, as the parser writes
// them (at_width.dart; their rules worked out by at_rules.dart), is printed
// as its own lines and its `at` blocks, a block's first lines known by their
// name (`at phone`). A line of a block that is one of the part's own read
// again (`links_phone`, equal to `links` up to its ids) is `...#links`, and
// all of them `...`. A part whose print does not read back so is printed as
// its children are (twins: `hide=phone` beside `show=phone`), and so is a
// part inside a block (a defined word with a design of its own at a width,
// used in a block or read again by one).
part of 'print.dart';

extension on _Printer {
  void _atClear() {
    _atPrinted.clear();
    _view.clear();
    _underIf.clear();
    _taken.clear();
    _copiesPrinted.clear();
    _atIn = null;
  }

  /// After a print that does not read back: the lines printed as `...` are
  /// printed as they are, or else the parts printed with their blocks are
  /// printed as their children are. Whether there was one to change.
  bool _atRetry() {
    if (_copiesPrinted.any((c) => !_noCopy.contains(c))) {
      _noCopy.addAll(_copiesPrinted);
    } else if (_atPrinted.any((p) => !_noAt.contains(p))) {
      _noAt.addAll(_atPrinted);
    } else {
      return false;
    }
    why = 'an at block that does not read back';
    return true;
  }

  /// Records how many ids of each type node [id]'s lines took since
  /// [before] (the parser's own ids, read again by a `...`): true.
  bool _took(String id, Map<String, int> before) {
    _taken[id] = {
      for (final e in _counts.entries)
        if (e.value != (before[e.key] ?? 0)) e.key: e.value - (before[e.key] ?? 0),
    };
    return true;
  }

  /// Each block of [at] at [depth]: its `at` line and its lines.
  bool _atBlocks(({List<String> own, List<({String words, Json condition, List<String> tops})> blocks, Map<String, Json> view}) at, int depth) {
    final own = <String>{};
    void add(String k) {
      if (!own.add(k)) return;
      final n = readMap(nodes[k]);
      readStrings(n?['children']).forEach(add);
      for (final v in (readMap(n?['slots']) ?? const {}).values) {
        if (v is String) add(v);
      }
    }

    at.own.forEach(add);
    final outer = _atIn;
    try {
      for (final b in at.blocks) {
        _lines.add(_Line(depth, 'at ${b.words}'));
        _atIn = (suffix: b.words.replaceAll('.', '_'), own: own, all: at.own);
        if (!_kids(b.tops, depth + 1)) return false;
      }
    } finally {
      _atIn = outer;
    }
    return true;
  }

  /// At [kids][i], in a block: when the lines from there are the part's own
  /// lines read again, all of them, `...` and how many; else 0.
  int _atAll(List<String> kids, int i, int depth, String? condition) {
    final all = _atIn!.all;
    if (all.isEmpty || i + all.length > kids.length) return 0;
    for (var j = 0; j < all.length; j++) {
      final same = _atSame(kids[i + j], all[j], condition);
      if (same == null || same.needIf != null) return 0;
    }
    _lines.add(_Line(depth, '...'));
    for (var j = 0; j < all.length; j++) {
      _atRead(kids[i + j], all[j]);
      _copiesPrinted.add(kids[i + j]);
    }
    return all.length;
  }

  /// Node [id] in a block, when it is one of the part's own lines read
  /// again (`<id>_<condition>`): `...#id` (under the `if` it alone is under).
  bool _atCopy(String id, int depth, String? condition) {
    final suffix = '_${_atIn!.suffix}';
    if (!id.endsWith(suffix)) return false;
    final of = id.substring(0, id.length - suffix.length);
    if (!_atIn!.own.contains(of)) return false;
    final same = _atSame(id, of, condition);
    if (same == null) return false;
    if (same.needIf case final String c) {
      _lines.add(_Line(depth, 'if $c'));
      depth++;
    }
    _lines.add(_Line(depth, '...#$of'));
    _atRead(id, of);
    _copiesPrinted.add(id);
    return true;
  }

  /// [copy], printed as `...` of [of]: its nodes are said, and the ids the
  /// lines it reads again take.
  void _atRead(String copy, String of) {
    void seen(String k) {
      if (!_seen.add(k)) return;
      final n = readMap(nodes[k]);
      readStrings(n?['children']).forEach(seen);
      for (final v in (readMap(n?['slots']) ?? const {}).values) {
        if (v is String) seen(v);
      }
    }

    seen(copy);
    for (final e in (_taken[of] ?? const <String, int>{}).entries) {
      _counts[e.key] = (_counts[e.key] ?? 0) + e.value;
    }
  }

  /// Whether node [copy] is node [of] (one of the part's own lines, printed)
  /// read again: equal up to its ids, a line whose id is written having it
  /// `_<condition>`. Its own visible binding is the `if` it is under
  /// ([condition]), or one to write above it ([needIf]). Null: not.
  ({String? needIf})? _atSame(String copy, String of, String? condition) {
    // (A line printed with blocks of its own is not read again with them.)
    if (_noCopy.contains(copy) || _atPrinted.contains(of)) return null;
    final c = _view[copy] ?? readMap(nodes[copy]), o = _view[of] ?? readMap(nodes[of]);
    if (c == null || o == null) return null;
    var cn = _atBare(c), on = _atBare(o);
    // Printed under an if, its line does not say the if's condition.
    if (_underIf.contains(of)) on = _atUnbound(on);
    String? needIf;
    final shown = readMap(cn['bind'])?['visible'];
    if (shown != null && shown != readMap(on['bind'])?['visible']) {
      if (condition != null && shown == '\${= $condition}') {
        cn = _atUnbound(cn);
      } else if (shown is String && shown.startsWith(r'${= ') && shown.endsWith('}') && !shown.contains('\n') && readMap(on['bind'])?['visible'] == null) {
        needIf = shown.substring(4, shown.length - 1).trim();
        cn = _atUnbound(cn);
      } else {
        return null;
      }
    }
    // Its size may be its place's (a row in a column fills it): the print
    // read back says whether it is.
    cn.remove('layout');
    on.remove('layout');
    if (jsonEncode(_sorted(cn)) != jsonEncode(_sorted(on)) || !_atIds(copy, of) || !_atUnder(c, o)) return null;
    return (needIf: needIf);
  }

  /// Whether the nodes under [c] are those under [o], read again.
  bool _atUnder(Json c, Json o) {
    final ck = readStrings(c['children']), ok = readStrings(o['children']);
    if (ck.length != ok.length) return false;
    for (var i = 0; i < ck.length; i++) {
      if (!_atDeep(ck[i], ok[i])) return false;
    }
    final cs = readMap(c['slots']) ?? const {}, os = readMap(o['slots']) ?? const {};
    if (cs.length != os.length) return false;
    for (final e in os.entries) {
      final x = cs[e.key];
      if (x is! String || e.value is! String || !_atDeep(x, e.value as String)) return false;
    }
    return true;
  }

  bool _atDeep(String copy, String of) {
    final c = readMap(nodes[copy]), o = readMap(nodes[of]);
    if (c == null || o == null || _atPrinted.contains(of)) return false;
    return jsonEncode(_sorted(_atBare(c))) == jsonEncode(_sorted(_atBare(o))) && _atIds(copy, of) && _atUnder(c, o);
  }

  /// A line whose id is written ([of]'s, printed) is read again with its id
  /// `_<condition>`.
  bool _atIds(String copy, String of) {
    final mark = RegExp('#${RegExp.escape(of)}(?=[\\s{]|\$)');
    final written = _lines.any((l) => l.id == of && mark.hasMatch(l.text));
    return !written || copy == '${of}_${_atIn!.suffix}';
  }

  static Json _atBare(Json n) => {...n}
    ..remove('children')
    ..remove('slots');

  static Json _atUnbound(Json n) {
    final bind = {...?readMap(n['bind'])}..remove('visible');
    final out = {...n}..remove('bind');
    if (bind.isNotEmpty) out['bind'] = bind;
    return out;
  }
}
