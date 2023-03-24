// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import 'models/models.dart';
import 'nodes/nodes.dart';

/// A base class for nodes that can have blends and decoration.
abstract class DefaultShapeNode extends SceneNode
    with BlendMixin, GeometryMixin {
  /// Default constructor for this class.
  DefaultShapeNode({
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
    super.reactions,
    super.parentID,
    // BlendMixin properties
    double opacity = 1,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    // GeometryMixin properties
    List<PaintModel> fills = const [],
    List<PaintModel> strokes = const [],
    double strokeWeight = 0,
    double? strokeMiterLimit,
    StrokeAlignC strokeAlign = StrokeAlignC.inside,
    StrokeCapEnum strokeCap = StrokeCapEnum.none,
    List<double>? dashPattern,
    StrokeSide strokeSide = StrokeSide.all,
  }) {
    setBlendMixin(
      opacity: opacity,
      effects: [...effects],
      isMask: isMask,
      blendMode: blendMode,
    );

    setGeometryMixin(
      fills: [...fills],
      strokes: [...strokes],
      strokeWeight: strokeWeight,
      strokeMiterLimit: strokeMiterLimit,
      strokeAlign: strokeAlign,
      strokeCap: strokeCap,
      dashPattern: dashPattern,
      strokeSide: strokeSide,
    );
  }

  @override
  String toString() => '\n$type [${super.toString()}]';
}

/// A base class for all the nodes that can have a shape, blends, decoration,
/// clipping, and children.
abstract class ParentNode extends DefaultShapeNode
    with ClipMixin, ChildrenMixin {
  /// Default constructor for this class.
  ParentNode({
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
    super.opacity,
    super.isMask,
    super.effects,
    super.blendMode,
    super.fills,
    super.strokes,
    super.strokeWeight,
    super.strokeMiterLimit,
    super.strokeAlign,
    super.strokeCap,
    super.dashPattern,
    super.strokeSide,
    super.reactions,
    super.parentID,
    // ChildrenMixin properties
    required List<String> children,
    // ClipMixin properties
    bool clipsContent = true,
  }) {
    setChildrenMixin(children: children);
    setClipMixin(clipsContent: clipsContent);
  }
}

/// renamed with Enum at the end to not conflict with Flutter's own TextAlignVertical
enum TextAlignVerticalEnum {
  /// Aligns the text on the top edge of the container.
  top,

  /// Aligns the text on the center edge of the container.
  center,

  /// Aligns the text on the bottom edge of the container.
  bottom;
}

/// renamed to be in conformity with [TextAlignVerticalEnum].
/// Represents Flutter's [TextAlign] enum.
enum TextAlignHorizontalEnum {
  /// Align the text on the left edge of the container.
  left,

  /// Align the text in the center of the container.
  center,

  /// Align the text on the right edge of the container.
  right,

  /// Stretch lines of text that end with a soft line break to fill the width of
  /// the container.
  ///
  /// Lines that end with hard line breaks are aligned towards the [start] edge.
  justified;
}

/// Defines the affinity of an icon with any other node/widget.
/// e.g. for buttons with icon and text/label.
enum IconPlacementEnum {
  /// Places the icon before its sibling.
  start,

  /// Places the icon after its sibling,
  end;
}

/// Defines the type of an icon.
enum IconTypeEnum {
  /// Represents a Flutter supported font based icon.
  /// In most cases, its a material icon but it can also be any other font
  /// based icon.
  icon,

  /// Represents an image based icon. This could be a network based image or
  /// a local asset.
  image;
}

/// Allows to define reactions to user interactions on a node. This is directly
/// used by the actions system in Codelessly.
mixin ReactionMixin {
  /// Holds actions/reactions defined on a node.
  late List<Reaction> reactions;

  /// Sets the reactions on a node.
  void setReactionMixin(List<Reaction>? reactions) {
    this.reactions = reactions ?? [];
  }

  /// Default value for all nodes that don't override this.
  List<TriggerType> get triggerTypes =>
      [TriggerType.click, TriggerType.longPress];
}

