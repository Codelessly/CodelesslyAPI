// Binding paths: what a key of `Node.bind` names, and how a value lands
// there. See DESIGN.md §5.1 for the grammar and the catalogue.
//
// Values arrive as whatever an expression gave (a number, text, a bool, a
// list, a map) and are read loosely, as v1 read them: `"12"` is a number,
// `1` is true, `"#F00"`... is a color. A value that can't be read leaves the
// node as it was. The common paths (visibility, opacity, layout, paints,
// radius, stroke width, top-level props, text style) are set on the typed
// model directly; the rest (nested props, behaviours) through that one
// value's JSON.
import 'json.dart';
import 'layout.dart';
import 'decoration.dart';
import 'node.dart';
import 'props.dart';
import 'values/color.dart';
import 'values/geometry.dart';
import 'values/paint.dart';
import 'values/text.dart';
import 'widgets/text.dart';
import 'behaviours.dart';

/// One step of a binding path: a key, an index (`[2]`), or every item (`*`).
typedef PathKey = Object;

/// The wildcard key: every item of a list.
const String everyItem = '*';

/// Binding paths (keys of [Node.bind]) and how values are applied to them.
abstract final class BindPaths {
  static const visible = 'visible';
  static const opacity = 'opacity';
  static const width = 'layout.width';
  static const height = 'layout.height';
  static const flex = 'layout.flex';
  static const rotation = 'layout.rotation';
  static const margin = 'layout.margin';
  static const padding = 'layout.padding';
  static const x = 'layout.x';
  static const y = 'layout.y';
  static const radius = 'decoration.radius';
  static const strokeWidth = 'decoration.strokeWidth';
  static const scale = 'scale';
  static const textDirection = 'textDirection';

  /// The items a repeating widget (list, grid, page view) builds one per.
  static const data = 'data';

  /// `props.<key>`.
  static String prop(String key) => 'props.$key';

  /// A fill by paint id: the whole paint (a color gives a solid paint).
  static String fill(String paintId) => 'decoration.fills.$paintId';

  /// A stroke by paint id.
  static String stroke(String paintId) => 'decoration.strokes.$paintId';

  /// [path] split into keys: names, `[n]` indices, `*`. Empty when it
  /// isn't a path.
  static List<PathKey> parse(String path) {
    final out = <PathKey>[];
    for (final part in path.split('.')) {
      final m = _segment.firstMatch(part);
      if (m == null) return const [];
      if (m[1]!.isNotEmpty) out.add(m[1]!);
      for (final i in _index.allMatches(m[2] ?? '')) {
        out.add(int.parse(i[1]!));
      }
      if (m[1]!.isEmpty && (m[2] ?? '').isEmpty) return const [];
    }
    return out;
  }

  static final RegExp _segment = RegExp(r'^([A-Za-z0-9_\-*$@:#]*)((?:\[\d+\])*)$');
  static final RegExp _index = RegExp(r'\[(\d+)\]');

  /// [node] with [value] at binding [path]; [node] itself when the path or
  /// the value doesn't apply.
  static Node apply(Node node, String path, Object? value) {
    if (value == null) return node;
    final keys = parse(path);
    if (keys.isEmpty) return node;
    try {
      return _apply(node, keys, value) ?? node;
    } catch (_) {
      return node;
    }
  }

  static Node? _apply(Node n, List<PathKey> keys, Object value) {
    final head = keys.first;
    final rest = keys.sublist(1);
    switch (head) {
      case 'visible' when rest.isEmpty:
        return BindValue.boolean(value)?.let((v) => v == n.visible ? n : n.copyWith(visible: v));
      case 'opacity' when rest.isEmpty:
        return BindValue.number(value)?.let((v) => n.copyWith(opacity: v.clamp(0, 1).toDouble()));
      case 'layout':
        return _layout(n, rest, value);
      case 'decoration':
        return _decoration(n, rest, value);
      case 'props':
        return _props(n, rest, value);
      case 'data':
        // Read by the runtime (the items of a repeating widget): the node
        // itself doesn't hold it.
        return null;
    }
    if (head is String && Behaviours.keys.contains(head)) {
      final j = <String, Object?>{};
      n.behaviours.writeTo(j);
      final next = setJsonPath(j, keys, _jsonValue(value));
      return next == null ? null : n.copyWith(behaviours: Behaviours.fromJson(next));
    }
    return null;
  }

