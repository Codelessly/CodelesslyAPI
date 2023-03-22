// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import 'action.dart';

part 'link_action.g.dart';

/// An action that navigates/opens a link.
@JsonSerializable()
class LinkAction extends ActionModel with EquatableMixin, SerializableMixin {
  /// The link to navigate to.
  final String url;

  /// Creates a new [LinkAction] with the given data.
  LinkAction({required this.url}) : super(type: ActionType.link);

  @override
  List<Object?> get props => [url];

  /// Duplicate this [LinkAction] with the given data overrides.
  LinkAction copyWith({String? url}) => LinkAction(url: url ?? this.url);

  /// Factory constructor for creating a new [LinkAction] instance from
  /// JSON data.
  factory LinkAction.fromJson(Map json) => _$LinkActionFromJson(json);

  @override
  Map toJson() => _$LinkActionToJson(this);
}
