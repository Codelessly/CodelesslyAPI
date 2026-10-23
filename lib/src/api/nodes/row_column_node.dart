import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';

part 'row_column_node.g.dart';

/// A node that can lay out its children in a row or column.
/// Typically referred to [Row] and [Column] widgets in Flutter.
@JsonSerializable()
class RowColumnNode extends ParentNode
    with RowColumnMixin, ScrollableMixin, CornerMixin {
  @override
  final String type = 'rowColumn';

  @override
  final bool supportsPadding = true;

  /// A row/column scrolls along its main axis. One that [wrap]s scrolls
  /// along its cross axis instead, through its runs: its main axis is where
  /// it wraps, so it needs a bounded extent there.
  @JsonKey(includeFromJson: false)
  @override
  AxisC get scrollDirection => (rowColumnType == RowColumnType.row) != wrap
      ? AxisC.horizontal
      : AxisC.vertical;

  @override
  set scrollDirection(AxisC value) {}

  /// Creates a [RowColumnNode] with the given data.
  RowColumnNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    required super.children,
    required RowColumnType rowColumnType,
    MainAxisAlignmentC mainAxisAlignment = MainAxisAlignmentC.center,
    CrossAxisAlignmentC crossAxisAlignment = CrossAxisAlignmentC.center,
    double spacing = 0,
    bool wrap = false,
    double runSpacing = 0,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
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
    super.clipsContent = false,
    // [CornerMixin] properties.
    CornerRadius cornerRadius = CornerRadius.zero,
    double cornerSmoothing = 0,
    // [ScrollableMixin] properties.
    bool isScrollable = false,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.platformDependent,
    bool primary = true,
    bool shrinkWrap = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
    bool useFlutterListView = false,
    bool shouldAlwaysScroll = true,
  }) {
    setCornerMixin(
      cornerRadius: cornerRadius,
      cornerSmoothing: cornerSmoothing,
    );

    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      wrap: wrap,
      runSpacing: runSpacing,
    );

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
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'spacing': NumFieldAccess<double>(
      'Spacing',
      'Gap between consecutive children along the main axis.',
      () => spacing,
      (value) => spacing = value,
      defaultValue: () => 0,
      min: 0,
      requiresLayout: true,
    ),
    'wrap': BoolFieldAccess(
      'Wrap',
      'Whether children wrap onto further runs when they do not fit.',
      () => wrap,
      (value) => wrap = value,
      defaultValue: () => false,
      requiresLayout: true,
    ),
    'runSpacing': NumFieldAccess<double>(
      'Run Spacing',
      'Gap between runs along the cross axis when wrapping.',
      () => runSpacing,
      (value) => runSpacing = value,
      defaultValue: () => 0,
      min: 0,
      requiresLayout: true,
    ),
  };

  /// Creates a [RowColumnNode] from a JSON data.
  factory RowColumnNode.fromJson(Map json) => _$RowColumnNodeFromJson(json);

  @override
  Map toJson() =>
      _$RowColumnNodeOmitDefaults(this, _$RowColumnNodeToJson(this));
}
