// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_data_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$CloudFieldWriteOmitDefaults(
  CloudFieldWrite instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.value, '')) json.remove('value');
  if (isJsonDefault(instance.operation, CloudFieldOperation.set))
    json.remove('operation');
  return json;
}

Map<String, dynamic> _$CloudDataActionOmitDefaults(
  CloudDataAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.operation, CloudDataOperation.create))
    json.remove('operation');
  if (isJsonDefault(instance.collection, '')) json.remove('collection');
  if (isJsonDefault(instance.documentId, '')) json.remove('documentId');
  if (isJsonDefault(instance.fields, [])) json.remove('fields');
  if (isJsonDefault(instance.whereFilters, [])) json.remove('whereFilters');
  if (isJsonDefault(instance.orderByFilters, [])) json.remove('orderByFilters');
  if (isJsonDefault(instance.aggregateField, '')) json.remove('aggregateField');
  if (isJsonDefault(instance.loadRelated, [])) json.remove('loadRelated');
  if (isJsonDefault(instance.deleteSubcollections, []))
    json.remove('deleteSubcollections');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

Map<String, dynamic> _$CloudBatchActionOmitDefaults(
  CloudBatchAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.steps, [])) json.remove('steps');
  if (isJsonDefault(instance.transaction, false)) json.remove('transaction');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudFieldWrite _$CloudFieldWriteFromJson(Map json) => CloudFieldWrite(
  field: json['field'] as String,
  value: json['value'] as String? ?? '',
  operation:
      $enumDecodeNullable(_$CloudFieldOperationEnumMap, json['operation']) ??
      CloudFieldOperation.set,
);

Map<String, dynamic> _$CloudFieldWriteToJson(CloudFieldWrite instance) =>
    <String, dynamic>{
      'field': instance.field,
      'value': instance.value,
      'operation': _$CloudFieldOperationEnumMap[instance.operation]!,
    };

const _$CloudFieldOperationEnumMap = {
  CloudFieldOperation.set: 'set',
  CloudFieldOperation.increment: 'increment',
  CloudFieldOperation.arrayAdd: 'arrayAdd',
  CloudFieldOperation.arrayRemove: 'arrayRemove',
  CloudFieldOperation.delete: 'delete',
  CloudFieldOperation.serverTime: 'serverTime',
};

CloudDataAction _$CloudDataActionFromJson(Map json) => CloudDataAction(
  operation:
      $enumDecodeNullable(_$CloudDataOperationEnumMap, json['operation']) ??
      CloudDataOperation.create,
  collection: json['collection'] as String? ?? '',
  documentId: json['documentId'] as String? ?? '',
  fields:
      (json['fields'] as List<dynamic>?)
          ?.map((e) => CloudFieldWrite.fromJson(e as Map))
          .toList() ??
      [],
  whereFilters:
      (json['whereFilters'] as List<dynamic>?)
          ?.map(
            (e) =>
                WhereQueryFilter.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      [],
  orderByFilters:
      (json['orderByFilters'] as List<dynamic>?)
          ?.map(
            (e) => OrderByQueryFilter.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList() ??
      [],
  limit: (json['limit'] as num?)?.toInt(),
  aggregateField: json['aggregateField'] as String? ?? '',
  loadRelated:
      (json['loadRelated'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  deleteSubcollections:
      (json['deleteSubcollections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  resultVariable: json['resultVariable'] == null
      ? null
      : VariableData.fromJson(
          Map<String, dynamic>.from(json['resultVariable'] as Map),
        ),
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$CloudDataActionToJson(CloudDataAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'operation': _$CloudDataOperationEnumMap[instance.operation]!,
      'collection': instance.collection,
      'documentId': instance.documentId,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
      'whereFilters': instance.whereFilters.map((e) => e.toJson()).toList(),
      'orderByFilters': instance.orderByFilters.map((e) => e.toJson()).toList(),
      'limit': ?instance.limit,
      'aggregateField': instance.aggregateField,
      'loadRelated': instance.loadRelated,
      'deleteSubcollections': instance.deleteSubcollections,
      'resultVariable': ?instance.resultVariable?.toJson(),
    };

const _$CloudDataOperationEnumMap = {
  CloudDataOperation.create: 'create',
  CloudDataOperation.update: 'update',
  CloudDataOperation.delete: 'delete',
  CloudDataOperation.get: 'get',
  CloudDataOperation.query: 'query',
  CloudDataOperation.count: 'count',
  CloudDataOperation.sum: 'sum',
  CloudDataOperation.average: 'average',
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
};

CloudBatchAction _$CloudBatchActionFromJson(Map json) => CloudBatchAction(
  steps:
      (json['steps'] as List<dynamic>?)
          ?.map((e) => CloudDataAction.fromJson(e as Map))
          .toList() ??
      [],
  transaction: json['transaction'] as bool? ?? false,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$CloudBatchActionToJson(CloudBatchAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
      'transaction': instance.transaction,
    };
