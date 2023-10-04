// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'border_side.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorderSideModel _$BorderSideModelFromJson(Map json) => BorderSideModel(
      color: json['color'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['color']),
      style: $enumDecodeNullable(_$BorderStyleEnumEnumMap, json['style']) ??
          BorderStyleEnum.solid,
      width: (json['width'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$BorderSideModelToJson(BorderSideModel instance) {
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

  writeNotNull(
      'color', instance.color, instance.color.toJson(), ColorRGBA.black);
  writeNotNull('style', instance.style,
      _$BorderStyleEnumEnumMap[instance.style]!, BorderStyleEnum.solid);
  writeNotNull('width', instance.width, instance.width, 1);
  return val;
}

const _$BorderStyleEnumEnumMap = {
  BorderStyleEnum.solid: 'solid',
  BorderStyleEnum.none: 'none',
};
