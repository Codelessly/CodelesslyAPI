import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';

import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

part 'grid_view_node.g.dart';

/// A material design [GridView].
/// Refer to [GridView](https://api.flutter.dev/flutter/widgets/GridView-class.html)
/// in Flutter for more details.
@FlutterNode('GridView', family: 'widgets', nodeType: 'gridView')
@JsonSerializable()
class GridViewNode extends SinglePlaceholderNode
    with
        ScrollableMixin,
        CustomPropertiesMixin,
        ClipMixin,
        QueryableMixin,
        FieldsHolder {
  @override
  final String type = 'gridView';

  @override
  final bool supportsPadding = true;

  @override
  bool get isScrollingEnforced => true;

  @override
  bool get canBeMarked => true;

  /// The properties of the [GridView].
  @override
  covariant GridViewProperties properties;

  /// A text variable this GridView writes the status of its cloud query into,
  /// for loading, empty and error states: [kQueryStatusLoading],
  /// [kQueryStatusEmpty], [kQueryStatusError] or [kQueryStatusLoaded].
  VariableData? statusVariable;

  /// Creates a [GridViewNode].
  GridViewNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
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
    super.parentID,
    super.reactions,
    required this.properties,
    required List<String> children,
    super.variables,
    super.multipleVariables,
    bool clipsContent = true,
    this.statusVariable,

    // A grid always scrolls its items and never uses a Flutter ListView.
    // Their defaults are shared with the ScrollableMixin parameters below.
    // [CloudDatabaseMixin] properties.
    bool useCloudDatabase = false,
    String? collectionPath,
    int? limit = 20,
    List<WhereQueryFilter>? whereFilters,
    List<OrderByQueryFilter>? orderByFilters,

    // [ScrollableMixin] properties.
    bool isScrollable = true,
    bool useFlutterListView = false,
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
         deniedTypes: ['GridView'],
         ephemeral: false,
       ) {
    setChildrenMixin(children: children);
    setClipMixin(clipsContent: clipsContent);

    setScrollableMixin(
      isScrollable: isScrollable,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      primary: primary,
      shrinkWrap: false,
      keyboardDismissBehavior: keyboardDismissBehavior,
      useFlutterListView: useFlutterListView,
      shouldAlwaysScroll: shouldAlwaysScroll,
    );

    setQueryableMixin(
      useCloudDatabase: useCloudDatabase,
      collectionPath: collectionPath,
      limit: limit,
      whereFilters: whereFilters ?? [],
      orderByFilters: orderByFilters ?? [],
    );
  }

  /// Calculates the fixed main axis extent of any child in the grid.
  double calculateMainAxisExtent(
    AxisC mainAxis,
    SizeC size, [
    double? crossAxisExtent,
  ]) {
    final childCrossAxisExtent =
        crossAxisExtent ??
        calculateCrossAxisExtent(scrollDirection, innerBoxLocal.size);

    return properties.gridDelegate.mainAxisExtent ??
        childCrossAxisExtent / properties.gridDelegate.childAspectRatio;
  }

  /// Calculates the fixed cross axis extent of any child in the grid.
  double calculateCrossAxisExtent(AxisC mainAxis, SizeC size) {
    // Total cross axis space available for the grid view.
    final double totalCrossAxisSize = mainAxis.opposite.isHorizontal
        ? size.width
        : size.height;

    switch (properties.gridDelegate) {
      case FixedCrossAxisCountGridDelegateProperties prop:
        final double usableCrossAxisExtent = max(
          0.0,
          totalCrossAxisSize -
              prop.crossAxisSpacing * (prop.crossAxisCount - 1),
        );
        return usableCrossAxisExtent / prop.crossAxisCount;
      case MaxCrossAxisExtentGridDelegateProperties prop:
        int crossAxisCount =
            (totalCrossAxisSize /
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

    // Rows sized to their content leave the item's main axis to its own fit.
    final bool shrinkWrapRows = properties.gridDelegate.shrinkWrapRows;
    return switch (scrollDirection) {
      AxisC.horizontal => BoxConstraintsModel(
        minWidth: shrinkWrapRows ? null : childMainAxisExtent,
        maxWidth: shrinkWrapRows ? null : childMainAxisExtent,
        minHeight: childCrossAxisExtent,
        maxHeight: childCrossAxisExtent,
      ),
      AxisC.vertical => BoxConstraintsModel(
        minWidth: childCrossAxisExtent,
        maxWidth: childCrossAxisExtent,
        minHeight: shrinkWrapRows ? null : childMainAxisExtent,
        maxHeight: shrinkWrapRows ? null : childMainAxisExtent,
      ),
    };
  }

  /// Returns the appropriate alignment of the child based on the
  /// [scrollDirection] and [reverse] properties.
  AlignmentModel gridChildAlignment() {
    switch (scrollDirection) {
      case AxisC.horizontal:
        return reverse ? AlignmentModel.topRight : AlignmentModel.topLeft;
      case AxisC.vertical:
        return reverse ? AlignmentModel.bottomLeft : AlignmentModel.topLeft;
    }
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<GridViewProperties>(
      'Properties',
      'Properties of the GridView.',
      () => properties,
      (value) => properties = value,
    ),
  };

  /// Creates a [GridViewNode] from a JSON object.
  factory GridViewNode.fromJson(Map json) => _$GridViewNodeFromJson({
    // Node JSON may leave out scrolling fields; read the constructor's.
    'isScrollable': true,
    'useFlutterListView': false,
    'allowedTypes': <String>[],
    'deniedTypes': ['GridView'],
    ...json,
  });

  /// Keys that SDKs up to codelessly_api 6.0.0 require in a grid's JSON. They are written
  /// even at their defaults so those SDKs can still read it.
  static const List<String> _legacyRequiredKeys = [
    'isScrollable',
    'useFlutterListView',
  ];

  @override
  Map toJson() {
    final Map<String, dynamic> json = _$GridViewNodeToJson(this);
    final Map<String, dynamic> legacy = {
      for (final key in _legacyRequiredKeys) key: json[key],
    };
    final Map<String, dynamic> result = {
      ..._$GridViewNodeOmitDefaults(this, json),
      ...legacy,
    };
    // fromJson reads a missing deniedTypes as ['GridView'], so write any
    // other value, even the empty list, to survive a save and reload.
    if (deniedTypes.length == 1 && deniedTypes.single == 'GridView') {
      result.remove('deniedTypes');
    } else {
      result['deniedTypes'] = [...deniedTypes];
    }
    return result;
  }
}

/// The properties of a [GridViewNode].
@JsonSerializable()
class GridViewProperties extends CustomProperties with FieldsHolder {
  /// The number of items to display in the list view. Can be null if the list
  /// is infinite.
  int? itemCount;

  /// The number of pixels by which to allow pre-rendering of items outside
  /// the visible area.
  ///
  /// Render with `scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent)`;
  /// the `cacheExtent` parameter of Flutter's scroll views is deprecated.
  @FlutterProp(
    'cacheExtent',
    type: 'number',
    group: 'Layout',
    control: 'number',
    field: 'properties.cacheExtent',
  )
  double? cacheExtent;

  /// Properties of the grid delegate that controls the layout of the grid.
  /// JSON without one gets two columns.
  @JsonKey(readValue: _readGridDelegate)
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
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'gridDelegate': ObjectFieldAccess<GridDelegateProperties>(
      'Grid',
      'Properties of the ListView',
      () => gridDelegate,
      (value) => gridDelegate = value,
    ),
  };

  @override
  Map<String, dynamic> toJson() =>
      _$GridViewPropertiesOmitDefaults(this, _$GridViewPropertiesToJson(this));

  /// Creates a [GridViewProperties] from a JSON object.
  factory GridViewProperties.fromJson(Map json) =>
      _$GridViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [itemCount, cacheExtent, gridDelegate];
}

