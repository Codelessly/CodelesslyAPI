// A node's custom paint, animations and charts in the notation's words, for
// printNodeLine (print_fields.dart) and the walk (print.dart): the
// `animate=` word on the node's line, and the record lines under it
// (docs/design/22-notation-parity.md, 4.6):
//
//   box#mark w=30 h=30
//     customPaint viewBox=[28,28]
//       circle c=[14,18.5] radius=2.6 fill={theme.colors.onBrand}
//     animation#enter duration=520 curve=easeOutCubic
//       track path=opacity from=0 to=1
//
// Each line is checked by reading it back (readPaintRecord), and the whole
// of a node's records by expanding them under a line of their own: what
// does not read back exactly is not written, and stays in the node line's
// `{…}` tail.
import 'dart:convert';

import '../behavior_fields.dart' show AnimationTrackFields, NodeAnimationFields, TransitionFields;
import '../custom_paint.dart' show DrawOp;
import '../custom_paint_fields.dart' show CustomPaintFields, DrawOpCommonFields, DrawOpSpecs;
import '../json.dart';
import '../props.dart' show PropDef, PropKind;
import 'notation.dart';
import 'print_fields.dart';

/// The words for node [id]'s custom paint, animations and charts, each written after the line's fields;
/// empty when it has none or the notation has no word for them (they stay
/// in the line's `{…}` tail).
List<String> printPaint(String id, Json node, PrintContext context) => _printed(id, node, context).words;

/// The record lines under node [id]'s line (its `customPaint`, its
/// `animation`s and its `transition`s), each on a line of its own indented under a node at
/// [depth]: empty, or each line with the newline before it.
String printPaintLines(String id, Json node, PrintContext context, int depth) {
  final lines = _printed(id, node, context).lines;
  if (lines.isEmpty) return '';
  final pad = '  ' * (depth + 1);
  return [for (final l in lines) '\n$pad$l'].join();
}

/// The fields of [node] that [printPaint] and [printPaintLines] say
/// (`customPaint`, `animations`, `props.series`, `props.data`…): what a
/// node's other words leave to them.
Set<String> printPaintSays(String id, Json node, PrintContext context) => _printed(id, node, context).says;

typedef _Printed = ({List<String> words, List<String> lines, Set<String> says});

final _memo = Expando<Map<String, _Printed>>();

_Printed _printed(String id, Json node, PrintContext context) => (_memo[context] ??= {})[id] ??= _Printer(context)._node(node);

final _name = RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$');
final _word = RegExp(r'^[A-Za-z][A-Za-z0-9]*$');

final class _Printer {
  _Printer(this.context);
  final PrintContext context;

  List<Object?> get _screenVariables {
    final roots = readStrings(context.document['roots']);
    final screen = roots.isEmpty ? 'screen' : roots.first;
    return readList(readMap(context.document['variables'])?[screen]) ?? const [];
  }

  late final Map<String, Json> _variables = {
    for (final v in _screenVariables)
      if (v is Map && v['name'] is String) v['name'] as String: v.cast<String, Object?>(),
  };

  _Printed _node(Json node) {
    final words = <String>[];
    final lines = <String>[];
    final says = <String>{};
    final paint = readMap(node['customPaint']);
    if (paint != null) {
      final block = _customPaint(paint);
      if (block != null && _same(_expand('', block)?['customPaint'], paint)) {
        lines.addAll(block);
        says.add('customPaint');
      }
    }
    final animations = readList(node['animations']);
    if (animations != null && animations.isNotEmpty) {
      final preset = _preset(animations.first);
      final more = <String>[];
      var ok = true;
      for (final a in animations.skip(preset == null ? 0 : 1)) {
        final m = readMap(a);
        final l = m == null ? null : _animation(m);
        if (l == null) {
          ok = false;
          break;
        }
        more.addAll(l);
      }
      final head = preset == null ? '' : ' ${preset.join(' ')}';
      if (ok && _same(_expand(head, more)?['animations'], animations)) {
        words.addAll(preset ?? const []);
        lines.addAll(more);
        says.add('animations');
      }
    }
    final transitions = readList(node['transitions']);
    if (transitions != null && transitions.isNotEmpty) {
      final more = <String>[];
      for (final t in transitions) {
        final m = readMap(t);
        final line = m == null ? null : _record('transition', m, TransitionFields.all);
        if (line == null) break;
        more.add(line);
      }
      if (more.length == transitions.length && _same(_expand('', more)?['transitions'], transitions)) {
        lines.addAll(more);
        says.add('transitions');
      }
    }
    final points = _chart(node);
    if (points.isNotEmpty) says.addAll(const {'props.data', 'props.xField', 'props.yField', 'bind.props.data'});
    final lists = _chartLists(node, skip: points.isEmpty ? const {} : const {'data'});
    for (final w in [...points, ...lists]) {
      words.add(w);
      says.add('props.${w.substring(0, w.indexOf('='))}');
    }
    return (words: words, lines: lines, says: says);
  }

