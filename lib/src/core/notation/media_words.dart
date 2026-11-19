// A node's media rules in the notation's words (docs/design/22 section 2.4,
// "Media": the form is written down there): `phone.pad=16 tablet.gap=8
// max899.hidden` is the line's value at other widths. Shared by the parser
// (notation.dart, which reads the words) and the printer (print_media.dart,
// which writes them), so that both work a rule out the same way.
//
// A word is a condition, a dot, and a key the line already reads, with its
// value as the line writes it. Its patch is what that key changes on the
// line: the parser reads the line with and without the rule's words and
// keeps the difference ([mediaPatchBetween]), so every key the line knows is
// a key a rule knows.
import '../json.dart';
import '../media.dart';
import '../node_patch.dart';
import '../props.dart';
import '../value_fields.dart';
import 'notation.dart' show NotationResult;
import 'reflow.dart' show reflowPhoneMax, reflowTabletMax;

/// The notation's named sizes as a rule's condition: the bounds `hide=phone`,
/// `hide=tablet` and `hide=desktop` hide at (design 13 section 14).
const Map<String, Json> mediaSizes = {
  'phone': {'maxWidth': reflowPhoneMax},
  'tablet': {'maxWidth': reflowTabletMax},
  'desktop': {'minWidth': reflowTabletMax + 1},
};

/// What `hide=` and `show=` write: hidden where the condition holds, the
/// line's own visible binding dropped there.
const Json mediaHidden = {'visible': false, 'bind': {'visible': null}};

/// The rule `hide=<size>` / `show=<size>` makes, by the word as it is printed
/// (`hide=tablet` and `show=desktop` are one rule: the first is printed).
const Map<String, Json> mediaHideWords = {
  'hide=phone': {'maxWidth': reflowPhoneMax},
  'hide=tablet': {'maxWidth': reflowTabletMax},
  'show=phone': {'minWidth': reflowPhoneMax + 1},
  'hide=desktop': {'minWidth': reflowTabletMax + 1},
};

final _bound = RegExp(r'^(min|max)(?:(\d+)|([A-Z][A-Za-z0-9]*))$');

/// The condition the leading segments of [key] name (`phone.pad` →
/// `{"maxWidth": 699}`, `min700.tablet.gap` → `{"minWidth": 700, "maxWidth":
/// 1023}`), with the length of that prefix and its dot; null when [key] does
/// not start with one or has nothing after it. [problem] says a condition
/// that names one bound twice.
({Json condition, int length, String? problem})? mediaCondition(String key) {
  final parts = key.split('.');
  final condition = <String, Object?>{};
  String? problem;
  var used = 0, length = 0;
  void set(String k, Object v, String segment) {
    if (condition.containsKey(k)) problem ??= 'A rule\x27s condition says $k once: $segment repeats it.';
    condition[k] = v;
  }

  for (final s in parts.take(parts.length - 1)) {
    final size = mediaSizes[s == 'mobile' ? 'phone' : s];
    final bound = _bound.firstMatch(s);
    if (size != null) {
      size.forEach((k, v) => set(k, v!, s));
    } else if (MediaOrientation.values.any((o) => o.name == s)) {
      set('orientation', s, s);
    } else if (bound != null && !const {'minWidth', 'maxWidth', 'minHeight', 'maxHeight'}.contains(s)) {
      final k = bound[1] == 'min' ? 'minWidth' : 'maxWidth';
      // max899: a width in px. minTablet: a breakpoint by its id.
      final Object v = bound[2] != null ? int.parse(bound[2]!) : '${bound[3]![0].toLowerCase()}${bound[3]!.substring(1)}';
      set(k, v, s);
    } else {
      break;
    }
    used++;
    length += s.length + 1;
  }
  if (used == 0 || parts[used].isEmpty) return null;
  return (condition: condition, length: length, problem: problem);
}

