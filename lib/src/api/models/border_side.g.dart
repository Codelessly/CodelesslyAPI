// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'border_side.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorderSideModel _$BorderSideModelFromJson(Map json) => BorderSideModel(
      color: json['color'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['color']),
      style: $enumDecodeNullable(_$BorderStyleEnumEnumMap, json['style']) ??
          BorderStyleEnum.solid,
      width: (json['width'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$BorderSideModelToJson(BorderSideModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'color', instance.color, instance.color.toJson(), ColorRGBA.black);
  writeNotNull('style', instance.style,
      _$BorderStyleEnumEnumMap[instance.style]!, BorderStyleEnum.solid);
  writeNotNull('width', instance.width, instance.width, 1);
  return val;
}

const _$BorderStyleEnumEnumMap = {
  BorderStyleEnum.solid: 'solid',
  BorderStyleEnum.none: 'none',
};
