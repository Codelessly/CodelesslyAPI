import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../mixins.dart';
import '../models/models.dart';

part 'path_node.g.dart';

/// A shape drawn from SVG path data: a curve, a squiggle, a trail, an
/// arrow, a blob. It is filled with its fills and outlined with its strokes
/// (weight, cap, join, dashes), like a rectangle.
///
/// The path's coordinates are in a [viewBoxWidth] × [viewBoxHeight] box
/// scaled to the node's size; without a view box they are the node's own
/// logical pixels. [trimStart] and [trimEnd] draw only part of the outline,
/// by length, so a line can draw itself on: bind `trimEnd` through
/// [BaseNode.variables] and set [transitionMs].
///
/// The same path data can drive [MotionModel.path], so a node can travel
/// along the line the path draws.
@FlutterNode('CodelesslyPath', family: 'codelessly', nodeType: 'path')
@JsonSerializable()
class PathNode extends DefaultShapeNode {
  @override
  final String type = 'path';

  /// SVG path data (`M0 0 C 40 -60 120 -60 160 0`). Bindable as `pathData`.
  String pathData;

  /// Width of the box the path's coordinates are in; scaled to the node's
  /// width. Null draws the coordinates as logical pixels.
  double? viewBoxWidth;

  /// Height of the box the path's coordinates are in. See [viewBoxWidth].
  double? viewBoxHeight;

  /// Where the outline starts, as a fraction of its length (0 to 1).
  /// Bindable as `trimStart`.
  double trimStart;

  /// Where the outline ends, as a fraction of its length (0 to 1): 0.5
  /// draws its first half. Bindable as `trimEnd`.
  double trimEnd;

  /// How the outline's segments meet at corners.
  StrokeJoinEnum strokeJoin;

  /// Colours of the path's shapes, one per closed subpath (an `M ... Z` of
  /// [pathData]) in the order they are drawn, as `#RRGGBB` or `#AARRGGBB`.
  /// The list repeats when it is shorter than the path's shapes: one colour
  /// per shape colours each by index, `['#E8762C', '#D9452B']` alternates.
  /// It replaces the colour of the node's solid fills (keeping each fill's
  /// opacity), so one path node of pollen cells paints every cell its own
  /// colour; gradient fills are painted as they are (a per-shape radial
  /// over the colours shades every cell). An entry that is not a colour
  /// keeps the fill's own colour for that shape. Subpaths inside the
  /// previous shape's bounds (holes) belong to that shape.
  ///
  /// Bindable as `subpathColors`: a list of colours, or a formula
  /// returning one (or a comma-separated string), e.g. a colour per cell
  /// worked out from the layout.
  List<String> subpathColors;

  /// Creates a new [PathNode] with the given data.
  PathNode({
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
    super.strokeWeight = 2,
    super.strokeMiterLimit,
    super.strokeAlign = StrokeAlignC.center,
    super.strokeCap = StrokeCapEnum.round,
    super.dashPattern,
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
    this.pathData = '',
    this.viewBoxWidth,
    this.viewBoxHeight,
    this.trimStart = 0,
    this.trimEnd = 1,
    this.strokeJoin = StrokeJoinEnum.round,
    this.subpathColors = const [],
  });

  /// The properties that can be bound to variables or formulas through
  /// [BaseNode.variables].
  static const List<String> bindableProperties = [
    'pathData',
    'trimStart',
    'trimEnd',
    'subpathColors',
  ];

  /// Creates a new [PathNode] from a JSON data.
  factory PathNode.fromJson(Map json) => _$PathNodeFromJson(json);

  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.longPress,
    TriggerType.doubleTap,
    ...TriggerType.swipes,
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
    TriggerType.drag,
    TriggerType.dragEnd,
    TriggerType.reorder,
    TriggerType.changed,
  ];

  @override
  Map toJson() => _$PathNodeOmitDefaults(this, _$PathNodeToJson(this));
}
