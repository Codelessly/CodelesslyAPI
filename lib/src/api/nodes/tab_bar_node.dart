// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'tab_bar_node.g.dart';

/// Represents tabs in UI.
@JsonSerializable()
class TabBarNode extends SceneNode with CustomPropertiesMixin, ScrollableMixin {
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
    ScrollPhysicsC physics = ScrollPhysicsC.alwaysScrollableScrollPhysics,
    this.initialIndex = 0,
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
    );
  }

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

/// The properties of a [TabBarNode].
@JsonSerializable()
class TabBarProperties with SerializableMixin, EquatableMixin {
  /// The tabs of the [TabBarNode].
  List<TabItem> tabs;

  /// The color of the tab indicator.
  ColorRGBA? indicatorColor;

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
      ];
}

/// Represents a tab in a [TabBarNode].
@JsonSerializable()
class TabItem with EquatableMixin, SerializableMixin {
  /// ID of the tab.
  final String id;

  /// Label of the tab.
  String label;

  /// Alignment of the label.
  TextAlignHorizontalEnum labelAlignment;

  /// Style of the label.
  TextProp labelStyle;

  /// Describes the position of the icon.
  IconPlacementEnum placement;

  /// Space between the icon and the label.
  double gap;

  /// Icon to display in the button.
  MultiSourceIconModel icon;

  /// Creates a new [TabItem] instance.
  TabItem({
    required this.id,
    required this.label,
    this.labelAlignment = TextAlignHorizontalEnum.center,
    TextProp? labelStyle,
    this.placement = IconPlacementEnum.start,
    this.gap = 8,
    this.icon = const MultiSourceIconModel(size: 20, color: null),
  }) : labelStyle =
            labelStyle ?? TextProp.general(fills: List.empty(growable: true));

  /// Creates a copy of this [TabItem] instance with the given values.
  TabItem copyWith({
    String? id,
    String? label,
    TextAlignHorizontalEnum? labelAlignment,
    TextProp? labelStyle,
    IconPlacementEnum? placement,
    double? gap,
    MultiSourceIconModel? icon,
  }) {
    return TabItem(
      id: id ?? this.id,
      label: label ?? this.label,
      labelAlignment: labelAlignment ?? this.labelAlignment,
      labelStyle: labelStyle ?? this.labelStyle,
      placement: placement ?? this.placement,
      gap: gap ?? this.gap,
      icon: icon ?? this.icon,
    );
  }

  /// Creates a [TabItem] from a JSON object.
  factory TabItem.fromJson(Map json) => _$TabItemFromJson(json);

  @override
  Map toJson() => _$TabItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        label,
        labelAlignment,
        labelStyle,
        placement,
        gap,
        icon,
      ];
}
