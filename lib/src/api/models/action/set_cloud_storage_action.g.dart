// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_cloud_storage_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SetCloudStorageActionOmitDefaults(
  SetCloudStorageAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

Map<String, dynamic> _$AddDocumentSubActionOmitDefaults(
  AddDocumentSubAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.path, '')) json.remove('path');
  if (isJsonDefault(instance.documentId, '')) json.remove('documentId');
  if (isJsonDefault(instance.autoGenerateId, false))
    json.remove('autoGenerateId');
  if (isJsonDefault(instance.skipCreationIfDocumentExists, true))
    json.remove('skipCreationIfDocumentExists');
  if (isJsonDefault(instance.rawValue, '')) json.remove('rawValue');
  if (isJsonDefault(instance.newValue, '')) json.remove('newValue');
  if (isJsonDefault(instance.useRawValue, false)) json.remove('useRawValue');
  return json;
}

Map<String, dynamic> _$RemoveDocumentSubActionOmitDefaults(
  RemoveDocumentSubAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.path, '')) json.remove('path');
  if (isJsonDefault(instance.documentId, '')) json.remove('documentId');
  return json;
}

Map<String, dynamic> _$UpdateDocumentSubActionOmitDefaults(
  UpdateDocumentSubAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.path, '')) json.remove('path');
  if (isJsonDefault(instance.documentId, '')) json.remove('documentId');
  if (isJsonDefault(instance.rawValue, '')) json.remove('rawValue');
  if (isJsonDefault(instance.key, '')) json.remove('key');
  if (isJsonDefault(instance.variableType, VariableType.text))
    json.remove('variableType');
  if (isJsonDefault(instance.useRawValue, false)) json.remove('useRawValue');
  if (isJsonDefault(instance.index, '0')) json.remove('index');
  if (isJsonDefault(instance.listOperation, ListOperation.replace))
    json.remove('listOperation');
  if (isJsonDefault(instance.mapKey, 'key')) json.remove('mapKey');
  if (isJsonDefault(instance.mapOperation, MapOperation.replace))
    json.remove('mapOperation');
  if (isJsonDefault(instance.newValue, '')) json.remove('newValue');
  if (isJsonDefault(instance.toggled, false)) json.remove('toggled');
  if (isJsonDefault(instance.numberOperation, NumberOperation.set))
    json.remove('numberOperation');
  return json;
}

Map<String, dynamic> _$RemoveDocumentsSubActionOmitDefaults(
  RemoveDocumentsSubAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.path, '')) json.remove('path');
  if (isJsonDefault(instance.documentIds, '')) json.remove('documentIds');
  if (isJsonDefault(instance.whereFilters, [])) json.remove('whereFilters');
  return json;
}

Map<String, dynamic> _$SetDocumentsSubActionOmitDefaults(
  SetDocumentsSubAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.path, '')) json.remove('path');
  if (isJsonDefault(instance.documents, '')) json.remove('documents');
  if (isJsonDefault(instance.idField, 'id')) json.remove('idField');
  if (isJsonDefault(instance.merge, false)) json.remove('merge');
  if (isJsonDefault(instance.replaceCollection, false))
    json.remove('replaceCollection');
  return json;
}

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
  VariableType.choice: 'choice',
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

RemoveDocumentsSubAction _$RemoveDocumentsSubActionFromJson(Map json) =>
    RemoveDocumentsSubAction(
      path: json['path'] as String? ?? '',
      documentIds: json['documentIds'] as String? ?? '',
      whereFilters:
          (json['whereFilters'] as List<dynamic>?)
              ?.map(
                (e) => WhereQueryFilter.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$RemoveDocumentsSubActionToJson(
  RemoveDocumentsSubAction instance,
) => <String, dynamic>{
  'path': instance.path,
  'documentIds': instance.documentIds,
  'whereFilters': instance.whereFilters.map((e) => e.toJson()).toList(),
};

SetDocumentsSubAction _$SetDocumentsSubActionFromJson(Map json) =>
    SetDocumentsSubAction(
      path: json['path'] as String? ?? '',
      documents: json['documents'] as String? ?? '',
      idField: json['idField'] as String? ?? 'id',
      merge: json['merge'] as bool? ?? false,
      replaceCollection: json['replaceCollection'] as bool? ?? false,
    );

Map<String, dynamic> _$SetDocumentsSubActionToJson(
  SetDocumentsSubAction instance,
) => <String, dynamic>{
  'path': instance.path,
  'documents': instance.documents,
  'idField': instance.idField,
  'merge': instance.merge,
  'replaceCollection': instance.replaceCollection,
};
