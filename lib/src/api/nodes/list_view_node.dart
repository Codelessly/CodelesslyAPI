import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../../../codelessly_api.dart';

part 'list_view_node.g.dart';

/// A material design [ListView].
/// Refer to [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html)
/// in Flutter for more details.
@FlutterNode('ListView', family: 'widgets', nodeType: 'listView')
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

/// How a [ListViewNode] arranges its items.
enum ListLayout {
  /// Items follow one another along the scroll direction (a normal list).
  list,

  /// Items are layered on top of each other in the list's box, each placed
  /// by its item's `x` and `y` (bound with `BaseNode.variables`, evaluated
  /// for that item) relative to the list's padded box, or by its design
  /// offset when not bound. Nothing scrolls. Use it to draw data as a
  /// diagram, such as furniture on a floor plan or pins on a map.
  stack,
}

/// The properties of a [ListViewNode].
@JsonSerializable()
class ListViewProperties extends CustomProperties with FieldsHolder {
  /// The number of items to display in the list view. Can be null if the list
  /// is infinite.
  int? itemCount;

  /// The forced-size of each item in the list view in the scroll axis.
  @FlutterProp('itemExtent', type: 'number', group: 'Layout', control: 'number', field: 'properties.itemExtent')
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

  /// Legacy deck stacking: items overlap centered, first on top, and can
  /// move apart by motion bound to their index. Unlike [ListLayout.stack],
  /// this does not position items by bound x/y coordinates.
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

  /// Whether this list wraps its items instead of using either stack mode.
  bool get isWrapping => wrap && !stacked && layout == ListLayout.list;

  /// PR43 run-gap value, retained for existing serialized lists. New lists
  /// can use [wrapRunSpacing]; consumers of both wire formats should honor
  /// [runSpacing] when [wrapRunSpacing] is zero.
  double runSpacing;

  /// Position-based layout added by PR49, distinct from centered [stacked].
  ListLayout layout;

  /// Creates a new [ListViewProperties] instance.
  ListViewProperties({
    this.layout = ListLayout.list,
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
  }) : dividerProperties = dividerProperties ?? DividerProperties() {
    if (stacked && layout == ListLayout.stack) {
      throw ArgumentError('Conflicting centered and positional stack modes');
    }
  }

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
    ListLayout? layout,
  }) {
    return ListViewProperties(
      layout: layout ?? this.layout,
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
    'layout': EnumFieldAccess<ListLayout>(
      'Layout',
      'List: items follow one another. Stack: items are layered and placed by their bound x and y.',
      () => layout,
      (value) => layout = value,
      defaultValue: () => ListLayout.list,
      options: () => ListLayout.values,
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
  Map<String, dynamic> toJson() {
    if (stacked && layout == ListLayout.stack) {
      throw StateError('Conflicting centered and positional stack modes');
    }
    final json = _$ListViewPropertiesOmitDefaults(
      this,
      _$ListViewPropertiesToJson(this),
    );
    if (!stacked) json.remove('stacked');
    if (layout == ListLayout.list) json.remove('layout');
    return json;
  }

  /// Creates a [ListViewProperties] from a JSON object.
  factory ListViewProperties.fromJson(Map json) {
    // Old centered deck stacking and new x/y positional stacking have
    // different rendering semantics. Never convert one wire key to the other.
    if (json['stacked'] == true && json['layout'] == 'stack') {
      throw const FormatException(
        'Conflicting centered and positional stack modes',
      );
    }
    return _$ListViewPropertiesFromJson(json);
  }

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
    layout,
  ];
}
