// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

// ignore_for_file: prefer_final_fields

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../api.dart';

part '../node_processor.dart';

/// This is a global flag that is used to determine if the current layout
/// is being tested or not. This is used to determine if the [BaseNode]
bool isTestLayout = false;

/// Base class for all nodes. Any node class must extend this class.
/// This provides base properties of any node like its id, name, size, fits,
/// constraints, etc.
///
/// If you wish to update the values of a node, it is highly recommended you
/// use the [update] extension method or the [updateNode] method inside the
/// [NodeProcessor] class.
abstract class BaseNode with SerializableMixin, EquatableMixin {
  /// The type is a unique string representation/identifier for this node.
  /// It is essentially the unique key that this node will use for static
  /// registration. It is usually the lowerCamelCase of the class's name.
  ///
  /// Example: A [BaseNode] class called MyCoolNode would have a [type] of
  ///          'myCoolNode'.
  ///
  /// This field MUST ALWAYS BE OVERRIDDEN in the child class.
  late final String type;

  /// The unique identifier for this node. Whenever a node is created, it will
  /// assign this to a random unique string.
  String id;

  /// The name is a human readable string that is assigned when this node
  /// is created. Nodes are often created with a default human readable name,
  /// but if multiple of this node exist in one place, we try to append
  /// a number to the end of the name to make it unique so that it is
  /// easily distinguishable from other nodes of the same type.
  ///
  /// But it is still purely meant for visual purposes and can even be
  /// modified by users.
  String name;

  /// A simple bool that indicates whether this node is visible in the editor
  /// or hidden.
  ///
  /// Determines if the widget that is produced from this node
  /// through the [codelessly_sdk] is wrapped in a [Visibility] widget.
  bool visible;

  /// Since a lot of components can't support padding, the default value is set
  /// to false. Any node that supports padding must override this and and set
  /// it to true. Otherwise, the padding control won't show up in the editor.
  ///
  /// Nodes that can't support external padding modifications are like
  /// [EmbeddedVideoNode], [WebviewNode], [IconNode], [TextNode], etc.
  final bool supportsPadding = false;

  /// Constraints apply to the [middleBoxLocal]
  /// See [BoxConstraintsModel] for more info on how to define the
  /// constraints.
  BoxConstraintsModel constraints;

  /// Edge Pins apply to the [outerBoxLocal].
  /// See [EdgePinsModel] for more info on how to define the edge pins.
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
  ///
  /// This field does nothing computationally and is simply used to track
  /// the desired UI state of the node inside the Codelessly editor, showing
  /// the alignment UI or the edge pins UI depending on the value of this
  /// field.
  PositioningMode positioningMode;

  /// The horizontal fit of a node determines how this node gets its box laid
  /// out on the horizontal axis.
  ///
  /// See [SizeFit] for more info.
  SizeFit horizontalFit;

  /// The vertical fit of a node determines how this node gets its box laid
  /// out on the vertical axis.
  ///
  /// See [SizeFit] for more info.
  SizeFit verticalFit;

  /// The flex factor to use when this node's [SizeFit] is set to
  /// [SizeFit.expanded] or [SizeFit.flexible].
  ///
  /// It's behavior is 1-1 with how Flutter handles flex factors and only really
  /// takes effect if at least two or more nodes have a [SizeFit] of
  /// [SizeFit.expanded] or [SizeFit.flexible] in a given [RowColumnNode].
  ///
  /// You can think of it as "how much space does this node want to take up
  /// relative to the other nodes that are also set to [SizeFit.expanded] or
  /// [SizeFit.flexible]?". The higher the flex factor, the more space it will
  /// take up.
  int flex;

  /// This determines if the aspect ratio of the node is locked or not.
  ///
  /// It does not handle logic, but it signals to the layout system and to the
  /// editor selection rectangle that the aspect ratio is locked and should be
  /// respected.
  bool aspectRatioLock;

  /// The ID of the parent of this node. Or the ID of the node that this node
  /// is a child of.
  ///
  /// This value is not initialized by default (It's set to an empty string),
  /// but it is specified when a project is loaded.
  ///
  /// This field is never stored on the server or json. It is exclusively
  /// specified when a project is loaded through interpretation of the
  /// [children] list instead. The reasoning behind this is that it avoids
  /// deserialization issues.
  @JsonKey(includeFromJson: false, includeToJson: false)
  String parentID;

  AlignmentModel _alignment;

