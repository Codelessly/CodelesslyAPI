// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variables_model.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$VariableDataOmitDefaults(
  VariableData instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.value, '')) json.remove('value');
  if (isJsonDefault(instance.type, VariableType.text)) json.remove('type');
  if (isJsonDefault(instance.extra, {})) json.remove('extra');
  if (isJsonDefault(instance.formula, '')) json.remove('formula');
  if (isJsonDefault(instance.parameters, <String>[])) json.remove('parameters');
  return json;
}

Map<String, dynamic> _$CanvasVariableDataOmitDefaults(
  CanvasVariableData instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.value, '')) json.remove('value');
  if (isJsonDefault(instance.type, VariableType.text)) json.remove('type');
  if (isJsonDefault(instance.formula, '')) json.remove('formula');
  if (isJsonDefault(instance.parameters, <String>[])) json.remove('parameters');
  return json;
}

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
  formula: json['formula'] as String? ?? '',
  parameters:
      (json['parameters'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$VariableDataToJson(VariableData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'type': _$VariableTypeEnumMap[instance.type]!,
      'extra': instance.extra,
      'formula': instance.formula,
      'parameters': instance.parameters,
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
  VariableType.choice: 'choice',
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
  formula: json['formula'] as String? ?? '',
  parameters:
      (json['parameters'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$CanvasVariableDataToJson(CanvasVariableData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'type': _$VariableTypeEnumMap[instance.type]!,
      'extra': instance.extra,
      'formula': instance.formula,
      'parameters': instance.parameters,
      'canvasId': instance.canvasId,
    };
