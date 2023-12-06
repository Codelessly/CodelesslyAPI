// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationAction _$NavigationActionFromJson(Map json) => NavigationAction(
      navigationType: $enumDecodeNullable(
              _$NavigationTypeEnumMap, json['navigationType']) ??
          NavigationType.push,
      destinationId: json['destinationId'] as String,
      params: (json['params'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      nonBlocking: json['nonBlocking'] as bool? ?? false,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$NavigationActionToJson(NavigationAction instance) {
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
  writeNotNull('navigationType', instance.navigationType,
      _$NavigationTypeEnumMap[instance.navigationType]!, NavigationType.push);
  val['destinationId'] = instance.destinationId;
  val['params'] = instance.params;
  return val;
}

const _$NavigationTypeEnumMap = {
  NavigationType.push: 'push',
  NavigationType.pop: 'pop',
  NavigationType.replace: 'replace',
};

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