/// The words for a rule's condition ([MediaRule.conditionKeys]), the
/// counterpart of [mediaCondition]: a named size where a bound is one, else
/// `min<px>`/`max<px>`, `min<Breakpoint>`/`max<Breakpoint>`, `portrait` or
/// `landscape`, joined by dots. Null when the rule has another key or a
/// bound the words cannot say (a fraction of a px).
String? mediaConditionWords(Json rule) {
  if (rule.keys.any((k) => k != 'patch' && !MediaRule.conditionKeys.contains(k))) return null;
  final out = <String>[];
  for (final k in const ['minWidth', 'maxWidth']) {
    final v = rule[k];
    if (v == null) continue;
    final named = mediaSizes.entries.where((e) => e.value.length == 1 && e.value[k] == v).firstOrNull?.key;
    if (named != null && v is num) {
      out.add(named);
    } else if (v is num && v == v.roundToDouble() && v >= 0) {
      out.add('${k.substring(0, 3)}${v.toInt()}');
    } else if (v is String && RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(v)) {
      out.add('${k.substring(0, 3)}${v[0].toUpperCase()}${v.substring(1)}');
    } else {
      return null;
    }
  }
  if (rule['orientation'] case final Object o) {
    if (!MediaOrientation.values.any((m) => m.name == o)) return null;
    out.add('$o');
  }
  return out.isEmpty ? null : out.join('.');
}

/// The patch that takes node [base] to node [changed] over the fields a
/// rule may patch ([MediaRule.patchKeys]), as [mergeNodePatch] reads one: a
/// field whose value has several forms (a size, a position) or a text style
/// from another named style is written whole, where a merge would mix two
/// forms; a field [changed] lacks is null. [props] are the node type's
/// declarations. Null when nothing differs. [keys] are the node keys a
/// patch may hold, [MediaRule.patchKeys] unless given (a state's patch:
/// docs/design/22, "States").
Json? mediaPatchBetween(Json base, Json changed, List<PropDef<Object?>> props, {bool Function(String key)? keys}) {
  final out = <String, Object?>{};
  final patches = keys ?? MediaRule.patchKeys.contains;
  for (final k in {...MediaRule.patchKeys, ...base.keys, ...changed.keys}) {
    if (!patches(k)) continue;
    final fields = switch (k) {
      'layout' => LayoutFields.all,
      'decoration' => DecorationFields.all,
      'props' => props,
      _ => null,
    };
    final d = _diff(base[k], changed[k], base.containsKey(k), changed.containsKey(k), fields == null ? null : {for (final f in fields) f.key: f.type});
    if (d != _same) out[k] = d;
  }
  return out.isEmpty ? null : out;
}

/// The keys other than a rule's that differ between [base] and [changed]
/// (what a rule's words said that a rule cannot hold: an event, a child).
/// [keys] as [mediaPatchBetween] takes them.
List<String> mediaOtherChanges(Json base, Json changed, {bool Function(String key)? keys}) => [
      for (final k in {...base.keys, ...changed.keys})
        if (!(keys ?? MediaRule.patchKeys.contains)(k) && k != 'media' && !jsonEquality.equals(base[k], changed[k])) k,
    ];

const _same = Object();

Object? _diff(Object? a, Object? b, bool hadA, bool hasB, Map<String, PropType>? fields) {
  if (hadA == hasB && jsonEquality.equals(a, b)) return _same;
  if (!hasB) return null;
  if (a is! Map || b is! Map) return b;
  final out = <String, Object?>{};
  for (final k in {...a.keys, ...b.keys}) {
    final av = a[k], bv = b[k];
    if (a.containsKey(k) == b.containsKey(k) && jsonEquality.equals(av, bv)) continue;
    final type = fields?[k];
    if (!b.containsKey(k)) {
      out['$k'] = null;
    } else if (av is Map && bv is Map && type != null && _whole(type, av, bv)) {
      out['$k'] = bv;
    } else if (av is Map && bv is Map) {
      final sub = type != null && type.kind == PropKind.object ? {for (final f in type.fields) f.key: f.type} : null;
      out['$k'] = _diff(av, bv, true, true, sub);
    } else {
      out['$k'] = bv;
    }
  }
  return out;
}

/// Whether a patch writes [b] whole over [a] (as [mergeNodePatch] would
/// replace, not merge).
bool _whole(PropType type, Map a, Map b) {
  if (type.kind == PropKind.object && type.name == 'TextStyle') return b['from'] != null && b['from'] != a['from'];
  if (!isUnionType(type)) return false;
  if (type.kind == PropKind.value && type.name == 'AxisSize') return true;
  final fa = unionForm(type, a), fb = unionForm(type, b);
  return fb != null && fa != fb;
}

