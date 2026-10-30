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
  if (isJsonDefault(instance.destinationId, null)) json.remove('destinationId');
  if (isJsonDefault(instance.transition, PageTransition.platform))
    json.remove('transition');
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
  destinationId: _readDestinationId(json, 'destinationId') as String? ?? '',
  params: (json['params'] as Map?)?.map((k, e) => MapEntry(k as String, e)),
  baseDestinationId: json['baseDestinationId'] as String?,
  baseParams: (json['baseParams'] as Map?)?.map(
    (k, e) => MapEntry(k as String, e),
  ),
  transition:
      $enumDecodeNullable(_$PageTransitionEnumMap, json['transition']) ??
      PageTransition.platform,
  transitionMs: (json['transitionMs'] as num?)?.toInt(),
  reverseTransitionMs: (json['reverseTransitionMs'] as num?)?.toInt(),
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
      'baseDestinationId': ?instance.baseDestinationId,
      'baseParams': ?instance.baseParams,
      'transition': _$PageTransitionEnumMap[instance.transition]!,
      'transitionMs': ?instance.transitionMs,
      'reverseTransitionMs': ?instance.reverseTransitionMs,
    };

const _$NavigationTypeEnumMap = {
  NavigationType.push: 'push',
  NavigationType.pop: 'pop',
  NavigationType.replace: 'replace',
  NavigationType.reset: 'reset',
};

const _$PageTransitionEnumMap = {
  PageTransition.platform: 'platform',
  PageTransition.none: 'none',
  PageTransition.fade: 'fade',
  PageTransition.fadeUp: 'fadeUp',
  PageTransition.slideUp: 'slideUp',
  PageTransition.slideLeft: 'slideLeft',
  PageTransition.scale: 'scale',
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
};
