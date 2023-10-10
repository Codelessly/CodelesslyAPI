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
};

CanvasVariables _$CanvasVariablesFromJson(Map json) => CanvasVariables(
      id: json['id'] as String,
      variables: (json['variables'] as Map).map(
        (k, e) => MapEntry(k as String,
            CanvasVariableData.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      lastUpdated:
          const DateTimeConverter().fromJson(json['lastUpdated'] as int?),
      projectId: json['project'] as String,
      owner: json['owner'] as String,
    );

Map<String, dynamic> _$CanvasVariablesToJson(CanvasVariables instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'variables': instance.variables.map((k, e) => MapEntry(k, e.toJson())),
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('lastUpdated', instance.lastUpdated,
      const DateTimeConverter().toJson(instance.lastUpdated), null);
  val['owner'] = instance.owner;
  val['project'] = instance.projectId;
  return val;
}

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
