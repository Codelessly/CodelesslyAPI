import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:meta/meta.dart';

import 'models/models.dart';
import 'nodes/nodes.dart';

/// Excludes [BoxConstraintsModel] from the json if it's technically doing
/// nothing.
bool excludeConstraintsIf(BaseNode node) =>
    (node.constraints.minHeight == null || node.constraints.minHeight == 0) &&
    (node.constraints.minWidth == null || node.constraints.minWidth == 0) &&
    (node.constraints.maxHeight == null ||
        node.constraints.maxHeight == double.infinity) &&
    (node.constraints.maxWidth == null ||
        node.constraints.maxWidth == double.infinity);

/// Excludes [EdgePinsModel] from the json if it's technically doing nothing.
bool excludeEdgePinsIf(BaseNode node) {
  if (node.outerBoxLocal.edgeSize != SizeC.zero) return false;
  if (!node.edgePins.isStandard) return false;

  return true;
}

/// Defines nodes that are selectively exempted from default auto-layout
/// interactions, specifically disallows edge detection.
/// Ex: Canvases and placeholders
mixin IsolatedMixin {}

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
    // [BlendMixin] properties.
    double opacity = 1,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    InkWellModel? inkWell,

    // [GeometryMixin] properties.
    List<PaintModel> fills = const [],
    List<PaintModel> strokes = const [],
    double strokeWeight = 0,
    double strokeMiterLimit = 4.0,
    StrokeAlignC strokeAlign = StrokeAlignC.inside,
    StrokeCapEnum strokeCap = StrokeCapEnum.none,
    List<double> dashPattern = const [],
    StrokeSide strokeSide = StrokeSide.all,
  }) {
    setBlendMixin(
      opacity: opacity,
      effects: [...effects],
      isMask: isMask,
      blendMode: blendMode,
      inkWell: inkWell,
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
    // [ChildrenMixin] properties.
    required List<String> children,
    // [ClipMixin] properties.
    bool clipsContent = true,
  }) {
    setChildrenMixin(children: children);
    setClipMixin(clipsContent: clipsContent);
  }
}

/// Defines text node's vertical alignment.
/// Corresponds to Flutter's [TextAlignVertical] enum.
enum TextAlignVerticalEnum {
  /// Aligns the text on the top edge of the container.
  top,

  /// Aligns the text on the center edge of the container.
  center,

  /// Aligns the text on the bottom edge of the container.
  bottom;
}

/// Defines text node's horizontal alignment.
/// Corresponds to Flutter's [TextAlign] enum.
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

  /// Places the icon after its sibling.
  end;
}

/// Defines the type of an icon.
enum IconTypeEnum {
  /// Represents a Flutter supported font based icon.
  /// In most cases, its a material icon but it can also be any other font based
  /// icon.
  icon,

  /// Represents an image based icon. This could be a network based image or a
  /// local asset.
  image;
}

/// Defines reactions to user interactions on a node.
mixin ReactionMixin {
  /// Holds reactions defined on a node.
  late List<Reaction> reactions;

  /// Sets the reactions on a node.
  void setReactionMixin(List<Reaction>? reactions) {
    this.reactions = [...reactions ?? []];
  }

  /// Default value for all nodes that don't override this.
  List<TriggerType> get triggerTypes => [];
}

/// A mixin that holds the children of the node that are reactive, i.e., can
/// perform actions on triggers. For ex. [NavigationBarNode].
mixin ParentReactionMixin {
  /// These objects represent the children of the
  /// node that are reactive. A reactive child is one that can respond to
  /// certain triggers or changes in the application, such as user interaction
  /// or changes in data.
  List<ReactionMixin> get reactiveChildren;
}

