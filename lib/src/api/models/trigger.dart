// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';

part 'trigger.g.dart';

/// Types of different triggers.
enum TriggerType {
  /// Triggered when the user clicks on a target.
  click,

  /// Triggered when text is changed inside a text input field.
  changed,

  /// Triggered when text editing is completed on a text input field and
  /// it is about to submit.
  editingComplete,

  /// Triggered when a text field is submitted.
  submitted,

  /// Triggered when the user long presses on a target.
  longPress,

  /// Triggered when the user hovers over a target with mouse/cursor.
  hover,

  /// Triggered when the user drags a target.
  drag,
  // unused, for now.
  // afterTimeout,
  /// Triggered when the cursor enters a target region.
  cursorEnter,

  /// Triggered when the cursor exits a target region.
  cursorExit,

  /// Triggered when a pointer down event is received on a target.
  pointerDown,

  /// Triggered when a pointer up event is received on a target.
  pointerUp;

  /// Displayable string representation of the trigger type.
  String get prettify {
    switch (this) {
      case TriggerType.click:
        return 'Click';
      case TriggerType.longPress:
        return 'Long Press';
      case TriggerType.hover:
        return 'Hover';
      case TriggerType.drag:
        return 'Drag';
      // case TriggerType.afterTimeout:
      //   return 'After Timeout';
      case TriggerType.cursorEnter:
        return 'Cursor Enter';
      case TriggerType.cursorExit:
        return 'Cursor Exit';
      case TriggerType.pointerDown:
        return 'Pointer Down';
      case TriggerType.pointerUp:
        return 'Pointer Up';
      case TriggerType.changed:
        return 'Changed';
      case TriggerType.editingComplete:
        return 'Editing Complete';
      case TriggerType.submitted:
        return 'Submitted';
    }
  }
}

/// A model representing a trigger event data.
@JsonSerializable()
class TriggerModel with EquatableMixin, SerializableMixin {
  /// The type of the trigger.
  final TriggerType type;

  // TODO: We might implement timeout in future, but it is not relevant for now.
  // // When ActionType is [afterTimeout].
  // final double timeout;

  /// Creates a [TriggerModel] with given data.
  TriggerModel({required this.type});

  @override
  List<Object?> get props => [type];

  /// Duplicate this [TriggerModel] with given data overrides.
  TriggerModel copyWith({TriggerType? type}) =>
      TriggerModel(type: type ?? this.type);

  /// Factory constructor for creating a new [TriggerModel] instance from
  /// JSON data.
  factory TriggerModel.fromJson(Map json) => _$TriggerModelFromJson(json);

  @override
  Map toJson() => _$TriggerModelToJson(this);
}
