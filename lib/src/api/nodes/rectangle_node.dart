import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';

part 'rectangle_node.g.dart';

/// Represents a rectangular node with decoration that cannot have any children.
/// Typically a box with color or gradient, or an image.
@JsonSerializable()
class RectangleNode extends DefaultShapeNode with CornerMixin, ClipMixin {
  @override
  final String type = 'rectangle';

  @override
  final bool supportsPadding = true;

  /// Creates a new [RectangleNode] with the given data.
  RectangleNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.rotationDegrees,
    super.fills,
    super.strokes,
    super.effects,
    super.blendMode,
    super.visible,
    super.enabled,
    super.opacity,
    super.isMask,
    super.strokeWeight = 0,
    super.strokeMiterLimit,
    super.strokeAlign,
    super.strokeCap,
    super.dashPattern,
    super.padding,
    super.margin,
    super.alignment,
    super.strokeSide,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    // [CornerMixin] properties.
    double cornerSmoothing = 0,
    CornerRadius cornerRadius = CornerRadius.zero,
    // [ClipMixin] properties.
    bool clipsContent = true,
  }) {
    setCornerMixin(
      cornerRadius: cornerRadius,
      cornerSmoothing: cornerSmoothing,
    );

    setClipMixin(clipsContent: clipsContent);
  }

  /// Creates a new [RectangleNode] from a JSON data.
  factory RectangleNode.fromJson(Map json) => _$RectangleNodeFromJson(json);

  @override
  List<TriggerType> get triggerTypes =>
      [TriggerType.click, TriggerType.longPress];

  @override
  Map toJson() => _$RectangleNodeToJson(this);
}
