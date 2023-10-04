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

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'firstNameField', instance.firstNameField, instance.firstNameField, '');
  writeNotNull(
      'lastNameField', instance.lastNameField, instance.lastNameField, '');
  return val;
}
