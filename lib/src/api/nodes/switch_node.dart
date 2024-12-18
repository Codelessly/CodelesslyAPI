import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'switch_node.g.dart';

/// Default height of the switch.
const double kSwitchDefaultHeight = 40;

/// Default width of the switch.
const double kSwitchDefaultWidth = 59;

/// Switch is a widget that lets the user toggle a single boolean value.
/// The value is true when the switch is on; and is false when the switch is
/// off.
/// Refer to [Switch](https://api.flutter.dev/flutter/material/Switch-class.html)
/// in Flutter for more details.
@JsonSerializable()
class SwitchNode extends SceneNode with CustomPropertiesMixin, ScalableMixin {
  @override
  final String type = 'switch';

  @override
  double get defaultWidth => kSwitchDefaultWidth;

  @override
  double get defaultHeight => kSwitchDefaultHeight;

  /// Current value of the switch.
  bool value = false;

  /// Holds configurable properties of the switch.
  @override
  covariant SwitchProperties properties;

  /// Creates a mock switch preview.
  SwitchNode.empty()
      : properties = SwitchProperties(),
        super(
          id: 'switch',
          name: 'Switch',
          basicBoxLocal:
              NodeBox(0, 0, kSwitchDefaultWidth, kSwitchDefaultHeight),
        );

  /// Creates a switch from the given properties.
  SwitchNode.fromProperties(this.properties)
      : super(
          id: 'switch',
          name: 'Switch',
          basicBoxLocal:
              NodeBox(0, 0, kSwitchDefaultWidth, kSwitchDefaultHeight),
        );

  /// Creates a [SwitchNode] instance with the given data.
  SwitchNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    this.value = false,
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
  }) {
    fields['properties'] = ObjectFieldAccess<SwitchProperties>(
      () => 'Properties',
      () => 'Holds configurable properties of the switch.',
      () => properties,
      (value) => properties = value,
    );
  }

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    BoolValue(name: 'value', value: value),
  ];

  /// Creates a [SwitchNode] instance from a JSON object.
  factory SwitchNode.fromJson(Map json) => _$SwitchNodeFromJson(json);

  @override
  Map toJson() => _$SwitchNodeToJson(this);

  @override
  double get scale => basicBoxLocal.width / kSwitchDefaultWidth;
}

/// Holds configurable properties of the switch.
@JsonSerializable()
class SwitchProperties extends CustomProperties with FieldsHolder {
  /// Color of switch's track when it's active.
  late ColorRGBA activeTrackColor;

  /// Color of switch's track when it's inactive.
  late ColorRGBA inactiveTrackColor;

  /// Color of switch's thumb when it's active.
  late ColorRGBA activeThumbColor;

  /// Color of switch's thumb when it's inactive.
  late ColorRGBA inactiveThumbColor;

  /// Color of switch when it is hovered.
  late ColorRGBA hoverColor;

  /// Color of switch when it is focused.
  late ColorRGBA focusColor;

  /// Splash radius of the circular ink response.
  late double splashRadius;

  /// Whether to focus on the switch automatically.
  late bool autofocus;

  /// Color of switch's track border when it's active.
  late ColorRGBA? activeTrackBorderColor;

  /// Color of switch's track border when it's inactive.
  late ColorRGBA? inactiveTrackBorderColor;

  /// Width of switch's track border.
  late double trackOutlineWidth;

  /// Whether to use material 3 style.
  late bool useMaterial3;

  /// Creates a [SwitchProperties] instance with the given data.
  SwitchProperties({
    this.activeTrackColor = ColorRGBA.black,
    this.inactiveTrackColor = ColorRGBA.grey,
    this.activeThumbColor = ColorRGBA.white,
    this.inactiveThumbColor = ColorRGBA.white,
    this.hoverColor = ColorRGBA.grey10,
    this.focusColor = ColorRGBA.grey10,
    this.splashRadius = kRadialReactionRadius,
    this.autofocus = false,
    this.activeTrackBorderColor = ColorRGBA.transparent,
    this.inactiveTrackBorderColor = ColorRGBA.transparent,
    this.trackOutlineWidth = 2,
    this.useMaterial3 = false,
  });

