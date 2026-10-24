// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_style_model.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TextStyleModelOmitDefaults(
  TextStyleModel instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextStyleModel _$TextStyleModelFromJson(Map json) => TextStyleModel(
  fontFamily: json['fontFamily'] as String?,
  fontWeight: $enumDecodeNullable(
    _$FontWeightNumericEnumMap,
    json['fontWeight'],
    unknownValue: FontWeightNumeric.w400,
  ),
  italic: json['italic'] as bool?,
  fontSize: (json['fontSize'] as num?)?.toDouble(),
  lineHeight: (json['lineHeight'] as num?)?.toDouble(),
  letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
  color: json['color'] == null ? null : ColorRGBA.fromJson(json['color']),
);

Map<String, dynamic> _$TextStyleModelToJson(TextStyleModel instance) =>
    <String, dynamic>{
      'fontFamily': ?instance.fontFamily,
      'fontWeight': ?_$FontWeightNumericEnumMap[instance.fontWeight],
      'italic': ?instance.italic,
      'fontSize': ?instance.fontSize,
      'lineHeight': ?instance.lineHeight,
      'letterSpacing': ?instance.letterSpacing,
      'color': ?instance.color?.toJson(),
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
