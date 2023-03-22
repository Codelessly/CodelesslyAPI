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
          : CornerRadius.fromJson(json['cornerRadius'] as Map),
      gapPadding: (json['gapPadding'] as num?)?.toDouble() ?? 4,
    );

Map<String, dynamic> _$InputBorderModelToJson(InputBorderModel instance) =>
    <String, dynamic>{
      'borderType': _$BorderTypeEnumEnumMap[instance.borderType]!,
      'borderSide': instance.borderSide.toJson(),
      'cornerRadius': instance.cornerRadius.toJson(),
      'gapPadding': instance.gapPadding,
    };

const _$BorderTypeEnumEnumMap = {
  BorderTypeEnum.none: 'none',
  BorderTypeEnum.outline: 'outline',
  BorderTypeEnum.underline: 'underline',
};
