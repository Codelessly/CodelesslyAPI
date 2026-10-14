// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_value_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SetValueActionOmitDefaults(
  SetValueAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

Map<String, dynamic> _$BoolValueOmitDefaults(
  BoolValue instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nullable, false)) json.remove('nullable');
  if (isJsonDefault(instance.mode, SetValueMode.discrete)) json.remove('mode');
  if (isJsonDefault(instance.value, false)) json.remove('value');
  return json;
}

Map<String, dynamic> _$IntValueOmitDefaults(
  IntValue instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.mode, SetValueMode.discrete)) json.remove('mode');
  if (isJsonDefault(instance.value, 0)) json.remove('value');
  return json;
}

Map<String, dynamic> _$DoubleValueOmitDefaults(
  DoubleValue instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.mode, SetValueMode.discrete)) json.remove('mode');
  if (isJsonDefault(instance.value, 0)) json.remove('value');
  return json;
}

Map<String, dynamic> _$StringValueOmitDefaults(
  StringValue instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.mode, SetValueMode.discrete)) json.remove('mode');
  if (isJsonDefault(instance.value, '')) json.remove('value');
  return json;
}

Map<String, dynamic> _$ObjectValueOmitDefaults(
  ObjectValue instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.mode, SetValueMode.syncValue)) json.remove('mode');
  if (isJsonDefault(instance.value, '')) json.remove('value');
  return json;
}

Map<String, dynamic> _$ColorValueOmitDefaults(
  ColorValue instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nullable, false)) json.remove('nullable');
  if (isJsonDefault(instance.mode, SetValueMode.discrete)) json.remove('mode');
  return json;
}

Map<String, dynamic> _$PaintValueOmitDefaults(
  PaintValue instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.nullable, false)) json.remove('nullable');
  if (isJsonDefault(instance.mode, SetValueMode.discrete)) json.remove('mode');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetValueAction _$SetValueActionFromJson(Map json) => SetValueAction(
  nodeID: json['nodeID'] as String,
  values: valuesFromJson(json['values'] as List),
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetValueActionToJson(SetValueAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'nodeID': instance.nodeID,
      'values': instance.values.map((e) => e.toJson()).toList(),
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
};

BoolValue _$BoolValueFromJson(Map json) => BoolValue(
  name: json['name'] as String,
  mode:
      $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
      SetValueMode.discrete,
  value: json['value'] as bool? ?? false,
  nullable: json['nullable'] as bool? ?? false,
);

Map<String, dynamic> _$BoolValueToJson(BoolValue instance) => <String, dynamic>{
  'name': instance.name,
  'mode': _$SetValueModeEnumMap[instance.mode]!,
  'value': ?instance.value,
  'type': _$ValueTypeEnumMap[instance.type]!,
  'nullable': instance.nullable,
};

const _$SetValueModeEnumMap = {
  SetValueMode.discrete: 'discrete',
  SetValueMode.toggle: 'toggle',
  SetValueMode.syncValue: 'syncValue',
};

const _$ValueTypeEnumMap = {
  ValueType.string: 'string',
  ValueType.int: 'int',
  ValueType.double: 'double',
  ValueType.bool: 'bool',
  ValueType.color: 'color',
  ValueType.paint: 'paint',
  ValueType.object: 'object',
};

IntValue _$IntValueFromJson(Map json) => IntValue(
  name: json['name'] as String,
  mode:
      $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
      SetValueMode.discrete,
  value: (json['value'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$IntValueToJson(IntValue instance) => <String, dynamic>{
  'name': instance.name,
  'mode': _$SetValueModeEnumMap[instance.mode]!,
  'value': instance.value,
  'type': _$ValueTypeEnumMap[instance.type]!,
};

DoubleValue _$DoubleValueFromJson(Map json) => DoubleValue(
  name: json['name'] as String,
  mode:
      $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
      SetValueMode.discrete,
  value: (json['value'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$DoubleValueToJson(DoubleValue instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': _$SetValueModeEnumMap[instance.mode]!,
      'value': instance.value,
      'type': _$ValueTypeEnumMap[instance.type]!,
    };

StringValue _$StringValueFromJson(Map json) => StringValue(
  name: json['name'] as String,
  mode:
      $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
      SetValueMode.discrete,
  value: json['value'] as String? ?? '',
);

Map<String, dynamic> _$StringValueToJson(StringValue instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': _$SetValueModeEnumMap[instance.mode]!,
      'value': instance.value,
      'type': _$ValueTypeEnumMap[instance.type]!,
    };

ObjectValue _$ObjectValueFromJson(Map json) => ObjectValue(
  name: json['name'] as String,
  mode:
      $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
      SetValueMode.syncValue,
  value: json['value'] ?? '',
);

Map<String, dynamic> _$ObjectValueToJson(ObjectValue instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': _$SetValueModeEnumMap[instance.mode]!,
      'value': ?instance.value,
      'type': _$ValueTypeEnumMap[instance.type]!,
    };

ColorValue _$ColorValueFromJson(Map json) => ColorValue(
  name: json['name'] as String,
  mode:
      $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
      SetValueMode.discrete,
  value: json['value'] == null ? null : ColorRGBA.fromJson(json['value']),
  nullable: json['nullable'] as bool? ?? false,
);

Map<String, dynamic> _$ColorValueToJson(ColorValue instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': _$SetValueModeEnumMap[instance.mode]!,
      'value': ?instance.value?.toJson(),
      'type': _$ValueTypeEnumMap[instance.type]!,
      'nullable': instance.nullable,
    };

PaintValue _$PaintValueFromJson(Map json) => PaintValue(
  name: json['name'] as String,
  mode:
      $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
      SetValueMode.discrete,
  value: json['value'] == null
      ? null
      : PaintModel.fromJson(json['value'] as Map),
  nullable: json['nullable'] as bool? ?? false,
);

Map<String, dynamic> _$PaintValueToJson(PaintValue instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': _$SetValueModeEnumMap[instance.mode]!,
      'value': ?instance.value?.toJson(),
      'type': _$ValueTypeEnumMap[instance.type]!,
      'nullable': instance.nullable,
    };
