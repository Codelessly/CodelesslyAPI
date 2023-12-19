import 'dart:math';

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

part 'grid_view_node.g.dart';

/// A material design [GridView].
/// Refer to [GridView](https://api.flutter.dev/flutter/widgets/GridView-class.html)
/// in Flutter for more details.
@JsonSerializable()
class GridViewNode extends SinglePlaceholderNode
    with ScrollableMixin, CustomPropertiesMixin, ClipMixin, QueryableMixin {
  @override
  final String type = 'gridView';

  @override
  final bool supportsPadding = true;

  @override
  bool get isScrollingEnforced => true;

  /// The properties of the [GridView].
  GridViewProperties properties;

  /// Creates a [GridViewNode].
  GridViewNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
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
    super.parentID,
    super.reactions,
    required this.properties,
    required List<String> children,
    super.variables,
    super.multipleVariables,
    bool clipsContent = true,

    // [CloudDatabaseMixin] properties.
    bool useCloudDatabase = false,
    String? collectionPath,
    int? limit = 20,
    List<WhereQueryFilter>? whereOperations,
    List<OrderByQueryFilter>? orderByFilters,

    // [ScrollableMixin] properties.
    AxisC scrollDirection = AxisC.vertical,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.platformDependent,
    bool primary = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
    bool shouldAlwaysScroll = true,
  }) : super(
          children: [],
          allowedTypes: [],
          deniedTypes: [
            'GridView',
          ],
        ) {
    setChildrenMixin(children: children);
    setClipMixin(clipsContent: clipsContent);

    setScrollableMixin(
      isScrollable: true,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      primary: primary,
      shrinkWrap: false,
      keyboardDismissBehavior: keyboardDismissBehavior,
      useFlutterListView: false,
      shouldAlwaysScroll: shouldAlwaysScroll,
    );

    setQueryableMixin(
      useCloudDatabase: useCloudDatabase,
      collectionPath: collectionPath,
      limit: limit,
      whereFilters: whereOperations ?? [],
      orderByFilters: orderByFilters ?? [],
    );
  }

  /// Calculates the fixed main axis extent of any child in the grid.
  double calculateMainAxisExtent(
    AxisC mainAxis,
    SizeC size, [
    double? crossAxisExtent,
  ]) {
    final childCrossAxisExtent = crossAxisExtent ??
        calculateCrossAxisExtent(
          scrollDirection,
          innerBoxLocal.size,
        );

    return properties.gridDelegate.mainAxisExtent ??
        childCrossAxisExtent / properties.gridDelegate.childAspectRatio;
  }

  /// Calculates the fixed cross axis extent of any child in the grid.
  double calculateCrossAxisExtent(AxisC mainAxis, SizeC size) {
    // Total cross axis space available for the grid view.
    final double totalCrossAxisSize =
        mainAxis.opposite.isHorizontal ? size.width : size.height;

    switch (properties.gridDelegate) {
      case FixedCrossAxisCountGridDelegateProperties prop:
        final double usableCrossAxisExtent = max(
          0.0,
          totalCrossAxisSize -
              prop.crossAxisSpacing * (prop.crossAxisCount - 1),
        );
        return usableCrossAxisExtent / prop.crossAxisCount;
      case MaxCrossAxisExtentGridDelegateProperties prop:
        int crossAxisCount = (totalCrossAxisSize /
                (prop.maxCrossAxisExtent + prop.crossAxisSpacing))
            .ceil();
        crossAxisCount = max(1, crossAxisCount);

        final double usableCrossAxisExtent = max(
          0.0,
          totalCrossAxisSize - prop.crossAxisSpacing * (crossAxisCount - 1),
        );
        return usableCrossAxisExtent / crossAxisCount;
    }
  }

  @override
  BoxConstraintsModel? relegatedConstraintsToChildren(BaseNode child) {
    final double childCrossAxisExtent = calculateCrossAxisExtent(
      scrollDirection,
      innerBoxLocal.size,
    );
    final double childMainAxisExtent = calculateMainAxisExtent(
      scrollDirection,
      innerBoxLocal.size,
      childCrossAxisExtent,
    );

    return switch (scrollDirection) {
      AxisC.horizontal => BoxConstraintsModel(
          minWidth: childMainAxisExtent,
          maxWidth: childMainAxisExtent,
          minHeight: childCrossAxisExtent,
          maxHeight: childCrossAxisExtent,
        ),
      AxisC.vertical => BoxConstraintsModel(
          minWidth: childCrossAxisExtent,
          maxWidth: childCrossAxisExtent,
          minHeight: childMainAxisExtent,
          maxHeight: childMainAxisExtent,
        ),
    };
  }

  /// Creates a [GridViewNode] from a JSON object.
  factory GridViewNode.fromJson(Map json) => _$GridViewNodeFromJson(json);

  @override
  Map toJson() => _$GridViewNodeToJson(this);

  /// Returns the appropriate alignment of the child based on the
  /// [scrollDirection] and [reverse] properties.
  AlignmentModel childAlignment() {
    switch (scrollDirection) {
      case AxisC.horizontal:
        return reverse ? AlignmentModel.topRight : AlignmentModel.topLeft;
      case AxisC.vertical:
        return reverse ? AlignmentModel.bottomLeft : AlignmentModel.topLeft;
    }
  }
}

