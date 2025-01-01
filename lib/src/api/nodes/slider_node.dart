import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'slider_node.g.dart';

/// Default width of the slider.
const double kSliderDefaultWidth = 300;

/// Default height of the slider.
const double kSliderDefaultHeight = 48;

/// Default height of slider's track.
const double kSliderDefaultTrackHeight = 4;

/// Default radius of slider's tick mark.
const double kSliderDefaultTickMarkRadius = 1;

/// Default radius of slider's thumb.
const double kSliderDefaultThumbRadius = 10;

/// Default radius of slider's overlay.
const double kSliderDefaultOverlayRadius = 24;

/// Default label of slider.
const String kSliderDefaultLabel = r'${value}';

/// Default color of slider's track when it is inactive.
const ColorRGBA kSliderDefaultInactiveTrackColor =
    ColorRGBA(r: 0.5, g: 0.5, b: 0.5, a: kSliderDefaultOverlayOpacity);

/// Default opacity of slider's overlay.
const double kSliderDefaultOverlayOpacity = 0.12;

/// Slider is a widget that lets the user select a value from a given range.
/// Refer to [Slider](https://api.flutter.dev/flutter/material/Slider-class.html)
/// in Flutter for more details.
@JsonSerializable()
class SliderNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'slider';

  /// Currently selected value of slider.
  double value;

  /// Holds configurable properties of the slider.
  @override
  covariant SliderProperties properties;

  /// Creates a mock slider preview.
  SliderNode.empty()
      : properties = SliderProperties(),
        value = 0,
        super(
          id: 'slider',
          name: 'Slider',
          basicBoxLocal:
              NodeBox(0, 0, kSliderDefaultWidth, kSliderDefaultHeight),
        );

  /// Creates a slider from the given properties.
  SliderNode.fromProperties(this.properties)
      : value = 0,
        super(
          id: 'slider',
          name: 'Slider',
          basicBoxLocal:
              NodeBox(0, 0, kSliderDefaultWidth, kSliderDefaultHeight),
        );

  /// Creates a [SliderNode] instance with the given data.
  SliderNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required this.value,
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
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<SliderProperties>(
          'Properties',
          'Holds configurable properties of the slider.',
          () => properties,
          (value) => properties = value,
        ),
      };

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    DoubleValue(name: 'value', value: value),
  ];

  /// Creates a [SliderNode] instance from a JSON object.
  factory SliderNode.fromJson(Map json) => _$SliderNodeFromJson(json);

  @override
  Map toJson() => _$SliderNodeToJson(this);
}

/// Holds configurable properties of the slider.
@JsonSerializable()
class SliderProperties extends CustomProperties with FieldsHolder {
  /// Color of slider's track when it's active.
  ColorRGBA activeTrackColor;

  /// Color of slider's track when it's inactive.
  ColorRGBA inactiveTrackColor;

  /// Color of slider's overlay.
  ColorRGBA overlayColor;

  /// Color of slider's thumb.
  ColorRGBA thumbColor;

  /// Whether to focus on slider automatically.
  bool autofocus;

  /// Number of divisions in slider.
  int? divisions;

  /// Minimum value of slider.
  double min;

  /// Maximum value of slider.
  double max;

  /// Height of slider's track.
  double trackHeight;

  /// Label shown above the slider.
  String label;

  /// Whether to add divisions to the slider.
  bool isDiscrete;

  /// Whether to show label above the slider.
  bool showLabel;

  /// Color of slider's tick mark when it's active.
  ColorRGBA activeTickMarkColor;

  /// Color of slider's tick mark when it's inactive.
  ColorRGBA inactiveTickMarkColor;

  /// Color of slider's value indicator.
  ColorRGBA valueIndicatorColor;

  /// Color of slider's value indicator's text.
  ColorRGBA valueIndicatorTextColor;

  /// Font size of slider's value indicator's text.
  double valueIndicatorFontSize;

