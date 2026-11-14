// Checks one JSON value against a declaration's PropType (and codec): the
// strict reading of what the lenient decoders accept. Every rule here
// mirrors a decoder: what it reads, what it silently replaces.
import '../core/custom_paint.dart' show Expr;
import '../core/custom_paint_fields.dart' show ExprCodec;
import '../core/json.dart';
import '../core/props.dart';
import '../core/values/geometry.dart';
import '../core/theme.dart';
import '../core/values/color.dart';
import '../core/values/text.dart';
import 'diagnostic.dart';

/// Collects diagnostics for one document.
final class Reporter {
  final List<Diagnostic> out = [];
  String? node;

  void add(DiagnosticCode code, String path, String message, {String? suggestion, String? nodeId}) =>
      out.add(Diagnostic(code, path, message, nodeId: nodeId ?? node, suggestion: suggestion));
}

/// Hook for values whose JSON is free-form in the declarations but has a
/// known meaning (nested action chains, reactions, predicates): called with
/// the [PropType] name and the value; returns true when it checked it.
typedef JsonValueHook = bool Function(PropDef<Object?>? def, PropType type, Object? json, String path);

String describe(Object? v) => switch (v) {
      null => 'null',
      bool() => 'a boolean ($v)',
      num() => 'a number ($v)',
      String() => 'the text "${v.length > 40 ? '${v.substring(0, 40)}...' : v}"',
      List() => 'a list of ${v.length}',
      Map() => 'an object',
      _ => '$v',
    };

/// The JSON forms each value type reads, as a reader would write them.
const Map<String, String> valueForms = {
  'Color': '"#AARRGGBB" or "#RRGGBB" (hex, alpha first)',
  'EdgeInsets': 'a number (all sides) or [left, top, right, bottom]',
  'BorderRadius': 'a number (every corner), [x, y] (every corner elliptical) or [topLeft, topRight, bottomRight, bottomLeft] (each a number or [x, y])',
  'Alignment': '[x, y] from -1 to 1, or a name: topLeft, topCenter, topRight, centerLeft, center, centerRight, bottomLeft, bottomCenter, bottomRight',
  'Offset': '[dx, dy]',
  'BoxConstraints': '{"minWidth", "maxWidth", "minHeight", "maxHeight"} (each optional, numbers >= 0)',
  'AxisSize': 'a number (fixed) or {"fill"|"flexible"|"hug"|"fixed": number}',
  'AxisPosition': 'a number (distance from the start) or {"start": d}, {"end": d}, {"start": a, "end": b}, {"align": -1..1}, {"relative": d}',
  'FontWeight': '100, 200 ... 900',
  'FontFeature': 'an OpenType tag ("tnum", "ss01") or "tag=value" ("liga=0")',
  'Rect': '[left, top, width, height]',
  'IconData': 'a Material icon name ("check_circle", "lock_open_rounded"), an image URL, or {"type": "MATERIAL_ICON", "name", "style"}',
  'Size': '[width, height]',
};

final class ValueChecker {
  ValueChecker(this.r, {this.hook, this.theme});
  final Reporter r;
  final JsonValueHook? hook;

  /// The project's theme: the colors and text styles names may refer to
  /// (null: names are checked as names only).
  final ThemeTokens? theme;

  void _colorName(String name, String path) {
    final t = theme;
    if (t != null && t.color(name) != null) return;
    final names = t?.colorNames.toList() ?? const <String>[];
    r.add(Codes.unknownThemeName, path,
        names.isEmpty
            ? '"$name" is not a color: write "#AARRGGBB", or declare "$name" in the site manifest\'s "theme": {"colors": {"$name": "#AARRGGBB"}} (site.json beside the pages).'
            : 'No theme color "$name". The theme\'s colors: ${_list(names)}.',
        suggestion: nearest(name, names));
  }

  void _styleName(String name, String path) {
    final t = theme;
    if (t != null && t.textStyle(name) != null) return;
    final names = t?.textStyles.keys.toList() ?? const <String>[];
    r.add(Codes.unknownThemeName, path,
        names.isEmpty
            ? 'No text style "$name": declare it in the site manifest\'s "theme": {"textStyles": {"$name": {...}}} (site.json beside the pages).'
            : t!.textStyles.containsKey(name)
                ? 'Text style "$name" starts from a style the theme does not have, or from itself.'
                : 'No theme text style "$name". The theme\'s text styles: ${_list(names)}.',
        suggestion: nearest(name, names));
  }

