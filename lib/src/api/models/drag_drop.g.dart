// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drag_drop.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$DraggableModelOmitDefaults(
  DraggableModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.data, '')) json.remove('data');
  if (isJsonDefault(instance.group, '')) json.remove('group');
  if (isJsonDefault(instance.feedbackScale, 1.1)) json.remove('feedbackScale');
  if (isJsonDefault(instance.feedbackRotation, 0))
    json.remove('feedbackRotation');
  if (isJsonDefault(instance.feedbackOpacity, 1))
    json.remove('feedbackOpacity');
  if (isJsonDefault(instance.feedbackShadow, true))
    json.remove('feedbackShadow');
  if (isJsonDefault(instance.whileDragging, DragLeaveBehavior.ghost))
    json.remove('whileDragging');
  if (isJsonDefault(instance.ghostOpacity, 0.3)) json.remove('ghostOpacity');
  if (isJsonDefault(instance.axis, DragAxisLock.free)) json.remove('axis');
  if (isJsonDefault(instance.longPressMs, 0)) json.remove('longPressMs');
  if (isJsonDefault(instance.returnSpring, true)) json.remove('returnSpring');
  if (isJsonDefault(instance.springStiffness, 260))
    json.remove('springStiffness');
  if (isJsonDefault(instance.springDamping, 14)) json.remove('springDamping');
  return json;
}

Map<String, dynamic> _$DropTargetModelOmitDefaults(
  DropTargetModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.groups, const [])) json.remove('groups');
  if (isJsonDefault(instance.acceptIf, '')) json.remove('acceptIf');
  if (isJsonDefault(instance.fullIf, '')) json.remove('fullIf');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraggableModel _$DraggableModelFromJson(Map json) => DraggableModel(
  enabled: json['enabled'] as bool? ?? true,
  data: json['data'] as String? ?? '',
  group: json['group'] as String? ?? '',
  feedbackScale: (json['feedbackScale'] as num?)?.toDouble() ?? 1.1,
  feedbackRotation: (json['feedbackRotation'] as num?)?.toDouble() ?? 0,
  feedbackOpacity: (json['feedbackOpacity'] as num?)?.toDouble() ?? 1,
  feedbackShadow: json['feedbackShadow'] as bool? ?? true,
  whileDragging:
      $enumDecodeNullable(_$DragLeaveBehaviorEnumMap, json['whileDragging']) ??
      DragLeaveBehavior.ghost,
  ghostOpacity: (json['ghostOpacity'] as num?)?.toDouble() ?? 0.3,
  axis:
      $enumDecodeNullable(_$DragAxisLockEnumMap, json['axis']) ??
      DragAxisLock.free,
  longPressMs: (json['longPressMs'] as num?)?.toInt() ?? 0,
  returnSpring: json['returnSpring'] as bool? ?? true,
  springStiffness: (json['springStiffness'] as num?)?.toDouble() ?? 260,
  springDamping: (json['springDamping'] as num?)?.toDouble() ?? 14,
);

Map<String, dynamic> _$DraggableModelToJson(DraggableModel instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'data': instance.data,
      'group': instance.group,
      'feedbackScale': instance.feedbackScale,
      'feedbackRotation': instance.feedbackRotation,
      'feedbackOpacity': instance.feedbackOpacity,
      'feedbackShadow': instance.feedbackShadow,
      'whileDragging': _$DragLeaveBehaviorEnumMap[instance.whileDragging]!,
      'ghostOpacity': instance.ghostOpacity,
      'axis': _$DragAxisLockEnumMap[instance.axis]!,
      'longPressMs': instance.longPressMs,
      'returnSpring': instance.returnSpring,
      'springStiffness': instance.springStiffness,
      'springDamping': instance.springDamping,
    };

const _$DragLeaveBehaviorEnumMap = {
  DragLeaveBehavior.keep: 'keep',
  DragLeaveBehavior.ghost: 'ghost',
  DragLeaveBehavior.hidden: 'hidden',
};

const _$DragAxisLockEnumMap = {
  DragAxisLock.free: 'free',
  DragAxisLock.horizontal: 'horizontal',
  DragAxisLock.vertical: 'vertical',
};

DropTargetModel _$DropTargetModelFromJson(Map json) => DropTargetModel(
  enabled: json['enabled'] as bool? ?? true,
  groups:
      (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  acceptIf: json['acceptIf'] as String? ?? '',
  fullIf: json['fullIf'] as String? ?? '',
);

Map<String, dynamic> _$DropTargetModelToJson(DropTargetModel instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'groups': instance.groups,
      'acceptIf': instance.acceptIf,
      'fullIf': instance.fullIf,
    };
