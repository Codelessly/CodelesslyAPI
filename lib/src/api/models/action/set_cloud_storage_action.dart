// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'set_cloud_storage_action.g.dart';

/// Represents an operation to perform on a data in storage.
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

  bool get isAddDocument => this == addDocument;

  bool get isUpdateDocument => this == updateDocument;

  bool get isRemoveDocument => this == removeDocument;
}

/// An action that sets value of a variable.
@JsonSerializable()
class SetCloudStorageAction extends ActionModel
    with EquatableMixin, SerializableMixin {
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

sealed class SetCloudStorageSubAction with EquatableMixin, SerializableMixin {
  final SetCloudStorageOperation operation;

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

@JsonSerializable()
class AddDocumentSubAction extends SetCloudStorageSubAction {
  final String path;
  final String documentId;
  final bool autoGenerateId;
  final bool skipCreationIfDocumentExists;
  final String rawValue;
  final String newValue;
  final bool useRawValue;

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
  Map toJson() => _$AddDocumentSubActionToJson(this)..['operation'] = operation.name;

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

@JsonSerializable()
class RemoveDocumentSubAction extends SetCloudStorageSubAction {
  final String path;
  final String documentId;

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
  Map toJson() => _$RemoveDocumentSubActionToJson(this)..['operation'] = operation.name;

  @override
  List<Object?> get props => [
        path,
        documentId,
      ];
}

@JsonSerializable()
class UpdateDocumentSubAction extends SetCloudStorageSubAction
    implements DataOperationInterface {
  final String path;
  final String documentId;
  final String rawValue;
  final String key;
  final VariableType variableType;

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
  }) : super(operation: SetCloudStorageOperation.updateDocument);

  /// Duplicates this [AddDocumentSubAction] with given data overrides.
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
    );
  }

  /// Creates a new [AddDocumentSubAction] instance from a JSON data.
  factory UpdateDocumentSubAction.fromJson(Map json) =>
      _$UpdateDocumentSubActionFromJson(json);

  @override
  Map toJson() => _$UpdateDocumentSubActionToJson(this)..['operation'] = operation.name;

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
      ];
}
