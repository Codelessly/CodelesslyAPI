// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variables_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VariableData _$VariableDataFromJson(Map json) => VariableData(
  id: json['id'] as String,
  name: json['name'] as String,
  value: json['value'] ?? '',
  type:
      $enumDecodeNullable(
        _$VariableTypeEnumMap,
        json['type'],
        unknownValue: VariableType.text,
      ) ??
      VariableType.text,
  extra: (json['extra'] as Map?)?.map((k, e) => MapEntry(k as String, e)),
);

Map<String, dynamic> _$VariableDataToJson(VariableData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'type': _$VariableTypeEnumMap[instance.type]!,
      'extra': instance.extra,
    };

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
  type:
      $enumDecodeNullable(
        _$VariableTypeEnumMap,
        json['type'],
        unknownValue: VariableType.text,
      ) ??
      VariableType.text,
  value: json['value'] ?? '',
  extra: (json['extra'] as Map?)?.map((k, e) => MapEntry(k as String, e)),
);

Map<String, dynamic> _$CanvasVariableDataToJson(CanvasVariableData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'type': _$VariableTypeEnumMap[instance.type]!,
      'extra': instance.extra,
      'canvasId': instance.canvasId,
    };
