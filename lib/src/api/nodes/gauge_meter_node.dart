import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'gauge_meter_node.g.dart';

/// The default size of an arc gauge.
const double kGaugeMeterDefaultSize = 160;

/// The shape a [GaugeMeterNode] draws.
enum GaugeShape {
  /// A ring segment, e.g. a speedometer. Sweeps clockwise from
  /// [GaugeMeterProperties.startAngle] by [GaugeMeterProperties.sweepAngle].
  arc,

  /// A straight bar that fills along its length: left to right, or bottom to
  /// top when the node is taller than it is wide.
  bar;

  /// Displayable label.
  String get prettify => switch (this) {
    GaugeShape.arc => 'Arc',
    GaugeShape.bar => 'Bar',
  };
}

/// How a gauge's limit line is drawn.
enum GaugeLimitStyle {
  /// A solid line.
  solid,

  /// A dashed line.
  dashed;

  /// Displayable label.
  String get prettify => switch (this) {
    GaugeLimitStyle.solid => 'Solid',
    GaugeLimitStyle.dashed => 'Dashed',
  };
}

/// A gauge: a value between [GaugeMeterProperties.min] and [GaugeMeterProperties.max]
/// shown as a filled arc (dials) or bar (tank levels, LED meters).
///
/// The fill is either continuous or split into [GaugeMeterProperties.segments]
/// blocks. Optional scale ticks and a limit marker (e.g. an alarm
/// threshold) sit on top. [value], the fill [GaugeMeterProperties.color] and the
/// [limit] can be bound to variables or formulas.
@JsonSerializable()
class GaugeMeterNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'gaugeMeter';

  @override
  covariant GaugeMeterProperties properties;

  /// The current value, between [GaugeMeterProperties.min] and
  /// [GaugeMeterProperties.max].
  double value;

  /// Where the limit marker sits, in the same units as [value]. No marker
  /// when null.
  double? limit;

  @override
  bool get supportsPadding => false;

  /// Creates a gauge preview. Strictly used for previews, e.g. in the
  /// components panel.
  GaugeMeterNode.empty()
    : properties = GaugeMeterProperties(),
      value = 60,
      limit = null,
      super(
        id: 'gaugeMeter',
        name: 'Gauge',
        basicBoxLocal: NodeBox(
          0,
          0,
          kGaugeMeterDefaultSize,
          kGaugeMeterDefaultSize,
        ),
      );

  /// Creates a [GaugeMeterNode] with the given data.
  GaugeMeterNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
    super.rotationDegrees,
    super.alignment,
    super.margin,
    super.padding,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    super.parentID,
    super.reactions,
    // Custom properties.
    this.value = 0,
    this.limit,
    required this.properties,
    super.variables,
    super.multipleVariables,
  }) {
    setVariablesMixin(
      variables: variables,
      multipleVariables: multipleVariables,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'value': NumFieldAccess<double>(
      'Value',
      'Current value of the gauge',
      () => value,
      (value) => this.value = value,
    ),
    'properties': ObjectFieldAccess<GaugeMeterProperties>(
      'Properties',
      'properties of the gauge',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<Object?> get props => [
    ...super.props,
    value,
    limit,
    properties,
    variables,
    multipleVariables,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    DoubleValue(name: 'value', value: value),
    DoubleValue(name: 'limit', value: limit ?? 0),
    ColorValue(name: 'color', value: properties.color),
    ColorValue(name: 'limitColor', value: properties.limitColor),
  ];

  /// Creates a [GaugeMeterNode] from a JSON object.
  factory GaugeMeterNode.fromJson(Map json) => _$GaugeMeterNodeFromJson(json);

  @override
  Map toJson() =>
      _$GaugeMeterNodeOmitDefaults(this, _$GaugeMeterNodeToJson(this))
        ..['type'] = type;
}

/// Configurable properties of a [GaugeMeterNode].
@JsonSerializable()
class GaugeMeterProperties extends CustomProperties with FieldsHolder {
  /// Arc or bar.
  GaugeShape shape;

  /// The value of an empty gauge.
  double min;

  /// The value of a full gauge.
  double max;

  /// Fill color. Bindable as `color`.
  ColorRGBA color;

  /// Color of the unfilled part (the track, or unlit segments).
  ColorRGBA trackColor;

  /// Opacity of the fill at its start (the bottom of a vertical bar), from 0
  /// to 1. Below 1 the fill fades from [color] at its end to this opacity at
  /// its start, like liquid in a sight glass.
  double fillStartOpacity;

  /// Number of blocks the gauge is split into, like LEDs. 0 draws a
  /// continuous fill. A segment is lit when it lies fully below the value
  /// (rounded to the nearest segment).
  int segments;

  /// Space between segments: degrees for an arc, logical pixels for a bar.
  double segmentGap;

  /// Arc thickness in logical pixels. 0 uses 7.5% of the gauge's width.
  double thickness;

  /// Where the arc starts, in degrees clockwise from 3 o'clock. 135 starts
  /// at 7:30.
  double startAngle;

  /// How far the arc sweeps clockwise, in degrees.
  double sweepAngle;

  /// Corner radius of a bar (its well) and of bar segments.
  double cornerRadius;

  /// Background of a bar's well, behind the track. Transparent for none.
  ColorRGBA backgroundColor;

  /// 1 px border around a bar's well. Transparent for none.
  ColorRGBA borderColor;

  /// Space between a bar's well and its fill.
  double inset;

  /// Thickness of a line drawn across the end of the fill (the meniscus of a
  /// liquid). 0 for none.
  double edgeWidth;

  /// Color of the [edgeWidth] line.
  ColorRGBA edgeColor;

  /// Number of scale divisions. An arc draws ticks inside the ring; a bar
  /// draws graduation lines across the well. 0 for none.
  int ticks;

  /// Every this many ticks is a major tick: longer (and thicker on arcs).
  /// 0 makes every tick minor.
  int majorTickEvery;

  /// Tick color.
  ColorRGBA tickColor;

  /// Color of the limit marker. Bindable as `limitColor`.
  ColorRGBA limitColor;

  /// Thickness of the limit marker line.
  double limitWidth;

  /// Solid or dashed limit line.
  GaugeLimitStyle limitStyle;

  /// Whether a bar's limit line has a small triangle pointing at it from the
  /// start edge.
  bool limitPointer;

  /// Whether value changes animate.
  bool animate;

  /// Animation duration in milliseconds.
  int animationDurationInMillis;

  /// Creates [GaugeMeterProperties] with the given data.
  GaugeMeterProperties({
    this.shape = GaugeShape.arc,
    this.min = 0,
    this.max = 100,
    this.color = const ColorRGBA(r: 0.24, g: 0.84, b: 0.55, a: 1),
    this.trackColor = const ColorRGBA(r: 0.16, g: 0.18, b: 0.21, a: 1),
    this.fillStartOpacity = 1,
    this.segments = 0,
    this.segmentGap = 1.25,
    this.thickness = 0,
    this.startAngle = 135,
    this.sweepAngle = 270,
    this.cornerRadius = 0,
    this.backgroundColor = ColorRGBA.transparent,
    this.borderColor = ColorRGBA.transparent,
    this.inset = 0,
    this.edgeWidth = 0,
    this.edgeColor = ColorRGBA.white,
    this.ticks = 0,
    this.majorTickEvery = 0,
    this.tickColor = const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1),
    this.limitColor = const ColorRGBA(r: 0.95, g: 0.76, b: 0.19, a: 1),
    this.limitWidth = 3,
    this.limitStyle = GaugeLimitStyle.solid,
    this.limitPointer = false,
    this.animate = true,
    this.animationDurationInMillis = 700,
  });

  /// Duplicates these properties with the given overrides.
  GaugeMeterProperties copyWith({
    GaugeShape? shape,
    double? min,
    double? max,
    ColorRGBA? color,
    ColorRGBA? trackColor,
    double? fillStartOpacity,
    int? segments,
    double? segmentGap,
    double? thickness,
    double? startAngle,
    double? sweepAngle,
    double? cornerRadius,
    ColorRGBA? backgroundColor,
    ColorRGBA? borderColor,
    double? inset,
    double? edgeWidth,
    ColorRGBA? edgeColor,
    int? ticks,
    int? majorTickEvery,
    ColorRGBA? tickColor,
    ColorRGBA? limitColor,
    double? limitWidth,
    GaugeLimitStyle? limitStyle,
    bool? limitPointer,
    bool? animate,
    int? animationDurationInMillis,
  }) => GaugeMeterProperties(
    shape: shape ?? this.shape,
    min: min ?? this.min,
    max: max ?? this.max,
    color: color ?? this.color,
    trackColor: trackColor ?? this.trackColor,
    fillStartOpacity: fillStartOpacity ?? this.fillStartOpacity,
    segments: segments ?? this.segments,
    segmentGap: segmentGap ?? this.segmentGap,
    thickness: thickness ?? this.thickness,
    startAngle: startAngle ?? this.startAngle,
    sweepAngle: sweepAngle ?? this.sweepAngle,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    inset: inset ?? this.inset,
    edgeWidth: edgeWidth ?? this.edgeWidth,
    edgeColor: edgeColor ?? this.edgeColor,
    ticks: ticks ?? this.ticks,
    majorTickEvery: majorTickEvery ?? this.majorTickEvery,
    tickColor: tickColor ?? this.tickColor,
    limitColor: limitColor ?? this.limitColor,
    limitWidth: limitWidth ?? this.limitWidth,
    limitStyle: limitStyle ?? this.limitStyle,
    limitPointer: limitPointer ?? this.limitPointer,
    animate: animate ?? this.animate,
    animationDurationInMillis:
        animationDurationInMillis ?? this.animationDurationInMillis,
  );

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'shape': EnumFieldAccess<GaugeShape>(
      'Shape',
      'Arc or bar',
      () => shape,
      (value) => shape = value,
      defaultValue: () => GaugeShape.arc,
      options: () => GaugeShape.values,
    ),
    'min': NumFieldAccess<double>(
      'Min',
      'The value of an empty gauge',
      () => min,
      (value) => min = value,
    ),
    'max': NumFieldAccess<double>(
      'Max',
      'The value of a full gauge',
      () => max,
      (value) => max = value,
    ),
    'color': ColorFieldAccess<ColorRGBA>(
      'Color',
      'Fill color',
      () => color,
      (value) => color = value,
    ),
    'trackColor': ColorFieldAccess<ColorRGBA>(
      'Track Color',
      'Color of the unfilled part',
      () => trackColor,
      (value) => trackColor = value,
    ),
    'segments': NumFieldAccess<int>(
      'Segments',
      'Number of blocks, 0 for a continuous fill',
      () => segments,
      (value) => segments = value,
    ),
    'ticks': NumFieldAccess<int>(
      'Ticks',
      'Number of scale divisions',
      () => ticks,
      (value) => ticks = value,
    ),
    'limitColor': ColorFieldAccess<ColorRGBA>(
      'Limit Color',
      'Color of the limit marker',
      () => limitColor,
      (value) => limitColor = value,
    ),
  };

  @override
  List<Object?> get props => [
    shape,
    min,
    max,
    color,
    trackColor,
    fillStartOpacity,
    segments,
    segmentGap,
    thickness,
    startAngle,
    sweepAngle,
    cornerRadius,
    backgroundColor,
    borderColor,
    inset,
    edgeWidth,
    edgeColor,
    ticks,
    majorTickEvery,
    tickColor,
    limitColor,
    limitWidth,
    limitStyle,
    limitPointer,
    animate,
    animationDurationInMillis,
  ];

  /// Creates [GaugeMeterProperties] from a JSON object.
  factory GaugeMeterProperties.fromJson(Map json) =>
      _$GaugeMeterPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GaugeMeterPropertiesOmitDefaults(
    this,
    _$GaugeMeterPropertiesToJson(this),
  );
}