/// A mixin that can be used to add children functionality to a BaseNode class.
/// In simple words, allows a node to have child/children.
///
/// To use, include the mixin in the class definition and call
/// [ChildrenMixin.setChildrenMixin] method in the constructor of the node.
mixin ChildrenMixin on BaseNode {
  /// A list of node ids that are children of this node.
  late List<String> children;

  /// Sets the children of this node.
  void setChildrenMixin({required List<String> children}) {
    this.children = children;
  }

  /// Called when a child is replaced with another child.
  /// [oldID] represents the id of the child that is being replaced.
  /// [newID] represents the id of the child that is replacing the old child.
  void onChildIDChanged(String oldID, String newID) {}
}

/// A mixin that can be used to add a single globally identifiable color
/// property to a BaseNode class.
mixin SingleColorMixin on BaseNode {
  /// In some places, like icons, only a single color is supported.
  /// Therefore, [PaintModel] is not needed.
  late ColorRGBA? color;

  /// Sets properties of this mixin.
  void setSingleColorMixin({required ColorRGBA? color}) {
    this.color = color;
  }
}

/// Adds blend properties to a node making the node blendable. This is very
/// similar to Figma's blending properties.
mixin BlendMixin on BaseNode {
  /// Overall opacity of the node.
  late double opacity;

  /// Type of blending applied to the node.
  @JsonKey(unknownEnumValue: BlendModeC.srcOver)
  late BlendModeC blendMode;

  /// Whether this node is a mask.
  late bool isMask;

  /// List of effects applied to the node.
  late List<Effect> effects;

  /// Sets the blend properties of the node.
  void setBlendMixin({
    required double opacity,
    required bool isMask,
    required List<Effect> effects,
    required BlendModeC blendMode,
  }) {
    this.opacity = opacity;
    this.isMask = isMask;
    this.effects = effects;
    this.blendMode = blendMode;
  }

  @override
  String toString() =>
      "${super.toString()}\n Blend(${"opacity: $opacity, isMask: $isMask"})";
}

/// Represents the type of sizing a node can have or either axis.
enum SizeFit {
  /// We're not sure what to do with this yet. It does nothing right now.
  locked,

  /// The node has fixed size on applied axis. This is the default value.
  /// This means that no external factors can change the size of the node.
  fixed,

  /// Allows the node to grow to fit its parent on the applied axis. This is
  /// controlled by the node parent to determine how much space the node can
  /// have.
  expanded,

  /// Allows the node to shrink to fit its parent on the applied axis if the
  /// parent cannot allow the node to be of its own size. This would make the
  /// node take exact amount of space it requires on applied axis if available
  /// or shrink to fit if not available.
  flexible,

  /// Allows the node to only grow to fit its children inside. This is not
  /// affected by its parent but rather its children.
  shrinkWrap;

  /// Whether this SizeFit is wrapping.
  bool get isWrap => this == SizeFit.shrinkWrap || this == SizeFit.flexible;

  /// Whether this SizeFit is fixed.
  bool get isFixed => this == SizeFit.locked || this == SizeFit.fixed;

  /// Whether this SizeFit is expanded.
  bool get isFill => this == SizeFit.expanded;

  /// Whether this SizeFit allows the node to flex.
  bool get isFlex => this == SizeFit.flexible || this == SizeFit.expanded;

  /// Whether this SizeFit is flexible.
  bool get isFlexible => this == SizeFit.flexible;
}

/// Represents the positioning coordinate space a [NodeBox] could have.
enum PositioningSpace {
  /// A coordinate space that is relative to the parent node.
  local,

  /// A coordinate space that is relative to [RootNode].
  global,
}

/// Represents the type of the boundary for a [NodeBox].
enum NodeBoundaryType {
  /// The inner space of a node that is available for the children to use.
  innerBox,

  /// The physical boundary of a node that is the max space available for the
  /// children of the node to use in case of no padding. Typically the actual
  /// boundaries of a node excluding margin.
  middleBox,

  /// The total space a node has including everything inside plus anything that
  /// is outside the actual boundaries of the node like margin.
  outerBox,

  /// Represents the [innerBox] but with rotation since rotation changes these
  /// bounds based on the rotation angel.
  innerRotatedBox,

  /// Represents the [middleBox] but with rotation since rotation changes these
  //   /// bounds based on the rotation angel.
  middleRotatedBox,

