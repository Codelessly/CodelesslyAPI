// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$VecOmitDefaults(
  Vec instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vec _$VecFromJson(Map json) =>
    Vec((json['x'] as num).toDouble(), (json['y'] as num).toDouble());

Map<String, dynamic> _$VecToJson(Vec instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
};