/// [patch] with the line's bindings of the fields it sets dropped where it
/// holds (`"bind": {"layout.width": null}`), so that the value written
/// shows: a binding shows over a patched value. [bound] are the node's
/// bound paths (`layout.width`, `decoration.fills[0].color`).
Json mediaDropBindings(Json patch, Iterable<String> bound) {
  final set = <String>[];
  void walk(Object? v, String at) {
    if (v is Map && v.isNotEmpty) {
      v.forEach((k, e) => walk(e, '$at.$k'));
    } else {
      set.add(at);
    }
  }

  for (final e in patch.entries) {
    if (e.key == 'bind') continue;
    if (e.value is Map) {
      (e.value as Map).forEach((k, v) => walk(v, '${e.key}.$k'));
    } else {
      set.add(e.key);
    }
  }
  final own = readMap(patch['bind']) ?? const {};
  final drop = <String, Object?>{};
  for (final k in bound) {
    if (own.containsKey(k)) continue;
    final path = k.replaceAllMapped(RegExp(r'\[(\d+)\]'), (m) => '.${m[1]}');
    if (set.any((p) => path == p || path.startsWith('$p.') || p.startsWith('$path.'))) drop[k] = null;
  }
  if (drop.isEmpty) return patch;
  return {
    ...patch,
    'bind': {...own, ...drop},
  };
}

/// [patch] with the fields of [alone] (the same words read on the line's
/// type alone) it lacks where the words gave them: a value the line already
/// has (`hidden max899.hidden`: the line read with its words, [changed],
/// has it too), or one under a binding of the line ([bound]), which hides it
/// when the line is read with them. A size, a position and a binding are
/// one field each.
Json mediaWithAlone(Json patch, Json alone, Json changed, Iterable<String> bound) {
  final paths = [for (final k in bound) k.replaceAllMapped(RegExp(r'\[(\d+)\]'), (m) => '.${m[1]}')];
  final out = _copyMap(patch);
  Object? at(List<String> path) {
    Object? v = changed;
    for (final k in path.first == 'bind' ? ['bind', path.skip(1).join('.')] : path) {
      if (v is! Map || !v.containsKey(k)) return _absent;
      v = v[k];
    }
    return v;
  }

  void walk(Object? v, List<String> path) {
    final whole = path.length == 2 && ((path.first == 'layout' && const {'width', 'height', 'x', 'y'}.contains(path.last)) || path.first == 'bind');
    if (v is Map && v.isNotEmpty && !whole) {
      v.forEach((k, e) => walk(e, [...path, '$k']));
      return;
    }
    final p = path.join('.');
    final given = jsonEquality.equals(at(path), v) || (path.first != 'bind' && paths.any((b) => b == p || b.startsWith('$p.') || p.startsWith('$b.')));
    if (!given) return;
    Json into = out;
    for (final k in path.take(path.length - 1)) {
      final cur = into[k];
      if (cur != null && cur is! Map) return;
      final Json next = cur == null ? <String, Object?>{} : (cur as Map).cast<String, Object?>();
      into = into[k] = next;
    }
    into.putIfAbsent(path.last, () => v);
  }

  alone.forEach((k, v) => walk(v, ['$k']));
  return out;
}

const _absent = Object();

/// [m] without the value at [path], and without a map that leaves empty.
Json _removed(Json m, List<String> path) {
  if (path.first == 'bind' || !m.containsKey(path.first)) return m;
  final out = {...m};
  if (path.length == 1) {
    out.remove(path.first);
  } else if (readMap(m[path.first]) case final Json inner) {
    final rest = _removed(inner, path.sublist(1));
    if (rest.isEmpty) {
      out.remove(path.first);
    } else {
      out[path.first] = rest;
    }
  }
  return out;
}

Json _copyMap(Json m) => {for (final e in m.entries) e.key: e.value is Map ? _copyMap(readMap(e.value)!) : e.value};

