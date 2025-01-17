import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'floating_action_button_node.g.dart';

/// A floating action button (FAB) performs the primary, or most common, action
/// on a screen. It appears in front of all screen content, typically as a
/// circular shape with an icon in its center.
/// FABs come in three types: regular, mini, and extended.
/// Refer to [FloatingActionButton](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html)
/// in Flutter for more details.
@JsonSerializable()
class FloatingActionButtonNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'floatingActionButton';

  /// Holds configurable properties for the [FloatingActionButtonNode].
  @override
  covariant FloatingActionButtonProperties properties;

  /// Strictly used for previews. e.g in components panel.
  FloatingActionButtonNode.empty()
      : properties = FloatingActionButtonProperties(),
        super(
          id: 'fab',
          name: 'FAB',
          basicBoxLocal:
              NodeBox(0, 0, kSwitchDefaultWidth, kSwitchDefaultHeight),
        );

  /// Strictly used for previews. e.g in components panel.
  FloatingActionButtonNode.fromProperties(this.properties)
      : super(
          id: 'fab',
          name: 'FAB',
          basicBoxLocal:
              NodeBox(0, 0, properties.type.size, properties.type.size),
        );

  /// Creates a [FloatingActionButtonNode] with the given data.
  FloatingActionButtonNode({
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
    super.aspectRatioLock,
    super.constraints,
    super.parentID,
    super.positioningMode,
    super.edgePins,
    // Custom properties.
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  List<TriggerType> get triggerTypes => [TriggerType.click];

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<FloatingActionButtonProperties>(
          'Properties',
          'Properties of the FAB',
          () => properties,
          (value) => properties = value,
        ),
      };

  /// Creates a [FloatingActionButtonNode] from a JSON data.
  factory FloatingActionButtonNode.fromJson(Map json) =>
      _$FloatingActionButtonNodeFromJson(json);

  @override
  Map toJson() => _$FloatingActionButtonNodeToJson(this);
}