  /// The alignment that this node will use to position itself inside the
  /// [innerBoxLocal] of its parent.
  ///
  /// This is 1-1 with Flutter's [Alignment] model with the exception of
  /// non-nullability. If this node does NOT have an alignment and is
  /// positioning itself purely through freeform coordinates (edge pins), then
  /// this value will have an [AlignmentModel.data] of null, but the model
  /// itself will never be null.
  AlignmentModel get alignment => _alignment;

  OuterNodeBox _outerBoxLocal;

  /// The outer box is the box of this node with margins and strokes expanding
  /// outside of it. In the Codelessly editor, for a node with margin, it is the
  /// green boundary that renders outside of its selection rectangle.
  ///
  /// This is the LOCAL version of the box as opposed to [outerBoxGlobal],
  /// meaning that the box is relative to the parent's [middleBoxLocal].
  /// The top left corner of the parent is the (0, 0) point of this box.
  ///
  /// You can access the middle box from this box through
  /// OuterNodeBox.innerX/Y/Left/Right/Top/Bottom/Width/Height and you can
  /// access the distance between the outer box and the middle box through
  /// OuterNodeBox.edgeLeft/Right/Top/Bottom.
  OuterNodeBox get outerBoxLocal => _outerBoxLocal;

  NodeBox _basicBoxLocal;

  /// The basic box, also known as the middle box, is the box of this node
  /// without any margins or strokes expanding outside of it. In the Codelessly
  /// editor, this is the selection rectangle that is rendered around the node.
  ///
  /// This is the LOCAL version of the box as opposed to [middleBoxGlobal],
  /// meaning that the box is relative to the parent's [middleBoxLocal].
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
  /// For example, if you take a rectangle inside a canvas and change its
  /// [SizeFit] to [SizeFit.expanded], the outer box will expand to fill the
  /// canvas. the [retainedOuterBoxLocal] will keep track of the original
  /// outer box so that when the [SizeFit] is changed back to [SizeFit.fixed],
  /// the outer box will be restored to its original size.
  ///
  /// This is not an essential [NodeBox] and is meant for usage convenience by
  /// the Codelessly editor.
  @JsonKey(includeFromJson: false, includeToJson: false)
  NodeBox get retainedOuterBoxLocal => _retainedOuterBoxLocal;

  late InnerNodeBox _innerBoxLocal;

  /// The inner box is the box of this node with padding shrinking the box
  /// inside of it. In the Codelessly editor, for a node with padding, it is the
  /// orange boundary that renders inside of its selection rectangle.
  ///
  /// This is the LOCAL version of the box as opposed to [innerBoxGlobal],
  /// meaning that the box is relative to the parent's [middleBoxLocal].
  /// The top left corner of the parent is the (0, 0) point of this box if no
  /// padding is applied, otherwise, it's the amount of padding applied.
  ///
  /// You can access the middle box from this box through
  /// InnerNodeBox.outerX/Y/Left/Right/Top/Bottom/Width/Height and you can
  /// access the distance between the inner box and the middle box through
  /// InnerNodeBox.edgeLeft/Right/Top/Bottom.
  @JsonKey(includeFromJson: false, includeToJson: false)
  InnerNodeBox get innerBoxLocal => _innerBoxLocal;

  late OuterNodeBox _outerBoxGlobal;

