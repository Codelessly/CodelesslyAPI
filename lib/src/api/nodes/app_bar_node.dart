import 'dart:math';

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../extensions.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'app_bar_node.g.dart';

/// Default height of an app bar.
const double kAppBarDefaultHeight = 56;

/// A Material Design app bar.
/// Refer to [AppBar](https://api.flutter.dev/flutter/material/AppBar-class.html)
/// in Flutter for more details.
@JsonSerializable()
class AppBarNode extends SceneNode
    with CustomPropertiesMixin, ParentReactionMixin {
  @override
  final String type = 'appBar';

  /// Holds configurable properties of the app bar.
  AppBarProperties properties;

  @override
  bool get supportsMargin => false;

  @override
  bool get supportsRotation => false;

  @override
  bool get supportsConstraints => false;

  @override
  bool get supportsVisibility => false;

  /// Creates a new [AppBarNode] instance.
  AppBarNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.rotationDegrees,
    super.visible,
    super.alignment,
    super.padding,
    super.margin,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    super.variables,
    super.multipleVariables,
    required this.properties,
  });

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'title', value: properties.title),
  ];

  @override
  List<ReactionMixin> get reactiveChildren {
    final List<ReactionMixin> items = [...properties.actions];
    if (properties.leading.icon.show &&
        properties.automaticallyImplyLeading == false) {
      items.add(properties.leading);
    }
    return items;
  }

  /// Creates a new [AppBarNode] instance from a JSON data.
  factory AppBarNode.fromJson(Map json) => _$AppBarNodeFromJson(json);

  @override
  Map toJson() => _$AppBarNodeToJson(this);

  @override
  BoxConstraintsModel internalConstraints({
    required SizeFit horizontalFit,
    required SizeFit verticalFit,
  }) {
    double minHeight;
    if (properties.automaticallyImplyLeading) {
      minHeight = 40;
    } else if (properties.leading.icon.show) {
      // Has a leading icon.
      minHeight = max(properties.leading.icon.size ?? 24,
              properties.titleStyle.fontSize) +
          16;
    } else {
      // Does not have a leading icon.
      minHeight = properties.titleStyle.fontSize + 16;
    }
    minHeight = min(56, minHeight);
    return super
        .internalConstraints(
            horizontalFit: horizontalFit, verticalFit: verticalFit)
        .union(
          BoxConstraintsModel(minHeight: minHeight),
        );
  }

  @override
  void updateVariableName({required String oldName, required String newName}) {
    super.updateVariableName(oldName: oldName, newName: newName);
    if (properties.title.isEmpty) return;
    properties.title = properties.title.replaceVariableName(oldName, newName);
  }
}

/// Properties of an app bar.
@JsonSerializable()
class AppBarProperties with SerializableMixin, EquatableMixin {
  /// Whether to align the title text in center.
  late bool centerTitle;

  /// Elevation of the app bar.
  late double elevation;

  /// Leading icon of the app bar.
  late IconAppBarActionItem leading;

  /// Whether to automatically show/hide leading icon based on the route.
  late bool automaticallyImplyLeading;

  /// Style of the title text.
  late TextProp titleStyle;

  /// Background color of the app bar.
  late ColorRGBA backgroundColor;

  /// Title text of the app bar.
  late String title;

  /// Spacing between the leading icon (if given) and the title text.
  late double titleSpacing;

  /// Actions of the app bar.
  late List<IconAppBarActionItem> actions;

  /// Elevation shadow color of the app bar.
  late ColorRGBA shadowColor;

  /// Creates a new [AppBarProperties] instance.
  AppBarProperties({
    required this.title,
    required this.backgroundColor,
    required this.leading,
    this.actions = const [],
    this.centerTitle = false,
    TextProp? titleStyle,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
    this.titleSpacing = 16,
    this.shadowColor = ColorRGBA.black,
  }) : titleStyle = titleStyle ?? TextProp(fontSize: 20);

  /// Duplicate this [AppBarProperties] instance with the given data overrides.
  AppBarProperties copyWith({
    List<IconAppBarActionItem>? actions,
    bool? centerTitle,
    double? elevation,
    IconAppBarActionItem? leading,
    bool? automaticallyImplyLeading,
    TextProp? titleStyle,
    ColorRGBA? backgroundColor,
    String? title,
    double? titleSpacing,
    ColorRGBA? shadowColor,
  }) {
    return AppBarProperties(
      actions: actions ?? this.actions,
      centerTitle: centerTitle ?? this.centerTitle,
      elevation: elevation ?? this.elevation,
      leading: leading ?? this.leading,
      automaticallyImplyLeading:
          automaticallyImplyLeading ?? this.automaticallyImplyLeading,
      titleStyle: titleStyle ?? this.titleStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      title: title ?? this.title,
      titleSpacing: titleSpacing ?? this.titleSpacing,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  List<Object?> get props => [
        actions,
        centerTitle,
        elevation,
        leading,
        automaticallyImplyLeading,
        titleStyle,
        backgroundColor,
        title,
        titleSpacing,
        shadowColor,
      ];

  /// Creates a new [AppBarProperties] instance from a JSON data.
  factory AppBarProperties.fromJson(Map json) =>
      _$AppBarPropertiesFromJson(json);

  @override
  Map toJson() => _$AppBarPropertiesToJson(this);
}

/// An app bar action item.
abstract class AppBarActionItem
    with ReactionMixin, SerializableMixin, EquatableMixin {
  /// ID of the action item.
  final String id;

  /// Type of the action item.
  late final String type;

  /// Creates a new [AppBarActionItem] instance.
  AppBarActionItem({required this.id, List<Reaction> reactions = const []}) {
    setReactionMixin(reactions);
  }

  /// Factory constructor for creating a new [AppBarActionItem] instance from
  /// JSON data.
  factory AppBarActionItem.fromJson(Map json) {
    switch (json['type']) {
      case 'icon':
        return IconAppBarActionItem.fromJson(json);
      default:
        throw UnimplementedError('${json['type']} is not implemented');
    }
  }
}

/// An app bar action item with an icon.
@JsonSerializable()
class IconAppBarActionItem extends AppBarActionItem {
  /// Icon of the action item.
  MultiSourceIconModel icon;

  /// Tooltip text to show when the action item is hovered.
  String? tooltip;

  @override
  final String type = 'icon';

  /// Creates a new [IconAppBarActionItem] instance.
  IconAppBarActionItem({
    required super.id,
    required this.icon,
    this.tooltip,
    super.reactions,
  });

  /// Duplicate this [IconAppBarActionItem] instance with the given data
  /// overrides.
  IconAppBarActionItem copyWith({
    MultiSourceIconModel? icon,
    List<Reaction>? reactions,
    String? tooltip,
    double? iconSize,
  }) =>
      IconAppBarActionItem(
        id: id,
        icon: icon ?? this.icon,
        reactions: reactions ?? this.reactions,
        tooltip: tooltip ?? this.tooltip,
      );

  @override
  List<Object?> get props => [icon, reactions, tooltip];

  /// Creates a new [IconAppBarActionItem] instance from a JSON data.
  factory IconAppBarActionItem.fromJson(Map json) =>
      _$IconAppBarActionItemFromJson(json);

  @override
  Map toJson() => _$IconAppBarActionItemToJson(this);
}
