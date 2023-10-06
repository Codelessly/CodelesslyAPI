// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_border.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InputBorderModel _$InputBorderModelFromJson(Map json) => InputBorderModel(
      borderType:
          $enumDecodeNullable(_$BorderTypeEnumEnumMap, json['borderType']) ??
              BorderTypeEnum.outline,
      borderSide: json['borderSide'] == null
          ? const BorderSideModel()
          : BorderSideModel.fromJson(json['borderSide'] as Map),
      cornerRadius: json['cornerRadius'] == null
          ? const CornerRadius.all(RadiusModel.circular(4))
          : CornerRadius.fromJson(json['cornerRadius']),
      gapPadding: (json['gapPadding'] as num?)?.toDouble() ?? 4,
    );

Map<String, dynamic> _$InputBorderModelToJson(InputBorderModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('borderType', instance.borderType,
      _$BorderTypeEnumEnumMap[instance.borderType]!, BorderTypeEnum.outline);
  writeNotNull('borderSide', instance.borderSide, instance.borderSide.toJson(),
      const BorderSideModel());
  writeNotNull(
      'cornerRadius',
      instance.cornerRadius,
      instance.cornerRadius.toJson(),
      const CornerRadius.all(RadiusModel.circular(4)));
  writeNotNull('gapPadding', instance.gapPadding, instance.gapPadding, 4);
  return val;
}

const _$BorderTypeEnumEnumMap = {
  BorderTypeEnum.none: 'none',
  BorderTypeEnum.outline: 'outline',
  BorderTypeEnum.underline: 'underline',
};
