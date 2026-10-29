// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_call_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ApiCallActionOmitDefaults(
  ApiCallAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.parameters, {})) json.remove('parameters');
  if (isJsonDefault(instance.onSuccess, [])) json.remove('onSuccess');
  if (isJsonDefault(instance.onError, [])) json.remove('onError');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiCallAction _$ApiCallActionFromJson(Map json) => ApiCallAction(
  apiId: json['apiId'] as String?,
  parameters: (json['parameters'] as Map?)?.map(
    (k, e) => MapEntry(k as String, e as String),
  ),
  onSuccess: (json['onSuccess'] as List<dynamic>?)
      ?.map((e) => ActionModel.fromJson(e as Map))
      .toList(),
  onError: (json['onError'] as List<dynamic>?)
      ?.map((e) => ActionModel.fromJson(e as Map))
      .toList(),
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ApiCallActionToJson(ApiCallAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'apiId': ?instance.apiId,
      'parameters': instance.parameters,
      'onSuccess': instance.onSuccess.map((e) => e.toJson()).toList(),
      'onError': instance.onError.map((e) => e.toJson()).toList(),
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
  ActionType.cloudData: 'cloudData',
  ActionType.cloudBatch: 'cloudBatch',
  ActionType.copyToClipboard: 'copyToClipboard',
};
