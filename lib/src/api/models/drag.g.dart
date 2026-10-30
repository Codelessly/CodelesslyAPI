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
  if (isJsonDefault(instance.release, DragRelease.snapBack))
    json.remove('release');
  if (isJsonDefault(instance.directions, const [
    DragDirection.left,
    DragDirection.right,
    DragDirection.up,
    DragDirection.down,
  ]))
    json.remove('directions');
  if (isJsonDefault(instance.distanceThreshold, 0.35))
    json.remove('distanceThreshold');
  if (isJsonDefault(instance.velocityThreshold, 800))
    json.remove('velocityThreshold');
  if (isJsonDefault(instance.rotateFactor, 0)) json.remove('rotateFactor');
  if (isJsonDefault(instance.originX, 0)) json.remove('originX');
  if (isJsonDefault(instance.originY, 0)) json.remove('originY');
  if (isJsonDefault(instance.resistance, 0)) json.remove('resistance');
  if (isJsonDefault(instance.snapBackMs, 450)) json.remove('snapBackMs');
  if (isJsonDefault(instance.snapCurve, MotionCurve.spring))
    json.remove('snapCurve');
  if (isJsonDefault(instance.flyOutMs, 320)) json.remove('flyOutMs');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.shakeWhenDisabled, false))
    json.remove('shakeWhenDisabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DragModel _$DragModelFromJson(Map json) => DragModel(
  axis: $enumDecodeNullable(_$DragAxisEnumMap, json['axis']) ?? DragAxis.free,
  release:
      $enumDecodeNullable(_$DragReleaseEnumMap, json['release']) ??
      DragRelease.snapBack,
  directions:
      (json['directions'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DragDirectionEnumMap, e))
          .toList() ??
      const [
        DragDirection.left,
        DragDirection.right,
        DragDirection.up,
        DragDirection.down,
      ],
  distanceThreshold: (json['distanceThreshold'] as num?)?.toDouble() ?? 0.35,
  velocityThreshold: (json['velocityThreshold'] as num?)?.toDouble() ?? 800,
  rotateFactor: (json['rotateFactor'] as num?)?.toDouble() ?? 0,
  originX: (json['originX'] as num?)?.toDouble() ?? 0,
  originY: (json['originY'] as num?)?.toDouble() ?? 0,
  resistance: (json['resistance'] as num?)?.toDouble() ?? 0,
  snapBackMs: (json['snapBackMs'] as num?)?.toInt() ?? 450,
  snapCurve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['snapCurve']) ??
      MotionCurve.spring,
  flyOutMs: (json['flyOutMs'] as num?)?.toInt() ?? 320,
  enabled: json['enabled'] as bool? ?? true,
  shakeWhenDisabled: json['shakeWhenDisabled'] as bool? ?? false,
);

Map<String, dynamic> _$DragModelToJson(DragModel instance) => <String, dynamic>{
  'axis': _$DragAxisEnumMap[instance.axis]!,
  'release': _$DragReleaseEnumMap[instance.release]!,
  'directions': instance.directions
      .map((e) => _$DragDirectionEnumMap[e]!)
      .toList(),
  'distanceThreshold': instance.distanceThreshold,
  'velocityThreshold': instance.velocityThreshold,
  'rotateFactor': instance.rotateFactor,
  'originX': instance.originX,
  'originY': instance.originY,
  'resistance': instance.resistance,
  'snapBackMs': instance.snapBackMs,
  'snapCurve': _$MotionCurveEnumMap[instance.snapCurve]!,
  'flyOutMs': instance.flyOutMs,
  'enabled': instance.enabled,
  'shakeWhenDisabled': instance.shakeWhenDisabled,
};

const _$DragAxisEnumMap = {
  DragAxis.free: 'free',
  DragAxis.horizontal: 'horizontal',
  DragAxis.vertical: 'vertical',
};

const _$DragReleaseEnumMap = {
  DragRelease.snapBack: 'snapBack',
  DragRelease.stay: 'stay',
  DragRelease.dismiss: 'dismiss',
};

const _$DragDirectionEnumMap = {
  DragDirection.left: 'left',
  DragDirection.right: 'right',
  DragDirection.up: 'up',
  DragDirection.down: 'down',
};

const _$MotionCurveEnumMap = {
  MotionCurve.linear: 'linear',
  MotionCurve.easeInOut: 'easeInOut',
  MotionCurve.easeOut: 'easeOut',
  MotionCurve.easeIn: 'easeIn',
  MotionCurve.easeOutBack: 'easeOutBack',
  MotionCurve.easeOutCubic: 'easeOutCubic',
  MotionCurve.spring: 'spring',
  MotionCurve.elasticOut: 'elasticOut',
  MotionCurve.bounceOut: 'bounceOut',
  MotionCurve.fastOutSlowIn: 'fastOutSlowIn',
};
