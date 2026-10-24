// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_dialog_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ShowDialogActionOmitDefaults(
  ShowDialogAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.barrierDismissible, true))
    json.remove('barrierDismissible');
  if (isJsonDefault(instance.barrierColor, ColorRGBA.black54))
    json.remove('barrierColor');
  if (isJsonDefault(instance.showCloseButton, false))
    json.remove('showCloseButton');
  if (isJsonDefault(instance.presentation, DialogPresentation.dialog))
    json.remove('presentation');
  if (isJsonDefault(instance.alignment, AlignmentModel.center))
    json.remove('alignment');
  if (isJsonDefault(instance.maxHeightFactor, 0.92))
    json.remove('maxHeightFactor');
  if (isJsonDefault(instance.showDragHandle, true))
    json.remove('showDragHandle');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShowDialogAction _$ShowDialogActionFromJson(Map json) => ShowDialogAction(
  destinationId: json['destinationId'] as String,
  params: (json['params'] as Map?)?.map(
    (k, e) => MapEntry(k as String, e as String),
  ),
  barrierColor: json['barrierColor'] == null
      ? ColorRGBA.black54
      : ColorRGBA.fromJson(json['barrierColor']),
  barrierDismissible: json['barrierDismissible'] as bool? ?? true,
  showCloseButton: json['showCloseButton'] as bool? ?? false,
  presentation:
      $enumDecodeNullable(
        _$DialogPresentationEnumMap,
        json['presentation'],
        unknownValue: DialogPresentation.dialog,
      ) ??
      DialogPresentation.dialog,
  alignment: json['alignment'] == null
      ? AlignmentModel.center
      : AlignmentModel.fromJson(json['alignment'] as Map),
  sheetWidth: (json['sheetWidth'] as num?)?.toDouble(),
  maxHeightFactor: (json['maxHeightFactor'] as num?)?.toDouble() ?? 0.92,
  showDragHandle: json['showDragHandle'] as bool? ?? true,
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ShowDialogActionToJson(ShowDialogAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'destinationId': instance.destinationId,
      'params': instance.params,
      'barrierDismissible': instance.barrierDismissible,
      'barrierColor': ?instance.barrierColor?.toJson(),
      'showCloseButton': instance.showCloseButton,
      'presentation': _$DialogPresentationEnumMap[instance.presentation]!,
      'alignment': instance.alignment.toJson(),
      'sheetWidth': ?instance.sheetWidth,
      'maxHeightFactor': instance.maxHeightFactor,
      'showDragHandle': instance.showDragHandle,
    };

const _$DialogPresentationEnumMap = {
  DialogPresentation.dialog: 'dialog',
  DialogPresentation.bottomSheet: 'bottomSheet',
  DialogPresentation.adaptive: 'adaptive',
  DialogPresentation.sideSheet: 'sideSheet',
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
