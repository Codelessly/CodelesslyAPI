import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';

part 'frame_node.g.dart';

/// A node that represents a frame that behaves like a stack.
@JsonSerializable()
class FrameNode extends DefaultShapeNode
    with CornerMixin, ClipMixin, ChildrenMixin, ScrollableMixin, PortalMixin {
  @override
  final String type = 'frame';

  @override
  final bool supportsPadding = true;

  /// Frame is a Rectangle with children, which can be clipped.
  FrameNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    required List<String> children,
    super.retainedOuterBoxLocal,
    super.rotationDegrees,
    super.fills,
    super.strokes,
    super.effects,
    super.blendMode,
    super.visible,
    super.opacity,
    super.isMask,
    super.strokeWeight,
    super.strokeMiterLimit,
    super.strokeAlign,
    super.strokeCap,
    double cornerSmoothing = 0,
    CornerRadius cornerRadius = CornerRadius.zero,
    super.dashPattern,
    super.alignment,
    super.padding,
    super.margin,
    super.strokeSide,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    super.parentID,

    // [ClipMixin] properties.
    bool clipsContent = true,

    // [ScrollableMixin] properties.
    bool isScrollable = false,
    AxisC scrollDirection = AxisC.vertical,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.platformDependent,
    bool primary = true,
    bool shrinkWrap = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
    bool useFlutterListView = false,
    bool shouldAlwaysScroll = true,

    // [PortalMixin] properties.
    String? canvasID,
    String? pageID,
    String? layoutID,
    bool showPortal = false,
  }) {
    setCornerMixin(
        cornerRadius: cornerRadius, cornerSmoothing: cornerSmoothing);

    setClipMixin(clipsContent: clipsContent);

    setChildrenMixin(children: children);

    setScrollableMixin(
      isScrollable: isScrollable,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      primary: primary,
      shrinkWrap: shrinkWrap,
      keyboardDismissBehavior: keyboardDismissBehavior,
      useFlutterListView: useFlutterListView,
      shouldAlwaysScroll: shouldAlwaysScroll,
    );

    setPortalMixin(
      canvasID: canvasID,
      pageID: pageID,
      layoutID: layoutID,
      showPortal: showPortal,
    );
  }

  @override
  List<TriggerType> get triggerTypes =>
      [TriggerType.click, TriggerType.longPress];

  /// Creates a [FrameNode] from a JSON data.
  factory FrameNode.fromJson(Map json) => _$FrameNodeFromJson(json);

  @override
  Map toJson() => _$FrameNodeToJson(this);
}
