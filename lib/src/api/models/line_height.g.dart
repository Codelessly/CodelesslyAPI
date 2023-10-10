// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_height.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineHeight _$LineHeightFromJson(Map json) => LineHeight(
      value: (json['value'] as num?)?.toDouble(),
      unit: $enumDecodeNullable(_$LineHeightUnitEnumEnumMap, json['unit']) ??
          LineHeightUnitEnum.pixels,
    );

Map<String, dynamic> _$LineHeightToJson(LineHeight instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('value', instance.value, instance.value, null);
  writeNotNull('unit', instance.unit,
      _$LineHeightUnitEnumEnumMap[instance.unit]!, LineHeightUnitEnum.pixels);
  return val;
}

const _$LineHeightUnitEnumEnumMap = {
  LineHeightUnitEnum.pixels: 'pixels',
  LineHeightUnitEnum.percent: 'percent',
  LineHeightUnitEnum.auto: 'auto',
};