  /// Duplicates this [SwitchProperties] instance with the given data
  /// overrides.
  SwitchProperties copyWith({
    ColorRGBA? activeTrackColor,
    ColorRGBA? inactiveTrackColor,
    ColorRGBA? activeThumbColor,
    ColorRGBA? inactiveThumbColor,
    ColorRGBA? hoverColor,
    ColorRGBA? focusColor,
    double? splashRadius,
    bool? autofocus,
    ColorRGBA? activeTrackBorderColor,
    ColorRGBA? inactiveTrackBorderColor,
    bool forceActiveTrackBorderColor = false,
    bool forceInactiveTrackBorderColor = false,
    double? trackOutlineWidth,
    bool? useMaterial3,
  }) {
    return SwitchProperties(
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      inactiveTrackColor: inactiveTrackColor ?? this.inactiveTrackColor,
      activeThumbColor: activeThumbColor ?? this.activeThumbColor,
      inactiveThumbColor: inactiveThumbColor ?? this.inactiveThumbColor,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      splashRadius: splashRadius ?? this.splashRadius,
      autofocus: autofocus ?? this.autofocus,
      activeTrackBorderColor: forceActiveTrackBorderColor
          ? activeTrackBorderColor
          : activeTrackBorderColor ?? this.activeTrackBorderColor,
      inactiveTrackBorderColor: forceInactiveTrackBorderColor
          ? inactiveTrackBorderColor
          : inactiveTrackBorderColor ?? this.inactiveTrackBorderColor,
      trackOutlineWidth: trackOutlineWidth ?? this.trackOutlineWidth,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
    );
  }

  @override
  late final Map<String, FieldAccess<Object?>> fields = {
    'activeTrackColor': ColorFieldAccess<ColorRGBA>(
      () => 'Active Track Color',
      () => 'Color of switch\'s track when it\'s active.',
      () => activeTrackColor,
      (ColorRGBA? value) {
        if (value != null) activeTrackColor = value;
      },
    ),
    'inactiveTrackColor': ColorFieldAccess<ColorRGBA>(
      () => 'Inactive Track Color',
      () => 'Color of switch\'s track when it\'s inactive.',
      () => inactiveTrackColor,
      (ColorRGBA? value) {
        if (value != null) inactiveTrackColor = value;
      },
    ),
    'activeThumbColor': ColorFieldAccess<ColorRGBA>(
      () => 'Active Thumb Color',
      () => 'Color of switch\'s thumb when it\'s active.',
      () => activeThumbColor,
      (ColorRGBA? value) {
        if (value != null) activeThumbColor = value;
      },
    ),
    'inactiveThumbColor': ColorFieldAccess<ColorRGBA>(
      () => 'Inactive Thumb Color',
      () => 'Color of switch\'s thumb when it\'s inactive.',
      () => inactiveThumbColor,
      (ColorRGBA? value) {
        if (value != null) inactiveThumbColor = value;
      },
    ),
    'hoverColor': ColorFieldAccess<ColorRGBA>(
      () => 'Hover Color',
      () => 'Color of switch when it is hovered.',
      () => hoverColor,
      (ColorRGBA? value) {
        if (value != null) hoverColor = value;
      },
    ),
    'focusColor': ColorFieldAccess<ColorRGBA>(
      () => 'Focus Color',
      () => 'Color of switch when it is focused.',
      () => focusColor,
      (ColorRGBA? value) {
        if (value != null) focusColor = value;
      },
    ),
    'splashRadius': NumFieldAccess<double>(
      () => 'Splash Radius',
      () => 'Splash radius of the circular ink response.',
      () => splashRadius,
      (double? value) {
        if (value != null) splashRadius = value;
      },
    ),
    'autofocus': BoolFieldAccess(
      () => 'Autofocus',
      () => 'Whether to focus on the switch automatically.',
      () => autofocus,
      (bool? value) {
        if (value != null) autofocus = value;
      },
    ),
    'activeTrackBorderColor': ColorFieldAccess<ColorRGBA>(
      () => 'Active Track Border Color',
      () => 'Color of switch\'s track border when it\'s active.',
      () => activeTrackBorderColor,
      (ColorRGBA? value) {
        if (value != null) activeTrackBorderColor = value;
      },
    ),
    'inactiveTrackBorderColor': ColorFieldAccess<ColorRGBA>(
      () => 'Inactive Track Border Color',
      () => 'Color of switch\'s track border when it\'s inactive.',
      () => inactiveTrackBorderColor,
      (ColorRGBA? value) {
        if (value != null) inactiveTrackBorderColor = value;
      },
    ),
    'trackOutlineWidth': NumFieldAccess<double>(
      () => 'Track Outline Width',
      () => 'Width of switch\'s track border.',
      () => trackOutlineWidth,
      (double? value) {
        if (value != null) trackOutlineWidth = value;
      },
    ),
    'useMaterial3': BoolFieldAccess(
      () => 'Use Material 3',
      () => 'Whether to use material 3 style.',
      () => useMaterial3,
      (bool? value) {
        if (value != null) useMaterial3 = value;
      },
    ),
  };

  @override
  List<Object?> get props => [
        activeTrackColor,
        inactiveTrackColor,
        activeThumbColor,
        inactiveThumbColor,
        hoverColor,
        focusColor,
        splashRadius,
        autofocus,
        activeTrackBorderColor,
        inactiveTrackBorderColor,
        trackOutlineWidth,
        useMaterial3,
      ];

  /// Creates a [SwitchProperties] instance from a JSON object.
  factory SwitchProperties.fromJson(Map json) =>
      _$SwitchPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SwitchPropertiesToJson(this);
}
