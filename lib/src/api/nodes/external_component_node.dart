// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'external_component_node.g.dart';

/// An inert node that does nothing.
/// This is populated dynamically through the Codelessly SDK.
@JsonSerializable()
class ExternalComponentNode extends BaseNode with CustomPropertiesMixin {
  @override
  final String type = 'external';

  /// A user-defined ID that is used to map this node to a widget builder.
  /// The reason we allow an external ID is to allow users to define friendly
  /// names for their dynamic nodes instead of arbitrarily-generated IDs.
  /// Another reason is that the ID can be used more than once to map multiple
  /// nodes to the same widget builder.
  String? builderID;

  /// Creates an [ExternalComponentNode] with the given data.
  ExternalComponentNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required this.builderID,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.rotationDegrees,
    super.alignment,
    super.margin,
    super.padding,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
  });

  /// Creates a [ExternalComponentNode] from a JSON object.
  factory ExternalComponentNode.fromJson(Map json) =>
      _$ExternalComponentNodeFromJson(json);

  @override
  Map toJson() => _$ExternalComponentNodeToJson(this);
}
