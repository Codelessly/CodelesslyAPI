// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

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
  SwitchProperties properties;

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
  });

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
class SwitchProperties with SerializableMixin, EquatableMixin {
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
  Map toJson() => _$SwitchPropertiesToJson(this);
}
