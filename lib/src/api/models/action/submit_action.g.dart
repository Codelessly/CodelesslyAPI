// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitAction _$SubmitActionFromJson(Map json) => SubmitAction(
      service: $enumDecode(_$SubmitActionServiceEnumMap, json['service']),
      primaryTextField: json['primaryTextField'] as String,
      apiKey: json['apiKey'] as String,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SubmitActionToJson(SubmitAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'service': _$SubmitActionServiceEnumMap[instance.service]!,
      'primaryTextField': instance.primaryTextField,
      'apiKey': instance.apiKey,
    };

const _$SubmitActionServiceEnumMap = {
  SubmitActionService.mailchimp: 'mailchimp',
};

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.setVariable: 'setVariable',
  ActionType.callFunction: 'callFunction',
  ActionType.callApi: 'callApi',
};

MailchimpSubmitAction _$MailchimpSubmitActionFromJson(Map json) =>
    MailchimpSubmitAction(
      primaryTextField: json['primaryTextField'] as String,
      apiKey: json['apiKey'] as String,
      dataCenter: json['dataCenter'] as String,
      listID: json['listID'] as String,
      firstNameField: json['firstNameField'] as String? ?? '',
      lastNameField: json['lastNameField'] as String? ?? '',
    )
      ..type = $enumDecode(_$ActionTypeEnumMap, json['type'])
      ..service = $enumDecode(_$SubmitActionServiceEnumMap, json['service']);

Map<String, dynamic> _$MailchimpSubmitActionToJson(
    MailchimpSubmitAction instance) {
  final val = <String, dynamic>{
    'type': _$ActionTypeEnumMap[instance.type]!,
    'service': _$SubmitActionServiceEnumMap[instance.service]!,
    'primaryTextField': instance.primaryTextField,
    'apiKey': instance.apiKey,
    'dataCenter': instance.dataCenter,
    'listID': instance.listID,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'firstNameField', instance.firstNameField, instance.firstNameField, '');
  writeNotNull(
      'lastNameField', instance.lastNameField, instance.lastNameField, '');
  return val;
}