/// Works out the patches of a line's rules, as the parser does and the
/// printer checks its words with: [line] (its words without its rules and
/// its `{…}` tail) read alone under its parent's kind, with and without a
/// rule's words, by [parse].
///
/// A node's states (docs/design/22, "States") are worked out by the same
/// reader: [keys] are then the node keys a state's patch may hold, [rule]
/// says what is read (`A hovered state`), and [dropBindings] is false (a
/// state's patch shows over the node's bindings by itself).
final class MediaLineReader {
  MediaLineReader(this.parse,
      {required this.line, required this.parentType, required this.props, required this.bound, this.keys, this.rule = 'A media rule', this.dropBindings = true});

  /// Reads a text in the notation, with no rules of its own lines read.
  final NotationResult Function(String text) parse;
  final String line;
  final String? parentType;

  /// The line's type's props, and the fields its node binds.
  final List<PropDef<Object?>> props;
  final Iterable<String> bound;

  /// The node keys a patch may hold ([MediaRule.patchKeys] when null), what
  /// is read, and whether a value written drops the line's binding of it.
  final bool Function(String key)? keys;
  final String rule;
  final bool dropBindings;

  late final NotationResult _without = parse(mediaLineText(parentType, line));
  late final String _head = RegExp(r'^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)?').stringMatch(line) ?? line;
  late final Json? _headAlone = mediaLineNode(parse(mediaLineText(parentType, _head)).document);

  /// The patch of a rule whose words are [words] (each `key=value` or a
  /// flag, without its condition), null when they change nothing, and what
  /// was wrong with them.
  ({Json? patch, List<String> issues}) patch(List<String> words) {
    // A word written by its full path from the node (`props.scrollable=true`,
    // `layout.width=fill`) patches that path only: what reading it adds
    // elsewhere on the line (a scrolling row's edge fade, a text's
    // squeezable) is not the rule's (docs/design/22, 4.8).
    final exact = [for (final w in words) if (_fullPath.firstMatch(w) != null) w];
    if (exact.isNotEmpty) return _exactly(words, exact);
    final issues = <String>[];
    // A key the rule writes that the line binds (`w={listW}` and
    // `phone.w=fill`) is the rule's value there, not read beside the
    // binding: the binding kept the pane at the tablet's width on a phone
    // (track C: notes, every screen).
    final written = {for (final w in words) if (w.indexOf('=') case final i when i > 0) w.substring(0, i)};
    final withWords = parse(mediaLineText(parentType, dropBindings ? _withoutBindings(line, written) : line, words));
    final a = mediaLineNode(_without.document), b = mediaLineNode(withWords.document);
    if (a == null || b == null) {
      return (
        patch: null,
        issues: [
          keys == null
              ? 'The line cannot be read alone, so its rules cannot be: write them as its media in the {…} tail.'
              : 'The line cannot be read alone, so its states cannot be: write them as its states in the {…} tail.',
        ],
      );
    }
    // What the words said wrong is said where the rule is.
    final before = [for (final x in _without.issues) x.message];
    for (final x in withWords.issues) {
      if (!before.remove(x.message)) issues.add(x.message);
    }
    final other = mediaOtherChanges(a, b, keys: keys);
    if (other.isNotEmpty) {
      issues.add(keys == null ? 'A media rule changes ${MediaRule.patchKeys.join(', ')}: not ${other.join(', ')}.' : other.contains('type')
              ? '$rule changes fields of the node, and these words make it another kind of node (a Text with a fill or a border is drawn in a box of its own): write the box, with the state and its look on it (Box selected={â€¦} selected.fill=â€¦ and the Text in it).'
              : '$rule changes fields of the node: not its ${other.join(', ')}.');
    }
    var patch = mediaPatchBetween(a, b, props, keys: keys) ?? <String, Object?>{};
    if (_headAlone case final Json alone) {
      final b2 = mediaLineNode(parse(mediaLineText(parentType, _head, words)).document);
      final more = b2 == null ? null : mediaPatchBetween(alone, b2, props, keys: keys);
      if (more != null) patch = mediaWithAlone(patch, more, b, bound);
    }
    // A field the rule binds shows its binding: the value a binding word
    // leaves in its place (`w={…}`: a width of 0) is not the rule's.
    for (final e in (readMap(patch['bind']) ?? const {}).entries) {
      if (e.value != null && '${e.key}'.contains('.')) patch = _removed(patch, '${e.key}'.split('.'));
    }
    // A state's words that make the line another kind of node (a Text given
    // a fill is drawn in a box of its own) are not a change of the node's
    // fields: what was worked out between the two (the text's own text and
    // style taken away) is not kept, only the look. (The label of a
    // selected tab vanished: `Text â€¦ selected={â€¦} selected.fill=tint`.)
    if (keys != null && other.contains('type')) {
      patch = {
        for (final k in const ['decoration', 'opacity'])
          if (patch[k] != null) k: patch[k],
      };
    }
    if (patch.isEmpty) return (patch: null, issues: issues);
    return (patch: dropBindings ? mediaDropBindings(patch, bound) : patch, issues: issues);
  }

