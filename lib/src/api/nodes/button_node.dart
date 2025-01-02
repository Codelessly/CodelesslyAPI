import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../extensions.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'button_node.g.dart';

/// The default button padding used to convert nodes into Flutter buttons.
const EdgeInsetsModel defaultButtonPadding =
    EdgeInsetsModel.symmetric(horizontal: 16, vertical: 8);

/// Type of the material button.
enum ButtonTypeEnum {
  /// Elevated buttons have a shadow that makes them look 'elevated'.
  elevated,

  /// Text buttons are typically used for less-pronounced actions.
  text,

  /// Outlined buttons are medium-emphasis buttons. They contain actions that
  /// are important, but aren’t the primary action in an app.
  outlined,

  /// A button made of only an icon, no label.
  icon;

  /// Whether this button type is icon.
  bool get isIconButton => this == ButtonTypeEnum.icon;

  /// Whether this button type is elevated.
  bool get isElevatedButton => this == ButtonTypeEnum.elevated;

  /// Whether this button type is outlined.
  bool get isTextButton => this == ButtonTypeEnum.text;

  /// Whether this button type is outlined.
  bool get isOutlinedButton => this == ButtonTypeEnum.outlined;

  /// Displayable string representation of this button type.
  String get prettify {
    switch (this) {
      case ButtonTypeEnum.elevated:
        return 'Elevated Button';
      case ButtonTypeEnum.text:
        return 'Text Button';
      case ButtonTypeEnum.outlined:
        return 'Outlined Button';
      case ButtonTypeEnum.icon:
        return 'Icon Button';
    }
  }
}

/// A material button.
/// Refer to [Material 2 Buttons](https://m2.material.io/components/buttons) for
/// more details.
@JsonSerializable()
class ButtonNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'button';

  @override
  final bool supportsPadding = true;

  /// Holds configurable properties of this button.
  @override
  covariant ButtonProperties properties;

  /// Strictly used for previews. e.g in components panel.
  ButtonNode.empty()
      : properties = ButtonProperties(),
        super(
          id: 'button',
          name: 'Button',
          basicBoxLocal: NodeBox(0, 0, 100, 30),
        );

  /// Strictly used for previews. e.g in components panel.
  ButtonNode.fromProperties(this.properties)
      : super(
          id: 'button',
          name: 'Button',
          basicBoxLocal: NodeBox(0, 0, 100, 30),
        );

  /// An icon button can be defined by either having a buttonType of
  /// [ButtonTypeEnum.icon], or by having a shape of [CShapeBorder.circle] with
  /// an empty label.
  bool get behavesLikeAnIconButton =>
      properties.buttonType.isIconButton ||
      (properties.shape == CShapeBorder.circle &&
          properties.label.trim().isEmpty);

  @override
  EdgeInsetsModel? preferredDefaultPadding() {
    if (behavesLikeAnIconButton) {
      return const EdgeInsetsModel.all(16);
    } else {
      return defaultButtonPadding;
    }
  }

  /// Creates a [ButtonNode] with given data.
  ButtonNode({
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
        'properties': ObjectFieldAccess<ButtonProperties>(
          'Properties',
          'Properties of a button',
          () => properties,
          (value) => properties = value,
        ),
      };

  @override
  List<TriggerType> get triggerTypes =>
      [TriggerType.click, TriggerType.longPress];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    BoolValue(name: 'enabled', value: properties.enabled),
  ];

  @override
  List<Object?> get props => [
        ...super.props,
        properties,
        variables,
        multipleVariables,
      ];

  /// Creates a [ButtonNode] from a JSON data.
  factory ButtonNode.fromJson(Map json) => _$ButtonNodeFromJson(json);

  @override
  Map toJson() => _$ButtonNodeToJson(this);

  @override
  void updateVariableName({required String oldName, required String newName}) {
    super.updateVariableName(oldName: oldName, newName: newName);
    if (properties.label.isEmpty) return;
    properties.label = properties.label.replaceVariableName(oldName, newName);
  }
}

