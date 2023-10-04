// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

// ignore_for_file: prefer_final_fields

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../constants.dart';
import '../math_helper.dart';
import '../mixins.dart';
import '../models/models.dart';
import '../utils.dart';

part '../node_processor.dart';

/// This is a global flag that is used to determine if the current layout
/// is being tested or not. This is used by the golden tests to render
/// additional information on top of the nodes to help with debugging.
bool kIsTestLayout = false;

/// Base class for all nodes. Any node class must extend this class.
/// This provides base properties of any node like its id, name, size, fits,
/// constraints, etc.
///
/// If you wish to update the values of a node, it is highly recommended you
/// use the [update] extension method or the [updateNode] method inside the
/// [NodeProcessor] class.
abstract class BaseNode
    with SerializableMixin, EquatableMixin, VariablePropertiesMixin {
  /// [type] is a string representation for the type of this node. It is a
  /// unique key that this node class uses for static registration. It is
  /// usually the lowerCamelCase of the class' name. Overriding [type] is
  /// mandatory.
  ///
  /// Example: A [BaseNode] class called [MyNode] would have a [type] of
  /// 'myNode'.
  late final String type;

  /// The unique identifier for this node. Whenever a node is created, [id] is
  /// assigned a unique new string.
  String id;

  /// The name is a human readable string that is assigned when this node
  /// is created. Nodes are created with a default human readable name but can
  /// be modified by users.
  String name;

  /// Whether this node is visible or not.
  bool visible;

  BoxConstraintsModel _constraints;

  /// Constraints apply to the [middleBoxLocal].
  ///
  /// See [BoxConstraintsModel] for more information about constraints.
  @JsonKey(excludeIf: excludeConstraintsIf)
  BoxConstraintsModel get constraints => _constraints;

  late BoxConstraintsModel _resolvedConstraints;

  /// Resolved constraints are the constraints that are actually applied to
  /// the [middleBoxLocal] after all the constraints are resolved.
  ///
  /// This is a runtime-computed value and is not serialized.
  @JsonKey(includeFromJson: false, includeToJson: false)
  BoxConstraintsModel get resolvedConstraints => _resolvedConstraints;

  /// Edge Pins apply to the [outerBoxLocal].
  /// See [EdgePinsModel] for more info on how to define the edge pins.
  @JsonKey(excludeIf: excludeEdgePinsIf)
  EdgePinsModel edgePins;

  /// [PositioningMode] defines if the node positions itself using [alignment]
  /// or [edgePins].
  ///
  /// At any given point, both arguments are properly synchronized and
  /// up-to-date, however, what the widget physically uses is determined by
  /// the values of [edgePins] and [alignment].
  ///
  /// [edgePins] are never null and will always reflect the [middleBoxLocal]
  /// in some way, while [alignment] can have a null data model inside to
  /// indicate freeform (no-alignment) positioning.
  PositioningMode positioningMode;

  /// The horizontal fit of a node determines how this node gets its box laid
  /// out on the horizontal axis.
  ///
  /// See [SizeFit] for more info.
  SizeFit horizontalFit;

  /// The vertical fit of a node determines how this node gets its box laid out
  /// on the vertical axis.
  ///
  /// See [SizeFit] for more info.
  SizeFit verticalFit;

  /// The flex factor to use when this node's [SizeFit] is set to
  /// [SizeFit.expanded] or [SizeFit.flexible].
  ///
  /// It replicates the behavior of Flutter's flex factors and takes effect only
  /// if two or more nodes have a [SizeFit] of [SizeFit.expanded] or
  /// [SizeFit.flexible] in the given [RowColumnNode].
  int flex;

  /// Whether the node preserves its aspect ratio while resizing.
  bool aspectRatioLock;

  /// The ID of the parent of this node.
  ///
  /// This value is not initialized by default (It's set to an empty string),
  /// but it is specified when a project is loaded.
  ///
  /// This field is never stored on the server or json. It is exclusively
  /// specified when a project is loaded through interpretation of the
  /// [children] list instead. This helps avoid deserialization issues.
  @JsonKey(includeFromJson: false, includeToJson: false)
  String parentID;

  AlignmentModel _alignment;

  /// The alignment that this node will use to position itself inside the
  /// [innerBoxLocal] of its parent.
  ///
  /// Replicates Flutter's [Alignment] model with the exception of
  /// non-nullability. If this node does not have an alignment and is
  /// positioning itself purely through freeform coordinates (edge pins), then
  /// this value will have an [AlignmentModel.data] of null, but the model
  /// itself will never be null.
  AlignmentModel get alignment => _alignment;

  OuterNodeBox _outerBoxLocal;

  /// The outer box is the box of this node with margins and strokes expanding
  /// outside of it.
  ///
  /// This box's position is relative to the parent's [middleBoxLocal].
  /// The top left corner of the parent is the (0, 0) point of this box.
  ///
  /// Middle box can be accessed from this box through
  /// OuterNodeBox.innerX/Y/Left/Right/Top/Bottom/Width/Height and the distance
  /// between the outer box and the middle box can be accessed through
  /// OuterNodeBox.edgeLeft/Right/Top/Bottom.
  @JsonKey(includeFromJson: false, includeToJson: false)
  OuterNodeBox get outerBoxLocal => _outerBoxLocal;

  NodeBox _basicBoxLocal;

  /// The basic box, also known as the middle box, is the box of this node
  /// without any margins or strokes expanding outside of it.
  ///
  /// This box's position is relative to the parent's [middleBoxLocal].
  ///
  /// The top left corner of the parent is the (0, 0) point of this box unless
  /// margin/stroke is applied, in which case, the top left corner of the
  /// parent is the (margin.left, margin.top) point of this box.
  NodeBox get basicBoxLocal => _basicBoxLocal;

  /// Alias property getter for [basicBoxLocal].
  NodeBox get middleBoxLocal => _basicBoxLocal;

  late NodeBox _retainedOuterBoxLocal;

  /// This is a tracker box that is used to keep track of the outer box when any
  /// sudden changes to the box occurs.
  ///
  /// For example, if a rectangle is moved inside a canvas and its [SizeFit] is
  /// changed to [SizeFit.expanded], the outer box will expand to fill the
  /// canvas. The [retainedOuterBoxLocal] will keep track of the original
  /// outer box so that when the [SizeFit] is changed back to [SizeFit.fixed],
  /// the outer box will be restored to its original size.
  ///
  /// This is not an essential [NodeBox] and is meant for usage convenience by
  /// the Codelessly editor.
  @JsonKey(includeFromJson: false, includeToJson: false)
  NodeBox get retainedOuterBoxLocal => _retainedOuterBoxLocal;

  late InnerNodeBox _innerBoxLocal;

  /// The inner box is the box of this node with padding shrinking the box
  /// inside of it.
  ///
  /// This box's position is relative to the parent's [middleBoxLocal].
  /// The top left corner of the parent is the (0, 0) point of this box if no
  /// padding is applied, otherwise, it's the amount of padding applied.
  ///
  /// Middle box can be accessed from this box through
  /// InnerNodeBox.outerX/Y/Left/Right/Top/Bottom/Width/Height and the distance
  /// between the inner box and the middle box can be accessed through
  /// InnerNodeBox.edgeLeft/Right/Top/Bottom.
  @JsonKey(includeFromJson: false, includeToJson: false)
  InnerNodeBox get innerBoxLocal => _innerBoxLocal;

  late OuterNodeBox _outerBoxGlobal;

  /// This is the global version of the box as opposed to [outerBoxLocal].
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [outerBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  OuterNodeBox get outerBoxGlobal => _outerBoxGlobal;

  late NodeBox _basicBoxGlobal;

  /// This is the global version of the box as opposed to [middleBoxLocal],
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [middleBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  NodeBox get basicBoxGlobal => _basicBoxGlobal;

  /// Alias property getter for [basicBoxGlobal].
  @JsonKey(includeFromJson: false, includeToJson: false)
  NodeBox get middleBoxGlobal => _basicBoxGlobal;

  late InnerNodeBox _innerBoxGlobal;

  /// This is the global version of the box as opposed to [innerBoxLocal],
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [innerBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  InnerNodeBox get innerBoxGlobal => _innerBoxGlobal;

  late RotatedNodeBox _middleRotatedBoxLocal;

  /// The middle rotated box is the middle box of this node with rotation
  /// applied.
  ///
  /// This box's position is relative to the parent's [middleBoxLocal].
  @JsonKey(includeFromJson: false, includeToJson: false)
  RotatedNodeBox get middleRotatedBoxLocal => _middleRotatedBoxLocal;

  late RotatedNodeBox _middleRotatedBoxGlobal;

  /// This is the global version of the box as opposed to
  /// [middleRotatedBoxLocal].
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [middleRotatedBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  RotatedNodeBox get middleRotatedBoxGlobal => _middleRotatedBoxGlobal;

  late RotatedNodeBox _outerRotatedBoxLocal;

  /// The outer rotated box is the outer box of this node with rotation and
  /// margins applied. It must be noted that the margins remain unrotated.
  ///
  /// This box's position is relative to the parent's [middleBoxLocal].
  ///
  /// The top left corner of the parent is the (0, 0) point of this box.
  ///
  /// Refer to [middleRotatedBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  RotatedNodeBox get outerRotatedBoxLocal => _outerRotatedBoxLocal;

  late RotatedNodeBox _outerRotatedBoxGlobal;

  /// This is the GLOBAL version of the box as opposed to
  /// [outerRotatedBoxLocal].
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [outerRotatedBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  RotatedNodeBox get outerRotatedBoxGlobal => _outerRotatedBoxGlobal;

  late Vec _rotatedTopLeftCorner;

  /// The top left corner of the middle box. This is not
  /// [middleBoxGlobal.topLeft], rather the visual top left corner of the
  /// visually rotated box instead of the point of the bounding box containing
  /// the rotated box.
  ///
  /// This value is calculated at runtime and is used as a means of caching
  /// the value for performance reasons.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Vec get rotatedTopLeftCorner => _rotatedTopLeftCorner;

  EdgeInsetsModel _margin;

  /// The margin applied outside the node.
  ///
  /// Replicates the behavior of Flutter's [Padding] widget.
  EdgeInsetsModel get margin => _margin;

  EdgeInsetsModel _padding;

  /// The padding applied inside the node.
  ///
  /// Replicates the behavior of [padding] property of Flutter's [Container]
  /// widget.
  EdgeInsetsModel get padding => _padding;

  @JsonKey(includeFromJson: false, includeToJson: false)
  int _rotationDegrees;

  /// The rotation in degrees. This is the rotation of the node's
  /// [middleBoxLocal], represented by the [middleRotatedBoxLocal].
  @JsonKey(name: 'rotation', fromJson: castRotation)
  int get rotationDegrees => _rotationDegrees;

  @JsonKey(includeFromJson: false, includeToJson: false)
  double _rotationRadians;

  /// The rotation in radians. It is not stored on the server and is
  /// computed whenever [rotationDegrees] is updated. It is meant purely as
  /// an optimization and convenience.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get rotationRadians => _rotationRadians;

  /// The global rotation in degrees. It is not stored on the server and is
  /// computed whenever [rotationDegrees] is updated. It is meant purely as
  /// an optimization and convenience.
  @JsonKey(includeFromJson: false, includeToJson: false)
  int globalRotationDegrees;

  /// The global rotation in radians. It is not stored on the server and is
  /// computed whenever [rotationDegrees] is updated. It is meant purely as
  /// an optimization and convenience.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double globalRotationRadians;

  /// A simple label for console debugging.
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get debugLabel => '$name [$id]';

  /// Since a lot of nodes don't support padding, the default value is set
  /// to false. Any node that supports padding must override this and and set
  /// it to true.
  ///
  /// Nodes that can't support external padding modifications are [IconNode],
  /// [EmbeddedVideoNode], [WebViewNode], [TextNode], etc.
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get supportsPadding => false;

  /// Width of the node in fraction of the parent's width.
  /// [widthFactor] of [0.5] means that the node will be half the width of its
  /// parent.
  double? widthFactor;

  /// Height of the node in fraction of the parent's height.
  /// [heightFactor] of [0.5] means that the node will be half the height of its
  /// parent.
  double? heightFactor;

  /// Whether the node is sized in fraction of the parent's size.
  bool get isFractionallySized => widthFactor != null || heightFactor != null;

  /// Whether the node's width is sized in fraction of the parent's width.
  bool get isFractionallySizedHorizontally => widthFactor != null;

  /// Whether the node's height is sized in fraction of the parent's height.
  bool get isFractionallySizedVertically => heightFactor != null;

  /// Default constructor of this class.
  BaseNode({
    required this.id,
    required this.name,
    required NodeBox basicBoxLocal,
    OuterNodeBox? outerBoxLocal,
    NodeBox? retainedOuterBoxLocal,
    this.visible = true,
    int rotationDegrees = 0,
    AlignmentModel alignment = AlignmentModel.none,
    EdgeInsetsModel margin = EdgeInsetsModel.zero,
    EdgeInsetsModel padding = EdgeInsetsModel.zero,
    this.horizontalFit = SizeFit.fixed,
    this.verticalFit = SizeFit.fixed,
    this.flex = 1,
    BoxConstraintsModel constraints = const BoxConstraintsModel(),
    this.edgePins = EdgePinsModel.standard,
    this.aspectRatioLock = false,
    this.positioningMode = PositioningMode.align,
    this.parentID = '',
    this.widthFactor,
    this.heightFactor,
    Map<String, String>? variables,
    Map<String, List<String>>? multipleVariables,
  })  : _basicBoxLocal = basicBoxLocal,
        _rotationDegrees = rotationDegrees,
        globalRotationDegrees = rotationDegrees,
        _rotationRadians = rotationDegrees * pi / 180,
        globalRotationRadians = rotationDegrees * pi / 180,
        _margin = margin,
        _alignment = alignment,
        _constraints = constraints,
        _padding = padding,
        _outerBoxLocal = (outerBoxLocal ??
            OuterNodeBox.fromMiddleBox(basicBoxLocal, edgeInsets: margin)) {
    _retainedOuterBoxLocal =
        (retainedOuterBoxLocal ?? _outerBoxLocal.copyWith());
    _outerBoxGlobal = _outerBoxLocal.copyWith();
    _basicBoxGlobal = NodeBox(
      _outerBoxGlobal.innerLeft,
      _outerBoxGlobal.innerTop,
      _outerBoxGlobal.innerWidth,
      _outerBoxGlobal.innerHeight,
    );
    _rotatedTopLeftCorner = middleBoxLocal.topLeft;

    _resolvedConstraints = _constraints;

    NodeProcessor._computeInnerBoxLocal(this);
    NodeProcessor._computeInnerBoxGlobal(this);
    setVariablesMixin(
        variables: variables, multipleVariables: multipleVariables);
  }

  /// The minimum internal size is the size that this node
  /// is not allowed to go below.
  ///
  /// Many Material widgets have an internal size that is not transparently
  /// accessible. For example, a Flutter material [TextButton] widget has an
  /// internal size that is equal to the icon inside as well as some fixed
  /// padding numbers that cannot be modified.
  ///
  /// Since these values cannot be directly accessed, [minimumInternalSize]
  /// helps the layout system compute the minimum size of the node.
  ///
  /// [horizontalFit] and [verticalFit] are used to determine what type of
  /// numbers [internalConstraints] should use. It will normally use this
  /// node's [horizontalFit] and [verticalFit] if not provided. These two
  /// SizeFits properties are mainly overridden to determine the validity of
  /// certain layout changes. For example, nodes with image fills change their
  /// constraints based on if they are shrink-wrapping or not.
  ///
  /// More examples are [LoadingIndicatorNode], [DropdownNode], [SliderNode],
  /// [DividerNode], [AppBarNode], [NavigationBarNode], and nodes with
  /// images with particular [SizeFit]s or crop data applied through
  /// [GeometryMixin].
  BoxConstraintsModel internalConstraints({
    required SizeFit horizontalFit,
    required SizeFit verticalFit,
  }) =>
      const BoxConstraintsModel();

  /// The value that this node's padding cannot shrink below. Similar to
  /// [internalConstraints] but is not used for the same purpose. Strokes
  /// consider internal padding through [GeometryMixin] as well as
  /// [LoadingIndicatorNode], [ListTileNode], and [ExpansionTileNode].
  ///
  /// The reason this is separate from [padding] is because [padding] can be
  /// modified by users while the internal padding is padding that is fixed,
  /// static, and unchanging. It is independent of the normal padding.
  EdgeInsetsModel minimumPadding() => EdgeInsetsModel.zero;

  /// Returns ideal default padding for the node.
  ///
  /// For example, when it comes to icon buttons, this is used when the
  /// button's type, shape, or size fits change to allow the button to adjust
  /// its padding to fit the new type, shape, or size.
  /// Because if an icon button suddenly wraps with zero padding, it shows
  /// only the icon, which is not ideal. So, [preferredDefaultPadding] is used
  /// to set a default padding when that property changes.
  ///
  /// When this is null, the padding is unaffected while editor operations
  /// are performed. If it is not null, the returned padding is enforced onto
  /// the node when editor operations are performed.
  EdgeInsetsModel? preferredDefaultPadding() => null;

  /// We have the [padding] field, but we also have an [minimumPadding] field.
  ///
  /// This function will resolve the maximum of every side of [minimumPadding]
  /// to the [padding] field to get a complete picture of the padding.
  EdgeInsetsModel resolvedPadding([EdgeInsetsModel? padding]) {
    return (padding ?? _padding).max(minimumPadding());
  }

  /// A convenience getter to get the list of children of this node.
  /// Normally, if a node supports children, it has to extend [ChildrenMixin],
  /// but it is cumbersome to always check if the type of a node extends
  /// [ChildrenMixin] before accessing the children list. This getter is a
  /// convenience getter that will return an empty list if the node does not
  /// support children.
  List<String> get childrenOrEmpty =>
      (this is ChildrenMixin) ? (this as ChildrenMixin).children : <String>[];

  /// Whether this node has reached both its minimum height and width.
  bool get isAtMinimumSize => isAtMinWidth && isAtMinHeight;

  /// Whether this node has reached both its maximum height and width.
  bool get isAtMaximumSize => isAtMaxWidth && isAtMaxHeight;

  /// Whether the height of this node is at the maximum height it can be.
  /// This is always false if no maxHeight constraint is set.
  bool get isAtMaxHeight =>
      resolvedConstraints.maxHeight != null &&
      middleBoxLocal.height >= resolvedConstraints.maxHeight!;

  /// Whether the width of this node is at the maximum width it can be.
  /// This is always false if no maxHeight constraint is set.
  bool get isAtMaxWidth =>
      resolvedConstraints.maxWidth != null &&
      middleBoxLocal.width >= resolvedConstraints.maxWidth!;

  /// Whether the height of this node is at the minimum height it can be.
  /// This is always false if no maxHeight constraint is set.
  bool get isAtMinHeight =>
      resolvedConstraints.minHeight != null &&
      middleBoxLocal.height <= resolvedConstraints.minHeight!;

  /// Whether the width of this node is at the minimum width it can be.
  /// This is always false if no maxHeight constraint is set.
  bool get isAtMinWidth =>
      resolvedConstraints.minWidth != null &&
      middleBoxLocal.width <= resolvedConstraints.minWidth!;

  /// Determines whether this node relegates internal constraints to its
  /// children.
  ///
  /// This is used in places where a node needs to apply runtime internal
  /// constraints on its children. For example, [ListTile]s have a
  /// minLeadingWidth field that is enforced on the leading widget.
  ///
  /// The leading widget, however, is a [SinglePlaceholderNode] instead of the
  /// leading node directly. So the [SinglePlaceholderNode] needs to relegate
  /// its own constraints onto its child.
  BoxConstraintsModel? relegatedConstraintsToChildren(BaseNode child) => null;

  /// Returns the relevant [NodeBox] given the [NodeBoundaryType] and the
  /// [PositioningSpace] desired.
  ///
  /// This is a convenience function meant for programmatic use.
  NodeBox getBox({
    required NodeBoundaryType type,
    required PositioningSpace space,
  }) =>
      switch (space) {
        PositioningSpace.local => switch (type) {
            NodeBoundaryType.outerBox => outerBoxLocal,
            NodeBoundaryType.innerBox ||
            NodeBoundaryType.innerRotatedBox =>
              innerBoxLocal,
            NodeBoundaryType.middleBox => basicBoxLocal,
            NodeBoundaryType.outerRotatedBox => outerRotatedBoxGlobal,
            NodeBoundaryType.middleRotatedBox => middleRotatedBoxLocal,
          },
        PositioningSpace.global => switch (type) {
            NodeBoundaryType.outerBox => outerBoxGlobal,
            NodeBoundaryType.innerBox ||
            NodeBoundaryType.innerRotatedBox =>
              innerBoxGlobal,
            NodeBoundaryType.middleBox => basicBoxGlobal,
            NodeBoundaryType.outerRotatedBox => outerRotatedBoxGlobal,
            NodeBoundaryType.middleRotatedBox => middleRotatedBoxGlobal,
          }
      };

  /// A convenience function that will take a [value] and constraint it
  /// using the [resolvedConstraints] function.
  ///
  /// The value is going to be constrained according to the node's [middleBox]
  SizeC constrainSize(
    SizeC value, {
    required NodeBoundaryType nodeBoundaryType,
  }) =>
      SizeC(
        constrainValue(
          value.width,
          AxisC.horizontal,
          nodeBoundaryType: nodeBoundaryType,
        ),
        constrainValue(
          value.height,
          AxisC.vertical,
          nodeBoundaryType: nodeBoundaryType,
        ),
      );

  double _convertMiddleSizeToBoundary(
    double value,
    AxisC axis, {
    required NodeBoundaryType nodeBoundaryType,
  }) =>
      switch (nodeBoundaryType) {
        NodeBoundaryType.middleBox ||
        NodeBoundaryType.middleRotatedBox =>
          value,
        NodeBoundaryType.innerBox || NodeBoundaryType.innerRotatedBox => value -
            (axis.isHorizontal
                ? innerBoxLocal.horizontalEdgeSpace
                : innerBoxLocal.verticalEdgeSpace),
        NodeBoundaryType.outerBox || NodeBoundaryType.outerRotatedBox => value +
            (axis.isHorizontal
                ? outerBoxLocal.horizontalEdgeSpace
                : outerBoxLocal.verticalEdgeSpace)
      };

  /// A convenience function that will take a [value] and constrain it
  /// using the [resolvedConstraints] of this node.
  ///
  /// Since constraints represent both width and height of a given node, this
  /// function also takes an [axis] to indicate which axis to constrain the
  /// [value].
  ///
  /// It takes an additional [nodeBoundaryType] to indicate which [NodeBox]
  /// to use to constrain the desired [value]. You may want to constrain
  /// some arbitrary [value] based on the outer box, the middle box, the inner
  /// box, the outer rotated box, or the middle rotated box, or the inner
  /// rotated box.
  ///
  /// [horizontalFit] and [verticalFit] are used to determine what type of
  /// numbers [internalConstraints] should use. It will normally use this
  /// node's [horizontalFit] and [verticalFit] but they can be overridden
  ///
  /// Returns the constrained value that cannot exceed the total constraints of
  /// this node.
  ///
  /// The [resolvedConstraints] are relative to the node's [middleBox]
  double constrainValue(
    double value,
    AxisC axis, {
    required NodeBoundaryType nodeBoundaryType,
  }) {
    switch (axis) {
      case AxisC.horizontal:
        final double minWidth = _convertMiddleSizeToBoundary(
          resolvedConstraints.minWidth ?? 0,
          axis,
          nodeBoundaryType: nodeBoundaryType,
        );
        final double maxWidth = _convertMiddleSizeToBoundary(
          resolvedConstraints.maxWidth ?? double.infinity,
          axis,
          nodeBoundaryType: nodeBoundaryType,
        );

        return value.clamp(minWidth, maxWidth);
      case AxisC.vertical:
        final double minHeight = _convertMiddleSizeToBoundary(
          resolvedConstraints.minHeight ?? 0,
          axis,
          nodeBoundaryType: nodeBoundaryType,
        );
        final double maxHeight = _convertMiddleSizeToBoundary(
          resolvedConstraints.maxHeight ?? double.infinity,
          axis,
          nodeBoundaryType: nodeBoundaryType,
        );

        return value.clamp(minHeight, maxHeight);
    }
  }

  /// If this node has minimum constraints, it returns its minimum possible size
  /// given those values. Otherwise, it returns the [value] passed, indicating
  /// that this node has no leeway to shrink.
  ///
  /// No leeway to shrink means that this node has not reached its minimum size
  /// just yet (not account for its children).
  double hasLeewayToShrink(
    double value,
    AxisC axis, {
    required NodeBoundaryType type,
    SizeFit? horizontalFit,
    SizeFit? verticalFit,
  }) {
    final BoxConstraintsModel minInnerSize = internalConstraints(
      horizontalFit: horizontalFit ?? this.horizontalFit,
      verticalFit: verticalFit ?? this.verticalFit,
    );

    final double horizontalEdgeSpace, verticalEdgeSpace;
    switch (type) {
      case NodeBoundaryType.middleBox:
      case NodeBoundaryType.middleRotatedBox:
        horizontalEdgeSpace = innerBoxLocal.horizontalEdgeSpace;
        verticalEdgeSpace = innerBoxLocal.verticalEdgeSpace;
        break;
      case NodeBoundaryType.outerBox:
      case NodeBoundaryType.outerRotatedBox:
        horizontalEdgeSpace = outerBoxLocal.horizontalEdgeSpace +
            innerBoxLocal.horizontalEdgeSpace;
        verticalEdgeSpace =
            outerBoxLocal.verticalEdgeSpace + innerBoxLocal.verticalEdgeSpace;
        break;
      case NodeBoundaryType.innerBox:
      case NodeBoundaryType.innerRotatedBox:
        horizontalEdgeSpace = -innerBoxLocal.horizontalEdgeSpace;
        verticalEdgeSpace = -innerBoxLocal.verticalEdgeSpace;
        break;
    }

    switch (axis) {
      case AxisC.horizontal:
        if (resolvedConstraints.minWidth != null) {
          final constrainedMinWidth = (minInnerSize.minWidth ?? 0) +
              (resolvedConstraints.minWidth ?? 0);

          return constrainedMinWidth + horizontalEdgeSpace;
        }
        return value;
      case AxisC.vertical:
        if (resolvedConstraints.minHeight != null) {
          final constrainedMinHeight = (minInnerSize.minHeight ?? 0) +
              (resolvedConstraints.minHeight ?? 0);

          return constrainedMinHeight + verticalEdgeSpace;
        }
        return value;
    }
  }

  /// This function will set the [alignment] to [AlignmentModel.none], and the
  /// [edgePins] to [EdgePinsModel.standard] (top left).
  void clearAlignmentAndPins() {
    _alignment = AlignmentModel.none;
    edgePins = EdgePinsModel.standard;
    positioningMode = PositioningMode.align;
  }

  @override
  List<Object?> get props => [id];
}
