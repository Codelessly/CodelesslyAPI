// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_variable_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetVariableAction _$SetVariableActionFromJson(Map json) => SetVariableAction(
      variable: VariableData.fromJson(
          Map<String, dynamic>.from(json['variable'] as Map)),
      newValue: json['newValue'] as String,
      toggled: json['toggled'] as bool? ?? false,
      listOperation:
          $enumDecodeNullable(_$ListOperationEnumMap, json['listOperation']) ??
              ListOperation.replace,
      index: json['index'] as String? ?? '0',
      mapOperation:
          $enumDecodeNullable(_$MapOperationEnumMap, json['mapOperation']) ??
              MapOperation.replace,
      key: json['key'] as String? ?? 'key',
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetVariableActionToJson(SetVariableAction instance) {
  final val = <String, dynamic>{
    'type': _$ActionTypeEnumMap[instance.type]!,
    'variable': instance.variable.toJson(),
    'newValue': instance.newValue,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('toggled', instance.toggled, instance.toggled, false);
  writeNotNull('listOperation', instance.listOperation,
      _$ListOperationEnumMap[instance.listOperation]!, ListOperation.replace);
  writeNotNull('index', instance.index, instance.index, '0');
  writeNotNull('mapOperation', instance.mapOperation,
      _$MapOperationEnumMap[instance.mapOperation]!, MapOperation.replace);
  writeNotNull('key', instance.key, instance.key, 'key');
  return val;
}

const _$ListOperationEnumMap = {
  ListOperation.replace: 'replace',
  ListOperation.add: 'add',
  ListOperation.insert: 'insert',
  ListOperation.removeAt: 'removeAt',
  ListOperation.remove: 'remove',
  ListOperation.update: 'update',
};

const _$MapOperationEnumMap = {
  MapOperation.replace: 'replace',
  MapOperation.add: 'add',
  MapOperation.remove: 'remove',
  MapOperation.update: 'update',
};

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.setVariable: 'setVariable',
  ActionType.callFunction: 'callFunction',
  ActionType.callApi: 'callApi',
};
