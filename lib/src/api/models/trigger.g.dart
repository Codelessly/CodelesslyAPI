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
  if (isJsonDefault(instance.intervalMillis, 1000))
    json.remove('intervalMillis');
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
  duration: (json['duration'] as num?)?.toInt() ?? 1200,
  intervalMillis: (json['intervalMillis'] as num?)?.toInt() ?? 1000,
);

Map<String, dynamic> _$TriggerModelToJson(TriggerModel instance) =>
    <String, dynamic>{
      'type': _$TriggerTypeEnumMap[instance.type]!,
      'debounceMs': instance.debounceMs,
      'variable': ?instance.variable,
      'intervalMs': ?instance.intervalMs,
      'key': ?instance.key,
      'duration': instance.duration,
      'intervalMillis': instance.intervalMillis,
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
  TriggerType.hold: 'hold',
  TriggerType.changeEnd: 'changeEnd',
  TriggerType.interval: 'interval',
  TriggerType.dragEnd: 'dragEnd',
  TriggerType.keyDown: 'keyDown',
  TriggerType.secondaryClick: 'secondaryClick',
  TriggerType.dragStart: 'dragStart',
  TriggerType.dragCancel: 'dragCancel',
  TriggerType.drop: 'drop',
  TriggerType.dragEnter: 'dragEnter',
  TriggerType.dragExit: 'dragExit',
  TriggerType.dragHover: 'dragHover',
};
