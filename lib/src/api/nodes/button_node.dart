import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';

import '../extensions.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'button_node.g.dart';

/// The default button padding used to convert nodes into Flutter buttons.
const EdgeInsetsModel defaultButtonPadding = EdgeInsetsModel.symmetric(
  horizontal: 24,
  vertical: 10,
);

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
  icon,

  /// Filled buttons have the most visual impact after the FAB and are used
  /// for important, final actions. Mirrors Flutter's `FilledButton`.
  filled,

  /// Filled tonal buttons are a middle ground between filled and outlined
  /// buttons. Mirrors Flutter's `FilledButton.tonal`.
  filledTonal;

  /// Whether this button type is icon.
  bool get isIconButton => this == ButtonTypeEnum.icon;

  /// Whether this button type is elevated.
  bool get isElevatedButton => this == ButtonTypeEnum.elevated;

  /// Whether this button type is text.
  bool get isTextButton => this == ButtonTypeEnum.text;

  /// Whether this button type is outlined.
  bool get isOutlinedButton => this == ButtonTypeEnum.outlined;

  /// Whether this button type is filled or filled tonal.
  bool get isFilledButton =>
      this == ButtonTypeEnum.filled || this == ButtonTypeEnum.filledTonal;

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
      case ButtonTypeEnum.filled:
        return 'Filled Button';
      case ButtonTypeEnum.filledTonal:
        return 'Filled Tonal Button';
    }
  }
}

/// A material button.
/// Refer to [Material 2 Buttons](https://m2.material.io/components/buttons) for
/// more details.
@JsonSerializable(constructor: '_forJson')
abstract class ButtonNode extends SceneNode with CustomPropertiesMixin {
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get type;

  ButtonTypeEnum get buttonType;

  @JsonKey(name: 'type', includeToJson: false)
  String get wireType => type;

  void validateButtonType() {
    if (properties.buttonType != buttonType) {
      throw ArgumentError.value(
        properties.buttonType,
        'properties.buttonType',
        'Expected $buttonType for $type',
      );
    }
  }

  @override
  final bool supportsPadding = true;

  /// Holds configurable properties of this button.
  @override
  covariant ButtonProperties properties;

  /// Strictly used for previews. e.g in components panel.
  ButtonNode.empty(ButtonTypeEnum kind)
    : properties = ButtonProperties(buttonType: kind),
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

  /// Icon behavior follows the Flutter class, never the visual shape.
  bool get behavesLikeAnIconButton => type == 'iconButton';

  @override
  EdgeInsetsModel? preferredDefaultPadding() {
    if (behavesLikeAnIconButton) {
      return const EdgeInsetsModel.all(16);
    } else {
      return defaultButtonPadding;
    }
  }

