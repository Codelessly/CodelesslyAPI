// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'set_cloud_storage_action.g.dart';

/// Represents an operation to perform on a data in cloud storage.
enum SetCloudStorageOperation {
  /// Adds a new document to the collection.
  addDocument,

  /// Updates an existing document in the collection.
  updateDocument,

  /// Removes an existing document from the collection.
  removeDocument;

  /// Displayable string representation of the [StorageOperation].
  String get label => switch (this) {
        SetCloudStorageOperation.addDocument => 'Add Document',
        SetCloudStorageOperation.updateDocument => 'Update Document',
        SetCloudStorageOperation.removeDocument => 'Remove Document',
      };

  /// Whether this [StorageOperation] is [addDocument].
  bool get isAddDocument => this == addDocument;

  /// Whether this [StorageOperation] is [updateDocument].
  bool get isUpdateDocument => this == updateDocument;

  /// Whether this [StorageOperation] is [removeDocument].
  bool get isRemoveDocument => this == removeDocument;
}

/// An action that changes data in cloud storage.
@JsonSerializable()
class SetCloudStorageAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// The sub action to perform. This can be one of [AddDocumentSubAction],
  /// [UpdateDocumentSubAction] or [RemoveDocumentSubAction].
  final SetCloudStorageSubAction subAction;

  /// Creates a new [SetCloudStorageAction].
  SetCloudStorageAction({
    required this.subAction,
  }) : super(type: ActionType.setCloudStorage);

  /// Duplicates this [SetCloudStorageAction] with given data overrides.
  SetCloudStorageAction copyWith({
    SetCloudStorageSubAction? subAction,
  }) =>
      SetCloudStorageAction(
        subAction: subAction ?? this.subAction,
      );

  @override
  List<Object?> get props => [subAction];

  /// Creates a new [SetCloudStorageAction] instance from a JSON data.
  factory SetCloudStorageAction.fromJson(Map json) =>
      _$SetCloudStorageActionFromJson(json);

  @override
  Map toJson() => _$SetCloudStorageActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitSetCloudStorageAction(this);
}

/// Represents a sub action to perform on a data in cloud storage.
sealed class SetCloudStorageSubAction with EquatableMixin, SerializableMixin {
  /// The operation to perform. Represents the type of the sub action.
  final SetCloudStorageOperation operation;

  /// Creates a new [SetCloudStorageSubAction].
  const SetCloudStorageSubAction({required this.operation});

  @override
  factory SetCloudStorageSubAction.fromJson(Map json) {
    final operation =
        SetCloudStorageOperation.values.byName(json['operation'].toString());
    return switch (operation) {
      SetCloudStorageOperation.addDocument =>
        AddDocumentSubAction.fromJson(json),
      SetCloudStorageOperation.updateDocument =>
        UpdateDocumentSubAction.fromJson(json),
      SetCloudStorageOperation.removeDocument =>
        RemoveDocumentSubAction.fromJson(json),
    };
  }
}

/// Represents a sub action to add a document to a collection in cloud storage.
@JsonSerializable()
class AddDocumentSubAction extends SetCloudStorageSubAction {
  /// Path to the collection where the document is located.
  ///
  /// A string that represents the path to the document excluding the document
  /// id. The path must always resolve to a collection. If the [path] is empty,
  /// then the document is added to "default" collection. If the path ends in
  /// a document path, then "default" is suffixed to the path to make it a
  /// collection path.
  final String path;

  /// The id of the document in the collection. If [documentId] is empty, then
  /// "default" is used as the document id. This is ignored if [autoGenerateId]
  /// is set to true.
  final String documentId;

  /// Whether to auto generate the document id. If this is set to true, then
  /// [documentId] is ignored and a random id is generated for the document
  /// instead.
  final bool autoGenerateId;

  /// Whether to skip creation of the document if it already exists. If this is
  /// set to true, then the document is not created if it already exists.
  final bool skipCreationIfDocumentExists;

