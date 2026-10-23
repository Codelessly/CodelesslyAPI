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
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerModel _$TriggerModelFromJson(Map json) => TriggerModel(
  type: $enumDecode(_$TriggerTypeEnumMap, json['type']),
  debounceMs: (json['debounceMs'] as num?)?.toInt() ?? 0,
  variable: json['variable'] as String?,
  intervalMs: (json['intervalMs'] as num?)?.toInt(),
  key: json['key'] as String?,
);

Map<String, dynamic> _$TriggerModelToJson(TriggerModel instance) =>
    <String, dynamic>{
      'type': _$TriggerTypeEnumMap[instance.type]!,
      'debounceMs': instance.debounceMs,
      'variable': ?instance.variable,
      'intervalMs': ?instance.intervalMs,
      'key': ?instance.key,
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
  TriggerType.timer: 'timer',
  TriggerType.keyPress: 'keyPress',
  TriggerType.swipeLeft: 'swipeLeft',
  TriggerType.swipeRight: 'swipeRight',
  TriggerType.swipeUp: 'swipeUp',
  TriggerType.swipeDown: 'swipeDown',
  TriggerType.doubleTap: 'doubleTap',
  TriggerType.hoverEnter: 'hoverEnter',
  TriggerType.hoverExit: 'hoverExit',
};