  // --- charts -------------------------------------------------------------------

  /// The chart types whose lists (series, reference lines, axis labels and
  /// ticks, zones, markers, values) are written here.
  static const _charts = {'chart', 'barChart', 'lineChart', 'plotChart', 'radialGauge', 'gaugeMeter'};

  /// A chart's list props by their own names, as JSON (`series=[{…}]`,
  /// `referenceLines=[…]`), each read back before it is written.
  List<String> _chartLists(Json node, {required Set<String> skip}) {
    final type = node['type'];
    if (type is! String || !_charts.contains(type)) return const [];
    final props = readMap(node['props']) ?? const {};
    final out = <String>[];
    for (final p in context.catalog.widget(type)?.props ?? const <PropDef<Object?>>[]) {
      final v = props[p.key];
      if (p.type.kind != PropKind.list || v is! List || skip.contains(p.key)) continue;
      final word = '${p.key}=${jsonEncode(v)}';
      if (_same(readMap(_expand(' $word', const [], type: type)?['props'])?[p.key], v)) out.add(word);
    }
    return out;
  }

  /// A line chart's points as the `values=[…]` (or `values={…}`) they were
  /// written as: `{"x": i, "y": v}` under `xField` x and `yField` y.
  List<String> _chart(Json node) {
    if (node['type'] != 'lineChart') return const [];
    final props = readMap(node['props']) ?? const {};
    if (props['xField'] != 'x' || props['yField'] != 'y') return const [];
    final bind = readMap(node['bind']) ?? const {};
    String? word;
    final data = readList(props['data']);
    final bound = bind['props.data'];
    if (data != null && data.isNotEmpty && !bind.containsKey('props.data')) {
      final ys = <Object?>[];
      for (var i = 0; i < data.length; i++) {
        final d = readMap(data[i]);
        if (d == null || d.length != 2 || d['x'] != i || d['y'] is! num) return const [];
        ys.add(d['y']);
      }
      word = 'values=${jsonEncode(ys)}';
    } else if (bound is String) {
      final m = RegExp(r'^\$\{= map\(range\(length\((.+)\)\), i => \{"x": i, "y": \((.+)\)\[i\]\}\)\}$').firstMatch(bound);
      if (m == null || m[1] != m[2]) return const [];
      word = 'values={${m[1]}}';
    }
    if (word == null) return const [];
    final got = _expand(' $word', const [], type: 'lineChart');
    final gotProps = readMap(got?['props']) ?? const {};
    final ok = got != null &&
        _same(gotProps['data'], props['data']) &&
        gotProps['xField'] == 'x' &&
        gotProps['yField'] == 'y' &&
        _same(readMap(got['bind'])?['props.data'], bind['props.data']);
    return ok ? [word] : const [];
  }

  /// The node a line of [type] with [head] after it and [lines] under it
  /// reads as, with this document's variables; null when anything is said
  /// of it.
  Json? _expand(String head, List<String> lines, {String type = 'Column'}) {
    final text = [
      for (final v in _screenVariables)
        if (v is Map && v['name'] is String) 'state ${v['name']}=${jsonEncode(v['value'])}',
      '$type#paint_check$head',
      for (final l in lines) '  $l',
    ].join('\n');
    try {
      final r = parseNotation(text, catalog: context.catalog, options: context.options);
      if (r.issues.isNotEmpty) return null;
      return readMap(readMap(r.document['nodes'])?['paint_check']);
    } on Object {
      return null;
    }
  }