  /// This is the GLOBAL version of the box as opposed to [outerBoxLocal],
  /// meaning that the box is relative to the global coordinate system.
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [outerBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  OuterNodeBox get outerBoxGlobal => _outerBoxGlobal;

  late NodeBox _basicBoxGlobal;

  /// This is the GLOBAL version of the box as opposed to [middleBoxLocal],
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

  /// This is the GLOBAL version of the box as opposed to [innerBoxLocal],
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [innerBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  InnerNodeBox get innerBoxGlobal => _innerBoxGlobal;

  late RotatedNodeBox _middleRotatedBoxLocal;

  /// The middle rotated box is the box of this node with rotation applied.
  /// In the Codelessly editor, it is the smallest box you can make when you
  /// rotate a node. To see it in action, rotate a node and observe the very
  /// thin outline around the rotated selection rectangle.
  ///
  /// This is the LOCAL version of the box as opposed to
  /// [middleRotatedBoxGlobal], meaning that the box is relative to the parent's
  /// [middleBoxLocal].
  @JsonKey(includeFromJson: false, includeToJson: false)
  RotatedNodeBox get middleRotatedBoxLocal => _middleRotatedBoxLocal;

  late RotatedNodeBox _middleRotatedBoxGlobal;

  /// This is the GLOBAL version of the box as opposed to
  /// [middleRotatedBoxLocal], meaning that the box is relative to the global
  /// coordinate system.
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [middleRotatedBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  RotatedNodeBox get middleRotatedBoxGlobal => _middleRotatedBoxGlobal;

  late RotatedNodeBox _outerRotatedBoxLocal;

  /// The outer rotated box is the box of this node with rotation and margins
  /// applied. It must be noted that the margin is NOT rotated, rather only
  /// the node's middle box only.
  ///
  /// To see it in action, rotate a node with margin and observe the very
  /// thin outline that is holding both the rotated selection box AND the
  /// green margin regions.
  ///
  /// This is the LOCAL version of the box as opposed to
  /// [outerRotatedBoxGlobal], meaning that the box is relative to the parent's
  /// [middleBoxLocal].
  ///
  /// The top left corner of the parent is the (0, 0) point of this box.
  ///
  /// Refer to [middleRotatedBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  RotatedNodeBox get outerRotatedBoxLocal => _outerRotatedBoxLocal;

  late RotatedNodeBox _outerRotatedBoxGlobal;

  /// This is the GLOBAL version of the box as opposed to
  /// [outerRotatedBoxLocal], meaning that the box is relative to the global
  /// coordinate system.
  ///
  /// The top left corner of the [RootNode] is the (0, 0) point of this box.
  ///
  /// Refer to [outerRotatedBoxLocal] for more info.
  @JsonKey(includeFromJson: false, includeToJson: false)
  RotatedNodeBox get outerRotatedBoxGlobal => _outerRotatedBoxGlobal;

  EdgeInsetsModel _margin;

  /// The margin to apply to the outer space of the node. You can think of this
  /// as wrapping a Flutter widget with a [Padding] widget. Or, more accurately,
  /// specifying the [Container.margin] property inside the [Container] widget.
  ///
  /// The thematics are correct, but Flutter's [Padding] widget may be confusing
  /// because we also have a [padding] property but it is the INNER padding
  /// of the node. This is the OUTER "padding" of the node. In UI/UX design,
  /// this "outer" padding is called the "margin".
  EdgeInsetsModel get margin => _margin;

  EdgeInsetsModel _padding;

  /// The padding to apply to the inner space of the node. You can think of this
  /// as wrapping the child of a Flutter [Container] widget with a [Padding]
  /// widget. Or, more accurately, specifying the [Container.padding] property
  /// inside the [Container] widget.
  ///
  /// The thematics are correct, but Flutter's [Padding] widget may be confusing
  /// because we also have a [margin] property but it is the OUTER padding
  /// of the node. This is the INNER "padding" of the node. In UI/UX design,
  /// this "inner" padding is called the "padding".
  EdgeInsetsModel get padding => _padding;

  @JsonKey(includeFromJson: false, includeToJson: false)
  int _rotationDegrees;

  /// The rotation in degrees. This is the rotation of the node's
  /// [middleBoxLocal], but the [middleBoxLocal] does NOT represent this
  /// rotation. This rotation is represented by the [middleRotatedBoxLocal].
  /// which is computed USING [middleBoxLocal] and this rotation.
  @JsonKey(name: 'rotation', fromJson: castRotation)
  int get rotationDegrees => _rotationDegrees;

  @JsonKey(includeFromJson: false, includeToJson: false)
  double _rotationRadians;

  /// The rotation in radians. This is computed whenever [rotationDegrees] is
  /// updated and is meant purely as an optimization and convenience.
  ///
  /// It is not stored on the server.
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

  /// A bool that is used to render the id of a node in the center. This is used
  /// by our golden tests.
  @Deprecated('No longer used')
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool renderDebugInfo = false;

  /// A simple label for easy console debugging.
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get debugLabel => '$name [$id]';

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
    this.constraints = const BoxConstraintsModel(),
    this.edgePins = EdgePinsModel.standard,
    this.aspectRatioLock = false,
    this.positioningMode = PositioningMode.align,
    this.parentID = '',
  })  : _basicBoxLocal = basicBoxLocal,
        _rotationDegrees = rotationDegrees,
        globalRotationDegrees = rotationDegrees,
        _rotationRadians = rotationDegrees * pi / 180,
        globalRotationRadians = rotationDegrees * pi / 180,
        _margin = margin,
        _alignment = alignment,
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

    NodeProcessor._computeInnerBoxLocal(this);
    NodeProcessor._computeInnerBoxGlobal(this);
  }

