// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_target.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$FieldTargetToJson(FieldTarget instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('stringify', instance.stringify, instance.stringify, null);
  val['hashCode'] = instance.hashCode;
  val['label'] = instance.label;
  val['description'] = instance.description;
  val['type'] = instance.type;
  return val;
}

SingleFieldTarget _$SingleFieldTargetFromJson(Map json) => SingleFieldTarget(
      label: json['label'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      target: json['target'] as String,
      defaultValue: json['defaultValue'],
    );

Map<String, dynamic> _$SingleFieldTargetToJson(SingleFieldTarget instance) {
  final val = <String, dynamic>{
    'label': instance.label,
    'description': instance.description,
    'type': instance.type,
    'target': instance.target,
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
      'defaultValue', instance.defaultValue, instance.defaultValue, null);
  return val;
}

MultiFieldTarget _$MultiFieldTargetFromJson(Map json) => MultiFieldTarget(
      label: json['label'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      targets:
          (json['targets'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MultiFieldTargetToJson(MultiFieldTarget instance) =>
    <String, dynamic>{
      'label': instance.label,
      'description': instance.description,
      'type': instance.type,
      'targets': instance.targets,
    };

GroupOfFieldTargets _$GroupOfFieldTargetsFromJson(Map json) =>
    GroupOfFieldTargets(
      label: json['label'] as String,
      description: json['description'] as String,
      properties: (json['properties'] as List<dynamic>)
          .map((e) => FieldTarget.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$GroupOfFieldTargetsToJson(
        GroupOfFieldTargets instance) =>
    <String, dynamic>{
      'label': instance.label,
      'description': instance.description,
      'properties': instance.properties.map((e) => e.toJson()).toList(),
    };