/// Holds configurable properties for the [FloatingActionButtonNode].
@JsonSerializable()
class FloatingActionButtonProperties extends CustomProperties
    with ShapeBorderMixin, ReactionMixin, FieldsHolder {
  /// Background color of the FAB.
  ColorRGBA backgroundColor;

  /// Color of the FAB's icon/text.
  ColorRGBA foregroundColor;

  /// Elevation of the FAB.
  double elevation;

  /// Elevation of the FAB when it is focuses.
  double focusElevation;

  /// Elevation of the FAB when it is hovered.
  double hoverElevation;

  /// Elevation of the FAB when it is highlighted.
  double highlightElevation;

  /// Type of the FAB. Mainly refers to its sizes. Extended type includes a
  /// label as well.
  FloatingActionButtonType type;

  /// Where to place the FAB on the screen.
  FABLocation location;

  /// Icon of the FAB.
  MultiSourceIconModel icon;

  /// Label of the FAB in case of [FloatingActionButtonType.extended].
  String label;

  /// Style of the label.
  TextProp labelStyle;

  /// Color of the FAB when it is focused.
  ColorRGBA? focusColor;

  /// Color of the FAB when it is hovered.
  ColorRGBA? hoverColor;

  /// Material splash color of the FAB.
  ColorRGBA? splashColor;

  /// Space between the icon and label for [FloatingActionButtonType.extended].
  double extendedIconLabelSpacing;

  @override
  List<TriggerType> get triggerTypes => [TriggerType.click];

  /// Creates a [FloatingActionButtonProperties] with the given data.
  FloatingActionButtonProperties({
    this.backgroundColor = ColorRGBA.black,
    this.foregroundColor = ColorRGBA.white,
    this.elevation = 0,
    this.focusElevation = 0,
    this.hoverElevation = 0,
    this.highlightElevation = 0,
    this.extendedIconLabelSpacing = 0,
    this.icon = const MultiSourceIconModel(),
    this.type = FloatingActionButtonType.regular,
    this.location = FABLocation.endFloat,
    this.label = '',
    TextProp? labelStyle,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    CShapeBorder shape = CShapeBorder.circle,
    CornerRadius cornerRadius = CornerRadius.zero,
    ColorRGBA? borderColor,
    double? borderWidth,
    List<Reaction>? reactions,
  }) : labelStyle = labelStyle ?? TextProp.general(fontSize: 14) {
    setShapeBorderMixin(
      shape: shape,
      cornerRadius: cornerRadius,
      borderWidth: borderWidth,
      borderColor: borderColor,
    );

    setReactionMixin(reactions ?? []);
  }

  /// Duplicate the current [FloatingActionButtonProperties] with the given data
  /// overrides.
  FloatingActionButtonProperties copyWith({
    ColorRGBA? backgroundColor,
    ColorRGBA? foregroundColor,
    double? elevation,
    double? focusElevation,
    double? hoverElevation,
    double? highlightElevation,
    MultiSourceIconModel? icon,
    FloatingActionButtonType? type,
    String? label,
    TextProp? labelStyle,
    ColorRGBA? focusColor,
    ColorRGBA? hoverColor,
    ColorRGBA? splashColor,
    CShapeBorder? shape,
    CornerRadius? cornerRadius,
    ColorRGBA? borderColor,
    double? borderWidth,
    double? extendedIconLabelSpacing,
  }) =>
      FloatingActionButtonProperties(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
        elevation: elevation ?? this.elevation,
        focusElevation: focusElevation ?? this.focusElevation,
        hoverElevation: hoverElevation ?? this.hoverElevation,
        highlightElevation: highlightElevation ?? this.highlightElevation,
        type: type ?? this.type,
        icon: icon ?? this.icon,
        label: label ?? this.label,
        labelStyle: labelStyle ?? this.labelStyle,
        focusColor: focusColor ?? this.focusColor,
        hoverColor: hoverColor ?? this.hoverColor,
        splashColor: splashColor ?? this.splashColor,
        shape: shape ?? this.shape,
        cornerRadius: cornerRadius ?? this.cornerRadius,
        borderColor: borderColor ?? this.borderColor,
        borderWidth: borderWidth ?? this.borderWidth,
        extendedIconLabelSpacing:
            extendedIconLabelSpacing ?? this.extendedIconLabelSpacing,
      );

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'backgroundColor': ColorFieldAccess<ColorRGBA>(
          'Background Color',
          'Background color of the FAB',
          () => backgroundColor,
          (value) => backgroundColor = value,
        ),
        'foregroundColor': ColorFieldAccess<ColorRGBA>(
          'Foreground Color',
          'Color of the FAB\'s icon/text',
          () => foregroundColor,
          (value) => foregroundColor = value,
        ),
        'elevation': NumFieldAccess<double>(
          'Elevation',
          'Elevation of the FAB',
          () => elevation,
          (value) => elevation = value,
        ),
        'focusElevation': NumFieldAccess<double>(
          'Focus Elevation',
          'Elevation of the FAB when it is focused',
          () => focusElevation,
          (value) => focusElevation = value,
        ),
        'hoverElevation': NumFieldAccess<double>(
          'Hover Elevation',
          'Elevation of the FAB when it is hovered',
          () => hoverElevation,
          (value) => hoverElevation = value,
        ),
        'highlightElevation': NumFieldAccess<double>(
          'Highlight Elevation',
          'Elevation of the FAB when it is highlighted',
          () => highlightElevation,
          (value) => highlightElevation = value,
        ),
        'type': EnumFieldAccess<FloatingActionButtonType>(
          'Type',
          'Type of the FAB',
          () => type,
          (value) => type = value,
          defaultValue: () => FloatingActionButtonType.regular,
          options: () => FloatingActionButtonType.values,
          requiresLayout: true,
        ),
        'location': EnumFieldAccess<FABLocation>(
          'Location',
          'Where to place the FAB on the screen',
          () => location,
          (value) => location = value,
          defaultValue: () => FABLocation.endFloat,
          options: () => FABLocation.values,
          requiresLayout: true,
        ),
        'icon': IconFieldAccess<MultiSourceIconModel>(
          'Icon',
          'Icon of the FAB',
          () => icon,
          (value) => icon = value,
          requiresLayout: true,
        ),
        'label': StringFieldAccess(
          'Label',
          'Label of the FAB in case of extended type',
          () => label,
          (value) => label = value,
          requiresLayout: true,
        ),
        'labelStyle': TextStyleFieldAccess(
          'Label Style',
          'Style of the label',
          () => labelStyle,
          (value) => labelStyle = value,
          requiresLayout: true,
        ),
        'focusColor': ColorFieldAccess<ColorRGBA?>(
          'Focus Color',
          'Color of the FAB when it is focused',
          () => focusColor,
          (value) => focusColor = value,
        ),
        'hoverColor': ColorFieldAccess<ColorRGBA?>(
          'Hover Color',
          'Color of the FAB when it is hovered',
          () => hoverColor,
          (value) => hoverColor = value,
        ),
        'splashColor': ColorFieldAccess<ColorRGBA?>(
          'Splash Color',
          'Material splash color of the FAB',
          () => splashColor,
          (value) => splashColor = value,
        ),
        'extendedIconLabelSpacing': NumFieldAccess<double>(
          'Extended Icon Label Spacing',
          'Space between the icon and label for extended type',
          () => extendedIconLabelSpacing,
          (value) => extendedIconLabelSpacing = value,
          requiresLayout: true,
        ),
        ...generateShapeBorderMixinFields(),
      };

  @override
  List<Object?> get props => [
        backgroundColor,
        foregroundColor,
        elevation,
        focusElevation,
        hoverElevation,
        highlightElevation,
        type,
        label,
        icon,
        labelStyle,
        focusColor,
        hoverColor,
        splashColor,
        shape,
        cornerRadius,
        borderColor,
        borderWidth,
        extendedIconLabelSpacing,
      ];

  /// Creates a [FloatingActionButtonProperties] from a JSON data.
  factory FloatingActionButtonProperties.fromJson(Map json) =>
      _$FloatingActionButtonPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FloatingActionButtonPropertiesToJson(this);
}
