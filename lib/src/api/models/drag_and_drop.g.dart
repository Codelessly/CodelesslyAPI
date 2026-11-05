// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drag_and_drop.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$DraggableModelOmitDefaults(
  DraggableModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.group, '')) json.remove('group');
  if (isJsonDefault(instance.data, '')) json.remove('data');
  if (isJsonDefault(instance.start, DragStart.auto)) json.remove('start');
  if (isJsonDefault(instance.axis, DragAxis.free)) json.remove('axis');
  if (isJsonDefault(instance.whileDragging, DragSourceStyle.ghost))
    json.remove('whileDragging');
  if (isJsonDefault(instance.ghostOpacity, 0.35)) json.remove('ghostOpacity');
  if (isJsonDefault(instance.feedbackRotation, -2))
    json.remove('feedbackRotation');
  if (isJsonDefault(instance.feedbackScale, 1)) json.remove('feedbackScale');
  if (isJsonDefault(instance.feedbackOpacity, 1))
    json.remove('feedbackOpacity');
  if (isJsonDefault(instance.feedbackElevation, 24))
    json.remove('feedbackElevation');
  if (isJsonDefault(instance.feedbackNodeId, '')) json.remove('feedbackNodeId');
  if (isJsonDefault(instance.returnSpring, true)) json.remove('returnSpring');
  if (isJsonDefault(instance.springStiffness, 260))
    json.remove('springStiffness');
  if (isJsonDefault(instance.springDamping, 14)) json.remove('springDamping');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

Map<String, dynamic> _$DropTargetModelOmitDefaults(
  DropTargetModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.accepts, const [])) json.remove('accepts');
  if (isJsonDefault(instance.key, '')) json.remove('key');
  if (isJsonDefault(instance.acceptIf, '')) json.remove('acceptIf');
  if (isJsonDefault(instance.listNodeId, '')) json.remove('listNodeId');
  if (isJsonDefault(instance.slot, DropSlot.gap)) json.remove('slot');
  if (isJsonDefault(instance.slotNodeId, '')) json.remove('slotNodeId');
  if (isJsonDefault(instance.slotExtent, 0)) json.remove('slotExtent');
  if (isJsonDefault(instance.hoverDelayMs, 0)) json.remove('hoverDelayMs');
  if (isJsonDefault(instance.fullIf, '')) json.remove('fullIf');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraggableModel _$DraggableModelFromJson(Map json) => DraggableModel(
  group: json['group'] as String? ?? '',
  data: json['data'] as String? ?? '',
  start:
      $enumDecodeNullable(
        _$DragStartEnumMap,
        json['start'],
        unknownValue: DragStart.auto,
      ) ??
      DragStart.auto,
  axis:
      $enumDecodeNullable(
        _$DragAxisEnumMap,
        json['axis'],
        unknownValue: DragAxis.free,
      ) ??
      DragAxis.free,
  whileDragging:
      $enumDecodeNullable(
        _$DragSourceStyleEnumMap,
        json['whileDragging'],
        unknownValue: DragSourceStyle.ghost,
      ) ??
      DragSourceStyle.ghost,
  ghostOpacity: (json['ghostOpacity'] as num?)?.toDouble() ?? 0.35,
  feedbackRotation: (json['feedbackRotation'] as num?)?.toDouble() ?? -2,
  feedbackScale: (json['feedbackScale'] as num?)?.toDouble() ?? 1,
  feedbackOpacity: (json['feedbackOpacity'] as num?)?.toDouble() ?? 1,
  feedbackElevation: (json['feedbackElevation'] as num?)?.toDouble() ?? 24,
  feedbackNodeId: json['feedbackNodeId'] as String? ?? '',
  returnSpring: json['returnSpring'] as bool? ?? true,
  springStiffness: (json['springStiffness'] as num?)?.toDouble() ?? 260,
  springDamping: (json['springDamping'] as num?)?.toDouble() ?? 14,
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$DraggableModelToJson(DraggableModel instance) =>
    <String, dynamic>{
      'group': instance.group,
      'data': instance.data,
      'start': _$DragStartEnumMap[instance.start]!,
      'axis': _$DragAxisEnumMap[instance.axis]!,
      'whileDragging': _$DragSourceStyleEnumMap[instance.whileDragging]!,
      'ghostOpacity': instance.ghostOpacity,
      'feedbackRotation': instance.feedbackRotation,
      'feedbackScale': instance.feedbackScale,
      'feedbackOpacity': instance.feedbackOpacity,
      'feedbackElevation': instance.feedbackElevation,
      'feedbackNodeId': instance.feedbackNodeId,
      'returnSpring': instance.returnSpring,
      'springStiffness': instance.springStiffness,
      'springDamping': instance.springDamping,
      'enabled': instance.enabled,
    };

const _$DragStartEnumMap = {
  DragStart.press: 'press',
  DragStart.longPress: 'longPress',
  DragStart.auto: 'auto',
};

const _$DragAxisEnumMap = {
  DragAxis.free: 'free',
  DragAxis.horizontal: 'horizontal',
  DragAxis.vertical: 'vertical',
};

const _$DragSourceStyleEnumMap = {
  DragSourceStyle.ghost: 'ghost',
  DragSourceStyle.hidden: 'hidden',
  DragSourceStyle.keep: 'keep',
};

DropTargetModel _$DropTargetModelFromJson(Map json) => DropTargetModel(
  accepts:
      (json['accepts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  key: json['key'] as String? ?? '',
  acceptIf: json['acceptIf'] as String? ?? '',
  listNodeId: json['listNodeId'] as String? ?? '',
  slot:
      $enumDecodeNullable(
        _$DropSlotEnumMap,
        json['slot'],
        unknownValue: DropSlot.gap,
      ) ??
      DropSlot.gap,
  slotNodeId: json['slotNodeId'] as String? ?? '',
  slotExtent: (json['slotExtent'] as num?)?.toDouble() ?? 0,
  hoverDelayMs: (json['hoverDelayMs'] as num?)?.toInt() ?? 0,
  fullIf: json['fullIf'] as String? ?? '',
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$DropTargetModelToJson(DropTargetModel instance) =>
    <String, dynamic>{
      'accepts': instance.accepts,
      'key': instance.key,
      'acceptIf': instance.acceptIf,
      'listNodeId': instance.listNodeId,
      'slot': _$DropSlotEnumMap[instance.slot]!,
      'slotNodeId': instance.slotNodeId,
      'slotExtent': instance.slotExtent,
      'hoverDelayMs': instance.hoverDelayMs,
      'fullIf': instance.fullIf,
      'enabled': instance.enabled,
    };

const _$DropSlotEnumMap = {
  DropSlot.none: 'none',
  DropSlot.gap: 'gap',
  DropSlot.node: 'node',
};
