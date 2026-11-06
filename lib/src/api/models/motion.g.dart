// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motion.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$MotionKeyframeOmitDefaults(
  MotionKeyframe instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$MotionModelOmitDefaults(
  MotionModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.translateX, 0)) json.remove('translateX');
  if (isJsonDefault(instance.translateY, 0)) json.remove('translateY');
  if (isJsonDefault(instance.scale, 1)) json.remove('scale');
  if (isJsonDefault(instance.shiftX, 0)) json.remove('shiftX');
  if (isJsonDefault(instance.shiftY, 0)) json.remove('shiftY');
  if (isJsonDefault(instance.scaleX, 1)) json.remove('scaleX');
  if (isJsonDefault(instance.scaleY, 1)) json.remove('scaleY');
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
  if (isJsonDefault(instance.springStiffness, 380))
    json.remove('springStiffness');
  if (isJsonDefault(instance.springDamping, 20)) json.remove('springDamping');
  if (isJsonDefault(instance.spin, 0)) json.remove('spin');
  if (isJsonDefault(instance.spinRampMs, 800)) json.remove('spinRampMs');
  if (isJsonDefault(instance.loop, MotionLoop.none)) json.remove('loop');
  if (isJsonDefault(instance.repeat, 0)) json.remove('repeat');
  if (isJsonDefault(instance.enter, false)) json.remove('enter');
  if (isJsonDefault(instance.delayMs, 0)) json.remove('delayMs');
  if (isJsonDefault(instance.blur, 0)) json.remove('blur');
  if (isJsonDefault(instance.backfaceHidden, false))
    json.remove('backfaceHidden');
  if (isJsonDefault(instance.pathProgress, 0)) json.remove('pathProgress');
  if (isJsonDefault(instance.arc, 0)) json.remove('arc');
  if (isJsonDefault(instance.orientToPath, false)) json.remove('orientToPath');
  if (isJsonDefault(instance.paused, false)) json.remove('paused');
  if (isJsonDefault(instance.phase, 0)) json.remove('phase');
  if (isJsonDefault(instance.pathPacing, MotionPathPacing.length))
    json.remove('pathPacing');
  if (isJsonDefault(instance.pathFocusX, 0)) json.remove('pathFocusX');
  if (isJsonDefault(instance.pathFocusY, 0)) json.remove('pathFocusY');
  if (isJsonDefault(instance.pathWrap, false)) json.remove('pathWrap');
  if (isJsonDefault(instance.keyframes, const [])) json.remove('keyframes');
  if (isJsonDefault(instance.revealOnScroll, false))
    json.remove('revealOnScroll');
  if (isJsonDefault(instance.revealFraction, kDefaultVisibleFraction))
    json.remove('revealFraction');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MotionKeyframe _$MotionKeyframeFromJson(Map json) => MotionKeyframe(
  t: (json['t'] as num).toDouble(),
  translateX: (json['translateX'] as num?)?.toDouble(),
  translateY: (json['translateY'] as num?)?.toDouble(),
  scale: (json['scale'] as num?)?.toDouble(),
  scaleX: (json['scaleX'] as num?)?.toDouble(),
  scaleY: (json['scaleY'] as num?)?.toDouble(),
  opacity: (json['opacity'] as num?)?.toDouble(),
  rotate: (json['rotate'] as num?)?.toDouble(),
  rotateX: (json['rotateX'] as num?)?.toDouble(),
  rotateY: (json['rotateY'] as num?)?.toDouble(),
  pathProgress: (json['pathProgress'] as num?)?.toDouble(),
);

Map<String, dynamic> _$MotionKeyframeToJson(MotionKeyframe instance) =>
    <String, dynamic>{
      't': instance.t,
      'translateX': ?instance.translateX,
      'translateY': ?instance.translateY,
      'scale': ?instance.scale,
      'scaleX': ?instance.scaleX,
      'scaleY': ?instance.scaleY,
      'opacity': ?instance.opacity,
      'rotate': ?instance.rotate,
      'rotateX': ?instance.rotateX,
      'rotateY': ?instance.rotateY,
      'pathProgress': ?instance.pathProgress,
    };

