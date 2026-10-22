// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motion.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$MotionModelOmitDefaults(
  MotionModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.translateX, 0)) json.remove('translateX');
  if (isJsonDefault(instance.translateY, 0)) json.remove('translateY');
  if (isJsonDefault(instance.scale, 1)) json.remove('scale');
  if (isJsonDefault(instance.opacity, 1)) json.remove('opacity');
  if (isJsonDefault(instance.rotate, 0)) json.remove('rotate');
  if (isJsonDefault(instance.rotateX, 0)) json.remove('rotateX');
  if (isJsonDefault(instance.rotateY, 0)) json.remove('rotateY');
  if (isJsonDefault(instance.perspective, 1)) json.remove('perspective');
  if (isJsonDefault(instance.originX, 0)) json.remove('originX');
  if (isJsonDefault(instance.originY, 0)) json.remove('originY');
  if (isJsonDefault(instance.durationMs, 0)) json.remove('durationMs');
  if (isJsonDefault(instance.curve, MotionCurve.easeInOut))
    json.remove('curve');
  if (isJsonDefault(instance.spin, 0)) json.remove('spin');
  if (isJsonDefault(instance.spinRampMs, 800)) json.remove('spinRampMs');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MotionModel _$MotionModelFromJson(Map json) => MotionModel(
  translateX: (json['translateX'] as num?)?.toDouble() ?? 0,
  translateY: (json['translateY'] as num?)?.toDouble() ?? 0,
  scale: (json['scale'] as num?)?.toDouble() ?? 1,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
  rotate: (json['rotate'] as num?)?.toDouble() ?? 0,
  rotateX: (json['rotateX'] as num?)?.toDouble() ?? 0,
  rotateY: (json['rotateY'] as num?)?.toDouble() ?? 0,
  perspective: (json['perspective'] as num?)?.toDouble() ?? 1,
  originX: (json['originX'] as num?)?.toDouble() ?? 0,
  originY: (json['originY'] as num?)?.toDouble() ?? 0,
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
  curve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['curve']) ??
      MotionCurve.easeInOut,
  spin: (json['spin'] as num?)?.toDouble() ?? 0,
  spinRampMs: (json['spinRampMs'] as num?)?.toInt() ?? 800,
);

Map<String, dynamic> _$MotionModelToJson(MotionModel instance) =>
    <String, dynamic>{
      'translateX': instance.translateX,
      'translateY': instance.translateY,
      'scale': instance.scale,
      'opacity': instance.opacity,
      'rotate': instance.rotate,
      'rotateX': instance.rotateX,
      'rotateY': instance.rotateY,
      'perspective': instance.perspective,
      'originX': instance.originX,
      'originY': instance.originY,
      'durationMs': instance.durationMs,
      'curve': _$MotionCurveEnumMap[instance.curve]!,
      'spin': instance.spin,
      'spinRampMs': instance.spinRampMs,
    };

const _$MotionCurveEnumMap = {
  MotionCurve.linear: 'linear',
  MotionCurve.easeInOut: 'easeInOut',
  MotionCurve.easeOut: 'easeOut',
  MotionCurve.easeIn: 'easeIn',
  MotionCurve.easeOutBack: 'easeOutBack',
  MotionCurve.easeOutCubic: 'easeOutCubic',
};
