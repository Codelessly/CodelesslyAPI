// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_value_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetValueAction _$SetValueActionFromJson(Map json) => SetValueAction(
      nodeID: json['nodeID'] as String,
      values: valuesFromJson(json['values'] as List),
      nonBlocking: json['nonBlocking'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetValueActionToJson(SetValueAction instance) {
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
  val['nodeID'] = instance.nodeID;
  val['values'] = instance.values.map((e) => e.toJson()).toList();
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
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('mode', instance.mode, _$SetValueModeEnumMap[instance.mode]!,
      SetValueMode.discrete);
  writeNotNull('value', instance.value, instance.value, false);
  val['type'] = _$ValueTypeEnumMap[instance.type]!;
  writeNotNull('nullable', instance.nullable, instance.nullable, false);
  return val;
}

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
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: (json['value'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$IntValueToJson(IntValue instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('mode', instance.mode, _$SetValueModeEnumMap[instance.mode]!,
      SetValueMode.discrete);
  writeNotNull('value', instance.value, instance.value, 0);
  val['type'] = _$ValueTypeEnumMap[instance.type]!;
  return val;
}

DoubleValue _$DoubleValueFromJson(Map json) => DoubleValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$DoubleValueToJson(DoubleValue instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('mode', instance.mode, _$SetValueModeEnumMap[instance.mode]!,
      SetValueMode.discrete);
  writeNotNull('value', instance.value, instance.value, 0);
  val['type'] = _$ValueTypeEnumMap[instance.type]!;
  return val;
}

StringValue _$StringValueFromJson(Map json) => StringValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$StringValueToJson(StringValue instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('mode', instance.mode, _$SetValueModeEnumMap[instance.mode]!,
      SetValueMode.discrete);
  writeNotNull('value', instance.value, instance.value, '');
  val['type'] = _$ValueTypeEnumMap[instance.type]!;
  return val;
}

ObjectValue _$ObjectValueFromJson(Map json) => ObjectValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.syncValue,
      value: json['value'] ?? '',
    );

Map<String, dynamic> _$ObjectValueToJson(ObjectValue instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('mode', instance.mode, _$SetValueModeEnumMap[instance.mode]!,
      SetValueMode.syncValue);
  writeNotNull('value', instance.value, instance.value, '');
  val['type'] = _$ValueTypeEnumMap[instance.type]!;
  return val;
}

ColorValue _$ColorValueFromJson(Map json) => ColorValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: json['value'] == null ? null : ColorRGBA.fromJson(json['value']),
      nullable: json['nullable'] as bool? ?? false,
    );

Map<String, dynamic> _$ColorValueToJson(ColorValue instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('mode', instance.mode, _$SetValueModeEnumMap[instance.mode]!,
      SetValueMode.discrete);
  writeNotNull('value', instance.value, instance.value?.toJson(), null);
  val['type'] = _$ValueTypeEnumMap[instance.type]!;
  writeNotNull('nullable', instance.nullable, instance.nullable, false);
  return val;
}

PaintValue _$PaintValueFromJson(Map json) => PaintValue(
      name: json['name'] as String,
      mode: $enumDecodeNullable(_$SetValueModeEnumMap, json['mode']) ??
          SetValueMode.discrete,
      value: json['value'] == null
          ? null
          : PaintModel.fromJson(json['value'] as Map),
      nullable: json['nullable'] as bool? ?? false,
    );

Map<String, dynamic> _$PaintValueToJson(PaintValue instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('mode', instance.mode, _$SetValueModeEnumMap[instance.mode]!,
      SetValueMode.discrete);
  writeNotNull('value', instance.value, instance.value?.toJson(), null);
  val['type'] = _$ValueTypeEnumMap[instance.type]!;
  writeNotNull('nullable', instance.nullable, instance.nullable, false);
  return val;
}
