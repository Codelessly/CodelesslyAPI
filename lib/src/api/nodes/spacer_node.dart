// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'spacer_node.g.dart';

/// A spacer node that can be used to create space between other nodes inside
/// a row or column or any other flexible spaces.
@JsonSerializable()
class SpacerNode extends SceneNode {
  @override
  final String type = 'spacer';

  /// Creates a new [SpacerNode] with the given data.
  SpacerNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.horizontalFit,
    super.verticalFit,
    super.visible,
    super.flex,
    super.edgePins,
    super.parentID,
  });

  /// Creates a new [SpacerNode] from a JSON data.
  factory SpacerNode.fromJson(Map json) => _$SpacerNodeFromJson(json);

  @override
  Map toJson() => _$SpacerNodeToJson(this);
}
