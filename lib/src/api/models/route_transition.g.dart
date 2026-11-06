// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_transition.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TransitionRevealOmitDefaults(
  TransitionReveal instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.shape, RevealShape.circle)) json.remove('shape');
  if (isJsonDefault(instance.origin, RevealOrigin.tap)) json.remove('origin');
  if (isJsonDefault(instance.x, 0)) json.remove('x');
  if (isJsonDefault(instance.y, 0)) json.remove('y');
  if (isJsonDefault(instance.startRadius, 0)) json.remove('startRadius');
  return json;
}

Map<String, dynamic> _$TransitionSideOmitDefaults(
  TransitionSide instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.motion, MotionModel.none)) json.remove('motion');
  if (isJsonDefault(instance.curve, MotionCurve.fastOutSlowIn))
    json.remove('curve');
  if (isJsonDefault(instance.delayMs, 0)) json.remove('delayMs');
  return json;
}

Map<String, dynamic> _$TransitionSpringOmitDefaults(
  TransitionSpring instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.stiffness, 380)) json.remove('stiffness');
  if (isJsonDefault(instance.damping, 36)) json.remove('damping');
  if (isJsonDefault(instance.mass, 1)) json.remove('mass');
  return json;
}

Map<String, dynamic> _$RouteDismissOmitDefaults(
  RouteDismiss instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.direction, DragDirection.down))
    json.remove('direction');
  if (isJsonDefault(instance.distance, 0.25)) json.remove('distance');
  if (isJsonDefault(instance.velocity, 700)) json.remove('velocity');
  if (isJsonDefault(instance.spring, const TransitionSpring()))
    json.remove('spring');
  return json;
}

