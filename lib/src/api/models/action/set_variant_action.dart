// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../codelessly_api.dart';

part 'set_variant_action.g.dart';

/// An action that sets the variant of a node.
@JsonSerializable()
class SetVariantAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// ID of the variance node whose variant is to be set.
  final String nodeID;

  /// ID of variant that needs to be set.
  final String variantID;

  /// Creates a new [SetVariantAction].
  SetVariantAction({
    required this.nodeID,
    required this.variantID,
  }) : super(type: ActionType.setVariant);

  @override
  List<Object?> get props => [nodeID, variantID];

  /// Duplicates this [SetVariantAction] with given data overrides.
  SetVariantAction copyWith({
    String? nodeID,
    String? variantID,
  }) =>
      SetVariantAction(
        nodeID: nodeID ?? this.nodeID,
        variantID: variantID ?? this.variantID,
      );

  /// Creates a new [SetVariantAction] instance from a JSON object.
  factory SetVariantAction.fromJson(Map json) =>
      _$SetVariantActionFromJson(json);

  @override
  Map toJson() => _$SetVariantActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSetVariantAction(this);
}
