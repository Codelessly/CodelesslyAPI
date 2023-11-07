// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';

part 'row_column_node.g.dart';

/// A node that can lay out its children in a row or column.
/// Typically referred to [Row] and [Column] widgets in Flutter.
@JsonSerializable()
class RowColumnNode extends ParentNode with RowColumnMixin, ScrollableMixin {
  @override
  final String type = 'rowColumn';

  @override
  final bool supportsPadding = true;

  @JsonKey(includeFromJson: false)
  @override
  AxisC get scrollDirection =>
      rowColumnType == RowColumnType.row ? AxisC.horizontal : AxisC.vertical;

  @override
  set scrollDirection(AxisC value) {}

  /// Creates a [RowColumnNode] with the given data.
  RowColumnNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    required super.children,
    required RowColumnType rowColumnType,
    MainAxisAlignmentC mainAxisAlignment = MainAxisAlignmentC.center,
    CrossAxisAlignmentC crossAxisAlignment = CrossAxisAlignmentC.center,
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
    super.reactions,
    super.parentID,
    super.clipsContent = false,
    // [ScrollableMixin] properties.
    bool isScrollable = false,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.platformDependent,
    bool primary = true,
    bool shrinkWrap = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
    bool useFlutterListView = false,
    bool shouldAlwaysScroll = true,
  }) {
    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );

    setScrollableMixin(
      isScrollable: isScrollable,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      primary: primary,
      shrinkWrap: shrinkWrap,
      keyboardDismissBehavior: keyboardDismissBehavior,
      useFlutterListView: useFlutterListView,
      shouldAlwaysScroll: shouldAlwaysScroll,
    );
  }

  /// Creates a [RowColumnNode] from a JSON data.
  factory RowColumnNode.fromJson(Map json) => _$RowColumnNodeFromJson(json);

  @override
  Map toJson() => _$RowColumnNodeToJson(this);
}