Map<String, dynamic> _$RouteTransitionOmitDefaults(
  RouteTransition instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransitionReveal _$TransitionRevealFromJson(Map json) => TransitionReveal(
  shape:
      $enumDecodeNullable(_$RevealShapeEnumMap, json['shape']) ??
      RevealShape.circle,
  origin:
      $enumDecodeNullable(_$RevealOriginEnumMap, json['origin']) ??
      RevealOrigin.tap,
  x: (json['x'] as num?)?.toDouble() ?? 0,
  y: (json['y'] as num?)?.toDouble() ?? 0,
  startRadius: (json['startRadius'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$TransitionRevealToJson(TransitionReveal instance) =>
    <String, dynamic>{
      'shape': _$RevealShapeEnumMap[instance.shape]!,
      'origin': _$RevealOriginEnumMap[instance.origin]!,
      'x': instance.x,
      'y': instance.y,
      'startRadius': instance.startRadius,
    };

const _$RevealShapeEnumMap = {
  RevealShape.circle: 'circle',
  RevealShape.rect: 'rect',
};

const _$RevealOriginEnumMap = {
  RevealOrigin.tap: 'tap',
  RevealOrigin.node: 'node',
  RevealOrigin.center: 'center',
  RevealOrigin.point: 'point',
};

TransitionSide _$TransitionSideFromJson(Map json) => TransitionSide(
  motion: json['motion'] == null
      ? MotionModel.none
      : MotionModel.fromJson(json['motion'] as Map),
  reveal: json['reveal'] == null
      ? null
      : TransitionReveal.fromJson(json['reveal'] as Map),
  curve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['curve']) ??
      MotionCurve.fastOutSlowIn,
  delayMs: (json['delayMs'] as num?)?.toInt() ?? 0,
  durationMs: (json['durationMs'] as num?)?.toInt(),
);

Map<String, dynamic> _$TransitionSideToJson(TransitionSide instance) =>
    <String, dynamic>{
      'motion': instance.motion.toJson(),
      'reveal': ?instance.reveal?.toJson(),
      'curve': _$MotionCurveEnumMap[instance.curve]!,
      'delayMs': instance.delayMs,
      'durationMs': ?instance.durationMs,
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

TransitionSpring _$TransitionSpringFromJson(Map json) => TransitionSpring(
  stiffness: (json['stiffness'] as num?)?.toDouble() ?? 380,
  damping: (json['damping'] as num?)?.toDouble() ?? 36,
  mass: (json['mass'] as num?)?.toDouble() ?? 1,
);

Map<String, dynamic> _$TransitionSpringToJson(TransitionSpring instance) =>
    <String, dynamic>{
      'stiffness': instance.stiffness,
      'damping': instance.damping,
      'mass': instance.mass,
    };

RouteDismiss _$RouteDismissFromJson(Map json) => RouteDismiss(
  direction:
      $enumDecodeNullable(_$DragDirectionEnumMap, json['direction']) ??
      DragDirection.down,
  distance: (json['distance'] as num?)?.toDouble() ?? 0.25,
  velocity: (json['velocity'] as num?)?.toDouble() ?? 700,
  spring: json['spring'] == null
      ? const TransitionSpring()
      : TransitionSpring.fromJson(json['spring'] as Map),
);

Map<String, dynamic> _$RouteDismissToJson(RouteDismiss instance) =>
    <String, dynamic>{
      'direction': _$DragDirectionEnumMap[instance.direction]!,
      'distance': instance.distance,
      'velocity': instance.velocity,
      'spring': instance.spring.toJson(),
    };

const _$DragDirectionEnumMap = {
  DragDirection.left: 'left',
  DragDirection.right: 'right',
  DragDirection.up: 'up',
  DragDirection.down: 'down',
};

RouteTransition _$RouteTransitionFromJson(Map json) => RouteTransition(
  preset: $enumDecodeNullable(_$RouteTransitionPresetEnumMap, json['preset']),
  enter: json['enter'] == null
      ? null
      : TransitionSide.fromJson(json['enter'] as Map),
  exit: json['exit'] == null
      ? null
      : TransitionSide.fromJson(json['exit'] as Map),
  popEnter: json['popEnter'] == null
      ? null
      : TransitionSide.fromJson(json['popEnter'] as Map),
  popExit: json['popExit'] == null
      ? null
      : TransitionSide.fromJson(json['popExit'] as Map),
  durationMs: (json['durationMs'] as num?)?.toInt(),
  reverseDurationMs: (json['reverseDurationMs'] as num?)?.toInt(),
  barrierColor: json['barrierColor'] == null
      ? null
      : ColorRGBA.fromJson(json['barrierColor']),
  opaque: json['opaque'] as bool?,
  swipeBack: $enumDecodeNullable(_$RouteSwipeBackEnumMap, json['swipeBack']),
  dismiss: json['dismiss'] == null
      ? null
      : RouteDismiss.fromJson(json['dismiss'] as Map),
);

Map<String, dynamic> _$RouteTransitionToJson(RouteTransition instance) =>
    <String, dynamic>{
      'preset': ?_$RouteTransitionPresetEnumMap[instance.preset],
      'enter': ?instance.enter?.toJson(),
      'exit': ?instance.exit?.toJson(),
      'popEnter': ?instance.popEnter?.toJson(),
      'popExit': ?instance.popExit?.toJson(),
      'durationMs': ?instance.durationMs,
      'reverseDurationMs': ?instance.reverseDurationMs,
      'barrierColor': ?instance.barrierColor?.toJson(),
      'opaque': ?instance.opaque,
      'swipeBack': ?_$RouteSwipeBackEnumMap[instance.swipeBack],
      'dismiss': ?instance.dismiss?.toJson(),
    };

const _$RouteTransitionPresetEnumMap = {
  RouteTransitionPreset.sharedAxisX: 'sharedAxisX',
  RouteTransitionPreset.sharedAxisY: 'sharedAxisY',
  RouteTransitionPreset.sharedAxisZ: 'sharedAxisZ',
  RouteTransitionPreset.fadeThrough: 'fadeThrough',
  RouteTransitionPreset.iosPush: 'iosPush',
  RouteTransitionPreset.iosModal: 'iosModal',
  RouteTransitionPreset.circularReveal: 'circularReveal',
  RouteTransitionPreset.zoom: 'zoom',
  RouteTransitionPreset.coverVertical: 'coverVertical',
  RouteTransitionPreset.cube: 'cube',
  RouteTransitionPreset.flip: 'flip',
};

const _$RouteSwipeBackEnumMap = {
  RouteSwipeBack.platform: 'platform',
  RouteSwipeBack.always: 'always',
  RouteSwipeBack.never: 'never',
};
