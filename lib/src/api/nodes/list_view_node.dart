import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

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

    // [CloudDatabaseMixin] properties.
    bool useCloudDatabase = false,
    String? collectionPath,
    int? limit = 20,
    List<WhereQueryFilter>? whereFilters,
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
            'listView',
          ],
          ephemeral: false,
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
      useFlutterListView: true,
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
  factory ListViewNode.fromJson(Map json) => _$ListViewNodeFromJson(json);

  @override
  Map toJson() => _$ListViewNodeToJson(this);

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
  space;
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

  /// Creates a new [ListViewProperties] instance.
  ListViewProperties({
    this.itemCount,
    this.itemExtent,
    this.cacheExtent,
    this.separator = ListItemSeparator.space,
    this.separatorSpacing = 0,
    this.hasSeparator = false,
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
    DividerProperties? dividerProperties,
  }) {
    return ListViewProperties(
      itemCount: itemCount ?? this.itemCount,
      itemExtent: itemExtent ?? this.itemExtent,
      cacheExtent: cacheExtent ?? this.cacheExtent,
      separator: separator ?? this.separator,
      separatorSpacing: separatorSpacing ?? this.separatorSpacing,
      hasSeparator: hasSeparator ?? this.hasSeparator,
      dividerProperties: dividerProperties ?? this.dividerProperties,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
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
      };

  @override
  Map<String, dynamic> toJson() => _$ListViewPropertiesToJson(this);

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
        dividerProperties,
      ];
}