  // --- layout ---------------------------------------------------------------

  static Node? _layout(Node n, List<PathKey> keys, Object value) {
    if (keys.isEmpty) return null;
    final l = n.layout;
    Layout? next;
    if (keys.length == 1) {
      next = switch (keys.first) {
        'width' => _axisSize(l.width, value)?.let((w) => l.copyWith(width: w)),
        'height' => _axisSize(l.height, value)?.let((h) => l.copyWith(height: h)),
        // A row/column needs a positive flex (v1: at least 1).
        'flex' => BindValue.number(value)?.let((f) => l.copyWith(flex: f.round() < 1 ? 1 : f.round())),
        'rotation' => BindValue.number(value)?.let((r) => l.copyWith(rotation: r)),
        'margin' => BindValue.insets(value)?.let((m) => l.copyWith(margin: m)),
        'padding' => BindValue.insets(value)?.let((p) => l.copyWith(padding: p)),
        'x' => _position(value)?.let((p) => l.copyWith(x: p)),
        'y' => _position(value)?.let((p) => l.copyWith(y: p)),
        'aspectRatio' => BindValue.number(value)?.let((r) => l.copyWith(aspectRatio: () => r > 0 ? r : null)),
        _ => null,
      };
    }
    // A typed field whose value can't be read stays as it was.
    if (next == null && keys.length == 1 && _typedLayout.contains(keys.first)) return null;
    if (next == null) {
      final j = setJsonPath(l.toJson(), keys, _jsonValue(value));
      next = j == null ? null : Layout.fromJson(j);
    }
    return next == null || next == l ? null : n.copyWith(layout: next);
  }

  static const _typedLayout = {'width', 'height', 'flex', 'rotation', 'margin', 'padding', 'x', 'y', 'aspectRatio'};

  /// A number sets the design size (the fit stays); `{"fill": 200}` and
  /// the like set both.
  static AxisSize? _axisSize(AxisSize current, Object value) {
    if (BindValue.number(value) case final double v) return current.withValue(v < 0 ? 0 : v);
    if (readMap(value) != null) return AxisSize.fromJson(value, fallback: current.value);
    return null;
  }

  /// A number is a distance from the start of the parent's padded box;
  /// a map is a position (`{"end": 8}`, `{"align": 0.5}`).
  static AxisPosition? _position(Object value) {
    if (BindValue.number(value) case final double v) return AxisPosition.start(v);
    if (readMap(value) != null) return AxisPosition.fromJson(value);
    return null;
  }

  // --- decoration -----------------------------------------------------------

  static Node? _decoration(Node n, List<PathKey> keys, Object value) {
    if (keys.isEmpty) return null;
    final d = n.decoration;
    Decoration? next;
    switch (keys.first) {
      case 'radius' when keys.length == 1:
        next = BindValue.radius(value)?.let((r) => d.copyWith(radius: r));
      case 'strokeWidth' when keys.length == 1:
        next = BindValue.number(value)?.let((w) => d.copyWith(strokeWidth: w < 0 ? 0 : w));
      case 'fills' || 'strokes' || 'foregroundFills':
        final key = keys.first as String;
        final list = switch (key) { 'fills' => d.fills, 'strokes' => d.strokes, _ => d.foregroundFills };
        final paints = _paints(list, keys.sublist(1), value);
        if (paints != null) {
          next = switch (key) {
            'fills' => d.copyWith(fills: paints),
            'strokes' => d.copyWith(strokes: paints),
            _ => d.copyWith(foregroundFills: paints),
          };
        }
      case 'effects':
        final effects = _effects(d.effects, keys.sublist(1), value);
        if (effects != null) next = d.copyWith(effects: effects);
    }
    if (next == null && keys.length == 1 && (keys.first == 'radius' || keys.first == 'strokeWidth')) return null;
    if (next == null && (keys.first == 'fills' || keys.first == 'strokes' || keys.first == 'foregroundFills' || keys.first == 'effects')) {
      return null;
    }
    if (next == null) {
      final j = setJsonPath(d.toJson(), keys, _jsonValue(value));
      next = j == null ? null : Decoration.fromJson(j);
    }
    return next == null || next == d ? null : n.copyWith(decoration: next);
  }

