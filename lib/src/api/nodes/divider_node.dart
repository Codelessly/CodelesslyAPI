// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'divider_node.g.dart';

/// Default width of a divider.
const double kDividerDefaultWidth = 150;

/// Default height of a divider.
const double kDividerDefaultHeight = 16;

/// A divider visually segments content into groups.
/// Refer to [Divider](https://api.flutter.dev/flutter/material/Divider-class.html)
/// in Flutter for more details.
@JsonSerializable()
class DividerNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'divider';

  /// Holds configurable properties of the divider.
  DividerProperties properties;

  @override
  bool get supportsPadding => false;

  /// Strictly used for previews. e.g in components panel.
  DividerNode.empty()
      : properties = DividerProperties(),
        super(
          id: 'divider',
          name: 'Divider',
          basicBoxLocal:
              NodeBox(0, 0, kDividerDefaultWidth, kDividerDefaultHeight),
        );

  /// Strictly used for previews. e.g in components panel.
  DividerNode.fromProperties(this.properties)
      : super(
          id: 'divider',
          name: 'Divider',
          basicBoxLocal:
              NodeBox(0, 0, kDividerDefaultWidth, kDividerDefaultHeight),
        );

  /// Creates a [DividerNode] with the given data.
  DividerNode({
    bool? value,
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
    // [BlendMixin] properties.
    double opacity = 1,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    // Custom properties.
    required this.properties,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        properties,
      ];

  /// Creates a [DividerNode] from a JSON data.
  factory DividerNode.fromJson(Map json) => _$DividerNodeFromJson(json);

  @override
  Map toJson() => _$DividerNodeToJson(this);

  @override
  SizeC minimumInternalSize({
    required SizeFit horizontalFit,
    required SizeFit verticalFit,
  }) {
    final SizeC size;
    if (properties.isVertical) {
      size = SizeC(properties.thickness, 0);
    } else {
      size = SizeC(0, properties.thickness);
    }
    return size |
        super.minimumInternalSize(
          horizontalFit: horizontalFit,
          verticalFit: verticalFit,
        );
  }

  @override
  EdgeInsetsModel? preferredDefaultPadding() {
    EdgeInsetsModel minPadding = EdgeInsetsModel.zero;

    // Dividers have a height property that is separate from their thickness as
    // a means to apply padding around the divider.
    // When a divider is set to shrinkwrap, it shrinkwraps to its thickness,
    // which is not desirable. Instead, we should shrinkwrap to some padding.
    // It's a pad of 16 by default (8 on each side).
    if (horizontalFit.isWrap) {
      minPadding = const EdgeInsetsModel.symmetric(
        horizontal: kDividerDefaultHeight / 2,
      );
    } else if (verticalFit.isWrap) {
      minPadding = const EdgeInsetsModel.symmetric(
        vertical: kDividerDefaultHeight / 2,
      );
    }

    return minPadding;
  }
}

/// Holds configurable properties of the divider.
@JsonSerializable()
class DividerProperties with SerializableMixin, EquatableMixin {
  /// Color of the divider.
  ColorRGBA color;

  /// Start indent of the divider. Refers to space of left for horizontal
  /// divider and top for vertical divider.
  double indent;

  /// End indent of the divider. Refers to space of right for horizontal
  /// divider and bottom for vertical divider.
  double endIndent;

  /// Whether this is a vertical divider.
  bool isVertical;

  /// Thickness of the diving line.
  double thickness;

  /// Creates a [DividerProperties] with the given data.
  DividerProperties({
    this.color = ColorRGBA.black,
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = 1,
    this.isVertical = false,
  });

  /// Duplicates this [DividerProperties] with the given data overrides.
  DividerProperties copyWith({
    ColorRGBA? color,
    double? indent,
    double? endIndent,
    bool? isVertical,
  }) {
    return DividerProperties(
      color: color ?? this.color,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
      isVertical: isVertical ?? this.isVertical,
    );
  }

  @override
  List<Object?> get props => [
        color,
        indent,
        endIndent,
        isVertical,
      ];

  /// Creates a [DividerProperties] from a JSON data.
  factory DividerProperties.fromJson(Map json) =>
      _$DividerPropertiesFromJson(json);

  @override
  Map toJson() => _$DividerPropertiesToJson(this);
}
