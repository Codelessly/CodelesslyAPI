// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSourceIconModel _$MultiSourceIconModelFromJson(Map json) =>
    MultiSourceIconModel(
      type: $enumDecodeNullable(_$IconTypeEnumEnumMap, json['type']) ??
          IconTypeEnum.icon,
      icon: json['icon'] == null
          ? null
          : IconModel.fromJson(Map<String, dynamic>.from(json['icon'] as Map)),
      iconImage: json['iconImage'] as String?,
      size: (json['size'] as num?)?.toDouble() ?? 24,
      color: json['color'] == null ? null : ColorRGBA.fromJson(json['color']),
      show: json['show'] as bool? ?? false,
      imageName: json['imageName'] as String?,
      scale: (json['scale'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$MultiSourceIconModelToJson(
    MultiSourceIconModel instance) {
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

  writeNotNull('iconImage', instance.iconImage, instance.iconImage, null);
  writeNotNull('icon', instance.icon, instance.icon?.toJson(), null);
  writeNotNull('color', instance.color, instance.color?.toJson(), null);
  writeNotNull('type', instance.type, _$IconTypeEnumEnumMap[instance.type]!,
      IconTypeEnum.icon);
  writeNotNull('size', instance.size, instance.size, 24);
  writeNotNull('show', instance.show, instance.show, false);
  writeNotNull('imageName', instance.imageName, instance.imageName, null);
  writeNotNull('scale', instance.scale, instance.scale, 1);
  return val;
}

const _$IconTypeEnumEnumMap = {
  IconTypeEnum.icon: 'icon',
  IconTypeEnum.image: 'image',
};
