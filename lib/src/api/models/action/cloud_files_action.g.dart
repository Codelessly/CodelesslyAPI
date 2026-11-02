// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_files_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$CloudFilesActionOmitDefaults(
  CloudFilesAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.operation, CloudFilesOperation.upload))
    json.remove('operation');
  if (isJsonDefault(instance.path, '')) json.remove('path');
  if (isJsonDefault(instance.fileType, CloudFilesType.image))
    json.remove('fileType');
  if (isJsonDefault(instance.allowMultiple, true)) json.remove('allowMultiple');
  if (isJsonDefault(instance.maxSizeMB, 10)) json.remove('maxSizeMB');
  if (isJsonDefault(instance.access, CloudFileAccess.public))
    json.remove('access');
  if (isJsonDefault(instance.actions, [])) json.remove('actions');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudFilesAction _$CloudFilesActionFromJson(Map json) => CloudFilesAction(
  operation:
      $enumDecodeNullable(_$CloudFilesOperationEnumMap, json['operation']) ??
      CloudFilesOperation.upload,
  path: json['path'] as String? ?? '',
  fileType:
      $enumDecodeNullable(_$CloudFilesTypeEnumMap, json['fileType']) ??
      CloudFilesType.image,
  allowMultiple: json['allowMultiple'] as bool? ?? true,
  maxSizeMB: json['maxSizeMB'] as num? ?? 10,
  progressVariable: json['progressVariable'] == null
      ? null
      : VariableData.fromJson(
          Map<String, dynamic>.from(json['progressVariable'] as Map),
        ),
  access:
      $enumDecodeNullable(_$CloudFileAccessEnumMap, json['access']) ??
      CloudFileAccess.public,
  actions: (json['actions'] as List<dynamic>?)
      ?.map((e) => ActionModel.fromJson(e as Map))
      .toList(),
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$CloudFilesActionToJson(CloudFilesAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'operation': _$CloudFilesOperationEnumMap[instance.operation]!,
      'path': instance.path,
      'fileType': _$CloudFilesTypeEnumMap[instance.fileType]!,
      'allowMultiple': instance.allowMultiple,
      'maxSizeMB': instance.maxSizeMB,
      'progressVariable': ?instance.progressVariable?.toJson(),
      'access': _$CloudFileAccessEnumMap[instance.access]!,
      'actions': instance.actions.map((e) => e.toJson()).toList(),
    };

const _$CloudFilesOperationEnumMap = {
  CloudFilesOperation.upload: 'upload',
  CloudFilesOperation.delete: 'delete',
};

const _$CloudFilesTypeEnumMap = {
  CloudFilesType.image: 'image',
  CloudFilesType.any: 'any',
};

const _$CloudFileAccessEnumMap = {
  CloudFileAccess.private: 'private',
  CloudFileAccess.public: 'public',
};

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.showDialog: 'showDialog',
  ActionType.closeModal: 'closeModal',
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
  ActionType.paywall: 'paywall',
  ActionType.focus: 'focus',
};