  /// Holds a serialized value of the document to add. This represents the
  /// document data as a JSON string defined from the JSON editor in the
  /// action settings.
  ///
  /// This is ignored if [useRawValue] is set to false. [newValue] is
  /// used instead.
  final String rawValue;

  /// A value composed from provided key-value pairs serialized as a JSON
  /// string. This is used to create the document data. This is ignored if
  /// [useRawValue] is set to true. [rawValue] is used instead.
  final String newValue;

  /// Whether to use [rawValue] instead of [newValue] to create the document.
  final bool useRawValue;

  /// Creates a new [AddDocumentSubAction].
  const AddDocumentSubAction({
    this.path = '',
    this.documentId = '',
    this.autoGenerateId = false,
    this.skipCreationIfDocumentExists = true,
    this.newValue = '',
    this.rawValue = '',
    this.useRawValue = false,
  }) : super(operation: SetCloudStorageOperation.addDocument);

  /// Duplicates this [AddDocumentSubAction] with given data overrides.
  AddDocumentSubAction copyWith({
    String? path,
    String? documentId,
    bool? autoGenerateId,
    bool? skipCreationIfDocumentExists,
    String? newValue,
    String? rawValue,
    bool? useRawValue,
  }) {
    return AddDocumentSubAction(
      path: path ?? this.path,
      documentId: documentId ?? this.documentId,
      autoGenerateId: autoGenerateId ?? this.autoGenerateId,
      skipCreationIfDocumentExists:
          skipCreationIfDocumentExists ?? this.skipCreationIfDocumentExists,
      newValue: newValue ?? this.newValue,
      rawValue: rawValue ?? this.rawValue,
      useRawValue: useRawValue ?? this.useRawValue,
    );
  }

  /// Creates a new [AddDocumentSubAction] instance from a JSON data.
  factory AddDocumentSubAction.fromJson(Map json) =>
      _$AddDocumentSubActionFromJson(json);

  @override
  Map toJson() =>
      _$AddDocumentSubActionToJson(this)..['operation'] = operation.name;

  @override
  List<Object?> get props => [
        path,
        documentId,
        autoGenerateId,
        skipCreationIfDocumentExists,
        newValue,
        rawValue,
        useRawValue,
      ];
}

/// Represents a sub action to remove a document from a collection in cloud
/// storage.
@JsonSerializable()
class RemoveDocumentSubAction extends SetCloudStorageSubAction {
  /// Path to the collection where the document is located.
  ///
  /// A string that represents the path to the document excluding the document
  /// id. The path must always resolve to a collection. If the [path] is empty,
  /// then the document is added to "default" collection. If the path ends in
  /// a document path, then "default" is suffixed to the path to make it a
  /// collection path.
  final String path;

  /// The id of the document in the collection. If [documentId] is empty, then
  /// "default" is used as the document id. This is ignored if [autoGenerateId]
  /// is set to true.
  final String documentId;

  /// Creates a new [RemoveDocumentSubAction].
  const RemoveDocumentSubAction({
    this.path = '',
    this.documentId = '',
  }) : super(operation: SetCloudStorageOperation.removeDocument);

  /// Duplicates this [AddDocumentSubAction] with given data overrides.
  RemoveDocumentSubAction copyWith({
    String? path,
    String? documentId,
    bool? autoGenerateId,
    bool? skipCreationIfDocumentExists,
    String? value,
  }) {
    return RemoveDocumentSubAction(
      path: path ?? this.path,
      documentId: documentId ?? this.documentId,
    );
  }

  /// Creates a new [AddDocumentSubAction] instance from a JSON data.
  factory RemoveDocumentSubAction.fromJson(Map json) =>
      _$RemoveDocumentSubActionFromJson(json);

  @override
  Map toJson() =>
      _$RemoveDocumentSubActionToJson(this)..['operation'] = operation.name;

  @override
  List<Object?> get props => [path, documentId];
}

