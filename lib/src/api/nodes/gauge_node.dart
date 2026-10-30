import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import '../node_json_converter.dart';
import 'nodes.dart';

part 'gauge_node.g.dart';

/// The default width of a gauge.
const double kGaugeDefaultWidth = 220;

/// The default height of a gauge.
const double kGaugeDefaultHeight = 185;

/// A radial gauge (dial): an arc track, optional colored zones, ticks and
/// labels, a value arc (continuous or in segments), a target notch and a
/// needle. The value is bindable (`variables: {"value": "${...}"}`), so a
/// readout is usually a text node placed over the dial.
@FlutterNode(
  'CodelesslyRadialGauge',
  family: 'codelessly',
  nodeType: 'gauge',
  variant: 'radial',
)
@JsonSerializable()
class GaugeNode extends SceneNode with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'gauge';

  /// Configurable properties of the gauge.
  @override
  covariant GaugeProperties properties;

  /// Current value, between [GaugeProperties.min] and [GaugeProperties.max].
  @FlutterProp(
    'value',
    type: 'number',
    group: 'State',
    control: 'number',
    bindable: true,
  )
  double value;

  @override
  bool get supportsPadding => false;

  /// Creates a preview gauge, e.g. for the components panel.
  GaugeNode.empty()
    : properties = GaugeProperties(),
      value = 72,
      super(
        id: 'gaugeRadial',
        name: 'Gauge',
        basicBoxLocal: NodeBox(0, 0, kGaugeDefaultWidth, kGaugeDefaultHeight),
      );

  /// Creates a [GaugeNode] with the given data.
  GaugeNode({
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
    this.value = 0,
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
  List<TriggerType> get triggerTypes => [TriggerType.click];

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'value': NumFieldAccess<double>(
      'Value',
      'Current value of the gauge',
      () => value,
      (v) => value = v,
    ),
    'properties': ObjectFieldAccess<GaugeProperties>(
      'Properties',
      'Properties of the gauge',
      () => properties,
      (v) => properties = v,
    ),
  };

  @override
  List<Object?> get props => [
    ...super.props,
    value,
    properties,
    variables,
    multipleVariables,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    DoubleValue(name: 'value', value: value),
  ];

  /// Creates a [GaugeNode] from JSON.
  /// A missing `properties` key means default properties, so hand-written
  /// JSON (e.g. nodes.insertTree) can leave it out. Validate the explicit
  /// wire kind before applying property defaults.
  factory GaugeNode.fromJson(Map json) {
    NodeJsonConverter.validateGaugeWire(json, expectedType: 'radial');
    return _$GaugeNodeFromJson({
      ...json,
      if (json['properties'] == null) 'properties': const {},
    });
  }

  @override
  Map toJson() => _$GaugeNodeOmitDefaults(this, _$GaugeNodeToJson(this))
    ..['type'] = type
    ..['gaugeKind'] = 'radial';
}

/// A colored band of the gauge, from [from] to [to] in value units.
@JsonSerializable()
class GaugeZone with Equatable, SerializableMixin {
  /// Start value.
  final double from;

  /// End value.
  final double to;

  /// Band color. The value arc takes the color of the zone its value is in
  /// when [GaugeProperties.colorByZone] is true.
  final ColorRGBA color;

  /// Creates a [GaugeZone].
  const GaugeZone({required this.from, required this.to, required this.color});

  /// Creates a [GaugeZone] from JSON.
  factory GaugeZone.fromJson(Map json) => _$GaugeZoneFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GaugeZoneToJson(this);

  @override
  List<Object?> get props => [from, to, color];
}

/// The default zones: poor below 60, typical to 85, world class above.
const List<GaugeZone> kDefaultGaugeZones = [
  GaugeZone(
    from: 0,
    to: 60,
    color: ColorRGBA(r: 1, g: 74 / 255, b: 61 / 255, a: 1),
  ),
  GaugeZone(
    from: 60,
    to: 85,
    color: ColorRGBA(r: 245 / 255, g: 158 / 255, b: 43 / 255, a: 1),
  ),
  GaugeZone(
    from: 85,
    to: 100,
    color: ColorRGBA(r: 46 / 255, g: 209 / 255, b: 122 / 255, a: 1),
  ),
];

/// Configurable properties of a [GaugeNode].
@JsonSerializable()
class GaugeProperties extends CustomProperties with FieldsHolder {
  /// Value at the start of the arc.
  double min;

  /// Value at the end of the arc.
  double max;

  /// Where the arc starts, in degrees clockwise from 3 o'clock.
  double startAngle;

  /// How far the arc sweeps, in degrees.
  double sweepAngle;

  /// Thickness of the track and value arc.
  double thickness;

