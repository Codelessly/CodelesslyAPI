// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FontName _$FontNameFromJson(Map json) => FontName(
      family: json['family'] as String,
      weight: $enumDecodeNullable(_$FontWeightNumericEnumMap, json['weight']),
      style: json['style'] as String? ?? 'Normal',
    );

Map<String, dynamic> _$FontNameToJson(FontName instance) {
  final val = <String, dynamic>{
    'family': instance.family,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('style', instance.style, instance.style, 'Normal');
  writeNotNull('weight', instance.weight,
      _$FontWeightNumericEnumMap[instance.weight], null);
  return val;
}

const _$FontWeightNumericEnumMap = {
  FontWeightNumeric.w100: 'w100',
  FontWeightNumeric.w200: 'w200',
  FontWeightNumeric.w300: 'w300',
  FontWeightNumeric.w400: 'w400',
  FontWeightNumeric.w500: 'w500',
  FontWeightNumeric.w600: 'w600',
  FontWeightNumeric.w700: 'w700',
  FontWeightNumeric.w800: 'w800',
  FontWeightNumeric.w900: 'w900',
};
