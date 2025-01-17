import 'dart:math';

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import '../utils.dart';
import 'nodes.dart';

part 'navigation_bar_node.g.dart';

/// Defines how navigation bar label's visibility behaves.
enum MaterialNavigationBarLabelBehavior {
  /// Label always visible.
  alwaysShow,

  /// Label always hidden.
  alwaysHide,

  /// Only selected label visible.
  onlyShowSelected,

  /// Only unselected label visible.
  onlyShowUnselected;

  /// Returns values for Material 2 navigation bar.
  static List<MaterialNavigationBarLabelBehavior> get valuesForMaterial2 =>
      MaterialNavigationBarLabelBehavior.values;

  /// Returns values for Material 3 navigation bar.
  static List<MaterialNavigationBarLabelBehavior> get valuesForMaterial3 => [
        ...MaterialNavigationBarLabelBehavior.values
      ]..remove(MaterialNavigationBarLabelBehavior.onlyShowUnselected);

  /// Returns values in readable form.
  String prettify() {
    switch (this) {
      case MaterialNavigationBarLabelBehavior.alwaysShow:
        return 'Always Show Labels';
      case MaterialNavigationBarLabelBehavior.alwaysHide:
        return 'Always Hide Labels';
      case MaterialNavigationBarLabelBehavior.onlyShowSelected:
        return 'Only Show When Selected';
      case MaterialNavigationBarLabelBehavior.onlyShowUnselected:
        return 'Only Show When Unselected';
    }
  }

  /// Returns values for which selected label is always visible.
  bool showForSelected() =>
      this == MaterialNavigationBarLabelBehavior.alwaysShow ||
      this == MaterialNavigationBarLabelBehavior.onlyShowSelected;

  /// Returns values for which unselected label is always visible.
  bool showForUnselected() =>
      this == MaterialNavigationBarLabelBehavior.alwaysShow ||
      this == MaterialNavigationBarLabelBehavior.onlyShowUnselected;
}

/// Material 2 navigation bar type.
/// See [BottomNavigationBarType](https://api.flutter.dev/flutter/material/BottomNavigationBarType.html)
/// for reference.
enum M2NavigationBarType {
  /// Navigation bar items have fixed width.
  fixed,

  /// Navigation bar items change width and position depending on the selected
  /// item.
  shifting;

  /// Returns values in readable form.
  String prettify() {
    switch (this) {
      case M2NavigationBarType.fixed:
        return 'Fixed';
      case M2NavigationBarType.shifting:
        return 'Shifting';
    }
  }
}

/// Material 2 navigation bar's layout in landscape orientation.
/// See [BottomNavigationBarLandscapeLayout](https://api.flutter.dev/flutter/material/BottomNavigationBarLandscapeLayout.html)
/// for reference.
enum M2NavigationBarLandscapeLayout {
  /// Items spread across the entire width of the screen.
  spread,

  /// Items are centered and take the same space as they would take in portrait
  /// orientation.
  centered,

  /// Item's icon and label are laid out in a row instead of a column.
  linear;

  /// Returns values in readable form.
  String prettify() {
    switch (this) {
      case M2NavigationBarLandscapeLayout.spread:
        return 'Spread';
      case M2NavigationBarLandscapeLayout.centered:
        return 'Centered';
      case M2NavigationBarLandscapeLayout.linear:
        return 'Linear';
    }
  }
}

/// Creates a [NavigationBarProperties] instance from a JSON object.
NavigationBarProperties navigationBarPropertiesFromJson(Map json) {
  final StyleDefinition styleDefinition =
      StyleDefinition.values.byName(json['styleDefinition']);

  switch (styleDefinition) {
    case StyleDefinition.material_2:
      return M2NavigationBarProperties.fromJson(json);
    case StyleDefinition.material_3:
      return M3NavigationBarProperties.fromJson(json);
  }
}

/// The default height of bottom navigation bar.
const double kDefaultBottomNavigationBarHeight = 56;

/// The default height of navigation bar.
const double kDefaultNavigationBarHeight = 80;

/// Navigation bar is a widget that lets the user navigate to different pages by
/// tapping on any of its items. The items are laid out in a row and the bar
/// itself is typically located at the bottom of the screen.
/// Inspired from: https://m3.material.io/components/navigation-bar.
@JsonSerializable()
class NavigationBarNode extends SceneNode
    with CustomPropertiesMixin, ParentReactionMixin, FieldsHolder {
  @override
  final String type = 'navigationBar';

  /// Index of currently selected item.
  int currentIndex;

  /// Holds configurable properties of the navigation bar.
  @override
  @JsonKey(fromJson: navigationBarPropertiesFromJson)
  covariant NavigationBarProperties properties;

  /// Creates a [NavigationBarNode] instance with the given data.
  NavigationBarNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.rotationDegrees,
    super.visible,
    super.enabled,
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
    this.currentIndex = 0,
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  List<ReactionMixin> get reactiveChildren => properties.items;

  /// Creates a [NavigationBarNode] from a JSON object.
  factory NavigationBarNode.fromJson(Map json) =>
      _$NavigationBarNodeFromJson(json);

  @override
  Map toJson() => _$NavigationBarNodeToJson(this);

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<NavigationBarProperties>(
          'Properties',
          'Properties of the navigation bar.',
          () => properties,
          (value) => properties = value,
        ),
      };
}