  /// [line] without its words that bind one of [keys] (`w={listW}`): the
  /// words of the line, split where it is not inside quotes or brackets.
  static String _withoutBindings(String line, Set<String> keys) {
    if (keys.isEmpty) return line;
    final out = <String>[];
    var depth = 0, start = 0;
    String? quote;
    void word(int end) {
      final w = line.substring(start, end);
      final eq = w.indexOf('={');
      if (w.isNotEmpty && !(eq > 0 && w.endsWith('}') && keys.contains(w.substring(0, eq)))) out.add(w);
    }

    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (quote != null) {
        if (c == r'\') {
          i++;
        } else if (c == quote) {
          quote = null;
        }
      } else if (c == '"' || c == "'") {
        quote = c;
      } else if (c == '{' || c == '[' || c == '(') {
        depth++;
      } else if (c == '}' || c == ']' || c == ')') {
        depth--;
      } else if (c == ' ' && depth == 0) {
        word(i);
        start = i + 1;
      }
    }
    word(line.length);
    return out.join(' ');
  }

  /// A key that is a full path into a section, no list index in it.
  static final _fullPath = RegExp(r'^(props|layout|decoration)((?:\.[A-Za-z_][A-Za-z0-9_]*)+)=');

  /// [patch] of [words] where [exact] are written by their full paths: the
  /// other words' patch, and each of [exact] as the value its path has on
  /// the line read with it (null where it has none).
  ({Json? patch, List<String> issues}) _exactly(List<String> words, List<String> exact) {
    final rest = [for (final w in words) if (!exact.contains(w)) w];
    final base = rest.isEmpty ? (patch: null, issues: const <String>[]) : patch(rest);
    final issues = [...base.issues];
    final out = _copyMap(base.patch ?? const {});
    final before = [for (final x in _without.issues) x.message];
    for (final w in exact) {
      final read = parse(mediaLineText(parentType, line, [w]));
      for (final x in read.issues) {
        if (!before.contains(x.message)) issues.add(x.message);
      }
      final node = mediaLineNode(read.document);
      if (node == null) continue;
      final path = w.substring(0, w.indexOf('=')).split('.');
      Object? v = node;
      for (final k in path) {
        v = v is Map ? v[k] : null;
      }
      Json into = out;
      for (final k in path.take(path.length - 1)) {
        final cur = into[k];
        final Json next = cur is Map ? cur.cast<String, Object?>() : <String, Object?>{};
        into = into[k] = next;
      }
      into[path.last] = v;
    }
    if (out.isEmpty) return (patch: null, issues: issues);
    return (patch: dropBindings ? mediaDropBindings(out, bound) : out, issues: issues);
  }
}

/// The two lines a rule's patch is worked out from, read alone: [line]
/// under a line of its parent's kind ([parentType]), with and without the
/// rule's [words].
String mediaLineText(String? parentType, String line, [List<String> words = const []]) =>
    '${parentType == 'row' ? 'Row' : 'Column'}#mediaParent__\n  ${[line, ...words].join(' ')}';

/// The node of [document] that [mediaLineText]'s line expanded to.
Json? mediaLineNode(Json document) {
  final nodes = readMap(document['nodes']) ?? const {};
  final kids = readStrings(readMap(nodes['mediaParent__'])?['children']);
  return kids.isEmpty ? null : readMap(nodes[kids.first]);
}
