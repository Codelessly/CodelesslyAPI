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
  if (isJsonDefault(instance.params, {})) json.remove('params');
  if (isJsonDefault(instance.barrierDismissible, true))
    json.remove('barrierDismissible');
  if (isJsonDefault(instance.presentation, DialogPresentation.dialog))
    json.remove('presentation');
  if (isJsonDefault(instance.maxHeightFactor, 1))
    json.remove('maxHeightFactor');
  if (isJsonDefault(instance.showDragHandle, false))
    json.remove('showDragHandle');
  if (isJsonDefault(instance.placement, DialogPlacement.belowStart))
    json.remove('placement');
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
  dialogId: json['dialogId'] as String?,
  params: (json['params'] as Map?)?.map((k, e) => MapEntry(k as String, e)),
  barrierDismissible: json['barrierDismissible'] as bool? ?? true,
  barrierColor: json['barrierColor'] == null
      ? null
      : ColorRGBA.fromJson(json['barrierColor']),
  backgroundColor: json['backgroundColor'] == null
      ? null
      : ColorRGBA.fromJson(json['backgroundColor']),
  textColor: json['textColor'] == null
      ? null
      : ColorRGBA.fromJson(json['textColor']),
  confirmColor: json['confirmColor'] == null
      ? null
      : ColorRGBA.fromJson(json['confirmColor']),
  cornerRadius: (json['cornerRadius'] as num?)?.toDouble(),
  border: json['border'] == null
      ? null
      : BorderSideModel.fromJson(json['border'] as Map),
  shadows: (json['shadows'] as List<dynamic>?)
      ?.map((e) => Effect.fromJson(e as Map))
      .toList(),
  titleStyle: json['titleStyle'] == null
      ? null
      : TextStyleModel.fromJson(json['titleStyle'] as Map),
  messageStyle: json['messageStyle'] == null
      ? null
      : TextStyleModel.fromJson(json['messageStyle'] as Map),
  buttonStyle: json['buttonStyle'] == null
      ? null
      : TextStyleModel.fromJson(json['buttonStyle'] as Map),
  buttonRadius: (json['buttonRadius'] as num?)?.toDouble(),
  buttonBorder: json['buttonBorder'] == null
      ? null
      : BorderSideModel.fromJson(json['buttonBorder'] as Map),
  buttonShadows: (json['buttonShadows'] as List<dynamic>?)
      ?.map((e) => Effect.fromJson(e as Map))
      .toList(),
  confirmTextColor: json['confirmTextColor'] == null
      ? null
      : ColorRGBA.fromJson(json['confirmTextColor']),
  cancelColor: json['cancelColor'] == null
      ? null
      : ColorRGBA.fromJson(json['cancelColor']),
  cancelTextColor: json['cancelTextColor'] == null
      ? null
      : ColorRGBA.fromJson(json['cancelTextColor']),
  presentation:
      $enumDecodeNullable(
        _$DialogPresentationEnumMap,
        json['presentation'],
        unknownValue: DialogPresentation.dialog,
      ) ??
      DialogPresentation.dialog,
  sheetWidth: (json['sheetWidth'] as num?)?.toDouble(),
  maxHeightFactor: (json['maxHeightFactor'] as num?)?.toDouble() ?? 1,
  showDragHandle: json['showDragHandle'] as bool? ?? false,
  placement:
      $enumDecodeNullable(
        _$DialogPlacementEnumMap,
        json['placement'],
        unknownValue: DialogPlacement.belowStart,
      ) ??
      DialogPlacement.belowStart,
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
      'dialogId': ?instance.dialogId,
      'params': instance.params,
      'barrierDismissible': instance.barrierDismissible,
      'barrierColor': ?instance.barrierColor?.toJson(),
      'backgroundColor': ?instance.backgroundColor?.toJson(),
      'textColor': ?instance.textColor?.toJson(),
      'confirmColor': ?instance.confirmColor?.toJson(),
      'cornerRadius': ?instance.cornerRadius,
      'border': ?instance.border?.toJson(),
      'shadows': ?instance.shadows?.map((e) => e.toJson()).toList(),
      'titleStyle': ?instance.titleStyle?.toJson(),
      'messageStyle': ?instance.messageStyle?.toJson(),
      'buttonStyle': ?instance.buttonStyle?.toJson(),
      'buttonRadius': ?instance.buttonRadius,
      'buttonBorder': ?instance.buttonBorder?.toJson(),
      'buttonShadows': ?instance.buttonShadows?.map((e) => e.toJson()).toList(),
      'confirmTextColor': ?instance.confirmTextColor?.toJson(),
      'cancelColor': ?instance.cancelColor?.toJson(),
      'cancelTextColor': ?instance.cancelTextColor?.toJson(),
      'presentation': _$DialogPresentationEnumMap[instance.presentation]!,
      'sheetWidth': ?instance.sheetWidth,
      'maxHeightFactor': instance.maxHeightFactor,
      'showDragHandle': instance.showDragHandle,
      'placement': _$DialogPlacementEnumMap[instance.placement]!,
    };

const _$DialogPresentationEnumMap = {
  DialogPresentation.dialog: 'dialog',
  DialogPresentation.bottomSheet: 'bottomSheet',
  DialogPresentation.adaptive: 'adaptive',
  DialogPresentation.sideSheet: 'sideSheet',
  DialogPresentation.fullScreen: 'fullScreen',
  DialogPresentation.popover: 'popover',
};

const _$DialogPlacementEnumMap = {
  DialogPlacement.belowStart: 'belowStart',
  DialogPlacement.belowCenter: 'belowCenter',
  DialogPlacement.belowEnd: 'belowEnd',
  DialogPlacement.aboveStart: 'aboveStart',
  DialogPlacement.aboveCenter: 'aboveCenter',
  DialogPlacement.aboveEnd: 'aboveEnd',
  DialogPlacement.rightStart: 'rightStart',
  DialogPlacement.rightCenter: 'rightCenter',
  DialogPlacement.rightEnd: 'rightEnd',
  DialogPlacement.leftStart: 'leftStart',
  DialogPlacement.leftCenter: 'leftCenter',
  DialogPlacement.leftEnd: 'leftEnd',
  DialogPlacement.center: 'center',
  DialogPlacement.bottomSheet: 'bottomSheet',
  DialogPlacement.adaptive: 'adaptive',
  DialogPlacement.anchored: 'anchored',
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
};
