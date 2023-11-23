// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_storage_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetStorageAction _$SetStorageActionFromJson(Map json) => SetStorageAction(
      key: json['key'] as String? ?? 'key',
      operation:
          $enumDecodeNullable(_$StorageOperationEnumMap, json['operation']) ??
              StorageOperation.addOrUpdate,
      variableType:
          $enumDecodeNullable(_$VariableTypeEnumMap, json['variableType']) ??
              VariableType.text,
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
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetStorageActionToJson(SetStorageAction instance) {
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

  writeNotNull('newValue', instance.newValue, instance.newValue, '');
  writeNotNull('toggled', instance.toggled, instance.toggled, false);
  writeNotNull('listOperation', instance.listOperation,
      _$ListOperationEnumMap[instance.listOperation]!, ListOperation.replace);
  writeNotNull('index', instance.index, instance.index, '0');
  writeNotNull('mapOperation', instance.mapOperation,
      _$MapOperationEnumMap[instance.mapOperation]!, MapOperation.replace);
  writeNotNull('mapKey', instance.mapKey, instance.mapKey, 'key');
  writeNotNull('key', instance.key, instance.key, 'key');
  writeNotNull(
      'operation',
      instance.operation,
      _$StorageOperationEnumMap[instance.operation]!,
      StorageOperation.addOrUpdate);
  writeNotNull('variableType', instance.variableType,
      _$VariableTypeEnumMap[instance.variableType]!, VariableType.text);
  return val;
}

const _$StorageOperationEnumMap = {
  StorageOperation.remove: 'remove',
  StorageOperation.addOrUpdate: 'addOrUpdate',
  StorageOperation.clear: 'clear',
};

const _$VariableTypeEnumMap = {
  VariableType.integer: 'integer',
  VariableType.text: 'text',
  VariableType.decimal: 'decimal',
  VariableType.boolean: 'boolean',
  VariableType.color: 'color',
  VariableType.list: 'list',
  VariableType.map: 'map',
};

const _$ListOperationEnumMap = {
  ListOperation.replace: 'replace',
  ListOperation.set: 'set',
  ListOperation.add: 'add',
  ListOperation.insert: 'insert',
  ListOperation.removeAt: 'removeAt',
  ListOperation.remove: 'remove',
  ListOperation.update: 'update',
};

const _$MapOperationEnumMap = {
  MapOperation.replace: 'replace',
  MapOperation.add: 'add',
  MapOperation.remove: 'remove',
  MapOperation.update: 'update',
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
};
