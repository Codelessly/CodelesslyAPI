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
  if (isJsonDefault(instance.iconSize, 18)) json.remove('iconSize');
  if (isJsonDefault(instance.bottomOffset, 104)) json.remove('bottomOffset');
  if (isJsonDefault(instance.bottomOffsets, {})) json.remove('bottomOffsets');
  if (isJsonDefault(instance.showClose, false)) json.remove('showClose');
  if (isJsonDefault(instance.maxWidth, 560)) json.remove('maxWidth');
  if (isJsonDefault(instance.accentWidth, 4)) json.remove('accentWidth');
  if (isJsonDefault(instance.alignment, ToastAlignment.center))
    json.remove('alignment');
  if (isJsonDefault(instance.sideMargin, 16)) json.remove('sideMargin');
  if (isJsonDefault(instance.showCloseButton, false))
    json.remove('showCloseButton');
  if (isJsonDefault(instance.offset, '')) json.remove('offset');
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
  iconSize: (json['iconSize'] as num?)?.toDouble() ?? 18,
  bottomOffset: (json['bottomOffset'] as num?)?.toDouble() ?? 104,
  bottomOffsets: (json['bottomOffsets'] as Map?)?.map(
    (k, e) => MapEntry(
      $enumDecode(_$ScreenBreakpointEnumMap, k),
      (e as num).toDouble(),
    ),
  ),
  actionColor: json['actionColor'] == null
      ? null
      : ColorRGBA.fromJson(json['actionColor']),
  showClose: json['showClose'] as bool? ?? false,
  closeColor: json['closeColor'] == null
      ? null
      : ColorRGBA.fromJson(json['closeColor']),
  cornerRadius: (json['cornerRadius'] as num?)?.toDouble(),
  border: json['border'] == null
      ? null
      : BorderSideModel.fromJson(json['border'] as Map),
  shadows: (json['shadows'] as List<dynamic>?)
      ?.map((e) => Effect.fromJson(e as Map))
      .toList(),
  padding: json['padding'] == null
      ? null
      : EdgeInsetsModel.fromJson(json['padding']),
  maxWidth: (json['maxWidth'] as num?)?.toDouble() ?? 560,
  messageStyle: json['messageStyle'] == null
      ? null
      : TextStyleModel.fromJson(json['messageStyle'] as Map),
  actionStyle: json['actionStyle'] == null
      ? null
      : TextStyleModel.fromJson(json['actionStyle'] as Map),
  accentColor: json['accentColor'] == null
      ? null
      : ColorRGBA.fromJson(json['accentColor']),
  accentWidth: (json['accentWidth'] as num?)?.toDouble() ?? 4,
  iconColor: json['iconColor'] == null
      ? null
      : ColorRGBA.fromJson(json['iconColor']),
  fontFamily: json['fontFamily'] as String?,
  alignment:
      $enumDecodeNullable(
        _$ToastAlignmentEnumMap,
        json['alignment'],
        unknownValue: ToastAlignment.center,
      ) ??
      ToastAlignment.center,
  sideMargin: (json['sideMargin'] as num?)?.toDouble() ?? 16,
  showCloseButton: json['showCloseButton'] as bool? ?? false,
  fontSize: (json['fontSize'] as num?)?.toDouble(),
  fontWeight: $enumDecodeNullable(
    _$FontWeightNumericEnumMap,
    json['fontWeight'],
  ),
  offset: json['offset'] as String? ?? '',
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
      'iconSize': instance.iconSize,
      'bottomOffset': instance.bottomOffset,
      'bottomOffsets': instance.bottomOffsets.map(
        (k, e) => MapEntry(_$ScreenBreakpointEnumMap[k]!, e),
      ),
      'actionColor': ?instance.actionColor?.toJson(),
      'showClose': instance.showClose,
      'closeColor': ?instance.closeColor?.toJson(),
      'cornerRadius': ?instance.cornerRadius,
      'border': ?instance.border?.toJson(),
      'shadows': ?instance.shadows?.map((e) => e.toJson()).toList(),
      'padding': ?instance.padding?.toJson(),
      'maxWidth': instance.maxWidth,
      'messageStyle': ?instance.messageStyle?.toJson(),
      'actionStyle': ?instance.actionStyle?.toJson(),
      'accentColor': ?instance.accentColor?.toJson(),
      'accentWidth': instance.accentWidth,
      'iconColor': ?instance.iconColor?.toJson(),
      'fontFamily': ?instance.fontFamily,
      'alignment': _$ToastAlignmentEnumMap[instance.alignment]!,
      'sideMargin': instance.sideMargin,
      'showCloseButton': instance.showCloseButton,
      'fontSize': ?instance.fontSize,
      'fontWeight': ?_$FontWeightNumericEnumMap[instance.fontWeight],
      'offset': instance.offset,
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

const _$ScreenBreakpointEnumMap = {
  ScreenBreakpoint.mobile: 'mobile',
  ScreenBreakpoint.tablet: 'tablet',
  ScreenBreakpoint.desktop: 'desktop',
};

const _$ToastAlignmentEnumMap = {
  ToastAlignment.center: 'center',
  ToastAlignment.start: 'start',
  ToastAlignment.end: 'end',
  ToastAlignment.stretch: 'stretch',
};

const _$FontWeightNumericEnumMap = {
  FontWeightNumeric.w100: 'w100',
  FontWeightNumeric.w200: 'w200',
  FontWeightNumeric.w300: 'w300',
  FontWeightNumeric.w400: 'w400',
  FontWeightNumeric.w500: 'w500',
  FontWeightNumeric.w600: 'w600',
  FontWeightNumeric.w700: 'w700',
  FontWeightNumeric.w800: 'w800',
  FontWeightNumeric.w900: 'w900',
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
