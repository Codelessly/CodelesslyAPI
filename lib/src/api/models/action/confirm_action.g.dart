// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ConfirmActionOmitDefaults(
  ConfirmAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.message, '')) json.remove('message');
  if (isJsonDefault(instance.confirmLabel, 'OK')) json.remove('confirmLabel');
  if (isJsonDefault(instance.cancelLabel, 'Cancel')) json.remove('cancelLabel');
  if (isJsonDefault(instance.destructive, false)) json.remove('destructive');
  if (isJsonDefault(instance.actions, [])) json.remove('actions');
  if (isJsonDefault(instance.cancelActions, [])) json.remove('cancelActions');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmAction _$ConfirmActionFromJson(Map json) => ConfirmAction(
  title: json['title'] as String,
  message: json['message'] as String? ?? '',
  confirmLabel: json['confirmLabel'] as String? ?? 'OK',
  cancelLabel: json['cancelLabel'] as String? ?? 'Cancel',
  destructive: json['destructive'] as bool? ?? false,
  actions: (json['actions'] as List<dynamic>?)
      ?.map((e) => ActionModel.fromJson(e as Map))
      .toList(),
  cancelActions: (json['cancelActions'] as List<dynamic>?)
      ?.map((e) => ActionModel.fromJson(e as Map))
      .toList(),
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ConfirmActionToJson(ConfirmAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'title': instance.title,
      'message': instance.message,
      'confirmLabel': instance.confirmLabel,
      'cancelLabel': instance.cancelLabel,
      'destructive': instance.destructive,
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'cancelActions': instance.cancelActions.map((e) => e.toJson()).toList(),
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
