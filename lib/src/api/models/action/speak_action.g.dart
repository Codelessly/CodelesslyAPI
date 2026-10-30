// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speak_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SpeakActionOmitDefaults(
  SpeakAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.text, '')) json.remove('text');
  if (isJsonDefault(instance.language, '')) json.remove('language');
  if (isJsonDefault(instance.rate, 1)) json.remove('rate');
  if (isJsonDefault(instance.pitch, 1)) json.remove('pitch');
  if (isJsonDefault(instance.stop, false)) json.remove('stop');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeakAction _$SpeakActionFromJson(Map json) => SpeakAction(
  text: json['text'] as String? ?? '',
  language: json['language'] as String? ?? '',
  rate: (json['rate'] as num?)?.toDouble() ?? 1,
  pitch: (json['pitch'] as num?)?.toDouble() ?? 1,
  stop: json['stop'] as bool? ?? false,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SpeakActionToJson(SpeakAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'text': instance.text,
      'language': instance.language,
      'rate': instance.rate,
      'pitch': instance.pitch,
      'stop': instance.stop,
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
};
