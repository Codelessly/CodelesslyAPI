import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'freeform_placeholder_node.g.dart';

/// An unselectable node that serves as a placeholder for Freeform nodes.
/// Related: [AutoPlaceholderNode].
@JsonSerializable()
class FreeformPlaceholderNode extends DefaultShapeNode
    with ChildrenMixin, PlaceholderMixin, IsolatedMixin {
  @override
  final String type = 'freeformPlaceholder';

  @override
  final bool supportsPadding = true;

  /// Creates a new [FreeformPlaceholderNode] instance with given data.
  FreeformPlaceholderNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    required List<String> children,
    super.retainedOuterBoxLocal,
    super.rotationDegrees,
    super.visible,
    super.enabled,
    double cornerSmoothing = 0,
    CornerRadius cornerRadius = CornerRadius.zero,
    super.alignment,
    super.padding,
    super.margin,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    // [ClipMixin] properties.
    bool clipsContent = true,
    // [DefaultShapeNode] properties.
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
  }) {
    setChildrenMixin(children: children);
  }

  /// Creates a new [FreeformPlaceholderNode] instance from a json data.
  factory FreeformPlaceholderNode.fromJson(Map json) =>
      _$FreeformPlaceholderNodeFromJson(json);

  @override
  Map toJson() => _$FreeformPlaceholderNodeToJson(this);
}
