// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'copy_to_clipboard_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$CopyToClipboardActionOmitDefaults(
  CopyToClipboardAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.text, '')) json.remove('text');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CopyToClipboardAction _$CopyToClipboardActionFromJson(Map json) =>
    CopyToClipboardAction(
      text: json['text'] as String? ?? '',
      nonBlocking: json['nonBlocking'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$CopyToClipboardActionToJson(
  CopyToClipboardAction instance,
) => <String, dynamic>{
  'type': _$ActionTypeEnumMap[instance.type]!,
  'nonBlocking': instance.nonBlocking,
  'enabled': instance.enabled,
  'text': instance.text,
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
};
