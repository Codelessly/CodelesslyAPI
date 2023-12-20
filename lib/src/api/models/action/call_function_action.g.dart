// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_function_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallFunctionAction _$CallFunctionActionFromJson(Map json) => CallFunctionAction(
      name: json['name'] as String,
      params: (json['params'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      nonBlocking: json['nonBlocking'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$CallFunctionActionToJson(CallFunctionAction instance) {
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

  writeNotNull(
      'nonBlocking', instance.nonBlocking, instance.nonBlocking, false);
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  val['name'] = instance.name;
  val['params'] = instance.params;
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
  ActionType.loadFromCloudStorage: 'loadFromCloudStorage',
};
