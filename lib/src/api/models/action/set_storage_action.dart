// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'set_storage_action.g.dart';

/// Represents an operation to perform on a data in storage.
enum StorageOperation {
  /// Remove the data from storage.
  remove,

  /// Add or update the data in storage.
  addOrUpdate,

  /// Clear all data from storage.
  clear;

  /// Displayable string representation of the [StorageOperation].
  String get label => switch (this) {
        StorageOperation.addOrUpdate => 'Add/Update',
        StorageOperation.remove => 'Remove',
        StorageOperation.clear => 'Clear',
      };

  /// Whether the operation is [StorageOperation.remove].
  bool get isRemove => this == StorageOperation.remove;

  /// Whether the operation is [StorageOperation.clear].
  bool get isClear => this == StorageOperation.clear;

  /// Whether the operation is [StorageOperation.addOrUpdate].
  bool get isAddOrUpdate => this == StorageOperation.addOrUpdate;
}

/// An action that sets value of a variable.
@JsonSerializable()
class SetStorageAction extends ActionModel
    with EquatableMixin, SerializableMixin
    implements DataOperationInterface {
  /// Key of the data in storage.
  final String key;

  /// Operation to perform on the data.
  final StorageOperation operation;

  /// Type of the variable.
  /// This is used to convert the value to the correct type.
  final VariableType variableType;

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

  /// Whether to skip the operation if the [key] already exists in storage.
  final bool skipIfAlreadyExists;

  /// Creates a new [SetStorageAction].
  SetStorageAction({
    this.key = 'key',
    this.operation = StorageOperation.addOrUpdate,
    this.variableType = VariableType.text,
    this.newValue = '',
    this.toggled = false,
    this.listOperation = ListOperation.replace,
    this.index = '0',
    this.mapOperation = MapOperation.replace,
    this.mapKey = 'key',
    this.numberOperation = NumberOperation.set,
    this.skipIfAlreadyExists = false,
  }) : super(type: ActionType.setStorage);

  /// Duplicates this [SetStorageAction] with given data overrides.
  SetStorageAction copyWith({
    String? key,
    StorageOperation? operation,
    VariableType? variableType,
    String? newValue,
    bool? toggled,
    ListOperation? listOperation,
    String? index,
    MapOperation? mapOperation,
    String? mapKey,
    NumberOperation? numberOperation,
    bool? skipIfAlreadyExists,
  }) {
    // final String? sanitizedValue = value == null
    //     ? null
    //     : sanitizeValueForVariableType(
    //         value, variableType ?? this.variableType);
    return SetStorageAction(
      key: key ?? this.key,
      operation: operation ?? this.operation,
      variableType: variableType ?? this.variableType,
      newValue: newValue ?? this.newValue,
      toggled: toggled ?? this.toggled,
      listOperation: listOperation ?? this.listOperation,
      index: index ?? this.index,
      mapOperation: mapOperation ?? this.mapOperation,
      mapKey: mapKey ?? this.mapKey,
      numberOperation: numberOperation ?? this.numberOperation,
      skipIfAlreadyExists: skipIfAlreadyExists ?? this.skipIfAlreadyExists,
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
        numberOperation,
        skipIfAlreadyExists,
      ];

  /// Creates a new [SetStorageAction] instance from a JSON data.
  factory SetStorageAction.fromJson(Map json) =>
      _$SetStorageActionFromJson(json);

  @override
  Map toJson() => _$SetStorageActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSetStorageAction(this);
}
