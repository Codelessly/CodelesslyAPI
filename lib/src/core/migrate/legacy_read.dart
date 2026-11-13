// The lenient readers the schema-2 decoders used, for the migration's steps:
// they read legacy keys exactly as the decoders did before schema 3.
import 'dart:convert' show jsonDecode;
import 'dart:math' as math;

import '../behaviors.dart';
import '../json.dart';
import '../values/color.dart';
import 'migrate.dart';

/// A legacy JSON object read as the schema-2 decoders read it.
extension type const LegacyReader(Json m) {
  double d(String k, double fallback) => readDouble(m[k]) ?? fallback;
  double? dn(String k) => readDouble(m[k]);
  int i(String k, int fallback) => readInt(m[k]) ?? fallback;
  int ms(String k, int fallback) => math.max(0, readInt(m[k]) ?? fallback);
  bool b(String k, bool fallback) => readBool(m[k]) ?? fallback;
  String s(String k, [String fallback = '']) => readString(m[k]) ?? fallback;
  T e<T extends Enum>(List<T> values, String k, T fallback) => readEnum(values, m[k], fallback);
  AnimationCurve curve(String k, AnimationCurve fallback) => AnimationCurve.parse(m[k]) ?? fallback;
  Color? color(String k) => Color.fromJson(m[k]);
  List<double> doubles(String k) => [...?readList(m[k])?.map(readDouble).nonNulls];
}

/// [v], or the JSON [v] holds as text (a bound list given as JSON text).
Object? jsonText(Object? v) {
  if (v is! String) return v;
  try {
    return jsonDecode(v);
  } catch (_) {
    return null;
  }
}

/// A bound switch read loosely: true, 1, `on`, `true`.
bool? loose(Object? v) => switch (v) {
      final bool b => b,
      final num n => n != 0,
      final String s => switch (s.trim().toLowerCase()) {
          'true' || 'on' || '1' => true,
          'false' || 'off' || '0' || '' => false,
          _ => null,
        },
      _ => null,
    };

/// [v] for a params map: whole numbers as ints, others unrounded.
num jsonNum(double v) => v == v.roundToDouble() && v.abs() < 1e15 ? v.toInt() : v;

/// The formula of binding [expression]: `${= f}` → `f`, `${path}` → `path`,
/// a number → itself; null for anything else (text around it).
String? formulaOf(String expression) {
  final t = expression.trim();
  if (num.tryParse(t) != null) return t;
  final f = RegExp(r'^\$\{=\s*([^]*)\}$').firstMatch(t);
  if (f != null && !f[1]!.contains(r'${')) return f[1]!.trim();
  final p = RegExp(r'^\$\{([^{}=]+)\}$').firstMatch(t);
  return p?[1]!.trim();
}

/// A node's `bind` map (string values only), as the decoders read it.
Map<String, String> bindOf(Json node) => {
      for (final e in (readMap(node['bind']) ?? const <String, Object?>{}).entries)
        if (e.value is String) e.key: e.value as String,
    };

/// Sets [node]'s `bind` to [bind] (removed when empty) and reports the keys
/// that changed.
void putBind(Json node, Map<String, String> bind, MigrationScope s) {
  final before = bindOf(node);
  if (jsonEquality.equals(before, bind)) return;
  final raw = readMap(node['bind']) ?? const <String, Object?>{};
  // Keys that weren't text (dropped by the decoder) are kept as they were.
  final kept = {for (final e in raw.entries) if (e.value is! String) e.key: e.value};
  for (final k in {...before.keys, ...bind.keys}) {
    if (before[k] != bind[k]) s.rewrite('/bind/${k.replaceAll('~', '~0').replaceAll('/', '~1')}', before[k], bind[k]);
  }
  final out = {...kept, ...bind};
  if (out.isEmpty) {
    node.remove('bind');
  } else {
    node['bind'] = out;
  }
}

/// Sets [node]`[key]` to [value] (removes it for null), reporting it when it
/// changes.
void putKey(Json node, String key, Object? value, MigrationScope s, {String? path}) {
  final old = node[key];
  if (jsonEquality.equals(old, value) && (value != null || !node.containsKey(key))) return;
  s.rewrite(path ?? '/$key', old, value);
  if (value == null) {
    node.remove(key);
  } else {
    node[key] = value;
  }
}

/// Calls [visit] with every map inside [json] (depth first, [json] itself
/// first) and its JSON pointer from [at].
void eachMap(Object? json, void Function(Json map, String at) visit, [String at = '']) {
  if (json is Map) {
    final m = readMap(json)!;
    visit(m, at);
    for (final e in m.entries) {
      eachMap(e.value, visit, '$at/${e.key}');
    }
  } else if (json is List) {
    for (var i = 0; i < json.length; i++) {
      eachMap(json[i], visit, '$at/$i');
    }
  }
}
