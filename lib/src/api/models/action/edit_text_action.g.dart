// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_text_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$EditTextActionOmitDefaults(
  EditTextAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nodeId, '')) json.remove('nodeId');
  if (isJsonDefault(instance.operation, EditTextOperation.insert))
    json.remove('operation');
  if (isJsonDefault(instance.text, '')) json.remove('text');
  if (isJsonDefault(instance.before, '')) json.remove('before');
  if (isJsonDefault(instance.numbered, false)) json.remove('numbered');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditTextAction _$EditTextActionFromJson(Map json) => EditTextAction(
  nodeId: json['nodeId'] as String? ?? '',
  operation:
      $enumDecodeNullable(_$EditTextOperationEnumMap, json['operation']) ??
      EditTextOperation.insert,
  text: json['text'] as String? ?? '',
  before: json['before'] as String? ?? '',
  after: json['after'] as String?,
  numbered: json['numbered'] as bool? ?? false,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$EditTextActionToJson(EditTextAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'nodeId': instance.nodeId,
      'operation': _$EditTextOperationEnumMap[instance.operation]!,
      'text': instance.text,
      'before': instance.before,
      'after': ?instance.after,
      'numbered': instance.numbered,
    };

const _$EditTextOperationEnumMap = {
  EditTextOperation.wrap: 'wrap',
  EditTextOperation.toggleList: 'toggleList',
  EditTextOperation.insert: 'insert',
  EditTextOperation.replaceWord: 'replaceWord',
  EditTextOperation.setText: 'setText',
  EditTextOperation.clear: 'clear',
  EditTextOperation.focus: 'focus',
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
