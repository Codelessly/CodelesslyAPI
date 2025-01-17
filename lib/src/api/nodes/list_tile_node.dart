import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'list_tile_node.g.dart';

/// Default width for the [ListTileNode].
const double kDefaultListTileWidth = 300;

/// Default height for the [ListTileNode].
const double kDefaultListTileHeight = 65;

/// Default value for [horizontalTitleGap] in [ListTile].
const double kDefaultListTileHorizontalTitleGap = 16;

/// Default value for [minVerticalPadding] in [ListTile].
const double kDefaultListTileMinVerticalPadding = 4;

/// Default value for [minLeadingWidth] in [ListTile].
const double kDefaultListTileMinLeadingWidth = 40;

/// Default value for [contentPadding] in [ListTile].
const EdgeInsetsModel kDefaultListTileContentPadding =
    EdgeInsetsModel.symmetric(horizontal: 16);

/// A single fixed-height row that typically contains some text as well as a
/// leading or trailing icon.
/// Refer to [ListTile](https://api.flutter.dev/flutter/material/ListTile-class.html)
/// in Flutter for more details.
@JsonSerializable()
class ListTileNode extends SceneNode
    with ChildrenMixin, CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'listTile';

  /// ID of the leading node.
  String? leading;

  /// ID of the title node.
  String? title;

  /// ID of the subtitle node.
  String? subtitle;

  /// ID of the trailing node.
  String? trailing;

  /// Holds configurable properties for the [ListTileNode].
  @override
  covariant ListTileProperties properties;

  @override
  BoxConstraintsModel? relegatedConstraintsToChildren(BaseNode child) {
    if (child.id == leading) {
      return BoxConstraintsModel(minWidth: properties.minLeadingWidth);
    }
    if (child.id == trailing) {
      return BoxConstraintsModel(minWidth: properties.minLeadingWidth);
    }

    return const BoxConstraintsModel();
  }

  /// Strictly used for previews. e.g in components panel.
  ListTileNode.empty()
      : properties = ListTileProperties(),
        super(
          id: 'list_tile',
          name: 'List Tile',
          basicBoxLocal: NodeBox(0, 0, 300, 65),
        );

  /// Strictly used for previews. e.g in components panel.
  ListTileNode.fromProperties(this.properties)
      : super(
          id: 'list_tile',
          name: 'List Tile',
          basicBoxLocal: NodeBox(0, 0, 300, 65),
        );

  /// Creates a [ListTileNode] with the given data.
  ListTileNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,

    // Start [ListTile].
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    required this.properties,
    // End [ListTile].

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
    required List<String> children,
    super.variables,
    super.multipleVariables,
  }) {
    setChildrenMixin(children: children);
  }

  @override
  List<TriggerType> get triggerTypes =>
      [TriggerType.click, TriggerType.longPress];

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<ListTileProperties>(
          'Properties',
          'Properties of the ListTile',
          () => properties,
          (value) => properties = value,
        ),
      };

  @override
  void onChildIDChanged(String oldID, String newID) {
    if (leading == oldID) {
      leading = newID;
    } else if (title == oldID) {
      title = newID;
    } else if (subtitle == oldID) {
      subtitle = newID;
    } else if (trailing == oldID) {
      trailing = newID;
    }
  }

  @override
  EdgeInsetsModel minimumPadding() {
    final double additionalPadding = properties.borderWidth ?? 0.0;
    return super.minimumPadding() + EdgeInsetsModel.all(additionalPadding);
  }

  /// Creates a [ListTileNode] from a JSON data.
  factory ListTileNode.fromJson(Map json) => _$ListTileNodeFromJson(json);

  @override
  Map toJson() => _$ListTileNodeToJson(this);
}

