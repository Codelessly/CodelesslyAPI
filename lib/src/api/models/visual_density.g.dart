// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_density.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$VisualDensityModelOmitDefaults(
  VisualDensityModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.horizontal, 0.0)) json.remove('horizontal');
  if (isJsonDefault(instance.vertical, 0.0)) json.remove('vertical');
  if (isJsonDefault(instance.type, VisualDensityType.standard))
    json.remove('type');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisualDensityModel _$VisualDensityModelFromJson(Map json) => VisualDensityModel(
  horizontal: (json['horizontal'] as num?)?.toDouble() ?? 0.0,
  vertical: (json['vertical'] as num?)?.toDouble() ?? 0.0,
  type:
      $enumDecodeNullable(_$VisualDensityTypeEnumMap, json['type']) ??
      VisualDensityType.standard,
);

Map<String, dynamic> _$VisualDensityModelToJson(VisualDensityModel instance) =>
    <String, dynamic>{
      'horizontal': instance.horizontal,
      'vertical': instance.vertical,
      'type': _$VisualDensityTypeEnumMap[instance.type]!,
    };

const _$VisualDensityTypeEnumMap = {
  VisualDensityType.standard: 'standard',
  VisualDensityType.comfortable: 'comfortable',
  VisualDensityType.compact: 'compact',
  VisualDensityType.adaptivePlatformDensity: 'adaptivePlatformDensity',
  VisualDensityType.minimum: 'minimum',
  VisualDensityType.maximum: 'maximum',
  VisualDensityType.custom: 'custom',
};
