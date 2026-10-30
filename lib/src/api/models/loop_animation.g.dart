// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loop_animation.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$LoopAnimationOmitDefaults(
  LoopAnimation instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.durationMs, 1000)) json.remove('durationMs');
  if (isJsonDefault(instance.delayMs, 0)) json.remove('delayMs');
  if (isJsonDefault(instance.reverse, false)) json.remove('reverse');
  if (isJsonDefault(instance.curve, LoopAnimationCurve.linear))
    json.remove('curve');
  if (isJsonDefault(instance.scaleFrom, 1)) json.remove('scaleFrom');
  if (isJsonDefault(instance.scaleTo, 1)) json.remove('scaleTo');
  if (isJsonDefault(instance.opacityFrom, 1)) json.remove('opacityFrom');
  if (isJsonDefault(instance.opacityTo, 1)) json.remove('opacityTo');
  if (isJsonDefault(instance.turns, 1)) json.remove('turns');
  if (isJsonDefault(instance.distance, 10)) json.remove('distance');
  if (isJsonDefault(instance.angle, 4)) json.remove('angle');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoopAnimation _$LoopAnimationFromJson(Map json) => LoopAnimation(
  type: $enumDecode(
    _$LoopAnimationTypeEnumMap,
    json['type'],
    unknownValue: LoopAnimationType.pulse,
  ),
  enabled: json['enabled'] as bool? ?? true,
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 1000,
  delayMs: (json['delayMs'] as num?)?.toInt() ?? 0,
  reverse: json['reverse'] as bool? ?? false,
  curve:
      $enumDecodeNullable(
        _$LoopAnimationCurveEnumMap,
        json['curve'],
        unknownValue: LoopAnimationCurve.linear,
      ) ??
      LoopAnimationCurve.linear,
  scaleFrom: (json['scaleFrom'] as num?)?.toDouble() ?? 1,
  scaleTo: (json['scaleTo'] as num?)?.toDouble() ?? 1,
  opacityFrom: (json['opacityFrom'] as num?)?.toDouble() ?? 1,
  opacityTo: (json['opacityTo'] as num?)?.toDouble() ?? 1,
  turns: (json['turns'] as num?)?.toDouble() ?? 1,
  distance: (json['distance'] as num?)?.toDouble() ?? 10,
  angle: (json['angle'] as num?)?.toDouble() ?? 4,
);

Map<String, dynamic> _$LoopAnimationToJson(LoopAnimation instance) =>
    <String, dynamic>{
      'type': _$LoopAnimationTypeEnumMap[instance.type]!,
      'enabled': instance.enabled,
      'durationMs': instance.durationMs,
      'delayMs': instance.delayMs,
      'reverse': instance.reverse,
      'curve': _$LoopAnimationCurveEnumMap[instance.curve]!,
      'scaleFrom': instance.scaleFrom,
      'scaleTo': instance.scaleTo,
      'opacityFrom': instance.opacityFrom,
      'opacityTo': instance.opacityTo,
      'turns': instance.turns,
      'distance': instance.distance,
      'angle': instance.angle,
    };

const _$LoopAnimationTypeEnumMap = {
  LoopAnimationType.pulse: 'pulse',
  LoopAnimationType.fade: 'fade',
  LoopAnimationType.scale: 'scale',
  LoopAnimationType.spin: 'spin',
  LoopAnimationType.bob: 'bob',
  LoopAnimationType.sway: 'sway',
};

const _$LoopAnimationCurveEnumMap = {
  LoopAnimationCurve.linear: 'linear',
  LoopAnimationCurve.easeIn: 'easeIn',
  LoopAnimationCurve.easeOut: 'easeOut',
  LoopAnimationCurve.easeInOut: 'easeInOut',
  LoopAnimationCurve.fastOutSlowIn: 'fastOutSlowIn',
  LoopAnimationCurve.decelerate: 'decelerate',
};