  /// Constructor selected by json_serializable to instantiate the wire subtype.
  factory ButtonNode._forJson({
    required String id,
    required String name,
    required NodeBox basicBoxLocal,
    required ButtonProperties properties,
    @JsonKey(name: 'type') required String wireType,
    bool visible = true,
    bool enabled = true,
    AlignmentModel alignment = AlignmentModel.none,
    EdgeInsetsModel padding = EdgeInsetsModel.zero,
    EdgeInsetsModel margin = EdgeInsetsModel.zero,
    int rotationDegrees = 0,
    List<Reaction> reactions = const [],
    SizeFit horizontalFit = SizeFit.fixed,
    SizeFit verticalFit = SizeFit.fixed,
    int flex = 1,
    BoxConstraintsModel constraints = const BoxConstraintsModel(),
    bool aspectRatioLock = false,
    EdgePinsModel edgePins = EdgePinsModel.standard,
    PositioningMode positioningMode = PositioningMode.align,
    Map<String, String> variables = const {},
    Map<String, List<String>> multipleVariables = const {},
  }) => _buttonNodeForJson(
    id: id,
    name: name,
    basicBoxLocal: basicBoxLocal,
    properties: properties,
    wireType: wireType,
    visible: visible,
    enabled: enabled,
    alignment: alignment,
    padding: padding,
    margin: margin,
    rotationDegrees: rotationDegrees,
    reactions: reactions,
    horizontalFit: horizontalFit,
    verticalFit: verticalFit,
    flex: flex,
    constraints: constraints,
    aspectRatioLock: aspectRatioLock,
    edgePins: edgePins,
    positioningMode: positioningMode,
    variables: variables,
    multipleVariables: multipleVariables,
  );

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
  }) {
    validateButtonType();
  }

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
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.longPress,
    TriggerType.doubleTap,
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
  ];

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
  factory ButtonNode.fromJson(Map json) {
    final kind = switch (json['type']) {
      'elevatedButton' => ButtonTypeEnum.elevated,
      'textButton' => ButtonTypeEnum.text,
      'outlinedButton' => ButtonTypeEnum.outlined,
      'iconButton' => ButtonTypeEnum.icon,
      'filledButton' => ButtonTypeEnum.filled,
      _ => throw FormatException('Unknown button wire type: ${json['type']}'),
    };
    final rawProperties = json['properties'];
    if (rawProperties is! Map)
      throw const FormatException('Missing button properties');
    if (rawProperties.containsKey('buttonType')) {
      throw const FormatException(
        'Legacy properties.buttonType is not supported',
      );
    }
    if (kind == ButtonTypeEnum.filled) {
      if (rawProperties['variant'] != 'filled' &&
          rawProperties['variant'] != 'tonal') {
        throw const FormatException(
          'Filled button requires variant filled or tonal',
        );
      }
    } else if (rawProperties.containsKey('variant')) {
      throw FormatException('Unexpected variant for ${json['type']}');
    }
    return _$ButtonNodeFromJson(json);
  }

  @override
  Map toJson() {
    validateButtonType();
    final json = _$ButtonNodeOmitDefaults(this, _$ButtonNodeToJson(this));
    if (type == 'filledButton') {
      (json['properties'] as Map)['variant'] =
          properties.buttonType == ButtonTypeEnum.filledTonal
          ? 'tonal'
          : 'filled';
    }
    json['type'] = type;
    return json;
  }

  @override
  void updateVariableName({required String oldName, required String newName}) {
    super.updateVariableName(oldName: oldName, newName: newName);
    if (properties.label.isEmpty) return;
    properties.label = properties.label.replaceVariableName(oldName, newName);
  }
}

ButtonNode _buttonNodeForJson({
  required String id,
  required String name,
  required NodeBox basicBoxLocal,
  bool visible = true,
  bool enabled = true,
  AlignmentModel alignment = AlignmentModel.none,
  EdgeInsetsModel padding = EdgeInsetsModel.zero,
  EdgeInsetsModel margin = EdgeInsetsModel.zero,
  int rotationDegrees = 0,
  List<Reaction> reactions = const [],
  SizeFit horizontalFit = SizeFit.fixed,
  SizeFit verticalFit = SizeFit.fixed,
  int flex = 1,
  BoxConstraintsModel constraints = const BoxConstraintsModel(),
  bool aspectRatioLock = false,
  EdgePinsModel edgePins = EdgePinsModel.standard,
  PositioningMode positioningMode = PositioningMode.align,
  required ButtonProperties properties,
  required String wireType,
  Map<String, String> variables = const {},
  Map<String, List<String>> multipleVariables = const {},
}) {
  final kind = switch (wireType) {
    'elevatedButton' => ButtonTypeEnum.elevated,
    'textButton' => ButtonTypeEnum.text,
    'outlinedButton' => ButtonTypeEnum.outlined,
    'iconButton' => ButtonTypeEnum.icon,
    'filledButton' =>
      properties.buttonType == ButtonTypeEnum.filledTonal
          ? ButtonTypeEnum.filledTonal
          : ButtonTypeEnum.filled,
    _ => throw FormatException('Unknown button wire type: $wireType'),
  };
  properties.buttonType = kind;
  final constructor = switch (kind) {
    ButtonTypeEnum.elevated => ElevatedButtonNode.new,
    ButtonTypeEnum.text => TextButtonNode.new,
    ButtonTypeEnum.outlined => OutlinedButtonNode.new,
    ButtonTypeEnum.icon => IconButtonNode.new,
    ButtonTypeEnum.filled || ButtonTypeEnum.filledTonal => FilledButtonNode.new,
  };
  return constructor(
    id: id,
    name: name,
    basicBoxLocal: basicBoxLocal,
    properties: properties,
    visible: visible,
    enabled: enabled,
    alignment: alignment,
    padding: padding,
    margin: margin,
    rotationDegrees: rotationDegrees,
    reactions: reactions,
    horizontalFit: horizontalFit,
    verticalFit: verticalFit,
    flex: flex,
    constraints: constraints,
    aspectRatioLock: aspectRatioLock,
    edgePins: edgePins,
    positioningMode: positioningMode,
    variables: variables,
    multipleVariables: multipleVariables,
  );
}