/// Holds configurable properties of a [ButtonNode].
@JsonSerializable()
class ButtonProperties extends CustomProperties
    with ShapeBorderMixin, FieldsHolder {
  // Button properties.

  /// Type of the button.
  late ButtonTypeEnum buttonType;

  /// Background color of the button.
  late ColorRGBA buttonColor;

  /// Elevation shadow color of the button.
  late ColorRGBA shadowColor;

  /// Elevation of the button.
  late double elevation;

  /// Whether the button is enabled.
  late bool enabled;

  // Label properties.

  /// Text to display in the button.
  late String label;

  /// Alignment of the label.
  late TextAlignHorizontalEnum labelAlignment;

  /// Style of the label.
  late TextProp labelStyle;

  // Icon properties.

  /// Describes the position of the icon.
  late IconPlacementEnum placement;

  /// Space between the icon and the label.
  late double gap;

  /// Icon to display in the button.
  late MultiSourceIconModel icon;

  /// Creates a [ButtonProperties] with given data.
  ButtonProperties({
    this.buttonType = ButtonTypeEnum.elevated,
    this.buttonColor = ColorRGBA.black,
    this.shadowColor = const ColorRGBA(r: 0.65, g: 0.65, b: 0.65, a: 1),
    this.label = '',
    this.elevation = 0,
    this.enabled = true,
    this.labelAlignment = TextAlignHorizontalEnum.center,
    this.placement = IconPlacementEnum.start,
    this.gap = 8,
    TextProp? labelStyle,
    this.icon = const MultiSourceIconModel(size: 20, color: null),
    CornerRadius cornerRadius = const CornerRadius.all(RadiusModel.circular(4)),
    ColorRGBA? borderColor,
    CShapeBorder shape = CShapeBorder.roundedRectangle,
    double? borderWidth,
  }) : labelStyle =
            labelStyle ?? TextProp.general(fills: List.empty(growable: true)) {
    setShapeBorderMixin(
      shape: shape,
      cornerRadius: cornerRadius,
      borderWidth: borderWidth,
      borderColor: borderColor,
    );
  }

  /// Duplicates this [ButtonProperties] instance with given data overrides.
  ButtonProperties copyWith({
    ButtonTypeEnum? buttonType,
    ColorRGBA? buttonColor,
    ColorRGBA? shadowColor,
    double? elevation,
    CornerRadius? cornerRadius,
    bool? enabled,
    String? label,
    TextProp? labelStyle,
    TextAlignHorizontalEnum? labelAlignment,
    IconPlacementEnum? placement,
    double? gap,
    MultiSourceIconModel? icon,
    CShapeBorder? shape,
    double? borderWidth,
    ColorRGBA? borderColor,
  }) {
    return ButtonProperties(
      buttonType: buttonType ?? this.buttonType,
      buttonColor: buttonColor ?? this.buttonColor,
      shadowColor: shadowColor ?? this.shadowColor,
      elevation: elevation ?? this.elevation,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
      labelStyle: labelStyle ?? this.labelStyle,
      labelAlignment: labelAlignment ?? this.labelAlignment,
      placement: placement ?? this.placement,
      gap: gap ?? this.gap,
      icon: icon ?? this.icon,
      shape: shape ?? this.shape,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        // 'buttonType': EnumFieldAccess<ButtonTypeEnum>(
        //   'Button Type',
        //   'Type of the button.',
        //   () => buttonType,
        //   (ButtonTypeEnum? value) {
        //     if (value != null) buttonType = value;
        //   },
        //   ButtonTypeEnum.values,
        // ),
        'buttonColor': ColorFieldAccess<ColorRGBA>(
          'Button Color',
          'Color of the button.',
          () => buttonColor,
          (ColorRGBA? value) {
            if (value != null) buttonColor = value;
          },
        ),
        'shadowColor': ColorFieldAccess<ColorRGBA>(
          'Shadow Color',
          'Color of button\'s shadow.',
          () => shadowColor,
          (ColorRGBA? value) {
            if (value != null) shadowColor = value;
          },
        ),
        'elevation': NumFieldAccess<double>(
          'Elevation',
          'Elevation of the button.',
          () => elevation,
          (double value) => elevation = value,
        ),
        'cornerRadius': RadiusFieldAccess(
          'Corner Radius',
          'Corner radius of the button.',
          () => cornerRadius,
          (CornerRadius? value) {
            if (value != null) cornerRadius = value;
          },
        ),
        'enabled': BoolFieldAccess(
          'Enabled',
          'Whether the button is enabled.',
          () => enabled,
          (bool? value) {
            if (value != null) enabled = value;
          },
        ),
        'label': StringFieldAccess(
          'Label',
          'Text label of the button.',
          () => label,
          requiresLayout: true,
          (String? value) {
            if (value != null) label = value;
          },
        ),
        'labelStyle': TextStyleFieldAccess(
          'Label Style',
          'Style of the button\'s label text.',
          () => labelStyle,
          requiresLayout: true,
          (TextProp value) => labelStyle = value,
        ),
        'labelAlignment': EnumFieldAccess<TextAlignHorizontalEnum>(
          'Label Alignment',
          'Horizontal alignment of the label text.',
          () => labelAlignment,
          (TextAlignHorizontalEnum? value) {
            if (value != null) labelAlignment = value;
          },
          defaultValue: () => TextAlignHorizontalEnum.left,
          options: () => TextAlignHorizontalEnum.values,
        ),
        'placement': EnumFieldAccess<IconPlacementEnum>(
          'Icon Placement',
          'Placement of the icon relative to the label.',
          () => placement,
          (IconPlacementEnum? value) {
            if (value != null) placement = value;
          },
          defaultValue: () => IconPlacementEnum.start,
          options: () => IconPlacementEnum.values,
        ),
        'gap': NumFieldAccess<double>(
          'Gap',
          'Space between icon and label.',
          () => gap,
          requiresLayout: true,
          (double value) => gap = value,
        ),
        'icon': IconFieldAccess(
          'Icon',
          'Icon displayed in the button.',
          () => icon,
          requiresLayout: true,
          (MultiSourceIconModel? value) {
            if (value != null) icon = value;
          },
        ),
        'shape': EnumFieldAccess<CShapeBorder>(
          'Shape',
          'Shape of the button.',
          () => shape,
          (CShapeBorder? value) {
            if (value != null) shape = value;
          },
          options: () => CShapeBorder.values,
          requiresLayout: true,
          defaultValue: () => CShapeBorder.roundedRectangle,
        ),
        'borderWidth': NumFieldAccess<double?>(
          'Border Width',
          'Width of the button\'s border.',
          () => borderWidth,
          requiresLayout: true,
          (double? value) => borderWidth = value,
        ),
        'borderColor': ColorFieldAccess<ColorRGBA>(
          'Border Color',
          'Color of the button\'s border.',
          () => borderColor,
          (ColorRGBA? value) {
            if (value != null) borderColor = value;
          },
        ),
      };

  /// Creates a [ButtonProperties] from a JSON data.
  factory ButtonProperties.fromJson(Map json) =>
      _$ButtonPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ButtonPropertiesToJson(this);

  @override
  List<Object?> get props => [
        buttonType,
        buttonColor,
        shadowColor,
        elevation,
        cornerRadius,
        enabled,
        label,
        labelStyle,
        labelAlignment,
        placement,
        gap,
        icon,
        shape,
        borderWidth,
        borderColor,
      ];
}
