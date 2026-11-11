// Total decoding: every reader takes whatever JSON gave it and returns a
// valid value, falling back to the default. Nothing here throws.
import 'package:collection/collection.dart';

/// A JSON object.
typedef Json = Map<String, Object?>;

/// Deep equality for JSON-like values (maps, lists, scalars).
const DeepCollectionEquality jsonEquality = DeepCollectionEquality();

/// [v] as a finite double, or null.
double? readDouble(Object? v) => switch (v) {
      final num n when n.isFinite => n.toDouble(),
      final String s => double.tryParse(s).let((d) => d != null && d.isFinite ? d : null),
      _ => null,
    };

/// [v] as an int, or null.
int? readInt(Object? v) => switch (v) {
      final int n => n,
      final num n when n.isFinite => n.round(),
      final String s => int.tryParse(s),
      _ => null,
    };

/// [v] as a bool, or null.
bool? readBool(Object? v) => switch (v) {
      final bool b => b,
      'true' => true,
      'false' => false,
      _ => null,
    };

/// [v] as a string, or null.
String? readString(Object? v) => v is String ? v : null;

/// [v] as a JSON object, or null. Keys are stringified.
Json? readMap(Object? v) => switch (v) {
      final Map<String, Object?> m => m,
      final Map m => {for (final e in m.entries) '${e.key}': e.value},
      _ => null,
    };

/// [v] as a list, or null.
List<Object?>? readList(Object? v) => v is List ? v.cast<Object?>() : null;

/// [v] as a list of strings (non-strings dropped).
List<String> readStrings(Object? v) => [...?readList(v)?.whereType<String>()];

/// The enum value named [v], or [fallback].
T readEnum<T extends Enum>(List<T> values, Object? v, T fallback) {
  if (v is! String) return fallback;
  for (final e in values) {
    if (e.name == v) return e;
  }
  return fallback;
}

/// Rounds a double for storage: integral values become ints, others keep
/// up to 4 decimals (sub-pixel noise from editors goes away).
num writeDouble(double v) {
  final r = (v * 10000).roundToDouble() / 10000;
  return r == r.roundToDouble() && r.abs() < 1e15 ? r.toInt() : r;
}

/// A ratio for storage: integral values become ints, others keep 12
/// significant decimals. Rounding a ratio to 4 decimals ([writeDouble]) is
/// off by up to 0.00005 per unit, which a size scales: 320/180 stored as
/// 1.7778 made a 300 px drawing 168.748 tall instead of 168.75.
num writeRatio(double v) {
  final r = (v * 1e12).roundToDouble() / 1e12;
  return r == r.roundToDouble() && r.abs() < 1e15 ? r.toInt() : r;
}

/// Puts [key] in [json] unless [value] is null or equals [defaultValue].
void put(Json json, String key, Object? value, [Object? defaultValue]) {
  if (value == null) return;
  if (defaultValue != null && jsonEquality.equals(value, defaultValue)) return;
  json[key] = value;
}

extension Let<T> on T {
  /// Applies [f] to this value.
  R let<R>(R Function(T) f) => f(this);
}
