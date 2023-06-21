// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'expansion_tile_node.g.dart';

/// A single-line [ListTile] with an expansion arrow icon that expands or
/// collapses the tile to reveal or hide the body.
///
/// Refer to Flutter's [ExpansionTile](https://api.flutter.dev/flutter/material/ExpansionTile-class.html)
/// for more details.
@JsonSerializable()
class ExpansionTileNode extends SceneNode
    with ChildrenMixin, RowColumnMixin, CustomPropertiesMixin, IsolatedMixin {
  @override
  final String type = 'expansionTile';

  /// Whether it is expanded or not.
  late bool isExpanded;

  /// ID of the ListView child used for the header/collapsed state.
  String? listTileChild;

  /// Holds configurable properties for the [ExpansionTileNode].
  ExpansionTileProperties properties;

  /// Strictly used for previews. e.g in components panel.
  ExpansionTileNode.empty()
      : properties = ExpansionTileProperties(),
        super(
          id: 'list_tile',
          name: 'List Tile',
          basicBoxLocal: NodeBox(0, 0, 300, 65),
        );

  /// Creates a [ExpansionTileNode] with given data.
  ExpansionTileNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    bool? isExpanded,
    // Start ExpansionTile.
    this.listTileChild,
    required this.properties,
    // End ExpansionTile.

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
    required List<String> children,
    super.variables,
    super.multipleVariables,
  }) {
    setChildrenMixin(children: children);
    setRowColumnMixin(
      rowColumnType: RowColumnType.column,
      mainAxisAlignment: MainAxisAlignmentC.start,
      crossAxisAlignment: CrossAxisAlignmentC.center,
    );
    this.isExpanded = isExpanded ?? properties.initiallyExpanded;
  }

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  void onChildIDChanged(String oldID, String newID) {
    if (listTileChild == oldID) {
      listTileChild = newID;
    }
  }

  @override
  EdgeInsetsModel minimumPadding() {
    // ExpansionTiles have fixed top and bottom borders that are always 1 pixel
    // height and cannot be removed.
    return super.minimumPadding() +
        const EdgeInsetsModel.symmetric(vertical: 1);
  }

  /// Creates a new [ExpansionTileNode] instance from a [json] map.
  factory ExpansionTileNode.fromJson(Map json) =>
      _$ExpansionTileNodeFromJson(json);

  @override
  Map toJson() => _$ExpansionTileNodeToJson(this);
}

/// Holds configurable properties of an [ExpansionTileNode].
@JsonSerializable()
class ExpansionTileProperties with SerializableMixin, EquatableMixin {
  /// Color of the tile's background when it is expanded.
  ColorRGBA? backgroundColor;

  /// Color of the tile's background when it is collapsed.
  ColorRGBA? collapsedBackgroundColor;

  /// Specifies if the list tile is initially expanded or collapsed (false, by
  /// default).
  bool initiallyExpanded;

  /// Specifies whether the state of the children is maintained when the tile
  /// expands and collapses.
  ///
  /// When true, the children are kept in the tree while the tile is collapsed.
  /// When false (default), the children are removed from the tree when the tile
  /// is collapsed and recreated upon expansion.
  bool maintainState;

  /// Specifies padding for the [ListTile].
  ///
  /// Analogous to [ListTile.contentPadding], this property defines the insets
  /// for the [leading], [title], [subtitle] and [trailing] widgets. It does not
  /// inset the expanded [children] widgets.
  EdgeInsetsModel? tilePadding;

  /// Specifies the alignment of [children], which are arranged in a column when
  /// the tile is expanded.
  ///
  /// The internals of the expanded tile make use of a [Column] widget for
  /// [children], and [Align] widget to align the column. The
  /// [expandedAlignment] parameter is passed directly into the [Align].
  ///
  /// Modifying this property controls the alignment of the column within the
  /// expanded tile, not the alignment of [children] widgets within the column.
  /// To align each child within [children], see [expandedCrossAxisAlignment].
  ///
  /// The width of the column is the width of the widest child widget in
  /// [children].
  AlignmentModel? expandedAlignment;

  /// Specifies the alignment of each child within [children] when the tile is
  /// expanded.
  ///
  /// The internals of the expanded tile make use of a [Column] widget for
  /// [children], and the [crossAxisAlignment] parameter is passed directly into
  /// the [Column].
  ///
  /// Modifying this property controls the cross axis alignment of each child
  /// within its [Column]. Note that the width of the [Column] that houses
  /// [children] will be the same as the widest child widget in [children]. It
  /// is not necessarily the width of [Column] is equal to the width of expanded
  /// tile.
  ///
  /// To align the [Column] along the expanded tile, use the [expandedAlignment]
  /// property instead.
  ///
  /// When the value is null, the value of [expandedCrossAxisAlignment] is
  /// [CrossAxisAlignment.center].
  CrossAxisAlignmentC expandedCrossAxisAlignment;

