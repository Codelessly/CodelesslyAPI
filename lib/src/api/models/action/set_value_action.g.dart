// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_value_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetValueAction _$SetValueActionFromJson(Map json) => SetValueAction(
      nodeID: json['nodeID'] as String,
      values: valuesFromJson(json['values'] as List),
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetValueActionToJson(SetValueAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nodeID': instance.nodeID,
      'values': instance.values.map((e) => e.toJson()).toList(),
    };

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.callFunction: 'callFunction',
};

BoolValue _$BoolValueFromJson(Map json) => BoolValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: json['value'] as bool? ?? false,
      nullable: json['nullable'] as bool? ?? false,
    );

Map<String, dynamic> _$BoolValueToJson(BoolValue instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'mode': _$SetValueModeEnumMap[instance.mode]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('value', instance.value);
  val['nullable'] = instance.nullable;
  return val;
}

const _$SetValueModeEnumMap = {
  SetValueMode.discrete: 'discrete',
  SetValueMode.toggle: 'toggle',
  SetValueMode.syncValue: 'syncValue',
};

IntValue _$IntValueFromJson(Map json) => IntValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: json['value'] as int? ?? 0,
    );

Map<String, dynamic> _$IntValueToJson(IntValue instance) => <String, dynamic>{
      'name': instance.name,
      'mode': _$SetValueModeEnumMap[instance.mode]!,
      'value': instance.value,
    };

DoubleValue _$DoubleValueFromJson(Map json) => DoubleValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$DoubleValueToJson(DoubleValue instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': _$SetValueModeEnumMap[instance.mode]!,
      'value': instance.value,
    };

StringValue _$StringValueFromJson(Map json) => StringValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$StringValueToJson(StringValue instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': _$SetValueModeEnumMap[instance.mode]!,
      'value': instance.value,
    };
