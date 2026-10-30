// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effect_animation.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$EffectAnimationOmitDefaults(
  EffectAnimation instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.durationMs, 520)) json.remove('durationMs');
  if (isJsonDefault(instance.delayMs, 0)) json.remove('delayMs');
  if (isJsonDefault(instance.amount, 1)) json.remove('amount');
  if (isJsonDefault(instance.originX, 0)) json.remove('originX');
  if (isJsonDefault(instance.originY, 0)) json.remove('originY');
  if (isJsonDefault(instance.playOnAppear, false)) json.remove('playOnAppear');
  return json;
}

Map<String, dynamic> _$ParticleEmitterOmitDefaults(
  ParticleEmitter instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.count, 40)) json.remove('count');
  if (isJsonDefault(instance.emitMs, 0)) json.remove('emitMs');
  if (isJsonDefault(instance.colors, ParticleEmitter.defaultColors))
    json.remove('colors');
  if (isJsonDefault(instance.shapes, const [
    ParticleShape.square,
    ParticleShape.strip,
    ParticleShape.circle,
  ]))
    json.remove('shapes');
  if (isJsonDefault(instance.size, 10)) json.remove('size');
  if (isJsonDefault(instance.originX, 0)) json.remove('originX');
  if (isJsonDefault(instance.originY, 0)) json.remove('originY');
  if (isJsonDefault(instance.originWidth, 0)) json.remove('originWidth');
  if (isJsonDefault(instance.direction, 0)) json.remove('direction');
  if (isJsonDefault(instance.spread, 60)) json.remove('spread');
  if (isJsonDefault(instance.speed, 700)) json.remove('speed');
  if (isJsonDefault(instance.gravity, 900)) json.remove('gravity');
  if (isJsonDefault(instance.lifetimeMs, 2600)) json.remove('lifetimeMs');
  if (isJsonDefault(instance.playOnAppear, false)) json.remove('playOnAppear');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EffectAnimation _$EffectAnimationFromJson(Map json) => EffectAnimation(
  name: json['name'] as String,
  type: $enumDecode(_$EffectAnimationTypeEnumMap, json['type']),
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 520,
  delayMs: (json['delayMs'] as num?)?.toInt() ?? 0,
  amount: (json['amount'] as num?)?.toDouble() ?? 1,
  originX: (json['originX'] as num?)?.toDouble() ?? 0,
  originY: (json['originY'] as num?)?.toDouble() ?? 0,
  playOnAppear: json['playOnAppear'] as bool? ?? false,
);

Map<String, dynamic> _$EffectAnimationToJson(EffectAnimation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$EffectAnimationTypeEnumMap[instance.type]!,
      'durationMs': instance.durationMs,
      'delayMs': instance.delayMs,
      'amount': instance.amount,
      'originX': instance.originX,
      'originY': instance.originY,
      'playOnAppear': instance.playOnAppear,
    };

const _$EffectAnimationTypeEnumMap = {
  EffectAnimationType.shake: 'shake',
  EffectAnimationType.bounce: 'bounce',
  EffectAnimationType.pop: 'pop',
  EffectAnimationType.wiggle: 'wiggle',
  EffectAnimationType.jelly: 'jelly',
  EffectAnimationType.flash: 'flash',
  EffectAnimationType.spin: 'spin',
};

ParticleEmitter _$ParticleEmitterFromJson(Map json) => ParticleEmitter(
  count: (json['count'] as num?)?.toInt() ?? 40,
  emitMs: (json['emitMs'] as num?)?.toInt() ?? 0,
  colors:
      (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      ParticleEmitter.defaultColors,
  shapes:
      (json['shapes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ParticleShapeEnumMap, e))
          .toList() ??
      const [ParticleShape.square, ParticleShape.strip, ParticleShape.circle],
  size: (json['size'] as num?)?.toDouble() ?? 10,
  originX: (json['originX'] as num?)?.toDouble() ?? 0,
  originY: (json['originY'] as num?)?.toDouble() ?? 0,
  originWidth: (json['originWidth'] as num?)?.toDouble() ?? 0,
  direction: (json['direction'] as num?)?.toDouble() ?? 0,
  spread: (json['spread'] as num?)?.toDouble() ?? 60,
  speed: (json['speed'] as num?)?.toDouble() ?? 700,
  gravity: (json['gravity'] as num?)?.toDouble() ?? 900,
  lifetimeMs: (json['lifetimeMs'] as num?)?.toInt() ?? 2600,
  playOnAppear: json['playOnAppear'] as bool? ?? false,
);

Map<String, dynamic> _$ParticleEmitterToJson(ParticleEmitter instance) =>
    <String, dynamic>{
      'count': instance.count,
      'emitMs': instance.emitMs,
      'colors': instance.colors,
      'shapes': instance.shapes.map((e) => _$ParticleShapeEnumMap[e]!).toList(),
      'size': instance.size,
      'originX': instance.originX,
      'originY': instance.originY,
      'originWidth': instance.originWidth,
      'direction': instance.direction,
      'spread': instance.spread,
      'speed': instance.speed,
      'gravity': instance.gravity,
      'lifetimeMs': instance.lifetimeMs,
      'playOnAppear': instance.playOnAppear,
    };

const _$ParticleShapeEnumMap = {
  ParticleShape.square: 'square',
  ParticleShape.circle: 'circle',
  ParticleShape.strip: 'strip',
  ParticleShape.star: 'star',
};
