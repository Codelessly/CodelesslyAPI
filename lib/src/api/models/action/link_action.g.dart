// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkAction _$LinkActionFromJson(Map json) => LinkAction(
      url: json['url'] as String,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$LinkActionToJson(LinkAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'url': instance.url,
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
  ActionType.setStorage: 'setStorage',
  ActionType.showDialog: 'showDialog',
};