  /// [paints] with the paint [keys] selects (`[i]`, a paint id or `*`)
  /// changed: the whole paint, or a field of it (`color`, `opacity`,
  /// `visible`, `image.url`...).
  static List<Paint>? _paints(List<Paint> paints, List<PathKey> keys, Object value) {
    if (keys.isEmpty) {
      // The whole list: a list of paints, or one color/paint for all.
      if (value is List) return [...value.map(Paint.fromJson).nonNulls];
      return null;
    }
    final sel = keys.first;
    final rest = keys.sublist(1);
    final indices = _select(paints.length, sel, (i) => paints[i].id);
    final out = [...paints];
    // The first paint of an empty list: bound onto nothing, it's added.
    if (indices.isEmpty && sel == 0 && rest.isEmpty) {
      final p = BindValue.paint(value, null);
      return p == null ? null : [p];
    }
    if (indices.isEmpty) return null;
    var changed = false;
    for (final i in indices) {
      final p = _paint(out[i], rest, value);
      if (p != null && p != out[i]) {
        out[i] = p;
        changed = true;
      }
    }
    return changed ? out : null;
  }

  static Paint? _paint(Paint p, List<PathKey> keys, Object value) {
    if (keys.isEmpty) return BindValue.paint(value, p);
    if (keys.length == 1) {
      switch (keys.first) {
        case 'color':
          return BindValue.color(value)?.let((c) => Paint(
                id: p.id,
                visible: p.visible,
                opacity: p.opacity,
                blendMode: p.blendMode,
                color: c,
              ));
        case 'visible':
          return BindValue.boolean(value)?.let((v) => Paint.fromJson({...p.toJson(), 'visible': v}));
        case 'opacity':
          return BindValue.number(value)?.let((o) => Paint.fromJson({...p.toJson(), 'opacity': o.clamp(0, 1)}));
      }
    }
    // A gradient stop's color keeps the stop's own alpha for `#RRGGBB`.
    if (keys.length == 3 && keys[0] == 'stops' && keys[1] is int && keys[2] == 'color') {
      final i = keys[1] as int;
      if (i >= p.stops.length) return null;
      final s = p.stops[i];
      final text = value is String ? value.trim() : null;
      var c = BindValue.color(value);
      if (c == null) return null;
      if (text != null && RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(text)) c = c.withAlpha(s.color.alpha);
      final j = p.toJson();
      final stops = [for (final st in p.stops) st.toJson()];
      stops[i] = {...stops[i], 'color': c.toJson()};
      j['stops'] = stops;
      return Paint.fromJson(j);
    }
    final j = setJsonPath(p.toJson(), keys, _jsonValue(value));
    return j == null ? null : Paint.fromJson(j);
  }

