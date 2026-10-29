import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'chip_node.g.dart';

/// Default width of a chip node.
const double kChipDefaultWidth = 100;

/// Default height of a chip node, the Material 3 chip height.
const double kChipDefaultHeight = 32;

/// A Material 3 chip: a compact element that represents an input, attribute
/// or action.
/// Refer to [Chip](https://api.flutter.dev/flutter/material/Chip-class.html),
/// [ActionChip](https://api.flutter.dev/flutter/material/ActionChip-class.html),
/// [ChoiceChip](https://api.flutter.dev/flutter/material/ChoiceChip-class.html),
/// [FilterChip](https://api.flutter.dev/flutter/material/FilterChip-class.html)
/// and [InputChip](https://api.flutter.dev/flutter/material/InputChip-class.html)
/// in Flutter for more details.
@FlutterNode('ChoiceChip', family: 'material', nodeType: 'chip')
@JsonSerializable()
class ChipNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'chip';

  @override
  bool get supportsPadding => true;

  /// Holds configurable properties of this chip.
  @override
  covariant ChipProperties properties;

  /// Strictly used for previews. e.g in components panel.
  ChipNode.empty()
    : properties = ChipProperties(),
      super(
        id: 'chip',
        name: 'Chip',
        basicBoxLocal: NodeBox(0, 0, kChipDefaultWidth, kChipDefaultHeight),
      );

  /// Strictly used for previews. e.g in components panel.
  ChipNode.fromProperties(this.properties)
    : super(
        id: 'chip',
        name: 'Chip',
        basicBoxLocal: NodeBox(0, 0, kChipDefaultWidth, kChipDefaultHeight),
      );

  /// Creates a [ChipNode] with the given data.
  ChipNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
    super.alignment,
    super.padding,
    super.margin,
    super.rotationDegrees,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.aspectRatioLock,
    super.edgePins,
    super.parentID,
    super.positioningMode,
    // Custom properties.
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<ChipProperties>(
      'Properties',
      'Properties of the chip.',
      () => properties,
      (value) => properties = value,
    ),
  };

  /// [TriggerType.click] fires when an action, choice, filter or input chip
  /// is pressed and when an input chip's delete icon is pressed.
  /// [TriggerType.changed] fires with the new selection when a choice or
  /// filter chip is selected or deselected.
  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.changed,
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'label', value: properties.label),
    if (properties.chipType.supportsSelection)
      BoolValue(name: 'selected', value: properties.selected),
  ];

  @override
  List<Object?> get props => [
    ...super.props,
    properties,
    variables,
    multipleVariables,
  ];

  /// Creates a [ChipNode] from a JSON data.
  factory ChipNode.fromJson(Map json) => _$ChipNodeFromJson(json);

  @override
  Map toJson() => _$ChipNodeOmitDefaults(this, _$ChipNodeToJson(this));
}

/// Material 3 chip types.
enum ChipType {
  /// A plain [Chip] that displays information.
  basic,

  /// An [ActionChip] that triggers an action when pressed.
  action,

  /// A [ChoiceChip] for single selection.
  choice,

  /// A [FilterChip] for multi-selection.
  filter,

  /// An [InputChip] representing a piece of user input, with a delete icon.
  input;

  /// Returns displayable string representation.
  String get prettify => switch (this) {
    ChipType.basic => 'Chip',
    ChipType.action => 'Action Chip',
    ChipType.choice => 'Choice Chip',
    ChipType.filter => 'Filter Chip',
    ChipType.input => 'Input Chip',
  };

  /// Whether this chip type has a selected state.
  bool get supportsSelection => this == choice || this == filter;

  /// Whether this chip type has a delete icon.
  bool get supportsDeletion => this == input;

  /// Whether this chip type reacts to presses.
  bool get supportsPress => this == action || this == choice || this == filter;
}

/// Holds configurable properties of a [ChipNode].
@JsonSerializable()
class ChipProperties extends CustomProperties with FieldsHolder {
  /// Type of chip.
  ChipType chipType;

  /// Label text of the chip.
  String label;

  /// Label text style. Its color defaults to the theme's when the style has
  /// no fills.
  TextProp labelStyle;

  /// Icon shown as the chip's avatar when [avatar] is not set.
  MultiSourceIconModel? icon;

  /// URL of an image shown in a circle as the chip's avatar.
  String? avatar;

  /// Delete icon of input chips. Defaults to Flutter's clear icon.
  MultiSourceIconModel? deleteIcon;

  /// Color of the default delete icon.
  ColorRGBA? deleteIconColor;

