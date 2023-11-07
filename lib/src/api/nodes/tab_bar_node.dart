// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'tab_bar_node.g.dart';

/// Represents tabs in UI.
@JsonSerializable()
class TabBarNode extends SceneNode
    with CustomPropertiesMixin, ScrollableMixin, ParentReactionMixin {
  @override
  final String type = 'tabBar';

  /// The properties of the TabBar].
  TabBarProperties properties;

  /// The index of the initially selected tab.
  int initialIndex = 0;

  @override
  bool get supportsPadding => true;

  /// Creates a [TabBarNode] with the given data.
  TabBarNode({
    bool? value,
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
    super.variables,
    required this.properties,
    bool isScrollable = false,
    ScrollPhysicsC physics = ScrollPhysicsC.platformDependent,
    this.initialIndex = 0,
    bool shouldAlwaysScroll = true,
  }) {
    setScrollableMixin(
      isScrollable: isScrollable,
      scrollDirection: AxisC.horizontal,
      reverse: false,
      physics: physics,
      primary: false,
      shrinkWrap: false,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehaviorC.manual,
      useFlutterListView: false,
      shouldAlwaysScroll: shouldAlwaysScroll,
    );
  }

  @override
  List<TriggerType> get triggerTypes => [TriggerType.click];

  @override
  List<ReactionMixin> get reactiveChildren => properties.tabs;

  /// Creates a [TabBarNode] from a JSON object.
  factory TabBarNode.fromJson(Map json) => _$TabBarNodeFromJson(json);

  @override
  Map toJson() => _$TabBarNodeToJson(this);
}

/// Represents the size of the tab indicator.
enum TabBarIndicatorSizeEnum {
  /// The tab indicator's bounds are as wide as the space occupied by the tab
  /// in the tab bar: from the right edge of the previous tab to the left edge
  /// of the next tab.
  tab,

  /// The tab's bounds are only as wide as the (centered) tab widget itself.
  ///
  /// This value is used to align the tab's label, typically a [Tab]
  /// widget's text or icon, with the selected tab indicator.
  label,
}

/// Represents a tab item content: text, icon, or both.
enum TabBarContentType {
  /// Show only the text.
  label('Label'),

  /// Show only the icon.
  icon('Icon'),

  /// Show both the text and the icon.
  labelAndIcon('Label & Icon');

  const TabBarContentType(this.displayLabel);

  /// The display label of the tab item content.
  final String displayLabel;

  /// Whether to show the icon.
  bool get showIcon =>
      this == TabBarContentType.icon || this == TabBarContentType.labelAndIcon;

  /// Whether to show the text.
  bool get showLabel =>
      this == TabBarContentType.label || this == TabBarContentType.labelAndIcon;

  /// Whether to show both the text and the icon.
  bool get showBoth => this == TabBarContentType.labelAndIcon;
}

/// Represents the style of the tab indicator.
enum TabIndicatorStyle {
  /// no indicator.
  none,

  /// Default style.
  underline,

  /// A rectangle that stretches from one tab to another.
  filled,

  /// A border around the tab.
  border;
}

/// The properties of a [TabBarNode].
@JsonSerializable()
class TabBarProperties with SerializableMixin, EquatableMixin {
  /// The tabs of the [TabBarNode].
  List<TabItem> tabs;

  /// The color of the tab indicator.
  ColorRGBA indicatorColor;

  /// The thickness of the tab indicator.
  double indicatorWeight;

  /// The size of the tab indicator.
  TabBarIndicatorSizeEnum indicatorSize;

  /// The color of the tab label.
  ColorRGBA? labelColor;

  /// The style of the tab label.
  TextProp labelStyle;

  /// The color of the unselected tab label.
  ColorRGBA? unselectedLabelColor;

  /// The style of the unselected tab label.
  TextProp unselectedLabelStyle;

  /// The color of the tab overlay.
  ColorRGBA? overlayColor;

  /// The padding of the tab indicator.
  EdgeInsetsModel indicatorPadding;

  /// The padding of the tab label.
  EdgeInsetsModel labelPadding;

  /// The color of the tab divider.
  ColorRGBA? dividerColor;

  /// Determines the direction of label and icon in a tab.
  AxisC tabItemDirection;

  /// Spacing between icon and text of a tab.
  double gap;

  /// Determines what to show for a tab: text, icon or both.
  TabBarContentType contentType;

  /// Whether to show the divider.
  bool showDivider;

  /// The style of the tab indicator.
  TabIndicatorStyle indicatorStyle;

  /// The shape of the tab indicator.
  CShapeBorder indicatorShape;

  /// The corner radius of the tab indicator.
  CornerRadius indicatorCornerRadius;

