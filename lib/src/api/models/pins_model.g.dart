// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pins_model.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$EdgePinsModelOmitDefaults(
  EdgePinsModel instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdgePinsModel _$EdgePinsModelFromJson(Map json) => EdgePinsModel(
  left: (json['left'] as num?)?.toDouble(),
  top: (json['top'] as num?)?.toDouble(),
  right: (json['right'] as num?)?.toDouble(),
  bottom: (json['bottom'] as num?)?.toDouble(),
);

Map<String, dynamic> _$EdgePinsModelToJson(EdgePinsModel instance) =>
    <String, dynamic>{
      'left': ?instance.left,
      'top': ?instance.top,
      'right': ?instance.right,
      'bottom': ?instance.bottom,
    };