  /// Represents the [outerBox] but with rotation since rotation changes these
  //   /// bounds based on the rotation angel.
  outerRotatedBox;

  /// Whether the [NodeBox] with this boundary type is rotated.
  bool get isRotatedBox =>
      this == NodeBoundaryType.innerRotatedBox ||
      this == NodeBoundaryType.middleRotatedBox ||
      this == NodeBoundaryType.outerRotatedBox;

  /// Returns the correct [NodeBox] for given [node] based on the given [space].
  NodeBox getBoxForNode(BaseNode node, {required PositioningSpace space}) {
    switch (space) {
      case PositioningSpace.local:
        return getLocalBoxForNode(node);
      case PositioningSpace.global:
        return getGlobalBoxForNode(node);
    }
  }

  /// Returns the local box for the [node] that is in the global coordinate
  /// space of the node and the [RootNode].
  NodeBox getGlobalBoxForNode(BaseNode node) {
    switch (this) {
      case NodeBoundaryType.outerBox:
        return node.outerBoxGlobal;
      case NodeBoundaryType.outerRotatedBox:
        return node.outerRotatedBoxGlobal;
      case NodeBoundaryType.middleBox:
        return node.middleBoxGlobal;
      case NodeBoundaryType.middleRotatedBox:
        return node.middleRotatedBoxGlobal;
      case NodeBoundaryType.innerBox:
      case NodeBoundaryType.innerRotatedBox:
        return node.innerBoxGlobal;
    }
  }

  /// Returns a [NodeBox] for the given [node] that is in the local coordinate
  /// space of the node and its parent.
  NodeBox getLocalBoxForNode(BaseNode node) {
    switch (this) {
      case NodeBoundaryType.outerBox:
        return node.outerBoxLocal;
      case NodeBoundaryType.outerRotatedBox:
        return node.outerRotatedBoxLocal;
      case NodeBoundaryType.middleBox:
        return node.middleBoxLocal;
      case NodeBoundaryType.middleRotatedBox:
        return node.middleRotatedBoxLocal;
      case NodeBoundaryType.innerBox:
      case NodeBoundaryType.innerRotatedBox:
        return node.innerBoxLocal;
    }
  }
}

/// Defines the type of positioning used for a node inside its parent.
enum PositioningMode {
  /// The node is positioned relative to its parent such that it changes
  /// its position relative to the top-left corner node when the node is
  /// resized. Typically, this would wrap a node with [Align] inside a stack.
  /// Upon resizing, it doesn't maintain the fixed distance from the edges of
  /// its parent but rather maintains it on percentage basis.
  ///
  /// In simple words, position is calculated in percentage basis based on the
  /// size of the parent and its offset from the top-left edge of the parent.
  align,

  /// The node is positioned relative to its parent based on fixed distance
  /// from the edge of the parent. Typically, this would wrap a node with
  /// [Positioned] inside a stack.
  ///
  /// This allows the node to anchor itself to one/more edge/s of the parent
  /// with some distance from the edge such that unlike [align], it would
  /// always maintain that distance from anchored edge regardless of the size
  /// of the parent in case of resizing.
  ///
  /// In simple words, position is calculated in fixed pixels based on the
  /// anchored edges of the parent which is not influenced by the size of the
  /// parent.
  pin,
}

/// Represents the alignment of a stroke on a node. This directly affects
/// inner space of a node that allowed for the children to use.
enum StrokeAlignC {
  /// Aligns the stroke at the center of the node boundary. This means that
  /// the stroke will be drawn in such a way that half of the stroke is
  /// outside the node boundary and half of the stroke is inside the node
  /// boundary. This partially affects the contents/children of the node.
  center(0),

  /// Aligns the stroke at the outside of the node boundary. This means that
  /// the stroke will be drawn completely outside node boundary not affecting
  /// the contents/children of the node at all.
  outside(1),

  /// Aligns the stroke at the inside of the node boundary. This means that
  /// the stroke will be drawn completely inside node boundary affecting the
  /// contents/children of the node.
  inside(-1);

  /// The alignment value that is used for the final double alignment;
  final double alignment;

  /// Creates a [StrokeAlignC] with the given [alignment].
  const StrokeAlignC(this.alignment);
}

