import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../mixins.dart';
import '../models/models.dart';

part 'frame_node.g.dart';

/// A node that represents a frame that behaves like a stack.
@FlutterNode('Stack', family: 'widgets', nodeType: 'frame')
@JsonSerializable()
class FrameNode extends DefaultShapeNode
    with CornerMixin, ClipMixin, ChildrenMixin, ScrollableMixin, PortalMixin {
  @override
  final String type = 'frame';

  @override
  final bool supportsPadding = true;

  /// Scales the frame's content to fit it, like Flutter's [FittedBox]: the
  /// children are laid out in the frame's design-size content box and the
  /// result is scaled by this fit into the content box the frame gets, e.g.
  /// [Fit.contain] to show a fixed drawing as large as it fits. Null (the
  /// default) lays the children out in the frame's actual size, unscaled.
  Fit? contentFit;

  /// Where scaled content sits in the frame when [contentFit] leaves space
  /// on one axis.
  AlignmentModel contentAlignment;

  /// The design size of the content box that [contentFit] scales from: the
  /// children are laid out in a box this big (inside the padding) and then
  /// scaled into the box the frame gets. Null takes the frame's own content
  /// box (its size minus padding), which changes whenever the frame is
  /// resized.
  ///
  /// Set it to scale a frame whose size follows its parent, e.g. a card
  /// drawn at 340x214 that fills the width it gets
  /// (`"horizontalFit": "expanded"`, `"layoutAspectRatio": 1.5888`) and scales
  /// its children with it. The children's boxes are in this design space.
  SizeC? contentSize;

  /// The size the children are laid out at before [contentFit] scales them:
  /// [contentSize] when set, otherwise the frame's content box.
  SizeC get contentDesignSize => contentSize ?? innerBoxLocal.size;

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
    super.enabled,
    super.opacity,
    super.isMask,
    super.strokeWeight,
    super.strokeMiterLimit,
    super.strokeAlign,
    super.strokeCap,
    double cornerSmoothing = 0,
    CornerRadius cornerRadius = CornerRadius.zero,
    List<NotchModel> notches = const [],
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
    this.contentFit,
    this.contentAlignment = AlignmentModel.center,
    this.contentSize,
  }) {
    setCornerMixin(
      cornerRadius: cornerRadius,
      notches: notches,
      cornerSmoothing: cornerSmoothing,
    );

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
    TriggerType.reorder,
    TriggerType.changed,
    TriggerType.wheel,
    TriggerType.pinch,
    TriggerType.pointerDown,
    TriggerType.pointerUp,
    ...TriggerType.viewport,
  ];

  /// Creates a [FrameNode] from a JSON data.
  factory FrameNode.fromJson(Map json) => _$FrameNodeFromJson(json);

  @override
  Map toJson() => _$FrameNodeOmitDefaults(this, _$FrameNodeToJson(this));
}