/// A mixin that allows the node to have children.
///
/// To use, include the mixin in the class definition and call
/// [ChildrenMixin.setChildrenMixin] method in the constructor of the node.
mixin ChildrenMixin on BaseNode {
  /// A list of node ids that are children of this node.
  @JsonKey(defaultValue: [])
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

/// Adds a single globally identifiable color property to the node.
mixin SingleColorMixin on BaseNode {
  /// In some places, like icons, only a single color is supported.
  /// Therefore, [PaintModel] is not needed.
  late ColorRGBA? color;

  /// Sets properties of this mixin.
  void setSingleColorMixin({required ColorRGBA? color}) {
    this.color = color;
  }
}

/// Adds blend properties to the node.
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

  /// Whether to use ink well on this node, along with its properties.
  late InkWellModel? inkWell;

  /// Sets the blend properties of the node.
  void setBlendMixin({
    required double opacity,
    required bool isMask,
    required List<Effect> effects,
    required BlendModeC blendMode,
    required InkWellModel? inkWell,
  }) {
    this.opacity = opacity;
    this.isMask = isMask;
    this.effects = effects;
    this.blendMode = blendMode;
    this.inkWell = inkWell;
  }

  @override
  String toString() =>
      "${super.toString()}\n Blend(${"opacity: $opacity, isMask: $isMask, effects: $effects, blendMode: $blendMode, inkWell: $inkWell"})";
}

/// Represents the type of sizing a node can have on either axis.
enum SizeFit {
  /// Defines locked size fit. It does nothing right now.
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

  /// Whether this [SizeFit] is wrapping.
  bool get isWrap => this == SizeFit.shrinkWrap || this == SizeFit.flexible;

  /// Whether this [SizeFit] is fixed.
  bool get isFixed => this == SizeFit.locked || this == SizeFit.fixed;

  /// Whether this [SizeFit] is expanded.
  bool get isFill => this == SizeFit.expanded;

  /// Whether this [SizeFit] allows the node to flex.
  bool get isFlex => this == SizeFit.flexible || this == SizeFit.expanded;

  /// Whether this [SizeFit] is [flexible].
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
  /// bounds based on the rotation angle.
  innerRotatedBox,

  /// Represents the [middleBox] but with rotation since rotation changes these
  /// bounds based on the rotation angle.
  middleRotatedBox,

  /// Represents the [outerBox] but with rotation since rotation changes these
  /// bounds based on the rotation angle.
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
  /// Node's position is calculated relative to its parent's top-left corner,
  /// which changes based on a certain percentage corresponding the size of the
  /// parent.
  ///
  /// Replicates the behavior of Flutter's [Align] widget.
  align,

  /// Node's position is caluclated relative to the specified edge of its
  /// parent. Node maintains a fixed distance from the edge irrespective of the
  /// size of the parent.
  ///
  /// Replicates the behavior of Flutter's [Positioned] widget.
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
  /// the stroke will be drawn completely outside node boundary without
  /// affecting the contents/children of the node at all.
  outside(1),

  /// Aligns the stroke at the inside of the node boundary. This means that
  /// the stroke will be drawn completely inside node boundary affecting the
  /// contents/children of the node.
  inside(-1);

  /// The value used to specify the stroke alignment.
  final double alignment;

  /// Creates a [StrokeAlignC] with the given [alignment].
  const StrokeAlignC(this.alignment);
}

/// Styles to use for line endings on a stroke.
/// Corresponds to [StrokeCap] in Flutter.
enum StrokeCapEnum {
  /// Begin and end contours with a semi-circle extension.
  ///
  /// ![A round cap adds a rounded end to the line segment that protrudes
  /// by one half of the thickness of the line (which is the radius of the cap)
  /// past the end of the segment.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/round_cap.png)
  ///
  /// The cap is colored in the diagram above to highlight it: in normal use it
  /// is the same color as the line.
  round,

  /// Begin and end contours with a flat edge and no extension.
  ///
  /// ![A butt cap ends line segments with a square end that stops at the end of
  /// the line segment.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/butt_cap.png)
  ///
  /// Compare to the [square] cap, which has the same shape, but extends past
  /// the end of the line by half a stroke width.
  none,

