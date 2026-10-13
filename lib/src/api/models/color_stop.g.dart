// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_stop.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ColorStopOmitDefaults(
  ColorStop instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorStop _$ColorStopFromJson(Map json) => ColorStop(
  position: (json['position'] as num).toDouble(),
  color: ColorRGBA.fromJson(json['color']),
);

Map<String, dynamic> _$ColorStopToJson(ColorStop instance) => <String, dynamic>{
  'position': instance.position,
  'color': instance.color.toJson(),
};
