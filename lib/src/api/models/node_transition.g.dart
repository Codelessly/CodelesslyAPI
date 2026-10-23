// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_transition.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$NodeTransitionOmitDefaults(
  NodeTransition instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.durationMillis, 200))
    json.remove('durationMillis');
  if (isJsonDefault(instance.curve, TransitionCurve.easeInOut))
    json.remove('curve');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeTransition _$NodeTransitionFromJson(Map json) => NodeTransition(
  durationMillis: (json['durationMillis'] as num?)?.toInt() ?? 200,
  curve:
      $enumDecodeNullable(_$TransitionCurveEnumMap, json['curve']) ??
      TransitionCurve.easeInOut,
);

Map<String, dynamic> _$NodeTransitionToJson(NodeTransition instance) =>
    <String, dynamic>{
      'durationMillis': instance.durationMillis,
      'curve': _$TransitionCurveEnumMap[instance.curve]!,
    };

const _$TransitionCurveEnumMap = {
  TransitionCurve.linear: 'linear',
  TransitionCurve.easeIn: 'easeIn',
  TransitionCurve.easeOut: 'easeOut',
  TransitionCurve.easeInOut: 'easeInOut',
  TransitionCurve.easeOutCubic: 'easeOutCubic',
};
