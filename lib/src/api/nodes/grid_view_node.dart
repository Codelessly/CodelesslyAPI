import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

part 'grid_view_node.g.dart';

/// A material design [GridView].
/// Refer to [GridView](https://api.flutter.dev/flutter/widgets/GridView-class.html)
/// in Flutter for more details.
@JsonSerializable()
class GridViewNode extends SinglePlaceholderNode
    with ScrollableMixin, CustomPropertiesMixin, ClipMixin {
  @override
  final String type = 'gridView';

  @override
  final bool supportsPadding = true;

  @override
  bool get isScrollingEnforced => true;

  /// The properties of the [GridView].
  GridViewProperties properties;

  @override
  BoxConstraintsModel? relegatedConstraintsToChildren(BaseNode child) {
    // TODO: implement relegatedConstraintsToChildren.
    // if (scrollDirection == AxisC.vertical) {
    //   return BoxConstraintsModel(maxHeight: properties.itemExtent);
    // } else {
    //   return BoxConstraintsModel(maxWidth: properties.itemExtent);
    // }
  }

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
        return reverse ? AlignmentModel.centerRight : AlignmentModel.centerLeft;
      case AxisC.vertical:
        return reverse ? AlignmentModel.bottomCenter : AlignmentModel.topCenter;
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

/// Defines the type of grid delegate to use for a [GridViewNode].
enum GridDelegateType {
  /// Represents a delegate that makes grid layouts with a fixed number of tiles
  /// in the cross axis.
  fixedCrossAxisCount,

  /// Represents a delegate that makes grid layouts with tiles that each have a
  /// maximum cross-axis extent.
  maxCrossAxisExtent;

  /// Pretty name of the enum value.
  String get label => switch (this) {
        fixedCrossAxisCount => 'Fixed Cross Axis Count',
        maxCrossAxisExtent => 'Max Cross Axis Extent',
      };
}

sealed class GridDelegateProperties with EquatableMixin, SerializableMixin {
  final GridDelegateType type;

  /// Creates a new [GridDelegateProperties] instance.
  const GridDelegateProperties(this.type);

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
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;

  /// Creates a new [FixedCrossAxisCountGridDelegateProperties] instance.
  const FixedCrossAxisCountGridDelegateProperties({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
  }) : super(GridDelegateType.fixedCrossAxisCount);

  @override
  Map toJson() => _$FixedCrossAxisCountGridDelegatePropertiesToJson(this)
    ..['type'] = type.name;

  factory FixedCrossAxisCountGridDelegateProperties.fromJson(Map json) =>
      _$FixedCrossAxisCountGridDelegatePropertiesFromJson(json);

  /// Creates a copy of this [FixedCrossAxisCountGridDelegateProperties]
  /// instance with the given value overrides.
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
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      mainAxisExtent: forceMainAxisExtent
          ? mainAxisExtent
          : mainAxisExtent ?? this.mainAxisExtent,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        crossAxisCount,
        mainAxisSpacing,
        crossAxisSpacing,
        childAspectRatio,
      ];
}

/// Represents a delegate that makes grid layouts with tiles that each have a
/// maximum cross-axis extent.
@JsonSerializable()
class MaxCrossAxisExtentGridDelegateProperties extends GridDelegateProperties {
  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;

  /// Creates a new [MaxCrossAxisExtentGridDelegateProperties] instance.
  const MaxCrossAxisExtentGridDelegateProperties({
    required this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
  }) : super(GridDelegateType.maxCrossAxisExtent);

  @override
  Map toJson() => _$MaxCrossAxisExtentGridDelegatePropertiesToJson(this)
    ..['type'] = type.name;

  factory MaxCrossAxisExtentGridDelegateProperties.fromJson(Map json) =>
      _$MaxCrossAxisExtentGridDelegatePropertiesFromJson(json);

  /// Creates a copy of this [MaxCrossAxisExtentGridDelegateProperties]
  /// instance with the given value overrides.
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
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      mainAxisExtent: forceMainAxisExtent
          ? mainAxisExtent
          : mainAxisExtent ?? this.mainAxisExtent,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        maxCrossAxisExtent,
        mainAxisSpacing,
        crossAxisSpacing,
        childAspectRatio,
      ];
}