  /// Begin and end contours with a half square extension. This is similar to
  /// extending each contour by half the stroke width/thickness.
  ///
  /// ![A square cap has a square end that effectively extends the line length
  /// by half of the stroke width.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/square_cap.png)
  ///
  /// The cap is colored in the diagram above to highlight it: in normal use it
  /// is the same color as the line.
  square;
}

/// An enum representing the side or sides of a shape that a stroke should be
/// applied to.
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
  /// The value indicator is in the shape of an upside-down pear.
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

/// Adds decorative properties to a node. This includes fills and strokes.
mixin GeometryMixin on BaseNode {
  /// A list of fills applied to the node. This can be a solid color or a
  /// gradient or an image. Refer [PaintModel.type] for more info on supported
  /// types of fill.
  late List<PaintModel> fills;

  /// A list of strokes applied to the node. Only solid color type of fill is
  /// supported at the moment.
  List<PaintModel> strokes = [];

  /// Thickness/weight of the stroke.
  double strokeWeight = 0;

  /// The limit for miters to be drawn on segments for given stroke join.
  late double strokeMiterLimit;

  /// Alignment of the stroke on the node boundary.
  late StrokeAlignC strokeAlign;

  /// Type of line cap to use for the stroke.
  @JsonKey(unknownEnumValue: StrokeCapEnum.none)
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

  /// Returns true if the node has any fills that can be interpreted as strokes.
  bool get hasStroke => strokes.isNotEmpty && strokeWeight > 0;

  // @override
  // EdgeInsetsModel minimumPadding() {
  //   final double additionalPadding = strokes.isNotEmpty ? strokeWeight : 0.0;
  //   return super.minimumPadding() + EdgeInsetsModel.all(additionalPadding);
  // }

  /// If an image is in the fills, allow shrink-wrapping up to to a fixed
  /// minimum.
  @override
  BoxConstraintsModel internalConstraints({
    required SizeFit horizontalFit,
    required SizeFit verticalFit,
  }) {
    BoxConstraintsModel resultSize = super.internalConstraints(
      horizontalFit: horizontalFit,
      verticalFit: verticalFit,
    );
    for (final PaintModel fill in fills) {
      if (fill.type != PaintType.image) continue;
      if ((fill.sourceWidth != null && fill.sourceHeight != null) ||
          (fill.cropData != null)) {
        final double? imgWidth =
            (fill.cropData?.width ?? fill.sourceWidth)?.roundToDouble();
        final double? imgHeight =
            (fill.cropData?.height ?? fill.sourceHeight)?.roundToDouble();

        double? width, height;
        if (horizontalFit == SizeFit.shrinkWrap &&
            verticalFit == SizeFit.shrinkWrap) {
          width = imgWidth;
          height = imgHeight;
        } else if (imgWidth != null && imgHeight != null) {
          // If this image vertically shrinkwraps, then we want to set the
          // minimum height to be equal to or less than the source height,
          // preserving aspect ratio with respect to the current node width.
          if (verticalFit == SizeFit.shrinkWrap) {
            height =
                (imgHeight * (basicBoxLocal.width / imgWidth)).roundToDouble();
          }
          if (horizontalFit == SizeFit.shrinkWrap) {
            width =
                (imgWidth * (basicBoxLocal.height / imgHeight)).roundToDouble();
          }
        }

        resultSize = resultSize.union(
          BoxConstraintsModel(
            minWidth: width,
            minHeight: height,
          ),
        );
      }
    }
    return resultSize;
  }
}

/// Adds clipping functionality to a node.
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

/// Adds border shape properties to a node enabling the node to have differently
/// shaped borders.
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

/// Adds rounded corner shape properties to a node enabling the node to have
/// rounded corners.
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