/// Styles to use for line endings on a stroke. This is directly related to
/// [StrokeCap] in Flutter.
enum StrokeCapEnum {
  /// Unspecified.
  none,

  /// Begin and end contours with a semi-circle extension.
  ///
  /// ![A round cap adds a rounded end to the line segment that protrudes
  /// by one half of the thickness of the line (which is the radius of the cap)
  /// past the end of the segment.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/round_cap.png)
  ///
  /// The cap is colored in the diagram above to highlight it: in normal use it
  /// is the same color as the line.
  round,

  /// Begin and end contours with a half square extension. This is
  /// similar to extending each contour by half the stroke width/thickness.
  ///
  /// ![A square cap has a square end that effectively extends the line length
  /// by half of the stroke width.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/square_cap.png)
  ///
  /// The cap is colored in the diagram above to highlight it: in normal use it
  /// is the same color as the line.
  square;
}

/// An enum representing the side or sides of a shape that a stroke should be applied to.
enum StrokeSide {
  /// The left side of the shape.
  left,

  /// The right side of the shape.
  right,

  /// The bottom side of the shape.
  bottom,

  /// The top side of the shape.
  top,

  /// All sides of the shape.
  all;
}

/// Represents the shape of the track for a slider.
enum SliderTrackShapeEnum {
  /// A rectangular track with sharp edges.
  rectangle,

  /// A rectangular track with rounded edges.
  roundedRectangle;

  /// Display-able string representation of the enum.
  String get prettify {
    switch (this) {
      case SliderTrackShapeEnum.rectangle:
        return 'Rectangle';
      case SliderTrackShapeEnum.roundedRectangle:
        return 'Rounded';
    }
  }
}

/// Represents the shape of the value indicator showed above the thumb of a
/// slider when interacted.
enum SliderValueIndicatorShape {
  /// The value indicator is in
  /// the shape of an upside-down pear.
  ///
  /// ![A slider widget, consisting of 5 divisions and showing the paddle slider value indicator shape.]
  /// (https://flutter.github.io/assets-for-api-docs/assets/material/paddle_slider_value_indicator_shape.png)
  paddle,

  /// The default shape of a [Slider]'s value indicator.
  ///
  /// ![A slider widget, consisting of 5 divisions and showing the rectangular slider value indicator shape.]
  /// (https://flutter.github.io/assets-for-api-docs/assets/material/rectangular_slider_value_indicator_shape.png)
  rectangle;

  /// Display-able string representation of the enum.
  String get prettify {
    switch (this) {
      case SliderValueIndicatorShape.rectangle:
        return 'Rectangle';
      case SliderValueIndicatorShape.paddle:
        return 'Paddle';
    }
  }
}