/// Represents a sub action to update a document in a collection in cloud
/// storage.
@JsonSerializable()
class UpdateDocumentSubAction extends SetCloudStorageSubAction
    implements DataOperationInterface {
  /// Path to the collection where the document is located.
  ///
  /// A string that represents the path to the document excluding the document
  /// id. The path must always resolve to a collection. If the [path] is empty,
  /// then the document is added to "default" collection. If the path ends in
  /// a document path, then "default" is suffixed to the path to make it a
  /// collection path.
  final String path;

  /// The id of the document in the collection. If [documentId] is empty, then
  /// "default" is used as the document id. This is ignored if [autoGenerateId]
  /// is set to true.
  final String documentId;

  /// Holds a serialized value of the document to add. This represents the
  /// document data as a JSON string defined from the JSON editor in the
  /// action settings.
  ///
  /// This is ignored if [useRawValue] is set to false. [newValue] is
  /// used instead.
  final String rawValue;

  /// Represents a key/field in the document to update. This is used to update
  /// a single field in the document.
  final String key;

  /// Represents the type of data the [key] field holds. This is used to better
  /// handle the data when updating the document.
  final VariableType variableType;

  /// Whether to use [rawValue] instead of [newValue] to create the document.
  final bool useRawValue;

  @override
  final String index;

  @override
  final ListOperation listOperation;

  @override
  final String mapKey;

  @override
  final MapOperation mapOperation;

  @override
  final String newValue;

  @override
  final bool toggled;

  @override
  final NumberOperation numberOperation;

  /// Creates a new [UpdateDocumentSubAction].
  const UpdateDocumentSubAction({
    this.path = '',
    this.documentId = '',
    this.rawValue = '',
    this.key = '',
    this.variableType = VariableType.text,
    this.index = '0',
    this.listOperation = ListOperation.replace,
    this.mapKey = 'key',
    this.mapOperation = MapOperation.replace,
    this.newValue = '',
    this.toggled = false,
    this.useRawValue = false,
    this.numberOperation = NumberOperation.set,
  }) : super(operation: SetCloudStorageOperation.updateDocument);

  /// Duplicates this [UpdateDocumentSubAction] with given data overrides.
  UpdateDocumentSubAction copyWith({
    String? path,
    String? documentId,
    bool? autoGenerateId,
    bool? skipCreationIfDocumentExists,
    String? rawValue,
    String? key,
    VariableType? variableType,
    String? index,
    ListOperation? listOperation,
    String? mapKey,
    MapOperation? mapOperation,
    String? newValue,
    bool? toggled,
    bool? useRawValue,
    NumberOperation? numberOperation,
  }) {
    return UpdateDocumentSubAction(
      path: path ?? this.path,
      documentId: documentId ?? this.documentId,
      rawValue: rawValue ?? this.rawValue,
      key: key ?? this.key,
      variableType: variableType ?? this.variableType,
      index: index ?? this.index,
      listOperation: listOperation ?? this.listOperation,
      mapKey: mapKey ?? this.mapKey,
      mapOperation: mapOperation ?? this.mapOperation,
      newValue: newValue ?? this.newValue,
      toggled: toggled ?? this.toggled,
      useRawValue: useRawValue ?? this.useRawValue,
      numberOperation: numberOperation ?? this.numberOperation,
    );
  }

  /// Creates a new [UpdateDocumentSubAction] instance from a JSON data.
  factory UpdateDocumentSubAction.fromJson(Map json) =>
      _$UpdateDocumentSubActionFromJson(json);

  @override
  Map toJson() =>
      _$UpdateDocumentSubActionToJson(this)..['operation'] = operation.name;

  @override
  List<Object?> get props => [
        path,
        documentId,
        rawValue,
        key,
        variableType,
        index,
        listOperation,
        mapKey,
        mapOperation,
        newValue,
        toggled,
        useRawValue,
        numberOperation,
      ];
}
