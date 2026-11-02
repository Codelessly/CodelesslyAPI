import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../mixins.dart';
import '../models/models.dart';

part 'rectangle_node.g.dart';

/// Represents a rectangular node with decoration that cannot have any children.
/// Typically a box with color or gradient, or an image.
@FlutterNode('CodelesslyRectangle', family: 'codelessly', nodeType: 'rectangle')
@JsonSerializable()
class RectangleNode extends DefaultShapeNode with CornerMixin, ClipMixin {
  @override
  final String type = 'rectangle';

  @override
  final bool supportsPadding = true;

  /// An open or closed shape to draw instead of the box, as SVG path data
  /// in the node's own coordinates (0,0 is its top-left corner, in pixels):
  /// `M0 30 V8 Q0 0 8 0 H30` draws a corner bracket. The strokes stroke the
  /// path with [strokeWeight], [strokeCap] and [strokeJoin] (centered on it,
  /// whatever [strokeAlign] says), and the fills fill it; the corner radius,
  /// notches and shadows of the box don't apply. A path is drawn whole: it
  /// is not clipped to the box, so round caps at its edge show. Supports
  /// the M, L, H, V, C, S, Q, T, A and Z commands, absolute and relative.
  /// Null draws the box.
  String? path;

  /// How the segments of [path] meet when it is stroked.
  @JsonKey(unknownEnumValue: StrokeJoinEnum.miter)
  StrokeJoinEnum strokeJoin;

  /// Whether this rectangle draws [path] instead of its box.
  bool get hasPath => path != null && path!.trim().isNotEmpty;

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
    List<NotchModel> notches = const [],
    // [ClipMixin] properties.
    bool clipsContent = true,
    this.path,
    this.strokeJoin = StrokeJoinEnum.miter,
  }) {
    setCornerMixin(
      cornerRadius: cornerRadius,
      notches: notches,
      cornerSmoothing: cornerSmoothing,
    );

    setClipMixin(clipsContent: clipsContent);
  }

  /// Creates a new [RectangleNode] from a JSON data.
  factory RectangleNode.fromJson(Map json) => _$RectangleNodeFromJson(json);

  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.longPress,
    TriggerType.doubleTap,
    ...TriggerType.swipes,
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
    TriggerType.hold,
    TriggerType.drag,
    TriggerType.dragEnd,
    TriggerType.pointerDown,
    TriggerType.pointerUp,
  ];

  @override
  Map toJson() =>
      _$RectangleNodeOmitDefaults(this, _$RectangleNodeToJson(this));
}
