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

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
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
