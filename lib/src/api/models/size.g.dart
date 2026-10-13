// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'size.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SizeCOmitDefaults(
  SizeC instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SizeC _$SizeCFromJson(Map json) => SizeC(
  (json['width'] as num).toDouble(),
  (json['height'] as num).toDouble(),
);

Map<String, dynamic> _$SizeCToJson(SizeC instance) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
};
