// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_sound_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PlaySoundActionOmitDefaults(
  PlaySoundAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.sound, 'wood')) json.remove('sound');
  if (isJsonDefault(instance.volume, '1')) json.remove('volume');
  if (isJsonDefault(instance.pitch, '1')) json.remove('pitch');
  if (isJsonDefault(instance.at, '')) json.remove('at');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaySoundAction _$PlaySoundActionFromJson(Map json) => PlaySoundAction(
  sound: json['sound'] as String? ?? 'wood',
  volume: json['volume'] as String? ?? '1',
  pitch: json['pitch'] as String? ?? '1',
  at: json['at'] as String? ?? '',
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$PlaySoundActionToJson(PlaySoundAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'sound': instance.sound,
      'volume': instance.volume,
      'pitch': instance.pitch,
      'at': instance.at,
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
  ActionType.playSound: 'playSound',
};
