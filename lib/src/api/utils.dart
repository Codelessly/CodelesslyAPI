// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:collection/collection.dart';

import '../../codelessly_api.dart';

/// Rounds the given [value] to the [precision]'th decimal place.
double roundDoubleToJson(double value) => value.roundToPrecision(3);

/// Defines a function that returns a node by its id.
typedef GetNode = BaseNode Function(String id);

/// An interface for computing text information. This is meant to be used as an
/// abstraction to Flutter's [TextPainter].
abstract class ITextSizeCalculator {
  /// Returns the height of a defined [TextNode] based on its width.
  /// The details are dependant on the implementation.
  double getHeightForWidth(double width);

  /// Returns the width of a defined [TextNode] based on its height.
  /// The details are dependant on the implementation.
  double getWidthForHeight(double height, double fallbackWidth);

  /// Returns The minimum possible width of a defined [TextNode].
  /// The details are dependant on the implementation.
  double getMinWidth();

  /// Returns The maximum possible width of a defined [TextNode].
  /// The details are dependant on the implementation.
  double getMaxWidth();

  /// Returns the smallest possible width a [TextNode] can have given the
  /// constraints of its current [NodeBox].
  /// The details are dependant on the implementation.
  double getBestTextWidthAtCurrentNodeBox(double internalBoxWidth);

  /// Returns The minimum height of a defined [TextNode].
  /// The details are dependant on the implementation.
  double getMinHeight();

  /// Returns The distance to the [baseline] of a defined [TextNode].
  /// The details are dependant on the implementation.
  double computeDistanceToActualBaseline(CTextBaseline baseline);
}

/// Defines different styling options for a widget.
enum StyleDefinition {
  /// Represents the Material 2.0 design specs.
  material_2,

  /// Represents the Material 3.0 design specs.
  material_3;

  /// Whether this is the material 2.0 design.
  bool get isMaterial2 => this == StyleDefinition.material_2;

  /// Whether this is the material 3.0 design.
  bool get isMaterial3 => this == StyleDefinition.material_3;

  /// Whether this is a material design style.
  bool get isMaterial => isMaterial2 || isMaterial3;
}

/// Whether the aspect ratio for this [node] is locked.
bool isAspectRatioLocked(BaseNode node) {
  return node is FixedAspectRatioMixin ||
      node is ScalableMixin ||
      node.aspectRatioLock;
}

/// Retrieves the aspect ratio of given [node].
double getAspectRatio(BaseNode node) {
  if (node is FixedAspectRatioMixin) {
    return node.aspectRatio;
  } else {
    return node.middleBoxLocal.width / node.middleBoxLocal.height;
  }
}

/// Does a reverse lookup for the parent node of a given [node] in a list of
/// [nodes].
///
/// This function is required because node's [parentID] is not stored on the
/// server.
String resolveParentNodeIDs({
  required BaseNode node,
  required List<BaseNode> nodes,
}) {
  return nodes.firstWhereOrNull(
        (parent) {
          if (parent is ChildrenMixin && parent.children.contains(node.id)) {
            return true;
          }
          if (parent is VarianceNode) {
            return parent.allVariantsChildren.contains(node.id);
          }
          return false;
        },
      )?.id ??
      kRootNode;
}
