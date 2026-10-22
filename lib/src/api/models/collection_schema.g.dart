// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_schema.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SchemaFieldOmitDefaults(
  SchemaField instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.type, SchemaFieldType.text)) json.remove('type');
  if (isJsonDefault(instance.required, false)) json.remove('required');
  return json;
}

Map<String, dynamic> _$CollectionSchemaOmitDefaults(
  CollectionSchema instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.fields, [])) json.remove('fields');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchemaField _$SchemaFieldFromJson(Map json) => SchemaField(
  name: json['name'] as String,
  type:
      $enumDecodeNullable(_$SchemaFieldTypeEnumMap, json['type']) ??
      SchemaFieldType.text,
  required: json['required'] as bool? ?? false,
  defaultValue: json['defaultValue'] as String?,
  referenceCollection: json['referenceCollection'] as String?,
);

Map<String, dynamic> _$SchemaFieldToJson(SchemaField instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$SchemaFieldTypeEnumMap[instance.type]!,
      'required': instance.required,
      'defaultValue': ?instance.defaultValue,
      'referenceCollection': ?instance.referenceCollection,
    };

const _$SchemaFieldTypeEnumMap = {
  SchemaFieldType.text: 'text',
  SchemaFieldType.number: 'number',
  SchemaFieldType.boolean: 'boolean',
  SchemaFieldType.date: 'date',
  SchemaFieldType.image: 'image',
  SchemaFieldType.file: 'file',
  SchemaFieldType.reference: 'reference',
  SchemaFieldType.list: 'list',
  SchemaFieldType.object: 'object',
};

CollectionSchema _$CollectionSchemaFromJson(Map json) => CollectionSchema(
  name: json['name'] as String,
  fields:
      (json['fields'] as List<dynamic>?)
          ?.map((e) => SchemaField.fromJson(e as Map))
          .toList() ??
      [],
);

Map<String, dynamic> _$CollectionSchemaToJson(CollectionSchema instance) =>
    <String, dynamic>{
      'name': instance.name,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
    };
