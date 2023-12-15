// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_from_cloud_storage_action.dart';

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
              Map<String, dynamic>.from(json['variable'] as Map)),
      loadSingleDocument: json['loadSingleDocument'] as bool? ?? true,
      nonBlocking: json['nonBlocking'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
      whereFilters: (json['whereFilters'] as List<dynamic>?)
          ?.map((e) =>
              WhereQueryFilter.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      orderByOperations: (json['orderByOperations'] as List<dynamic>?)
          ?.map((e) =>
              OrderByQueryFilter.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    )
      ..type = $enumDecode(_$ActionTypeEnumMap, json['type'])
      ..useCloudDatabase = json['useCloudDatabase'] as bool
      ..collectionPath = json['collectionPath'] as String?
      ..limit = json['limit'] as int;

Map<String, dynamic> _$LoadFromCloudStorageActionToJson(
    LoadFromCloudStorageAction instance) {
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

  writeNotNull(
      'nonBlocking', instance.nonBlocking, instance.nonBlocking, false);
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  val['whereFilters'] = instance.whereFilters.map((e) => e.toJson()).toList();
  val['orderByOperations'] =
      instance.orderByOperations.map((e) => e.toJson()).toList();
  val['useCloudDatabase'] = instance.useCloudDatabase;
  writeNotNull(
      'collectionPath', instance.collectionPath, instance.collectionPath, null);
  val['limit'] = instance.limit;
  writeNotNull('path', instance.path, instance.path, '');
  writeNotNull('documentId', instance.documentId, instance.documentId, '');
  writeNotNull(
      'variable', instance.variable, instance.variable?.toJson(), null);
  writeNotNull('loadSingleDocument', instance.loadSingleDocument,
      instance.loadSingleDocument, true);
  return val;
}

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
