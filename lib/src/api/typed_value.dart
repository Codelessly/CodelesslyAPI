import 'dart:convert';

import 'package:collection/collection.dart';

import '../../codelessly_api.dart';

/// Declares extensions on [Object].
extension ObjectExt on Object? {
  /// Converts given string to a typed value if possible.
  /// Returns [defaultValue] or null otherwise.
  R? typedValue<R extends Object>({R? defaultValue}) {
    final value = this;
    if (this == null) return defaultValue;
    if (value is R) return value;

    return switch (R) {
      const (String) =>
        (value is List || value is Map ? jsonEncode(value) : value.toString())
                .tryCast<R>() ??
            defaultValue,
      const (int) => value.toInt().tryCast<R>() ?? defaultValue,
      const (double) => value.toDouble().tryCast<R>() ?? defaultValue,
      const (num) => value.toNum().tryCast<R>() ?? defaultValue,
      const (bool) => value.toBool().tryCast<R>() ?? defaultValue,
      const (ColorRGBA) => value.toColorRGBA().tryCast<R>() ?? defaultValue,
      const (ColorRGB) =>
        ColorRGB.fromColorRGBA(value.toColorRGBA()).tryCast<R>() ??
            defaultValue,
      const (PaintModel) =>
        value.toColorRGBA()?.toPaint().tryCast<R>() ?? defaultValue,
      _ when R.isMap => value.toMap().tryCast<R>(),
      _ when R.isList || R.isIterable => value.toList<R>(),
      _ when R.isSet => value.toSet<R>(),
      _ => defaultValue,
    };
  }
}

/// Declares extensions on [Type].
extension TypeExt on Type {
  /// Returns the type of the first generic argument of this type.
  /// e.g. `List<int>` returns `int`.
  Type? get subType => subTypeString?.toType();

  /// Returns the type of the first generic argument of this type.
  /// e.g. `List<int>` returns `int`.
  String? get subTypeString {
    final value = toString();
    final startIndex = value.indexOf('<');
    final endIndex = value.lastIndexOf('>');
    if (startIndex == -1 || endIndex == -1) return null;
    final subType = value.substring(startIndex + 1, endIndex);
    return subType;
  }

  /// Returns the type of the first generic argument of this type.
  /// e.g. `List<int>` returns `List`.
  String get mainTypeString {
    final value = toString();
    final endIndex = value.indexOf('<');
    if (endIndex == -1) return value;
    final mainType = value.substring(0, endIndex);
    return mainType;
  }

  /// Returns the type of the first generic argument of this type.
  /// e.g. `List<int>` returns `List`.
  Type? get mainType => mainTypeString.toType();

  /// Returns true if this type is a generic type.
  /// e.g. `List<int>` returns `true`.
  ///       `List` returns `true`.
  bool get isList => mainType == List;

  /// Returns true if this type is a generic type.
  /// e.g. `Set<int>` returns `true`.
  ///      `Set` returns `true`.
  bool get isSet => mainType == Set;

  /// Returns true if this type is a generic type.
  /// e.g. `Iterable<int>` returns `true`.
  ///      `Iterable` returns `true`.
  bool get isIterable => isList || isSet || mainType == Iterable;

  /// Returns true if this type is a generic type.
  /// e.g. `Map<int, String>` returns `true`.
  ///      `Map` returns `true`.
  bool get isMap => mainType == Map;
}

/// Extensions on string about types.
extension TypedStringExt on String {
  /// Converts given string to a typed value derived from the original value
  /// of this string.
  Object? parsedValue() {
    if (this == 'null') return null;
    return toInt() ??
        toDouble() ??
        toBool() ??
        toList() ??
        toMap() ??
        (isEmpty ? null : this);
  }

  /// Converts given string to a known type.
  Type toType() {
    return switch (this) {
      'int' => int,
      'num' => num,
      'String' => String,
      'double' => double,
      'bool' => bool,
      'Map' => Map,
      'List' => List,
      'Set' => Set,
      'Iterable' => Iterable,
      'Object' => Object,
      _ => Object,
    };
  }
}

/// Declares extensions on Generic types that allows to type cast safely.
extension CastExt<T> on T? {
  /// Tries to cast this object to given type [R]. Returns null if the cast
  /// fails.
  R? tryCast<R>() {
    if (this == null) return null;
    try {
      return this as R;
    } catch (e) {
      return null;
    }
  }
}

/// Tries to decode given string to a json object. Returns null if the
/// decoding fails.
Object? tryJsonDecode(String value) {
  try {
    return jsonDecode(value);
  } catch (e) {
    return null;
  }
}

/// Declares extensions on [Object] that allows to convert to other types.
extension ConversionExt on Object? {
  /// Converts given object to a number if possible. Returns null otherwise.
  num? toNum() {
    final value = this;
    if (value == null) return null;
    if (value is num) return value;
    if (value is int) return value;
    if (value is double) return value;
    if (value is String) return num.tryParse(value);
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  /// Converts given object to an integer if possible. Returns null otherwise.
  int? toInt() => toNum()?.toInt();

  /// Converts given object to a double if possible. Returns null otherwise.
  double? toDouble() => toNum()?.toDouble();

  /// Converts given object to a boolean if possible. Returns null otherwise.
  bool? toBool() {
    final value = this;
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is double) return value != 0;
    if (value is num) return value != 0;
    if (value is String) {
      final parsedBool = bool.tryParse(value, caseSensitive: false);
      if (parsedBool != null) return parsedBool;
      final parsedNum = num.tryParse(value);
      if (parsedNum != null) return parsedNum != 0;
    }
    return null;
  }

