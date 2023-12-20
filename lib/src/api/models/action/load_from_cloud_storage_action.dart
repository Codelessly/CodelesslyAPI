// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'load_from_cloud_storage_action.g.dart';

/// An action that loads data from cloud storage. This is primarily used to
/// load data from Firestore on canvas load.
@JsonSerializable()
class LoadFromCloudStorageAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// Path to the collection to load data from.
  ///
  /// A string that represents the path to the document excluding the document
  /// id. The path must always resolve to a collection. If the [path] is empty,
  /// then the document is added to "default" collection. If the path ends in
  /// a document path, then "default" is suffixed to the path to make it a
  /// collection path.
  final String path;

  /// The id of the document in the collection. If [documentId] is empty, then
  /// "default" is used as the document id.
  final String documentId;

  /// The variable to store the loaded data in. The variable must be of type
  /// [VariableType.map]. This variable will be updated with the new data
  /// whenever the data on cloud storage changes.
  final VariableData? variable;

  /// Creates a new [LoadFromCloudStorageAction].
  LoadFromCloudStorageAction({
    this.path = '',
    this.documentId = '',
    this.variable,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.loadFromCloudStorage);

  /// Duplicates this [LoadFromCloudStorageAction] with given data overrides.
  LoadFromCloudStorageAction copyWith({
    String? path,
    String? documentId,
    VariableData? variable,
  }) =>
      LoadFromCloudStorageAction(
        path: path ?? this.path,
        documentId: documentId ?? this.documentId,
        variable: variable ?? this.variable,
      );

  @override
  List<Object?> get props => [path, documentId, variable];

  /// Creates a new [LoadFromCloudStorageAction] instance from a JSON data.
  factory LoadFromCloudStorageAction.fromJson(Map json) =>
      _$LoadFromCloudStorageActionFromJson(json);

  @override
  Map toJson() => _$LoadFromCloudStorageActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitLoadFromCloudStorageAction(this);
}