  /// The minimum internal size is the red-line minimum size that this node
  /// is not allowed to go below. Many Material widgets have an internal size
  /// that is not transparently accessible. For example, a Flutter material
  /// [TextButton] widget has an internal size that is equal to the icon inside
  /// as well as some fixed padding numbers that cannot be modified.
  ///
  /// Since we cannot access those values for the layout system to utilize
  /// directly, we just signal to the layout system that this node has a
  /// minimum internal size that it cannot go below. The layout system will
  /// then use this value to compute the minimum size of the node.
  ///
  /// [horizontalFit] and [verticalFit] are used to determine what type of
  /// numbers [minimumInternalSize] should use. It will normally use this
  /// node's [horizontalFit] and [verticalFit] but you can override it if
  /// you want.
  ///
  /// More examples are [LoadingIndicatorNode], [DropdownNode], [SliderNode],
  /// [DividerNode], [AppBarNode], [NavigationBarNode], and nodes with
  /// images with particular [SizeFit]s or crop data applied through
  /// [GeometryMixin].
  SizeC minimumInternalSize({
    required SizeFit horizontalFit,
    required SizeFit verticalFit,
  }) =>
      SizeC.zero;

  /// The internal padding is a very normal padding that this node's padding
  /// cannot shrink below. This is very similar to [minimumInternalSize] but
  /// is not used for the same purpose. Strokes are considered internal padding
  /// through [GeometryMixin] as well as [LoadingIndicatorNode], [ListTileNode],
  /// and [ExpansionTileNode].
  ///
  /// The reason this is separate from [padding] is because [padding] can be
  /// modified by users while the internal padding is padding that is fixed,
  /// static, and unchanging. It is independent of the normal padding.
  EdgeInsetsModel minimumPadding() => EdgeInsetsModel.zero;

  /// Returns what this node would like its padding to be ideally to look
  /// good.
  ///
  /// For example, when it comes to icon buttons, this is used when the
  /// button's type, shape, or size fits change to allow the button to adjust
  /// its padding to fit the new type, shape, or size.
  /// Because if an icon button suddenly shrinkwraps with zero padding, it's
  /// going to take on a very ugly form that's the size of the icon without any
  /// padding around it, so we use this to set a default padding to it when
  /// that property changes.
  ///
  /// When this is null, the padding is unaffected while editor operations
  /// are performed. If it is not null, the returned padding is enforced onto
  /// the node when editor operations are performed.
  EdgeInsetsModel? preferredDefaultPadding() => null;

  /// A convenience getter to get the list of children of this node.
  /// Normally, if a node supports children, it has to extend [ChildrenMixin],
  /// but it is cumbersome to always check if the type of a node extends
  /// [ChildrenMixin] before accessing the children list. This getter
  /// is a convenience getter that will return an empty list if the node
  /// does not support children.
  List<String> get childrenOrEmpty =>
      (this is ChildrenMixin) ? (this as ChildrenMixin).children : <String>[];

  /// A convenience getter.
  bool get isAtMinimumSize => isAtMinWidth && isAtMinHeight;

  /// A convenience getter.
  bool get isAtMaximumSize => isAtMaxWidth && isAtMaxHeight;

  /// Whether the height of this node is at the maximum height it can be.
  /// This is always false if no maxHeight constraint is set.
  bool get isAtMaxHeight {
    final BoxConstraintsModel constraints = resolvedConstraints();
    return constraints.maxHeight != null &&
        outerBoxLocal.height >=
            (constraints.maxHeight! + outerBoxLocal.verticalEdgeSpace);
  }

  /// Whether the width of this node is at the maximum width it can be.
  /// This is always false if no maxHeight constraint is set.
  bool get isAtMaxWidth {
    final BoxConstraintsModel constraints = resolvedConstraints();
    return constraints.maxWidth != null &&
        outerBoxLocal.width >=
            (constraints.maxWidth! + outerBoxLocal.horizontalEdgeSpace);
  }

  /// Whether the height of this node is at the minimum height it can be.
  /// This is always false if no maxHeight constraint is set.
  bool get isAtMinHeight {
    final BoxConstraintsModel constraints = resolvedConstraints();
    return constraints.minHeight != null &&
        outerBoxLocal.height <=
            (constraints.minHeight! + outerBoxLocal.verticalEdgeSpace);
  }

  /// Whether the width of this node is at the minimum width it can be.
  /// This is always false if no maxHeight constraint is set.
  bool get isAtMinWidth {
    final BoxConstraintsModel constraints = resolvedConstraints();
    return constraints.minWidth != null &&
        outerBoxLocal.width <=
            (constraints.minWidth! + outerBoxLocal.horizontalEdgeSpace);
  }

