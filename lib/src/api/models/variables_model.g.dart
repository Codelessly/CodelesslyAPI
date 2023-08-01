// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variables_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VariableData _$VariableDataFromJson(Map json) => VariableData(
      id: json['id'] as String,
      name: json['name'] as String,
      value: json['value'] as String? ?? '',
      type: $enumDecodeNullable(_$VariableTypeEnumMap, json['type'],
              unknownValue: VariableType.text) ??
          VariableType.text,
    );

Map<String, dynamic> _$VariableDataToJson(VariableData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'type': _$VariableTypeEnumMap[instance.type]!,
    };

const _$VariableTypeEnumMap = {
  VariableType.integer: 'integer',
  VariableType.text: 'text',
  VariableType.decimal: 'decimal',
  VariableType.boolean: 'boolean',
  VariableType.color: 'color',
  VariableType.list: 'list',
  VariableType.map: 'map',
};

CanvasVariables _$CanvasVariablesFromJson(Map json) => CanvasVariables(
      id: json['id'] as String,
      variables: (json['variables'] as Map).map(
        (k, e) => MapEntry(k as String,
            CanvasVariableData.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      lastUpdated: jsonToDate(json['lastUpdated'] as int?),
      projectId: json['project'] as String,
      owner: json['owner'] as String,
    );

Map<String, dynamic> _$CanvasVariablesToJson(CanvasVariables instance) =>
    <String, dynamic>{
      'id': instance.id,
      'variables': instance.variables.map((k, e) => MapEntry(k, e.toJson())),
      'lastUpdated': dateToJson(instance.lastUpdated),
      'owner': instance.owner,
      'project': instance.projectId,
    };

CanvasVariableData _$CanvasVariableDataFromJson(Map json) => CanvasVariableData(
      id: json['id'] as String,
      canvasId: json['canvasId'] as String,
      name: json['name'] as String,
      type: $enumDecodeNullable(_$VariableTypeEnumMap, json['type'],
              unknownValue: VariableType.text) ??
          VariableType.text,
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$CanvasVariableDataToJson(CanvasVariableData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'type': _$VariableTypeEnumMap[instance.type]!,
      'canvasId': instance.canvasId,
    };