/// A mixin that adds decorative properties to a node. This includes fills and
/// strokes.
mixin GeometryMixin on BaseNode {
  /// A list of fills applied to the node. This can be a solid color or a
  /// gradient or an image. Refer [PaintModel.type] for more info on supported
  /// types of fill.
  late List<PaintModel> fills;

  /// A list of strokes applied to the node. Only solid color type of fill
  /// is supported at the moment.
  List<PaintModel> strokes = [];

  /// Thickness/weight of the stroke.
  double strokeWeight = 0;

  /// The limit for miters to be drawn on segments for given stroke join.
  late double strokeMiterLimit;

  /// Alignment of the stroke on the node boundary.
  late StrokeAlignC strokeAlign;

  /// Type of line cap to use for the stroke.
  late StrokeCapEnum strokeCap;

  /// The pattern of dashes and gaps to apply to the stroke in case of dashed
  /// stroke.
  late List<double> dashPattern;

  /// Side of the shape to apply the stroke to.
  late StrokeSide strokeSide;

  /// Sets the properties this mixin.
  void setGeometryMixin({
    required List<PaintModel> fills,
    required List<PaintModel> strokes,
    required double strokeWeight,
    required double? strokeMiterLimit,
    required StrokeAlignC strokeAlign,
    required StrokeCapEnum strokeCap,
    required List<double>? dashPattern,
    required StrokeSide? strokeSide,
  }) {
    this.fills = fills;
    this.strokes = strokes;
    this.strokeWeight = strokeWeight;
    this.strokeMiterLimit = strokeMiterLimit ?? 4;
    this.strokeAlign = strokeAlign;
    this.strokeCap = strokeCap;
    this.dashPattern = dashPattern ??= [];
    this.strokeSide = strokeSide ??= StrokeSide.all;
  }

  /// Returns true if the node has any fills that can be interpreted as
  /// strokes.
  bool get hasStroke => strokes.isNotEmpty && strokeWeight > 0;

  @override
  EdgeInsetsModel minimumPadding() {
    final double additionalPadding = strokes.isNotEmpty ? strokeWeight : 0.0;
    return super.minimumPadding() + EdgeInsetsModel.all(additionalPadding);
  }

  /// If an image is in the fills, allow shrink-wrapping up to to a fixed
  /// minimum.
  @override
  SizeC minimumInternalSize({
    required SizeFit horizontalFit,
    required SizeFit verticalFit,
  }) {
    SizeC resultSize = super.minimumInternalSize(
      horizontalFit: horizontalFit,
      verticalFit: verticalFit,
    );
    for (final PaintModel fill in fills) {
      if (fill.type != PaintType.image) continue;
      if ((fill.sourceWidth != null && fill.sourceHeight != null) ||
          (fill.cropData != null)) {
        final SizeC currentSize = SizeC(
          fill.cropData?.width ?? fill.sourceWidth ?? 0,
          fill.cropData?.height ?? fill.sourceHeight ?? 0,
        );
        SizeC size = SizeC.zero;
        if (horizontalFit == SizeFit.shrinkWrap &&
            verticalFit == SizeFit.shrinkWrap) {
          size = SizeC(currentSize.width.roundToDouble(),
              currentSize.height.roundToDouble());
        } else {
          // If this image vertically shrinkwraps, then we want to set the
          // minimum height to be equal to or less than the source height,
          // preserving aspect ratio with respect to the current node width.
          if (verticalFit == SizeFit.shrinkWrap) {
            size = SizeC(
              size.width,
              (currentSize.height * (basicBoxLocal.width / currentSize.width))
                  .roundToDouble(),
            );
          }
          if (horizontalFit == SizeFit.shrinkWrap) {
            size = SizeC(
              (currentSize.width * (basicBoxLocal.height / currentSize.height))
                  .roundToDouble(),
              size.height,
            );
          }
        }

        resultSize = resultSize | size;
      }
    }
    return resultSize;
  }
}

/// A mixin that adds clipping functionality to a node. In simple words,
/// makes the node clip-able.
mixin ClipMixin on BaseNode {
  /// Whether to clip contents of the node.
  late bool clipsContent;

  /// Sets the clipping.
  void setClipMixin({
    required bool clipsContent,
  }) {
    this.clipsContent = clipsContent;
  }
}

/// A mixin that adds border shape properties to a node enabling the node to
/// have differently shaped borders.
mixin ShapeBorderMixin {
  /// Represents the shape of the border.
  late CShapeBorder shape;

  /// Radius of the corners of the border.
  late CornerRadius cornerRadius;

  /// Thickness of the border.
  double? borderWidth;

  /// Color of the border.
  ColorRGBA? borderColor;

  /// Sets the properties of this mixin.
  void setShapeBorderMixin({
    required CShapeBorder shape,
    required CornerRadius cornerRadius,
    required double? borderWidth,
    required ColorRGBA? borderColor,
  }) {
    this.shape = shape;
    this.cornerRadius = cornerRadius;
    this.borderWidth = borderWidth;
    this.borderColor = borderColor;
  }

  @override
  String toString() =>
      '${super.toString()}\n ShapeBorder(shape: $shape, cornerRadius: $cornerRadius, borderColor: $borderColor, borderWidth: $borderWidth)';
}

/// A mixin that adds rounded corner shape properties to a node enabling the
/// node to have rounded corners.
mixin CornerMixin on BaseNode {
  /// Level of pixel smoothing applied to the corners.
  late double cornerSmoothing;

  /// Radius of the corners of the node.
  late CornerRadius cornerRadius;

  /// Sets the properties of this mixin.
  void setCornerMixin({
    required CornerRadius cornerRadius,
    required double cornerSmoothing,
  }) {
    this.cornerRadius = cornerRadius;
    this.cornerSmoothing = cornerSmoothing;
  }

  @override
  String toString() =>
      '${super.toString()}\n Corner(cornerSmoothing: $cornerSmoothing, radius: ${cornerRadius.toString()})';
}

