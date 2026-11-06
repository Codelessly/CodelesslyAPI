// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drag_track.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$DragTrackModelOmitDefaults(
  DragTrackModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.shape, DragTrackShape.line)) json.remove('shape');
  if (isJsonDefault(instance.min, 0)) json.remove('min');
  if (isJsonDefault(instance.max, 1)) json.remove('max');
  if (isJsonDefault(instance.step, 0)) json.remove('step');
  if (isJsonDefault(instance.input, DragTrackInput.follow))
    json.remove('input');
  if (isJsonDefault(instance.pixelsPerRange, 200))
    json.remove('pixelsPerRange');
  if (isJsonDefault(instance.x1, 0)) json.remove('x1');
  if (isJsonDefault(instance.y1, 0)) json.remove('y1');
  if (isJsonDefault(instance.x2, 0)) json.remove('x2');
  if (isJsonDefault(instance.y2, -100)) json.remove('y2');
  if (isJsonDefault(instance.startAngle, -135)) json.remove('startAngle');
  if (isJsonDefault(instance.endAngle, 135)) json.remove('endAngle');
  if (isJsonDefault(instance.pivotX, 0)) json.remove('pivotX');
  if (isJsonDefault(instance.pivotY, 0)) json.remove('pivotY');
  if (isJsonDefault(instance.rotate, true)) json.remove('rotate');
  if (isJsonDefault(instance.orientToPath, false)) json.remove('orientToPath');
  if (isJsonDefault(instance.orientUpright, false))
    json.remove('orientUpright');
  if (isJsonDefault(instance.jumpOnTap, false)) json.remove('jumpOnTap');
  if (isJsonDefault(instance.wheel, true)) json.remove('wheel');
  if (isJsonDefault(instance.detent, 0)) json.remove('detent');
  if (isJsonDefault(instance.overscroll, 0)) json.remove('overscroll');
  if (isJsonDefault(instance.settleMs, 0)) json.remove('settleMs');
  if (isJsonDefault(instance.settleCurve, MotionCurve.easeOutCubic))
    json.remove('settleCurve');
  if (isJsonDefault(instance.settleStiffness, 380))
    json.remove('settleStiffness');
  if (isJsonDefault(instance.settleDamping, 20)) json.remove('settleDamping');
  if (isJsonDefault(instance.keyboard, true)) json.remove('keyboard');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DragTrackModel _$DragTrackModelFromJson(Map json) => DragTrackModel(
  shape:
      $enumDecodeNullable(_$DragTrackShapeEnumMap, json['shape']) ??
      DragTrackShape.line,
  variable: json['variable'] as String,
  min: (json['min'] as num?)?.toDouble() ?? 0,
  max: (json['max'] as num?)?.toDouble() ?? 1,
  step: (json['step'] as num?)?.toDouble() ?? 0,
  defaultValue: (json['defaultValue'] as num?)?.toDouble(),
  input:
      $enumDecodeNullable(_$DragTrackInputEnumMap, json['input']) ??
      DragTrackInput.follow,
  pixelsPerRange: (json['pixelsPerRange'] as num?)?.toDouble() ?? 200,
  x1: (json['x1'] as num?)?.toDouble() ?? 0,
  y1: (json['y1'] as num?)?.toDouble() ?? 0,
  x2: (json['x2'] as num?)?.toDouble() ?? 0,
  y2: (json['y2'] as num?)?.toDouble() ?? -100,
  startAngle: (json['startAngle'] as num?)?.toDouble() ?? -135,
  endAngle: (json['endAngle'] as num?)?.toDouble() ?? 135,
  pivotX: (json['pivotX'] as num?)?.toDouble() ?? 0,
  pivotY: (json['pivotY'] as num?)?.toDouble() ?? 0,
  rotate: json['rotate'] as bool? ?? true,
  path: json['path'] as String?,
  orientToPath: json['orientToPath'] as bool? ?? false,
  orientUpright: json['orientUpright'] as bool? ?? false,
  jumpOnTap: json['jumpOnTap'] as bool? ?? false,
  wheel: json['wheel'] as bool? ?? true,
  detent: (json['detent'] as num?)?.toDouble() ?? 0,
  overscroll: (json['overscroll'] as num?)?.toDouble() ?? 0,
  settleMs: (json['settleMs'] as num?)?.toInt() ?? 0,
  settleCurve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['settleCurve']) ??
      MotionCurve.easeOutCubic,
  settleStiffness: (json['settleStiffness'] as num?)?.toDouble() ?? 380,
  settleDamping: (json['settleDamping'] as num?)?.toDouble() ?? 20,
  parkedProgress: (json['parkedProgress'] as num?)?.toDouble(),
  keyboard: json['keyboard'] as bool? ?? true,
);

Map<String, dynamic> _$DragTrackModelToJson(DragTrackModel instance) =>
    <String, dynamic>{
      'shape': _$DragTrackShapeEnumMap[instance.shape]!,
      'variable': instance.variable,
      'min': instance.min,
      'max': instance.max,
      'step': instance.step,
      'defaultValue': ?instance.defaultValue,
      'input': _$DragTrackInputEnumMap[instance.input]!,
      'pixelsPerRange': instance.pixelsPerRange,
      'x1': instance.x1,
      'y1': instance.y1,
      'x2': instance.x2,
      'y2': instance.y2,
      'startAngle': instance.startAngle,
      'endAngle': instance.endAngle,
      'pivotX': instance.pivotX,
      'pivotY': instance.pivotY,
      'rotate': instance.rotate,
      'path': ?instance.path,
      'orientToPath': instance.orientToPath,
      'orientUpright': instance.orientUpright,
      'jumpOnTap': instance.jumpOnTap,
      'wheel': instance.wheel,
      'detent': instance.detent,
      'overscroll': instance.overscroll,
      'settleMs': instance.settleMs,
      'settleCurve': _$MotionCurveEnumMap[instance.settleCurve]!,
      'settleStiffness': instance.settleStiffness,
      'settleDamping': instance.settleDamping,
      'parkedProgress': ?instance.parkedProgress,
      'keyboard': instance.keyboard,
    };

const _$DragTrackShapeEnumMap = {
  DragTrackShape.line: 'line',
  DragTrackShape.arc: 'arc',
  DragTrackShape.path: 'path',
};

const _$DragTrackInputEnumMap = {
  DragTrackInput.follow: 'follow',
  DragTrackInput.vertical: 'vertical',
  DragTrackInput.horizontal: 'horizontal',
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