  /// Color of the empty track.
  ColorRGBA trackColor;

  /// Color of the value arc when [colorByZone] is false or no zone matches.
  ColorRGBA valueColor;

  /// Whether the value arc takes the color of the zone its value is in.
  bool colorByZone;

  /// Number of segments the arc is split into (an LED bar look). 0 draws a
  /// continuous arc.
  int segments;

  /// Gap between segments, in degrees.
  double segmentGap;

  /// Colored bands drawn outside the track.
  List<GaugeZone> zones;

  /// Thickness of the zone bands. 0 hides them.
  double zoneThickness;

  /// Opacity of the zone bands.
  double zoneOpacity;

  /// Number of major tick intervals (0 hides ticks).
  int majorTicks;

  /// Minor ticks between two major ticks.
  int minorTicks;

  /// Tick color.
  ColorRGBA tickColor;

  /// Values that get a number label inside the arc.
  List<double> labels;

  /// Label color.
  ColorRGBA labelColor;

  /// Label font size.
  double labelFontSize;

  /// Label font family (a Google Font name), or null for the default.
  String? labelFontFamily;

  /// Whether a target value is marked with a notch outside the arc.
  bool showTarget;

  /// The target value.
  double target;

  /// Color of the target notch.
  ColorRGBA targetColor;

  /// Whether a needle points at the value.
  bool showNeedle;

  /// Needle color.
  ColorRGBA needleColor;

  /// Fraction of the radius around the center the needle leaves clear, so it
  /// doesn't cross a readout placed in the middle (0 draws it to the hub).
  double needleClearance;

  /// Whether value changes animate.
  bool animate;

  /// Animation duration in milliseconds.
  int animationDurationInMillis;

  /// Creates [GaugeProperties].
  GaugeProperties({
    this.min = 0,
    this.max = 100,
    this.startAngle = 150,
    this.sweepAngle = 240,
    this.thickness = 14,
    this.trackColor = const ColorRGBA(
      r: 18 / 255,
      g: 19 / 255,
      b: 22 / 255,
      a: 1,
    ),
    this.valueColor = const ColorRGBA(r: 1, g: 212 / 255, b: 0, a: 1),
    this.colorByZone = true,
    this.segments = 40,
    this.segmentGap = 0.9,
    this.zones = kDefaultGaugeZones,
    this.zoneThickness = 4,
    this.zoneOpacity = 0.55,
    this.majorTicks = 10,
    this.minorTicks = 1,
    this.tickColor = const ColorRGBA(
      r: 163 / 255,
      g: 171 / 255,
      b: 178 / 255,
      a: 1,
    ),
    this.labels = const [0, 60, 85, 100],
    this.labelColor = const ColorRGBA(
      r: 112 / 255,
      g: 120 / 255,
      b: 130 / 255,
      a: 1,
    ),
    this.labelFontSize = 10,
    this.labelFontFamily,
    this.showTarget = true,
    this.target = 85,
    this.targetColor = const ColorRGBA(
      r: 232 / 255,
      g: 235 / 255,
      b: 237 / 255,
      a: 1,
    ),
    this.showNeedle = true,
    this.needleColor = const ColorRGBA(
      r: 232 / 255,
      g: 235 / 255,
      b: 237 / 255,
      a: 1,
    ),
    this.needleClearance = 0.62,
    this.animate = true,
    this.animationDurationInMillis = 420,
  });

  /// Value as a 0–1 fraction of the arc.
  double fraction(double value) =>
      max == min ? 0 : ((value - min) / (max - min)).clamp(0.0, 1.0);

  /// Color of the value arc for [value].
  ColorRGBA colorFor(double value) {
    if (colorByZone) {
      for (final zone in zones) {
        if (value >= zone.from && value < zone.to) return zone.color;
      }
      if (zones.isNotEmpty && value >= zones.last.to) return zones.last.color;
    }
    return valueColor;
  }

