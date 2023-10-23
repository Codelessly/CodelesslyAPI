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
      barrierDismissible: json['barrierDismissible'] as bool? ?? true,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$ShowDialogActionToJson(ShowDialogAction instance) {
  final val = <String, dynamic>{
    'type': _$ActionTypeEnumMap[instance.type]!,
    'destinationId': instance.destinationId,
    'params': instance.params,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('barrierDismissible', instance.barrierDismissible,
      instance.barrierDismissible, true);
  return val;
}

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.setVariable: 'setVariable',
  ActionType.callFunction: 'callFunction',
  ActionType.callApi: 'callApi',
  ActionType.setStorage: 'setStorage',
  ActionType.showDialog: 'showDialog',
};