  /// Creates a new [TabBarProperties] instance.
  TabBarProperties({
    List<TabItem> tabs = const [],
    this.indicatorColor = ColorRGBA.black,
    this.indicatorWeight = 2.0,
    this.indicatorSize = TabBarIndicatorSizeEnum.tab,
    this.labelColor = ColorRGBA.black,
    this.unselectedLabelColor = ColorRGBA.black,
    TextProp? labelStyle,
    TextProp? unselectedLabelStyle,
    this.overlayColor = ColorRGBA.grey10,
    this.indicatorPadding = EdgeInsetsModel.zero,
    this.dividerColor = ColorRGBA.black,
    this.labelPadding = EdgeInsetsModel.zero,
    this.tabItemDirection = AxisC.horizontal,
    this.gap = 10,
    this.contentType = TabBarContentType.labelAndIcon,
    this.showDivider = true,
    this.indicatorStyle = TabIndicatorStyle.underline,
    this.indicatorShape = CShapeBorder.roundedRectangle,
    this.indicatorCornerRadius = CornerRadius.zero,
  })  : tabs = [...tabs],
        labelStyle = labelStyle ?? TextProp(),
        unselectedLabelStyle = unselectedLabelStyle ?? TextProp();

  /// Creates a copy of this [LTabBarProperties] instance with the given value
  /// overrides.
  TabBarProperties copyWith({
    List<TabItem>? tabs,
    ColorRGBA? indicatorColor,
    double? indicatorWeight,
    TabBarIndicatorSizeEnum? indicatorSize,
    ColorRGBA? labelColor,
    TextProp? labelStyle,
    ColorRGBA? unselectedLabelColor,
    TextProp? unselectedLabelStyle,
    ColorRGBA? overlayColor,
    EdgeInsetsModel? indicatorPadding,
    EdgeInsetsModel? labelPadding,
    ColorRGBA? dividerColor,
    AxisC? tabItemDirection,
    double? gap,
    TabBarContentType? contentType,
    bool? showDivider,
    TabIndicatorStyle? indicatorStyle,
    CShapeBorder? indicatorShape,
    CornerRadius? indicatorCornerRadius,
  }) {
    return TabBarProperties(
      tabs: tabs ?? this.tabs,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorWeight: indicatorWeight ?? this.indicatorWeight,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      labelColor: labelColor ?? this.labelColor,
      labelStyle: labelStyle ?? this.labelStyle,
      unselectedLabelColor: unselectedLabelColor ?? this.unselectedLabelColor,
      unselectedLabelStyle: unselectedLabelStyle ?? this.unselectedLabelStyle,
      overlayColor: overlayColor ?? this.overlayColor,
      indicatorPadding: indicatorPadding ?? this.indicatorPadding,
      labelPadding: labelPadding ?? this.labelPadding,
      dividerColor: dividerColor ?? this.dividerColor,
      tabItemDirection: tabItemDirection ?? this.tabItemDirection,
      gap: gap ?? this.gap,
      contentType: contentType ?? this.contentType,
      showDivider: showDivider ?? this.showDivider,
      indicatorStyle: indicatorStyle ?? this.indicatorStyle,
      indicatorShape: indicatorShape ?? this.indicatorShape,
      indicatorCornerRadius:
          indicatorCornerRadius ?? this.indicatorCornerRadius,
    );
  }

  @override
  Map toJson() => _$TabBarPropertiesToJson(this);

  /// Creates a [TabBarProperties] from a JSON object.
  factory TabBarProperties.fromJson(Map json) =>
      _$TabBarPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        tabs,
        indicatorColor,
        indicatorWeight,
        indicatorSize,
        labelColor,
        labelStyle,
        unselectedLabelColor,
        unselectedLabelStyle,
        overlayColor,
        indicatorPadding,
        labelPadding,
        dividerColor,
        tabItemDirection,
        gap,
        contentType,
        showDivider,
        indicatorStyle,
      ];
}

/// Represents a tab in a [TabBarNode].
@JsonSerializable()
class TabItem with EquatableMixin, SerializableMixin, ReactionMixin {
  /// ID of the tab.
  final String id;

  /// Label of the tab.
  String label;

  /// Icon to display in the button.
  MultiSourceIconModel icon;

  /// Creates a new [TabItem] instance.
  TabItem({
    required this.id,
    required this.label,
    TextProp? labelStyle,
    List<Reaction>? reactions,
    this.icon = const MultiSourceIconModel(size: 20, color: null),
  }) {
    setReactionMixin(reactions ?? []);
  }

  /// Creates a copy of this [TabItem] instance with the given values.
  TabItem copyWith({
    String? id,
    String? label,
    TextAlignHorizontalEnum? labelAlignment,
    TextProp? labelStyle,
    IconPlacementEnum? placement,
    double? gap,
    MultiSourceIconModel? icon,
    List<Reaction>? reactions,
  }) {
    return TabItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      reactions: reactions ?? this.reactions,
    );
  }

  /// Creates a [TabItem] from a JSON object.
  factory TabItem.fromJson(Map json) => _$TabItemFromJson(json);

  @override
  Map toJson() => _$TabItemToJson(this);

  @override
  List<Object?> get props => [id, label, icon];
}