  /// Specifies padding for [children].
  EdgeInsetsModel? childrenPadding;

  /// The icon color of tile's expansion arrow icon when the sublist is
  /// expanded.
  ColorRGBA? iconColor;

  /// The icon color of tile's expansion arrow icon when the sublist is
  /// collapsed.
  ColorRGBA? collapsedIconColor;

  /// The color of the tile's titles when the sublist is expanded.
  ColorRGBA? textColor;

  /// The color of the tile's titles when the sublist is collapsed.
  ColorRGBA? collapsedTextColor;

  /// Typically used to force the expansion arrow icon to the tile's leading or
  /// trailing edge.
  ///
  /// By default, the value of [controlAffinity] is
  /// [ListTileControlAffinity.platform], which means that the expansion arrow
  /// icon will appear on the tile's trailing edge.
  ListTileControlAffinityC? controlAffinity;

  /// Material visual density.
  VisualDensityModel visualDensity;

  /// Whether to show a divider between header and body.
  bool showDividers;

  /// Platform or null affinity defaults to trailing.
  ListTileControlAffinityC effectiveAffinity(
      ListTileControlAffinityC? affinity) {
    switch (affinity ?? ListTileControlAffinityC.trailing) {
      case ListTileControlAffinityC.leading:
        return ListTileControlAffinityC.leading;
      case ListTileControlAffinityC.trailing:
      case ListTileControlAffinityC.platform:
        return ListTileControlAffinityC.trailing;
    }
  }

  /// Creates a new [ExpansionTileProperties] instance with give data.
  ExpansionTileProperties({
    this.backgroundColor = ColorRGBA.transparent,
    this.collapsedBackgroundColor = ColorRGBA.transparent,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding = kDefaultListTileContentPadding,
    this.expandedAlignment = AlignmentModel.center,
    this.expandedCrossAxisAlignment = CrossAxisAlignmentC.center,
    this.childrenPadding = EdgeInsetsModel.zero,
    this.iconColor = ColorRGBA.grey,
    this.collapsedIconColor = ColorRGBA.grey,
    this.textColor = ColorRGBA.grey,
    this.collapsedTextColor = ColorRGBA.grey,
    this.controlAffinity,
    this.visualDensity = VisualDensityModel.standard,
    this.showDividers = true,
  });

  /// Duplicates this [ExpansionTileProperties] instance with given data
  /// overrides.
  ExpansionTileProperties copyWith({
    ColorRGBA? backgroundColor,
    ColorRGBA? collapsedBackgroundColor,
    bool? initiallyExpanded,
    bool? maintainState,
    EdgeInsetsModel? tilePadding,
    AlignmentModel? expandedAlignment,
    CrossAxisAlignmentC? expandedCrossAxisAlignment,
    EdgeInsetsModel? childrenPadding,
    ColorRGBA? iconColor,
    ColorRGBA? collapsedIconColor,
    ColorRGBA? textColor,
    ColorRGBA? collapsedTextColor,
    ListTileControlAffinityC? controlAffinity,
    VisualDensityModel? visualDensity,
    bool? automaticChevron,
    bool? showDividers,
  }) {
    return ExpansionTileProperties(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      collapsedBackgroundColor:
          collapsedBackgroundColor ?? this.collapsedBackgroundColor,
      initiallyExpanded: initiallyExpanded ?? this.initiallyExpanded,
      maintainState: maintainState ?? this.maintainState,
      tilePadding: tilePadding ?? this.tilePadding,
      expandedAlignment: expandedAlignment ?? this.expandedAlignment,
      expandedCrossAxisAlignment:
          expandedCrossAxisAlignment ?? this.expandedCrossAxisAlignment,
      childrenPadding: childrenPadding ?? this.childrenPadding,
      iconColor: iconColor ?? this.iconColor,
      collapsedIconColor: collapsedIconColor ?? this.collapsedIconColor,
      textColor: textColor ?? this.textColor,
      collapsedTextColor: collapsedTextColor ?? this.collapsedTextColor,
      controlAffinity: controlAffinity ?? this.controlAffinity,
      visualDensity: visualDensity ?? this.visualDensity,
      showDividers: showDividers ?? this.showDividers,
    );
  }

  @override
  List<Object?> get props => [];

  @override
  Map toJson() => _$ExpansionTilePropertiesToJson(this);

  /// Creates a new [ExpansionTileProperties] from a JSON data.
  factory ExpansionTileProperties.fromJson(Map<String, dynamic> json) =>
      _$ExpansionTilePropertiesFromJson(json);
}
