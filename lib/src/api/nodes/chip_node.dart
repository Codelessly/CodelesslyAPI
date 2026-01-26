import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'chip_node.g.dart';

/// A Material 3 chip widget for compact representation of information or actions.
/// Refer to [Chip](https://api.flutter.dev/flutter/material/Chip-class.html)
/// and related chip widgets for more details.
@JsonSerializable()
class ChipNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'chip';

  @override
  final bool supportsPadding = true;

  /// Holds configurable properties of this chip.
  @override
  covariant ChipProperties properties;

  /// Strictly used for previews. e.g in components panel.
  ChipNode.empty()
      : properties = ChipProperties(),
        super(
          id: 'chip',
          name: 'Chip',
          basicBoxLocal: NodeBox(0, 0, 100, 32),
        );

  /// Strictly used for previews. e.g in components panel.
  ChipNode.fromProperties(this.properties)
      : super(
          id: 'chip',
          name: 'Chip',
          basicBoxLocal: NodeBox(0, 0, 100, 32),
        );

  /// Creates a [ChipNode] with given data.
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
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<ChipProperties>(
          'Properties',
          'Properties of a chip',
          () => properties,
          (value) => properties = value,
        ),
      };

  @override
  List<TriggerType> get triggerTypes => [
        TriggerType.click,
      ];

  @override
  late final List<ValueModel> propertyVariables = [
        ...super.propertyVariables,
        if (properties.chipType == ChipType.choice ||
            properties.chipType == ChipType.filter)
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
  Map toJson() => _$ChipNodeToJson(this);
}

/// Chip types following Material 3 design.
enum ChipType {
  /// Basic chip for displaying information.
  basic,

  /// Chip that represents an action.
  action,

  /// Chip for single selection.
  choice,

  /// Chip for filtering with multi-selection.
  filter,

  /// Chip representing complex information with optional delete.
  input;

  /// Returns displayable string representation.
  String get prettify {
    switch (this) {
      case ChipType.basic:
        return 'Chip';
      case ChipType.action:
        return 'Action Chip';
      case ChipType.choice:
        return 'Choice Chip';
      case ChipType.filter:
        return 'Filter Chip';
      case ChipType.input:
        return 'Input Chip';
    }
  }

  /// Whether this chip type supports selection state.
  bool get supportsSelection => this == choice || this == filter;

  /// Whether this chip type supports deletion.
  bool get supportsDeletion => this == input;

  /// Whether this chip type supports press action.
  bool get supportsPress => this == action || this == choice || this == filter;
}

/// Holds configurable properties of a [ChipNode].
@JsonSerializable()
class ChipProperties extends CustomProperties with FieldsHolder {
  /// Type of chip.
  late ChipType chipType;

  /// Label text of the chip.
  late String label;

  /// Label text style.
  late TextProp labelStyle;

  /// Leading icon.
  late MultiSourceIconModel? icon;

  /// Avatar image (alternative to icon).
  late String? avatar;

  /// Delete icon (for input chips).
  late MultiSourceIconModel? deleteIcon;

  /// Whether the chip is selected (for choice/filter chips).
  late bool selected;

  /// Background color of the chip.
  late ColorRGBA? backgroundColor;

  /// Selected background color (for choice/filter chips).
  late ColorRGBA? selectedColor;

  /// Border color.
  late ColorRGBA? borderColor;

  /// Border width.
  late double borderWidth;

  /// Corner radius.
  late double cornerRadius;

  /// Elevation.
  late double elevation;

  /// Shadow color.
  late ColorRGBA? shadowColor;

  /// Padding inside the chip.
  late EdgeInsetsModel padding;

  /// Label padding.
  late EdgeInsetsModel labelPadding;

  /// Whether the chip should auto-resize to content.
  late bool autofocus;

  /// Creates a [ChipProperties] with given data.
  ChipProperties({
    this.chipType = ChipType.action,
    this.label = 'Chip',
    TextProp? labelStyle,
    this.icon,
    this.avatar,
    this.deleteIcon,
    this.selected = false,
    this.backgroundColor,
    this.selectedColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.cornerRadius = 8.0,
    this.elevation = 0,
    this.shadowColor,
    EdgeInsetsModel? padding,
    EdgeInsetsModel? labelPadding,
    this.autofocus = false,
  })  : labelStyle =
            labelStyle ?? TextProp.general(fills: List.empty(growable: true)),
        padding = padding ?? const EdgeInsetsModel.symmetric(horizontal: 12),
        labelPadding = labelPadding ??
            const EdgeInsetsModel.symmetric(horizontal: 8, vertical: 4);

