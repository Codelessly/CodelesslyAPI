// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_call_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiCallAction _$ApiCallActionFromJson(Map json) => ApiCallAction(
      apiId: json['apiId'] as String?,
      parameters: (json['parameters'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ApiCallActionToJson(ApiCallAction instance) {
  final val = <String, dynamic>{
    'type': _$ActionTypeEnumMap[instance.type]!,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('apiId', instance.apiId, instance.apiId, null);
  val['parameters'] = instance.parameters;
  return val;
}

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.showDialog: 'showDialog',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.setVariable: 'setVariable',
  ActionType.callFunction: 'callFunction',
  ActionType.callApi: 'callApi',
  ActionType.setStorage: 'setStorage',
  ActionType.setCloudStorage: 'setCloudStorage',
};
