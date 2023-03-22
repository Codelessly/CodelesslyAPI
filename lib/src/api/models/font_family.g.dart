// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_family.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FontFamilyModel _$FontFamilyModelFromJson(Map json) => FontFamilyModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      fontVariants: (json['fontVariants'] as List<dynamic>)
          .map((e) =>
              FontVariantModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$FontFamilyModelToJson(FontFamilyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fontVariants': instance.fontVariants.map((e) => e.toJson()).toList(),
    };

FontVariantModel _$FontVariantModelFromJson(Map json) => FontVariantModel(
      name: json['name'] as String? ?? 'regular',
      weight: $enumDecodeNullable(_$FontWeightNumericEnumMap, json['weight']) ??
          FontWeightNumeric.w400,
      style: json['style'] as String? ?? 'Normal',
      fontURL: json['fontURL'] as String? ?? '',
      previewURL: json['previewURL'] as String? ?? '',
    );

Map<String, dynamic> _$FontVariantModelToJson(FontVariantModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'weight': _$FontWeightNumericEnumMap[instance.weight]!,
      'style': instance.style,
      'fontURL': instance.fontURL,
      'previewURL': instance.previewURL,
    };

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