  static List<Effect>? _effects(List<Effect> effects, List<PathKey> keys, Object value) {
    if (keys.isEmpty) return value is List ? [...value.map(Effect.fromJson).nonNulls] : null;
    final indices = _select(effects.length, keys.first, (i) => effects[i].id);
    if (indices.isEmpty) return null;
    final rest = keys.sublist(1);
    final out = [...effects];
    var changed = false;
    for (final i in indices) {
      final e = out[i];
      final j = e.toJson();
      Object? v = _jsonValue(value);
      List<PathKey> at = rest;
      // offset.dx / offset.dy: Offset's JSON is [dx, dy].
      if (rest.length == 2 && rest[0] == 'offset' && (rest[1] == 'dx' || rest[1] == 'dy')) {
        final d = BindValue.number(value);
        if (d == null) continue;
        final o = readList(j['offset']) ?? const [0, 0];
        v = rest[1] == 'dx' ? [d, o.elementAtOrNull(1) ?? 0] : [o.elementAtOrNull(0) ?? 0, d];
        at = const ['offset'];
      } else if (rest.length == 1 && rest[0] == 'visible') {
        v = BindValue.boolean(value);
      } else if (rest.length == 1 && rest[0] == 'color') {
        v = BindValue.color(value)?.toJson();
      } else if (rest.length == 1 && (rest[0] == 'blurRadius' || rest[0] == 'spreadRadius')) {
        v = BindValue.number(value);
      }
      if (v == null) continue;
      final next = at.isEmpty ? readMap(v) : setJsonPath(j, at, v);
      final eff = next == null ? null : Effect.fromJson(next);
      if (eff != null && eff != e) {
        out[i] = eff;
        changed = true;
      }
    }
    return changed ? out : null;
  }

  /// The indices of a list of [length] that [sel] selects: `[i]`, `*`, or
  /// the item whose id ([idOf]) is [sel].
  static List<int> _select(int length, PathKey sel, String? Function(int) idOf) {
    if (sel is int) return sel < length ? [sel] : const [];
    if (sel == everyItem) return [for (var i = 0; i < length; i++) i];
    for (var i = 0; i < length; i++) {
      if (idOf(i) == sel) return [i];
    }
    return const [];
  }

  // --- props ----------------------------------------------------------------

  static Node? _props(Node n, List<PathKey> keys, Object value) {
    if (keys.isEmpty || keys.first is! String) return null;
    final spec = n.spec;
    final key = keys.first as String;
    final def = spec?.prop(key);
    final rest = keys.sublist(1);
    // A text's style field is every run's too (v1 set every span).
    if (n.type == TextProps.spec.type && key == 'style' && rest.length == 1 && rest.first is String) {
      return _textStyle(n, rest.first as String, value);
    }
    if (def == null) {
      final j = setJsonPath(n.props.toJson(spec), keys, _jsonValue(value));
      return j == null ? null : n.copyWith(props: Props.fromJson(spec, j));
    }
    Object? decoded;
    if (rest.isEmpty) {
      decoded = def.decode(_forCodec(def.codec, value));
      if (decoded == null && value is String && def.defaultValue is! String) return null;
      if (decoded == null && !_nullable(def)) return null;
    } else {
      final current = def.encode(n.props.get(def));
      final j = setJsonPath(current, rest, _jsonValue(value));
      if (j == null) return null;
      decoded = def.decode(j);
      if (decoded == null) return null;
    }
    final props = n.props.set(def, decoded);
    return props == n.props ? null : n.copyWith(props: props);
  }

  static bool _nullable(PropDef<Object?> def) => def.defaultValue == null;

  static Object? _forCodec(PropCodec<Object?> codec, Object value) => switch (codec) {
        BoolCodec() => BindValue.boolean(value),
        DoubleCodec() || OptionalDoubleCodec() => BindValue.number(value),
        IntCodec() || OptionalIntCodec() => BindValue.number(value)?.round(),
        StringCodec() => BindValue.text(value),
        EnumCodec() => value is String ? value.trim() : value,
        _ when identical(codec, Codecs.color) => BindValue.color(value)?.toJson(),
        _ when identical(codec, Codecs.insets) => BindValue.insets(value)?.toJson(),
        _ => _jsonValue(value),
      };

  static Node? _textStyle(Node n, String field, Object value) {
    final Object? v = switch (field) {
      'color' || 'decorationColor' => BindValue.color(value)?.toJson(),
      'fontSize' || 'letterSpacing' || 'height' || 'decorationThickness' => BindValue.number(value),
      'fontWeight' => BindValue.fontWeight(value),
      'fontFamily' => BindValue.text(value)?.trim().let((f) => f.isEmpty ? null : f),
      'decoration' => BindValue.textDecoration(value),
      _ => _jsonValue(value),
    };
    if (v == null) return null;
    TextStyle withField(TextStyle s) => TextStyle.fromJson({...s.toJson(), field: v});
    final style = n.prop(TextProps.style);
    final runs = n.prop(TextProps.runs);
    final nextStyle = withField(style);
    final nextRuns = [
      for (final r in runs) TextRun(r.start, r.end, withField(r.style), link: r.link),
    ];
    final next = n.withProp(TextProps.style, nextStyle).withProp(TextProps.runs, nextRuns);
    return next == n ? null : next;
  }