/// Holds configurable properties for the [ListTileNode].
@JsonSerializable()
class ListTileProperties extends CustomProperties
    with ShapeBorderMixin, FieldsHolder {
  /// Whether this list tile is intended to display three lines of text.
  ///
  /// If true, then [subtitle] must be non-null (since it is expected to give
  /// the second and third lines of text).
  ///
  /// If false, the list tile is treated as having one line if the subtitle is
  /// null and treated as having two lines if the subtitle is non-null.
  ///
  /// When using a [Text] widget for [title] and [subtitle], line limits can be
  /// enforced using [Text.maxLines].
  bool isThreeLine;

  /// Whether the list tile layout is densely cramped together.
  bool dense;

  /// The default for visual densities is zero for both vertical and horizontal
  /// densities, which corresponds to the default visual density of components
  /// in the Material Design specification.
  VisualDensityModel visualDensity;

  /// Defines the color used for icons and text when the list tile is selected.
  ColorRGBA? selectedColor;

  /// Defines the default color for [leading] and [trailing] icons.
  ColorRGBA? iconColor;

  /// Defines the default color for the [title] and [subtitle].
  ColorRGBA? textColor;

  /// The tile's internal padding.
  ///
  /// Insets a [ListTile]'s contents: its [leading], [title], [subtitle], and
  /// [trailing] widgets.
  EdgeInsetsModel contentPadding;

  /// Whether this list tile is interactive.
  bool enabled;

  /// Whether this list tile is selected.
  bool selected;

  /// The color for the tile's [Material] when it has the input focus.
  ColorRGBA? focusColor;

  /// The color for the tile's [Material] when a pointer is hovering over it.
  ColorRGBA? hoverColor;

  /// Whether to automatically focus the tile.
  bool autofocus;

  /// Defines the background color of `ListTile` when [selected] is false.
  ///
  /// When the value is null, the `tileColor` is set to
  /// [ListTileTheme.tileColor] if it's not null and to [Colors.transparent] if
  /// it's null.
  ColorRGBA? tileColor;

  /// Defines the background color of `ListTile` when [selected] is true.
  ///
  /// When the value if null, the `selectedTileColor` is set to
  /// [ListTileTheme.selectedTileColor] if it's not null and to
  /// [Colors.transparent] if it's null.
  ColorRGBA? selectedTileColor;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// When null, the default value is true.
  bool enableFeedback;

  /// The horizontal gap between the titles and the leading/trailing widgets.
  ///
  /// If null, then the value of [ListTileTheme.horizontalTitleGap] is used. If
  /// that is also null, then a default value of 16 is used.
  double? horizontalTitleGap;

  /// The minimum padding on the top and bottom of the title and subtitle
  /// widgets.
  ///
  /// If null, then the value of [ListTileTheme.minVerticalPadding] is used. If
  /// that is also null, then a default value of 4 is used.
  double? minVerticalPadding;

  /// The minimum width allocated for the [ListTile.leading] widget.
  ///
  /// If null, then the value of [ListTileTheme.minLeadingWidth] is used. If
  /// that is also null, then a default value of 40 is used.
  double? minLeadingWidth;

  /// Whether to show the leading widget.
  bool showLeading;

  /// Whether to show the title widget.
  bool showTitle;

  /// Whether to show the subtitle widget.
  bool showSubtitle;

  /// Whether to show the trailing widget.
  bool showTrailing;

  /// Creates a new [ListTileProperties] with given data.
  ListTileProperties({
    this.showLeading = true,
    this.showTitle = true,
    this.showSubtitle = true,
    this.showTrailing = true,
    this.isThreeLine = false,
    this.dense = false,
    this.visualDensity = VisualDensityModel.standard,
    CShapeBorder shape = CShapeBorder.rectangle,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.contentPadding = kDefaultListTileContentPadding,
    this.enabled = true,
    this.selected = false,
    this.focusColor,
    this.hoverColor,
    this.autofocus = false,
    CornerRadius cornerRadius = CornerRadius.zero,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback = true,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
    ColorRGBA? borderColor,
    double? borderWidth,
  }) {
    setShapeBorderMixin(
      shape: shape,
      cornerRadius: cornerRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );
  }

  /// Duplicate this [ListTileProperties] instance with the given data
  /// overrides.
  ListTileProperties copyWith({
    bool? isThreeLine,
    bool? dense,
    VisualDensityModel? visualDensity,
    CShapeBorder? shape,
    ColorRGBA? selectedColor,
    ColorRGBA? iconColor,
    ColorRGBA? textColor,
    EdgeInsetsModel? contentPadding,
    bool? enabled,
    bool? selected,
    ColorRGBA? focusColor,
    ColorRGBA? hoverColor,
    bool? autofocus,
    CornerRadius? cornerRadius,
    ColorRGBA? tileColor,
    ColorRGBA? selectedTileColor,
    bool? enableFeedback,
    double? horizontalTitleGap,
    double? minVerticalPadding,
    double? minLeadingWidth,
    ColorRGBA? borderColor,
    double? borderWidth,
    bool? showLeading,
    bool? showTitle,
    bool? showSubtitle,
    bool? showTrailing,
  }) {
    return ListTileProperties(
      isThreeLine: isThreeLine ?? this.isThreeLine,
      dense: dense ?? this.dense,
      visualDensity: visualDensity ?? this.visualDensity,
      shape: shape ?? this.shape,
      selectedColor: selectedColor ?? this.selectedColor,
      iconColor: iconColor ?? this.iconColor,
      textColor: textColor ?? this.textColor,
      contentPadding: contentPadding ?? this.contentPadding,
      enabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      autofocus: autofocus ?? this.autofocus,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      tileColor: tileColor ?? this.tileColor,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      horizontalTitleGap: horizontalTitleGap ?? this.horizontalTitleGap,
      minVerticalPadding: minVerticalPadding ?? this.minVerticalPadding,
      minLeadingWidth: minLeadingWidth ?? this.minLeadingWidth,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      showLeading: showLeading ?? this.showLeading,
      showTitle: showTitle ?? this.showTitle,
      showSubtitle: showSubtitle ?? this.showSubtitle,
      showTrailing: showTrailing ?? this.showTrailing,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'isThreeLine': BoolFieldAccess(
          'Is Three Line',
          'Whether this list tile is intended to display three lines of text.',
          () => isThreeLine,
          (value) => isThreeLine = value,
          requiresLayout: true,
        ),
        'dense': BoolFieldAccess(
          'Dense',
          'Whether the list tile layout is densely cramped together.',
          () => dense,
          (value) => dense = value,
          requiresLayout: true,
        ),
        'selectedColor': ColorFieldAccess<ColorRGBA?>(
          'Selected Color',
          'Defines the color used for icons and text when the list tile is selected.',
          () => selectedColor,
          (value) => selectedColor = value,
        ),
        'iconColor': ColorFieldAccess<ColorRGBA?>(
          'Icon Color',
          'Defines the default color for leading and trailing icons.',
          () => iconColor,
          (value) => iconColor = value,
        ),
        'textColor': ColorFieldAccess<ColorRGBA?>(
          'Text Color',
          'Defines the default color for the title and subtitle.',
          () => textColor,
          (value) => textColor = value,
        ),
        'contentPadding': SpacingFieldAccess.padding(
          'Content Padding',
          'The tile\'s internal padding.',
          () => contentPadding,
          (value) => contentPadding = value,
          requiresLayout: true,
        ),
        'enabled': BoolFieldAccess(
          'Enabled',
          'Whether this list tile is interactive.',
          () => enabled,
          (value) => enabled = value,
        ),
        'selected': BoolFieldAccess(
          'Selected',
          'Whether this list tile is selected.',
          () => selected,
          (value) => selected = value,
          requiresLayout: true,
        ),
        'focusColor': ColorFieldAccess<ColorRGBA?>(
          'Focus Color',
          'The color for the tile\'s Material when it has the input focus.',
          () => focusColor,
          (value) => focusColor = value,
        ),
        'hoverColor': ColorFieldAccess<ColorRGBA?>(
          'Hover Color',
          'The color for the tile\'s Material when a pointer is hovering over it.',
          () => hoverColor,
          (value) => hoverColor = value,
        ),
        'autofocus': BoolFieldAccess(
          'Autofocus',
          'Whether to automatically focus the tile.',
          () => autofocus,
          (value) => autofocus = value,
        ),
        'tileColor': ColorFieldAccess<ColorRGBA?>(
          'Tile Color',
          'Defines the background color of ListTile when selected is false.',
          () => tileColor,
          (value) => tileColor = value,
        ),
        'selectedTileColor': ColorFieldAccess<ColorRGBA?>(
          'Selected Tile Color',
          'Defines the background color of ListTile when selected is true.',
          () => selectedTileColor,
          (value) => selectedTileColor = value,
        ),
        'enableFeedback': BoolFieldAccess(
          'Enable Feedback',
          'Whether detected gestures should provide acoustic and/or haptic feedback.',
          () => enableFeedback,
          (value) => enableFeedback = value,
        ),
        'horizontalTitleGap': NumFieldAccess<double?>(
          'Horizontal Title Gap',
          'The horizontal gap between the titles and the leading/trailing widgets.',
          () => horizontalTitleGap,
          (value) => horizontalTitleGap = value,
          requiresLayout: true,
        ),
        'minVerticalPadding': NumFieldAccess<double?>(
          'Min Vertical Padding',
          'The minimum padding on the top and bottom of the title and subtitle widgets.',
          () => minVerticalPadding,
          (value) => minVerticalPadding = value,
          requiresLayout: true,
        ),
        'minLeadingWidth': NumFieldAccess<double?>(
          'Min Leading Width',
          'The minimum width allocated for the ListTile.leading widget.',
          () => minLeadingWidth,
          (value) => minLeadingWidth = value,
          requiresLayout: true,
        ),
      };

  @override
  List<Object?> get props => [
        isThreeLine,
        dense,
        visualDensity,
        shape,
        selectedColor,
        iconColor,
        textColor,
        contentPadding,
        enabled,
        selected,
        focusColor,
        hoverColor,
        autofocus,
        tileColor,
        selectedTileColor,
        enableFeedback,
        horizontalTitleGap,
        minVerticalPadding,
        minLeadingWidth,
        borderColor,
        borderWidth,
      ];

  @override
  Map<String, dynamic> toJson() => _$ListTilePropertiesToJson(this);

  /// Creates a new [ListTileProperties] from a JSON data.
  factory ListTileProperties.fromJson(Map json) =>
      _$ListTilePropertiesFromJson(json);
}
