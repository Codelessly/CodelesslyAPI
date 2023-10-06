// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_spacing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LetterSpacing _$LetterSpacingFromJson(Map json) => LetterSpacing(
      value: (json['value'] as num).toDouble(),
      unit: $enumDecodeNullable(_$LetterSpacingUnitEnumEnumMap, json['unit']) ??
          LetterSpacingUnitEnum.pixels,
    );

Map<String, dynamic> _$LetterSpacingToJson(LetterSpacing instance) {
  final val = <String, dynamic>{
    'value': instance.value,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'unit',
      instance.unit,
      _$LetterSpacingUnitEnumEnumMap[instance.unit]!,
      LetterSpacingUnitEnum.pixels);
  return val;
}

const _$LetterSpacingUnitEnumEnumMap = {
  LetterSpacingUnitEnum.pixels: 'pixels',
  LetterSpacingUnitEnum.percent: 'percent',
};