  // --- animations ---------------------------------------------------------------

  /// `animate=<word> duration=… delay=…` when [a] is what that word gives.
  List<String>? _preset(Object? a) {
    final m = readMap(a);
    if (m == null || m['id'] != 'a') return null;
    final rest = {...m}..remove('id');
    final duration = rest.remove('duration'), delay = rest.remove('delay');
    if ((duration != null && duration is! int) || (delay != null && delay is! int)) return null;
    for (final e in notationAnimations.entries) {
      if (!_same(rest, e.value)) continue;
      return ['animate=${e.key}', if (duration != null) 'duration=$duration', if (delay != null) 'delay=$delay'];
    }
    return null;
  }

  /// An `animation` line and its `track` lines under it.
  List<String>? _animation(Json a) {
    final tracks = readList(a['tracks']);
    final under = <String>[];
    var trackLines = tracks != null && tracks.isNotEmpty;
    if (tracks != null && trackLines) {
      for (final t in tracks) {
        final m = readMap(t);
        final line = m == null ? null : _record('track', m, AnimationTrackFields.all);
        if (line == null) {
          trackLines = false;
          under.clear();
          break;
        }
        under.add('  $line');
      }
    }
    final head = _record('animation', {...a}..removeWhere((k, _) => k == 'tracks' && trackLines), NodeAnimationFields.all);
    if (head == null) return null;
    return [head, ...under];
  }

  // --- custom paint -------------------------------------------------------------

  /// A `customPaint` line and its ops under it.
  List<String>? _customPaint(Json paint) {
    final head = {...paint};
    final under = <String>[];
    final painter = readList(paint['painter']), front = readList(paint['foregroundPainter']);
    if (painter != null && painter.isNotEmpty) {
      final lines = _ops(painter);
      if (lines != null) {
        under.addAll(lines);
        head.remove('painter');
      }
    }
    if (front != null) {
      final lines = _ops(front);
      if (lines != null) {
        under
          ..add('foregroundPainter')
          ..addAll([for (final l in lines) '  $l']);
        head.remove('foregroundPainter');
      }
    }
    final line = _record('customPaint', head, CustomPaintFields.all);
    if (line == null) return null;
    return [line, for (final l in under) '  $l'];
  }

  /// The lines of [ops], each op's own under it; null when one has no line.
  List<String>? _ops(List<Object?> ops) {
    final out = <String>[];
    for (final o in ops) {
      final m = readMap(o);
      final lines = m == null ? null : _op(m);
      if (lines == null) return null;
      out.addAll(lines);
    }
    return out;
  }

  /// An op's line, and a group's or a repeat's ops under it.
  List<String>? _op(Json op) {
    final name = op['op'];
    if (name is! String || !_word.hasMatch(name)) return null;
    final spec = DrawOpSpecs.of(DrawOp.opName(name) ?? name);
    if (spec == null) return null;
    final children = readList(op['ops']);
    final nested = (spec.op == 'group' || spec.op == 'repeat') && children != null && children.isNotEmpty;
    final under = nested ? _ops(children) : null;
    final own = {...op}..remove('op');
    if (under != null) own.remove('ops');
    final fields = [...DrawOpCommonFields.all, ...spec.fields];
    final want = {...own, 'op': name};
    for (final plain in [false, true]) {
      final line = _opLine(name, spec.op, own, fields, plain: plain);
      if (_reads('op', line, want)) return [line, for (final l in under ?? const <String>[]) '  $l'];
    }
    // Its fields as the line's {…}, as a node's are.
    var head = name;
    final rest = {...own};
    if (rest['id'] case final String id when _name.hasMatch(id)) {
      head = '$name#$id';
      rest.remove('id');
    }
    final line = rest.isEmpty ? head : '$head ${jsonEncode(rest)}';
    if (!_reads('op', line, want)) return null;
    return [line, for (final l in under ?? const <String>[]) '  $l'];
  }