/// The properties of a grid delegate that controls the layout of a
/// [GridViewNode].
sealed class GridDelegateProperties
    with Equatable, SerializableMixin, FieldsHolder {
  /// Represents the type of grid delegate.
  final GridDelegateType type;

  /// The number of logical pixels between each child along the main axis.
  double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child. This
  /// is ignored if [mainAxisExtent] is not null.
  double childAspectRatio;

  /// The main axis extent of each child in the grid. If this is null, then
  /// [childAspectRatio] controls the main axis extent of each child.
  double? mainAxisExtent;

  /// Whether each row (each column of a horizontal grid) takes the main axis
  /// extent of its largest item instead of a fixed one, like a [Row] of
  /// cells in an `IntrinsicHeight`: items keep their own main axis fit and
  /// the other cells of the row stretch to match. [mainAxisExtent] and
  /// [childAspectRatio] are then ignored.
  bool shrinkWrapRows;

  /// Creates a new [GridDelegateProperties] instance.
  GridDelegateProperties(
    this.type, {
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
    this.shrinkWrapRows = false,
  });

  /// Creates a copy of this [GridDelegateProperties] instance with the given
  /// value overrides.
  GridDelegateProperties copyWith({
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    double? childAspectRatio,
    double? mainAxisExtent,
    bool forceMainAxisExtent = false,
    bool? shrinkWrapRows,
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
  List<Object?> get props => [
    type,
    mainAxisSpacing,
    crossAxisSpacing,
    childAspectRatio,
    mainAxisExtent,
    shrinkWrapRows,
  ];

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'mainAxisSpacing': NumFieldAccess<double>(
      'Main Axis Spacing',
      'The number of logical pixels between each child along the main axis.',
      () => mainAxisSpacing,
      (value) => mainAxisSpacing = value,
      requiresLayout: true,
    ),
    'crossAxisSpacing': NumFieldAccess<double>(
      'Cross Axis Spacing',
      'The number of logical pixels between each child along the cross axis.',
      () => crossAxisSpacing,
      (value) => crossAxisSpacing = value,
      requiresLayout: true,
    ),
    'childAspectRatio': NumFieldAccess<double>(
      'Child Aspect Ratio',
      'The ratio of the cross-axis to the main-axis extent of each child.',
      () => childAspectRatio,
      (value) => childAspectRatio = value,
      requiresLayout: true,
    ),
    'mainAxisExtent': NumFieldAccess<double?>(
      'Main Axis Extent',
      'The main axis extent of each child in the grid.',
      () => mainAxisExtent,
      (value) => mainAxisExtent = value,
      requiresLayout: true,
    ),
    'shrinkWrapRows': BoolFieldAccess(
      'Shrink-wrap Rows',
      'Whether each row is as tall as its tallest item.',
      () => shrinkWrapRows,
      (value) => shrinkWrapRows = value,
      requiresLayout: true,
    ),
  };
}

/// Represents a delegate that makes grid layouts with a fixed number of tiles
/// in the cross axis.
@JsonSerializable()
class FixedCrossAxisCountGridDelegateProperties extends GridDelegateProperties {
  /// The number of children to fit in the cross axis for a grid view.
  int crossAxisCount;

  /// Creates a new [FixedCrossAxisCountGridDelegateProperties] instance.
  FixedCrossAxisCountGridDelegateProperties({
    required this.crossAxisCount,
    super.mainAxisSpacing = 0,
    super.crossAxisSpacing = 0,
    super.childAspectRatio = 1,
    super.mainAxisExtent,
    super.shrinkWrapRows = false,
  }) : super(GridDelegateType.fixedCrossAxisCount);

  @override
  Map toJson() => _$FixedCrossAxisCountGridDelegatePropertiesOmitDefaults(
    this,
    _$FixedCrossAxisCountGridDelegatePropertiesToJson(this),
  )..['type'] = type.name;

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
    bool? shrinkWrapRows,
  }) {
    return FixedCrossAxisCountGridDelegateProperties(
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      mainAxisSpacing: mainAxisSpacing ?? super.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? super.crossAxisSpacing,
      childAspectRatio: childAspectRatio ?? super.childAspectRatio,
      mainAxisExtent: forceMainAxisExtent
          ? mainAxisExtent
          : mainAxisExtent ?? super.mainAxisExtent,
      shrinkWrapRows: shrinkWrapRows ?? super.shrinkWrapRows,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'crossAxisCount': NumFieldAccess<int>(
      'Cross Axis Count',
      'The number of children to fit in the cross axis for a grid view.',
      () => crossAxisCount,
      (value) => crossAxisCount = value,
      requiresLayout: true,
    ),
  };

  @override
  List<Object?> get props => [...super.props, crossAxisCount];
}