@FlutterNode('ElevatedButton', family: 'material', nodeType: 'elevatedButton')
class ElevatedButtonNode extends ButtonNode {
  @override
  String get type => 'elevatedButton';
  @override
  ButtonTypeEnum get buttonType => ButtonTypeEnum.elevated;
  ElevatedButtonNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required super.properties,
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
    super.positioningMode,
    super.variables,
    super.multipleVariables,
  });
  ElevatedButtonNode.empty() : super.empty(ButtonTypeEnum.elevated);
  factory ElevatedButtonNode.fromJson(Map json) =>
      _decodeButton<ElevatedButtonNode>(json, 'elevatedButton');
}

@FlutterNode('TextButton', family: 'material', nodeType: 'textButton')
class TextButtonNode extends ButtonNode {
  @override
  String get type => 'textButton';
  @override
  ButtonTypeEnum get buttonType => ButtonTypeEnum.text;
  TextButtonNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required super.properties,
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
    super.positioningMode,
    super.variables,
    super.multipleVariables,
  });
  TextButtonNode.empty() : super.empty(ButtonTypeEnum.text);
  factory TextButtonNode.fromJson(Map json) =>
      _decodeButton<TextButtonNode>(json, 'textButton');
}

@FlutterNode('OutlinedButton', family: 'material', nodeType: 'outlinedButton')
class OutlinedButtonNode extends ButtonNode {
  @override
  String get type => 'outlinedButton';
  @override
  ButtonTypeEnum get buttonType => ButtonTypeEnum.outlined;
  OutlinedButtonNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required super.properties,
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
    super.positioningMode,
    super.variables,
    super.multipleVariables,
  });
  OutlinedButtonNode.empty() : super.empty(ButtonTypeEnum.outlined);
  factory OutlinedButtonNode.fromJson(Map json) =>
      _decodeButton<OutlinedButtonNode>(json, 'outlinedButton');
}

@FlutterNode('IconButton', family: 'material', nodeType: 'iconButton')
class IconButtonNode extends ButtonNode {
  @override
  String get type => 'iconButton';
  @override
  ButtonTypeEnum get buttonType => ButtonTypeEnum.icon;
  IconButtonNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required super.properties,
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
    super.positioningMode,
    super.variables,
    super.multipleVariables,
  });
  IconButtonNode.empty() : super.empty(ButtonTypeEnum.icon);
  factory IconButtonNode.fromJson(Map json) =>
      _decodeButton<IconButtonNode>(json, 'iconButton');
}