  /// Duplicates this [ChipProperties] instance with given data overrides.
  ChipProperties copyWith({
    ChipType? chipType,
    String? label,
    TextProp? labelStyle,
    MultiSourceIconModel? icon,
    String? avatar,
    MultiSourceIconModel? deleteIcon,
    bool? selected,
    ColorRGBA? backgroundColor,
    ColorRGBA? selectedColor,
    ColorRGBA? borderColor,
    double? borderWidth,
    double? cornerRadius,
    double? elevation,
    ColorRGBA? shadowColor,
    EdgeInsetsModel? padding,
    EdgeInsetsModel? labelPadding,
    bool? autofocus,
  }) {
    return ChipProperties(
      chipType: chipType ?? this.chipType,
      label: label ?? this.label,
      labelStyle: labelStyle ?? this.labelStyle,
      icon: icon ?? this.icon,
      avatar: avatar ?? this.avatar,
      deleteIcon: deleteIcon ?? this.deleteIcon,
      selected: selected ?? this.selected,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      padding: padding ?? this.padding,
      labelPadding: labelPadding ?? this.labelPadding,
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
          (ChipType? value) {
            if (value != null) chipType = value;
          },
          defaultValue: () => ChipType.action,
          options: () => ChipType.values,
          requiresLayout: true,
        ),
        'label': StringFieldAccess(
          'Label',
          'Text label of the chip.',
          () => label,
          requiresLayout: true,
          (String? value) {
            if (value != null) label = value;
          },
        ),
        'labelStyle': TextStyleFieldAccess<TextProp>(
          'Label Style',
          'Style of the chip label text.',
          () => labelStyle,
          requiresLayout: true,
          (TextProp value) => labelStyle = value,
        ),
        'icon': IconFieldAccess<MultiSourceIconModel?>(
          'Icon',
          'Leading icon of the chip.',
          () => icon,
          (MultiSourceIconModel? value) => icon = value,
          requiresLayout: true,
        ),
        'avatar': StringFieldAccess(
          'Avatar',
          'Avatar image URL (alternative to icon).',
          () => avatar ?? '',
          requiresLayout: true,
          (String? value) => avatar = value?.isEmpty ?? true ? null : value,
        ),
        'deleteIcon': IconFieldAccess<MultiSourceIconModel?>(
          'Delete Icon',
          'Delete icon for input chips.',
          () => deleteIcon,
          (MultiSourceIconModel? value) => deleteIcon = value,
          requiresLayout: true,
        ),
        'selected': BoolFieldAccess(
          'Selected',
          'Whether the chip is selected (choice/filter chips).',
          () => selected,
          (bool? value) {
            if (value != null) selected = value;
          },
        ),
        'backgroundColor': ColorFieldAccess<ColorRGBA?>(
          'Background Color',
          'Background color of the chip.',
          () => backgroundColor,
          (ColorRGBA? value) => backgroundColor = value,
        ),
        'selectedColor': ColorFieldAccess<ColorRGBA?>(
          'Selected Color',
          'Background color when selected (choice/filter chips).',
          () => selectedColor,
          (ColorRGBA? value) => selectedColor = value,
        ),
        'borderColor': ColorFieldAccess<ColorRGBA?>(
          'Border Color',
          'Border color of the chip.',
          () => borderColor,
          (ColorRGBA? value) => borderColor = value,
        ),
        'borderWidth': NumFieldAccess<double>(
          'Border Width',
          'Width of the chip border.',
          () => borderWidth,
          requiresLayout: true,
          (double value) => borderWidth = value,
        ),
        'cornerRadius': NumFieldAccess<double>(
          'Corner Radius',
          'Corner radius of the chip.',
          () => cornerRadius,
          requiresLayout: true,
          (double value) => cornerRadius = value,
        ),
        'elevation': NumFieldAccess<double>(
          'Elevation',
          'Elevation of the chip.',
          () => elevation,
          requiresLayout: true,
          (double value) => elevation = value,
        ),
        'shadowColor': ColorFieldAccess<ColorRGBA?>(
          'Shadow Color',
          'Shadow color of the chip.',
          () => shadowColor,
          (ColorRGBA? value) => shadowColor = value,
        ),
        'padding': SpacingFieldAccess.padding(
          'Padding',
          'Padding inside the chip.',
          () => padding,
          (EdgeInsetsModel? value) {
            if (value != null) padding = value;
          },
          requiresLayout: true,
        ),
        'labelPadding': SpacingFieldAccess.padding(
          'Label Padding',
          'Padding around the label.',
          () => labelPadding,
          (EdgeInsetsModel? value) {
            if (value != null) labelPadding = value;
          },
          requiresLayout: true,
        ),
        'autofocus': BoolFieldAccess(
          'Autofocus',
          'Whether the chip should autofocus.',
          () => autofocus,
          (bool? value) {
            if (value != null) autofocus = value;
          },
        ),
      };

  /// Creates a [ChipProperties] from a JSON data.
  factory ChipProperties.fromJson(Map json) => _$ChipPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChipPropertiesToJson(this);

  @override
  List<Object?> get props => [
        chipType,
        label,
        labelStyle,
        icon,
        avatar,
        deleteIcon,
        selected,
        backgroundColor,
        selectedColor,
        borderColor,
        borderWidth,
        cornerRadius,
        elevation,
        shadowColor,
        padding,
        labelPadding,
        autofocus,
      ];
}
