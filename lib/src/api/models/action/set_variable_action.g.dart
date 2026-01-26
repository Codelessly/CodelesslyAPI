// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_variable_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetVariableAction _$SetVariableActionFromJson(Map json) => SetVariableAction(
  variable: VariableData.fromJson(
    Map<String, dynamic>.from(json['variable'] as Map),
  ),
  newValue: json['newValue'] as String? ?? '',
  toggled: json['toggled'] as bool? ?? false,
  listOperation:
      $enumDecodeNullable(_$ListOperationEnumMap, json['listOperation']) ??
      ListOperation.replace,
  index: json['index'] as String? ?? '0',
  mapOperation:
      $enumDecodeNullable(_$MapOperationEnumMap, json['mapOperation']) ??
      MapOperation.replace,
  mapKey: json['mapKey'] as String? ?? 'key',
  numberOperation:
      $enumDecodeNullable(_$NumberOperationEnumMap, json['numberOperation']) ??
      NumberOperation.set,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetVariableActionToJson(SetVariableAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'variable': instance.variable.toJson(),
      'index': instance.index,
      'listOperation': _$ListOperationEnumMap[instance.listOperation]!,
      'mapKey': instance.mapKey,
      'mapOperation': _$MapOperationEnumMap[instance.mapOperation]!,
      'newValue': instance.newValue,
      'toggled': instance.toggled,
      'numberOperation': _$NumberOperationEnumMap[instance.numberOperation]!,
    };

const _$ListOperationEnumMap = {
  ListOperation.replace: 'replace',
  ListOperation.set: 'set',
  ListOperation.add: 'add',
  ListOperation.insert: 'insert',
  ListOperation.insertAll: 'insertAll',
  ListOperation.removeAt: 'removeAt',
  ListOperation.remove: 'remove',
  ListOperation.update: 'update',
};

const _$MapOperationEnumMap = {
  MapOperation.replace: 'replace',
  MapOperation.add: 'add',
  MapOperation.remove: 'remove',
  MapOperation.update: 'update',
  MapOperation.set: 'set',
};

const _$NumberOperationEnumMap = {
  NumberOperation.set: 'set',
  NumberOperation.add: 'add',
  NumberOperation.subtract: 'subtract',
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
