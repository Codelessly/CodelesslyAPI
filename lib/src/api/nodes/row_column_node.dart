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

  /// The gap, in logical pixels, inserted between consecutive visible
  /// children along the main axis. Equivalent to Flutter's
  /// `Row(spacing: ...)` / `Column(spacing: ...)` and CSS `gap`.
  ///
  /// Only children that are actually laid out (visible) receive a gap; a
  /// hidden child does not contribute an extra gap. Defaults to 0 and is
  /// omitted from JSON at the default.
  double itemSpacing;

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
    this.itemSpacing = 0,
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
    'itemSpacing': NumFieldAccess<double>(
      'Gap',
      'Space between consecutive children along the main axis.',
      () => itemSpacing,
      (value) => itemSpacing = value,
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
