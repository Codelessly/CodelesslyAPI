// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';

part 'frame_node.g.dart';

/// A node that represents a frame that behaves like a stack.
@JsonSerializable()
class FrameNode extends DefaultShapeNode
    with CornerMixin, ClipMixin, ChildrenMixin, ScrollableMixin {
  @override
  final String type = 'frame';

  @override
  final bool supportsPadding = true;

  /// Frame is a Rectangle with children, which can be clipped.
  FrameNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    required List<String> children,
    super.retainedOuterBoxLocal,
    super.rotationDegrees,
    super.fills,
    super.strokes,
    super.effects,
    super.blendMode,
    super.visible,
    super.opacity,
    super.isMask,
    super.strokeWeight,
    super.strokeMiterLimit,
    super.strokeAlign,
    super.strokeCap,
    double cornerSmoothing = 0,
    CornerRadius cornerRadius = CornerRadius.zero,
    super.dashPattern,
    super.alignment,
    super.padding,
    super.margin,
    super.strokeSide,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    // [ClipMixin] properties.
    bool clipsContent = true,
    // [ScrollableMixin] properties.
    bool isScrollable = false,
    AxisC scrollDirection = AxisC.vertical,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.alwaysScrollableScrollPhysics,
    bool primary = true,
    bool shrinkWrap = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
    bool useFlutterListView = false,
  }) {
    setCornerMixin(
        cornerRadius: cornerRadius, cornerSmoothing: cornerSmoothing);

    setClipMixin(clipsContent: clipsContent);

    setChildrenMixin(children: children);

    setScrollableMixin(
      isScrollable: isScrollable,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      primary: primary,
      shrinkWrap: shrinkWrap,
      keyboardDismissBehavior: keyboardDismissBehavior,
      useFlutterListView: useFlutterListView,
    );
  }

  /// Creates a [FrameNode] from a JSON data.
  factory FrameNode.fromJson(Map json) => _$FrameNodeFromJson(json);

  @override
  Map toJson() => _$FrameNodeToJson(this);
}