  String _opLine(String name, String op, Json own, List<PropDef<Object?>> fields, {required bool plain}) {
    final kinds = {for (final f in fields) f.key: f.type.kind};
    final rest = {...own};
    final words = <String>[];
    var head = name;
    if (rest['id'] case final String id when _name.hasMatch(id)) {
      head = '$name#$id';
      rest.remove('id');
    }
    final main = switch (op) {
      'paragraph' => 'text',
      'image' => 'url',
      _ => null,
    };
    if (main != null && rest[main] is String) {
      final s = _string(rest[main]! as String, plain: plain);
      if (s != null) {
        words.add(s);
        rest.remove(main);
      }
    }
    final tail = <String, Object?>{};
    for (final e in rest.entries) {
      final key = e.key, v = e.value;
      if (!kinds.containsKey(key)) {
        tail[key] = v;
        continue;
      }
      if (key == 'paint') {
        final paint = _paint(v, plain: plain);
        if (paint != null) {
          words.addAll(paint);
          continue;
        }
      }
      if (v == true && kinds[key] == PropKind.boolean) {
        words.add(key);
        continue;
      }
      final w = _value(v, plain: plain);
      if (w == null) {
        tail[key] = v;
      } else {
        words.add('$key=$w');
      }
    }
    return [head, ...words, if (tail.isNotEmpty) jsonEncode(tail)].join(' ');
  }

  /// An op's paint as `fill=` and `stroke=` (with the stroke's own fields).
  List<String>? _paint(Object? paint, {required bool plain}) {
    Map<Object?, Object?>? strokeOf(Object? p) => p is Map &&
            p['style'] == 'stroke' &&
            p.containsKey('color') &&
            p.keys.every((k) => k == 'color' || k == 'style' || notationStrokeWords.contains(k) || notationPaintWords.contains(k))
        ? p
        : null;
    // The fields every paint of the op shares (`blurRadius`), written once.
    Map<Object?, Object?> shared(Map<Object?, Object?> p) => {
          for (final e in p.entries)
            if (notationPaintWords.contains(e.key)) e.key: e.value,
        };
    List<String>? stroke(Map<Object?, Object?> s) {
      final out = <String>[];
      for (final e in s.entries) {
        if (e.key == 'style' || notationPaintWords.contains(e.key)) continue;
        final w = _value(e.value, plain: plain);
        if (w == null) return null;
        out.add('${e.key == 'color' ? 'stroke' : e.key}=$w');
      }
      return out;
    }

    List<String>? words(Map<Object?, Object?> fields) {
      final out = <String>[];
      for (final e in fields.entries) {
        final w = _value(e.value, plain: plain);
        if (w == null) return null;
        out.add('${e.key}=$w');
      }
      return out;
    }

    bool solid(Object? p) => p is! Map && p is! List;
    // A fill with only the shared fields beside its color: its color, and
    // the fields.
    (Object?, Map<Object?, Object?>)? fillOf(Object? p) {
      if (solid(p)) return (p, const {});
      if (p is Map && p.containsKey('color') && p.keys.every((k) => k == 'color' || notationPaintWords.contains(k)) && solid(p['color'])) {
        return (p['color'], shared(p));
      }
      return null;
    }

    bool sameFields(Map<Object?, Object?> a, Map<Object?, Object?> b) => a.length == b.length && a.entries.every((e) => jsonEquality.equals(b[e.key], e.value));
    if (paint is List && paint.length == 2 && fillOf(paint.first) != null && strokeOf(paint.last) != null) {
      final (color, fields) = fillOf(paint.first)!;
      final s = strokeOf(paint.last)!;
      if (!sameFields(fields, shared(s))) return null;
      final f = _value(color, plain: plain), sw = stroke(s), fw = words(fields);
      return f == null || sw == null || fw == null ? null : ['fill=$f', ...sw, ...fw];
    }
    if (strokeOf(paint) case final Map<Object?, Object?> s) {
      final sw = stroke(s), fw = words(shared(s));
      return sw == null || fw == null ? null : [...sw, ...fw];
    }
    if (fillOf(paint) case (final color, final fields)) {
      final f = _value(color, plain: plain), fw = words(fields);
      return f == null || fw == null ? null : ['fill=$f', ...fw];
    }
    return null;
  }

