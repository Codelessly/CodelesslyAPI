// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'placeholder_node.g.dart';

/// [PlaceholderNode] holds the place for another node until the other node
/// replaces it.
@JsonSerializable()
class PlaceholderNode extends SceneNode with PlaceholderMixin {
  @override
  final String type = 'placeholder';

  @override
  final bool supportsPadding = true;

  /// Image asset displayed in the placeholder.
  String? leadingAsset;

  /// Text displayed in the placeholder.
  String? text;

  /// Creates a [PlaceholderNode] instance with the given data.
  PlaceholderNode({
    required this.text,
    required this.leadingAsset,
    required super.id,
    required super.name,
    required super.basicBoxLocal,
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
    super.parentID,
    super.reactions,
  });

  /// Creates a [PlaceholderNode] instance from a JSON object.
  factory PlaceholderNode.fromJson(Map json) => _$PlaceholderNodeFromJson(json);

  @override
  Map toJson() => _$PlaceholderNodeToJson(this);
}
