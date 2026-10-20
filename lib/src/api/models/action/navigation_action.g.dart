// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$NavigationActionOmitDefaults(
  NavigationAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.navigationType, NavigationType.push))
    json.remove('navigationType');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationAction _$NavigationActionFromJson(Map json) => NavigationAction(
  navigationType:
      $enumDecodeNullable(_$NavigationTypeEnumMap, json['navigationType']) ??
      NavigationType.push,
  destinationId: json['destinationId'] as String,
  params: (json['params'] as Map?)?.map((k, e) => MapEntry(k as String, e)),
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$NavigationActionToJson(NavigationAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'navigationType': _$NavigationTypeEnumMap[instance.navigationType]!,
      'destinationId': instance.destinationId,
      'params': instance.params,
    };

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
  ActionType.auth: 'auth',
  ActionType.conditional: 'conditional',
  ActionType.forEach: 'forEach',
  ActionType.cloudFiles: 'cloudFiles',
  ActionType.showToast: 'showToast',
  ActionType.confirm: 'confirm',
  ActionType.delay: 'delay',
};