  /// Whether a choice or filter chip is selected.
  @FlutterProp('selected', type: 'boolean', group: 'State', control: 'switch', field: 'properties.selected', required: true)
  bool selected;

  /// Whether a selected filter chip shows a checkmark.
  @FlutterProp('showCheckmark', type: 'boolean', group: 'Appearance', control: 'switch', field: 'properties.showCheckmark')
  bool showCheckmark;

  /// Color of the checkmark of a selected filter chip.
  ColorRGBA? checkmarkColor;

  /// Background color of the chip.
  ColorRGBA? backgroundColor;

  /// Background color of a selected choice or filter chip.
  ColorRGBA? selectedColor;

  /// Border color. Defaults to the theme's `colorScheme.outlineVariant`.
  ColorRGBA? borderColor;

  /// Border width.
  double borderWidth;

  /// Corner radius.
  double cornerRadius;

  /// Elevation.
  @FlutterProp('elevation', type: 'number', group: 'Appearance', control: 'number', field: 'properties.elevation')
  double elevation;

  /// Shadow color.
  ColorRGBA? shadowColor;

  /// Padding between the chip's contents and its border.
  EdgeInsetsModel padding;

  /// Padding around the label.
  EdgeInsetsModel labelPadding;

  /// Tooltip shown on long press or hover.
  @FlutterProp('tooltip', type: 'string', group: 'Interaction', control: 'text', field: 'properties.tooltip')
  String? tooltip;

  /// Whether the chip is focused automatically.
  @FlutterProp('autofocus', type: 'boolean', group: 'Interaction', control: 'switch', field: 'properties.autofocus')
  bool autofocus;

  /// Creates a [ChipProperties] with the given data.
  ChipProperties({
    this.chipType = ChipType.action,
    this.label = 'Chip',
    TextProp? labelStyle,
    this.icon,
    this.avatar,
    this.deleteIcon,
    this.deleteIconColor,
    this.selected = false,
    this.showCheckmark = true,
    this.checkmarkColor,
    this.backgroundColor,
    this.selectedColor,
    this.borderColor,
    this.borderWidth = 1,
    this.cornerRadius = 8,
    this.elevation = 0,
    this.shadowColor,
    this.padding = const EdgeInsetsModel.all(8),
    this.labelPadding = const EdgeInsetsModel.symmetric(horizontal: 8),
    this.tooltip,
    this.autofocus = false,
  }) : labelStyle =
           labelStyle ??
           TextProp.general(fontSize: 14, fills: List.empty(growable: true));

