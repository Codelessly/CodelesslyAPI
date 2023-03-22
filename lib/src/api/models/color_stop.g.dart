// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_stop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorStop _$ColorStopFromJson(Map json) => ColorStop(
      position: (json['position'] as num).toDouble(),
      color: ColorRGBA.fromJson(json['color'] as Map),
    );

Map<String, dynamic> _$ColorStopToJson(ColorStop instance) => <String, dynamic>{
      'position': instance.position,
      'color': instance.color.toJson(),
    };
