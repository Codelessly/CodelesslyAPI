// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_spacing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LetterSpacing _$LetterSpacingFromJson(Map json) => LetterSpacing(
  value: (json['value'] as num).toDouble(),
  unit:
      $enumDecodeNullable(_$LetterSpacingUnitEnumEnumMap, json['unit']) ??
      LetterSpacingUnitEnum.pixels,
);

Map<String, dynamic> _$LetterSpacingToJson(LetterSpacing instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': _$LetterSpacingUnitEnumEnumMap[instance.unit]!,
    };

const _$LetterSpacingUnitEnumEnumMap = {
  LetterSpacingUnitEnum.pixels: 'pixels',
  LetterSpacingUnitEnum.percent: 'percent',
};
