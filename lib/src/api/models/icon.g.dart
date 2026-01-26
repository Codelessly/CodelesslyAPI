// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReactiveIconModel _$ReactiveIconModelFromJson(Map json) => ReactiveIconModel(
  icon: MultiSourceIconModel.fromJson(json['icon'] as Map),
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => Reaction.fromJson(e as Map))
          .toList() ??
      const [],
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
};

const _$IconTypeEnumEnumMap = {
  IconTypeEnum.icon: 'icon',
  IconTypeEnum.image: 'image',
};
