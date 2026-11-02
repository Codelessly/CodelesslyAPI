// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notch.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$NotchModelOmitDefaults(
  NotchModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.edge, NotchEdge.leftRight)) json.remove('edge');
  if (isJsonDefault(instance.offset, 0.5)) json.remove('offset');
  if (isJsonDefault(instance.fromEnd, false)) json.remove('fromEnd');
  if (isJsonDefault(instance.relative, true)) json.remove('relative');
  if (isJsonDefault(instance.radius, 10)) json.remove('radius');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotchModel _$NotchModelFromJson(Map json) => NotchModel(
  edge:
      $enumDecodeNullable(_$NotchEdgeEnumMap, json['edge']) ??
      NotchEdge.leftRight,
  offset: (json['offset'] as num?)?.toDouble() ?? 0.5,
  fromEnd: json['fromEnd'] as bool? ?? false,
  relative: json['relative'] as bool? ?? true,
  radius: (json['radius'] as num?)?.toDouble() ?? 10,
);

Map<String, dynamic> _$NotchModelToJson(NotchModel instance) =>
    <String, dynamic>{
      'edge': _$NotchEdgeEnumMap[instance.edge]!,
      'offset': instance.offset,
      'fromEnd': instance.fromEnd,
      'relative': instance.relative,
      'radius': instance.radius,
    };

const _$NotchEdgeEnumMap = {
  NotchEdge.left: 'left',
  NotchEdge.right: 'right',
  NotchEdge.leftRight: 'leftRight',
  NotchEdge.top: 'top',
  NotchEdge.bottom: 'bottom',
  NotchEdge.topBottom: 'topBottom',
};
