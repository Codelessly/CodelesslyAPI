import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_defaults.dart';
import '../mixins.dart';

part 'collection_schema.g.dart';

/// The type of a field of a cloud database collection.
enum SchemaFieldType {
  /// Text.
  text('Text'),

  /// A whole or decimal number.
  number('Number'),

  /// Yes or no.
  boolean('Yes / No'),

  /// A date and time, stored as a Firestore timestamp.
  date('Date'),

  /// The URL of an image.
  image('Image'),

  /// The URL of a file.
  file('File'),

  /// The id of a document in another collection
  /// ([SchemaField.referenceCollection]).
  reference('Reference'),

  /// A list of values.
  list('List'),

  /// A map of values.
  object('Object');

  /// The name shown to builders.
  final String label;

  const SchemaFieldType(this.label);
}

/// A field of a cloud database collection.
@JsonSerializable()
class SchemaField with Equatable, SerializableMixin {
  /// The field's name in the document.
  final String name;

  /// What the field holds.
  final SchemaFieldType type;

  /// Whether creating a document needs a value for it (or its
  /// [defaultValue]).
  @JsonKey(defaultValue: false)
  final bool required;

  /// The value a new document gets when none is given, as text: `true`,
  /// `12`, `now` for a date, or plain text.
  final String? defaultValue;

  /// For a [SchemaFieldType.reference], the collection its documents are in.
  final String? referenceCollection;

  /// Creates a [SchemaField].
  const SchemaField({
    required this.name,
    this.type = SchemaFieldType.text,
    this.required = false,
    this.defaultValue,
    this.referenceCollection,
  });

  /// Duplicates this field with the given values replaced.
  SchemaField copyWith({
    String? name,
    SchemaFieldType? type,
    bool? required,
    String? defaultValue,
    String? referenceCollection,
  }) => SchemaField(
    name: name ?? this.name,
    type: type ?? this.type,
    required: required ?? this.required,
    defaultValue: defaultValue ?? this.defaultValue,
    referenceCollection: referenceCollection ?? this.referenceCollection,
  );

  @override
  List<Object?> get props => [
    name,
    type,
    required,
    defaultValue,
    referenceCollection,
  ];

  /// Creates a [SchemaField] from JSON.
  factory SchemaField.fromJson(Map json) => _$SchemaFieldFromJson(json);

  @override
  Map toJson() => _$SchemaFieldOmitDefaults(this, _$SchemaFieldToJson(this));
}

/// The fields of a cloud database collection, defined in the editor's Data
/// panel. Forms, the binding picker and the cloud data actions read it; the
/// SDK fills defaults and converts values to the field types on writes.
@JsonSerializable()
class CollectionSchema with Equatable, SerializableMixin {
  /// The collection's name (its top-level path).
  final String name;

  /// The collection's fields, in the order they are shown.
  @JsonKey(defaultValue: [])
  final List<SchemaField> fields;

  /// Creates a [CollectionSchema].
  const CollectionSchema({required this.name, this.fields = const []});

  /// The field named [name], if any.
  SchemaField? field(String name) {
    for (final SchemaField field in fields) {
      if (field.name == name) return field;
    }
    return null;
  }

  /// Duplicates this schema with the given values replaced.
  CollectionSchema copyWith({String? name, List<SchemaField>? fields}) =>
      CollectionSchema(name: name ?? this.name, fields: fields ?? this.fields);

  @override
  List<Object?> get props => [name, fields];

  /// Creates a [CollectionSchema] from JSON.
  factory CollectionSchema.fromJson(Map json) =>
      _$CollectionSchemaFromJson(json);

  @override
  Map toJson() =>
      _$CollectionSchemaOmitDefaults(this, _$CollectionSchemaToJson(this));
}
