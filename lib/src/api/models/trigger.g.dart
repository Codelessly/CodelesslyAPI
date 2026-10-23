// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TriggerModelOmitDefaults(
  TriggerModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.debounceMs, 0)) json.remove('debounceMs');
  if (isJsonDefault(instance.duration, kDefaultHoldDuration))
    json.remove('duration');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerModel _$TriggerModelFromJson(Map json) => TriggerModel(
  type: $enumDecode(_$TriggerTypeEnumMap, json['type']),
  debounceMs: (json['debounceMs'] as num?)?.toInt() ?? 0,
  variable: json['variable'] as String?,
  duration: (json['duration'] as num?)?.toInt() ?? 1200,
);

Map<String, dynamic> _$TriggerModelToJson(TriggerModel instance) =>
    <String, dynamic>{
      'type': _$TriggerTypeEnumMap[instance.type]!,
      'debounceMs': instance.debounceMs,
      'variable': ?instance.variable,
      'duration': instance.duration,
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
  TriggerType.load: 'load',
  TriggerType.valueChanged: 'valueChanged',
  TriggerType.hold: 'hold',
};