/// Holds configurable properties of the navigation bar.
abstract class NavigationBarProperties<T extends NavigationBarItem>
    extends CustomProperties with FieldsHolder {
  /// Defines the style of the navigation bar, i.e., Material 2 or Material 3.
  ///
  /// This has to be like this to force json serializable to serialize it.
  /// This is because if a field is not in the constructor of a class, it does
  /// not get serialized.
  late final StyleDefinition styleDefinition;

  /// Navigation bar's items.
  List<T> items;

  /// Add notch to the navigation bar.
  bool makeNotched;

  /// The margin between [FloatingActionButton] and navigation bar's notch.
  double notchMargin;

  /// Creates a [NavigationBarProperties] instance with the given data.
  NavigationBarProperties({
    required this.items,
    this.makeNotched = false,
    this.notchMargin = 4,
  });

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'makeNotched': BoolFieldAccess(
          'Make Notched',
          'Whether to make the navigation bar notched.',
          () => makeNotched,
          (value) => makeNotched = value,
          requiresLayout: true,
        ),
        'notchMargin': NumFieldAccess<double>(
          'Notch Margin',
          'The margin between the floating action button and the navigation bar\'s notch.',
          () => notchMargin,
          (value) => notchMargin = value,
          requiresLayout: true,
        ),
        'items': IterableFieldAccess<T>(
          'Items',
          'Nav items of the navigation bar.',
          () => items,
          (value) => items = value,
          (item) => item.label,
        ),
      };
}

/// Holds configurable properties of the material navigation bar.
abstract class MaterialNavigationBarProperties {
  /// Text style applied to selected item's label.
  abstract TextProp selectedLabelStyle;

  /// Text style applied to unselected item's label.
  abstract TextProp unselectedLabelStyle;

  /// Color of unselected item's icon.
  abstract ColorRGBA? unselectedIconColor;

  /// Color of selected item's icon.
  abstract ColorRGBA? selectedIconColor;

  /// Size of unselected item's icon.
  abstract double unselectedIconSize;

  /// Size of selected item's icon.
  abstract double selectedIconSize;

  /// Navigation bar's position in z-coordinate.
  abstract double elevation;

  /// Color of navigation bar's background.
  abstract ColorRGBA? backgroundColor;

  /// Defines how navigation bar label's visibility behaves.
  abstract MaterialNavigationBarLabelBehavior labelBehavior;
}

/// Holds configurable properties of the material 3 navigation bar.
@JsonSerializable()
class M3NavigationBarProperties
    extends NavigationBarProperties<M3NavigationBarItem>
    implements MaterialNavigationBarProperties {
  @override
  late final StyleDefinition styleDefinition = StyleDefinition.material_3;

  /// Color of navigation bar's selection indicator.
  ColorRGBA? indicatorColor;

  @override
  TextProp selectedLabelStyle;
  @override
  TextProp unselectedLabelStyle;
  @override
  ColorRGBA? unselectedIconColor;
  @override
  ColorRGBA? selectedIconColor;
  @override
  double unselectedIconSize;
  @override
  double selectedIconSize;
  @override
  double elevation;
  @override
  ColorRGBA? backgroundColor;
  @override
  MaterialNavigationBarLabelBehavior labelBehavior;

  /// Creates a [M3NavigationBarProperties] instance with the given data.
  M3NavigationBarProperties({
    required super.items,
    super.makeNotched,
    super.notchMargin,
    this.backgroundColor,
    this.elevation = 0,
    TextProp? selectedLabelStyle,
    TextProp? unselectedLabelStyle,
    this.unselectedIconColor,
    this.selectedIconColor,
    this.indicatorColor,
    this.unselectedIconSize = 24,
    this.selectedIconSize = 24,
    this.labelBehavior = MaterialNavigationBarLabelBehavior.alwaysShow,
  })  : selectedLabelStyle = selectedLabelStyle ?? TextProp(fontSize: 14),
        unselectedLabelStyle = unselectedLabelStyle ?? TextProp(fontSize: 12);

  /// Duplicates this [M3NavigationBarProperties] instance with the given data
  /// overrides.
  M3NavigationBarProperties copyWith({
    ColorRGBA? backgroundColor,
    double? elevation,
    TextProp? selectedLabelStyle,
    TextProp? unselectedLabelStyle,
    ColorRGBA? unselectedIconColor,
    ColorRGBA? selectedIconColor,
    ColorRGBA? indicatorColor,
    double? unselectedIconSize,
    double? selectedIconSize,
    MaterialNavigationBarLabelBehavior? labelBehavior,
    List<M3NavigationBarItem>? items,
    bool? makeNotched,
    double? notchMargin,
  }) {
    return M3NavigationBarProperties(
      items: items ?? this.items,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      unselectedLabelStyle: unselectedLabelStyle ?? this.unselectedLabelStyle,
      unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      unselectedIconSize: unselectedIconSize ?? this.unselectedIconSize,
      selectedIconSize: selectedIconSize ?? this.selectedIconSize,
      labelBehavior: labelBehavior ?? this.labelBehavior,
      makeNotched: makeNotched ?? this.makeNotched,
      notchMargin: notchMargin ?? this.notchMargin,
    );
  }

  @override
  List<Object?> get props => [
        items,
        backgroundColor,
        elevation,
        selectedLabelStyle,
        unselectedLabelStyle,
        unselectedIconColor,
        selectedIconColor,
        indicatorColor,
        unselectedIconSize,
        selectedIconSize,
        labelBehavior,
        makeNotched,
        notchMargin,
      ];

  @override
  Map<String, dynamic> toJson() => _$M3NavigationBarPropertiesToJson(this);

  /// Creates a [M3NavigationBarProperties] instance from a JSON object.
  static M3NavigationBarProperties fromJson(Map json) =>
      _$M3NavigationBarPropertiesFromJson(json);
}

