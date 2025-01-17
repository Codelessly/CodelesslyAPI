import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'dropdown_node.g.dart';

/// A dropdown is a widget that lets the user choose from multiple options.
/// This widget is a material dropdown button that shows an overlay with the
/// options when pressed.
/// Refer to [DropdownButton](https://api.flutter.dev/flutter/material/DropdownButton-class.html)
/// in Flutter for more details.
@JsonSerializable()
class DropdownNode extends SceneNode with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'dropdown';

  @override
  bool get supportsPadding => true;

  /// Holds configurable properties of the dropdown.
  @override
  covariant DropdownProperties properties;

  /// Index of the selected option in the dropdown.
  Object? value;

  /// Creates a [DropdownNode] with the given data.
  DropdownNode({
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
    required this.properties,
    this.value,
  });

  @override
  List<TriggerType> get triggerTypes =>
      [TriggerType.click, TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    ObjectValue(name: 'value', value: value),
  ];

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<DropdownProperties>(
          'Properties',
          'Properties of the dropdown.',
          () => properties,
          (value) => properties = value,
        ),
      };

  /// Creates a [DropdownNode] from a JSON object.
  factory DropdownNode.fromJson(Map json) => _$DropdownNodeFromJson(json);

  @override
  Map toJson() => _$DropdownNodeToJson(this);
}

/// Holds configurable properties of the dropdown.
@JsonSerializable()
class DropdownProperties extends CustomProperties with FieldsHolder {
  /// Whether the dropdown is in the enabled state.
  bool enabled;

  /// Whether to reduce dropdown button's height.
  bool dense;

  /// Whether to expand the dropdown button's width.
  bool expanded;

  /// Whether to automatically focus the dropdown button.
  bool autoFocus;

  /// Whether to enable device-specific haptic feedback when dropdown button is
  /// tapped or long pressed.
  bool enableFeedback;

  /// Dropdown options.
  List<String> items;

  /// Text style applied to the dropdown's options.
  TextProp itemTextStyle;

  /// Alignment applied to the dropdown's options.
  AlignmentModel itemAlignment;

  /// Text style applied to the selected option.
  TextProp selectedItemTextStyle;

  /// Alignment applied to the selected option.
  AlignmentModel selectedItemAlignment;

  /// Placeholder text displayed in the dropdown button when [newValue] is null,
  /// i.e. no option is selected.
  String hint;

  /// Text style applied to hint.
  TextProp hintStyle;

  /// Color of icon when the dropdown button is disabled.
  ColorRGBA iconDisabledColor;

  /// Color of icon when the dropdown button is enabled.
  ColorRGBA iconEnabledColor;

  /// Icon size in dropdown button.
  double iconSize;

  /// Dropdown button's icon.
  MultiSourceIconModel icon;

  /// Color of dropdown overlay.
  ColorRGBA dropdownColor;

  /// Color of dropdown button when it is focused.
  ColorRGBA focusColor;

  /// Color of dropdown button and menu item when it is hovered.
  ColorRGBA? hoverColor;

  /// Splash Color of dropdown button.
  ColorRGBA? splashColor;

  /// The z-coordinate of the dropdown overlay.
  int elevation;

  /// Corner radii of the dropdown overlay.
  CornerRadius borderRadius;

  /// Whether to underline dropdown button's contents.
  bool underline;

  /// Whether to use data source to populate dropdown options.
  bool useDataSource;

  /// Label of the data source to use. This is only used when [useDataSource]
  /// is true. Allows to specify a template for item builder.
  String itemLabel;

