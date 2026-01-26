// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_cloud_storage_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetCloudStorageAction _$SetCloudStorageActionFromJson(Map json) =>
    SetCloudStorageAction(
      subAction: SetCloudStorageSubAction.fromJson(json['subAction'] as Map),
      nonBlocking: json['nonBlocking'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetCloudStorageActionToJson(
  SetCloudStorageAction instance,
) => <String, dynamic>{
  'type': _$ActionTypeEnumMap[instance.type]!,
  'nonBlocking': instance.nonBlocking,
  'enabled': instance.enabled,
  'subAction': instance.subAction.toJson(),
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

AddDocumentSubAction _$AddDocumentSubActionFromJson(Map json) =>
    AddDocumentSubAction(
      path: json['path'] as String? ?? '',
      documentId: json['documentId'] as String? ?? '',
      autoGenerateId: json['autoGenerateId'] as bool? ?? false,
      skipCreationIfDocumentExists:
          json['skipCreationIfDocumentExists'] as bool? ?? true,
      newValue: json['newValue'] as String? ?? '',
      rawValue: json['rawValue'] as String? ?? '',
      useRawValue: json['useRawValue'] as bool? ?? false,
    );

Map<String, dynamic> _$AddDocumentSubActionToJson(
  AddDocumentSubAction instance,
) => <String, dynamic>{
  'path': instance.path,
  'documentId': instance.documentId,
  'autoGenerateId': instance.autoGenerateId,
  'skipCreationIfDocumentExists': instance.skipCreationIfDocumentExists,
  'rawValue': instance.rawValue,
  'newValue': instance.newValue,
  'useRawValue': instance.useRawValue,
};

RemoveDocumentSubAction _$RemoveDocumentSubActionFromJson(Map json) =>
    RemoveDocumentSubAction(
      path: json['path'] as String? ?? '',
      documentId: json['documentId'] as String? ?? '',
    );

Map<String, dynamic> _$RemoveDocumentSubActionToJson(
  RemoveDocumentSubAction instance,
) => <String, dynamic>{
  'path': instance.path,
  'documentId': instance.documentId,
};

UpdateDocumentSubAction _$UpdateDocumentSubActionFromJson(Map json) =>
    UpdateDocumentSubAction(
      path: json['path'] as String? ?? '',
      documentId: json['documentId'] as String? ?? '',
      rawValue: json['rawValue'] as String? ?? '',
      key: json['key'] as String? ?? '',
      variableType:
          $enumDecodeNullable(_$VariableTypeEnumMap, json['variableType']) ??
          VariableType.text,
      index: json['index'] as String? ?? '0',
      listOperation:
          $enumDecodeNullable(_$ListOperationEnumMap, json['listOperation']) ??
          ListOperation.replace,
      mapKey: json['mapKey'] as String? ?? 'key',
      mapOperation:
          $enumDecodeNullable(_$MapOperationEnumMap, json['mapOperation']) ??
          MapOperation.replace,
      newValue: json['newValue'] as String? ?? '',
      toggled: json['toggled'] as bool? ?? false,
      useRawValue: json['useRawValue'] as bool? ?? false,
      numberOperation:
          $enumDecodeNullable(
            _$NumberOperationEnumMap,
            json['numberOperation'],
          ) ??
          NumberOperation.set,
    );

Map<String, dynamic> _$UpdateDocumentSubActionToJson(
  UpdateDocumentSubAction instance,
) => <String, dynamic>{
  'path': instance.path,
  'documentId': instance.documentId,
  'rawValue': instance.rawValue,
  'key': instance.key,
  'variableType': _$VariableTypeEnumMap[instance.variableType]!,
  'useRawValue': instance.useRawValue,
  'index': instance.index,
  'listOperation': _$ListOperationEnumMap[instance.listOperation]!,
  'mapKey': instance.mapKey,
  'mapOperation': _$MapOperationEnumMap[instance.mapOperation]!,
  'newValue': instance.newValue,
  'toggled': instance.toggled,
  'numberOperation': _$NumberOperationEnumMap[instance.numberOperation]!,
};

const _$VariableTypeEnumMap = {
  VariableType.integer: 'integer',
  VariableType.text: 'text',
  VariableType.decimal: 'decimal',
  VariableType.boolean: 'boolean',
  VariableType.color: 'color',
  VariableType.list: 'list',
  VariableType.map: 'map',
  VariableType.image: 'image',
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
