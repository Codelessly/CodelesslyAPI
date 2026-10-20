// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_from_cloud_storage_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$LoadFromCloudStorageActionOmitDefaults(
  LoadFromCloudStorageAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.path, '')) json.remove('path');
  if (isJsonDefault(instance.documentId, '')) json.remove('documentId');
  if (isJsonDefault(instance.loadSingleDocument, true))
    json.remove('loadSingleDocument');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.useCloudDatabase, true))
    json.remove('useCloudDatabase');
  if (isJsonDefault(instance.whereFilters, [])) json.remove('whereFilters');
  if (isJsonDefault(instance.orderByFilters, [])) json.remove('orderByFilters');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoadFromCloudStorageAction _$LoadFromCloudStorageActionFromJson(Map json) =>
    LoadFromCloudStorageAction(
        path: json['path'] as String? ?? '',
        documentId: json['documentId'] as String? ?? '',
        variable: json['variable'] == null
            ? null
            : VariableData.fromJson(
                Map<String, dynamic>.from(json['variable'] as Map),
              ),
        loadSingleDocument: json['loadSingleDocument'] as bool? ?? true,
        nonBlocking: json['nonBlocking'] as bool? ?? false,
        enabled: json['enabled'] as bool? ?? true,
        whereFilters: (json['whereFilters'] as List<dynamic>?)
            ?.map(
              (e) => WhereQueryFilter.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
        orderByFilters: (json['orderByFilters'] as List<dynamic>?)
            ?.map(
              (e) => OrderByQueryFilter.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
        limit: (json['limit'] as num?)?.toInt(),
        useCloudDatabase: json['useCloudDatabase'] as bool? ?? true,
      )
      ..type = $enumDecode(_$ActionTypeEnumMap, json['type'])
      ..collectionPath = json['collectionPath'] as String?;

Map<String, dynamic> _$LoadFromCloudStorageActionToJson(
  LoadFromCloudStorageAction instance,
) => <String, dynamic>{
  'type': _$ActionTypeEnumMap[instance.type]!,
  'nonBlocking': instance.nonBlocking,
  'enabled': instance.enabled,
  'useCloudDatabase': instance.useCloudDatabase,
  'collectionPath': ?instance.collectionPath,
  'limit': ?instance.limit,
  'whereFilters': instance.whereFilters.map((e) => e.toJson()).toList(),
  'orderByFilters': instance.orderByFilters.map((e) => e.toJson()).toList(),
  'path': instance.path,
  'documentId': instance.documentId,
  'variable': ?instance.variable?.toJson(),
  'loadSingleDocument': instance.loadSingleDocument,
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
};
