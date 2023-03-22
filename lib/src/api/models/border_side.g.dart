// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'border_side.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorderSideModel _$BorderSideModelFromJson(Map json) => BorderSideModel(
      color: json['color'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['color'] as Map),
      style: $enumDecodeNullable(_$BorderStyleEnumEnumMap, json['style']) ??
          BorderStyleEnum.solid,
      width: (json['width'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$BorderSideModelToJson(BorderSideModel instance) =>
    <String, dynamic>{
      'color': instance.color.toJson(),
      'style': _$BorderStyleEnumEnumMap[instance.style]!,
      'width': instance.width,
    };

const _$BorderStyleEnumEnumMap = {
  BorderStyleEnum.solid: 'solid',
  BorderStyleEnum.none: 'none',
};
