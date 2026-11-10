// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transform_gesture.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TransformHandlesModelOmitDefaults(
  TransformHandlesModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.corners, true)) json.remove('corners');
  if (isJsonDefault(instance.edges, false)) json.remove('edges');
  if (isJsonDefault(instance.rotateKnob, true)) json.remove('rotateKnob');
  if (isJsonDefault(instance.snapAngle, 0)) json.remove('snapAngle');
  if (isJsonDefault(instance.aspectLock, true)) json.remove('aspectLock');
  if (isJsonDefault(instance.minWidth, 16)) json.remove('minWidth');
  if (isJsonDefault(instance.minHeight, 16)) json.remove('minHeight');
  if (isJsonDefault(instance.maxWidth, 0)) json.remove('maxWidth');
  if (isJsonDefault(instance.maxHeight, 0)) json.remove('maxHeight');
  if (isJsonDefault(instance.outline, true)) json.remove('outline');
  if (isJsonDefault(instance.color, '#2F80ED')) json.remove('color');
  if (isJsonDefault(instance.handleSize, 12)) json.remove('handleSize');
  if (isJsonDefault(instance.selectionVariable, ''))
    json.remove('selectionVariable');
  if (isJsonDefault(instance.selectionKey, '')) json.remove('selectionKey');
  return json;
}

Map<String, dynamic> _$TransformGestureModelOmitDefaults(
  TransformGestureModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.target, TransformTarget.node))
    json.remove('target');
  if (isJsonDefault(instance.pan, TransformPan.always)) json.remove('pan');
  if (isJsonDefault(instance.zoom, true)) json.remove('zoom');
  if (isJsonDefault(instance.rotate, false)) json.remove('rotate');
  if (isJsonDefault(instance.minScale, 1)) json.remove('minScale');
  if (isJsonDefault(instance.maxScale, 4)) json.remove('maxScale');
  if (isJsonDefault(instance.bounds, GestureBounds.cover))
    json.remove('bounds');
  if (isJsonDefault(instance.doubleTapScale, 2.5))
    json.remove('doubleTapScale');
  if (isJsonDefault(instance.wheel, WheelZoom.ctrlZoom)) json.remove('wheel');
  if (isJsonDefault(instance.rotationSnap, 0)) json.remove('rotationSnap');
  if (isJsonDefault(instance.xVariable, '')) json.remove('xVariable');
  if (isJsonDefault(instance.yVariable, '')) json.remove('yVariable');
  if (isJsonDefault(instance.scaleVariable, '')) json.remove('scaleVariable');
  if (isJsonDefault(instance.rotationVariable, ''))
    json.remove('rotationVariable');
  if (isJsonDefault(instance.scaleXVariable, '')) json.remove('scaleXVariable');
  if (isJsonDefault(instance.scaleYVariable, '')) json.remove('scaleYVariable');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransformHandlesModel _$TransformHandlesModelFromJson(Map json) =>
    TransformHandlesModel(
      corners: json['corners'] as bool? ?? true,
      edges: json['edges'] as bool? ?? false,
      rotateKnob: json['rotateKnob'] as bool? ?? true,
      snapAngle: (json['snapAngle'] as num?)?.toDouble() ?? 0,
      aspectLock: json['aspectLock'] as bool? ?? true,
      minWidth: (json['minWidth'] as num?)?.toDouble() ?? 16,
      minHeight: (json['minHeight'] as num?)?.toDouble() ?? 16,
      maxWidth: (json['maxWidth'] as num?)?.toDouble() ?? 0,
      maxHeight: (json['maxHeight'] as num?)?.toDouble() ?? 0,
      outline: json['outline'] as bool? ?? true,
      color: json['color'] as String? ?? '#2F80ED',
      handleSize: (json['handleSize'] as num?)?.toDouble() ?? 12,
      selectionVariable: json['selectionVariable'] as String? ?? '',
      selectionKey: json['selectionKey'] as String? ?? '',
    );

