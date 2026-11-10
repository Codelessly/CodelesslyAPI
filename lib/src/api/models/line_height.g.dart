// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_height.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$LineHeightOmitDefaults(
  LineHeight instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.unit, LineHeightUnitEnum.pixels))
    json.remove('unit');
  if (isJsonDefault(
    instance.leadingDistribution,
    LeadingDistributionEnum.proportional,
  ))
    json.remove('leadingDistribution');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineHeight _$LineHeightFromJson(Map json) => LineHeight(
  value: (json['value'] as num?)?.toDouble(),
  unit:
      $enumDecodeNullable(
        _$LineHeightUnitEnumEnumMap,
        readSizeUnit(json, 'unit'),
      ) ??
      LineHeightUnitEnum.pixels,
  leadingDistribution:
      $enumDecodeNullable(
        _$LeadingDistributionEnumEnumMap,
        json['leadingDistribution'],
      ) ??
      LeadingDistributionEnum.proportional,
);

Map<String, dynamic> _$LineHeightToJson(LineHeight instance) =>
    <String, dynamic>{
      'value': ?instance.value,
      'unit': _$LineHeightUnitEnumEnumMap[instance.unit]!,
      'leadingDistribution':
          _$LeadingDistributionEnumEnumMap[instance.leadingDistribution]!,
    };

const _$LineHeightUnitEnumEnumMap = {
  LineHeightUnitEnum.pixels: 'pixels',
  LineHeightUnitEnum.percent: 'percent',
  LineHeightUnitEnum.auto: 'auto',
};

const _$LeadingDistributionEnumEnumMap = {
  LeadingDistributionEnum.proportional: 'proportional',
  LeadingDistributionEnum.even: 'even',
};
