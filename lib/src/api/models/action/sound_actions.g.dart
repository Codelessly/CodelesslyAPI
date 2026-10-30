// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_actions.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SpeakActionOmitDefaults(
  SpeakAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.text, '')) json.remove('text');
  if (isJsonDefault(instance.rate, 1)) json.remove('rate');
  if (isJsonDefault(instance.pitch, 1)) json.remove('pitch');
  if (isJsonDefault(instance.language, 'en-US')) json.remove('language');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

Map<String, dynamic> _$PlaySoundActionOmitDefaults(
  PlaySoundAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.preset, SoundPreset.pop)) json.remove('preset');
  if (isJsonDefault(instance.url, '')) json.remove('url');
  if (isJsonDefault(instance.volume, 1)) json.remove('volume');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeakAction _$SpeakActionFromJson(Map json) => SpeakAction(
  text: json['text'] as String? ?? '',
  rate: (json['rate'] as num?)?.toDouble() ?? 1,
  rateValue: json['rateValue'] as String?,
  pitch: (json['pitch'] as num?)?.toDouble() ?? 1,
  language: json['language'] as String? ?? 'en-US',
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SpeakActionToJson(SpeakAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'text': instance.text,
      'rate': instance.rate,
      'rateValue': ?instance.rateValue,
      'pitch': instance.pitch,
      'language': instance.language,
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
  ActionType.speak: 'speak',
  ActionType.playSound: 'playSound',
  ActionType.playAnimation: 'playAnimation',
};

PlaySoundAction _$PlaySoundActionFromJson(Map json) => PlaySoundAction(
  preset:
      $enumDecodeNullable(_$SoundPresetEnumMap, json['preset']) ??
      SoundPreset.pop,
  url: json['url'] as String? ?? '',
  volume: (json['volume'] as num?)?.toDouble() ?? 1,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$PlaySoundActionToJson(PlaySoundAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'preset': _$SoundPresetEnumMap[instance.preset]!,
      'url': instance.url,
      'volume': instance.volume,
    };

const _$SoundPresetEnumMap = {
  SoundPreset.pop: 'pop',
  SoundPreset.boing: 'boing',
  SoundPreset.chime: 'chime',
  SoundPreset.fanfare: 'fanfare',
  SoundPreset.tap: 'tap',
  SoundPreset.pick: 'pick',
};
