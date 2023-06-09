// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../condition.dart';
import 'action.dart';

part 'navigation_action.g.dart';

/// Defines how the navigation should be performed.
enum NavigationType {
  /// Navigate to the specified page.
  push,

  /// Navigate back from the current page.
  pop,

  /// Replace the current page with the specified page in the navigation stack.
  replace;

  /// Displayable string representation of [NavigationType].
  String get prettify {
    switch (this) {
      case NavigationType.push:
        return 'Navigate to page';
      case NavigationType.pop:
        return 'Navigate back';
      case NavigationType.replace:
        return 'Replace page';
    }
  }
}

/// An action that navigates to a new page.
@JsonSerializable()
class NavigationAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// Defines how the navigation should be performed.
  final NavigationType navigationType;

  /// Destination canvas node's ID.
  final String destinationId;

  /// Creates a new [NavigationAction].
  NavigationAction({
    this.navigationType = NavigationType.push,
    required this.destinationId,
  }) : super(type: ActionType.navigation);

  @override
  List<Object?> get props => [destinationId];

  /// Duplicates this [NavigationAction] with given data overrides.
  NavigationAction copyWith(
          {NavigationType? navigationType, String? destinationId}) =>
      NavigationAction(
        navigationType: navigationType ?? this.navigationType,
        destinationId: destinationId ?? this.destinationId,
      );

  /// Creates a new [NavigationAction] instance from a JSON data.
  factory NavigationAction.fromJson(Map json) =>
      _$NavigationActionFromJson(json);

  @override
  Map toJson() => _$NavigationActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitNavigationAction(this);
}
