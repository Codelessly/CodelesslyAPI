// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'accordion_node.g.dart';

/// An accordion is a type of menu that displays a list of headers stacked on
/// top of one another. When clicked on (or triggered by a keyboard interaction
/// or screen reader), these headers will either reveal or hide associated
/// content.
@JsonSerializable()
class AccordionNode extends SceneNode
    with ChildrenMixin, RowColumnMixin, IsolatedMixin {
  @override
  final String type = 'accordion';

  /// Whether the accordion is expanded or collapsed.
  bool isExpanded;

  /// Creates a new [AccordionNode] instance.
  AccordionNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    RowColumnType rowColumnType = RowColumnType.column,
    MainAxisAlignmentC mainAxisAlignment = MainAxisAlignmentC.center,
    CrossAxisAlignmentC crossAxisAlignment = CrossAxisAlignmentC.center,
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
    required List<String> children,
    this.isExpanded = true,
    super.variables,
    super.multipleVariables,
  }) {
    setChildrenMixin(children: children);
    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  /// Creates a [AccordionNode] from a JSON data.
  factory AccordionNode.fromJson(Map json) => _$AccordionNodeFromJson(json);

  @override
  Map toJson() => _$AccordionNodeToJson(this);
}
