// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_height.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineHeight _$LineHeightFromJson(Map json) => LineHeight(
      value: (json['value'] as num?)?.toDouble(),
      unit: $enumDecode(_$LineHeightUnitEnumEnumMap, json['unit']),
    );

Map<String, dynamic> _$LineHeightToJson(LineHeight instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('value', instance.value);
  val['unit'] = _$LineHeightUnitEnumEnumMap[instance.unit]!;
  return val;
}

const _$LineHeightUnitEnumEnumMap = {
  LineHeightUnitEnum.pixels: 'pixels',
  LineHeightUnitEnum.percent: 'percent',
  LineHeightUnitEnum.auto: 'auto',
};