  /// Creates a [DropdownProperties] instance with the given data.
  DropdownProperties({
    this.enabled = true,
    this.dense = false,
    this.expanded = false,
    this.autoFocus = false,
    this.enableFeedback = true,
    required this.items,
    TextProp? itemTextStyle,
    this.itemAlignment = AlignmentModel.centerLeft,
    TextProp? selectedItemTextStyle,
    this.selectedItemAlignment = AlignmentModel.centerLeft,
    this.hint = '',
    TextProp? hintStyle,
    this.iconDisabledColor = ColorRGBA.grey,
    this.iconEnabledColor = ColorRGBA.black,
    this.iconSize = 24,
    this.icon = const MultiSourceIconModel.icon(show: false),
    this.dropdownColor = ColorRGBA.white,
    this.focusColor = ColorRGBA.white,
    this.hoverColor,
    this.splashColor,
    this.elevation = 8,
    this.borderRadius = CornerRadius.zero,
    this.underline = true,
    this.useDataSource = false,
    this.itemLabel = '',
  })  : itemTextStyle = itemTextStyle ??
            TextProp.general(
              fills: [PaintModel.blackPaint],
              fontSize: 16,
              fontName: FontName.poppinsRegular,
            ),
        hintStyle = hintStyle ??
            TextProp.general(
              fills: [PaintModel.blackPaint],
              fontSize: 16,
              fontName: FontName.poppinsRegular,
            ),
        selectedItemTextStyle = selectedItemTextStyle ??
            TextProp.general(
              fills: [PaintModel.blackPaint],
              fontSize: 16,
              fontName: FontName.poppinsRegular,
            );

