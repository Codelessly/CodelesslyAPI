import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

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

/// Default width and height of a slider's rectangular thumb.
const double kSliderDefaultThumbSize = 20;

/// Default corner radius of a slider's rectangular thumb.
const double kSliderDefaultThumbCornerRadius = 4;

/// Default radius of slider's overlay.
const double kSliderDefaultOverlayRadius = 24;

/// Default label of slider.
const String kSliderDefaultLabel = r'${value}';

/// Default color of slider's track when it is inactive.
const ColorRGBA kSliderDefaultInactiveTrackColor = ColorRGBA(
  r: 0.5,
  g: 0.5,
  b: 0.5,
  a: kSliderDefaultOverlayOpacity,
);

/// Default opacity of slider's overlay.
const double kSliderDefaultOverlayOpacity = 0.12;

/// How a slider draws the marks at its divisions.
enum SliderTickMarkStyle {
  /// Dots on the track.
  dot,

  /// Short lines below the track, longer at every fifth mark.
  notch,
}

/// Slider is a widget that lets the user select a value from a given range.
/// Refer to [Slider](https://api.flutter.dev/flutter/material/Slider-class.html)
/// in Flutter for more details.
@FlutterNode('Slider', family: 'material', nodeType: 'slider')
@JsonSerializable()
class SliderNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'slider';

  /// Currently selected value of slider.
  @FlutterProp('value', type: 'number', group: 'State', control: 'number', required: true, bindable: true)
  double value;

  /// Where a thin marker sits on the track, e.g. the current reading next
  /// to an alarm limit the slider sets. No marker when null. Bindable as
  /// `markerValue`.
  double? markerValue;

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
        basicBoxLocal: NodeBox(0, 0, kSliderDefaultWidth, kSliderDefaultHeight),
      );

  /// Creates a slider from the given properties.
  SliderNode.fromProperties(this.properties)
    : value = 0,
      super(
        id: 'slider',
        name: 'Slider',
        basicBoxLocal: NodeBox(0, 0, kSliderDefaultWidth, kSliderDefaultHeight),
      );

  /// Creates a [SliderNode] instance with the given data.
  SliderNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required this.value,
    this.markerValue,
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
  List<TriggerType> get triggerTypes => [
    TriggerType.changed,
    TriggerType.doubleTap,
    TriggerType.changeEnd,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    DoubleValue(name: 'value', value: value),
    DoubleValue(name: 'min', value: properties.min),
    DoubleValue(name: 'max', value: properties.max),
    DoubleValue(name: 'markerValue', value: markerValue ?? 0),
    ColorValue(name: 'activeTrackColor', value: properties.activeTrackColor),
  ];

  /// Creates a [SliderNode] instance from a JSON object.
  factory SliderNode.fromJson(Map json) => _$SliderNodeFromJson(json);

  @override
  Map toJson() => _$SliderNodeOmitDefaults(this, _$SliderNodeToJson(this));
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
  @FlutterProp('autofocus', type: 'boolean', group: 'Interaction', control: 'switch', field: 'properties.autofocus')
  bool autofocus;

  /// Number of divisions in slider.
  @FlutterProp('divisions', type: 'integer', group: 'Appearance', control: 'number', field: 'properties.divisions')
  int? divisions;

  /// Minimum value of slider.
  @FlutterProp('min', type: 'number', group: 'Range', control: 'number', field: 'properties.min')
  double min;

  /// Maximum value of slider.
  @FlutterProp('max', type: 'number', group: 'Range', control: 'number', field: 'properties.max')
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

  /// Radius of slider's thumb when [thumbShape] is
  /// [SliderThumbShapeEnum.circle].
  double thumbRadius;

  /// Shape of slider's thumb: a circle of [thumbRadius], or a rounded
  /// rectangle of [thumbWidth] by [thumbHeight] with [thumbCornerRadius]
  /// corners.
  SliderThumbShapeEnum thumbShape;

  /// Width of a rectangular thumb as drawn on screen, across a vertical
  /// slider's track and along a horizontal one's.
  double thumbWidth;

  /// Height of a rectangular thumb as drawn on screen, along a vertical
  /// slider's track and across a horizontal one's.
  double thumbHeight;

  /// Corner radius of a rectangular thumb.
  double thumbCornerRadius;

  /// Whether to show slider's thumb.
  bool showThumb;

  /// Border color of a rectangular thumb, or null for no border.
  ColorRGBA? thumbBorderColor;

  /// Border width of a rectangular thumb.
  double thumbBorderWidth;

  /// Color of a vertical grip line in the middle of a rectangular thumb, or
  /// null for none.
  ColorRGBA? thumbGripColor;

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

  /// When to show the value indicator. When null, [showLabel] decides between
  /// [ShowValueIndicatorC.onDrag] and [ShowValueIndicatorC.never]. Mirrors
  /// `SliderThemeData.showValueIndicator`.
  ShowValueIndicatorC? showValueIndicator;

  /// Secondary progress shown between the thumb and the end of the track,
  /// such as a buffered amount. Mirrors `Slider.secondaryTrackValue`.
  double? secondaryTrackValue;

  /// Color of the track up to [secondaryTrackValue]. Mirrors
  /// `Slider.secondaryActiveColor`.
  ColorRGBA? secondaryActiveTrackColor;

  /// Padding around the slider's track and thumb. When null, Flutter reserves
  /// room for the thumb's overlay. Mirrors `Slider.padding`.
  EdgeInsetsModel? padding;

  /// Direction the slider runs in. A vertical slider runs from [min] at the
  /// bottom to [max] at the top (top to bottom when [inverted]); its node box
  /// is its full hit area.
  AxisC orientation;

  /// Whether the slider runs the other way: right to left when horizontal,
  /// top to bottom when vertical.
  bool inverted;

  /// Color of the stroke around the slider's thumb. No stroke when null or
  /// when [thumbStrokeWidth] is 0.
  ColorRGBA? thumbStrokeColor;

  /// Width of the stroke around the slider's thumb, drawn inside the thumb.
  double thumbStrokeWidth;

  /// Whether the active track runs from the thumb to the end instead of
  /// from the start to the thumb, e.g. to shade the "above the limit" zone.
  bool fillFromEnd;

  /// How division marks are drawn.
  SliderTickMarkStyle tickMarkStyle;

  /// Draw a notch only at every this many divisions, e.g. 2 for a notch
  /// every 10% on a slider that snaps every 5%. Every fifth notch drawn is a
  /// long one.
  int notchEvery;

  /// Color of the [SliderNode.markerValue] marker.
  ColorRGBA markerColor;

  /// Width of the marker.
  double markerWidth;

  /// Height of the marker, centered on the track.
  double markerHeight;

  /// The lowest value the thumb can be dragged to, when the track's range
  /// ([min] to [max]) is wider than what may be picked. Null for [min].
  double? selectableMin;

  /// The highest value the thumb can be dragged to. Null for [max].
  double? selectableMax;

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
    this.thumbShape = SliderThumbShapeEnum.circle,
    this.thumbWidth = kSliderDefaultThumbSize,
    this.thumbHeight = kSliderDefaultThumbSize,
    this.thumbCornerRadius = kSliderDefaultThumbCornerRadius,
    this.showThumb = true,
    this.thumbBorderColor,
    this.thumbBorderWidth = 2,
    this.thumbGripColor,
    this.trackShape = SliderTrackShapeEnum.roundedRectangle,
    this.tickMarkRadius = kSliderDefaultTickMarkRadius,
    this.valueIndicatorShape = SliderValueIndicatorShape.rectangle,
    this.overlayRadius = kSliderDefaultOverlayRadius,
    this.deriveOverlayColorFromThumb = true,
    this.showValueIndicator,
    this.secondaryTrackValue,
    this.secondaryActiveTrackColor,
    this.padding,
    this.orientation = AxisC.horizontal,
    this.inverted = false,
    this.thumbStrokeColor,
    this.thumbStrokeWidth = 0,
    this.fillFromEnd = false,
    this.tickMarkStyle = SliderTickMarkStyle.dot,
    this.notchEvery = 1,
    this.markerColor = ColorRGBA.white,
    this.markerWidth = 2,
    this.markerHeight = 14,
    this.selectableMin,
    this.selectableMax,
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
    SliderThumbShapeEnum? thumbShape,
    double? thumbWidth,
    double? thumbHeight,
    double? thumbCornerRadius,
    bool? showThumb,
    SliderTrackShapeEnum? trackShape,
    double? tickMarkRadius,
    SliderValueIndicatorShape? valueIndicatorShape,
    double? overlayRadius,
    bool? deriveOverlayColorFromThumb,
    ShowValueIndicatorC? showValueIndicator,
    double? secondaryTrackValue,
    ColorRGBA? secondaryActiveTrackColor,
    EdgeInsetsModel? padding,
    AxisC? orientation,
    bool? inverted,
    ColorRGBA? thumbStrokeColor,
    double? thumbStrokeWidth,
    ColorRGBA? thumbBorderColor,
    double? thumbBorderWidth,
    ColorRGBA? thumbGripColor,
    bool? fillFromEnd,
    SliderTickMarkStyle? tickMarkStyle,
    int? notchEvery,
    ColorRGBA? markerColor,
    double? markerWidth,
    double? markerHeight,
    double? selectableMin,
    double? selectableMax,
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
      thumbShape: thumbShape ?? this.thumbShape,
      thumbWidth: thumbWidth ?? this.thumbWidth,
      thumbHeight: thumbHeight ?? this.thumbHeight,
      thumbCornerRadius: thumbCornerRadius ?? this.thumbCornerRadius,
      showThumb: showThumb ?? this.showThumb,
      trackShape: trackShape ?? this.trackShape,
      tickMarkRadius: tickMarkRadius ?? this.tickMarkRadius,
      valueIndicatorShape: valueIndicatorShape ?? this.valueIndicatorShape,
      overlayRadius: overlayRadius ?? this.overlayRadius,
      deriveOverlayColorFromThumb:
          deriveOverlayColorFromThumb ?? this.deriveOverlayColorFromThumb,
      showValueIndicator: showValueIndicator ?? this.showValueIndicator,
      secondaryTrackValue: secondaryTrackValue ?? this.secondaryTrackValue,
      secondaryActiveTrackColor:
          secondaryActiveTrackColor ?? this.secondaryActiveTrackColor,
      padding: padding ?? this.padding,
      orientation: orientation ?? this.orientation,
      inverted: inverted ?? this.inverted,
      thumbStrokeColor: thumbStrokeColor ?? this.thumbStrokeColor,
      thumbStrokeWidth: thumbStrokeWidth ?? this.thumbStrokeWidth,
      thumbBorderColor: thumbBorderColor ?? this.thumbBorderColor,
      thumbBorderWidth: thumbBorderWidth ?? this.thumbBorderWidth,
      thumbGripColor: thumbGripColor ?? this.thumbGripColor,
      fillFromEnd: fillFromEnd ?? this.fillFromEnd,
      tickMarkStyle: tickMarkStyle ?? this.tickMarkStyle,
      notchEvery: notchEvery ?? this.notchEvery,
      markerColor: markerColor ?? this.markerColor,
      markerWidth: markerWidth ?? this.markerWidth,
      markerHeight: markerHeight ?? this.markerHeight,
      selectableMin: selectableMin ?? this.selectableMin,
      selectableMax: selectableMax ?? this.selectableMax,
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
        activeTrackColor = value;
      },
    ),
    'inactiveTrackColor': ColorFieldAccess<ColorRGBA>(
      'Inactive Track Color',
      'Color of slider\'s track when it\'s inactive.',
      () => inactiveTrackColor,
      (value) {
        inactiveTrackColor = value;
      },
    ),
    'thumbColor': ColorFieldAccess<ColorRGBA>(
      'Thumb Color',
      'Color of slider\'s thumb.',
      () => thumbColor,
      (value) {
        thumbColor = value;
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
      requiresLayout: true,
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
      requiresLayout: true,
    ),
    'showThumb': BoolFieldAccess(
      'Show Thumb',
      'Whether to show slider\'s thumb.',
      () => showThumb,
      (bool value) => showThumb = value,
      requiresLayout: true,
    ),
    'thumbShape': EnumFieldAccess<SliderThumbShapeEnum>(
      'Thumb Shape',
      'Shape of slider\'s thumb.',
      () => thumbShape,
      (SliderThumbShapeEnum value) => thumbShape = value,
      defaultValue: () => SliderThumbShapeEnum.circle,
      options: () => SliderThumbShapeEnum.values,
      requiresLayout: true,
    ),
    'thumbWidth': NumFieldAccess<double>(
      'Thumb Width',
      'Width of a rectangular thumb.',
      () => thumbWidth,
      (double value) => thumbWidth = value,
      requiresLayout: true,
    ),
    'thumbHeight': NumFieldAccess<double>(
      'Thumb Height',
      'Height of a rectangular thumb.',
      () => thumbHeight,
      (double value) => thumbHeight = value,
      requiresLayout: true,
    ),
    'thumbCornerRadius': NumFieldAccess<double>(
      'Thumb Corner Radius',
      'Corner radius of a rectangular thumb.',
      () => thumbCornerRadius,
      (double value) => thumbCornerRadius = value,
    ),
    'thumbBorderColor': ColorFieldAccess<ColorRGBA?>(
      'Thumb Border Color',
      'Border color of a rectangular thumb.',
      () => thumbBorderColor,
      (value) => thumbBorderColor = value,
    ),
    'thumbBorderWidth': NumFieldAccess<double>(
      'Thumb Border Width',
      'Border width of a rectangular thumb.',
      () => thumbBorderWidth,
      (double value) => thumbBorderWidth = value,
    ),
    'thumbGripColor': ColorFieldAccess<ColorRGBA?>(
      'Thumb Grip Color',
      'Color of the grip line in a rectangular thumb.',
      () => thumbGripColor,
      (value) => thumbGripColor = value,
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
      requiresLayout: true,
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
    'showValueIndicator': EnumFieldAccess<ShowValueIndicatorC?>(
      'Show Value Indicator',
      'When to show the value indicator.',
      () => showValueIndicator,
      (value) => showValueIndicator = value,
      defaultValue: () => null,
      options: () => ShowValueIndicatorC.values,
    ),
    'secondaryTrackValue': NumFieldAccess<double?>(
      'Secondary Track Value',
      'Secondary progress shown on the track, such as a buffered amount.',
      () => secondaryTrackValue,
      (value) => secondaryTrackValue = value,
    ),
    'secondaryActiveTrackColor': ColorFieldAccess<ColorRGBA?>(
      'Secondary Active Track Color',
      'Color of the track up to the secondary track value.',
      () => secondaryActiveTrackColor,
      (value) => secondaryActiveTrackColor = value,
    ),
    'orientation': EnumFieldAccess<AxisC>(
      'Orientation',
      'Direction the slider runs in.',
      () => orientation,
      (AxisC value) => orientation = value,
      defaultValue: () => AxisC.horizontal,
      options: () => AxisC.values,
      requiresLayout: true,
    ),
    'inverted': BoolFieldAccess(
      'Inverted',
      'Whether the slider runs right to left, or top to bottom.',
      () => inverted,
      (bool value) => inverted = value,
    ),
    'thumbStrokeColor': ColorFieldAccess<ColorRGBA?>(
      'Thumb Stroke Color',
      'Color of the stroke around the slider\'s thumb.',
      () => thumbStrokeColor,
      (value) => thumbStrokeColor = value,
    ),
    'thumbStrokeWidth': NumFieldAccess<double>(
      'Thumb Stroke Width',
      'Width of the stroke around the slider\'s thumb.',
      () => thumbStrokeWidth,
      (double value) => thumbStrokeWidth = value,
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
    thumbShape,
    thumbWidth,
    thumbHeight,
    thumbCornerRadius,
    showThumb,
    trackShape,
    tickMarkRadius,
    valueIndicatorShape,
    overlayRadius,
    deriveOverlayColorFromThumb,
    showValueIndicator,
    secondaryTrackValue,
    secondaryActiveTrackColor,
    padding,
    orientation,
    inverted,
    thumbStrokeColor,
    thumbStrokeWidth,
    thumbBorderColor,
    thumbBorderWidth,
    thumbGripColor,
    fillFromEnd,
    tickMarkStyle,
    notchEvery,
    markerColor,
    markerWidth,
    markerHeight,
    selectableMin,
    selectableMax,
  ];

  /// Creates a [SliderProperties] instance from a JSON object.
  factory SliderProperties.fromJson(Map json) =>
      _$SliderPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$SliderPropertiesOmitDefaults(this, _$SliderPropertiesToJson(this));
}