/// Indicates that the node has some custom properties. i.e. static
/// nodes.
mixin CustomPropertiesMixin on BaseNode {}

/// This can be used for nodes that cannot be resized by only height or width
/// but rather can resize proportionally preserving the aspect ratio.
/// e.g. Switch, Radio Button, Checkbox, Icon.
mixin FixedAspectRatioMixin on BaseNode {
  /// The aspect ratio of the node.
  double get aspectRatio;
}

/// This can be used for nodes that have fixed size and do not resize but
/// rather can scale (e.g. using Transform.scale).
/// e.g. Switch, Radio Button, Checkbox.
mixin ScalableMixin on BaseNode {
  /// The scale factor of the node.
  double get scale;

  /// This is useful to reset the scale.
  double get defaultWidth;

  /// This is useful to reset the scale.
  double get defaultHeight;

  /// Smallest allowed scale factor of the node.
  double get minScale => 0.5;

  /// Largest allowed scale factor of the node.
  double get maxScale => 5;

  /// Whether the node is scaled up beyond the allowed [maxScale].
  bool get isOverScaled => scale > maxScale;

  /// Whether the node is scaled down beyond the allowed [minScale].
  bool get isUnderScaled => scale < minScale;

  /// Whether the node scale value is in the boundaries of
  /// [minScale] and [maxScale].
  bool get isScaleInBounds => scale >= minScale && scale <= maxScale;

  /// Whether the node is scaled up/down beyond the
  /// allowed [maxScale]/[minScale].
  bool get isScaleOutOfBounds => !isScaleInBounds;

  /// Whether the node scale is at the minimum allowed scale.
  bool get isAtMinScale => scale == minScale;

  /// Whether the node scale is at the maximum allowed scale.
  bool get isAtMaxScale => scale == maxScale;

  /// Whether the node scale is same as the [minScale] or [maxScale].
  bool get isAtScaleBounds => scale == minScale || scale == maxScale;

  /// Minimum allowed width of the node calculated based on the [defaultWidth]
  /// and [minScale].
  double get minWidth => defaultWidth * minScale;

  /// Minimum allowed height of the node calculated based on the [defaultHeight]
  /// and [minScale].
  double get minHeight => defaultHeight * minScale;

  /// Maximum allowed width of the node calculated based on the [defaultWidth]
  /// and [maxScale].
  double get maxWidth => defaultWidth * maxScale;

  /// Maximum allowed height of the node calculated based on the [defaultHeight]
  /// and [maxScale].
  double get maxHeight => defaultHeight * maxScale;

  /// Returns the constraints for the node based on the [minWidth], [minHeight],
  /// [maxWidth] and [maxHeight].
  BoxConstraintsModel getFixedConstraints() => BoxConstraintsModel(
        minHeight: minHeight,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        minWidth: minWidth,
      );
}

/// A mixin that allows a node to store variables for its properties so that
/// value of those properties can be retrieved from those variables if present.
mixin VariablePropertiesMixin on BaseNode {
  /// property_name -> variable_name
  @JsonKey(defaultValue: {})
  Map<String, String> variables = {};

  /// property_name -> list of variable_name
  /// This is used for properties that can have multiple variables almost
  /// always interpolated like in a string.
  @JsonKey(defaultValue: {})
  Map<String, List<String>> multipleVariables = {};

  /// Sets the properties of this mixin.
  void setVariablesMixin({
    Map<String, String>? variables,
    Map<String, List<String>>? multipleVariables,
  }) {
    this.variables = variables ?? {};
    this.multipleVariables = multipleVariables ?? {};
  }

  /// Whether a variable with given [id] or name is used by this node.
  bool usesVariable(String id) =>
      variables.values.contains(id) ||
      multipleVariables.values.any((e) => e.contains(id));

  /// Replace variable with [oldName] to [newName].
  void updateVariableName({required String oldName, required String newName}) {}
}

