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
  if (isJsonDefault(instance.disabledFollow, 0)) json.remove('disabledFollow');
  if (isJsonDefault(instance.flyOutRotate, 0)) json.remove('flyOutRotate');
  if (isJsonDefault(instance.shareAs, '')) json.remove('shareAs');
  if (isJsonDefault(instance.restX, 0)) json.remove('restX');
  if (isJsonDefault(instance.restY, 0)) json.remove('restY');
  if (isJsonDefault(instance.reorder, false)) json.remove('reorder');
  if (isJsonDefault(instance.follow, true)) json.remove('follow');
  if (isJsonDefault(instance.flyOutCurve, MotionCurve.easeIn))
    json.remove('flyOutCurve');
  if (isJsonDefault(instance.xVariable, '')) json.remove('xVariable');
  if (isJsonDefault(instance.yVariable, '')) json.remove('yVariable');
  if (isJsonDefault(instance.bounds, GestureBounds.none)) json.remove('bounds');
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
  verticalThreshold: (json['verticalThreshold'] as num?)?.toDouble(),
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
  disabledFollow: (json['disabledFollow'] as num?)?.toDouble() ?? 0,
  flyOutRotate: (json['flyOutRotate'] as num?)?.toDouble() ?? 0,
  shareAs: json['shareAs'] as String? ?? '',
  restX: (json['restX'] as num?)?.toDouble() ?? 0,
  restY: (json['restY'] as num?)?.toDouble() ?? 0,
  track: json['track'] == null
      ? null
      : DragTrackModel.fromJson(json['track'] as Map),
  reorder: json['reorder'] as bool? ?? false,
  follow: json['follow'] as bool? ?? true,
  flyOutDistance: (json['flyOutDistance'] as num?)?.toDouble(),
  flyOutCurve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['flyOutCurve']) ??
      MotionCurve.easeIn,
  xVariable: json['xVariable'] as String? ?? '',
  yVariable: json['yVariable'] as String? ?? '',
  physics: json['physics'] == null
      ? null
      : PhysicsModel.fromJson(json['physics'] as Map),
  bounds:
      $enumDecodeNullable(
        _$GestureBoundsEnumMap,
        json['bounds'],
        unknownValue: GestureBounds.none,
      ) ??
      GestureBounds.none,
  minX: (json['minX'] as num?)?.toDouble(),
  maxX: (json['maxX'] as num?)?.toDouble(),
  minY: (json['minY'] as num?)?.toDouble(),
  maxY: (json['maxY'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DragModelToJson(DragModel instance) => <String, dynamic>{
  'axis': _$DragAxisEnumMap[instance.axis]!,
  'release': _$DragReleaseEnumMap[instance.release]!,
  'directions': instance.directions
      .map((e) => _$DragDirectionEnumMap[e]!)
      .toList(),
  'distanceThreshold': instance.distanceThreshold,
  'verticalThreshold': ?instance.verticalThreshold,
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
  'disabledFollow': instance.disabledFollow,
  'flyOutRotate': instance.flyOutRotate,
  'shareAs': instance.shareAs,
  'restX': instance.restX,
  'restY': instance.restY,
  'track': ?instance.track?.toJson(),
  'reorder': instance.reorder,
  'follow': instance.follow,
  'flyOutDistance': ?instance.flyOutDistance,
  'flyOutCurve': _$MotionCurveEnumMap[instance.flyOutCurve]!,
  'xVariable': instance.xVariable,
  'yVariable': instance.yVariable,
  'physics': ?instance.physics?.toJson(),
  'bounds': _$GestureBoundsEnumMap[instance.bounds]!,
  'minX': ?instance.minX,
  'maxX': ?instance.maxX,
  'minY': ?instance.minY,
  'maxY': ?instance.maxY,
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
  MotionCurve.easeInOutSine: 'easeInOutSine',
  MotionCurve.spring: 'spring',
  MotionCurve.elasticOut: 'elasticOut',
  MotionCurve.bounceOut: 'bounceOut',
  MotionCurve.fastOutSlowIn: 'fastOutSlowIn',
  MotionCurve.easeInOutCubic: 'easeInOutCubic',
  MotionCurve.step: 'step',
};

const _$GestureBoundsEnumMap = {
  GestureBounds.none: 'none',
  GestureBounds.contain: 'contain',
  GestureBounds.cover: 'cover',
};
