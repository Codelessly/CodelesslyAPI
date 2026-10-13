// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_rgb.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ColorRGBOmitDefaults(
  ColorRGB instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorRGB _$ColorRGBFromJson(Map json) => ColorRGB(
  r: (json['r'] as num).toDouble(),
  g: (json['g'] as num).toDouble(),
  b: (json['b'] as num).toDouble(),
);

Map<String, dynamic> _$ColorRGBToJson(ColorRGB instance) => <String, dynamic>{
  'r': instance.r,
  'g': instance.g,
  'b': instance.b,
};
