import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'list_view_node.g.dart';

/// A material design [ListView].
/// Refer to [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html)
/// in Flutter for more details.
@JsonSerializable()
class ListViewNode extends SinglePlaceholderNode
    with
        ScrollableMixin,
        CustomPropertiesMixin,
        ClipMixin,
        QueryableMixin,
        FieldsHolder {
  @override
  final String type = 'listView';

  @override
  final bool supportsPadding = true;

  @override
  bool get isScrollingEnforced => true;

  @override
  bool get canBeMarked => true;

  /// The properties of the [ListView].
  @override
  covariant ListViewProperties properties;

  /// A text variable this ListView writes the status of its cloud query into,
  /// for loading, empty and error states: [kQueryStatusLoading],
  /// [kQueryStatusEmpty], [kQueryStatusError] or [kQueryStatusLoaded].
  VariableData? statusVariable;

  @override
  BoxConstraintsModel? relegatedConstraintsToChildren(BaseNode child) {
    if (scrollDirection == AxisC.vertical) {
      return BoxConstraintsModel(maxHeight: properties.itemExtent);
    } else {
      return BoxConstraintsModel(maxWidth: properties.itemExtent);
    }
  }

  /// Creates a [ListViewNode].
  ListViewNode({
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

    // [CloudDatabaseMixin] properties.
    bool useCloudDatabase = false,
    String? collectionPath,
    int? limit = 20,
    List<WhereQueryFilter>? whereFilters,
    List<OrderByQueryFilter>? orderByFilters,

    // [ScrollableMixin] properties.
    bool isScrollable = true,
    bool useFlutterListView = true,
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
         deniedTypes: ['listView'],
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

  /// Creates a [ListViewNode] from a JSON object.
  ///
  /// A list always scrolls with a Flutter list view, so JSON written by hand
  /// can leave those flags out.
  factory ListViewNode.fromJson(Map json) => _$ListViewNodeFromJson({
    'isScrollable': true,
    'useFlutterListView': true,
    'allowedTypes': <String>[],
    'deniedTypes': ['listView'],
    ...json,
  });

  @override
  Map toJson() => _$ListViewNodeOmitDefaults(this, _$ListViewNodeToJson(this));

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

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<ListViewProperties>(
      'Properties',
      'Properties of the ListView',
      () => properties,
      (value) => properties = value,
    ),
  };
}

/// Defines the type of separator to use between list view items.
enum ListItemSeparator {
  /// A customizable divider. See [DividerNode] for more details.
  divider,

  /// A simple spacing between items.
  space,
}

/// The properties of a [ListViewNode].
@JsonSerializable()
class ListViewProperties extends CustomProperties with FieldsHolder {
  /// The number of items to display in the list view. Can be null if the list
  /// is infinite.
  int? itemCount;

  /// The forced-size of each item in the list view in the scroll axis.
  double? itemExtent;

  /// The number of pixels by which to allow pre-rendering of items outside
  /// the visible area.
  ///
  /// Render with `scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent)`;
  /// the `cacheExtent` parameter of Flutter's scroll views is deprecated.
  double? cacheExtent;

  /// The amount of pixels the spacing separator should have, if enabled.
  double separatorSpacing;

  /// The type of separator to use between list view items.
  ListItemSeparator separator;

  /// Whether to use a separator between list view items.
  bool hasSeparator;

  /// The properties of the divider to use as a separator between list view
  /// items, if enabled.
  DividerProperties dividerProperties;

  /// Whether the items are stacked on top of each other, like a deck of
  /// cards or records in a crate, instead of laid out one after another.
  /// The first item is drawn on top. A stacked list doesn't scroll; items
  /// are placed at the top center of the list and are usually moved apart
  /// with motion bound to their index (see [MotionModel]).
  bool stacked;

  /// Whether the items flow onto further lines (runs) when they don't fit,
  /// like Flutter's [Wrap], instead of scrolling in one line. The scroll
  /// direction is the wrap direction: a horizontal list fills a line from
  /// left to right, then starts a new line below; a vertical list fills a
  /// column top to bottom, then starts a new column to the right. Items keep
  /// their own size (they are not stretched to the list's cross extent).
  /// Separators are not drawn; use [wrapSpacing] and [wrapRunSpacing].
  /// Ignored when [stacked] is true.
  ///
  /// A wrapping list shows every item, so it needs an item count or a data
  /// source. It scrolls along the cross axis when its runs don't fit its box;
  /// give it a shrink-wrap fit on the cross axis to grow with its runs.
  bool wrap;

  /// The gap between two items of the same line when [wrap] is true.
  double wrapSpacing;

  /// The gap between two lines (runs) when [wrap] is true.
  double wrapRunSpacing;

  /// How the items of a line are placed along the wrap direction when [wrap]
  /// is true. Maps to Flutter's [WrapAlignment] by name.
  MainAxisAlignmentC wrapAlignment;

  /// Whether this list wraps its items: [wrap] is on and [stacked] is off.
  bool get isWrapping => wrap && !stacked;

  /// PR43 run-gap value, retained for existing serialized lists. New lists
  /// can use [wrapRunSpacing]; consumers of both wire formats should honor
  /// [runSpacing] when [wrapRunSpacing] is zero.
  double runSpacing;

  /// Creates a new [ListViewProperties] instance.
  ListViewProperties({
    this.itemCount,
    this.itemExtent,
    this.cacheExtent,
    this.separator = ListItemSeparator.space,
    this.separatorSpacing = 0,
    this.hasSeparator = false,
    this.stacked = false,
    this.wrap = false,
    this.wrapSpacing = 0,
    this.wrapRunSpacing = 0,
    this.wrapAlignment = MainAxisAlignmentC.start,
    this.runSpacing = 0,
    DividerProperties? dividerProperties,
  }) : dividerProperties = dividerProperties ?? DividerProperties();

  /// Creates a copy of this [ListViewProperties] instance with the given value
  /// overrides.
  ListViewProperties copyWith({
    String? bodyId,
    int? itemCount,
    ScrollPhysicsC? physics,
    AxisC? scrollDirection,
    double? itemExtent,
    double? cacheExtent,
    bool? reverse,
    ListItemSeparator? separator,
    double? separatorSpacing,
    double? dividerThickness,
    ColorRGBA? dividerColor,
    double? dividerSpacing,
    bool? hasSeparator,
    bool? stacked,
    bool? wrap,
    double? wrapSpacing,
    double? wrapRunSpacing,
    MainAxisAlignmentC? wrapAlignment,
    DividerProperties? dividerProperties,
    double? runSpacing,
  }) {
    return ListViewProperties(
      stacked: stacked ?? this.stacked,
      wrap: wrap ?? this.wrap,
      wrapSpacing: wrapSpacing ?? this.wrapSpacing,
      wrapRunSpacing: wrapRunSpacing ?? this.wrapRunSpacing,
      wrapAlignment: wrapAlignment ?? this.wrapAlignment,
      itemCount: itemCount ?? this.itemCount,
      itemExtent: itemExtent ?? this.itemExtent,
      cacheExtent: cacheExtent ?? this.cacheExtent,
      separator: separator ?? this.separator,
      separatorSpacing: separatorSpacing ?? this.separatorSpacing,
      hasSeparator: hasSeparator ?? this.hasSeparator,
      dividerProperties: dividerProperties ?? this.dividerProperties,
      runSpacing: runSpacing ?? this.runSpacing,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'stacked': BoolFieldAccess(
      'Stacked',
      'Draw the items on top of each other, the first on top, instead of '
          'one after another.',
      () => stacked,
      (value) => stacked = value,
      requiresLayout: true,
    ),
    'wrap': BoolFieldAccess(
      'Wrap',
      'Flow the items onto further lines when they do not fit, instead of '
          'scrolling in one line. Ignored when Stacked is on.',
      () => wrap,
      (value) => wrap = value,
      requiresLayout: true,
    ),
    'wrapSpacing': NumFieldAccess<double>(
      'Wrap Spacing',
      'The gap between two items of the same line of a wrapping list.',
      () => wrapSpacing,
      (value) => wrapSpacing = value,
      requiresLayout: true,
    ),
    'wrapRunSpacing': NumFieldAccess<double>(
      'Wrap Run Spacing',
      'The gap between two lines of a wrapping list.',
      () => wrapRunSpacing,
      (value) => wrapRunSpacing = value,
      requiresLayout: true,
    ),
    'wrapAlignment': EnumFieldAccess<MainAxisAlignmentC>(
      'Wrap Alignment',
      'How the items of a line of a wrapping list are placed along it.',
      () => wrapAlignment,
      (value) => wrapAlignment = value,
      defaultValue: () => MainAxisAlignmentC.start,
      options: () => MainAxisAlignmentC.values,
      requiresLayout: true,
    ),
    'hasSeparator': BoolFieldAccess(
      'Has Separator',
      'Whether to use a separator between list view items.',
      () => hasSeparator,
      (value) => hasSeparator = value,
      requiresLayout: true,
    ),
    'separatorSpacing': NumFieldAccess<double>(
      'Separator Spacing',
      'The amount of pixels the spacing separator should have, if enabled.',
      () => separatorSpacing,
      (value) => separatorSpacing = value,
      requiresLayout: true,
    ),
    'separator': EnumFieldAccess<ListItemSeparator>(
      'Separator',
      'The type of separator to use between list view items.',
      () => separator,
      (value) => separator = value,
      defaultValue: () => ListItemSeparator.space,
      options: () => ListItemSeparator.values,
      requiresLayout: true,
    ),
    'dividerProperties': ObjectFieldAccess<DividerProperties>(
      'Divider Properties',
      'The properties of the divider to use as a separator between list view items, if enabled.',
      () => dividerProperties,
      (value) => dividerProperties = value,
      requiresLayout: true,
    ),
    'runSpacing': NumFieldAccess<double>(
      'Run Gap',
      'The gap between runs when the items wrap.',
      () => runSpacing,
      (value) => runSpacing = value,
      defaultValue: () => 0,
      requiresLayout: true,
    ),
  };

  @override
  Map<String, dynamic> toJson() =>
      _$ListViewPropertiesOmitDefaults(this, _$ListViewPropertiesToJson(this));

  /// Creates a [ListViewProperties] from a JSON object.
  factory ListViewProperties.fromJson(Map json) =>
      _$ListViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
    itemCount,
    itemExtent,
    cacheExtent,
    separator,
    separatorSpacing,
    hasSeparator,
    stacked,
    wrap,
    wrapSpacing,
    wrapRunSpacing,
    wrapAlignment,
    dividerProperties,
    runSpacing,
  ];
}
