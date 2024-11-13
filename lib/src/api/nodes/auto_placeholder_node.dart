import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'auto_placeholder_node.g.dart';

/// An unselectable node that serves as a placeholder for Auto nodes.
/// Its interaction and layout behavior is same as [AutoCanvasNode].
/// Related: [FreeformPlaceholderNode].
@JsonSerializable()
class AutoPlaceholderNode extends DefaultShapeNode
    with ChildrenMixin, RowColumnMixin, PlaceholderMixin, IsolatedMixin {
  @override
  final String type = 'autoPlaceholder';

  @override
  final bool supportsPadding = true;

  /// Whether the placeholder is only meant to exist for a short period of time.
  /// This is used to determine whether the placeholder should be removed when
  /// the user inserts anything into it.
  bool ephemeral = false;

  /// Creates a new [AutoPlaceholderNode] instance.
  AutoPlaceholderNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    RowColumnType rowColumnType = RowColumnType.column,
    MainAxisAlignmentC mainAxisAlignment = MainAxisAlignmentC.center,
    CrossAxisAlignmentC crossAxisAlignment = CrossAxisAlignmentC.center,
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
    // ClipMixin properties.
    bool clipsContent = true,
    // DefaultShapeNode properties.
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

    // PlaceholderMixin properties.
    this.ephemeral = false,
  }) {
    setChildrenMixin(children: children);
    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  /// Creates an [AutoPlaceholderNode] instance from a JSON data.
  factory AutoPlaceholderNode.fromJson(Map json) =>
      _$AutoPlaceholderNodeFromJson(json);

  @override
  Map toJson() => _$AutoPlaceholderNodeToJson(this);
}
