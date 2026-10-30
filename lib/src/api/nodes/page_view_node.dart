import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../../../codelessly_api.dart';

part 'page_view_node.g.dart';

/// Page View is a widget that lets the user create carousel like scrolling
/// experience.
/// A scrollable list that works page by page.
/// Each child of a page view is forced to be the same size as the viewport.
@FlutterNode('PageView', family: 'widgets', nodeType: 'pageView')
@JsonSerializable()
class PageViewNode extends SinglePlaceholderNode
    with ScrollableMixin, CustomPropertiesMixin, ClipMixin, FieldsHolder {
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
         deniedTypes: ['pageView'],
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
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<PageViewProperties>(
      'Properties',
      'Properties of the Page View',
      () => properties,
      (value) => properties = value,
    ),
  };

  /// Creates a [ListViewNode] from a JSON object.
  factory PageViewNode.fromJson(Map json) => _$PageViewNodeFromJson({
    // Node JSON may leave out scrolling fields; read the constructor's.
    'isScrollable': true,
    'useFlutterListView': true,
    'allowedTypes': <String>[],
    'deniedTypes': ['pageView'],
    ...json,
  });

  @override
  Map toJson() => _$PageViewNodeOmitDefaults(this, _$PageViewNodeToJson(this));

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

/// How long a page view slides to a page set through its index, by
/// default, in milliseconds.
const int kDefaultPageAnimationDurationMs = 400;

/// The properties of a [PageViewNode].
@JsonSerializable()
class PageViewProperties extends CustomProperties with FieldsHolder {
  /// The number of items to display in the list view. Can be null if the list
  /// is infinite.
  int? itemCount;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  @FlutterProp('pageSnapping', type: 'boolean', group: 'Interaction', control: 'switch', field: 'properties.pageSnapping')
  bool pageSnapping;

  /// Whether to add padding to both ends of the list.
  @FlutterProp('padEnds', type: 'boolean', group: 'Layout', control: 'switch', field: 'properties.padEnds')
  bool padEnds;

  /// Keep current page in memory and restore it when the page is recreated.
  bool keepPage;

  /// The page to show when first creating the Page View.
  int initialPage;

  /// The fraction of the viewport that each page should occupy.
  double viewportFraction;

  /// Whether to lay out the pages next to the visible one, so accessibility
  /// focus can move to them. Mirrors `PageView.allowImplicitScrolling`.
  @FlutterProp('allowImplicitScrolling', type: 'boolean', group: 'Interaction', control: 'switch', field: 'properties.allowImplicitScrolling')
  bool allowImplicitScrolling;

  /// How long the page view takes to slide to a page when its bound
  /// `indexValue` changes (a dot or arrow of a carousel setting it), in
  /// milliseconds. 0 jumps straight there.
  int animationDurationMs;

  /// The easing of the slide to a page set through `indexValue`.
  MotionCurve animationCurve;

  /// Creates a [PageViewProperties].
  PageViewProperties({
    this.itemCount,
    this.pageSnapping = true,
    this.padEnds = true,
    this.keepPage = true,
    this.initialPage = 0,
    this.viewportFraction = 1,
    this.allowImplicitScrolling = false,
    this.animationDurationMs = kDefaultPageAnimationDurationMs,
    this.animationCurve = MotionCurve.easeInOut,
  });

  /// Creates a [PageViewProperties] from a JSON object.
  PageViewProperties copyWith({
    int? itemCount,
    bool? pageSnapping,
    bool? padEnds,
    bool? keepPage,
    int? initialPage,
    double? viewportFraction,
    bool? allowImplicitScrolling,
    int? animationDurationMs,
    MotionCurve? animationCurve,
  }) {
    return PageViewProperties(
      itemCount: itemCount ?? this.itemCount,
      pageSnapping: pageSnapping ?? this.pageSnapping,
      padEnds: padEnds ?? this.padEnds,
      keepPage: keepPage ?? this.keepPage,
      initialPage: initialPage ?? this.initialPage,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      allowImplicitScrolling:
          allowImplicitScrolling ?? this.allowImplicitScrolling,
      animationDurationMs: animationDurationMs ?? this.animationDurationMs,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'pageSnapping': BoolFieldAccess(
      'Page Snapping',
      'Set to false to disable page snapping, useful for custom scroll behavior.',
      () => pageSnapping,
      (value) => pageSnapping = value,
    ),
    'padEnds': BoolFieldAccess(
      'Pad Ends',
      'Whether to add padding to both ends of the list.',
      () => padEnds,
      (value) => padEnds = value,
      requiresLayout: true,
    ),
    'keepPage': BoolFieldAccess(
      'Keep Page',
      'Keep current page in memory and restore it when the page is recreated.',
      () => keepPage,
      (value) => keepPage = value,
    ),
    'viewportFraction': NumFieldAccess<double>(
      'Viewport Fraction',
      'The fraction of the viewport that each page should occupy.',
      () => viewportFraction,
      (value) => viewportFraction = value,
      requiresLayout: true,
    ),
    'allowImplicitScrolling': BoolFieldAccess(
      'Allow Implicit Scrolling',
      'Whether to lay out the pages next to the visible one.',
      () => allowImplicitScrolling,
      (value) => allowImplicitScrolling = value,
    ),
    'animationDurationMs': NumFieldAccess<int>(
      'Animation Duration',
      'How long the page view slides to a page set through its index, in '
          'milliseconds. 0 jumps.',
      () => animationDurationMs,
      (value) => animationDurationMs = value,
    ),
  };

  @override
  List<Object?> get props => [
    itemCount,
    pageSnapping,
    padEnds,
    keepPage,
    initialPage,
    viewportFraction,
    allowImplicitScrolling,
    animationDurationMs,
    animationCurve,
  ];

  @override
  Map<String, dynamic> toJson() =>
      _$PageViewPropertiesOmitDefaults(this, _$PageViewPropertiesToJson(this));

  /// Creates a [PageViewProperties] from a JSON object.
  factory PageViewProperties.fromJson(Map json) =>
      _$PageViewPropertiesFromJson(json);
}
