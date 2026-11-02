// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drag.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$DragModelOmitDefaults(
  DragModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.axis, DragAxis.free)) json.remove('axis');
  if (isJsonDefault(instance.follow, true)) json.remove('follow');
  if (isJsonDefault(instance.rotate, 0)) json.remove('rotate');
  if (isJsonDefault(instance.originX, 0)) json.remove('originX');
  if (isJsonDefault(instance.originY, 0)) json.remove('originY');
  if (isJsonDefault(instance.returnMs, 260)) json.remove('returnMs');
  if (isJsonDefault(instance.returnCurve, MotionCurve.easeOutBack))
    json.remove('returnCurve');
  if (isJsonDefault(instance.dismissTo, 1.25)) json.remove('dismissTo');
  if (isJsonDefault(instance.dismissMs, 240)) json.remove('dismissMs');
  if (isJsonDefault(instance.dismissCurve, MotionCurve.easeIn))
    json.remove('dismissCurve');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DragModel _$DragModelFromJson(Map json) => DragModel(
  axis: $enumDecodeNullable(_$DragAxisEnumMap, json['axis']) ?? DragAxis.free,
  follow: json['follow'] as bool? ?? true,
  rotate: (json['rotate'] as num?)?.toDouble() ?? 0,
  originX: (json['originX'] as num?)?.toDouble() ?? 0,
  originY: (json['originY'] as num?)?.toDouble() ?? 0,
  returnMs: (json['returnMs'] as num?)?.toInt() ?? 260,
  returnCurve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['returnCurve']) ??
      MotionCurve.easeOutBack,
  dismissDistance: (json['dismissDistance'] as num?)?.toDouble(),
  dismissVelocity: (json['dismissVelocity'] as num?)?.toDouble(),
  dismissTo: (json['dismissTo'] as num?)?.toDouble() ?? 1.25,
  dismissMs: (json['dismissMs'] as num?)?.toInt() ?? 240,
  dismissCurve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['dismissCurve']) ??
      MotionCurve.easeIn,
  xVariable: json['xVariable'] as String?,
  yVariable: json['yVariable'] as String?,
);

Map<String, dynamic> _$DragModelToJson(DragModel instance) => <String, dynamic>{
  'axis': _$DragAxisEnumMap[instance.axis]!,
  'follow': instance.follow,
  'rotate': instance.rotate,
  'originX': instance.originX,
  'originY': instance.originY,
  'returnMs': instance.returnMs,
  'returnCurve': _$MotionCurveEnumMap[instance.returnCurve]!,
  'dismissDistance': ?instance.dismissDistance,
  'dismissVelocity': ?instance.dismissVelocity,
  'dismissTo': instance.dismissTo,
  'dismissMs': instance.dismissMs,
  'dismissCurve': _$MotionCurveEnumMap[instance.dismissCurve]!,
  'xVariable': ?instance.xVariable,
  'yVariable': ?instance.yVariable,
};

const _$DragAxisEnumMap = {
  DragAxis.horizontal: 'horizontal',
  DragAxis.vertical: 'vertical',
  DragAxis.free: 'free',
};

const _$MotionCurveEnumMap = {
  MotionCurve.linear: 'linear',
  MotionCurve.easeInOut: 'easeInOut',
  MotionCurve.easeOut: 'easeOut',
  MotionCurve.easeIn: 'easeIn',
  MotionCurve.easeOutBack: 'easeOutBack',
  MotionCurve.easeOutCubic: 'easeOutCubic',
};