  /// We have the normal [constraints] field, but it does not tell the full
  /// story of this node. The [constraints] field is what is manually set
  /// by the user. However, we have additional constraints that are computed
  /// for different nodes. Material components may provide additional internal
  /// constraints. Images may provide their original sizes when shrink-wrapping,
  /// etc...
  ///
  /// This function will take the [minimumInternalSize] and add it to the
  /// [constraints] field to get a complete picture of the constraints.
  BoxConstraintsModel resolvedConstraints({
    SizeFit? horizontalFit,
    SizeFit? verticalFit,
  }) {
    final SizeC minInnerSize = minimumInternalSize(
      horizontalFit: horizontalFit ?? this.horizontalFit,
      verticalFit: verticalFit ?? this.verticalFit,
    );

    return constraints.add(minInnerSize);
  }

  /// We have the [padding] field, but we also have an [minimumPadding] field.
  ///
  /// This function will resolve the maximum of every side of [minimumPadding]
  /// to the [padding] field to get a complete picture of the padding.
  EdgeInsetsModel resolvedPadding([EdgeInsetsModel? padding]) {
    return (padding ?? _padding).max(minimumPadding());
  }

  /// A convenience function that will take a [value] and constraint it
  /// using the [resolvedConstraints] function.
  ///
  /// It takes an additional [nodeBoundaryType] to indicate WHICH [NodeBox]
  /// to use to constrain the desired [value]. You may want to constrain
  /// some arbitrary [value] based on the outer box, the middle box, the inner
  /// box, the outer ROTATED box, or the middle ROTATED box, or the inner
  /// ROTATED box. This function will take care of all of that for you on
  /// both the vertical and horizontal axes.
  SizeC constrainSize(SizeC value,
          {required NodeBoundaryType nodeBoundaryType}) =>
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

  /// A convenience function that is exactly the same as [constrainSize]
  /// except it takes a [Vec] instead.
  Vec constrainVec(Vec value, {required NodeBoundaryType nodeBoundaryType}) =>
      Vec(
        constrainValue(
          value.x,
          AxisC.horizontal,
          nodeBoundaryType: nodeBoundaryType,
        ),
        constrainValue(
          value.y,
          AxisC.vertical,
          nodeBoundaryType: nodeBoundaryType,
        ),
      );

  /// [returns] the relevant [NodeBox] given the [NodeBoundaryType] and
  /// the [PositioningSpace] desired.
  ///
  /// This is a convenience function meant for programmatic use.
  NodeBox getBox(
      {required NodeBoundaryType type, required PositioningSpace space}) {
    switch (space) {
      case PositioningSpace.local:
        switch (type) {
          case NodeBoundaryType.outerBox:
            return outerBoxLocal;
          case NodeBoundaryType.innerBox:
          case NodeBoundaryType.innerRotatedBox:
            return innerBoxLocal;
          case NodeBoundaryType.middleBox:
            return basicBoxLocal;
          case NodeBoundaryType.outerRotatedBox:
            return outerRotatedBoxGlobal;
          case NodeBoundaryType.middleRotatedBox:
            return middleRotatedBoxLocal;
        }
      case PositioningSpace.global:
        switch (type) {
          case NodeBoundaryType.outerBox:
            return outerBoxGlobal;
          case NodeBoundaryType.innerBox:
          case NodeBoundaryType.innerRotatedBox:
            return innerBoxGlobal;
          case NodeBoundaryType.middleBox:
            return basicBoxGlobal;
          case NodeBoundaryType.outerRotatedBox:
            return outerRotatedBoxGlobal;
          case NodeBoundaryType.middleRotatedBox:
            return middleRotatedBoxGlobal;
        }
    }
  }