/// A mixin that allows to define action configurable properties for a node.
mixin PropertyVariableMixin on BaseNode {
  /// Properties of the node that can be used in actions or can be changed by
  /// an action.
  late final List<ValueModel> propertyVariables = [
    BoolValue(name: 'visible', value: visible),
    IntValue(name: 'rotationDegrees', value: rotationDegrees),
  ];
}

/// Represents whether [RowColumnNode] is a row or a column.
enum RowColumnType {
  /// Lays out its children horizontally.
  row,

  /// lays out its children vertically.
  column;
}

/// A mixin that allows node to have sequential children layout like row and
/// column.
/// This contains common properties of row and columns.
mixin RowColumnMixin on BaseNode {
  /// Whether the node is a row/column.
  late RowColumnType rowColumnType;

  /// Represents the alignment of the children along the main axis which is
  /// horizontal for rows and vertical for columns. See [MainAxisAlignmentC]
  /// for details on available alignments.
  late MainAxisAlignmentC mainAxisAlignment;

  /// Represents the alignment of the children along the cross axis which is
  /// vertical for rows and horizontal for columns. See [CrossAxisAlignmentC]
  /// for details on available alignments.
  late CrossAxisAlignmentC crossAxisAlignment;

  /// Returns the main axis based on whether this is a row or column.
  AxisC get mainAxis =>
      (rowColumnType == RowColumnType.row) ? AxisC.horizontal : AxisC.vertical;

  /// Returns the cross axis based on whether this is a row or column.
  AxisC get crossAxis =>
      (rowColumnType == RowColumnType.row) ? AxisC.vertical : AxisC.horizontal;

  /// Sets the properties of this mixin.
  void setRowColumnMixin({
    required RowColumnType rowColumnType,
    required MainAxisAlignmentC mainAxisAlignment,
    required CrossAxisAlignmentC crossAxisAlignment,
  }) {
    this.rowColumnType = rowColumnType;
    this.mainAxisAlignment = mainAxisAlignment;
    this.crossAxisAlignment = crossAxisAlignment;
  }
}

/// A mixin that allows node behave like a container/placeholder for
/// other nodes.
mixin PlaceholderMixin on BaseNode {}

/// Represents the physics for scrolling on scrollable nodes like list view.
/// These values directly translates to [ScrollPhysics] in Flutter.
enum ScrollPhysicsC {
  /// Scroll physics that always lets the user scroll.
  ///
  /// This overrides the default behavior which is to disable scrolling
  /// when there is no content to scroll. It does not override the
  /// handling of over-scrolling.
  ///
  /// On Android, over-scrolls will be clamped by default and result in an
  /// overscroll glow. On iOS, over-scrolls will load a spring that will return the
  /// scroll view to its normal range when released.
  ///
  /// See [AlwaysScrollableScrollPhysics] in Flutter for more details.
  alwaysScrollableScrollPhysics,

  /// Scroll physics for environments that allow the scroll offset to go beyond
  /// the bounds of the content, but then bounce the content back to the edge of
  /// those bounds.
  ///
  /// This is the behavior typically seen on iOS.
  ///
  /// [BouncingScrollPhysics] by itself will not create an overscroll effect if
  /// the contents of the scroll view do not extend beyond the size of the
  /// viewport.
  ///
  /// See [BouncingScrollPhysics] in Flutter for more details.
  bouncingScrollPhysics,

  /// Scroll physics for environments that prevent the scroll offset from reaching
  /// beyond the bounds of the content.
  ///
  /// See [ClampingScrollPhysics] in Flutter for more details.
  clampingScrollPhysics,

  /// Scroll physics that does not allow the user to scroll.
  neverScrollableScrollPhysics,

  /// Scroll physics that attempt to keep the scroll position in range when the
  /// contents change dimensions suddenly.
  ///
  /// See [RangeMaintainingScrollPhysics] in Flutter for more details.
  rangeMaintainingScrollPhysics;

  /// Displayable string representation of [ScrollPhysicsC].
  String get prettify {
    switch (this) {
      case ScrollPhysicsC.rangeMaintainingScrollPhysics:
        return 'Range Maintaining';
      case ScrollPhysicsC.bouncingScrollPhysics:
        return 'Bouncing';
      case ScrollPhysicsC.clampingScrollPhysics:
        return 'Clamping';
      case ScrollPhysicsC.neverScrollableScrollPhysics:
        return 'Never Scrollable';
      case ScrollPhysicsC.alwaysScrollableScrollPhysics:
        return 'Always Scrollable';
    }
  }
}

