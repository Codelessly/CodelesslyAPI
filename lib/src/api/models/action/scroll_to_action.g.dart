// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scroll_to_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ScrollToActionOmitDefaults(
  ScrollToAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nodeId, '')) json.remove('nodeId');
  if (isJsonDefault(instance.durationMs, 400)) json.remove('durationMs');
  if (isJsonDefault(instance.curve, MotionCurve.easeInOut))
    json.remove('curve');
  if (isJsonDefault(instance.alignment, 0)) json.remove('alignment');
  if (isJsonDefault(instance.offset, 0)) json.remove('offset');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScrollToAction _$ScrollToActionFromJson(Map json) => ScrollToAction(
  nodeId: json['nodeId'] as String? ?? '',
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 400,
  curve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['curve']) ??
      MotionCurve.easeInOut,
  alignment: (json['alignment'] as num?)?.toDouble() ?? 0,
  offset: (json['offset'] as num?)?.toDouble() ?? 0,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ScrollToActionToJson(ScrollToAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'nodeId': instance.nodeId,
      'durationMs': instance.durationMs,
      'curve': _$MotionCurveEnumMap[instance.curve]!,
      'alignment': instance.alignment,
      'offset': instance.offset,
    };

const _$MotionCurveEnumMap = {
  MotionCurve.linear: 'linear',
  MotionCurve.easeInOut: 'easeInOut',
  MotionCurve.easeOut: 'easeOut',
  MotionCurve.easeIn: 'easeIn',
  MotionCurve.easeOutBack: 'easeOutBack',
  MotionCurve.easeOutCubic: 'easeOutCubic',
  MotionCurve.spring: 'spring',
  MotionCurve.elasticOut: 'elasticOut',
  MotionCurve.bounceOut: 'bounceOut',
  MotionCurve.fastOutSlowIn: 'fastOutSlowIn',
};

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.showDialog: 'showDialog',
  ActionType.closeModal: 'closeModal',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.setVariable: 'setVariable',
  ActionType.callFunction: 'callFunction',
  ActionType.callApi: 'callApi',
  ActionType.setStorage: 'setStorage',
  ActionType.setCloudStorage: 'setCloudStorage',
  ActionType.loadFromCloudStorage: 'loadFromCloudStorage',
  ActionType.auth: 'auth',
  ActionType.conditional: 'conditional',
  ActionType.forEach: 'forEach',
  ActionType.cloudFiles: 'cloudFiles',
  ActionType.showToast: 'showToast',
  ActionType.confirm: 'confirm',
  ActionType.delay: 'delay',
  ActionType.cloudData: 'cloudData',
  ActionType.cloudBatch: 'cloudBatch',
  ActionType.copyToClipboard: 'copyToClipboard',
  ActionType.paywall: 'paywall',
  ActionType.controlDrag: 'controlDrag',
  ActionType.speak: 'speak',
  ActionType.focusField: 'focusField',
  ActionType.scrollTo: 'scrollTo',
};
