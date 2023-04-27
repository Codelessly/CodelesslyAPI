// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';

part 'action.g.dart';

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
      case ActionType.callFunction:
        return 'Call Function';
      case ActionType.callApi:
        return 'Call API';
    }
  }
}

/// Holds information about an action to perform on a user interaction.
@JsonSerializable()
class ActionModel with SerializableMixin {
  /// Type of the action.
  ActionType type;

  /// Creates an [ActionModel] with the given data.
  ActionModel({required this.type});

  /// Factory constructor for creating a new [ActionModel] instance from
  /// JSON data.
  factory ActionModel.fromJson(Map json) => _$ActionModelFromJson(json);

  @override
  Map toJson() => _$ActionModelToJson(this);
}