  /// Duplicates this [DropdownProperties] instance with the given data
  /// overrides.
  DropdownProperties copyWith({
    List<String>? items,
    TextProp? itemTextStyle,
    AlignmentModel? itemAlignment,
    TextProp? selectedItemTextStyle,
    AlignmentModel? selectedItemAlignment,
    String? hint,
    TextProp? hintStyle,
    ColorRGBA? iconDisabledColor,
    ColorRGBA? iconEnabledColor,
    double? iconSize,
    MultiSourceIconModel? icon,
    ColorRGBA? dropdownColor,
    ColorRGBA? focusColor,
    ColorRGBA? hoverColor,
    ColorRGBA? splashColor,
    int? elevation,
    CornerRadius? borderRadius,
    bool? underline,
    bool? useDataSource,
    String? itemLabel,
  }) {
    return DropdownProperties(
      items: items ?? this.items,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemAlignment: itemAlignment ?? this.itemAlignment,
      selectedItemTextStyle:
          selectedItemTextStyle ?? this.selectedItemTextStyle,
      selectedItemAlignment:
          selectedItemAlignment ?? this.selectedItemAlignment,
      hint: hint ?? this.hint,
      hintStyle: hintStyle ?? this.hintStyle,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconEnabledColor: iconEnabledColor ?? this.iconEnabledColor,
      iconSize: iconSize ?? this.iconSize,
      icon: icon ?? this.icon,
      dropdownColor: dropdownColor ?? this.dropdownColor,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      splashColor: splashColor ?? this.splashColor,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      underline: underline ?? this.underline,
      useDataSource: useDataSource ?? this.useDataSource,
      itemLabel: itemLabel ?? this.itemLabel,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'enabled': BoolFieldAccess(
          'Enabled',
          'Whether the dropdown is in the enabled state.',
          () => enabled,
          (value) => enabled = value,
        ),
        'dense': BoolFieldAccess(
          'Dense',
          'Whether to reduce dropdown button\'s height.',
          () => dense,
          (value) => dense = value,
          requiresLayout: true,
        ),
        'expanded': BoolFieldAccess(
          'Expanded',
          'Whether to expand the dropdown button\'s width.',
          () => expanded,
          (value) => expanded = value,
          requiresLayout: true,
        ),
        'autoFocus': BoolFieldAccess(
          'Auto Focus',
          'Whether to automatically focus the dropdown button.',
          () => autoFocus,
          (value) => autoFocus = value,
        ),
        'enableFeedback': BoolFieldAccess(
          'Enable Feedback',
          'Whether to enable device-specific haptic feedback when dropdown button is tapped or long pressed.',
          () => enableFeedback,
          (value) => enableFeedback = value,
        ),
        'items': IterableFieldAccess<String>(
          'Items',
          'Dropdown options.',
          () => items,
          (value) => items = value,
          (item) => item,
        ),
        'itemTextStyle': TextStyleFieldAccess<TextProp>(
          'Item Text Style',
          'Text style applied to the dropdown\'s options.',
          () => itemTextStyle,
          (value) => itemTextStyle = value,
          requiresLayout: true,
        ),
        'itemAlignment': AlignmentFieldAccess(
          'Item Alignment',
          'Alignment applied to the dropdown\'s options.',
          () => itemAlignment,
          (value) => itemAlignment = value,
          defaultValue: () => AlignmentModel.centerLeft,
        ),
        'selectedItemTextStyle': TextStyleFieldAccess<TextProp>(
          'Selected Item Text Style',
          'Text style applied to the selected option.',
          () => selectedItemTextStyle,
          (value) => selectedItemTextStyle = value,
          requiresLayout: true,
        ),
        'selectedItemAlignment': AlignmentFieldAccess(
          'Selected Item Alignment',
          'Alignment applied to the selected option.',
          () => selectedItemAlignment,
          (value) => selectedItemAlignment = value,
          defaultValue: () => AlignmentModel.centerLeft,
        ),
        'hint': StringFieldAccess(
          'Hint',
          'Placeholder text displayed in the dropdown button when [newValue] is null, i.e. no option is selected.',
          () => hint,
          (value) => hint = value,
        ),
        'hintStyle': TextStyleFieldAccess<TextProp>(
          'Hint Style',
          'Text style applied to hint.',
          () => hintStyle,
          (value) => hintStyle = value,
          requiresLayout: true,
        ),
        'iconDisabledColor': ColorFieldAccess<ColorRGBA>(
          'Icon Disabled Color',
          'Color of icon when the dropdown button is disabled.',
          () => iconDisabledColor,
          (value) => iconDisabledColor = value,
        ),
        'iconEnabledColor': ColorFieldAccess<ColorRGBA>(
          'Icon Enabled Color',
          'Color of icon when the dropdown button is enabled.',
          () => iconEnabledColor,
          (value) => iconEnabledColor = value,
        ),
        'iconSize': NumFieldAccess<double>(
          'Icon Size',
          'Icon size in dropdown button.',
          () => iconSize,
          (value) => iconSize = value,
          requiresLayout: true,
        ),
        'icon': IconFieldAccess<MultiSourceIconModel>(
          'Icon',
          'Dropdown button\'s icon.',
          () => icon,
          (value) => icon = value,
          requiresLayout: true,
        ),
        'dropdownColor': ColorFieldAccess<ColorRGBA>(
          'Dropdown Color',
          'Color of dropdown overlay.',
          () => dropdownColor,
          (value) => dropdownColor = value,
        ),
        'focusColor': ColorFieldAccess<ColorRGBA>(
          'Focus Color',
          'Color of dropdown button when it is focused.',
          () => focusColor,
          (value) => focusColor = value,
        ),
        'hoverColor': ColorFieldAccess<ColorRGBA?>(
          'Hover Color',
          'Color of dropdown button and menu item when it is hovered.',
          () => hoverColor,
          (value) => hoverColor = value,
        ),
        'splashColor': ColorFieldAccess<ColorRGBA?>(
          'Splash Color',
          'Splash Color of dropdown button.',
          () => splashColor,
          (value) => splashColor = value,
        ),
        'elevation': NumFieldAccess<int>(
          'Elevation',
          'The z-coordinate of the dropdown overlay.',
          () => elevation,
          (value) => elevation = value,
        ),
        'borderRadius': RadiusFieldAccess(
          'Border Radius',
          'Corner radii of the dropdown overlay.',
          () => borderRadius,
          (value) => borderRadius = value,
        ),
        'underline': BoolFieldAccess(
          'Underline',
          'Whether to underline dropdown button\'s contents.',
          () => underline,
          (value) => underline = value,
          requiresLayout: true,
        ),
        'itemLabel': StringFieldAccess(
          'Item Label',
          'Label of the data source to use. This is only used when [useDataSource] is true. Allows to specify a template for item builder.',
          () => itemLabel,
          (value) => itemLabel = value,
          requiresLayout: true,
        ),
      };

  @override
  List<Object?> get props => [
        items,
        itemTextStyle,
        itemAlignment,
        selectedItemTextStyle,
        selectedItemAlignment,
        hint,
        hintStyle,
        iconDisabledColor,
        iconEnabledColor,
        iconSize,
        icon,
        dropdownColor,
        focusColor,
        hoverColor,
        splashColor,
        elevation,
        borderRadius,
        underline,
        useDataSource,
        itemLabel,
      ];

  /// Creates a [DropdownProperties] instance from a JSON object.
  factory DropdownProperties.fromJson(Map json) =>
      _$DropdownPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DropdownPropertiesToJson(this);
}
