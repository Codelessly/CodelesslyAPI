import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../../../codelessly_api.dart';

part 'page_view_node.g.dart';

/// Page View is a widget that lets the user create carousel like scrolling
/// experience.
/// A scrollable list that works page by page.
/// Each child of a page view is forced to be the same size as the viewport.
@JsonSerializable()
class PageViewNode extends SinglePlaceholderNode
    with ScrollableMixin, CustomPropertiesMixin, ClipMixin {
  @override
  final String type = 'pageView';

  /// The properties of the [PageViewNode].
  @override
  covariant PageViewProperties properties;

  @override
  bool get supportsPadding => false;

  @override
  bool get isScrollingEnforced => true;

  @override
  bool get canBeMarked => true;

  /// Creates a [PageViewNode].
  PageViewNode({
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
          deniedTypes: ['pageView'],
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
  }

  /// Creates a [ListViewNode] from a JSON object.
  factory PageViewNode.fromJson(Map json) => _$PageViewNodeFromJson(json);

  @override
  Map toJson() => _$PageViewNodeToJson(this);

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

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

/// The properties of a [PageViewNode].
@JsonSerializable()
class PageViewProperties extends CustomProperties {
  /// The number of items to display in the list view. Can be null if the list
  /// is infinite.
  int? itemCount;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  bool pageSnapping;

  /// Whether to add padding to both ends of the list.
  bool padEnds;

  /// Keep current page in memory and restore it when the page is recreated.
  bool keepPage;

  /// The page to show when first creating the Page View.
  int initialPage;

  /// The fraction of the viewport that each page should occupy.
  double viewportFraction;

  /// Creates a [PageViewProperties].
  PageViewProperties({
    this.itemCount,
    this.pageSnapping = true,
    this.padEnds = true,
    this.keepPage = true,
    this.initialPage = 0,
    this.viewportFraction = 1,
  });

  /// Creates a [PageViewProperties] from a JSON object.
  PageViewProperties copyWith({
    int? itemCount,
    bool? pageSnapping,
    bool? padEnds,
    bool? keepPage,
    int? initialPage,
    double? viewportFraction,
  }) {
    return PageViewProperties(
      itemCount: itemCount ?? this.itemCount,
      pageSnapping: pageSnapping ?? this.pageSnapping,
      padEnds: padEnds ?? this.padEnds,
      keepPage: keepPage ?? this.keepPage,
      initialPage: initialPage ?? this.initialPage,
      viewportFraction: viewportFraction ?? this.viewportFraction,
    );
  }

  @override
  List<Object?> get props => [
        itemCount,
        pageSnapping,
        padEnds,
        keepPage,
        initialPage,
        viewportFraction,
      ];

  @override
  Map<String, dynamic> toJson() => _$PageViewPropertiesToJson(this);

  /// Creates a [PageViewProperties] from a JSON object.
  factory PageViewProperties.fromJson(Map json) =>
      _$PageViewPropertiesFromJson(json);
}