/// The properties of a [GridViewNode].
@JsonSerializable()
class GridViewProperties with SerializableMixin, EquatableMixin {
  /// The number of items to display in the list view. Can be null if the list
  /// is infinite.
  int? itemCount;

  /// The number of pixels by which to allow pre-rendering of items outside
  /// the visible area.
  double? cacheExtent;

  /// Properties of the grid delegate that controls the layout of the grid.
  GridDelegateProperties gridDelegate;

  /// Creates a new [GridViewProperties] instance.
  GridViewProperties({
    this.itemCount,
    this.cacheExtent,
    required this.gridDelegate,
    DividerProperties? dividerProperties,
  });

  /// Creates a copy of this [GridViewProperties] instance with the given value
  /// overrides.
  GridViewProperties copyWith({
    String? bodyId,
    int? itemCount,
    ScrollPhysicsC? physics,
    AxisC? scrollDirection,
    double? cacheExtent,
    bool? reverse,
    GridDelegateProperties? gridDelegate,
  }) {
    return GridViewProperties(
      itemCount: itemCount ?? this.itemCount,
      cacheExtent: cacheExtent ?? this.cacheExtent,
      gridDelegate: gridDelegate ?? this.gridDelegate,
    );
  }

  @override
  Map toJson() => _$GridViewPropertiesToJson(this);

  /// Creates a [GridViewProperties] from a JSON object.
  factory GridViewProperties.fromJson(Map json) =>
      _$GridViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        itemCount,
        cacheExtent,
        gridDelegate,
      ];
}

/// The properties of a grid delegate that controls the layout of a
/// [GridViewNode].
sealed class GridDelegateProperties with EquatableMixin, SerializableMixin {
  /// Represents the type of grid delegate.
  final GridDelegateType type;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child. This
  /// is ignored if [mainAxisExtent] is not null.
  final double childAspectRatio;

  /// The main axis extent of each child in the grid. If this is null, then
  /// [childAspectRatio] controls the main axis extent of each child.
  final double? mainAxisExtent;

  /// Creates a new [GridDelegateProperties] instance.
  const GridDelegateProperties(
    this.type, {
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
  });

  /// Creates a copy of this [GridDelegateProperties] instance with the given
  /// value overrides.
  GridDelegateProperties copyWith({
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    double? childAspectRatio,
    double? mainAxisExtent,
    bool forceMainAxisExtent = false,
  });

  factory GridDelegateProperties.fromJson(Map json) {
    final type = GridDelegateType.values.byName(json['type']);
    return switch (type) {
      GridDelegateType.fixedCrossAxisCount =>
        FixedCrossAxisCountGridDelegateProperties.fromJson(json),
      GridDelegateType.maxCrossAxisExtent =>
        MaxCrossAxisExtentGridDelegateProperties.fromJson(json),
    };
  }

