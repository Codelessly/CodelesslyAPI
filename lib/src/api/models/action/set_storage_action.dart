// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'set_storage_action.g.dart';

/// Represents an operation to perform on a data in storage.
enum StorageOperation {
  /// Remove the data from storage.
  remove,

  /// Add or update the data in storage.
  addOrUpdate;

  /// Displayable string representation of the [StorageOperation].
  String get label => switch (this) {
        StorageOperation.addOrUpdate => 'Add/Update',
        StorageOperation.remove => 'Remove',
      };
}

/// An action that sets value of a variable.
@JsonSerializable()
class SetStorageAction extends DataOperationActionModel
    with EquatableMixin, SerializableMixin {
  /// Key of the data in storage.
  final String key;

  /// Operation to perform on the data.
  final StorageOperation operation;

  /// Type of the variable.
  /// This is used to convert the value to the correct type.
  final VariableType variableType;

  /// Creates a new [SetValueAction].
  SetStorageAction({
    this.key = 'key',
    this.operation = StorageOperation.addOrUpdate,
    this.variableType = VariableType.text,
    super.newValue = '',
    super.toggled = false,
    super.listOperation = ListOperation.replace,
    super.index = '0',
    super.mapOperation = MapOperation.replace,
    super.mapKey = 'key',
  }) : super(type: ActionType.setStorage);

  /// Duplicates this [SetStorageAction] with given data overrides.
  SetStorageAction copyWith({
    String? key,
    StorageOperation? operation,
    VariableType? variableType,
    String? value,
    bool? toggled,
    ListOperation? listOperation,
    String? index,
    MapOperation? mapOperation,
    String? mapKey,
  }) {
    final String? sanitizedValue = value == null
        ? null
        : sanitizeValueForVariableType(
            value, variableType ?? this.variableType);
    return SetStorageAction(
      key: key ?? this.key,
      operation: operation ?? this.operation,
      variableType: variableType ?? this.variableType,
      newValue: sanitizedValue ?? newValue,
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

  /// Creates a new [SetStorageAction] instance from a JSON data.
  factory SetStorageAction.fromJson(Map json) =>
      _$SetStorageActionFromJson(json);

  @override
  Map toJson() => _$SetStorageActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSetStorageAction(this);
}