  // --- records and values -------------------------------------------------------

  /// `[head][#id] key=value … [{…}]` for [record], its keys the declared
  /// [fields] (any other in the `{…}`); null when it does not read back.
  String? _record(String head, Json record, List<PropDef<Object?>> fields) {
    final kinds = {for (final f in fields) f.key: f.type.kind};
    for (final plain in [false, true]) {
      final rest = {...record};
      var start = head;
      if (rest['id'] case final String id when kinds.containsKey('id') && _name.hasMatch(id)) {
        start = '$head#$id';
        rest.remove('id');
      }
      final words = <String>[start];
      final tail = <String, Object?>{};
      for (final e in rest.entries) {
        if (!kinds.containsKey(e.key)) {
          tail[e.key] = e.value;
          continue;
        }
        if (e.value == true && kinds[e.key] == PropKind.boolean) {
          words.add(e.key);
          continue;
        }
        final w = _value(e.value, plain: plain);
        if (w == null) {
          tail[e.key] = e.value;
        } else {
          words.add('${e.key}=$w');
        }
      }
      if (tail.isNotEmpty) words.add(jsonEncode(tail));
      final line = words.join(' ');
      if (_reads(head, line, record)) return line;
    }
    return null;
  }

  bool _reads(String kind, String line, Json want) {
    final issues = <NotationIssue>[];
    final got = readPaintRecord(kind, line, catalog: context.catalog, options: context.options, variables: _variables, issues: issues);
    return issues.isEmpty && got != null && _same(got, want);
  }

  /// [v] as a word's value that reads back as it (design 22, 4.6), or null.
  /// [plain]: lists as JSON and expressions in quotes, as they are held.
  String? _value(Object? v, {required bool plain}) {
    if (v == null || v is bool || v is num) return '$v';
    if (v is String) {
      if (!plain) {
        final braced = _braced(v);
        if (braced != null) return braced;
      }
      if (RegExp(r'^(#[0-9A-Fa-f]{6,8}|[A-Za-z_][A-Za-z0-9_.]*)$').hasMatch(v) && !const {'true', 'false', 'null'}.contains(v)) return v;
      return _string(v, plain: plain);
    }
    if (v is Map) return jsonEncode(v);
    if (v is List) {
      final json = jsonEncode(v);
      if (plain || !json.contains(r'${')) return json;
      final items = <String>[];
      for (final e in v) {
        final w = e is String ? (_braced(e) ?? _string(e, plain: false)) : _value(e, plain: false);
        if (w == null) return json;
        items.add(w);
      }
      return '[${items.join(',')}]';
    }
    return null;
  }

  /// `${name}` as `{name}`, `${= e}` as `{e}`; null for any other string.
  static String? _braced(String s) {
    if (!s.startsWith(r'${') || !s.endsWith('}')) return null;
    final inner = s.startsWith(r'${= ') ? s.substring(4, s.length - 1) : s.substring(2, s.length - 1);
    if (inner.trim().isEmpty || inner.contains('\n')) return null;
    return '{$inner}';
  }

  /// [s] quoted, when it reads back as it: each `${…}` in it as the `{…}`
  /// that reads it (not when [plain]: as it is held), and no other brace.
  static String? _string(String s, {bool plain = true}) {
    if (!s.contains('{')) return jsonEncode(s);
    if (plain) return s.contains(r'${') ? jsonEncode(s) : null;
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '{' || c == '}') return null;
      if (c != r'$' || i + 1 >= s.length || s[i + 1] != '{') {
        out.write(c);
        continue;
      }
      var depth = 0, end = -1;
      for (var j = i + 1; j < s.length; j++) {
        if (s[j] == '{') depth++;
        if (s[j] == '}' && --depth == 0) {
          end = j;
          break;
        }
      }
      final braced = end < 0 ? null : _braced(s.substring(i, end + 1));
      if (braced == null) return null;
      out.write(braced);
      i = end;
    }
    return jsonEncode(out.toString());
  }

  static bool _same(Object? a, Object? b) => jsonEquality.equals(a, b);
}