@FlutterNode('FilledButton', family: 'material', nodeType: 'filledButton')
class FilledButtonNode extends ButtonNode {
  @override
  String get type => 'filledButton';
  @override
  ButtonTypeEnum get buttonType => ButtonTypeEnum.filled;
  @override
  void validateButtonType() {
    if (!properties.buttonType.isFilledButton) {
      throw ArgumentError.value(
        properties.buttonType,
        'properties.buttonType',
        'Expected filled or filledTonal',
      );
    }
  }

  FilledButtonNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required super.properties,
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
    super.positioningMode,
    super.variables,
    super.multipleVariables,
  });
  FilledButtonNode.empty() : super.empty(ButtonTypeEnum.filled);
  FilledButtonNode.tonal({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
  }) : super(
         properties: ButtonProperties(buttonType: ButtonTypeEnum.filledTonal),
       );
  factory FilledButtonNode.fromJson(Map json) =>
      _decodeButton<FilledButtonNode>(json, 'filledButton');
}

T _decodeButton<T extends ButtonNode>(Map json, String type) {
  if (json['type'] != type) throw FormatException('Expected $type');
  return ButtonNode.fromJson(json) as T;
}

/// Holds configurable properties of a [ButtonNode].
///
/// Flutter's `ButtonStyle.minimumSize` and `fixedSize` are not repeated here:
/// the node's box is the button's size.
@JsonSerializable()
class ButtonProperties extends CustomProperties
    with ShapeBorderMixin, FieldsHolder {
  // Designs saved before 5.0.0 omit this key and used the Material 2 default.
  @override
  @JsonKey(defaultValue: CShapeBorder.roundedRectangle)
  // ignore: overridden_fields
  late CShapeBorder shape;

  // Button properties.

  /// Runtime button kind; the wire uses the node type and filled variant.
  @JsonKey(includeFromJson: false, includeToJson: false)
  late ButtonTypeEnum buttonType;

  /// Background color of the button, or null for the button type's default
  /// (no fill for a text or outlined button).
  ///
  /// Designs saved before this was nullable omit black, then the default:
  /// a missing key reads as null, an explicit color (black too) as set.
  ColorRGBA? buttonColor;

  /// Elevation shadow color of the button.
  late ColorRGBA shadowColor;

  /// Elevation of the button.
  late double elevation;

  /// Whether the button is enabled.
  late bool enabled;

  // Label properties.

  /// Text to display in the button.
  @FlutterProp(
    'label',
    type: 'string',
    group: 'Content',
    control: 'text',
    field: 'properties.label',
    flutterParam: false,
    note: "label text rendered as the button's child Text",
  )
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
  @FlutterProp(
    'icon',
    type: 'object',
    group: 'Content',
    control: 'icon',
    field: 'properties.icon',
    required: true,
  )
  late MultiSourceIconModel icon;

  /// Creates a [ButtonProperties] with given data.
  ButtonProperties({
    this.buttonType = ButtonTypeEnum.elevated,
    this.buttonColor,
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
    CShapeBorder shape = CShapeBorder.stadium,
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
    'buttonColor': ColorFieldAccess<ColorRGBA?>(
      'Button Color',
      'Color of the button.',
      () => buttonColor,
      (ColorRGBA? value) => buttonColor = value,
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
    'labelStyle': TextStyleFieldAccess<TextProp>(
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
    'borderColor': ColorFieldAccess<ColorRGBA?>(
      'Border Color',
      'Color of the button\'s border.',
      () => borderColor,
      (ColorRGBA? value) => borderColor = value,
    ),
  };

  /// Creates a [ButtonProperties] from a JSON data.
  factory ButtonProperties.fromJson(Map json) {
    final properties = _$ButtonPropertiesFromJson(json);
    properties.buttonType = switch (json['variant']) {
      'tonal' => ButtonTypeEnum.filledTonal,
      'filled' => ButtonTypeEnum.filled,
      _ => ButtonTypeEnum.elevated,
    };
    return properties;
  }

  @override
  Map<String, dynamic> toJson() =>
      _$ButtonPropertiesOmitDefaults(this, _$ButtonPropertiesToJson(this));

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
