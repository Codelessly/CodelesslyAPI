import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

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
  List<TriggerType> get triggerTypes => [TriggerType.click];

  /// Creates a [RadioNode] instance from a JSON object.
  factory RadioNode.fromJson(Map json) => _$RadioNodeFromJson(json);

  @override
  Map toJson() => _$RadioNodeToJson(this);

  @override
  double get scale => basicBoxLocal.width / kRadioDefaultSize;
}

/// Holds configurable properties of the radio.
@JsonSerializable()
class RadioProperties extends CustomProperties {
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

  /// Creates a [RadioProperties] instance with the given data.
  RadioProperties({
    this.activeColor = ColorRGBA.black,
    this.inactiveColor = ColorRGBA.grey,
    this.hoverColor = ColorRGBA.grey10,
    this.focusColor = ColorRGBA.grey10,
    this.splashRadius = kRadialReactionRadius,
    this.autofocus = false,
    this.toggleable = false,
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
  }) {
    return RadioProperties(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      splashRadius: splashRadius ?? this.splashRadius,
      autofocus: autofocus ?? this.autofocus,
      toggleable: toggleable ?? this.toggleable,
    );
  }

  @override
  List<Object?> get props => [
        activeColor,
        inactiveColor,
        hoverColor,
        focusColor,
        splashRadius,
        autofocus,
        toggleable,
      ];

  /// Creates a [RadioProperties] instance from a JSON object.
  factory RadioProperties.fromJson(Map json) => _$RadioPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RadioPropertiesToJson(this);
}
