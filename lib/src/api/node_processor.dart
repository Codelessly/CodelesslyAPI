// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

part of 'nodes/base_node.dart';

/// Extensions for [NodeBox].
extension NodeBoxHelper on NodeBox {
  /// Used to update the [NodeBox] with new values. This by default triggers
  /// computation on update.
  /// NodeBox does not hold a reference to the node itself, that's why we need
  /// to pass the [node] as a parameter.
  void update({
    required BaseNode node,
    double? x,
    double? y,
    double? width,
    double? height,
    BoxConstraintsModel? constraintOverrides,
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
      if (constraintOverrides != null) {
        node._resolvedConstraints =
            node._constraints.union(constraintOverrides);
      }
    } else {
      NodeProcessor.updateNode(
        node: node,
        basicBoxLocal: box,
        resolvedConstraints: constraintOverrides,
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
  /// NodeBox does not hold a reference to the node itself, that's why we need
  /// to pass the [node] as a parameter.
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
  /// Switches the parent node of this node from [oldParent] to [newParent].
  void switchParent({
    required BaseNode newParent,
    required BaseNode oldParent,
  }) {
    oldParent.childrenOrEmpty.remove(id);
    newParent.childrenOrEmpty.add(id);
    parentID = newParent.id;
  }

  /// Used to update the [BaseNode] with new values. This by default triggers
  /// computation on update.
  /// See [updateNode] for more details.
  void update({
    EdgeInsetsModel? margin,
    EdgeInsetsModel? padding,
    AlignmentModel? alignment,
    OuterNodeBox? outerBoxLocal,
    OuterNodeBox? outerBoxGlobal,
    NodeBox? middleBoxLocal,
    BoxConstraintsModel? constraints,
    int? rotationDegrees,
    bool resetRetainedBox = true,
    bool recursivelyCalculateChildrenGlobalBoxes = true,
    Vec? globalParentBoundingBoxPos,
    bool updatingSortedNodeList = false,
  }) =>
      NodeProcessor.updateNode(
        node: this,
        margin: margin,
        padding: padding,
        alignment: alignment,
        outerBoxLocal: outerBoxLocal,
        outerBoxGlobal: outerBoxGlobal,
        basicBoxLocal: middleBoxLocal,
        constraints: constraints,
        rotationDegrees: rotationDegrees,
        resetRetainedBox: resetRetainedBox,
        recursivelyCalculateChildrenGlobalBoxes:
            recursivelyCalculateChildrenGlobalBoxes,
        globalParentBoundingBoxPos: globalParentBoundingBoxPos,
        updatingSortedNodeList: updatingSortedNodeList,
      );

  /// Sets rotation for this node.
  void setNodeRotation(int newRotationDegrees) {
    _rotationDegrees = newRotationDegrees;
    _rotationRadians = newRotationDegrees * pi / 180;
  }

  /// Updates rotation for this node recursively for its children as well if
  /// [updateChildren] is true.
  void updateNodeRotation(
    int newRotationDegrees, {
    bool updateChildren = true,
  }) {
    setNodeRotation(newRotationDegrees);

    NodeProcessor.updateGlobalRotation(
      node: this,
      newRotationDegrees: newRotationDegrees,
      updateChildren: updateChildren,
    );
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

  /// There's the normal [constraints] field, but those constraints don't tell
  /// the full story of the provided node's true constraints.
  ///
  /// The [constraints] field is what is manually set by the user. However,
  /// we have additional constraints that are computed for different nodes.
  /// Material components may provide additional internal constraints. Images
  /// may provide their original sizes when shrink-wrapping, ListTiles provide
  /// a minimum size that the leading node must have, etc...
  ///
  /// This function will take the [internalConstraints] and union them to the
  /// [constraints] field to get a reinforced set of constraints.
  ///
  /// This function is recursive and may travel up the parent tree from the
  /// internal [BaseNode.relegatedConstraintsToChildren] function.
  static BoxConstraintsModel resolveConstraints(
    BaseNode node, {
    SizeFit? horizontalFit,
    SizeFit? verticalFit,
  }) {
    BoxConstraintsModel resolved = node.internalConstraints(
      horizontalFit: horizontalFit ?? node.horizontalFit,
      verticalFit: verticalFit ?? node.verticalFit,
    );

    if (node.id != kRootNode) {
      final BaseNode parent = getNode(node.parentID);
      final BoxConstraintsModel? relegatedConstraints =
          parent.relegatedConstraintsToChildren(node);
      if (relegatedConstraints != null) {
        final parentResolved =
            relegatedConstraints.union(resolveConstraints(parent));
        resolved = resolved.union(parentResolved);
      }
    }

    return node.constraints.union(resolved);
  }

  /// Update the global rotation for given [node] with [newRotationDegrees].
  static void updateGlobalRotation({
    required BaseNode node,
    required int newRotationDegrees,
    bool updateChildren = true,
  }) {
    if (node.id == kRootNode) {
      node.globalRotationDegrees = newRotationDegrees;
      node.globalRotationRadians = newRotationDegrees * pi / 180;
      node._rotatedTopLeftCorner = node.middleBoxLocal.topLeft;
    } else {
      final BaseNode parent = getNode(node.parentID);

      node.globalRotationDegrees =
          parent.globalRotationDegrees + newRotationDegrees;
      node.globalRotationRadians = node.globalRotationDegrees * pi / 180;

      node._rotatedTopLeftCorner = calculateGlobalRotatedBoxTopLeft(
        node.id,
        boundaryType: NodeBoundaryType.middleBox,
        unrotate: false,
        updatingSortedNodeList: true,
      );
    }

    if (updateChildren) {
      for (final String childId in node.childrenOrEmpty) {
        final child = getNode(childId);
        updateGlobalRotation(
          node: child,
          newRotationDegrees: child.rotationDegrees,
        );
      }
    }
  }

  /// [Returns] all of the parents of [node]. [node] is not included in the
  /// final result.
  static List<String> _allParentsOfNode(BaseNode node) {
    final List<String> parents = [];

    String currentId = node.parentID;
    while (currentId != kRootNode) {
      final BaseNode currentNode = getNode(currentId);
      parents.add(currentNode.id);
      currentId = currentNode.parentID;
    }

    return parents;
  }

  /// Sorted nodes is a list of nodes that go from parent -> child.
  static void sortNodes(List<BaseNode> nodes) {
    // We cache the parent chains for each node to avoid
    // re-computing them multiple times as an optimization.
    final Map<BaseNode, List<String>> parentChains = {};

    nodes.sort((a, b) {
      if (a.id == kRootNode) return -1;
      if (b.id == kRootNode) return 1;

      final BaseNode aParent = getNode(a.parentID);
      final BaseNode bParent = getNode(b.parentID);

      if (aParent.id == bParent.id) {
        return aParent.childrenOrEmpty.indexOf(a.id) -
            bParent.childrenOrEmpty.indexOf(b.id);
      }

      parentChains.putIfAbsent(a, () => _allParentsOfNode(a));
      parentChains.putIfAbsent(b, () => _allParentsOfNode(b));

      final List<String> aParents = parentChains[a] ?? const [];
      final List<String> bParents = parentChains[b] ?? const [];

      final int aIndex = bParents.indexOf(a.id);
      final int bIndex = aParents.indexOf(b.id);

      if (aIndex == -1 && bIndex == -1) {
        return bParents.indexOf(kRootNode) - aParents.indexOf(kRootNode);
      } else if (bIndex == -1) {
        return -1;
      } else if (aIndex == -1) {
        return 1;
      } else {
        return bIndex - aIndex;
      }
    });
  }

  /// [updateNode] is responsible for updating the node and its children when
  /// one or more of its properties change. Ex. if [margin] is changed, all the
  /// node boxes and node's children are updated accordingly.
  ///
  /// [outerBoxGlobal] and [globalParentBoundingBoxPos] are automatically
  /// updated by the layout system only, while other node boxes and
  /// [rotationDegrees] can be changed manually.
  ///
  /// If [resetRetainedBox] is true, the node's [retainedBox] will be reset to
  /// the [outerBoxLocal].
  ///
  /// If [recursivelyCalculateChildrenGlobalBoxes] is true, all of the node's
  /// children are updated recursively. If it is set to false, only the node is
  /// updated. This parameter is used during node initialization, since all the
  /// nodes are being laid out, there's no need for recursive updates.
  ///
  /// If [updatingSortedNodeList] is true, then you are currently updating a
  /// list of nodes one-by-one from parent to child order. If this is
  /// the case, then we can make important assumptions that can help optimize
  /// and avoid recursive computation.
  ///
  /// [resolvedConstraints] overrides [node.resolvedConstraints] while being
  /// still affected by user-given constraints.
  ///
  /// [EdgePins] are updated if this function is triggered manually, without
  /// the layout system. If the layout system triggers this function, edge pins
  /// are not updated because there were used BY the layout system to figure out
  /// the rest of the values (outer box global, middle box global, etc...).
  static void updateNode({
    required BaseNode node,
    EdgeInsetsModel? margin,
    EdgeInsetsModel? padding,
    AlignmentModel? alignment,
    OuterNodeBox? outerBoxLocal,
    OuterNodeBox? outerBoxGlobal,
    NodeBox? basicBoxLocal,
    BoxConstraintsModel? constraints,
    BoxConstraintsModel? resolvedConstraints,
    int? rotationDegrees,
    bool resetRetainedBox = true,
    bool recursivelyCalculateChildrenGlobalBoxes = true,
    Vec? globalParentBoundingBoxPos,
    bool updatingSortedNodeList = false,
  }) {
    final bool marginChanged = margin != null && margin != node.margin;
    final bool paddingChanged = padding != null && padding != node.padding;
    final bool alignmentChanged =
        alignment != null && alignment != node.alignment;
    final bool performLayoutRan =
        outerBoxGlobal != null && globalParentBoundingBoxPos != null;
    final bool localOuterBoxChanged = outerBoxLocal != null;
    final bool localMiddleBoxChanged = basicBoxLocal != null;
    final bool constraintsChanged = constraints != null;

    if (alignmentChanged) node._alignment = alignment;
    if (marginChanged) node._margin = margin;
    if (paddingChanged) node._padding = padding;
    if (localMiddleBoxChanged) node._basicBoxLocal = basicBoxLocal;
    if (localOuterBoxChanged) node._outerBoxLocal = outerBoxLocal;
    if (outerBoxGlobal != null) node._outerBoxGlobal = outerBoxGlobal;
    if (constraintsChanged) {
      node._constraints = constraints;
    }
    if (resolvedConstraints != null) {
      node._resolvedConstraints = node._constraints.union(resolvedConstraints);
    } else {
      node._resolvedConstraints = resolveConstraints(node);
    }

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

    // If a performLayout was run, the children do not need calculation
    // because they will be updated next.
    _computeGlobalAndRotatedBoxes(
      node,
      recursivelyCalculateChildren:
          !performLayoutRan && recursivelyCalculateChildrenGlobalBoxes,
      updatingSortedNodeList: updatingSortedNodeList,
    );

    _computeInnerBoxLocal(node);
  }

  static void _computeGlobalAndRotatedBoxes(
    BaseNode node, {
    bool recursivelyCalculateChildren = true,
    bool updatingSortedNodeList = false,
  }) {
    // Order matters.
    // Middle and inner boxes depend on outer.
    // Rotated boxes depend on all of them.
    _computeOuterBoxGlobal(
      node,
      updatingSortedNodeList: updatingSortedNodeList,
    );
    _computeMiddleBoxGlobal(node);
    _computeInnerBoxGlobal(node);

    _computeRotatedBoxes(
      node,
      updatingSortedNodeList: updatingSortedNodeList,
    );

    if (recursivelyCalculateChildren) {
      for (final String childID in node.childrenOrEmpty) {
        final BaseNode childNode = getNode(childID);
        _computeGlobalAndRotatedBoxes(
          childNode,
          updatingSortedNodeList: updatingSortedNodeList,
        );
      }
    }
  }

  static void _computeOuterBoxGlobal(
    BaseNode node, {
    bool updatingSortedNodeList = false,
  }) {
    final Vec globalBoundingTopLeft = calculateGlobalRotatedBoxTopLeft(
      node.id,
      unrotate: true,
      boundaryType: NodeBoundaryType.outerBox,
      updatingSortedNodeList: updatingSortedNodeList,
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

  static void _computeRotatedBoxes(
    BaseNode node, {
    bool updatingSortedNodeList = false,
  }) {
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
    final middleUnrotatedGlobalTopLeft = calculateGlobalRotatedBoxTopLeft(
      node.id,
      boundaryType: NodeBoundaryType.middleBox,
      updatingSortedNodeList: updatingSortedNodeList,
    );

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

  /// [unrotate] will unrotate the top-left corner of the rotated box to the
  /// top-left corner of the bounding box.
  ///
  /// if [updatingSortedNodeList] is true, then you are currently updating a
  /// list of nodes one-by-one order from parent to child order. If this is
  /// the case, then we can make important assumptions that can help optimize
  /// and avoid recursive computation.
  static Vec calculateGlobalRotatedBoxTopLeft(
    String id, {
    bool unrotate = true,
    required NodeBoundaryType boundaryType,
    bool updatingSortedNodeList = false,
  }) {
    assert(
      !boundaryType.isRotatedBox,
      "This function is computing the rotated part for you. You can't give it a rotated node boundary type",
    );

    // Our main offset were guiding to the target id.
    Vec currentVec = Vec.zero;

    if (id == kRootNode) return currentVec;

    if (updatingSortedNodeList) {
      return calculateSortedGlobalRotatedBoxTopLeft(
        id,
        unrotate: unrotate,
        boundaryType: boundaryType,
      );
    }

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
    // can without expensive calculations by just adding up the offsets.
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

      // Converting it to global.
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

    // If our target happens to be orthogonal w global.
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

  /// [unrotate] will unrotate the top-left corner of the rotated box to the
  /// top-left corner of the bounding box.
  ///
  /// This function is used when you are updating a list of nodes one-by-one
  /// order from parent to child order. If this is the case, then we can make
  /// important assumptions that can help optimize and avoid recursive
  /// computation.
  static Vec calculateSortedGlobalRotatedBoxTopLeft(
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

    final node = getNode(id);
    final parent = getNode(node.parentID);

    final NodeBox parentBox = parent.id == kRootNode
        ? parent.basicBoxLocal
        : boundaryType.getGlobalBoxForNode(parent);
    final NodeBox nodeBox = boundaryType.getLocalBoxForNode(node);

    currentVec = Vec.zero;

    if (node.globalRotationDegrees == 0) {
      currentVec = parentBox is OuterNodeBox
          ? parentBox.innerTopLeft
          : parentBox.topLeft;

      currentVec += nodeBox.topLeft;
    } else {
      currentVec = parent.rotatedTopLeftCorner;

      final RectC rect =
          (nodeBox is OuterNodeBox ? nodeBox.innerRect : nodeBox.rect);

      // Returns local box top left after rotation.
      // This will be the point of the top-left drag handle of this box.
      // IE: The literal visually rotated top left corner.
      //
      // The x/y is NOT yet translated inside the parent's space.
      // That's the next step.
      Vec rotated = calculateRotatedBoxTopLeftAroundSelf(
        radians: node.rotationRadians,
        x1: rect.left,
        y1: rect.top,
        x2: rect.right,
        y2: rect.bottom,
      );

      if (boundaryType == NodeBoundaryType.outerBox) {
        if (parent.rotationDegrees == 0) {
          currentVec += parent.outerBoxLocal.edgeTopLeft;
        }
      }

      // Converting it to global.
      rotated = localRotatedVecToGlobalVec(
        localX: rotated.x,
        localY: rotated.y,
        parentX: currentVec.x,
        parentY: currentVec.y,
        radians: parent.globalRotationRadians,
      );

      currentVec = rotated;
    }

    // If our target happens to be orthogonal w global.
    if (node.globalRotationDegrees == 0 || !unrotate) return currentVec;

    // Otherwise were pointing to an already rotated node which is not too
    // useful for most callers so we make it orthogonal w global.
    final SizeC size =
        (nodeBox is OuterNodeBox ? nodeBox.innerSize : nodeBox.size);

    final Vec unrotated = calculateUnrotatedVecFromRotatedVec(
          x: currentVec.x,
          y: currentVec.y,
          width: size.width,
          height: size.height,
          radians: node.globalRotationRadians,
        ) -
        (nodeBox is OuterNodeBox ? nodeBox.edgeTopLeft : Vec.zero);

    return unrotated;
  }
}