  /// Checks [json] at [path] against [def] (its type, bounds and codec).
  void checkDef(PropDef<Object?> def, Object? json, String path) => check(def.type, json, path, codec: def.codec, def: def);

  void check(PropType type, Object? json, String path, {PropCodec<Object?>? codec, PropDef<Object?>? def}) {
    if (json == null) return; // null is "unset": the default.
    // A field that takes an expression inline (ExprCodec) takes `${...}`.
    if (codec is ExprCodec && json is String && Expr.isSource(json.trim())) return;
    switch (type.kind) {
      case PropKind.boolean:
        if (json is bool) return;
        if (json == 'true' || json == 'false') {
          r.add(Codes.looseValue, path, 'Expected a boolean, got ${describe(json)}; write $json without quotes.');
        } else {
          r.add(Codes.wrongType, path, 'Expected a boolean (true or false), got ${describe(json)}.');
        }
      case PropKind.integer || PropKind.number:
        num? n;
        if (json is num) {
          n = json;
          if (type.kind == PropKind.integer && json != json.roundToDouble()) {
            r.add(Codes.wrongType, path, 'Expected a whole number, got $json (it would be rounded).');
          }
        } else if (json is String && num.tryParse(json) != null) {
          n = num.parse(json);
          r.add(Codes.looseValue, path, 'Expected a number, got ${describe(json)}; write it without quotes.');
        } else if (type.name == 'FontWeight') {
          // handled as a value type
        } else {
          final hint = json is String && json.contains(r'${') ? ' (to compute it, put the expression in "bind")' : '';
          r.add(Codes.wrongType, path, 'Expected a number, got ${describe(json)}$hint.');
          return;
        }
        if (n != null) _bounds(type, n, path);
      case PropKind.string:
        if (json is String) return;
        if (json is num) {
          r.add(Codes.looseValue, path, 'Expected text, got ${describe(json)}; write it as "$json".');
        } else {
          r.add(Codes.wrongType, path, 'Expected text, got ${describe(json)}.');
        }
      case PropKind.enumeration:
        if (json is String && type.values.contains(json)) return;
        // Some enum codecs read aliases (curves): accept what decodes.
        if (json is String && codec != null && codec.decode(json) != null) return;
        final s = json is String ? nearest(json, type.values) : null;
        r.add(Codes.invalidEnum, path,
            '${describe(json)} is not a ${type.name}. Allowed: ${_list(type.values)}.',
            suggestion: s);
      case PropKind.value:
        _value(type, json, path, codec);
      case PropKind.list:
        if (json is! List) {
          if (codec != null && codec.decode(json) != null) return; // a shorthand the codec reads
          r.add(Codes.wrongType, path, 'Expected a list of ${type.item!.typeName}, got ${describe(json)}.');
          return;
        }
        final itemCodec = codec is ListCodec ? codec.item as PropCodec<Object?> : null;
        for (var i = 0; i < json.length; i++) {
          check(type.item!, json[i], pointer(path, i), codec: itemCodec);
        }
      case PropKind.object:
        _object(type, json, path, codec);
      case PropKind.json:
        if (hook != null && hook!(def, type, json, path)) return;
        if (type.name.startsWith('Map<') && json is! Map) {
          r.add(Codes.wrongType, path, 'Expected an object (${type.name}), got ${describe(json)}.');
        } else if (codec != null && codec.decode(json) == null) {
          r.add(Codes.wrongType, path, 'This value is not read (${type.name} expected), got ${describe(json)}.');
        }
    }
  }

  void _bounds(PropType type, num n, String path) {
    if (type.min != null && n < type.min!) {
      r.add(Codes.outOfRange, path, '$n is below the minimum ${type.min}${type.max == null ? '' : ' (range ${type.min}–${type.max})'}; it reads as ${type.min}.');
    } else if (type.max != null && n > type.max!) {
      r.add(Codes.outOfRange, path, '$n is above the maximum ${type.max} (range ${type.min ?? '-∞'}–${type.max}); it reads as ${type.max}.');
    }
  }

