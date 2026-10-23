import 'dart:convert';

import '../../codelessly_api.dart';

/// Declares extensions on [Object].
extension ObjectExt on Object? {
  /// Converts given string to a typed value if possible.
  /// Returns [defaultValue] or null otherwise.
  R? typedValue<R extends Object?>({R? defaultValue}) {
    final value = this;
    if (this == null) return defaultValue;
    if (value is R) return value;

    return switch (R) {
      const (CornerRadius) =>
        value.toCornerRadius().tryCast<R>() ?? defaultValue,
      const (EdgeInsetsModel) =>
        value.toEdgeInsetsModel().tryCast<R>() ?? defaultValue,
      const (ColorRGB) =>
        ColorRGB.fromColorRGBA(value.toColorRGBA()).tryCast<R>() ??
            defaultValue,
      const (ColorRGBA) => value.toColorRGBA().tryCast<R>() ?? defaultValue,
      const (PaintModel) => value.toPaintModel().tryCast<R>() ?? defaultValue,
      const (String) =>
        (value is List || value is Map
                    ? encodeJsonValue(value)
                    : value.toString())
                .tryCast<R>() ??
            defaultValue,
      const (int) => value.toInt().tryCast<R>() ?? defaultValue,
      const (double) => value.toDouble().tryCast<R>() ?? defaultValue,
      const (num) => value.toNum().tryCast<R>() ?? defaultValue,
      const (bool) => value.toBool().tryCast<R>() ?? defaultValue,
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
      'PaintModel' => PaintModel,
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

  /// Converts given object to a [PaintModel] if possible: a paint's JSON,
  /// an image URL as an image that covers the node, or a color. Returns null
  /// otherwise.
  PaintModel? toPaintModel() {
    final value = this;
    if (value is PaintModel) return value;
    if (value is Map) {
      try {
        return PaintModel.fromJson(value);
      } catch (_) {
        return null;
      }
    }
    if (value is String && _isImageUrl(value)) {
      return PaintModel.fromJson({
        'id': 'bound-image',
        'type': PaintType.image.name,
        'downloadUrl': value.trim(),
        'fit': Fit.cover.name,
      });
    }
    return value.toColorRGBA()?.toPaint();
  }

  /// Converts given object to [ColorRGBA] if possible. Returns null otherwise.
  ColorRGBA? toColorRGBA([double alpha = 1.0]) {
    final value = this;
    if (value == null) return null;
    if (value is ColorRGBA) return value;
    if (value is String) return ColorRGBA.fromHex(value);
    if (value is ColorRGB) {
      return ColorRGBA(r: value.r, g: value.g, b: value.b, a: alpha);
    }
    if (value is PaintModel) {
      return ColorRGBA(
        r: value.color?.r ?? 0,
        g: value.color?.g ?? 0,
        b: value.color?.b ?? 0,
        a: value.opacity,
      );
    }

    return null;
  }

  /// Converts given object to [EdgeInsetsModel] if possible. Returns null otherwise.
  ///
  /// Accepts what a binding or formula gives a node's padding: a number for
  /// all sides, `[horizontal, vertical]`, `[left, top, right, bottom]`, a
  /// one-item list, or any of those as text (`"12"`, `"[16, 8]"`).
  EdgeInsetsModel? toEdgeInsetsModel() {
    final value = this;
    if (value == null) return null;
    if (value is EdgeInsetsModel) return value;
    if (value case [final num all]) return EdgeInsetsModel.all(all.toDouble());
    if (value case num() || [num(), num()] || [num(), num(), num(), num()]) {
      return EdgeInsetsModel.fromJson(value);
    }
    if (value is String) {
      final String text = value.trim();
      final Object? parsed = num.tryParse(text) ?? tryJsonDecode(text);
      if (parsed is String) return null;
      return parsed.toEdgeInsetsModel();
    }

    return null;
  }

  /// Converts given object to [CornerRadius] if possible. Returns null
  /// otherwise.
  ///
  /// Accepts what a binding or formula gives a node's corner radius: a
  /// number for all corners, `[topLeft, topRight, bottomRight, bottomLeft]`
  /// (the order of CSS's border-radius), a one-item list, any of those as
  /// text (`"12"`, `"[18, 18, 0, 0]"`), or a [CornerRadius]'s JSON.
  CornerRadius? toCornerRadius() {
    final value = this;
    switch (value) {
      case null:
        return null;
      case CornerRadius():
        return value;
      case num() || [num()]:
        final num all = value is num ? value : (value as List).first as num;
        return CornerRadius.all(RadiusModel.circular(all.toDouble()));
      case [num tl, num tr, num br, num bl]:
        return CornerRadius.only(
          tl: RadiusModel.circular(tl.toDouble()),
          tr: RadiusModel.circular(tr.toDouble()),
          br: RadiusModel.circular(br.toDouble()),
          bl: RadiusModel.circular(bl.toDouble()),
        );
      case String():
        final String text = value.trim();
        final Object? parsed = num.tryParse(text) ?? tryJsonDecode(text);
        if (parsed is String) return null;
        return parsed.toCornerRadius();
      case Map() || List():
        try {
          return CornerRadius.fromJson(value);
        } catch (_) {
          return null;
        }
    }
    return null;
  }

  /// Converts given object to [ColorRGB] if possible. Returns null otherwise.
  ColorRGB? toColorRGB() {
    final value = this;
    if (value == null) return null;
    if (value is ColorRGB) return value;
    if (value is String) return ColorRGB.fromHex(value);
    if (value is ColorRGBA) return ColorRGB(r: value.r, g: value.g, b: value.b);
    if (value is PaintModel) {
      return ColorRGB(
        r: value.color?.r ?? 0,
        g: value.color?.g ?? 0,
        b: value.color?.b ?? 0,
      );
    }

    return null;
  }

  /// Converts given object to a map if possible. Returns null otherwise.
  Map<Object?, Object?>? toMap() {
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
      return set.map<int?>((e) => e?.toInt()).nonNulls.toSet().tryCast<R>();
    }
    if (R == Set<int?>) {
      return set.map<int?>((e) => e?.toInt()).nonNulls.toSet().tryCast<R>();
    }
    if (R == Set<double>) {
      return set
          .map<double?>((e) => e?.toDouble())
          .nonNulls
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<double?>) {
      return set
          .map<double?>((e) => e?.toDouble())
          .nonNulls
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<num>) {
      return set.map<num?>((e) => e?.toNum()).nonNulls.toSet().tryCast<R>();
    }
    if (R == Set<num?>) {
      return set.map<num?>((e) => e?.toNum()).nonNulls.toSet().tryCast<R>();
    }
    if (R == Set<bool>) {
      return set.map<bool?>((e) => e?.toBool()).nonNulls.toSet().tryCast<R>();
    }
    if (R == Set<bool?>) {
      return set.map<bool?>((e) => e?.toBool()).nonNulls.toSet().tryCast<R>();
    }
    if (R == Set<String>) {
      return set
          .map<String?>((e) => e?.toString())
          .nonNulls
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<String?>) {
      return set
          .map<String?>((e) => e?.toString())
          .nonNulls
          .toSet()
          .tryCast<R>();
    }
    if (R == Set<Map>) {
      return set.map<Map?>((e) => e?.toMap()).nonNulls.toSet().tryCast<R>();
    }
    if (R == Set<Map?>) {
      return set.map<Map?>((e) => e?.toMap()).nonNulls.toSet().tryCast<R>();
    }

    return set.tryCast<R>();
  }
}

/// Whether [value] is a link to an image rather than a color.
bool _isImageUrl(String value) {
  final String url = value.trim().toLowerCase();
  return url.startsWith('https://') ||
      url.startsWith('http://') ||
      url.startsWith('data:image/');
}