  static Object? _jsonValue(Object? value) => switch (value) {
        final Color c => c.toJson(),
        final Iterable<Object?> l when l is! List => l.toList(),
        _ => value,
      };
}

/// Sets [keys] in JSON [root] (copied along the way) to [value]. Maps are
/// created for missing keys; an index past a list's end (or a list missing)
/// fails. Null when it can't be set.
Object? setJsonPathValue(Object? root, List<PathKey> keys, Object? value) {
  if (keys.isEmpty) return value;
  final k = keys.first;
  final rest = keys.sublist(1);
  if (k is int) {
    final l = readList(root);
    if (l == null || k >= l.length) return null;
    final v = setJsonPathValue(l[k], rest, value);
    if (v == null && value != null) return null;
    return [...l]..[k] = v;
  }
  if (k == everyItem) {
    final l = readList(root);
    if (l == null) return null;
    return [for (final item in l) setJsonPathValue(item, rest, value) ?? item];
  }
  // A key into a list selects the item with that id.
  if (readList(root) case final List<Object?> l) {
    final i = l.indexWhere((item) => readMap(item)?['id'] == k);
    if (i < 0) return null;
    return setJsonPathValue(l, [i, ...rest], value);
  }
  final m = readMap(root) ?? const <String, Object?>{};
  final v = setJsonPathValue(m[k], rest, value);
  if (v == null && rest.isNotEmpty) return null;
  return {...m, k as String: v};
}

/// [setJsonPathValue] for a JSON object root.
Json? setJsonPath(Object? root, List<PathKey> keys, Object? value) => readMap(setJsonPathValue(root, keys, value));

/// Loose readers for bound values (what an expression gave), as v1 read
/// them. Each returns null for a value it can't read.
abstract final class BindValue {
  /// `true`/`false`, numbers (non-zero is true), and their text.
  static bool? boolean(Object? v) => switch (v) {
        final bool b => b,
        final num n => n != 0,
        final String s => switch (s.trim().toLowerCase()) {
            'true' => true,
            'false' => false,
            final t => num.tryParse(t)?.let((n) => n != 0),
          },
        _ => null,
      };

  /// A finite number, or numeric text.
  static double? number(Object? v) => switch (v) {
        final num n when n.isFinite => n.toDouble(),
        final bool b => b ? 1 : 0,
        final String s => double.tryParse(s.trim())?.let((d) => d.isFinite ? d : null),
        _ => null,
      };

  /// Text: scalars as text; lists and maps aren't.
  static String? text(Object? v) => switch (v) {
        final String s => s,
        final double d when d == d.roundToDouble() && d.abs() < 1e15 => '${d.toInt()}',
        final num n => '$n',
        final bool b => '$b',
        _ => null,
      };

