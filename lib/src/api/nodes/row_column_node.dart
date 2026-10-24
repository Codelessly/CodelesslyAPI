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

  /// Whether a row lays its children out in runs, starting a new line when
  /// the next child does not fit the remaining width, like Flutter's [Wrap].
  ///
  /// Only rows wrap; a column ignores it. A wrapping row does not scroll, and
  /// its expanded or flexible children take their natural (design) size, as
  /// children of a Flutter [Wrap] do. [mainAxisAlignment] aligns each run
  /// along the row, and [crossAxisAlignment] aligns each child within its
  /// run (stretch and baseline behave as start).
  bool wrap;

  /// The gap between neighboring children of a run, along the main axis,
  /// when [wrap] is on. Corresponds to [Wrap.spacing].
  double spacing;

  /// The gap between runs, along the cross axis, when [wrap] is on.
  /// Corresponds to [Wrap.runSpacing].
  double runSpacing;

  /// Whether this node wraps its children into runs: [wrap] is on and it is
  /// a row.
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get wrapsChildren => wrap && rowColumnType == RowColumnType.row;

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
    this.wrap = false,
    this.spacing = 0,
    this.runSpacing = 0,
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
    'wrap': BoolFieldAccess(
      'Wrap',
      'Whether a row starts a new line when its children do not fit.',
      () => wrap,
      (value) => wrap = value,
      defaultValue: () => false,
      requiresLayout: true,
    ),
    'spacing': NumFieldAccess<double>(
      'Spacing',
      'Gap between children of a run when wrap is on.',
      () => spacing,
      (value) => spacing = value,
      min: 0,
      defaultValue: () => 0,
      requiresLayout: true,
    ),
    'runSpacing': NumFieldAccess<double>(
      'Run Spacing',
      'Gap between runs when wrap is on.',
      () => runSpacing,
      (value) => runSpacing = value,
      min: 0,
      defaultValue: () => 0,
      requiresLayout: true,
    ),
  };

  /// Creates a [RowColumnNode] from a JSON data.
  factory RowColumnNode.fromJson(Map json) => _$RowColumnNodeFromJson(json);

  @override
  Map toJson() =>
      _$RowColumnNodeOmitDefaults(this, _$RowColumnNodeToJson(this));
}
