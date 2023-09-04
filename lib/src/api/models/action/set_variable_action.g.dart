// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_variable_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetVariableAction _$SetVariableActionFromJson(Map json) => SetVariableAction(
      variable: VariableData.fromJson(
          Map<String, dynamic>.from(json['variable'] as Map)),
      newValue: json['newValue'] as String,
      toggled: json['toggled'] as bool? ?? false,
      listOperation:
          $enumDecodeNullable(_$ListOperationEnumMap, json['listOperation']) ??
              ListOperation.replace,
      index: json['index'] as String? ?? '0',
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetVariableActionToJson(SetVariableAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'variable': instance.variable.toJson(),
      'newValue': instance.newValue,
      'toggled': instance.toggled,
      'listOperation': _$ListOperationEnumMap[instance.listOperation]!,
      'index': instance.index,
    };

const _$ListOperationEnumMap = {
  ListOperation.replace: 'replace',
  ListOperation.add: 'add',
  ListOperation.insert: 'insert',
  ListOperation.removeAt: 'removeAt',
  ListOperation.remove: 'remove',
  ListOperation.update: 'update',
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
