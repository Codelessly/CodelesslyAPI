// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'border_side.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$BorderSideModelOmitDefaults(
  BorderSideModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.color, ColorRGBA.black)) json.remove('color');
  if (isJsonDefault(instance.style, BorderStyleEnum.solid))
    json.remove('style');
  if (isJsonDefault(instance.width, 1)) json.remove('width');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorderSideModel _$BorderSideModelFromJson(Map json) => BorderSideModel(
  color: json['color'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['color']),
  style:
      $enumDecodeNullable(_$BorderStyleEnumEnumMap, json['style']) ??
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