  /// Duplicates this [ChipProperties] with the given data overrides.
  ChipProperties copyWith({
    ChipType? chipType,
    String? label,
    TextProp? labelStyle,
    MultiSourceIconModel? icon,
    String? avatar,
    MultiSourceIconModel? deleteIcon,
    ColorRGBA? deleteIconColor,
    bool? selected,
    bool? showCheckmark,
    ColorRGBA? checkmarkColor,
    ColorRGBA? backgroundColor,
    ColorRGBA? selectedColor,
    ColorRGBA? borderColor,
    double? borderWidth,
    double? cornerRadius,
    double? elevation,
    ColorRGBA? shadowColor,
    EdgeInsetsModel? padding,
    EdgeInsetsModel? labelPadding,
    String? tooltip,
    bool? autofocus,
  }) {
    return ChipProperties(
      chipType: chipType ?? this.chipType,
      label: label ?? this.label,
      labelStyle: labelStyle ?? this.labelStyle,
      icon: icon ?? this.icon,
      avatar: avatar ?? this.avatar,
      deleteIcon: deleteIcon ?? this.deleteIcon,
      deleteIconColor: deleteIconColor ?? this.deleteIconColor,
      selected: selected ?? this.selected,
      showCheckmark: showCheckmark ?? this.showCheckmark,
      checkmarkColor: checkmarkColor ?? this.checkmarkColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      padding: padding ?? this.padding,
      labelPadding: labelPadding ?? this.labelPadding,
      tooltip: tooltip ?? this.tooltip,
      autofocus: autofocus ?? this.autofocus,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'chipType': EnumFieldAccess<ChipType>(
      'Chip Type',
      'Type of the chip.',
      () => chipType,
      (value) => chipType = value,
      defaultValue: () => ChipType.action,
      options: () => ChipType.values,
      requiresLayout: true,
    ),
    'label': StringFieldAccess(
      'Label',
      'Text label of the chip.',
      () => label,
      (value) => label = value,
      requiresLayout: true,
    ),
    'labelStyle': TextStyleFieldAccess<TextProp>(
      'Label Style',
      'Style of the chip label.',
      () => labelStyle,
      (value) => labelStyle = value,
      requiresLayout: true,
    ),
    'icon': IconFieldAccess<MultiSourceIconModel?>(
      'Icon',
      'Leading icon of the chip, shown when no avatar image is set.',
      () => icon,
      (value) => icon = value,
      requiresLayout: true,
      required: false,
    ),
    'avatar': StringFieldAccess(
      'Avatar',
      'URL of a leading avatar image.',
      () => avatar ?? '',
      (value) => avatar = value.isEmpty ? null : value,
      requiresLayout: true,
    ),
    'deleteIcon': IconFieldAccess<MultiSourceIconModel?>(
      'Delete Icon',
      'Delete icon of input chips.',
      () => deleteIcon,
      (value) => deleteIcon = value,
      requiresLayout: true,
      required: false,
    ),
    'deleteIconColor': ColorFieldAccess<ColorRGBA?>(
      'Delete Icon Color',
      'Color of the delete icon of input chips.',
      () => deleteIconColor,
      (value) => deleteIconColor = value,
    ),
    'selected': BoolFieldAccess(
      'Selected',
      'Whether a choice or filter chip is selected.',
      () => selected,
      (value) => selected = value,
    ),
    'showCheckmark': BoolFieldAccess(
      'Show Checkmark',
      'Whether a selected filter chip shows a checkmark.',
      () => showCheckmark,
      (value) => showCheckmark = value,
      requiresLayout: true,
    ),
    'checkmarkColor': ColorFieldAccess<ColorRGBA?>(
      'Checkmark Color',
      'Color of the checkmark of a selected filter chip.',
      () => checkmarkColor,
      (value) => checkmarkColor = value,
    ),
    'backgroundColor': ColorFieldAccess<ColorRGBA?>(
      'Background Color',
      'Background color of the chip.',
      () => backgroundColor,
      (value) => backgroundColor = value,
    ),
    'selectedColor': ColorFieldAccess<ColorRGBA?>(
      'Selected Color',
      'Background color of a selected choice or filter chip.',
      () => selectedColor,
      (value) => selectedColor = value,
    ),
    'borderColor': ColorFieldAccess<ColorRGBA?>(
      'Border Color',
      'Border color of the chip.',
      () => borderColor,
      (value) => borderColor = value,
    ),
    'borderWidth': NumFieldAccess<double>(
      'Border Width',
      'Width of the chip border.',
      () => borderWidth,
      (value) => borderWidth = value,
      requiresLayout: true,
    ),
    'cornerRadius': NumFieldAccess<double>(
      'Corner Radius',
      'Corner radius of the chip.',
      () => cornerRadius,
      (value) => cornerRadius = value,
    ),
    'elevation': NumFieldAccess<double>(
      'Elevation',
      'Elevation of the chip.',
      () => elevation,
      (value) => elevation = value,
    ),
    'shadowColor': ColorFieldAccess<ColorRGBA?>(
      'Shadow Color',
      'Shadow color of the chip.',
      () => shadowColor,
      (value) => shadowColor = value,
    ),
    'padding': SpacingFieldAccess.padding(
      'Padding',
      "Padding between the chip's contents and its border.",
      () => padding,
      (value) => padding = value,
      requiresLayout: true,
    ),
    'labelPadding': SpacingFieldAccess.padding(
      'Label Padding',
      'Padding around the label.',
      () => labelPadding,
      (value) => labelPadding = value,
      requiresLayout: true,
    ),
    'tooltip': StringFieldAccess(
      'Tooltip',
      'Tooltip shown on long press or hover.',
      () => tooltip ?? '',
      (value) => tooltip = value.isEmpty ? null : value,
    ),
    'autofocus': BoolFieldAccess(
      'Autofocus',
      'Whether the chip is focused automatically.',
      () => autofocus,
      (value) => autofocus = value,
    ),
  };

  @override
  List<Object?> get props => [
    chipType,
    label,
    labelStyle,
    icon,
    avatar,
    deleteIcon,
    deleteIconColor,
    selected,
    showCheckmark,
    checkmarkColor,
    backgroundColor,
    selectedColor,
    borderColor,
    borderWidth,
    cornerRadius,
    elevation,
    shadowColor,
    padding,
    labelPadding,
    tooltip,
    autofocus,
  ];

  /// Creates a [ChipProperties] from a JSON data.
  factory ChipProperties.fromJson(Map json) => _$ChipPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChipPropertiesOmitDefaults(this, _$ChipPropertiesToJson(this));
}