  /// `#RRGGBB`, `#AARRGGBB`, `0xAARRGGBB`, `Color(0xAARRGGBB)`, an ARGB int,
  /// or a `{r, g, b, a}` map with 0–1 or 0–255 components.
  static Color? color(Object? v) {
    switch (v) {
      case final Color c:
        return c;
      case final int i:
        return Color(i);
      case final String s:
        var t = s.trim();
        final call = RegExp(r'^Color\((0x[0-9a-fA-F]{8})\)$').firstMatch(t);
        if (call != null) t = call[1]!;
        if (t.startsWith('0x') || t.startsWith('0X')) return int.tryParse(t.substring(2), radix: 16)?.let(Color.new);
        if (!RegExp(r'^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(t)) return null;
        return Color.fromJson(t.startsWith('#') ? t : '#$t');
      case final Map<Object?, Object?> m:
        final r = readDouble(m['r']), g = readDouble(m['g']), b = readDouble(m['b']);
        if (r == null || g == null || b == null) return null;
        final a = readDouble(m['a']) ?? 1;
        final unit = r <= 1 && g <= 1 && b <= 1 && a <= 1;
        int c(double x) => (unit ? x * 255 : x).round().clamp(0, 255);
        return Color.fromARGB(c(unit ? a : (m['a'] == null ? 255 : a)), c(r), c(g), c(b));
    }
    return null;
  }

  /// A paint: a paint's JSON, an image URL (an image that covers the
  /// node), or a color (solid; the paint keeps [current]'s id).
  static Paint? paint(Object? v, Paint? current) {
    if (v is Map) {
      final p = Paint.fromJson(v);
      if (p == null) return null;
      return p.id == null && current?.id != null ? Paint.fromJson({...p.toJson(), 'id': current!.id}) : p;
    }
    final c = color(v);
    if (c != null) return Paint.solid(c, id: current?.id);
    if (v is String && RegExp(r'^(https?:|data:|assets?/)').hasMatch(v.trim())) {
      return Paint.fromJson({
        'type': 'image',
        'id': ?current?.id,
        'image': {'url': v.trim(), 'fit': 'cover'},
      });
    }
    return null;
  }

  /// A number (every side), `[horizontal, vertical]`, `[l, t, r, b]`, or a
  /// map of sides (`{"top": 44}`, `{"horizontal": 8}`).
  static EdgeInsets? insets(Object? v) {
    if (number(v) case final double d) return EdgeInsets.all(d);
    if (readList(v) case final List<Object?> l) {
      final n = [...l.map(number)];
      if (n.any((x) => x == null)) return null;
      if (n.length == 2) return EdgeInsets.fromLTRB(n[0]!, n[1]!, n[0]!, n[1]!);
      if (n.length == 4) return EdgeInsets.fromLTRB(n[0]!, n[1]!, n[2]!, n[3]!);
      return null;
    }
    if (readMap(v) case final Json m) {
      final h = number(m['horizontal']), vt = number(m['vertical']), all = number(m['all']);
      return EdgeInsets.fromLTRB(
        number(m['left']) ?? h ?? all ?? 0,
        number(m['top']) ?? vt ?? all ?? 0,
        number(m['right']) ?? h ?? all ?? 0,
        number(m['bottom']) ?? vt ?? all ?? 0,
      );
    }
    return null;
  }

  /// A number (every corner) or `[topLeft, topRight, bottomRight,
  /// bottomLeft]`.
  static BorderRadius? radius(Object? v) {
    if (number(v) case final double d) return BorderRadius.circular(d < 0 ? 0 : d);
    final l = readList(v);
    if (l == null || l.length != 4) return null;
    final n = [...l.map(number)];
    if (n.any((x) => x == null)) return null;
    return BorderRadius.only(topLeft: n[0]!, topRight: n[1]!, bottomRight: n[2]!, bottomLeft: n[3]!);
  }

  /// 100–900, `w700`, `bold`, `normal`.
  static int? fontWeight(Object? v) {
    if (number(v) case final double d) return (d.round() ~/ 100 * 100).clamp(100, 900);
    if (v is! String) return null;
    final t = v.trim().toLowerCase();
    if (t == 'bold') return 700;
    if (t == 'normal' || t == 'regular') return 400;
    final m = RegExp(r'^w(\d00)$').firstMatch(t);
    return m == null ? null : int.parse(m[1]!);
  }

  /// `none`, `underline`, `overline`, `lineThrough` (`strikethrough`), or
  /// true (struck through) / false (none).
  static String? textDecoration(Object? v) {
    if (v is bool) return v ? 'lineThrough' : 'none';
    if (v is! String) return null;
    return switch (v.trim().toLowerCase()) {
      'none' || 'false' || '' => 'none',
      'underline' => 'underline',
      'overline' => 'overline',
      'linethrough' || 'line-through' || 'strikethrough' || 'true' => 'lineThrough',
      _ => null,
    };
  }
}
