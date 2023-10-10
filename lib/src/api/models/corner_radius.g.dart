// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_radius.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CornerRadius _$CornerRadiusFromJson(Map json) => CornerRadius(
      type: $enumDecodeNullable(_$RadiusTypeEnumMap, json['type']) ??
          RadiusType.circular,
      tl: RadiusModel.fromJson(json['tl']),
      tr: RadiusModel.fromJson(json['tr']),
      bl: RadiusModel.fromJson(json['bl']),
      br: RadiusModel.fromJson(json['br']),
      linked: json['linked'] as bool? ?? false,
    );

Map<String, dynamic> _$CornerRadiusToJson(CornerRadius instance) {
  final val = <String, dynamic>{
    'tl': instance.tl.toJson(),
    'tr': instance.tr.toJson(),
    'bl': instance.bl.toJson(),
    'br': instance.br.toJson(),
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('type', instance.type, _$RadiusTypeEnumMap[instance.type]!,
      RadiusType.circular);
  writeNotNull('linked', instance.linked, instance.linked, false);
  return val;
}

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
