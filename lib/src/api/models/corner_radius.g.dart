// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_radius.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$CornerRadiusOmitDefaults(
  CornerRadius instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.type, RadiusType.circular)) json.remove('type');
  if (isJsonDefault(instance.linked, false)) json.remove('linked');
  return json;
}

Map<String, dynamic> _$RadiusModelOmitDefaults(
  RadiusModel instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CornerRadius _$CornerRadiusFromJson(Map json) => CornerRadius(
  type:
      $enumDecodeNullable(_$RadiusTypeEnumMap, json['type']) ??
      RadiusType.circular,
  tl: RadiusModel.fromJson(json['tl']),
  tr: RadiusModel.fromJson(json['tr']),
  bl: RadiusModel.fromJson(json['bl']),
  br: RadiusModel.fromJson(json['br']),
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
    <String, dynamic>{'x': instance.x, 'y': instance.y};
