// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_dialog_action.dart';

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
      nonBlocking: json['nonBlocking'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ShowDialogActionToJson(ShowDialogAction instance) {
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
  val['destinationId'] = instance.destinationId;
  val['params'] = instance.params;
  writeNotNull('barrierDismissible', instance.barrierDismissible,
      instance.barrierDismissible, true);
  writeNotNull('barrierColor', instance.barrierColor,
      instance.barrierColor?.toJson(), ColorRGBA.black54);
  writeNotNull('showCloseButton', instance.showCloseButton,
      instance.showCloseButton, false);
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