/// Holds configurable properties of the material 2 navigation bar.
@JsonSerializable()
class M2NavigationBarProperties
    extends NavigationBarProperties<M2NavigationBarItem>
    implements MaterialNavigationBarProperties {
  @override
  late final StyleDefinition styleDefinition = StyleDefinition.material_2;

  /// Navigation bar type.
  M2NavigationBarType navigationBarType;

  /// Navigation bar's layout in landscape orientation.
  M2NavigationBarLandscapeLayout landscapeLayout;

  @override
  TextProp selectedLabelStyle;
  @override
  TextProp unselectedLabelStyle;
  @override
  ColorRGBA? unselectedIconColor;
  @override
  ColorRGBA? selectedIconColor;
  @override
  double unselectedIconSize;
  @override
  double selectedIconSize;
  @override
  double elevation;
  @override
  ColorRGBA? backgroundColor;
  @override
  MaterialNavigationBarLabelBehavior labelBehavior;

  /// Creates a [M2NavigationBarProperties] instance with the given data.
  M2NavigationBarProperties({
    required super.items,
    super.makeNotched,
    super.notchMargin,
    this.backgroundColor,
    this.elevation = 0,
    this.navigationBarType = M2NavigationBarType.fixed,
    this.landscapeLayout = M2NavigationBarLandscapeLayout.spread,
    TextProp? selectedLabelStyle,
    TextProp? unselectedLabelStyle,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.unselectedIconSize = 24,
    this.selectedIconSize = 24,
    this.labelBehavior = MaterialNavigationBarLabelBehavior.alwaysShow,
  })  : selectedLabelStyle =
            selectedLabelStyle ?? TextProp.general(fontSize: 14),
        unselectedLabelStyle =
            unselectedLabelStyle ?? TextProp.general(fontSize: 12);

  /// Duplicates this [M2NavigationBarProperties] instance with the given data
  /// overrides.
  M2NavigationBarProperties copyWith({
    ColorRGBA? backgroundColor,
    double? elevation,
    M2NavigationBarType? navigationBarType,
    M2NavigationBarLandscapeLayout? landscapeLayout,
    TextProp? selectedLabelStyle,
    TextProp? unselectedLabelStyle,
    ColorRGBA? unselectedIconColor,
    ColorRGBA? selectedIconColor,
    double? unselectedIconSize,
    double? selectedIconSize,
    MaterialNavigationBarLabelBehavior? labelBehavior,
    List<M2NavigationBarItem>? items,
    bool? makeNotched,
    double? notchMargin,
  }) {
    return M2NavigationBarProperties(
      items: items ?? this.items,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      navigationBarType: navigationBarType ?? this.navigationBarType,
      landscapeLayout: landscapeLayout ?? this.landscapeLayout,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      unselectedLabelStyle: unselectedLabelStyle ?? this.unselectedLabelStyle,
      unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      unselectedIconSize: unselectedIconSize ?? this.unselectedIconSize,
      selectedIconSize: selectedIconSize ?? this.selectedIconSize,
      labelBehavior: labelBehavior ?? this.labelBehavior,
    );
  }

  @override
  List<Object?> get props => [
        items,
        backgroundColor,
        elevation,
        navigationBarType,
        landscapeLayout,
        selectedLabelStyle,
        unselectedLabelStyle,
        unselectedIconColor,
        selectedIconColor,
        unselectedIconSize,
        selectedIconSize,
        labelBehavior,
        makeNotched,
        notchMargin,
      ];

  @override
  Map<String, dynamic> toJson() => _$M2NavigationBarPropertiesToJson(this);

  /// Creates a [M2NavigationBarProperties] instance from a JSON object.
  factory M2NavigationBarProperties.fromJson(Map json) =>
      _$M2NavigationBarPropertiesFromJson(json);
}