  @override
  List<Object?> get props => [type];
}

/// Represents a delegate that makes grid layouts with a fixed number of tiles
/// in the cross axis.
@JsonSerializable()
class FixedCrossAxisCountGridDelegateProperties extends GridDelegateProperties {
  /// The number of children to fit in the cross axis for a grid view.
  final int crossAxisCount;

  /// Creates a new [FixedCrossAxisCountGridDelegateProperties] instance.
  const FixedCrossAxisCountGridDelegateProperties({
    required this.crossAxisCount,
    super.mainAxisSpacing = 0,
    super.crossAxisSpacing = 0,
    super.childAspectRatio = 1,
    super.mainAxisExtent,
  }) : super(GridDelegateType.fixedCrossAxisCount);

  @override
  Map toJson() => _$FixedCrossAxisCountGridDelegatePropertiesToJson(this)
    ..['type'] = type.name;

  /// Creates a [FixedCrossAxisCountGridDelegateProperties] from a JSON object.
  factory FixedCrossAxisCountGridDelegateProperties.fromJson(Map json) =>
      _$FixedCrossAxisCountGridDelegatePropertiesFromJson(json);

  /// Creates a copy of this [FixedCrossAxisCountGridDelegateProperties]
  /// instance with the given value overrides.
  @override
  FixedCrossAxisCountGridDelegateProperties copyWith({
    int? crossAxisCount,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    double? childAspectRatio,
    double? mainAxisExtent,
    bool forceMainAxisExtent = false,
  }) {
    return FixedCrossAxisCountGridDelegateProperties(
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      mainAxisSpacing: mainAxisSpacing ?? super.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? super.crossAxisSpacing,
      childAspectRatio: childAspectRatio ?? super.childAspectRatio,
      mainAxisExtent: forceMainAxisExtent
          ? mainAxisExtent
          : mainAxisExtent ?? super.mainAxisExtent,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        crossAxisCount,
      ];
}

/// Represents a delegate that makes grid layouts with tiles that each have a
/// maximum cross-axis extent.
@JsonSerializable()
class MaxCrossAxisExtentGridDelegateProperties extends GridDelegateProperties {
  /// The maximum extent of a child/item in the cross axis.
  final double maxCrossAxisExtent;

  /// Creates a new [MaxCrossAxisExtentGridDelegateProperties] instance.
  const MaxCrossAxisExtentGridDelegateProperties({
    required this.maxCrossAxisExtent,
    super.mainAxisSpacing = 0,
    super.crossAxisSpacing = 0,
    super.childAspectRatio = 1,
    super.mainAxisExtent,
  }) : super(GridDelegateType.maxCrossAxisExtent);

  @override
  Map toJson() => _$MaxCrossAxisExtentGridDelegatePropertiesToJson(this)
    ..['type'] = type.name;

  /// Creates a [MaxCrossAxisExtentGridDelegateProperties] from a JSON object.
  factory MaxCrossAxisExtentGridDelegateProperties.fromJson(Map json) =>
      _$MaxCrossAxisExtentGridDelegatePropertiesFromJson(json);

  /// Creates a copy of this [MaxCrossAxisExtentGridDelegateProperties]
  /// instance with the given value overrides.
  @override
  MaxCrossAxisExtentGridDelegateProperties copyWith({
    double? maxCrossAxisExtent,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    double? childAspectRatio,
    double? mainAxisExtent,
    bool forceMainAxisExtent = false,
  }) {
    return MaxCrossAxisExtentGridDelegateProperties(
      maxCrossAxisExtent: maxCrossAxisExtent ?? this.maxCrossAxisExtent,
      mainAxisSpacing: mainAxisSpacing ?? super.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? super.crossAxisSpacing,
      childAspectRatio: childAspectRatio ?? super.childAspectRatio,
      mainAxisExtent: forceMainAxisExtent
          ? mainAxisExtent
          : mainAxisExtent ?? super.mainAxisExtent,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        maxCrossAxisExtent,
      ];
}
