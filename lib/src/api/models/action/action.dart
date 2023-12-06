// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import '../../mixins.dart';
import '../models.dart';

/// Type of the action to perform on a user interaction.
enum ActionType {
  /// Navigate to a page.
  navigation,

  /// Show a dialog.
  showDialog,

  /// Open a link.
  link,

  /// Submit form.
  submit,

  /// Set a value.
  setValue,

  /// Set a variant.
  setVariant,

  /// Set a variable.
  setVariable,

  /// Call a custom function.
  callFunction,

  /// Call an API.
  callApi,

  /// Update data in local storage.
  setStorage,

  /// Update data in cloud storage.
  setCloudStorage,

  /// Load data from cloud storage.
  loadFromCloudStorage;

  /// Displayable string representation of the [ActionType].
  String get prettify {
    switch (this) {
      case ActionType.navigation:
        return 'Navigation';
      case ActionType.link:
        return 'Link';
      case ActionType.submit:
        return 'Submit';
      case ActionType.setValue:
        return 'Set Value';
      case ActionType.setVariant:
        return 'Set Variant';
      case ActionType.setVariable:
        return 'Set Variable';
      case ActionType.callFunction:
        return 'Call Function';
      case ActionType.callApi:
        return 'Call API';
      case ActionType.setStorage:
        return 'Set Storage';
      case ActionType.showDialog:
        return 'Show Dialog';
      case ActionType.setCloudStorage:
        return 'Set Cloud Storage';
      case ActionType.loadFromCloudStorage:
        return 'Load from Cloud Storage';
    }
  }
}

/// The [ActionModel] class is a representation of an interactive action
/// that a program can execute based on a user's interaction.
///
/// Each [ActionModel] instance contains a specific [ActionType], which
/// determines the type of action that needs to be performed.
///
/// The class supports serialization and deserialization from JSON,
/// allowing for easy storage, retrieval, and transmission of action data.
///
/// It is an abstract class, meant to be subclassed for specific types of actions.
/// The specific action classes are determined by the [ActionType] enumeration.
///
/// This class also implements the Visitor pattern via the [accept] method.
/// This allows for type-specific computations or actions to be performed
/// on an [ActionModel] instance without the need for type checking or casting.
///
/// For example, the [ActionModel] class can represent various types of actions
/// such as navigation, link, submit, setValue, setVariant, setVariable,
/// callFunction, and callApi. Each of these action types can be handled
/// differently based on the requirements of the application.
///
/// This design provides a flexible and extensible way to manage actions
/// in response to user interactions.
abstract class ActionModel with SerializableMixin {
  /// Type of the action.
  ActionType type;

  /// Whether the action is non-blocking.
  bool nonBlocking = false;

  /// Creates an [ActionModel] with the given data.
  ActionModel({required this.type, this.nonBlocking = false});

  /// Factory constructor for creating a new [ActionModel] instance from
  /// JSON data.
  factory ActionModel.fromJson(Map json) {
    final ActionType type = ActionType.values.byName(json['type']);
    switch (type) {
      case ActionType.navigation:
        return NavigationAction.fromJson(json);
      case ActionType.link:
        return LinkAction.fromJson(json);
      case ActionType.submit:
        return SubmitAction.fromJson(json);
      case ActionType.setValue:
        return SetValueAction.fromJson(json);
      case ActionType.setVariant:
        return SetVariantAction.fromJson(json);
      case ActionType.setVariable:
        return SetVariableAction.fromJson(json);
      case ActionType.callFunction:
        return CallFunctionAction.fromJson(json);
      case ActionType.callApi:
        return ApiCallAction.fromJson(json);
      case ActionType.setStorage:
        return SetStorageAction.fromJson(json);
      case ActionType.showDialog:
        return ShowDialogAction.fromJson(json);
      case ActionType.setCloudStorage:
        return SetCloudStorageAction.fromJson(json);
      case ActionType.loadFromCloudStorage:
        return LoadFromCloudStorageAction.fromJson(json);
    }
  }

  /// Applies the visitor pattern to this [ActionModel].
  ///
  /// The [accept] function takes a visitor object and calls the appropriate
  /// visit method on the visitor, according to the runtime type of this [ActionModel].
  /// This allows the visitor to perform computations or actions depending on
  /// the specific subclass of [ActionModel] it is dealing with.
  ///
  /// The return value is the result of calling the visit method on the visitor.
  /// The visitor is responsible for specifying the return type [R].
  ///
  /// @param visitor The visitor object to apply to this [ActionModel].
  ///
  /// @returns The result of calling the visit method on the visitor.
  R? accept<R>(ActionVisitor<R> visitor);
}

/// Defines the operation to be performed on a list type variable.
enum ListOperation {
  /// Replace entire list.
  replace,

  /// Replaces the list with a custom variable.
  set,

  /// Add [newValue] to the list.
  add,

  /// Insert [newValue] at [index] in the list.
  insert,

  /// Insert [newValue] at [index] in the list.
  insertAll,

  /// Remove value at [index] from the list.
  removeAt,

  /// Remove [newValue] from the list.
  remove,

  /// Update value at [index] with [newValue] in the list.
  update;

  /// Returns a string representation of this enum.
  String get prettify => switch (this) {
        ListOperation.replace => 'Replace',
        ListOperation.add => 'Add',
        ListOperation.set => 'Set',
        ListOperation.insert => 'Insert',
        ListOperation.insertAll => 'Insert All',
        ListOperation.removeAt => 'Remove At',
        ListOperation.remove => 'Remove',
        ListOperation.update => 'Update'
      };
}

/// Defines the operation to be performed on a map type variable.
enum MapOperation {
  /// Replace entire map.
  replace,

  /// Add [newValue] to the map.
  add,

  /// Remove [key] from the map.
  remove,

  /// Update value at [key] with [newValue] in the map.
  update,

  /// Same as replace but meant to replace the entire map with a new map from
  /// a variable.
  set;

  /// Returns a string representation of this enum.
  String get prettify => switch (this) {
        MapOperation.replace => 'Replace',
        MapOperation.add => 'Add',
        MapOperation.remove => 'Remove',
        MapOperation.update => 'Update',
        MapOperation.set => 'Set'
      };
}

/// Represents operations that can be performed on a number.
enum NumberOperation {
  /// Replace the value at the given index.
  set,

  /// Add the value to the existing value.
  add,

  /// Subtract the value from the existing value.
  subtract,
}

/// A base action class that represents an action that can be performed to
/// modify some data in some way depending on the data type.
abstract interface class DataOperationInterface {
  /// New value to be set.
  abstract final String newValue;

  /// Whether to toggle the value. This is used for boolean type variable.
  abstract final bool toggled;

  /// Operation to be performed on the list type variable.
  abstract final ListOperation listOperation;

  /// Index of the value to be updated/removed/inserted.
  /// Can be a discrete value or a variable referred by '${}' syntax.
  /// Used for list type variable.
  abstract final String index;

  /// Operation to be performed on the map type variable.
  abstract final MapOperation mapOperation;

  /// Key of the value to be updated/removed/inserted in the map.
  abstract final String mapKey;

  /// Operation to be performed on the int/double type variable.
  abstract final NumberOperation numberOperation;
}
