// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'auto_placeholder_node.g.dart';

/// An unselectable node that serves as a placeholder for Auto nodes.
/// This behaves like an AutoCanvas, without the "Canvas" part. The behavior is similar.
/// Related: [FreeformPlaceholderNode]
@JsonSerializable()
class AutoPlaceholderNode extends DefaultShapeNode
    with ChildrenMixin, RowColumnMixin, PlaceholderMixin, IsolatedMixin {
  @override
  final String type = 'autoPlaceholder';

  @override
  final bool supportsPadding = true;

  /// Frame is a Rectangle with children, which can be clipped.
  /// In Figma it also has the AutoLayout properties, but we don't yet have it.
  AutoPlaceholderNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    RowColumnType rowColumnType = RowColumnType.column,
    MainAxisAlignmentC mainAxisAlignment = MainAxisAlignmentC.center,
    CrossAxisAlignmentC crossAxisAlignment = CrossAxisAlignmentC.center,
    super.outerBoxLocal,
    required List<String> children,
    super.retainedOuterBoxLocal,
    super.rotationDegrees,
    super.visible,
    double cornerSmoothing = 0,
    CornerRadius cornerRadius = CornerRadius.zero,
    super.alignment,
    super.padding,
    super.margin,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    // ClipMixin properties
    bool clipsContent = true,
    // DefaultShapeNode properties
    super.opacity,
    super.isMask,
    super.effects,
    super.blendMode,
    super.fills,
    super.strokes,
    super.strokeWeight,
    super.strokeMiterLimit,
    super.strokeAlign,
    super.strokeCap,
    super.dashPattern,
    super.strokeSide,
  }) {
    setChildrenMixin(children: children);
    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  /// Creates a [AutoPlaceholderNode] from a JSON data.
  factory AutoPlaceholderNode.fromJson(Map json) =>
      _$AutoPlaceholderNodeFromJson(json);

  @override
  Map toJson() => _$AutoPlaceholderNodeToJson(this);
}
