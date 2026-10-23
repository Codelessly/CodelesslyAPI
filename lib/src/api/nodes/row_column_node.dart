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

  @JsonKey(includeFromJson: false)
  @override
  AxisC get scrollDirection =>
      rowColumnType == RowColumnType.row ? AxisC.horizontal : AxisC.vertical;

  @override
  set scrollDirection(AxisC value) {}

  /// Whether the children flow onto a new run (a line for a row, a column of
  /// items for a column) when they don't fit on the main axis, like Flutter's
  /// [Wrap]. Items keep their own size: a child that flexes on the main axis
  /// can't share free space in a run, so it takes its design size there.
  /// [mainAxisAlignment] places the items within each run and
  /// [crossAxisAlignment] places them within their run's thickness (stretch
  /// and baseline aren't available in a wrap and align to the start).
  /// The space between items is the children's margins.
  bool wrap;

  /// The space between runs on the cross axis when [wrap] is true.
  double runSpacing;

  /// How the runs are placed on the cross axis when [wrap] is true and the
  /// node is thicker than its runs.
  MainAxisAlignmentC runAlignment;

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
    this.wrap = false,
    this.runSpacing = 0,
    this.runAlignment = MainAxisAlignmentC.start,
  }) {
    setCornerMixin(
      cornerRadius: cornerRadius,
      cornerSmoothing: cornerSmoothing,
    );

    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
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

  /// Creates a [RowColumnNode] from a JSON data.
  factory RowColumnNode.fromJson(Map json) => _$RowColumnNodeFromJson(json);

  @override
  Map toJson() =>
      _$RowColumnNodeOmitDefaults(this, _$RowColumnNodeToJson(this));

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'wrap': BoolFieldAccess(
      'Wrap',
      'Whether the children flow onto a new run when they don\'t fit.',
      () => wrap,
      (value) => wrap = value,
      defaultValue: () => false,
      requiresLayout: true,
    ),
    'runSpacing': NumFieldAccess<double>(
      'Run Spacing',
      'The space between runs when the children wrap.',
      () => runSpacing,
      (value) => runSpacing = value,
      min: 0,
      defaultValue: () => 0,
      requiresLayout: true,
    ),
    'runAlignment': EnumFieldAccess<MainAxisAlignmentC>(
      'Run Alignment',
      'How the runs are placed on the cross axis when the children wrap.',
      () => runAlignment,
      (value) => runAlignment = value,
      defaultValue: () => MainAxisAlignmentC.start,
      options: () => MainAxisAlignmentC.values,
      requiresLayout: true,
    ),
  };
}
