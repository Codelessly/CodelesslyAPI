// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'base_node.dart';
import '../mixins.dart';
import '../models/models.dart';

/// SceneNode should never be called directly, only inherited by other nodes.
abstract class SceneNode extends BaseNode
    with ReactionMixin, PropertyVariableMixin {
  /// Creates a [SceneNode] with the given data.
  SceneNode({
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
    List<Reaction> reactions = const [],
  }) {
    setReactionMixin([...reactions]);
  }
}
