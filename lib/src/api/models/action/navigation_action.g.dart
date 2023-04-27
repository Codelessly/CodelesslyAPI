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
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$NavigationActionToJson(NavigationAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'navigationType': _$NavigationTypeEnumMap[instance.navigationType]!,
      'destinationId': instance.destinationId,
    };

const _$NavigationTypeEnumMap = {
  NavigationType.push: 'push',
  NavigationType.pop: 'pop',
  NavigationType.replace: 'replace',
};

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.callFunction: 'callFunction',
  ActionType.callApi: 'callApi',
};
