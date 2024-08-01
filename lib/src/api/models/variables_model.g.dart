// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variables_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VariableData _$VariableDataFromJson(Map json) => VariableData(
      id: json['id'] as String,
      name: json['name'] as String,
      value: json['value'] ?? '',
      type: $enumDecodeNullable(_$VariableTypeEnumMap, json['type'],
              unknownValue: VariableType.text) ??
          VariableType.text,
    );

Map<String, dynamic> _$VariableDataToJson(VariableData instance) {
  final val = <String, dynamic>{
    'id': instance.id,
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

  writeNotNull('value', instance.value, instance.value, '');
  writeNotNull('type', instance.type, _$VariableTypeEnumMap[instance.type]!,
      VariableType.text);
  return val;
}

const _$VariableTypeEnumMap = {
  VariableType.integer: 'integer',
  VariableType.text: 'text',
  VariableType.decimal: 'decimal',
  VariableType.boolean: 'boolean',
  VariableType.color: 'color',
  VariableType.list: 'list',
  VariableType.map: 'map',
  VariableType.image: 'image',
};

CanvasVariableData _$CanvasVariableDataFromJson(Map json) => CanvasVariableData(
      id: json['id'] as String,
      canvasId: json['canvasId'] as String,
      name: json['name'] as String,
      type: $enumDecodeNullable(_$VariableTypeEnumMap, json['type'],
              unknownValue: VariableType.text) ??
          VariableType.text,
      value: json['value'] ?? '',
    );

Map<String, dynamic> _$CanvasVariableDataToJson(CanvasVariableData instance) {
  final val = <String, dynamic>{
    'id': instance.id,
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

  writeNotNull('value', instance.value, instance.value, '');
  writeNotNull('type', instance.type, _$VariableTypeEnumMap[instance.type]!,
      VariableType.text);
  val['canvasId'] = instance.canvasId;
  return val;
}
