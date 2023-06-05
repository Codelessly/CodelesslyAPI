// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import '../../mixins.dart';
import '../models.dart';

/// Type of the action to perform on a user interaction.
enum ActionType {
  /// Navigate to a page.
  navigation,

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
  callApi;

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
    }
  }
}

/// Holds information about an action to perform on a user interaction.
abstract class ActionModel with SerializableMixin {
  /// Type of the action.
  ActionType type;

  /// Creates an [ActionModel] with the given data.
  ActionModel({required this.type});

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
    }
  }
}
