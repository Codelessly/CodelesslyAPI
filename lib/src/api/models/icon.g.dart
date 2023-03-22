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
      color: json['color'] == null
          ? null
          : ColorRGBA.fromJson(json['color'] as Map),
      show: json['show'] as bool? ?? false,
      imageName: json['imageName'] as String?,
      scale: (json['scale'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$MultiSourceIconModelToJson(
    MultiSourceIconModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('iconImage', instance.iconImage);
  writeNotNull('icon', instance.icon?.toJson());
  writeNotNull('color', instance.color?.toJson());
  val['type'] = _$IconTypeEnumEnumMap[instance.type]!;
  writeNotNull('size', instance.size);
  val['show'] = instance.show;
  writeNotNull('imageName', instance.imageName);
  val['scale'] = instance.scale;
  return val;
}

const _$IconTypeEnumEnumMap = {
  IconTypeEnum.icon: 'icon',
  IconTypeEnum.image: 'image',
};
