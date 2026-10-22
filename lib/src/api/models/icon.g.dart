// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ReactiveIconModelOmitDefaults(
  ReactiveIconModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  return json;
}

Map<String, dynamic> _$MultiSourceIconModelOmitDefaults(
  MultiSourceIconModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.type, IconTypeEnum.icon)) json.remove('type');
  if (isJsonDefault(instance.size, 24)) json.remove('size');
  if (isJsonDefault(instance.show, false)) json.remove('show');
  if (isJsonDefault(instance.scale, 1)) json.remove('scale');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReactiveIconModel _$ReactiveIconModelFromJson(Map json) => ReactiveIconModel(
  icon: MultiSourceIconModel.fromJson(json['icon'] as Map),
  reactions: json['reactions'] == null
      ? const []
      : reactionsFromJson(json['reactions']),
);

Map<String, dynamic> _$ReactiveIconModelToJson(ReactiveIconModel instance) =>
    <String, dynamic>{
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'icon': instance.icon.toJson(),
    };

MultiSourceIconModel _$MultiSourceIconModelFromJson(Map json) =>
    MultiSourceIconModel(
      type:
          $enumDecodeNullable(_$IconTypeEnumEnumMap, json['type']) ??
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
      fill: (json['fill'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      grade: (json['grade'] as num?)?.toDouble(),
      opticalSize: (json['opticalSize'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MultiSourceIconModelToJson(
  MultiSourceIconModel instance,
) => <String, dynamic>{
  'iconImage': ?instance.iconImage,
  'icon': ?instance.icon?.toJson(),
  'color': ?instance.color?.toJson(),
  'type': _$IconTypeEnumEnumMap[instance.type]!,
  'size': ?instance.size,
  'show': instance.show,
  'imageName': ?instance.imageName,
  'scale': instance.scale,
  'fill': ?instance.fill,
  'weight': ?instance.weight,
  'grade': ?instance.grade,
  'opticalSize': ?instance.opticalSize,
};

const _$IconTypeEnumEnumMap = {
  IconTypeEnum.icon: 'icon',
  IconTypeEnum.image: 'image',
};