/// Represents a delegate that makes grid layouts with tiles that each have a
/// maximum cross-axis extent.
@JsonSerializable()
class MaxCrossAxisExtentGridDelegateProperties extends GridDelegateProperties {
  /// The maximum extent of a child/item in the cross axis.
  double maxCrossAxisExtent;

  /// Creates a new [MaxCrossAxisExtentGridDelegateProperties] instance.
  MaxCrossAxisExtentGridDelegateProperties({
    required this.maxCrossAxisExtent,
    super.mainAxisSpacing = 0,
    super.crossAxisSpacing = 0,
    super.childAspectRatio = 1,
    super.mainAxisExtent,
    super.shrinkWrapRows = false,
  }) : super(GridDelegateType.maxCrossAxisExtent);

  @override
  Map toJson() => _$MaxCrossAxisExtentGridDelegatePropertiesOmitDefaults(
    this,
    _$MaxCrossAxisExtentGridDelegatePropertiesToJson(this),
  )..['type'] = type.name;

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
    bool? shrinkWrapRows,
  }) {
    return MaxCrossAxisExtentGridDelegateProperties(
      maxCrossAxisExtent: maxCrossAxisExtent ?? this.maxCrossAxisExtent,
      mainAxisSpacing: mainAxisSpacing ?? super.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? super.crossAxisSpacing,
      childAspectRatio: childAspectRatio ?? super.childAspectRatio,
      mainAxisExtent: forceMainAxisExtent
          ? mainAxisExtent
          : mainAxisExtent ?? super.mainAxisExtent,
      shrinkWrapRows: shrinkWrapRows ?? super.shrinkWrapRows,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'maxCrossAxisExtent': NumFieldAccess<double>(
      'Max Cross Axis Extent',
      'The maximum extent of a child/item in the cross axis.',
      () => maxCrossAxisExtent,
      (value) => maxCrossAxisExtent = value,
      requiresLayout: true,
    ),
  };

  @override
  List<Object?> get props => [...super.props, maxCrossAxisExtent];
}

Object? _readGridDelegate(Map json, String key) =>
    json[key] ?? const {'type': 'fixedCrossAxisCount', 'crossAxisCount': 2};