  /// A convenience function that will take a [value] and constraint it
  /// using the [resolvedConstraints] function.
  ///
  /// Since constraints represent both width and height of a given node, this
  /// function also takes an [axis] to indicate which axis to constrain the
  /// [value].
  ///
  /// It takes an additional [nodeBoundaryType] to indicate WHICH [NodeBox]
  /// to use to constrain the desired [value]. You may want to constrain
  /// some arbitrary [value] based on the outer box, the middle box, the inner
  /// box, the outer ROTATED box, or the middle ROTATED box, or the inner
  /// ROTATED box. This function will take care of all of that for you.
  ///
  /// [horizontalFit] and [verticalFit] are used to determine what type of
  /// numbers [minimumInternalSize] should use. It will normally use this
  /// node's [horizontalFit] and [verticalFit] but you can override it if
  /// you want.
  ///
  /// [returns] the constrained value that cannot exceed the total constraints
  ///           of this node.
  double constrainValue(
    double value,
    AxisC axis, {
    required NodeBoundaryType nodeBoundaryType,
    SizeFit? horizontalFit,
    SizeFit? verticalFit,
  }) {
    final BoxConstraintsModel constraints = resolvedConstraints(
      horizontalFit: horizontalFit,
      verticalFit: verticalFit,
    );

    switch (axis) {
      case AxisC.horizontal:
        double minValue = constraints.minWidth ?? 0.0;
        switch (nodeBoundaryType) {
          case NodeBoundaryType.middleBox:
          case NodeBoundaryType.middleRotatedBox:
            minValue += innerBoxLocal.horizontalEdgeSpace;
            break;
          case NodeBoundaryType.outerBox:
          case NodeBoundaryType.outerRotatedBox:
            minValue += outerBoxLocal.horizontalEdgeSpace +
                innerBoxLocal.horizontalEdgeSpace;
            break;
          case NodeBoundaryType.innerBox:
          case NodeBoundaryType.innerRotatedBox:
            minValue -= innerBoxLocal.horizontalEdgeSpace;
            break;
        }

        double output = max(value, minValue);

        if (constraints.maxWidth != null) {
          double maxValue = constraints.maxWidth!;
          switch (nodeBoundaryType) {
            case NodeBoundaryType.middleBox:
            case NodeBoundaryType.middleRotatedBox:
              break;
            case NodeBoundaryType.outerBox:
            case NodeBoundaryType.outerRotatedBox:
              maxValue += outerBoxLocal.horizontalEdgeSpace;
              break;
            case NodeBoundaryType.innerBox:
            case NodeBoundaryType.innerRotatedBox:
              maxValue -= innerBoxLocal.horizontalEdgeSpace;
              break;
          }
          output = min(output, maxValue);
        }

        return output;
      case AxisC.vertical:
        double minValue = constraints.minHeight ?? 0.0;
        switch (nodeBoundaryType) {
          case NodeBoundaryType.middleBox:
          case NodeBoundaryType.middleRotatedBox:
            minValue += innerBoxLocal.verticalEdgeSpace;
            break;
          case NodeBoundaryType.outerBox:
          case NodeBoundaryType.outerRotatedBox:
            minValue += outerBoxLocal.verticalEdgeSpace +
                innerBoxLocal.verticalEdgeSpace;
            break;
          case NodeBoundaryType.innerBox:
          case NodeBoundaryType.innerRotatedBox:
            minValue -= innerBoxLocal.verticalEdgeSpace;
            break;
        }

        double output = max(value, minValue);

        if (constraints.maxHeight != null) {
          double maxValue = constraints.maxHeight!;
          switch (nodeBoundaryType) {
            case NodeBoundaryType.middleBox:
            case NodeBoundaryType.middleRotatedBox:
              break;
            case NodeBoundaryType.outerBox:
            case NodeBoundaryType.outerRotatedBox:
              maxValue += outerBoxLocal.verticalEdgeSpace;
              break;
            case NodeBoundaryType.innerBox:
            case NodeBoundaryType.innerRotatedBox:
              maxValue -= innerBoxLocal.verticalEdgeSpace;
              break;
          }
          output = min(output, maxValue);
        }

        return output;
    }
  }

  /// If this node has minimum constraints, it returns its minimum possible
  /// size given those values. Otherwise, it returns the [value] passed,
  /// indicating that this node has no leeway to shrink.
  ///
  /// By no leeway to shrink, we mean that this node has not reached its minimum
  /// size just yet (not account for its children).
  double hasLeewayToShrink(
    double value,
    AxisC axis, {
    required NodeBoundaryType type,
    SizeFit? horizontalFit,
    SizeFit? verticalFit,
  }) {
    final SizeC minInnerSize = minimumInternalSize(
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
        if (constraints.minWidth != null) {
          final constrainedMinWidth =
              (minInnerSize.width) + (constraints.minWidth ?? 0);

          return constrainedMinWidth + horizontalEdgeSpace;
        }
        return value;
      case AxisC.vertical:
        if (constraints.minHeight != null) {
          final constrainedMinHeight =
              (minInnerSize.height) + (constraints.minHeight ?? 0);

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
  }

  @override
  List<Object?> get props => [id];
}
