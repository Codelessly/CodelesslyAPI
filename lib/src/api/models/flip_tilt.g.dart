// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flip_tilt.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$FlipModelOmitDefaults(
  FlipModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.axis, FlipAxis.y)) json.remove('axis');
  if (isJsonDefault(instance.flipped, false)) json.remove('flipped');
  if (isJsonDefault(instance.tapToFlip, true)) json.remove('tapToFlip');
  if (isJsonDefault(instance.dragToFlip, false)) json.remove('dragToFlip');
  if (isJsonDefault(instance.variable, '')) json.remove('variable');
  if (isJsonDefault(instance.spring, const TransitionSpring()))
    json.remove('spring');
  return json;
}

Map<String, dynamic> _$TiltModelOmitDefaults(
  TiltModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(
    instance.max,
    const MotionModel(rotateX: 10, rotateY: 10, scale: 1.03),
  ))
    json.remove('max');
  if (isJsonDefault(instance.hover, true)) json.remove('hover');
  if (isJsonDefault(instance.drag, true)) json.remove('drag');
  if (isJsonDefault(instance.resetMs, 400)) json.remove('resetMs');
  if (isJsonDefault(instance.curve, MotionCurve.easeOutCubic))
    json.remove('curve');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlipModel _$FlipModelFromJson(Map json) => FlipModel(
  axis: $enumDecodeNullable(_$FlipAxisEnumMap, json['axis']) ?? FlipAxis.y,
  flipped: json['flipped'] as bool? ?? false,
  tapToFlip: json['tapToFlip'] as bool? ?? true,
  dragToFlip: json['dragToFlip'] as bool? ?? false,
  variable: json['variable'] as String? ?? '',
  spring: json['spring'] == null
      ? const TransitionSpring()
      : TransitionSpring.fromJson(json['spring'] as Map),
);

Map<String, dynamic> _$FlipModelToJson(FlipModel instance) => <String, dynamic>{
  'axis': _$FlipAxisEnumMap[instance.axis]!,
  'flipped': instance.flipped,
  'tapToFlip': instance.tapToFlip,
  'dragToFlip': instance.dragToFlip,
  'variable': instance.variable,
  'spring': instance.spring.toJson(),
};

const _$FlipAxisEnumMap = {FlipAxis.y: 'y', FlipAxis.x: 'x'};

TiltModel _$TiltModelFromJson(Map json) => TiltModel(
  max: json['max'] == null
      ? const MotionModel(rotateX: 10, rotateY: 10, scale: 1.03)
      : MotionModel.fromJson(json['max'] as Map),
  hover: json['hover'] as bool? ?? true,
  drag: json['drag'] as bool? ?? true,
  resetMs: (json['resetMs'] as num?)?.toInt() ?? 400,
  curve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['curve']) ??
      MotionCurve.easeOutCubic,
);

Map<String, dynamic> _$TiltModelToJson(TiltModel instance) => <String, dynamic>{
  'max': instance.max.toJson(),
  'hover': instance.hover,
  'drag': instance.drag,
  'resetMs': instance.resetMs,
  'curve': _$MotionCurveEnumMap[instance.curve]!,
};

const _$MotionCurveEnumMap = {
  MotionCurve.linear: 'linear',
  MotionCurve.easeInOut: 'easeInOut',
  MotionCurve.easeOut: 'easeOut',
  MotionCurve.easeIn: 'easeIn',
  MotionCurve.easeOutBack: 'easeOutBack',
  MotionCurve.easeOutCubic: 'easeOutCubic',
  MotionCurve.easeInOutSine: 'easeInOutSine',
  MotionCurve.spring: 'spring',
  MotionCurve.elasticOut: 'elasticOut',
  MotionCurve.bounceOut: 'bounceOut',
  MotionCurve.fastOutSlowIn: 'fastOutSlowIn',
  MotionCurve.easeInOutCubic: 'easeInOutCubic',
  MotionCurve.step: 'step',
};
