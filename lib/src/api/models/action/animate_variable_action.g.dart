// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animate_variable_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$AnimateVariableActionOmitDefaults(
  AnimateVariableAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.variable, '')) json.remove('variable');
  if (isJsonDefault(instance.mode, AnimateVariableMode.play))
    json.remove('mode');
  if (isJsonDefault(instance.from, '')) json.remove('from');
  if (isJsonDefault(instance.to, '1')) json.remove('to');
  if (isJsonDefault(instance.durationMs, 1000)) json.remove('durationMs');
  if (isJsonDefault(instance.curve, MotionCurve.linear)) json.remove('curve');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimateVariableAction _$AnimateVariableActionFromJson(Map json) =>
    AnimateVariableAction(
      variable: json['variable'] as String? ?? '',
      mode:
          $enumDecodeNullable(
            _$AnimateVariableModeEnumMap,
            json['mode'],
            unknownValue: AnimateVariableMode.play,
          ) ??
          AnimateVariableMode.play,
      from: json['from'] == null ? '' : _jsonText(json['from']),
      to: json['to'] == null ? '1' : _jsonText(json['to']),
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 1000,
      duration: _jsonTextOrNull(json['duration']),
      curve:
          $enumDecodeNullable(
            _$MotionCurveEnumMap,
            json['curve'],
            unknownValue: MotionCurve.linear,
          ) ??
          MotionCurve.linear,
      nonBlocking: json['nonBlocking'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$AnimateVariableActionToJson(
  AnimateVariableAction instance,
) => <String, dynamic>{
  'type': _$ActionTypeEnumMap[instance.type]!,
  'nonBlocking': instance.nonBlocking,
  'enabled': instance.enabled,
  'variable': instance.variable,
  'mode': _$AnimateVariableModeEnumMap[instance.mode]!,
  'from': instance.from,
  'to': instance.to,
  'durationMs': instance.durationMs,
  'duration': ?instance.duration,
  'curve': _$MotionCurveEnumMap[instance.curve]!,
};

const _$AnimateVariableModeEnumMap = {
  AnimateVariableMode.play: 'play',
  AnimateVariableMode.pause: 'pause',
  AnimateVariableMode.resume: 'resume',
  AnimateVariableMode.stop: 'stop',
  AnimateVariableMode.seek: 'seek',
};

const _$MotionCurveEnumMap = {
  MotionCurve.linear: 'linear',
  MotionCurve.easeInOut: 'easeInOut',
  MotionCurve.easeOut: 'easeOut',
  MotionCurve.easeIn: 'easeIn',
  MotionCurve.easeOutBack: 'easeOutBack',
  MotionCurve.easeOutCubic: 'easeOutCubic',
  MotionCurve.easeInOutSine: 'easeInOutSine',
  MotionCurve.spring: 'spring',
  MotionCurve.elasticOut: 'elasticOut',
  MotionCurve.bounceOut: 'bounceOut',
  MotionCurve.fastOutSlowIn: 'fastOutSlowIn',
  MotionCurve.easeInOutCubic: 'easeInOutCubic',
  MotionCurve.step: 'step',
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
  ActionType.editText: 'editText',
  ActionType.paywall: 'paywall',
  ActionType.focus: 'focus',
  ActionType.controlDrag: 'controlDrag',
  ActionType.speak: 'speak',
  ActionType.scrollTo: 'scrollTo',
  ActionType.playSound: 'playSound',
  ActionType.playAnimation: 'playAnimation',
  ActionType.animateVariable: 'animateVariable',
  ActionType.haptic: 'haptic',
  ActionType.runScript: 'runScript',
};
