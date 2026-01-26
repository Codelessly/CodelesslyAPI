// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_height.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineHeight _$LineHeightFromJson(Map json) => LineHeight(
  value: (json['value'] as num?)?.toDouble(),
  unit:
      $enumDecodeNullable(_$LineHeightUnitEnumEnumMap, json['unit']) ??
      LineHeightUnitEnum.pixels,
);

Map<String, dynamic> _$LineHeightToJson(LineHeight instance) =>
    <String, dynamic>{
      'value': ?instance.value,
      'unit': _$LineHeightUnitEnumEnumMap[instance.unit]!,
    };

const _$LineHeightUnitEnumEnumMap = {
  LineHeightUnitEnum.pixels: 'pixels',
  LineHeightUnitEnum.percent: 'percent',
  LineHeightUnitEnum.auto: 'auto',
};
