// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_constraints.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$BoxConstraintsModelOmitDefaults(
  BoxConstraintsModel instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoxConstraintsModel _$BoxConstraintsModelFromJson(Map json) =>
    BoxConstraintsModel(
      minWidth: (json['minWidth'] as num?)?.toDouble(),
      maxWidth: (json['maxWidth'] as num?)?.toDouble(),
      minHeight: (json['minHeight'] as num?)?.toDouble(),
      maxHeight: (json['maxHeight'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BoxConstraintsModelToJson(
  BoxConstraintsModel instance,
) => <String, dynamic>{
  'minWidth': ?instance.minWidth,
  'maxWidth': ?instance.maxWidth,
  'minHeight': ?instance.minHeight,
  'maxHeight': ?instance.maxHeight,
};
