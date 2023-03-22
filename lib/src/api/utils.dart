// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:collection/collection.dart';

import '../../api.dart';

/// Defines a function that returns a node by its id.
typedef GetNode = BaseNode Function(String id);

/// Top level function for deserializing a json Map to a map of [BaseNode] and
/// their ids as keys.
Map<String, BaseNode> jsonToNodes(Map<String, dynamic> value) => value.map(
      (key, value) => MapEntry(
        key,
        NodeJsonConverter.instance.fromJson(value)!,
      ),
    );

/// Top level function for serializing a map of [BaseNode] and their ids as keys
/// to a json Map.
Map<String, dynamic> nodesToJson(Map<String, BaseNode> nodes) => nodes.map(
      (key, value) => MapEntry(
        key,
        NodeJsonConverter.instance.toJson(value),
      ),
    );

/// Top level function for deserializing a json Map to [BaseNode].
BaseNode? jsonToBaseNode(Map? value) =>
    value != null ? NodeJsonConverter.instance.fromJson(value) : null;

/// Top level function for serializing [BaseNode] to a json Map.
Map nodeToJson(BaseNode node) => node.toJson();

/// Top level function for deserializing millis from json to [DateTime].
DateTime jsonToDate(int? value) => value != null
    ? DateTime.fromMillisecondsSinceEpoch(value).toLocal()
    : DateTime.now();

/// Top level function for serializing [DateTime] to millisecondsSinceEpoch.
int dateToJson(DateTime date) => date.toUtc().millisecondsSinceEpoch;

/// Top level function for deserializing the millis from a json as the values of
/// a map to [DateTime].
Map<String, DateTime> jsonMapToDateValues(Map<String, dynamic> value) =>
    value.map(
      (key, value) => MapEntry(
        key,
        DateTime.fromMillisecondsSinceEpoch(value).toLocal(),
      ),
    );

/// Top level function for serializing a map of with [DateTime] as the values
/// to millisecondsSinceEpoch.
Map<String, int> dateValuesToJsonMap(Map<String, DateTime> dates) => dates.map(
      (key, value) => MapEntry(
        key,
        value.toUtc().millisecondsSinceEpoch,
      ),
    );

/// Top level function for serializing [DateTime] to millisecondsSinceEpoch
/// or null if [DateTime] is null.
int? dateToJsonNullable(DateTime? date) =>
    (date == null) ? null : dateToJson(date);

/// An interface for computing text information. This is meant to be used
/// as an abstraction to Flutter's [TextPainter].
abstract class ITextSizeCalculator {
  /// [returns] the height of a defined [TextNode] based on its width.
  /// The details are dependant on the implementation.
  double getHeightForWidth(double width);

  /// [returns] the width of a defined [TextNode] based on its height.
  /// The details are dependant on the implementation.
  double getWidthForHeight(double height, double fallbackWidth);

  /// [returns] The minimum possible width of a defined [TextNode].
  /// The details are dependant on the implementation.
  double getMinWidth();

  /// [returns] The maximum possible width of a defined [TextNode].
  /// The details are dependant on the implementation.
  double getMaxWidth();

  /// [returns] the smallest possible width a [TextNode] can have given the
  /// constraints of its current [NodeBox].
  /// The details are dependant on the implementation.
  double getBestTextWidthAtCurrentNodeBox();

  /// [returns] The minimum height of a defined [TextNode].
  /// The details are dependant on the implementation.
  double getMinHeight();

  /// [returns] The distance to the [baseline] of a defined [TextNode].
  /// The details are dependant on the implementation.
  double computeDistanceToActualBaseline(CTextBaseline baseline);
}

/// Defines different styling options for any widget.
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
/// By default, we do not store the [BaseNode.parentID] on the server, so we
/// need to do a reverse lookup to find the parent node of a given [node].
///
/// This function is most likely used during initialization of a project or
/// Node Singleton.
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
