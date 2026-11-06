// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptic_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$HapticActionOmitDefaults(
  HapticAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.kind, HapticKind.selection)) json.remove('kind');
  if (isJsonDefault(instance.when, '')) json.remove('when');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HapticAction _$HapticActionFromJson(Map json) => HapticAction(
  kind:
      $enumDecodeNullable(_$HapticKindEnumMap, json['kind']) ??
      HapticKind.selection,
  when: json['when'] as String? ?? '',
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$HapticActionToJson(HapticAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'kind': _$HapticKindEnumMap[instance.kind]!,
      'when': instance.when,
    };

const _$HapticKindEnumMap = {
  HapticKind.selection: 'selection',
  HapticKind.light: 'light',
  HapticKind.medium: 'medium',
  HapticKind.heavy: 'heavy',
  HapticKind.vibrate: 'vibrate',
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
  ActionType.paginate: 'paginate',
  ActionType.runScript: 'runScript',
};
