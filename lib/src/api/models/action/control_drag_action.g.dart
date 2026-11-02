// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_drag_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ControlDragActionOmitDefaults(
  ControlDragAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nodeId, '')) json.remove('nodeId');
  if (isJsonDefault(instance.command, DragCommand.fling))
    json.remove('command');
  if (isJsonDefault(instance.direction, DragDirection.right))
    json.remove('direction');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ControlDragAction _$ControlDragActionFromJson(Map json) => ControlDragAction(
  nodeId: json['nodeId'] as String? ?? '',
  command:
      $enumDecodeNullable(_$DragCommandEnumMap, json['command']) ??
      DragCommand.fling,
  direction:
      $enumDecodeNullable(_$DragDirectionEnumMap, json['direction']) ??
      DragDirection.right,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ControlDragActionToJson(ControlDragAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'nodeId': instance.nodeId,
      'command': _$DragCommandEnumMap[instance.command]!,
      'direction': _$DragDirectionEnumMap[instance.direction]!,
    };

const _$DragCommandEnumMap = {
  DragCommand.fling: 'fling',
  DragCommand.returnFrom: 'returnFrom',
  DragCommand.reset: 'reset',
};

const _$DragDirectionEnumMap = {
  DragDirection.left: 'left',
  DragDirection.right: 'right',
  DragDirection.up: 'up',
  DragDirection.down: 'down',
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
  ActionType.controlDrag: 'controlDrag',
  ActionType.speak: 'speak',
  ActionType.playSound: 'playSound',
};
