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
      nonBlocking: json['nonBlocking'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

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
  writeNotNull('path', instance.path, instance.path, '');
  writeNotNull('documentId', instance.documentId, instance.documentId, '');
  writeNotNull(
      'variable', instance.variable, instance.variable?.toJson(), null);
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
