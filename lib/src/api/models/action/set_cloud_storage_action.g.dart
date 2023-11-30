// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_cloud_storage_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetCloudStorageAction _$SetCloudStorageActionFromJson(Map json) =>
    SetCloudStorageAction(
      subAction: SetCloudStorageSubAction.fromJson(json['subAction'] as Map),
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetCloudStorageActionToJson(
        SetCloudStorageAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
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
    AddDocumentSubAction instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('path', instance.path, instance.path, '');
  writeNotNull('documentId', instance.documentId, instance.documentId, '');
  writeNotNull('autoGenerateId', instance.autoGenerateId,
      instance.autoGenerateId, false);
  writeNotNull(
      'skipCreationIfDocumentExists',
      instance.skipCreationIfDocumentExists,
      instance.skipCreationIfDocumentExists,
      true);
  writeNotNull('rawValue', instance.rawValue, instance.rawValue, '');
  writeNotNull('newValue', instance.newValue, instance.newValue, '');
  writeNotNull(
      'useRawValue', instance.useRawValue, instance.useRawValue, false);
  return val;
}

RemoveDocumentSubAction _$RemoveDocumentSubActionFromJson(Map json) =>
    RemoveDocumentSubAction(
      path: json['path'] as String? ?? '',
      documentId: json['documentId'] as String? ?? '',
    );

Map<String, dynamic> _$RemoveDocumentSubActionToJson(
    RemoveDocumentSubAction instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('path', instance.path, instance.path, '');
  writeNotNull('documentId', instance.documentId, instance.documentId, '');
  return val;
}

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
      numberOperation: $enumDecodeNullable(
              _$NumberOperationEnumMap, json['numberOperation']) ??
          NumberOperation.set,
    );

Map<String, dynamic> _$UpdateDocumentSubActionToJson(
    UpdateDocumentSubAction instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('path', instance.path, instance.path, '');
  writeNotNull('documentId', instance.documentId, instance.documentId, '');
  writeNotNull('rawValue', instance.rawValue, instance.rawValue, '');
  writeNotNull('key', instance.key, instance.key, '');
  writeNotNull('variableType', instance.variableType,
      _$VariableTypeEnumMap[instance.variableType]!, VariableType.text);
  writeNotNull(
      'useRawValue', instance.useRawValue, instance.useRawValue, false);
  writeNotNull('index', instance.index, instance.index, '0');
  writeNotNull('listOperation', instance.listOperation,
      _$ListOperationEnumMap[instance.listOperation]!, ListOperation.replace);
  writeNotNull('mapKey', instance.mapKey, instance.mapKey, 'key');
  writeNotNull('mapOperation', instance.mapOperation,
      _$MapOperationEnumMap[instance.mapOperation]!, MapOperation.replace);
  writeNotNull('newValue', instance.newValue, instance.newValue, '');
  writeNotNull('toggled', instance.toggled, instance.toggled, false);
  writeNotNull('numberOperation', instance.numberOperation,
      _$NumberOperationEnumMap[instance.numberOperation]!, NumberOperation.set);
  return val;
}

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
