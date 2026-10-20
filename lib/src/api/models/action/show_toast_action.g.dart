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
  if (isJsonDefault(
    instance.backgroundColor,
    const ColorRGBA(r: 0.169, g: 0.141, b: 0.125, a: 1),
  ))
    json.remove('backgroundColor');
  if (isJsonDefault(instance.textColor, ColorRGBA.white))
    json.remove('textColor');
  if (isJsonDefault(instance.bottomOffset, 104)) json.remove('bottomOffset');
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
      ? const ColorRGBA(r: 0.169, g: 0.141, b: 0.125, a: 1)
      : ColorRGBA.fromJson(json['backgroundColor']),
  textColor: json['textColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['textColor']),
  icon: json['icon'] == null
      ? null
      : MultiSourceIconModel.fromJson(json['icon'] as Map),
  bottomOffset: (json['bottomOffset'] as num?)?.toDouble() ?? 104,
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
      'backgroundColor': instance.backgroundColor.toJson(),
      'textColor': instance.textColor.toJson(),
      'icon': ?instance.icon?.toJson(),
      'bottomOffset': instance.bottomOffset,
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
};
