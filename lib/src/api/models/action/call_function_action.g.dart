// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_function_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallFunctionAction _$CallFunctionActionFromJson(Map json) => CallFunctionAction(
      name: json['name'] as String,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$CallFunctionActionToJson(CallFunctionAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'name': instance.name,
    };

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.callFunction: 'callFunction',
};