  /// Duplicates these properties with the given overrides.
  GaugeProperties copyWith({
    double? min,
    double? max,
    double? startAngle,
    double? sweepAngle,
    double? thickness,
    ColorRGBA? trackColor,
    ColorRGBA? valueColor,
    bool? colorByZone,
    int? segments,
    double? segmentGap,
    List<GaugeZone>? zones,
    double? zoneThickness,
    double? zoneOpacity,
    int? majorTicks,
    int? minorTicks,
    ColorRGBA? tickColor,
    List<double>? labels,
    ColorRGBA? labelColor,
    double? labelFontSize,
    String? labelFontFamily,
    bool? showTarget,
    double? target,
    ColorRGBA? targetColor,
    bool? showNeedle,
    ColorRGBA? needleColor,
    double? needleClearance,
    bool? animate,
    int? animationDurationInMillis,
  }) => GaugeProperties(
    min: min ?? this.min,
    max: max ?? this.max,
    startAngle: startAngle ?? this.startAngle,
    sweepAngle: sweepAngle ?? this.sweepAngle,
    thickness: thickness ?? this.thickness,
    trackColor: trackColor ?? this.trackColor,
    valueColor: valueColor ?? this.valueColor,
    colorByZone: colorByZone ?? this.colorByZone,
    segments: segments ?? this.segments,
    segmentGap: segmentGap ?? this.segmentGap,
    zones: zones ?? this.zones,
    zoneThickness: zoneThickness ?? this.zoneThickness,
    zoneOpacity: zoneOpacity ?? this.zoneOpacity,
    majorTicks: majorTicks ?? this.majorTicks,
    minorTicks: minorTicks ?? this.minorTicks,
    tickColor: tickColor ?? this.tickColor,
    labels: labels ?? this.labels,
    labelColor: labelColor ?? this.labelColor,
    labelFontSize: labelFontSize ?? this.labelFontSize,
    labelFontFamily: labelFontFamily ?? this.labelFontFamily,
    showTarget: showTarget ?? this.showTarget,
    target: target ?? this.target,
    targetColor: targetColor ?? this.targetColor,
    showNeedle: showNeedle ?? this.showNeedle,
    needleColor: needleColor ?? this.needleColor,
    needleClearance: needleClearance ?? this.needleClearance,
    animate: animate ?? this.animate,
    animationDurationInMillis:
        animationDurationInMillis ?? this.animationDurationInMillis,
  );

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'min': NumFieldAccess<double>(
      'Min',
      'Value at the start of the arc',
      () => min,
      (v) => min = v,
    ),
    'max': NumFieldAccess<double>(
      'Max',
      'Value at the end of the arc',
      () => max,
      (v) => max = v,
    ),
    'startAngle': NumFieldAccess<double>(
      'Start Angle',
      'Arc start in degrees',
      () => startAngle,
      (v) => startAngle = v,
    ),
    'sweepAngle': NumFieldAccess<double>(
      'Sweep Angle',
      'Arc sweep in degrees',
      () => sweepAngle,
      (v) => sweepAngle = v,
    ),
    'thickness': NumFieldAccess<double>(
      'Thickness',
      'Track thickness',
      () => thickness,
      (v) => thickness = v,
    ),
    'trackColor': ColorFieldAccess<ColorRGBA>(
      'Track Color',
      'Color of the empty track',
      () => trackColor,
      (v) => trackColor = v,
    ),
    'valueColor': ColorFieldAccess<ColorRGBA>(
      'Value Color',
      'Color of the value arc',
      () => valueColor,
      (v) => valueColor = v,
    ),
    'colorByZone': BoolFieldAccess(
      'Color By Zone',
      'Value arc takes its zone color',
      () => colorByZone,
      (v) => colorByZone = v,
    ),
    'segments': NumFieldAccess<int>(
      'Segments',
      'Segments in the value arc (0 = continuous)',
      () => segments,
      (v) => segments = v,
    ),
    'zoneThickness': NumFieldAccess<double>(
      'Zone Thickness',
      'Thickness of the zone bands',
      () => zoneThickness,
      (v) => zoneThickness = v,
    ),
    'majorTicks': NumFieldAccess<int>(
      'Major Ticks',
      'Major tick intervals',
      () => majorTicks,
      (v) => majorTicks = v,
    ),
    'minorTicks': NumFieldAccess<int>(
      'Minor Ticks',
      'Minor ticks per interval',
      () => minorTicks,
      (v) => minorTicks = v,
    ),
    'showNeedle': BoolFieldAccess(
      'Needle',
      'Whether a needle points at the value',
      () => showNeedle,
      (v) => showNeedle = v,
    ),
    'animate': BoolFieldAccess(
      'Animate',
      'Whether value changes animate',
      () => animate,
      (v) => animate = v,
    ),
  };

  @override
  List<Object?> get props => [
    min,
    max,
    startAngle,
    sweepAngle,
    thickness,
    trackColor,
    valueColor,
    colorByZone,
    segments,
    segmentGap,
    zones,
    zoneThickness,
    zoneOpacity,
    majorTicks,
    minorTicks,
    tickColor,
    labels,
    labelColor,
    labelFontSize,
    labelFontFamily,
    showTarget,
    target,
    targetColor,
    showNeedle,
    needleColor,
    needleClearance,
    animate,
    animationDurationInMillis,
  ];

  /// Creates [GaugeProperties] from JSON.
  factory GaugeProperties.fromJson(Map json) => _$GaugePropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$GaugePropertiesOmitDefaults(this, _$GaugePropertiesToJson(this));
}
