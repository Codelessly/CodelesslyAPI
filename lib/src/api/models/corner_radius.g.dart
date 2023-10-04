// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_radius.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CornerRadius _$CornerRadiusFromJson(Map json) => CornerRadius(
      type: $enumDecodeNullable(_$RadiusTypeEnumMap, json['type']) ??
          RadiusType.circular,
      tl: RadiusModel.fromJson(json['tl']),
      tr: RadiusModel.fromJson(json['tr']),
      bl: RadiusModel.fromJson(json['bl']),
      br: RadiusModel.fromJson(json['br']),
      linked: json['linked'] as bool? ?? false,
    );

Map<String, dynamic> _$CornerRadiusToJson(CornerRadius instance) {
  final val = <String, dynamic>{
    'tl': instance.tl.toJson(),
    'tr': instance.tr.toJson(),
    'bl': instance.bl.toJson(),
    'br': instance.br.toJson(),
  };

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

  writeNotNull('type', instance.type, _$RadiusTypeEnumMap[instance.type]!,
      RadiusType.circular);
  writeNotNull('linked', instance.linked, instance.linked, false);
  return val;
}

const _$RadiusTypeEnumMap = {
  RadiusType.circular: 'circular',
  RadiusType.elliptical: 'elliptical',
};

RadiusModel _$RadiusModelFromJson(Map json) => RadiusModel(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$RadiusModelToJson(RadiusModel instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };
