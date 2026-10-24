import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'radio_node.g.dart';

/// Default size of radio.
const double kRadioDefaultSize = 32;

/// Radio is a widget that lets the user choose an option from a group of
/// options. Unlike a checkbox that lets the user select multiple options, radio
/// restricts the user to select only a single option.
/// Refer to [Radio](https://api.flutter.dev/flutter/material/Radio-class.html)
/// in Flutter for more details.
@JsonSerializable()
class RadioNode extends SceneNode with CustomPropertiesMixin, ScalableMixin {
  @override
  final String type = 'radio';

  /// Holds configurable properties of the radio.
  @override
  covariant RadioProperties properties;

  @override
  double get defaultWidth => kRadioDefaultSize;

  @override
  double get defaultHeight => kRadioDefaultSize;

  /// Value of the radio button (an option in the radio group).
  String value = '';

  /// Currently selected option in the radio group.
  ///
  /// Radios that share a group value form a group. Render them under a
  /// Flutter `RadioGroup` with this value; `Radio.groupValue` and
  /// `Radio.onChanged` are deprecated.
  String? groupValue;

  /// Creates a mock radio preview.
  RadioNode.empty()
    : properties = RadioProperties(),
      super(
        id: 'radio',
        name: 'Radio',
        basicBoxLocal: NodeBox(0, 0, kRadioDefaultSize, kRadioDefaultSize),
      );

  /// Creates a radio node from properties.
  RadioNode.fromProperties(this.properties)
    : super(
        id: 'radio',
        name: 'Radio',
        basicBoxLocal: NodeBox(0, 0, kRadioDefaultSize, kRadioDefaultSize),
      );

  /// Creates a [RadioNode] instance with the given data.
  RadioNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    this.value = '',
    this.groupValue,
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
    super.parentID,
    super.positioningMode,
    super.constraints,
    super.edgePins,
    required this.properties,
    super.variables,
  });

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<RadioProperties>(
      'Properties',
      'Properties of radio button.',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
  ];

  /// Creates a [RadioNode] instance from a JSON object.
  factory RadioNode.fromJson(Map json) => _$RadioNodeFromJson(json);

  @override
  Map toJson() => _$RadioNodeOmitDefaults(this, _$RadioNodeToJson(this));

  @override
  double get scale => basicBoxLocal.width / kRadioDefaultSize;
}

/// Holds configurable properties of the radio.
@JsonSerializable()
class RadioProperties extends CustomProperties with FieldsHolder {
  /// Color of radio when it is active.
  late ColorRGBA activeColor;

  /// Color of radio when it is inactive.
  late ColorRGBA inactiveColor;

  /// Color of radio when it is hovered.
  late ColorRGBA hoverColor;

  /// Color of radio when it is focused.
  late ColorRGBA focusColor;

  /// Splash radius of the circular ink response.
  late double splashRadius;

  /// Whether to focus the radio automatically.
  late bool autofocus;

  /// Whether the button's value can be toggled on tap.
  late bool toggleable;

  /// Outline of the radio's circle. When null, Flutter draws it in the fill
  /// color. Mirrors `Radio.side`.
  BorderSideModel? side;

  /// Radius of the dot shown when selected. When null, Flutter uses 4.5.
  /// Mirrors `Radio.innerRadius`.
  double? innerRadius;

  /// Color inside the radio's circle. Mirrors `Radio.backgroundColor`.
  ColorRGBA? backgroundColor;

  /// Creates a [RadioProperties] instance with the given data.
  RadioProperties({
    this.activeColor = ColorRGBA.black,
    this.inactiveColor = ColorRGBA.grey,
    this.hoverColor = ColorRGBA.grey10,
    this.focusColor = ColorRGBA.grey10,
    this.splashRadius = kRadialReactionRadius,
    this.autofocus = false,
    this.toggleable = false,
    this.side,
    this.innerRadius,
    this.backgroundColor,
  });

  /// Duplicates this [RadioProperties] instance with the given data overrides.
  RadioProperties copyWith({
    ColorRGBA? activeColor,
    ColorRGBA? inactiveColor,
    ColorRGBA? hoverColor,
    ColorRGBA? focusColor,
    double? splashRadius,
    bool? autofocus,
    bool? toggleable,
    BorderSideModel? side,
    double? innerRadius,
    ColorRGBA? backgroundColor,
  }) {
    return RadioProperties(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      splashRadius: splashRadius ?? this.splashRadius,
      autofocus: autofocus ?? this.autofocus,
      toggleable: toggleable ?? this.toggleable,
      side: side ?? this.side,
      innerRadius: innerRadius ?? this.innerRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'activeColor': ColorFieldAccess<ColorRGBA>(
      'Active Color',
      'Color of radio when it is active.',
      () => activeColor,
      (ColorRGBA? value) {
        if (value != null) activeColor = value;
      },
    ),
    'inactiveColor': ColorFieldAccess<ColorRGBA>(
      'Inactive Color',
      'Color of radio when it is inactive.',
      () => inactiveColor,
      (ColorRGBA? value) {
        if (value != null) inactiveColor = value;
      },
    ),
    'hoverColor': ColorFieldAccess<ColorRGBA>(
      'Hover Color',
      'Color of radio when it is hovered.',
      () => hoverColor,
      (ColorRGBA? value) {
        if (value != null) hoverColor = value;
      },
    ),
    'focusColor': ColorFieldAccess<ColorRGBA>(
      'Focus Color',
      'Color of radio when it is focused.',
      () => focusColor,
      (ColorRGBA? value) {
        if (value != null) focusColor = value;
      },
    ),
    'splashRadius': NumFieldAccess<double>(
      'Splash Radius',
      'Splash radius of the circular ink response.',
      () => splashRadius,
      (double value) => splashRadius = value,
    ),
    'autofocus': BoolFieldAccess(
      'Autofocus',
      'Whether to focus the radio automatically.',
      () => autofocus,
      (bool? value) {
        if (value != null) autofocus = value;
      },
    ),
    'toggleable': BoolFieldAccess(
      'Toggleable',
      'Whether the button\'s value can be toggled on tap.',
      () => toggleable,
      (bool? value) {
        if (value != null) toggleable = value;
      },
    ),
    'innerRadius': NumFieldAccess<double?>(
      'Inner Radius',
      'Radius of the dot shown when selected.',
      () => innerRadius,
      (value) => innerRadius = value,
    ),
    'backgroundColor': ColorFieldAccess<ColorRGBA?>(
      'Background Color',
      'Color inside the radio\'s circle.',
      () => backgroundColor,
      (value) => backgroundColor = value,
    ),
  };

  @override
  List<Object?> get props => [
    activeColor,
    inactiveColor,
    hoverColor,
    focusColor,
    splashRadius,
    autofocus,
    toggleable,
    side,
    innerRadius,
    backgroundColor,
  ];

  /// Creates a [RadioProperties] instance from a JSON object.
  factory RadioProperties.fromJson(Map json) => _$RadioPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$RadioPropertiesOmitDefaults(this, _$RadioPropertiesToJson(this));
}
