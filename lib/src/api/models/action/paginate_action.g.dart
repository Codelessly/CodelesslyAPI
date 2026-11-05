// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginate_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PaginateActionOmitDefaults(
  PaginateAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.controller, '')) json.remove('controller');
  if (isJsonDefault(instance.command, PaginateCommand.next))
    json.remove('command');
  if (isJsonDefault(instance.page, '1')) json.remove('page');
  if (isJsonDefault(instance.pageSize, '20')) json.remove('pageSize');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginateAction _$PaginateActionFromJson(Map json) => PaginateAction(
  controller: json['controller'] as String? ?? '',
  command:
      $enumDecodeNullable(_$PaginateCommandEnumMap, json['command']) ??
      PaginateCommand.next,
  page: json['page'] as String? ?? '1',
  pageSize: json['pageSize'] as String? ?? '20',
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$PaginateActionToJson(PaginateAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'controller': instance.controller,
      'command': _$PaginateCommandEnumMap[instance.command]!,
      'page': instance.page,
      'pageSize': instance.pageSize,
    };

const _$PaginateCommandEnumMap = {
  PaginateCommand.next: 'next',
  PaginateCommand.previous: 'previous',
  PaginateCommand.goTo: 'goTo',
  PaginateCommand.first: 'first',
  PaginateCommand.last: 'last',
  PaginateCommand.refresh: 'refresh',
  PaginateCommand.retry: 'retry',
  PaginateCommand.setPageSize: 'setPageSize',
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
  ActionType.editText: 'editText',
  ActionType.paywall: 'paywall',
  ActionType.focus: 'focus',
  ActionType.controlDrag: 'controlDrag',
  ActionType.speak: 'speak',
  ActionType.scrollTo: 'scrollTo',
  ActionType.playSound: 'playSound',
  ActionType.playAnimation: 'playAnimation',
  ActionType.paginate: 'paginate',
};