Map<String, dynamic> _$TransformHandlesModelToJson(
  TransformHandlesModel instance,
) => <String, dynamic>{
  'corners': instance.corners,
  'edges': instance.edges,
  'rotateKnob': instance.rotateKnob,
  'snapAngle': instance.snapAngle,
  'aspectLock': instance.aspectLock,
  'minWidth': instance.minWidth,
  'minHeight': instance.minHeight,
  'maxWidth': instance.maxWidth,
  'maxHeight': instance.maxHeight,
  'outline': instance.outline,
  'color': instance.color,
  'handleSize': instance.handleSize,
  'selectionVariable': instance.selectionVariable,
  'selectionKey': instance.selectionKey,
};

TransformGestureModel _$TransformGestureModelFromJson(Map json) =>
    TransformGestureModel(
      enabled: json['enabled'] as bool? ?? true,
      target:
          $enumDecodeNullable(
            _$TransformTargetEnumMap,
            json['target'],
            unknownValue: TransformTarget.node,
          ) ??
          TransformTarget.node,
      pan:
          $enumDecodeNullable(
            _$TransformPanEnumMap,
            json['pan'],
            unknownValue: TransformPan.always,
          ) ??
          TransformPan.always,
      zoom: json['zoom'] as bool? ?? true,
      rotate: json['rotate'] as bool? ?? false,
      minScale: (json['minScale'] as num?)?.toDouble() ?? 1,
      maxScale: (json['maxScale'] as num?)?.toDouble() ?? 4,
      bounds:
          $enumDecodeNullable(
            _$GestureBoundsEnumMap,
            json['bounds'],
            unknownValue: GestureBounds.cover,
          ) ??
          GestureBounds.cover,
      doubleTapScale: (json['doubleTapScale'] as num?)?.toDouble() ?? 2.5,
      wheel:
          $enumDecodeNullable(
            _$WheelZoomEnumMap,
            json['wheel'],
            unknownValue: WheelZoom.ctrlZoom,
          ) ??
          WheelZoom.ctrlZoom,
      rotationSnap: (json['rotationSnap'] as num?)?.toDouble() ?? 0,
      physics: json['physics'] == null
          ? null
          : PhysicsModel.fromJson(json['physics'] as Map),
      xVariable: json['xVariable'] as String? ?? '',
      yVariable: json['yVariable'] as String? ?? '',
      scaleVariable: json['scaleVariable'] as String? ?? '',
      rotationVariable: json['rotationVariable'] as String? ?? '',
      scaleXVariable: json['scaleXVariable'] as String? ?? '',
      scaleYVariable: json['scaleYVariable'] as String? ?? '',
      handles: json['handles'] == null
          ? null
          : TransformHandlesModel.fromJson(json['handles'] as Map),
    );

Map<String, dynamic> _$TransformGestureModelToJson(
  TransformGestureModel instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'target': _$TransformTargetEnumMap[instance.target]!,
  'pan': _$TransformPanEnumMap[instance.pan]!,
  'zoom': instance.zoom,
  'rotate': instance.rotate,
  'minScale': instance.minScale,
  'maxScale': instance.maxScale,
  'bounds': _$GestureBoundsEnumMap[instance.bounds]!,
  'doubleTapScale': instance.doubleTapScale,
  'wheel': _$WheelZoomEnumMap[instance.wheel]!,
  'rotationSnap': instance.rotationSnap,
  'physics': ?instance.physics?.toJson(),
  'xVariable': instance.xVariable,
  'yVariable': instance.yVariable,
  'scaleVariable': instance.scaleVariable,
  'rotationVariable': instance.rotationVariable,
  'scaleXVariable': instance.scaleXVariable,
  'scaleYVariable': instance.scaleYVariable,
  'handles': ?instance.handles?.toJson(),
};

const _$TransformTargetEnumMap = {
  TransformTarget.node: 'node',
  TransformTarget.content: 'content',
};

const _$TransformPanEnumMap = {
  TransformPan.always: 'always',
  TransformPan.whenZoomed: 'whenZoomed',
  TransformPan.never: 'never',
};

const _$GestureBoundsEnumMap = {
  GestureBounds.none: 'none',
  GestureBounds.contain: 'contain',
  GestureBounds.cover: 'cover',
};

const _$WheelZoomEnumMap = {
  WheelZoom.none: 'none',
  WheelZoom.ctrlZoom: 'ctrlZoom',
  WheelZoom.zoom: 'zoom',
  WheelZoom.pan: 'pan',
};
