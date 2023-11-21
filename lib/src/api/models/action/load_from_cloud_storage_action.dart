// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'load_from_cloud_storage_action.g.dart';

/// An action that loads data from cloud storage.
@JsonSerializable()
class LoadFromCloudStorageAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  final String path;
  final String documentId;
  final VariableData? variable;

  /// Creates a new [LoadFromCloudStorageAction].
  LoadFromCloudStorageAction({
    this.path = '',
    this.documentId = '',
    this.variable,
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