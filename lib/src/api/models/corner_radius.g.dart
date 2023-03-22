// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_radius.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CornerRadius _$CornerRadiusFromJson(Map json) => CornerRadius(
      type: $enumDecodeNullable(_$RadiusTypeEnumMap, json['type']) ??
          RadiusType.circular,
      tl: RadiusModel.fromJson(json['tl'] as Map),
      tr: RadiusModel.fromJson(json['tr'] as Map),
      bl: RadiusModel.fromJson(json['bl'] as Map),
      br: RadiusModel.fromJson(json['br'] as Map),
      linked: json['linked'] as bool? ?? false,
    );

Map<String, dynamic> _$CornerRadiusToJson(CornerRadius instance) =>
    <String, dynamic>{
      'tl': instance.tl.toJson(),
      'tr': instance.tr.toJson(),
      'bl': instance.bl.toJson(),
      'br': instance.br.toJson(),
      'type': _$RadiusTypeEnumMap[instance.type]!,
      'linked': instance.linked,
    };

const _$RadiusTypeEnumMap = {
  RadiusType.circular: 'circular',
  RadiusType.elliptical: 'elliptical',
};

RadiusModel _$RadiusModelFromJson(Map json) => RadiusModel(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$RadiusModelToJson(RadiusModel instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };
