// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

part of 'nodes/base_node.dart';

/// Extensions for [NodeBox].
extension NodeBoxHelper on NodeBox {
  /// Used to update the [NodeBox] with new values. This by default triggers
  /// computation on update.
  /// NodeBox does not hold a reference to the node itself, this is why
  /// we need to pass the [node] as a parameter.
  void update({
    required BaseNode node,
    double? x,
    double? y,
    double? width,
    double? height,
    bool resetRetainedBox = true,
    bool recursivelyCalculateChildrenGlobalBoxes = true,
    bool triggerCompute = true,
  }) {
    final NodeBox box = NodeBox(
      x ?? this.x,
      y ?? this.y,
      width ?? this.width,
      height ?? this.height,
    );
    if (!triggerCompute) {
      node._basicBoxLocal = box;
    } else {
      NodeProcessor.updateNode(
        node: node,
        basicBoxLocal: box,
        resetRetainedBox: resetRetainedBox,
        recursivelyCalculateChildrenGlobalBoxes:
            recursivelyCalculateChildrenGlobalBoxes,
      );
    }
  }
}

/// Extensions for [OuterNodeBox].
extension OuterBoxHelper on OuterNodeBox {
  /// Used to update the [OuterNodeBox] with new values. This by default
  /// triggers computation on update.
  /// NodeBox does not hold a reference to the node itself, this is why
  /// we need to pass the [node] as a parameter.
  void update({
    required BaseNode node,
    double? x,
    double? y,
    double? width,
    double? height,
    bool resetRetainedBox = true,
    bool recursivelyCalculateChildrenGlobalBoxes = true,
    bool triggerCompute = true,
  }) {
    final OuterNodeBox box = OuterNodeBox(
      x ?? this.x,
      y ?? this.y,
      width ?? this.width,
      height ?? this.height,
      edgeInsets: node.margin,
    );

    if (!triggerCompute) {
      node._outerBoxLocal = box;
    } else {
      NodeProcessor.updateNode(
        node: node,
        outerBoxLocal: box,
        resetRetainedBox: resetRetainedBox,
        recursivelyCalculateChildrenGlobalBoxes:
            recursivelyCalculateChildrenGlobalBoxes,
      );
    }
  }
}

/// Extensions for [BaseNode].
extension BaseNodeUpdateExtension on BaseNode {
  ///Switches the parent node of this node from [oldParent] to [newParent].
  void switchParent({
    required BaseNode newParent,
    required BaseNode oldParent,
  }) {
    oldParent.childrenOrEmpty.remove(id);
    newParent.childrenOrEmpty.add(id);
    parentID = newParent.id;
  }

  /// Used to update the [BaseNode] with new values. This by default
  /// triggers computation on update.
  /// See [updateNode] for more details.
  void update({
    EdgeInsetsModel? margin,
    EdgeInsetsModel? padding,
    AlignmentModel? alignment,
    OuterNodeBox? outerBoxLocal,
    OuterNodeBox? outerBoxGlobal,
    NodeBox? middleBoxLocal,
    int? rotationDegrees,
    bool resetRetainedBox = true,
    bool recursivelyCalculateChildrenGlobalBoxes = true,
    Vec? globalParentBoundingBoxPos,
  }) =>
      NodeProcessor.updateNode(
        node: this,
        margin: margin,
        padding: padding,
        alignment: alignment,
        outerBoxLocal: outerBoxLocal,
        outerBoxGlobal: outerBoxGlobal,
        basicBoxLocal: middleBoxLocal,
        rotationDegrees: rotationDegrees,
        resetRetainedBox: resetRetainedBox,
        recursivelyCalculateChildrenGlobalBoxes:
            recursivelyCalculateChildrenGlobalBoxes,
        globalParentBoundingBoxPos: globalParentBoundingBoxPos,
      );

  /// Set rotation for this node.
  void setNodeRotation(int newRotationDegrees) {
    _rotationDegrees = newRotationDegrees;
    _rotationRadians = newRotationDegrees * pi / 180;
  }

  /// Updates rotation for this node recursively for its children as well
  /// if [updateChildren] is true.
  void updateNodeRotation(int newRotationDegrees,
      {bool updateChildren = true}) {
    setNodeRotation(newRotationDegrees);

    if (updateChildren) {
      NodeProcessor.updateGlobalRotation(
          node: this, newRotationDegrees: newRotationDegrees);
    } else {
      if (id == kRootNode) {
        globalRotationDegrees = newRotationDegrees;
        globalRotationRadians = newRotationDegrees * pi / 180;
      } else {
        final BaseNode parent = NodeProcessor.getNode(parentID);
        globalRotationDegrees =
            parent.globalRotationDegrees + newRotationDegrees;
        globalRotationRadians = globalRotationDegrees * pi / 180;
      }
    }
  }
}

/// This class is used to process nodes.
class NodeProcessor {
  /// This function is used to get the node from the node id.
  static late GetNode getNode;

  NodeProcessor._();

  /// This function is used to initialize the [getNode] function.
  static void registerNodeGetter(GetNode getNode) {
    NodeProcessor.getNode = getNode;
  }

  /// Update the global rotation for given [node] with [newRotationDegrees].
  static void updateGlobalRotation({
    required BaseNode node,
    required int newRotationDegrees,
  }) {
    if (node.id == kRootNode) {
      node.globalRotationDegrees = newRotationDegrees;
      node.globalRotationRadians = newRotationDegrees * pi / 180;
    } else {
      final BaseNode parent = getNode(node.parentID);
      node.globalRotationDegrees =
          parent.globalRotationDegrees + newRotationDegrees;
      node.globalRotationRadians = node.globalRotationDegrees * pi / 180;
    }

    for (var childId in node.childrenOrEmpty) {
      final child = getNode(childId);
      updateGlobalRotation(
          node: child, newRotationDegrees: child.rotationDegrees);
    }
  }

  /// Switches the parent node of this node from [oldParent] to [newParent].
  static void switchParent({
    required BaseNode node,
    required BaseNode newParent,
    required BaseNode oldParent,
  }) {
    oldParent.childrenOrEmpty.remove(node.id);
    oldParent.childrenOrEmpty.add(node.id);
    node.parentID = newParent.id;
  }

  /// This function will ensure that any of the below properties that you change
  /// from a given node will be done properly and be propagated adequately.
  /// If you update the [margin] space for example, it will ensure that ever
  /// [NodeBox] inside your [node] is updated properly to reflect those changes.
  /// Additionally, this function will recur into all of the children of this
  /// [node] to ensure that their relative positions all also get updated properly
  /// to reflect your changes.
  ///
  /// This function does a lot of processing to ensure that all the values of your
  /// node's and this node's children are updated properly, therefore it is a
  /// somewhat computationally expensive function.
  ///
  /// [node] is the node that is being updated. If position or rotation changes,
  ///        it's children will update their global boxes to reflect.
  ///
  /// If the [margin], [padding], [alignment] update, all of the [node]'s
  /// [NodeBox]es will update to reflect, as well as the [node]'s children.
  ///
  /// If the [outerBoxLocal] updates, that mean's the node's position is manually
  /// being changed and the layout system has not processed it yet, but will read
  /// this updated data. It will automatically cause [basicBoxLocal] to
  /// recalculate.
  ///
  /// If [outerBoxGlobal] updates, that means the layout system performed a layout
  /// that updates this node's position. [outerBoxGlobal] ONLY changes from the
  /// layout system because the layout system talks in global coordinates.
  ///
  /// If [basicBoxLocal] updates, that means the node's size is manually being
  /// changed and the layout system has not processed it yet, but will read this
  /// updated data. It will automatically cause [outerBoxLocal] to recalculate.
  ///
  /// if [rotationDegrees] updates, that means the node's rotation is manually
  /// being changed and the layout system has not processed it yet, but will read
  /// this updated data. It will automatically cause all the [NodeBox]es to
  /// recalculate, including the not-rotated boxes.
  ///
  /// If [resetRetainedBox] is true, the [node]'s [retainedBox] will be reset to
  /// the [outerBoxLocal].
  ///
  /// If [recursivelyCalculateChildrenGlobalBoxes] is true, the [node]'s children
  /// will have their global boxes recalculated recursively. If this is false,
  /// this node will only recalculate itself. This is useful when handling
  /// node initialization and bulk-processing to ensure order-of-operations is
  /// correct.
  ///
  /// [globalParentBoundingBoxPos] is the position of the parent's bounding box
  /// in global coordinates. This is set by the layout system automatically
  /// and should not be set manually. It is used to calculate this node's boxes
  /// properly from global coordinates.
  ///
  /// The layout system always specifies [outerBoxGlobal] and
  /// [globalParentBoundingBoxPos] to ensure the boxes are calculated properly.
  /// These two parameters are never set manually.
  static void updateNode({
    required BaseNode node,
    EdgeInsetsModel? margin,
    EdgeInsetsModel? padding,
    AlignmentModel? alignment,
    OuterNodeBox? outerBoxLocal,
    OuterNodeBox? outerBoxGlobal,
    NodeBox? basicBoxLocal,
    int? rotationDegrees,
    bool resetRetainedBox = true,
    bool recursivelyCalculateChildrenGlobalBoxes = true,
    Vec? globalParentBoundingBoxPos,
  }) {
    final bool marginChanged = margin != null && margin != node.margin;
    final bool paddingChanged = padding != null && padding != node.padding;
    final bool alignmentChanged =
        alignment != null && alignment != node.alignment;
    // final bool marginPaddingChanged = marginChanged || paddingChanged;
    final bool performLayoutRan =
        outerBoxGlobal != null && globalParentBoundingBoxPos != null;
    final bool localOuterBoxChanged = outerBoxLocal != null;
    final bool localMiddleBoxChanged = basicBoxLocal != null;

    if (alignmentChanged) node._alignment = alignment;
    if (marginChanged) node._margin = margin;
    if (paddingChanged) node._padding = padding;
    if (localMiddleBoxChanged) node._basicBoxLocal = basicBoxLocal;
    if (localOuterBoxChanged) node._outerBoxLocal = outerBoxLocal;
    if (outerBoxGlobal != null) node._outerBoxGlobal = outerBoxGlobal;

    node.updateNodeRotation(rotationDegrees ?? node.rotationDegrees);

    if (performLayoutRan) {
      node._outerBoxLocal = OuterNodeBox(
        node.outerBoxGlobal.x - globalParentBoundingBoxPos.x,
        node.outerBoxGlobal.y - globalParentBoundingBoxPos.y,
        node.outerBoxGlobal.width,
        node.outerBoxGlobal.height,
        edgeInsets: node.margin,
      );
    }

    if (!localOuterBoxChanged && (localMiddleBoxChanged || marginChanged)) {
      node._outerBoxLocal = OuterNodeBox(
        node.basicBoxLocal.left - node.margin.l,
        node.basicBoxLocal.top - node.margin.t,
        node.basicBoxLocal.width + node.margin.l + node.margin.r,
        node.basicBoxLocal.height + node.margin.t + node.margin.b,
        edgeInsets: node.margin,
      );
    }

    if (!localMiddleBoxChanged || performLayoutRan) {
      node._basicBoxLocal = NodeBox(
        node.outerBoxLocal.left + node.margin.l,
        node.outerBoxLocal.top + node.margin.t,
        node.outerBoxLocal.width - node.margin.l - node.margin.r,
        node.outerBoxLocal.height - node.margin.t - node.margin.b,
      );
    }

    if (resetRetainedBox) {
      node._retainedOuterBoxLocal = node.outerBoxLocal.copyWith();
    }

    if (node.id != kRootNode && !performLayoutRan) {
      final BaseNode parentNode = getNode(node.parentID);

      node.edgePins = node.edgePins.copyWithLeft(
        (node.edgePins.left == null) ? null : node.outerBoxLocal.left,
      );

      if (node.outerBoxLocal.width > 0) {
        node.edgePins = node.edgePins.copyWithRight(
          (node.edgePins.right == null)
              ? null
              : parentNode.outerBoxLocal.width -
                  node.outerBoxLocal.right -
                  parentNode.outerBoxGlobal.horizontalEdgeSpace,
        );
      }
      node.edgePins = node.edgePins.copyWithTop(
        (node.edgePins.top == null) ? null : node.outerBoxLocal.top,
      );
      if (node.outerBoxLocal.height > 0) {
        node.edgePins = node.edgePins.copyWithBottom(
          (node.edgePins.bottom == null)
              ? null
              : parentNode.outerBoxLocal.height -
                  node.outerBoxLocal.bottom -
                  parentNode.outerBoxLocal.verticalEdgeSpace,
        );
      }
    }

    if (globalParentBoundingBoxPos == null) {
      _computeGlobalAndRotatedBoxes(
        node,
        recursivelyCalculateChildren: recursivelyCalculateChildrenGlobalBoxes,
      );
    } else {
      _computeGlobalAndRotatedBoxes(
        node,
        recursivelyCalculateChildren: false,
      );
    }

    _computeInnerBoxLocal(node);
  }

  static void _computeGlobalAndRotatedBoxes(
    BaseNode node, {
    bool recursivelyCalculateChildren = true,
  }) {
    // Order matters.
    // Middle and inner boxes depend on outer.
    // Rotated boxes depend on all of them.
    _computeOuterBoxGlobal(node);
    _computeMiddleBoxGlobal(node);
    _computeInnerBoxGlobal(node);
    _computeRotatedBoxes(node);

    if (recursivelyCalculateChildren) {
      for (final String childID in node.childrenOrEmpty) {
        final BaseNode childNode = getNode(childID);
        _computeGlobalAndRotatedBoxes(childNode);
      }
    }
  }

  static void _computeOuterBoxGlobal(BaseNode node) {
    final Vec globalBoundingTopLeft = getGlobalRotatedBoxTopLeft(
      node.id,
      unrotate: true,
      boundaryType: NodeBoundaryType.outerBox,
    );
    node._outerBoxGlobal = OuterNodeBox(
      globalBoundingTopLeft.x,
      globalBoundingTopLeft.y,
      node.outerBoxLocal.width,
      node.outerBoxLocal.height,
      edgeInsets: node.margin,
    );
  }

  static void _computeMiddleBoxGlobal(BaseNode node) {
    node._basicBoxGlobal = NodeBox(
      node._outerBoxGlobal.innerLeft,
      node._outerBoxGlobal.innerTop,
      node._outerBoxGlobal.innerWidth,
      node._outerBoxGlobal.innerHeight,
    );
  }

  static void _computeInnerBoxLocal(BaseNode node) {
    node._innerBoxLocal = InnerNodeBox.fromMiddleBox(
      node.basicBoxLocal,
      edgeInsets: node.resolvedPadding(),
    );
  }

  static void _computeInnerBoxGlobal(BaseNode node) {
    node._innerBoxGlobal = InnerNodeBox.fromMiddleBox(
      node.basicBoxGlobal,
      edgeInsets: node.resolvedPadding(),
    );
  }

  static void _computeRotatedBoxes(BaseNode node) {
    final RectC middleRotatedBox = getRotatedBoundingBoxAroundSelf(
      node.middleBoxLocal.x,
      node.middleBoxLocal.y,
      node.middleBoxLocal.width,
      node.middleBoxLocal.height,
      node.globalRotationRadians,
    );

    // LOCAL
    node._middleRotatedBoxLocal = RotatedNodeBox(
      middleRotatedBox.left,
      middleRotatedBox.top,
      middleRotatedBox.width,
      middleRotatedBox.height,
      rotationDegrees: node.rotationDegrees,
    );
    node._outerRotatedBoxLocal = node._middleRotatedBoxLocal.copyWith(
      x: node._middleRotatedBoxLocal.left - node.outerBoxGlobal.edgeLeft,
      y: node._middleRotatedBoxLocal.top - node.outerBoxGlobal.edgeTop,
      width: node._middleRotatedBoxLocal.width +
          node.outerBoxGlobal.horizontalEdgeSpace,
      height: node._middleRotatedBoxLocal.height +
          node.outerBoxGlobal.verticalEdgeSpace,
    );

    // GLOBAL
    final middleUnrotatedGlobalTopLeft = getGlobalRotatedBoxTopLeft(node.id,
        boundaryType: NodeBoundaryType.middleBox);

    final RectC middleGlobalRotatedBox = getRotatedBoundingBoxAroundSelf(
      middleUnrotatedGlobalTopLeft.x,
      middleUnrotatedGlobalTopLeft.y,
      node.middleBoxGlobal.width,
      node.middleBoxGlobal.height,
      node.globalRotationRadians,
    );

    node._middleRotatedBoxGlobal = RotatedNodeBox(
      middleGlobalRotatedBox.left,
      middleGlobalRotatedBox.top,
      middleGlobalRotatedBox.width,
      middleGlobalRotatedBox.height,
      rotationDegrees: node.rotationDegrees,
    );

    node._outerRotatedBoxGlobal = node._middleRotatedBoxGlobal.copyWith(
      x: node._middleRotatedBoxGlobal.left - node.outerBoxGlobal.edgeLeft,
      y: node._middleRotatedBoxGlobal.top - node.outerBoxGlobal.edgeTop,
      width: node._middleRotatedBoxGlobal.width +
          node.outerBoxGlobal.horizontalEdgeSpace,
      height: node._middleRotatedBoxGlobal.height +
          node.outerBoxGlobal.verticalEdgeSpace,
    );
  }

  /// [unrotate] will de-rotate the top left point from the literal visual pointy
  /// corner or drag handle of the box to the top left corner that holds all
  /// 4 corners together as bounding box.
  static Vec getGlobalRotatedBoxTopLeft(
    String id, {
    bool unrotate = true,
    required NodeBoundaryType boundaryType,
  }) {
    assert(
      !boundaryType.isRotatedBox,
      "This function is computing the rotated part for you. You can't give it a rotated node boundary type",
    );

    // Our main offset were guiding to the target id.
    Vec currentVec = Vec.zero;

    if (id == kRootNode) return currentVec;

    // First collect the node's and all of it's ancestor's id.
    final List<BaseNode> parents = [];
    String currentId = id;
    while (currentId != kRootNode) {
      final BaseNode currentNode = getNode(currentId);
      parents.add(currentNode);
      currentId = currentNode.parentID;
    }

    // We'll keep track of the global rotation along the way.
    double globalRotation = 0.0;

    // We traverse in parent-child direction.
    // Life is simple until no child is rotated so we try to get as far as we
    // can without expensive calculations by just adding up the offsets
    int index;
    final int parentsSize = parents.length - 1;
    for (index = parentsSize; index >= 0; index--) {
      final BaseNode currentNode = parents[index];
      if (currentNode.rotationDegrees != 0) break;

      final NodeBox box = boundaryType.getLocalBoxForNode(currentNode);

      currentVec += box.topLeft;

      if (boundaryType == NodeBoundaryType.outerBox) {
        final BaseNode parentNode = getNode(currentNode.parentID);

        currentVec += parentNode.outerBoxLocal.edgeTopLeft;
      }
    }

    // We either made it all the way to our id or we encountered a rotated child
    // so if we have anything left we will need to account for rotation too.
    for (int i = index; i >= 0; i--) {
      final BaseNode currentNode = parents[i];

      final NodeBox box = boundaryType.getLocalBoxForNode(currentNode);
      final RectC rect = (box is OuterNodeBox ? box.innerRect : box.rect);

      // Returns local box top left after rotation.
      // This will be the point of the top-left drag handle of this box.
      // IE: The literal visually rotated top left corner.
      //
      // The x/y is NOT yet translated inside the parent's space.
      // That's the next step.
      Vec rotated = calculateRotatedBoxTopLeftAroundSelf(
        radians: currentNode.rotationRadians,
        x1: rect.left,
        y1: rect.top,
        x2: rect.right,
        y2: rect.bottom,
      );

      if (boundaryType == NodeBoundaryType.outerBox) {
        final BaseNode parentNode = getNode(currentNode.parentID);

        if (parentNode.rotationDegrees == 0) {
          currentVec += parentNode.outerBoxLocal.edgeTopLeft;
        }
      }

      // Converting it to global
      rotated = localRotatedVecToGlobalVec(
        localX: rotated.x,
        localY: rotated.y,
        parentX: currentVec.x,
        parentY: currentVec.y,
        radians: globalRotation,
      );

      globalRotation += currentNode.rotationRadians;
      currentVec = rotated;
    }

    // If our target happens to be orthogonal w global
    if (globalRotation == 0 || !unrotate) return currentVec;

    // Otherwise were pointing to an already rotated node which is not too
    // useful for most callers so we make it orthogonal w global.
    final BaseNode node = parents.first;
    final NodeBox box = boundaryType.getLocalBoxForNode(node);
    final SizeC size = (box is OuterNodeBox ? box.innerSize : box.size);

    final Vec unrotated = calculateUnrotatedVecFromRotatedVec(
          x: currentVec.x,
          y: currentVec.y,
          width: size.width,
          height: size.height,
          radians: globalRotation,
        ) -
        (box is OuterNodeBox ? box.edgeTopLeft : Vec.zero);

    return unrotated;
  }
}