/// Indicates that the node has some custom properties.
mixin CustomPropertiesMixin on BaseNode {
  /// Whether the node with custom properties handles its default reactions
  /// like click, long press, etc. internally. If this is true then the
  /// node itself is responsible for handling its own reactions. Otherwise,
  /// the transformer will provide for the default reactions.
  bool get handlesDefaultReactionsInternally => true;
}

/// Defines node that preserves its aspect ratio and cannot be resized by only
/// its width or height.
/// Ex. Switch, Radio Button, Checkbox, Icon, etc.
mixin FixedAspectRatioMixin on BaseNode {
  /// The aspect ratio of the node.
  double get aspectRatio;
}

/// Defines node that cannot be resized but can scale instead.
/// Ex. Switch, Radio Button, Checkbox, etc.
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

  /// Whether the node scale value is in the boundaries of [minScale] and
  /// [maxScale].
  bool get isScaleInBounds => scale >= minScale && scale <= maxScale;

  /// Whether the node is scaled up/down beyond the allowed
  /// [maxScale]/[minScale].
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
mixin VariablePropertiesMixin {
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

  /// Replace variable with [oldName] to [newName].
  @mustCallSuper
  void updateVariableName({required String oldName, required String newName}) {
    // variables
    for (final property in variables.keys) {
      final String variablePath = variables[property]!;
      if (!variablePath.startsWith(oldName)) continue;
      variables[property] = variablePath.replaceFirst(oldName, newName);
    }

    // multi-variables.
    for (final value in multipleVariables.values) {
      for (int index = 0; index < value.length; index++) {
        final variablePath = value[index];
        if (!variablePath.startsWith(oldName)) continue;
        value[index] = value[index].replaceFirst(oldName, newName);
      }
    }
  }
}

/// A mixin that allows to define properties of a node that can be set via an
/// action.
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

  /// Whether this is a row.
  bool get isRow => this == RowColumnType.row;

  /// Whether this is a column.
  bool get isColumn => this == RowColumnType.column;

  /// Returns the opposite of this [RowColumnType].
  RowColumnType get opposite => switch (this) {
        RowColumnType.row => RowColumnType.column,
        RowColumnType.column => RowColumnType.row,
      };
}

/// A mixin that allows node to have sequential children layout like row and
/// column.
/// This contains common properties of row and columns.
mixin RowColumnMixin on BaseNode {
  @override
  bool get supportsRotation => false;

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

/// A mixin that allows node behave like a placeholder for other nodes.
mixin PlaceholderMixin on BaseNode {
  @override
  bool get supportsRotation => false;
}

/// Represents the physics for scrolling on scrollable nodes like list view.
/// Corresponds to [ScrollPhysics] in Flutter.
enum ScrollPhysicsC {
  /// Scroll physics that always lets the user scroll.
  ///
  /// This overrides the default behavior which is to disable scrolling there is
  /// no content to scroll. It does not override the handling of over-scrolling.
  ///
  /// On Android, over-scrolls will be clamped by default and result in an
  /// overscroll glow. On iOS, over-scrolls will load a spring that will return
  /// the scroll view to its normal range when released.
  ///
  /// See [AlwaysScrollableScrollPhysics] in Flutter for more details.
  platformDependent,

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

  /// Scroll physics for environments that prevent the scroll offset from
  /// reaching beyond the bounds of the content.
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
      case ScrollPhysicsC.platformDependent:
        return 'Platform Dependent';
    }
  }
}

/// A representation of how a [ScrollView] should dismiss the on-screen
/// keyboard. Corresponds to [ScrollViewKeyboardDismissBehavior] in Flutter.
enum ScrollViewKeyboardDismissBehaviorC {
  /// [manual] means there is no automatic dismissal of the on-screen keyboard.
  /// It is up to the client to dismiss the keyboard.
  manual,

  /// [onDrag] means that the [ScrollView] will dismiss an on-screen keyboard
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
  @override
  bool get supportsRotation => false;

