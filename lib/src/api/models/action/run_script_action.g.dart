// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_script_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$RunScriptActionOmitDefaults(
  RunScriptAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.arguments, {})) json.remove('arguments');
  if (isJsonDefault(instance.onError, [])) json.remove('onError');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunScriptAction _$RunScriptActionFromJson(Map json) => RunScriptAction(
  scriptId: json['scriptId'] as String,
  arguments: (json['arguments'] as Map?)?.map(
    (k, e) => MapEntry(k as String, e as String),
  ),
  resultVariable: json['resultVariable'] as String?,
  onError: (json['onError'] as List<dynamic>?)
      ?.map((e) => ActionModel.fromJson(e as Map))
      .toList(),
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$RunScriptActionToJson(RunScriptAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'scriptId': instance.scriptId,
      'arguments': instance.arguments,
      'resultVariable': ?instance.resultVariable,
      'onError': instance.onError.map((e) => e.toJson()).toList(),
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