  /// Whether to allow non-whole numbers as min or max values of slider.
  bool allowFractionalPoints;

  /// Radius of slider's thumb.
  double thumbRadius;

  /// Whether to show slider's thumb.
  bool showThumb;

  /// Shape of slider's track.
  SliderTrackShapeEnum trackShape;

  /// Radius of slider's tick mark.
  double tickMarkRadius;

  /// Shape of slider's value indicator.
  SliderValueIndicatorShape valueIndicatorShape;

  /// Radius of slider's overlay.
  double overlayRadius;

  /// Whether to retrieve the overlay color from slider's thumb.
  bool deriveOverlayColorFromThumb;

  /// Creates a [SliderProperties] instance with the given data.
  SliderProperties({
    this.activeTrackColor = ColorRGBA.black,
    this.inactiveTrackColor = kSliderDefaultInactiveTrackColor,
    this.thumbColor = ColorRGBA.black,
    this.overlayColor = const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.38),
    this.autofocus = false,
    this.divisions,
    this.min = 0,
    this.max = 100,
    this.trackHeight = kSliderDefaultTrackHeight,
    this.label = kSliderDefaultLabel,
    this.isDiscrete = false,
    this.showLabel = false,
    this.activeTickMarkColor = ColorRGBA.grey,
    this.inactiveTickMarkColor = ColorRGBA.grey,
    this.allowFractionalPoints = false,
    this.valueIndicatorColor = ColorRGBA.grey,
    this.valueIndicatorTextColor = ColorRGBA.white,
    this.valueIndicatorFontSize = 14,
    this.thumbRadius = kSliderDefaultThumbRadius,
    this.showThumb = true,
    this.trackShape = SliderTrackShapeEnum.roundedRectangle,
    this.tickMarkRadius = kSliderDefaultTickMarkRadius,
    this.valueIndicatorShape = SliderValueIndicatorShape.rectangle,
    this.overlayRadius = kSliderDefaultOverlayRadius,
    this.deriveOverlayColorFromThumb = true,
  });

  /// Duplicates this [SliderProperties] instance with the given data
  /// overrides.
  SliderProperties copyWith({
    ColorRGBA? activeTrackColor,
    ColorRGBA? inactiveTrackColor,
    ColorRGBA? thumbColor,
    ColorRGBA? overlayColor,
    bool? autofocus,
    int? divisions,
    double? min,
    double? max,
    double? trackHeight,
    String? label,
    bool? isDiscrete,
    bool? showLabel,
    ColorRGBA? activeTickMarkColor,
    ColorRGBA? inactiveTickMarkColor,
    bool? allowFractionalPoints,
    ColorRGBA? valueIndicatorColor,
    ColorRGBA? valueIndicatorTextColor,
    double? valueIndicatorFontSize,
    double? thumbRadius,
    bool? showThumb,
    SliderTrackShapeEnum? trackShape,
    double? tickMarkRadius,
    SliderValueIndicatorShape? valueIndicatorShape,
    double? overlayRadius,
    bool? deriveOverlayColorFromThumb,
  }) {
    return SliderProperties(
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      inactiveTrackColor: inactiveTrackColor ?? this.inactiveTrackColor,
      thumbColor: thumbColor ?? this.thumbColor,
      overlayColor: overlayColor ?? this.overlayColor,
      autofocus: autofocus ?? this.autofocus,
      divisions: divisions ?? this.divisions,
      min: min ?? this.min,
      max: max ?? this.max,
      trackHeight: trackHeight ?? this.trackHeight,
      label: label ?? this.label,
      isDiscrete: isDiscrete ?? this.isDiscrete,
      showLabel: showLabel ?? this.showLabel,
      activeTickMarkColor: activeTickMarkColor ?? this.activeTickMarkColor,
      inactiveTickMarkColor:
          inactiveTickMarkColor ?? this.inactiveTickMarkColor,
      allowFractionalPoints:
          allowFractionalPoints ?? this.allowFractionalPoints,
      valueIndicatorColor: valueIndicatorColor ?? this.valueIndicatorColor,
      valueIndicatorTextColor:
          valueIndicatorTextColor ?? this.valueIndicatorTextColor,
      valueIndicatorFontSize:
          valueIndicatorFontSize ?? this.valueIndicatorFontSize,
      thumbRadius: thumbRadius ?? this.thumbRadius,
      showThumb: showThumb ?? this.showThumb,
      trackShape: trackShape ?? this.trackShape,
      tickMarkRadius: tickMarkRadius ?? this.tickMarkRadius,
      valueIndicatorShape: valueIndicatorShape ?? this.valueIndicatorShape,
      overlayRadius: overlayRadius ?? this.overlayRadius,
      deriveOverlayColorFromThumb:
          deriveOverlayColorFromThumb ?? this.deriveOverlayColorFromThumb,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'activeTrackColor': ColorFieldAccess<ColorRGBA>(
          'Active Track Color',
          'Color of slider\'s track when it\'s active.',
          () => activeTrackColor,
          (value) {
            if (value != null) activeTrackColor = value;
          },
        ),
        'inactiveTrackColor': ColorFieldAccess<ColorRGBA>(
          'Inactive Track Color',
          'Color of slider\'s track when it\'s inactive.',
          () => inactiveTrackColor,
          (value) {
            if (value != null) inactiveTrackColor = value;
          },
        ),
        'thumbColor': ColorFieldAccess<ColorRGBA>(
          'Thumb Color',
          'Color of slider\'s thumb.',
          () => thumbColor,
          (value) {
            if (value != null) thumbColor = value;
          },
        ),
        'overlayColor': ColorFieldAccess<ColorRGBA>(
          'Overlay Color',
          'Color of slider\'s overlay.',
          () => overlayColor,
          (ColorRGBA? value) {
            if (value != null) overlayColor = value;
          },
        ),
        'autofocus': BoolFieldAccess(
          'Autofocus',
          'Whether to focus on slider automatically.',
          () => autofocus,
          (bool value) {
            autofocus = value;
          },
        ),
        'divisions': NumFieldAccess<int?>(
          'Divisions',
          'Number of divisions in slider.',
          () => divisions,
          (int? value) => divisions = value,
        ),
        'min': NumFieldAccess<double>(
          'Min',
          'Minimum value of slider.',
          () => min,
          (double value) => min = value,
        ),
        'max': NumFieldAccess<double>(
          'Max',
          'Maximum value of slider.',
          () => max,
          (double value) => max = value,
        ),
        'trackHeight': NumFieldAccess<double>(
          'Track Height',
          'Height of slider\'s track.',
          () => trackHeight,
          (double value) => trackHeight = value,
        ),
        'label': StringFieldAccess(
          'Label',
          'Label shown above the slider.',
          () => label,
          (String value) => label = value,
        ),
        'isDiscrete': BoolFieldAccess(
          'Is Discrete',
          'Whether to add divisions to the slider.',
          () => isDiscrete,
          (bool value) => isDiscrete = value,
        ),
        'showLabel': BoolFieldAccess(
          'Show Label',
          'Whether to show label above the slider.',
          () => showLabel,
          (bool value) => showLabel = value,
        ),
        'activeTickMarkColor': ColorFieldAccess<ColorRGBA>(
          'Active Tick Mark Color',
          'Color of slider\'s tick mark when it\'s active.',
          () => activeTickMarkColor,
          (ColorRGBA? value) {
            if (value != null) activeTickMarkColor = value;
          },
        ),
        'inactiveTickMarkColor': ColorFieldAccess<ColorRGBA>(
          'Inactive Tick Mark Color',
          'Color of slider\'s tick mark when it\'s inactive.',
          () => inactiveTickMarkColor,
          (ColorRGBA? value) {
            if (value != null) inactiveTickMarkColor = value;
          },
        ),
        'valueIndicatorColor': ColorFieldAccess<ColorRGBA>(
          'Value Indicator Color',
          'Color of slider\'s value indicator.',
          () => valueIndicatorColor,
          (ColorRGBA? value) {
            if (value != null) valueIndicatorColor = value;
          },
        ),
        'valueIndicatorTextColor': ColorFieldAccess<ColorRGBA>(
          'Value Indicator Text Color',
          'Color of slider\'s value indicator\'s text.',
          () => valueIndicatorTextColor,
          (ColorRGBA? value) {
            if (value != null) valueIndicatorTextColor = value;
          },
        ),
        'valueIndicatorFontSize': NumFieldAccess<double>(
          'Value Indicator Font Size',
          'Font size of slider\'s value indicator\'s text.',
          () => valueIndicatorFontSize,
          (double value) => valueIndicatorFontSize = value,
        ),
        'allowFractionalPoints': BoolFieldAccess(
          'Allow Fractional Points',
          'Whether to allow non-whole numbers as min or max values of slider.',
          () => allowFractionalPoints,
          (bool value) => allowFractionalPoints = value,
        ),
        'thumbRadius': NumFieldAccess<double>(
          'Thumb Radius',
          'Radius of slider\'s thumb.',
          () => thumbRadius,
          (double value) => thumbRadius = value,
        ),
        'showThumb': BoolFieldAccess(
          'Show Thumb',
          'Whether to show slider\'s thumb.',
          () => showThumb,
          (bool value) => showThumb = value,
        ),
        'trackShape': EnumFieldAccess<SliderTrackShapeEnum>(
          'Track Shape',
          'Shape of slider\'s track.',
          () => trackShape,
          (SliderTrackShapeEnum value) => trackShape = value,
          defaultValue: () => SliderTrackShapeEnum.roundedRectangle,
          options: () => SliderTrackShapeEnum.values,
        ),
        'tickMarkRadius': NumFieldAccess<double>(
          'Tick Mark Radius',
          'Radius of slider\'s tick mark.',
          () => tickMarkRadius,
          (double value) => tickMarkRadius = value,
        ),
        'valueIndicatorShape': EnumFieldAccess<SliderValueIndicatorShape>(
          'Value Indicator Shape',
          'Shape of slider\'s value indicator.',
          () => valueIndicatorShape,
          (SliderValueIndicatorShape value) => valueIndicatorShape = value,
          defaultValue: () => SliderValueIndicatorShape.rectangle,
          options: () => SliderValueIndicatorShape.values,
        ),
        'overlayRadius': NumFieldAccess<double>(
          'Overlay Radius',
          'Radius of slider\'s overlay.',
          () => overlayRadius,
          (double value) => overlayRadius = value,
        ),
        'deriveOverlayColorFromThumb': BoolFieldAccess(
          'Derive Overlay Color From Thumb',
          'Whether to retrieve the overlay color from slider\'s thumb.',
          () => deriveOverlayColorFromThumb,
          (bool value) => deriveOverlayColorFromThumb = value,
        ),
      };

  @override
  List<Object?> get props => [
        activeTrackColor,
        inactiveTrackColor,
        thumbColor,
        overlayColor,
        autofocus,
        divisions,
        min,
        max,
        trackHeight,
        label,
        isDiscrete,
        showLabel,
        activeTickMarkColor,
        inactiveTickMarkColor,
        allowFractionalPoints,
        valueIndicatorColor,
        valueIndicatorTextColor,
        valueIndicatorFontSize,
        thumbRadius,
        showThumb,
        trackShape,
        tickMarkRadius,
        valueIndicatorShape,
        overlayRadius,
        deriveOverlayColorFromThumb,
      ];

  /// Creates a [SliderProperties] instance from a JSON object.
  factory SliderProperties.fromJson(Map json) =>
      _$SliderPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SliderPropertiesToJson(this);
}