  /// Converts given object to [ColorRGBA] if possible. Returns null otherwise.
  ColorRGBA? toColorRGBA([double alpha = 1.0]) {
    final value = this;
    if (value == null) return null;
    if (value is ColorRGBA) return value;
    if (value is String) return ColorRGBA.fromHex(value);
    if (value is ColorRGB)
      return ColorRGBA(r: value.r, g: value.g, b: value.b, a: alpha);

    return null;
  }

  /// Converts given object to [ColorRGB] if possible. Returns null otherwise.
  ColorRGB? toColorRGB() {
    final value = this;
    if (value == null) return null;
    if (value is ColorRGB) return value;
    if (value is String) return ColorRGB.fromHex(value);
    if (value is ColorRGBA) return ColorRGB(r: value.r, g: value.g, b: value.b);

    return null;
  }

  /// Converts given object to a map if possible. Returns null otherwise.
  Map? toMap() {
    if (this == null) return null;
    if (this is Map) return this as Map;
    if (this is String) return tryJsonDecode(this as String).tryCast<Map>();
    return null;
  }

  /// Converts given object to a list if possible. Returns null otherwise.
  R? toList<R>() {
    if (this == null) return null;
    List<Object?>? list;
    if (this is List) {
      list = this as List;
    } else if (this is String) {
      final decoded = tryJsonDecode(this as String);
      if (decoded is List) {
        list = decoded.map((e) => e is String ? e.parsedValue() : e).toList();
      }
    }
    if (list == null) return null;

    if (R == List<int?>) {
      return list.map<int?>((e) => e?.toInt()).toList().tryCast<R>();
    }
    if (R == List<int>) {
      return list.map<int?>((e) => e?.toInt()).toList().tryCast<R>();
    }
    if (R == List<double>) {
      return list.map<double?>((e) => e.toDouble()).toList().tryCast<R>();
    }
    if (R == List<double?>) {
      return list.map<double?>((e) => e.toDouble()).toList().tryCast<R>();
    }
    if (R == List<num>) {
      return list.map<num?>((e) => e.toNum()).toList().tryCast<R>();
    }
    if (R == List<num?>) {
      return list.map<num?>((e) => e.toNum()).toList().tryCast<R>();
    }
    if (R == List<bool>) {
      return list.map<bool?>((e) => e.toBool()).toList().tryCast<R>();
    }
    if (R == List<bool?>) {
      return list.map<bool?>((e) => e.toBool()).toList().tryCast<R>();
    }
    if (R == List<String>) {
      return list.map<String?>((e) => e.toString()).toList().tryCast<R>();
    }
    if (R == List<String?>) {
      return list.map<String?>((e) => e.toString()).toList().tryCast<R>();
    }
    if (R == List<Map>) {
      return list.map<Map?>((e) => e.toMap()).toList().tryCast<R>();
    }
    if (R == List<Map?>) {
      return list.map<Map?>((e) => e.toMap()).toList().tryCast<R>();
    }

    return list.tryCast<R>();
  }

  /// Converts given object to a set if possible. Returns null otherwise.
  R? toSet<R>() {
    if (this == null) return null;
    Set<Object?>? set;
    if (this is Set) {
      set = this as Set;
    } else if (this is String) {
      final decoded = tryJsonDecode(this as String);
      if (decoded is List) {
        set = decoded.map((e) => e is String ? e.parsedValue() : e).toSet();
      }
    }
    if (set == null) return null;

    if (R == Set<int>) {
      return set
          .map<int?>((e) => e?.toInt())
          .whereNotNull()
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<int?>) {
      return set.map<int?>((e) => e?.toInt()).toSet().tryCast<R>();
    }
    if (R == Set<double>) {
      return set
          .map<double?>((e) => e?.toDouble())
          .whereNotNull()
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<double?>) {
      return set.map<double?>((e) => e?.toDouble()).toSet().tryCast<R>();
    }
    if (R == Set<num>) {
      return set
          .map<num?>((e) => e?.toNum())
          .whereNotNull()
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<num?>) {
      return set.map<num?>((e) => e?.toNum()).toSet().tryCast<R>();
    }
    if (R == Set<bool>) {
      return set
          .map<bool?>((e) => e?.toBool())
          .whereNotNull()
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<bool?>) {
      return set.map<bool?>((e) => e?.toBool()).toSet().tryCast<R>();
    }
    if (R == Set<String>) {
      return set
          .map<String?>((e) => e?.toString())
          .whereNotNull()
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<String?>) {
      return set.map<String?>((e) => e?.toString()).toSet().tryCast<R>();
    }
    if (R == Set<Map>) {
      return set
          .map<Map?>((e) => e?.toMap())
          .whereNotNull()
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<Map?>) {
      return set.map<Map?>((e) => e?.toMap()).toSet().tryCast<R>();
    }

    return set.tryCast<R>();
  }
}
