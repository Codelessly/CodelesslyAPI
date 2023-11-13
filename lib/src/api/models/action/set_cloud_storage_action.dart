// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'set_cloud_storage_action.g.dart';

/// Represents an operation to perform on a data in storage.
enum CloudStorageOperation {
  /// Remove the data from storage.
  remove,

  /// Add or update the data in storage.
  addOrUpdate,

  /// Clear all data from storage.
  clear;

  /// Displayable string representation of the [StorageOperation].
  String get label => switch (this) {
    CloudStorageOperation.addOrUpdate => 'Add/Update',
    CloudStorageOperation.remove => 'Remove',
    CloudStorageOperation.clear => 'Clear',
      };

  /// Whether the operation is [CloudStorageOperation.remove].
  bool get isRemove => this == CloudStorageOperation.remove;

  /// Whether the operation is [CloudStorageOperation.clear].
  bool get isClear => this == CloudStorageOperation.clear;

  /// Whether the operation is [CloudStorageOperation.addOrUpdate].
  bool get isAddOrUpdate => this == CloudStorageOperation.addOrUpdate;
}

/// An action that sets value of a variable.
@JsonSerializable()
class SetCloudStorageAction extends DataOperationActionModel
    with EquatableMixin, SerializableMixin {
  /// Key of the data in storage.
  final String key;

  /// Operation to perform on the data.
  final CloudStorageOperation operation;

  /// Type of the variable.
  /// This is used to convert the value to the correct type.
  final VariableType variableType;

  /// Creates a new [SetCloudStorageAction].
  SetCloudStorageAction({
    this.key = 'key',
    this.operation = CloudStorageOperation.addOrUpdate,
    this.variableType = VariableType.text,
    super.newValue = '',
    super.toggled = false,
    super.listOperation = ListOperation.replace,
    super.index = '0',
    super.mapOperation = MapOperation.replace,
    super.mapKey = 'key',
  }) : super(type: ActionType.setCloudStorage);

  /// Duplicates this [SetCloudStorageAction] with given data overrides.
  SetCloudStorageAction copyWith({
    String? key,
    CloudStorageOperation? operation,
    VariableType? variableType,
    String? newValue,
    bool? toggled,
    ListOperation? listOperation,
    String? index,
    MapOperation? mapOperation,
    String? mapKey,
  }) {
    // final String? sanitizedValue = value == null
    //     ? null
    //     : sanitizeValueForVariableType(
    //         value, variableType ?? this.variableType);
    return SetCloudStorageAction(
      key: key ?? this.key,
      operation: operation ?? this.operation,
      variableType: variableType ?? this.variableType,
      newValue: newValue ?? this.newValue,
      toggled: toggled ?? this.toggled,
      listOperation: listOperation ?? this.listOperation,
      index: index ?? this.index,
      mapOperation: mapOperation ?? this.mapOperation,
      mapKey: mapKey ?? this.mapKey,
    );
  }

  @override
  List<Object?> get props => [
        key,
        operation,
        variableType,
        newValue,
        toggled,
        listOperation,
        index,
        mapOperation,
        mapKey,
      ];

  /// Creates a new [SetCloudStorageAction] instance from a JSON data.
  factory SetCloudStorageAction.fromJson(Map json) =>
      _$SetCloudStorageActionFromJson(json);

  @override
  Map toJson() => _$SetCloudStorageActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSetCloudStorageAction(this);
}
