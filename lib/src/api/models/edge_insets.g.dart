// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edge_insets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdgeInsetsModel _$EdgeInsetsModelFromJson(Map json) => EdgeInsetsModel(
      l: (json['l'] as num?)?.toDouble() ?? 0,
      t: (json['t'] as num?)?.toDouble() ?? 0,
      r: (json['r'] as num?)?.toDouble() ?? 0,
      b: (json['b'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$EdgeInsetsModelToJson(EdgeInsetsModel instance) {
  final val = <String, dynamic>{};

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('l', instance.l, instance.l, 0);
  writeNotNull('t', instance.t, instance.t, 0);
  writeNotNull('r', instance.r, instance.r, 0);
  writeNotNull('b', instance.b, instance.b, 0);
  return val;
}