/// A representation of how a [ScrollView] should dismiss the on-screen
/// keyboard. Directly translates to [ScrollViewKeyboardDismissBehavior] in
/// Flutter.
enum ScrollViewKeyboardDismissBehaviorC {
  /// `manual` means there is no automatic dismissal of the on-screen keyboard.
  /// It is up to the client to dismiss the keyboard.
  manual,

  /// `onDrag` means that the [ScrollView] will dismiss an on-screen keyboard
  /// when a drag begins.
  onDrag;

  /// Displayable string representation of [ScrollViewKeyboardDismissBehaviorC].
  String get prettify {
    switch (this) {
      case ScrollViewKeyboardDismissBehaviorC.manual:
        return 'Manual';
      case ScrollViewKeyboardDismissBehaviorC.onDrag:
        return 'On Drag';
    }
  }
}

/// A mixin that adds scrolling functionality to a node and makes it scrollable.
/// Nodes like [ListViewNode], [RowColumnNode] and [CanvasNode] uses this to
/// provide options for its scroll behavior.
mixin ScrollableMixin on BaseNode {
  /// Whether the scrolling is enabled.
  late bool isScrollable;

  /// Direction in which the scrolling is allowed.
  late AxisC scrollDirection;

  /// Whether the scrolling is reversed to be bottom-to-top instead of
  /// top-to-bottom.
  late bool reverse;

  /// Whether this is the primary scrollable in the screen/layout. Only one
  /// scrollable can be primary in a layout.
  late bool primary;

  /// TODO
  /// physics ?? ((primary ?? false) || (primary == null && controller == null && identical(scrollDirection, Axis.vertical)) ? const AlwaysScrollableScrollPhysics() : null),
  /// Physics to use for the scrollable.
  late ScrollPhysicsC physics;

  /// A representation of how a [ScrollView] should dismiss the on-screen
  /// keyboard.
  late ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior;

  /// Whether to use a [ListView] instead of [SingleChildScrollView] in flutter
  /// code-gen and transformers.
  late bool useFlutterListView;

  /// Sets the properties of this mixin.
  void setScrollableMixin({
    required bool isScrollable,
    required AxisC scrollDirection,
    required bool reverse,
    required ScrollPhysicsC physics,
    required bool primary,
    required bool shrinkWrap,
    required ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior,
    required bool useFlutterListView,
  }) {
    this.isScrollable = isScrollable;
    this.scrollDirection = scrollDirection;
    this.reverse = reverse;
    this.physics = physics;
    this.primary = primary;
    this.keyboardDismissBehavior = keyboardDismissBehavior;
    this.useFlutterListView = useFlutterListView;
  }
}

/// Will link this node to a provided [CanvasId] to render it as a scrollable
/// list view.
///
/// This is meant to be for defining a simple rectangle node into a "view" into
/// a canvas, where-in the output simply puts the entire canvas tree as a child
/// of rectangle.
@Deprecated(
  'This feature has been de-scoped and might be removed in the future. We have '
  'dedicated [ListViewNode]s and [PageViewNode]s now.',
)
mixin ScrollLinkableMixin on BaseNode {
  /// Whether the scroll link is enabled.
  late bool scrollLinkEnabled;

  /// The ID of the canvas node to link to.
  late String? scrollableCanvasId;

  /// Sets the properties of this mixin.
  void setScrollLinkableMixin({
    required bool scrollLinkEnabled,
    required String? scrollableCanvasId,
  }) {
    this.scrollLinkEnabled = scrollLinkEnabled;
    this.scrollableCanvasId = scrollableCanvasId;
  }
}

/// Type casts rotation value to integer.
int castRotation(dynamic v) => (v as num?)?.toInt() ?? 0;

/// This mixin is extended by every Undo Action and api models
/// so .toJson() can be called regardless of the class.
/// It is used for storing actions on server.
mixin SerializableMixin {
  /// Returns a serializable map representation of the object.
  Map toJson();
}
