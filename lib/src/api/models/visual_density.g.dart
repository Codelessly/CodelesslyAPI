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

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
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
