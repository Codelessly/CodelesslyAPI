// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SubmitActionOmitDefaults(
  SubmitAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

Map<String, dynamic> _$MailchimpSubmitActionOmitDefaults(
  MailchimpSubmitAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.firstNameField, '')) json.remove('firstNameField');
  if (isJsonDefault(instance.lastNameField, '')) json.remove('lastNameField');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitAction _$SubmitActionFromJson(Map json) => SubmitAction(
  service: $enumDecode(_$SubmitActionServiceEnumMap, json['service']),
  primaryTextField: json['primaryTextField'] as String,
  apiKey: json['apiKey'] as String,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SubmitActionToJson(SubmitAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'service': _$SubmitActionServiceEnumMap[instance.service]!,
      'primaryTextField': instance.primaryTextField,
      'apiKey': instance.apiKey,
    };

const _$SubmitActionServiceEnumMap = {
  SubmitActionService.mailchimp: 'mailchimp',
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
};

MailchimpSubmitAction _$MailchimpSubmitActionFromJson(Map json) =>
    MailchimpSubmitAction(
        primaryTextField: json['primaryTextField'] as String,
        apiKey: json['apiKey'] as String,
        dataCenter: json['dataCenter'] as String,
        listID: json['listID'] as String,
        firstNameField: json['firstNameField'] as String? ?? '',
        lastNameField: json['lastNameField'] as String? ?? '',
        nonBlocking: json['nonBlocking'] as bool? ?? false,
      )
      ..type = $enumDecode(_$ActionTypeEnumMap, json['type'])
      ..enabled = json['enabled'] as bool
      ..service = $enumDecode(_$SubmitActionServiceEnumMap, json['service']);

Map<String, dynamic> _$MailchimpSubmitActionToJson(
  MailchimpSubmitAction instance,
) => <String, dynamic>{
  'type': _$ActionTypeEnumMap[instance.type]!,
  'nonBlocking': instance.nonBlocking,
  'enabled': instance.enabled,
  'service': _$SubmitActionServiceEnumMap[instance.service]!,
  'primaryTextField': instance.primaryTextField,
  'apiKey': instance.apiKey,
  'dataCenter': instance.dataCenter,
  'listID': instance.listID,
  'firstNameField': instance.firstNameField,
  'lastNameField': instance.lastNameField,
};
