// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerModel _$TriggerModelFromJson(Map json) => TriggerModel(
      type: $enumDecode(_$TriggerTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$TriggerModelToJson(TriggerModel instance) =>
    <String, dynamic>{
      'type': _$TriggerTypeEnumMap[instance.type]!,
    };

const _$TriggerTypeEnumMap = {
  TriggerType.click: 'click',
  TriggerType.changed: 'changed',
  TriggerType.editingComplete: 'editingComplete',
  TriggerType.submitted: 'submitted',
  TriggerType.longPress: 'longPress',
  TriggerType.hover: 'hover',
  TriggerType.drag: 'drag',
  TriggerType.cursorEnter: 'cursorEnter',
  TriggerType.cursorExit: 'cursorExit',
  TriggerType.pointerDown: 'pointerDown',
  TriggerType.pointerUp: 'pointerUp',
};
