// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_density.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisualDensityModel _$VisualDensityModelFromJson(Map json) => VisualDensityModel(
      horizontal: (json['horizontal'] as num?)?.toDouble() ?? 0.0,
      vertical: (json['vertical'] as num?)?.toDouble() ?? 0.0,
      type: $enumDecodeNullable(_$VisualDensityTypeEnumMap, json['type']) ??
          VisualDensityType.standard,
    );

Map<String, dynamic> _$VisualDensityModelToJson(VisualDensityModel instance) {
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

  writeNotNull('horizontal', instance.horizontal, instance.horizontal, 0.0);
  writeNotNull('vertical', instance.vertical, instance.vertical, 0.0);
  writeNotNull('type', instance.type,
      _$VisualDensityTypeEnumMap[instance.type]!, VisualDensityType.standard);
  return val;
}

const _$VisualDensityTypeEnumMap = {
  VisualDensityType.standard: 'standard',
  VisualDensityType.comfortable: 'comfortable',
  VisualDensityType.compact: 'compact',
  VisualDensityType.adaptivePlatformDensity: 'adaptivePlatformDensity',
  VisualDensityType.minimum: 'minimum',
  VisualDensityType.maximum: 'maximum',
  VisualDensityType.custom: 'custom',
};