MotionModel _$MotionModelFromJson(Map json) => MotionModel(
  translateX: (json['translateX'] as num?)?.toDouble() ?? 0,
  translateY: (json['translateY'] as num?)?.toDouble() ?? 0,
  scale: (json['scale'] as num?)?.toDouble() ?? 1,
  shiftX: (json['shiftX'] as num?)?.toDouble() ?? 0,
  shiftY: (json['shiftY'] as num?)?.toDouble() ?? 0,
  scaleX: (json['scaleX'] as num?)?.toDouble() ?? 1,
  scaleY: (json['scaleY'] as num?)?.toDouble() ?? 1,
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
  springStiffness: (json['springStiffness'] as num?)?.toDouble() ?? 380,
  springDamping: (json['springDamping'] as num?)?.toDouble() ?? 20,
  spin: (json['spin'] as num?)?.toDouble() ?? 0,
  spinRampMs: (json['spinRampMs'] as num?)?.toInt() ?? 800,
  loop:
      $enumDecodeNullable(_$MotionLoopEnumMap, json['loop']) ?? MotionLoop.none,
  repeat: (json['repeat'] as num?)?.toInt() ?? 0,
  enter: json['enter'] as bool? ?? false,
  enterFrom: json['enterFrom'] == null
      ? null
      : MotionModel.fromJson(json['enterFrom'] as Map),
  replayKey: json['replayKey'] as String?,
  delayMs: (json['delayMs'] as num?)?.toInt() ?? 0,
  blur: (json['blur'] as num?)?.toDouble() ?? 0,
  backfaceHidden: json['backfaceHidden'] as bool? ?? false,
  path: json['path'] as String?,
  pathProgress: (json['pathProgress'] as num?)?.toDouble() ?? 0,
  arc: (json['arc'] as num?)?.toDouble() ?? 0,
  orientToPath: json['orientToPath'] as bool? ?? false,
  paused: json['paused'] as bool? ?? false,
  phase: (json['phase'] as num?)?.toDouble() ?? 0,
  pathPacing:
      $enumDecodeNullable(_$MotionPathPacingEnumMap, json['pathPacing']) ??
      MotionPathPacing.length,
  pathFocusX: (json['pathFocusX'] as num?)?.toDouble() ?? 0,
  pathFocusY: (json['pathFocusY'] as num?)?.toDouble() ?? 0,
  pathWrap: json['pathWrap'] as bool? ?? false,
  keyframes:
      (json['keyframes'] as List<dynamic>?)
          ?.map((e) => MotionKeyframe.fromJson(e as Map))
          .toList() ??
      const [],
  pulseKey: json['pulseKey'] as String?,
  revealOnScroll: json['revealOnScroll'] as bool? ?? false,
  revealFraction:
      (json['revealFraction'] as num?)?.toDouble() ?? kDefaultVisibleFraction,
);

Map<String, dynamic> _$MotionModelToJson(MotionModel instance) =>
    <String, dynamic>{
      'translateX': instance.translateX,
      'translateY': instance.translateY,
      'scale': instance.scale,
      'shiftX': instance.shiftX,
      'shiftY': instance.shiftY,
      'scaleX': instance.scaleX,
      'scaleY': instance.scaleY,
      'opacity': instance.opacity,
      'rotate': instance.rotate,
      'rotateX': instance.rotateX,
      'rotateY': instance.rotateY,
      'perspective': instance.perspective,
      'originX': instance.originX,
      'originY': instance.originY,
      'durationMs': instance.durationMs,
      'curve': _$MotionCurveEnumMap[instance.curve]!,
      'springStiffness': instance.springStiffness,
      'springDamping': instance.springDamping,
      'spin': instance.spin,
      'spinRampMs': instance.spinRampMs,
      'loop': _$MotionLoopEnumMap[instance.loop]!,
      'repeat': instance.repeat,
      'enter': instance.enter,
      'enterFrom': ?instance.enterFrom?.toJson(),
      'replayKey': ?instance.replayKey,
      'delayMs': instance.delayMs,
      'blur': instance.blur,
      'backfaceHidden': instance.backfaceHidden,
      'path': ?instance.path,
      'pathProgress': instance.pathProgress,
      'arc': instance.arc,
      'orientToPath': instance.orientToPath,
      'paused': instance.paused,
      'phase': instance.phase,
      'pathPacing': _$MotionPathPacingEnumMap[instance.pathPacing]!,
      'pathFocusX': instance.pathFocusX,
      'pathFocusY': instance.pathFocusY,
      'pathWrap': instance.pathWrap,
      'keyframes': instance.keyframes.map((e) => e.toJson()).toList(),
      'pulseKey': ?instance.pulseKey,
      'revealOnScroll': instance.revealOnScroll,
      'revealFraction': instance.revealFraction,
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

const _$MotionLoopEnumMap = {
  MotionLoop.none: 'none',
  MotionLoop.restart: 'restart',
  MotionLoop.reverse: 'reverse',
  MotionLoop.swing: 'swing',
};

const _$MotionPathPacingEnumMap = {
  MotionPathPacing.length: 'length',
  MotionPathPacing.area: 'area',
};
