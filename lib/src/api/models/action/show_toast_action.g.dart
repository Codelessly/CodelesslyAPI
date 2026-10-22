// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_toast_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ShowToastActionOmitDefaults(
  ShowToastAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.duration, 2600)) json.remove('duration');
  if (isJsonDefault(instance.style, ToastStyle.neutral)) json.remove('style');
  if (isJsonDefault(instance.position, ToastPosition.bottom))
    json.remove('position');
  if (isJsonDefault(instance.actionLabel, '')) json.remove('actionLabel');
  if (isJsonDefault(instance.actions, [])) json.remove('actions');
  if (isJsonDefault(instance.bottomOffset, 104)) json.remove('bottomOffset');
  if (isJsonDefault(instance.alignment, ToastAlignment.center))
    json.remove('alignment');
  if (isJsonDefault(instance.sideMargin, 16)) json.remove('sideMargin');
  if (isJsonDefault(instance.maxWidth, 560)) json.remove('maxWidth');
  if (isJsonDefault(instance.showCloseButton, false))
    json.remove('showCloseButton');
  if (isJsonDefault(instance.fontSize, 14)) json.remove('fontSize');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShowToastAction _$ShowToastActionFromJson(Map json) => ShowToastAction(
  message: json['message'] as String,
  duration: (json['duration'] as num?)?.toInt() ?? 2600,
  backgroundColor: json['backgroundColor'] == null
      ? null
      : ColorRGBA.fromJson(json['backgroundColor']),
  textColor: json['textColor'] == null
      ? null
      : ColorRGBA.fromJson(json['textColor']),
  style:
      $enumDecodeNullable(
        _$ToastStyleEnumMap,
        json['style'],
        unknownValue: ToastStyle.neutral,
      ) ??
      ToastStyle.neutral,
  position:
      $enumDecodeNullable(
        _$ToastPositionEnumMap,
        json['position'],
        unknownValue: ToastPosition.bottom,
      ) ??
      ToastPosition.bottom,
  actionLabel: json['actionLabel'] as String? ?? '',
  actions: (json['actions'] as List<dynamic>?)
      ?.map((e) => ActionModel.fromJson(e as Map))
      .toList(),
  icon: json['icon'] == null
      ? null
      : MultiSourceIconModel.fromJson(json['icon'] as Map),
  bottomOffset: (json['bottomOffset'] as num?)?.toDouble() ?? 104,
  alignment:
      $enumDecodeNullable(
        _$ToastAlignmentEnumMap,
        json['alignment'],
        unknownValue: ToastAlignment.center,
      ) ??
      ToastAlignment.center,
  sideMargin: (json['sideMargin'] as num?)?.toDouble() ?? 16,
  maxWidth: (json['maxWidth'] as num?)?.toDouble() ?? 560,
  cornerRadius: (json['cornerRadius'] as num?)?.toDouble(),
  actionColor: json['actionColor'] == null
      ? null
      : ColorRGBA.fromJson(json['actionColor']),
  showCloseButton: json['showCloseButton'] as bool? ?? false,
  fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ShowToastActionToJson(ShowToastAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'message': instance.message,
      'duration': instance.duration,
      'backgroundColor': ?instance.backgroundColor?.toJson(),
      'textColor': ?instance.textColor?.toJson(),
      'style': _$ToastStyleEnumMap[instance.style]!,
      'position': _$ToastPositionEnumMap[instance.position]!,
      'actionLabel': instance.actionLabel,
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'icon': ?instance.icon?.toJson(),
      'bottomOffset': instance.bottomOffset,
      'alignment': _$ToastAlignmentEnumMap[instance.alignment]!,
      'sideMargin': instance.sideMargin,
      'maxWidth': instance.maxWidth,
      'cornerRadius': ?instance.cornerRadius,
      'actionColor': ?instance.actionColor?.toJson(),
      'showCloseButton': instance.showCloseButton,
      'fontSize': instance.fontSize,
    };

const _$ToastStyleEnumMap = {
  ToastStyle.neutral: 'neutral',
  ToastStyle.info: 'info',
  ToastStyle.success: 'success',
  ToastStyle.warning: 'warning',
  ToastStyle.error: 'error',
};

const _$ToastPositionEnumMap = {
  ToastPosition.bottom: 'bottom',
  ToastPosition.top: 'top',
};

const _$ToastAlignmentEnumMap = {
  ToastAlignment.center: 'center',
  ToastAlignment.start: 'start',
  ToastAlignment.end: 'end',
  ToastAlignment.stretch: 'stretch',
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
