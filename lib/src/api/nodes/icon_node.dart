// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'icon_node.g.dart';

/// Default size of the icon.
const double kIconDefaultSize = 24;

/// Default icon used as placeholder when no icon is provided.
const MaterialIcon defaultIcon = MaterialIcon(
  name: 'add',
  codepoint: 57669,
  style: MaterialIconStyle.filled,
);

/// A node that displays an icon.
@JsonSerializable()
class IconNode extends SceneNode
    with
        BlendMixin,
        SingleColorMixin,
        FixedAspectRatioMixin,
        CustomPropertiesMixin {
  /// The icon to display.
  IconModel icon;

  /// Strictly used for previews. e.g in components panel.
  IconNode.empty()
      : this(
          id: 'icon1',
          name: 'Icon',
          icon: defaultIcon,
          basicBoxLocal: NodeBox(0, 0, 24, 24),
        );

  @override
  final String type = 'icon';

  @override
  bool get supportsPadding => false;

  @override
  double get aspectRatio => 1;

  /// Creates an [IconNode] with the given data.
  IconNode({
    required this.icon,
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
    ColorRGBA? color,
    double opacity = 1.0,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    InkWellModel? inkWell,
  }) {
    setBlendMixin(
      opacity: opacity,
      isMask: isMask,
      effects: effects,
      blendMode: blendMode,
      inkWell: inkWell,
    );
    setSingleColorMixin(color: color);
  }

  /// Creates an [IconNode] from a JSON data.
  factory IconNode.fromJson(Map json) => _$IconNodeFromJson(json);

  @override
  Map toJson() => _$IconNodeToJson(this);
}