  void _value(PropType type, Object? json, String path, PropCodec<Object?>? codec) {
    final forms = valueForms[type.name];
    void wrong([String? why]) => r.add(Codes.wrongType, path,
        '${why ?? 'Not a ${type.name}'}: got ${describe(json)}.${forms == null ? '' : ' A ${type.name} is $forms.'}');
    bool isNum(Object? v) => v is num;
    switch (type.name) {
      case 'Color':
        if (json is String) {
          final hex = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
          if (hex.hasMatch(json)) return;
          if (Color.isName(json)) return _colorName(json, path);
          if (RegExp(r'^([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(json)) {
            r.add(Codes.looseValue, path, 'Write colors with a leading "#": "#$json".');
            return;
          }
          if (json.contains(r'${')) return wrong('An expression is not a value here: put it in "bind"');
          return wrong(json.startsWith('#') && (json.length == 4 || json.length == 5)
              ? 'Short hex colors are not read'
              : null);
        }
        if (json is int) {
          r.add(Codes.looseValue, path, 'A color as an integer reads, but write it as "#AARRGGBB".');
          return;
        }
        return wrong();
      case 'EdgeInsets':
        if (isNum(json)) return;
        if (json is List && json.length == 4 && json.every(isNum)) return;
        if (json is List && json.length == 2) {
          return wrong('A list of 2 is not read here (it becomes 0 on every side); write [left, top, right, bottom]');
        }
        return wrong();
      case 'BorderRadius':
        if (isNum(json)) return;
        if (json is List && json.length == 2 && json.every(isNum)) return;
        bool corner(Object? c) => isNum(c) || (c is List && c.length == 2 && c.every(isNum));
        if (json is List && json.length == 4 && json.every(corner)) return;
        return wrong();
      case 'Alignment':
        if (json is String && Alignment.named.containsKey(json)) {
          return;
        }
        if (json is List && json.length == 2 && json.every(isNum)) return;
        return wrong(json is String ? '"$json" is not an alignment name' : null);
      case 'Offset':
        if (json is List && json.length == 2 && json.every(isNum)) return;
        return wrong();
      case 'Size':
        if (json is List && json.length == 2 && json.every(isNum)) return;
        if (codec != null && codec.decode(json) != null) return;
        return wrong();
      case 'Rect':
        if (json is List && json.length == 4 && json.every(isNum)) return;
        // A custom paint's view box may be `[width, height]` (at the origin).
        if (codec != null && codec.decode(json) != null) return;
        return wrong();
      case 'BoxConstraints':
        if (json is! Map) return wrong();
        const keys = ['minWidth', 'maxWidth', 'minHeight', 'maxHeight'];
        for (final e in json.entries) {
          final k = '${e.key}';
          if (!keys.contains(k)) {
            r.add(Codes.unknownField, pointer(path, k), 'BoxConstraints has no "$k". It takes: ${_list(keys)}.',
                suggestion: nearest(k, keys));
          } else if (!isNum(e.value) || (e.value as num) < 0) {
            r.add(Codes.wrongType, pointer(path, k), 'Expected a number >= 0, got ${describe(e.value)}.');
          }
        }
      case 'AxisSize':
        if (isNum(json)) {
          if ((json as num) < 0) r.add(Codes.outOfRange, path, 'A size below 0 reads as 0.');
          return;
        }
        if (json is Map && json.length == 1) {
          final k = '${json.keys.first}';
          const modes = ['fixed', 'fill', 'flexible', 'hug'];
          if (!modes.contains(k)) {
            r.add(Codes.invalidEnum, pointer(path, k), '"$k" is not a size mode. Allowed: ${_list(modes)}.',
                suggestion: nearest(k, modes));
            return;
          }
          final v = json.values.first;
          if (!isNum(v)) {
            r.add(Codes.wrongType, pointer(path, k),
                'The number after "$k" is the design size (the fallback when the mode cannot apply); got ${describe(v)}. Write {"$k": <number>}.');
          }
          return;
        }
        return wrong(json is Map ? 'A size object has exactly one key' : null);
      case 'AxisPosition':
        if (isNum(json)) return;
        if (json is! Map) return wrong();
        const keys = ['start', 'end', 'align', 'relative'];
        for (final e in json.entries) {
          final k = '${e.key}';
          if (!keys.contains(k)) {
            r.add(Codes.unknownField, pointer(path, k), 'A position has no "$k". It takes: ${_list(keys)}.',
                suggestion: nearest(k, keys));
          } else if (!isNum(e.value)) {
            r.add(Codes.wrongType, pointer(path, k), 'Expected a number, got ${describe(e.value)}.');
          }
        }
        final has = json.keys.map((k) => '$k').toSet();
        if (has.contains('align') && has.length > 1 || has.contains('relative') && has.length > 1) {
          r.add(Codes.wrongType, path, '"align" and "relative" stand alone: the other keys are ignored. ${valueForms['AxisPosition']}.');
        }
      case 'FontWeight':
        final w = json is num ? json : null;
        if (w == null) {
          return wrong(json is String ? 'Font weights are numbers, not names' : null);
        }
        if (w < 100 || w > 900) {
          r.add(Codes.outOfRange, path, 'A font weight is 100 to 900; $w reads as ${((w / 100).round().clamp(1, 9)) * 100}.');
        } else if (w % 100 != 0) {
          r.add(Codes.looseValue, path, '$w reads as ${(w / 100).round() * 100}: weights are hundreds.');
        }
      case 'FontFeature':
        if (OpenTypeFeature.tryParse(json) == null) wrong();
      case 'IconData':
        if (json is String) {
          if (json.trim().isEmpty) return wrong('An empty icon name');
          return;
        }
        if (json is! Map) return wrong();
      default:
        if (codec != null && codec.decode(json) == null) wrong();
    }
  }

  void _object(PropType type, Object? json, String path, PropCodec<Object?>? codec) {
    if (type.name == 'TextStyle') {
      if (json is String) return _styleName(json.trim(), path);
      if (json is Map && json['from'] is String) _styleName((json['from'] as String).trim(), pointer(path, 'from'));
    }
    if (json is! Map) {
      // A shorthand the model reads (a hero's tag, `sticky: true`, a preset name).
      if (codec != null && codec.decode(json) != null) return;
      r.add(Codes.wrongType, path, 'Expected a ${type.name} object, got ${describe(json)}.');
      return;
    }
    final m = readMap(json)!;
    final fields = {for (final f in type.fields) f.key: f};
    if (codec != null && codec.decode(m) == null && m.isNotEmpty) {
      // Decoding drops the whole value: name what would make it read.
      final missing = [
        for (final f in type.fields)
          if (!m.containsKey(f.key) && _decodesWith(codec, m, f)) f.key,
      ];
      r.add(Codes.wrongType, path,
          'This ${type.name} is not read (decoding drops it)${missing.isEmpty ? '' : ': it needs "${missing.first}"'}.');
    }
    for (final e in m.entries) {
      final f = fields[e.key];
      final p = pointer(path, e.key);
      if (f == null) {
        if (codec != null && readsKey(codec, m, e.key)) continue; // read by the model, though undeclared
        if (type.name == 'Paint' && e.key == 'gradientPerSubpath') {
          r.add(Codes.unknownField, p,
              'A Paint has no "gradientPerSubpath" since 30.1.0: a gradient in each shape is one "customPaint" path op '
              'per shape, the gradient as its paint\'s "shader".');
          continue;
        }
        r.add(Codes.unknownField, p, '${type.name} has no "${e.key}". It takes: ${_list(fields.keys)}.',
            suggestion: nearest(e.key, fields.keys));
        continue;
      }
      checkDef(f, e.value, p);
    }
  }

  static bool _decodesWith(PropCodec<Object?> codec, Json m, PropDef<Object?> f) {
    try {
      final enc = f.defaultValue == null ? null : f.codec.encode(f.defaultValue);
      if (enc == null) return false;
      return codec.decode({...m, f.key: enc}) != null;
    } catch (_) {
      return false;
    }
  }
}

/// Whether decoding [m] with [codec] reads [key]: the value decoded without
/// it differs, and it isn't merely kept as an unknown key that round-trips.
bool readsKey(PropCodec<Object?> codec, Json m, String key) {
  try {
    final withKey = codec.decode(m);
    final without = codec.decode({for (final e in m.entries) if (e.key != key) e.key: e.value});
    final a = withKey == null ? null : codec.encode(withKey);
    final b = without == null ? null : codec.encode(without);
    if (jsonEquality.equals(a, b)) return false;
    // Kept verbatim (an `extra` map): not read. A value that decodes back
    // as written (`widthFactor: 0`) looks the same, so the key is given a
    // value no reader takes: an extra map keeps that too.
    if (a is Map && jsonEquality.equals(a[key], m[key])) {
      const probe = {r'$notRead': true};
      final probed = codec.decode({...m, key: probe});
      final p = probed == null ? null : codec.encode(probed);
      if (p is Map && jsonEquality.equals(p[key], probe)) return false;
    }
    return true;
  } catch (_) {
    return false;
  }
}

String _list(Iterable<String> xs) {
  final l = xs.toList();
  return l.length > 40 ? '${l.take(40).join(', ')}, ... (${l.length} in all)' : l.join(', ');
}

String listOf(Iterable<String> xs) => _list(xs);