  /// Whether this widget enforces its scrollable behavior.
  /// [CanvasNode]s do not need to be scrollable but can.
  /// [ListViewNode]s, on the other hand, must be scrollable.
  ///
  /// If this is set to true, [isScrollable] becomes meaningless.
  bool get isScrollingEnforced => false;

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

  /// Physics to use for the scrollable.
  @JsonKey(unknownEnumValue: ScrollPhysicsC.platformDependent)
  late ScrollPhysicsC physics;

  /// Defines how a [ScrollView] should dismiss the on-screen keyboard.
  late ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior;

  /// Whether to use a [ListView] instead of [SingleChildScrollView] in flutter
  /// code-gen and transformers.
  late bool useFlutterListView;

  /// Whether to use AlwaysScrollableScrollPhysics or not.
  late bool shouldAlwaysScroll;

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
    required bool shouldAlwaysScroll,
  }) {
    this.isScrollable = isScrollable;
    this.scrollDirection = scrollDirection;
    this.reverse = reverse;
    this.physics = physics;
    this.primary = primary;
    this.keyboardDismissBehavior = keyboardDismissBehavior;
    this.useFlutterListView = useFlutterListView;
    this.shouldAlwaysScroll = shouldAlwaysScroll;
  }
}

/// A mixin that links a node [A] to another node [B], in that the linked node
/// [B] will be rendered into this node [A].
mixin PortalMixin on BaseNode {
  /// The id of the node that is linked to this node. IE: the node that this
  /// node will render inside of it.
  late String? canvasID;

  /// The id of the page that the linked node [canvasID] is in.
  late String? pageID;

  /// The id of the published layout that the linked node [canvasID] is in.
  late String? layoutID;

  /// Whether to render the [canvasID] node inside this node.
  late bool showPortal;

  /// Sets the properties of this mixin.
  void setPortalMixin({
    required String? canvasID,
    required String? pageID,
    required String? layoutID,
    required bool showPortal,
  }) {
    this.canvasID = canvasID;
    this.pageID = pageID;
    this.layoutID = layoutID;
    this.showPortal = showPortal;
  }
}

/// Type casts rotation value to integer.
int castRotation(dynamic v) => (v as num?)?.toInt() ?? 0;

/// Base mixin for providing [toJson] method to every class for
/// JSON serialization.
mixin BaseSerializableMixin<T> {
  /// Returns a serializable map representation of the object.
  T toJson();
}

/// A mixin typedef that serializes class to a [Map].
typedef SerializableMixin = BaseSerializableMixin<Map>;

/// A mixin typedef that serializes class to a dynamic.
typedef DynamicSerializableMixin = BaseSerializableMixin<dynamic>;

/// A mixin that adds the ability to add conditions to a node.
mixin ConditionsMixin {
  /// List of conditions that are applied to this node.
  List<BaseCondition> conditions = [];
}

/// A mixin that adds the ability to filter a collection of data
/// on a node.
mixin QueryableMixin {
  /// Whether to use cloud database.
  bool useCloudDatabase = false;

  /// The path of the collection to query.
  String? collectionPath;

  /// A limit integer to specify the number of documents to be returned.
  int? limit;

  /// Whether the query operation is going to be restrictive.
  /// This pertains to Firestore's indexing rules.
  bool get restrictedIndexing => useCloudDatabase;

  /// List of where() operations to be applied to the query.
  List<WhereQueryFilter> whereFilters = [];

  /// List of orderBy() operations to be applied to the query.
  List<OrderByQueryFilter> orderByFilters = [];

  /// Sets the properties of this mixin.
  void setQueryableMixin({
    required List<WhereQueryFilter> whereFilters,
    required List<OrderByQueryFilter> orderByFilters,
    required bool useCloudDatabase,
    required String? collectionPath,
    required int? limit,
  }) {
    this.whereFilters = whereFilters;
    this.orderByFilters = orderByFilters;
    this.useCloudDatabase = useCloudDatabase;
    this.collectionPath = collectionPath;
    this.limit = limit;
  }
}
