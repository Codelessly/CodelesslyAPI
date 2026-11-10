// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physics.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SnapPointOmitDefaults(
  SnapPoint instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.x, 0)) json.remove('x');
  if (isJsonDefault(instance.y, 0)) json.remove('y');
  return json;
}

Map<String, dynamic> _$SnapModelOmitDefaults(
  SnapModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.kind, SnapKind.points)) json.remove('kind');
  if (isJsonDefault(instance.points, const [])) json.remove('points');
  if (isJsonDefault(instance.gridX, 0)) json.remove('gridX');
  if (isJsonDefault(instance.gridY, 0)) json.remove('gridY');
  if (isJsonDefault(instance.projectVelocity, true))
    json.remove('projectVelocity');
  return json;
}

Map<String, dynamic> _$PhysicsModelOmitDefaults(
  PhysicsModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.stiffness, 380)) json.remove('stiffness');
  if (isJsonDefault(instance.damping, 32)) json.remove('damping');
  if (isJsonDefault(instance.mass, 1)) json.remove('mass');
  if (isJsonDefault(instance.fling, true)) json.remove('fling');
  if (isJsonDefault(instance.friction, 0.865)) json.remove('friction');
  if (isJsonDefault(instance.minFlingVelocity, 50))
    json.remove('minFlingVelocity');
  if (isJsonDefault(instance.maxFlingVelocity, 8000))
    json.remove('maxFlingVelocity');
  if (isJsonDefault(instance.overscroll, 0.5)) json.remove('overscroll');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnapPoint _$SnapPointFromJson(Map json) => SnapPoint(
  x: (json['x'] as num?)?.toDouble() ?? 0,
  y: (json['y'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$SnapPointToJson(SnapPoint instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
};

SnapModel _$SnapModelFromJson(Map json) => SnapModel(
  kind:
      $enumDecodeNullable(
        _$SnapKindEnumMap,
        json['kind'],
        unknownValue: SnapKind.points,
      ) ??
      SnapKind.points,
  points: json['points'] == null
      ? const []
      : SnapModel._pointsFromJson(json['points']),
  gridX: (json['gridX'] as num?)?.toDouble() ?? 0,
  gridY: (json['gridY'] as num?)?.toDouble() ?? 0,
  projectVelocity: json['projectVelocity'] as bool? ?? true,
);

Map<String, dynamic> _$SnapModelToJson(SnapModel instance) => <String, dynamic>{
  'kind': _$SnapKindEnumMap[instance.kind]!,
  'points': instance.points.map((e) => e.toJson()).toList(),
  'gridX': instance.gridX,
  'gridY': instance.gridY,
  'projectVelocity': instance.projectVelocity,
};

const _$SnapKindEnumMap = {
  SnapKind.points: 'points',
  SnapKind.grid: 'grid',
  SnapKind.edges: 'edges',
};

PhysicsModel _$PhysicsModelFromJson(Map json) => PhysicsModel(
  stiffness: (json['stiffness'] as num?)?.toDouble() ?? 380,
  damping: (json['damping'] as num?)?.toDouble() ?? 32,
  mass: (json['mass'] as num?)?.toDouble() ?? 1,
  bounce: (json['bounce'] as num?)?.toDouble(),
  durationMs: (json['durationMs'] as num?)?.toInt(),
  fling: json['fling'] as bool? ?? true,
  friction: (json['friction'] as num?)?.toDouble() ?? 0.865,
  minFlingVelocity: (json['minFlingVelocity'] as num?)?.toDouble() ?? 50,
  maxFlingVelocity: (json['maxFlingVelocity'] as num?)?.toDouble() ?? 8000,
  overscroll: (json['overscroll'] as num?)?.toDouble() ?? 0.5,
  snap: json['snap'] == null ? null : SnapModel.fromJson(json['snap'] as Map),
);

Map<String, dynamic> _$PhysicsModelToJson(PhysicsModel instance) =>
    <String, dynamic>{
      'stiffness': instance.stiffness,
      'damping': instance.damping,
      'mass': instance.mass,
      'bounce': ?instance.bounce,
      'durationMs': ?instance.durationMs,
      'fling': instance.fling,
      'friction': instance.friction,
      'minFlingVelocity': instance.minFlingVelocity,
      'maxFlingVelocity': instance.maxFlingVelocity,
      'overscroll': instance.overscroll,
      'snap': ?instance.snap?.toJson(),
    };
