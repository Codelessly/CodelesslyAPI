// One declaration per widget: its props, each with a Flutter name, a codec
// and Flutter's default. The declaration is the single place a prop exists:
// decoding, encoding, equality and the editor's panels all read it.
import 'package:meta/meta.dart';

import 'json.dart';
import 'values/color.dart';
import 'values/geometry.dart';
import 'values/text.dart';

/// Reads and writes one prop's JSON. Decoding returns null for values it
/// can't read (the prop then has its default).
abstract class PropCodec<T> {
  const PropCodec();
  T? decode(Object? json);
  Object? encode(T value);
}

final class DoubleCodec extends PropCodec<double> {
  const DoubleCodec({this.min, this.max});
  final double? min, max;
  @override
  double? decode(Object? json) {
    var v = readDouble(json);
    if (v == null) return null;
    if (min != null && v < min!) v = min!;
    if (max != null && v > max!) v = max!;
    return v;
  }

  @override
  Object encode(double value) => writeDouble(value);
}

final class IntCodec extends PropCodec<int> {
  const IntCodec({this.min});
  final int? min;
  @override
  int? decode(Object? json) {
    final v = readInt(json);
    return v == null || (min != null && v < min!) ? (v == null ? null : min) : v;
  }

  @override
  Object encode(int value) => value;
}

/// An int that may be absent (`maxLines`).
final class OptionalIntCodec extends PropCodec<int?> {
  const OptionalIntCodec();
  @override
  int? decode(Object? json) => readInt(json);
  @override
  Object? encode(int? value) => value;
}

final class BoolCodec extends PropCodec<bool> {
  const BoolCodec();
  @override
  bool? decode(Object? json) => readBool(json);
  @override
  Object encode(bool value) => value;
}

final class StringCodec extends PropCodec<String> {
  const StringCodec();
  @override
  String? decode(Object? json) => json is String ? json : (json is num ? '$json' : null);
  @override
  Object encode(String value) => value;
}

final class EnumCodec<T extends Enum> extends PropCodec<T> {
  const EnumCodec(this.values);
  final List<T> values;
  @override
  T? decode(Object? json) {
    for (final v in values) {
      if (v.name == json) return v;
    }
    return null;
  }

  @override
  Object encode(T value) => value.name;
}

/// A value type with its own `fromJson` / `toJson`.
final class ValueCodec<T> extends PropCodec<T> {
  const ValueCodec(this._decode, this._encode);
  final T? Function(Object?) _decode;
  final Object? Function(T) _encode;
  @override
  T? decode(Object? json) => json == null ? null : _decode(json);
  @override
  Object? encode(T value) => _encode(value);
}

final class ListCodec<T> extends PropCodec<List<T>> {
  const ListCodec(this.item);
  final PropCodec<T> item;
  @override
  List<T>? decode(Object? json) => readList(json)?.map(item.decode).whereType<T>().toList();
  @override
  Object encode(List<T> value) => [for (final v in value) item.encode(v)];
}

Object? _colorOut(Color c) => c.toJson();
Object? _insetsOut(EdgeInsets e) => e.toJson();
Object? _styleOut(TextStyle s) => s.toJson();
Object? _runOut(TextRun r) => r.toJson();
Color? _colorIn(Object? j) => Color.fromJson(j);
TextRun? _runIn(Object? j) => TextRun.fromJson(j);

/// Common codecs.
abstract final class Codecs {
  static const double = DoubleCodec();
  static const positive = DoubleCodec(min: 0);
  static const int = IntCodec();
  static const bool = BoolCodec();
  static const string = StringCodec();
  static const color = ValueCodec<Color>(_colorIn, _colorOut);
  static const insets = ValueCodec<EdgeInsets>(EdgeInsets.fromJson, _insetsOut);
  static const textStyle = ValueCodec<TextStyle>(TextStyle.fromJson, _styleOut);
  static const textRuns = ListCodec<TextRun>(ValueCodec(_runIn, _runOut));
}

/// One prop of a widget.
@immutable
final class PropDef<T> {
  const PropDef(this.key, this.codec, this.defaultValue, {this.doc = ''});

  /// The JSON key: Flutter's parameter name.
  final String key;
  final PropCodec<T> codec;

  /// Flutter's default. Values equal to it aren't stored.
  final T defaultValue;
  final String doc;

  T? decode(Object? json) => codec.decode(json);
  Object? encode(T value) => codec.encode(value);

  @override
  String toString() => 'PropDef($key)';
}

/// How a widget takes children.
enum ChildModel {
  /// A leaf.
  none,

  /// An ordered list (`children`).
  list,

  /// Named slots only (`slots`).
  slots,
}

/// The declaration of one widget type.
@immutable
final class WidgetSpec {
  const WidgetSpec(
    this.type, {
    required this.props,
    this.children = ChildModel.none,
    this.slots = const [],
    this.decorated = false,
    this.doc = '',
  });

  /// The node `type`.
  final String type;
  final List<PropDef<Object?>> props;
  final ChildModel children;

  /// Named slots this widget takes (`body`, `leading`...).
  final List<String> slots;

  /// Has a box decoration (fills, strokes, radius, effects).
  final bool decorated;
  final String doc;

  PropDef<Object?>? prop(String key) {
    for (final p in props) {
      if (p.key == key) return p;
    }
    return null;
  }
}

/// A widget's prop values: only the ones that differ from Flutter's defaults
/// are held. Keys a declaration doesn't know round-trip untouched.
@immutable
final class Props {
  const Props._(this._values, this._unknown);

  static const Props empty = Props._({}, {});

  final Map<String, Object?> _values;
  final Json _unknown;

  /// The value of [def] (its default when unset).
  T get<T>(PropDef<T> def) {
    final v = _values[def.key];
    return v == null ? def.defaultValue : v as T;
  }

  /// Whether [def] holds a non-default value.
  bool has(PropDef<Object?> def) => _values.containsKey(def.key);

  /// These props with [def] set to [value].
  Props set<T>(PropDef<T> def, T value) {
    final next = {..._values};
    if (value == null || jsonEquality.equals(value, def.defaultValue)) {
      next.remove(def.key);
    } else {
      next[def.key] = value;
    }
    return Props._(next, _unknown);
  }

  /// Keys no declaration knows (kept for round trips).
  Json get unknown => _unknown;

  bool get isEmpty => _values.isEmpty && _unknown.isEmpty;

  static Props fromJson(WidgetSpec? spec, Object? json) {
    final m = readMap(json);
    if (m == null || m.isEmpty) return empty;
    final values = <String, Object?>{};
    final unknown = <String, Object?>{};
    for (final e in m.entries) {
      final def = spec?.prop(e.key);
      if (def == null) {
        unknown[e.key] = e.value;
        continue;
      }
      final v = def.decode(e.value);
      if (v != null && !jsonEquality.equals(v, def.defaultValue)) values[e.key] = v;
    }
    return Props._(values, unknown);
  }

  Json toJson(WidgetSpec? spec) {
    final j = <String, Object?>{..._unknown};
    for (final e in _values.entries) {
      final def = spec?.prop(e.key);
      j[e.key] = def == null ? e.value : def.encode(e.value);
    }
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is Props && jsonEquality.equals(other._values, _values) && jsonEquality.equals(other._unknown, _unknown);

  @override
  int get hashCode => Object.hash(jsonEquality.hash(_values), jsonEquality.hash(_unknown));

  @override
  String toString() => 'Props($_values${_unknown.isEmpty ? '' : ', unknown: $_unknown'})';
}
