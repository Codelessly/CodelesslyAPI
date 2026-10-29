import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'chart_node.g.dart';

/// The default width of a chart.
const double kChartDefaultWidth = 360;

/// The default height of a chart.
const double kChartDefaultHeight = 200;

/// What a [ChartNode] draws.
enum ChartType {
  /// Bars per category (stacked or grouped by series), with line and tick
  /// series drawn over them.
  bar,

  /// Lines (optionally with a filled area) across the categories.
  line,

  /// One horizontal band of colored segments over a numeric domain, e.g. a
  /// machine's states across a shift.
  timeline;

  /// Display name.
  String get prettify => switch (this) {
    ChartType.bar => 'Bar',
    ChartType.line => 'Line',
    ChartType.timeline => 'Timeline',
  };
}

/// How a [ChartSeries] is drawn.
enum ChartSeriesKind {
  /// A bar per category. Bars of series with the same [ChartSeries.stack]
  /// stack; other bar series sit side by side.
  bar,

  /// A line through the category points.
  line,

  /// A line with the area under it filled.
  area,

  /// A short horizontal mark per category (a plan or target).
  tick;

  /// Display name.
  String get prettify => switch (this) {
    ChartSeriesKind.bar => 'Bar',
    ChartSeriesKind.line => 'Line',
    ChartSeriesKind.area => 'Area',
    ChartSeriesKind.tick => 'Tick',
  };
}

/// One series of a [ChartNode]: which field of each data item it reads and
/// how it is drawn.
@JsonSerializable()
class ChartSeries with Equatable, SerializableMixin {
  /// Field of each data item holding the value. Items where it is null or
  /// missing have no mark (for lines, the line stops).
  final String field;

  /// Name shown in descriptions.
  final String name;

  /// How the series is drawn.
  final ChartSeriesKind kind;

  /// Color.
  final ColorRGBA color;

  /// Field of each item holding a per-item color (hex), overriding [color].
  final String? colorField;

  /// Bar series with the same stack id stack on each other.
  final String? stack;

  /// Whether lines and ticks are dashed.
  final bool dashed;

  /// Line or tick thickness.
  final double strokeWidth;

  /// Whether a line ends in a dot at its last point.
  final bool endDot;

  /// For area series, the field of another series to fill down to instead of
  /// the axis (the gap between two lines).
  final String? fillTo;

  /// Opacity of an area fill.
  final double fillOpacity;

  /// Creates a [ChartSeries].
  const ChartSeries({
    required this.field,
    this.name = '',
    this.kind = ChartSeriesKind.bar,
    this.color = const ColorRGBA(r: 46 / 255, g: 209 / 255, b: 122 / 255, a: 1),
    this.colorField,
    this.stack,
    this.dashed = false,
    this.strokeWidth = 2,
    this.endDot = false,
    this.fillTo,
    this.fillOpacity = 0.25,
  });

  /// Creates a [ChartSeries] from JSON.
  factory ChartSeries.fromJson(Map json) => _$ChartSeriesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChartSeriesToJson(this);

  @override
  List<Object?> get props => [
    field,
    name,
    kind,
    color,
    colorField,
    stack,
    dashed,
    strokeWidth,
    endDot,
    fillTo,
    fillOpacity,
  ];
}

/// A horizontal line across the plot at [value] (a target or threshold).
@JsonSerializable()
class ChartReferenceLine with Equatable, SerializableMixin {
  /// Value on the y axis.
  final double value;

  /// Line color.
  final ColorRGBA color;

  /// Whether the line is dashed.
  final bool dashed;

  /// Line thickness.
  final double strokeWidth;

  /// Creates a [ChartReferenceLine].
  const ChartReferenceLine({
    required this.value,
    this.color = const ColorRGBA(r: 1, g: 1, b: 1, a: 0.6),
    this.dashed = true,
    this.strokeWidth = 1.5,
  });

  /// Creates a [ChartReferenceLine] from JSON.
  factory ChartReferenceLine.fromJson(Map json) =>
      _$ChartReferenceLineFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChartReferenceLineToJson(this);

  @override
  List<Object?> get props => [value, color, dashed, strokeWidth];
}

/// A data chart. Its data is a list of items (maps) bound with
/// `variables: {"data": "${list}"}` (or [ChartProperties.sampleData] when
/// unbound); each [ChartSeries] reads one field of every item, and
/// [ChartProperties.labelField] names the x-axis labels.
///
/// Tapping a category fires the node's `changed` reactions with the
/// category index as `${value}`; bind `selectedIndex` to show a selection.
@JsonSerializable()
class ChartNode extends SceneNode with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'chartSeries';

  /// Configurable properties of the chart.
  @override
  covariant ChartProperties properties;

  /// Index of the highlighted category, or -1 for none. Bindable.
  int selectedIndex;

  @override
  bool get supportsPadding => true;

  /// Creates a preview chart, e.g. for the components panel.
  ChartNode.empty()
    : properties = ChartProperties(),
      selectedIndex = -1,
      super(
        id: 'chart',
        name: 'Chart',
        basicBoxLocal: NodeBox(0, 0, kChartDefaultWidth, kChartDefaultHeight),
      );

  /// Creates a [ChartNode] with the given data.
  ChartNode({
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
    this.selectedIndex = -1,
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
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'selectedIndex': NumFieldAccess<int>(
      'Selected Index',
      'Index of the highlighted category (-1 for none)',
      () => selectedIndex,
      (v) => selectedIndex = v,
    ),
    'properties': ObjectFieldAccess<ChartProperties>(
      'Properties',
      'Properties of the chart',
      () => properties,
      (v) => properties = v,
    ),
  };

  @override
  List<Object?> get props => [
    ...super.props,
    selectedIndex,
    properties,
    variables,
    multipleVariables,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    IntValue(name: 'selectedIndex', value: selectedIndex),
  ];

  /// Creates a [ChartNode] from JSON.
  /// A missing `properties` key means default properties, so hand-written
  /// JSON (e.g. nodes.insertTree) can leave it out.
  factory ChartNode.fromJson(Map json) => _$ChartNodeFromJson(
    json['properties'] == null ? {...json, 'properties': const {}} : json,
  );

  @override
  Map toJson() => _$ChartNodeOmitDefaults(this, _$ChartNodeToJson(this));
}

/// Default sample data: six hours of output against a plan.
const List<Map<String, Object?>> kDefaultChartSampleData = [
  {'label': '14', 'good': 760, 'scrap': 12, 'plan': 800},
  {'label': '15', 'good': 690, 'scrap': 9, 'plan': 800},
  {'label': '16', 'good': 540, 'scrap': 15, 'plan': 800},
  {'label': '17', 'good': 780, 'scrap': 8, 'plan': 800},
  {'label': '18', 'good': 805, 'scrap': 11, 'plan': 800},
  {'label': '19', 'good': 420, 'scrap': 6, 'plan': 800},
];

/// Default series for [kDefaultChartSampleData].
const List<ChartSeries> kDefaultChartSeries = [
  ChartSeries(field: 'good', name: 'Good', stack: 'output'),
  ChartSeries(
    field: 'scrap',
    name: 'Scrap',
    stack: 'output',
    color: ColorRGBA(r: 1, g: 74 / 255, b: 61 / 255, a: 1),
  ),
  ChartSeries(
    field: 'plan',
    name: 'Plan',
    kind: ChartSeriesKind.tick,
    color: ColorRGBA(r: 232 / 255, g: 235 / 255, b: 237 / 255, a: 1),
  ),
];

/// Configurable properties of a [ChartNode].
@JsonSerializable()
class ChartProperties extends CustomProperties with FieldsHolder {
  /// What the chart draws.
  ChartType chartType;

  /// The series.
  List<ChartSeries> series;

  /// Field of each item holding its x-axis label.
  String labelField;

  /// Data shown when the node's `data` isn't bound to a variable.
  List<Map<String, Object?>> sampleData;

  /// Lowest y value, or null for 0 (or the data minimum when negative).
  double? minY;

  /// Highest y value, or null for a rounded-up maximum of the data.
  double? maxY;

  /// Horizontal grid intervals (and y-axis labels). 0 hides the grid.
  int gridLines;

  /// Grid line color.
  ColorRGBA gridColor;

  /// Whether y-axis labels are shown left of the plot.
  bool showYAxis;

  /// Width reserved for y-axis labels.
  double yAxisWidth;

  /// Whether x-axis labels are shown under the plot.
  bool showXAxis;

  /// Show every n-th x-axis label.
  int xLabelEvery;

  /// Axis label color.
  ColorRGBA axisLabelColor;

  /// Axis label font size.
  double axisFontSize;

  /// Axis label font family (a Google Font name), or null for the default.
  String? axisFontFamily;

  /// Horizontal lines across the plot.
  List<ChartReferenceLine> referenceLines;

  /// Width of a category's bars as a fraction of the category width.
  double barWidthFraction;

  /// Maximum width of one bar (or one group of side-by-side bars).
  double maxBarWidth;

  /// Gap between side-by-side bars.
  double barGap;

  /// Corner radius of bar tops.
  double barRadius;

  /// For bar charts: categories whose bar series are all empty draw a dashed
  /// outline up to their first tick series (hours still to come).
  bool dashEmpty;

  /// Fill behind the selected category.
  ColorRGBA selectionColor;

  /// For line charts: number of x slots the lines span (points sit on slot
  /// boundaries), or 0 to use the data length.
  int xSlots;

  /// Timeline: field holding a segment's start (number).
  String startField;

  /// Timeline: field holding a segment's end (number).
  String endField;

  /// Timeline: field holding a segment's color (hex).
  String segmentColorField;

  /// Timeline: domain start.
  double domainMin;

  /// Timeline: domain end.
  double domainMax;

  /// Timeline: domain position of "now"; the rest is hatched. Null for none.
  double? nowValue;

  /// Timeline: color of the "now" marker. Null for [axisLabelColor].
  ColorRGBA? nowColor;

  /// Timeline: track color and hatch color.
  ColorRGBA trackColor;

  /// Timeline: divisions marked with ticks (e.g. hours).
  int divisions;

  /// Creates [ChartProperties].
  ChartProperties({
    this.chartType = ChartType.bar,
    this.series = kDefaultChartSeries,
    this.labelField = 'label',
    this.sampleData = kDefaultChartSampleData,
    this.minY,
    this.maxY,
    this.gridLines = 4,
    this.gridColor = const ColorRGBA(
      r: 41 / 255,
      g: 46 / 255,
      b: 51 / 255,
      a: 1,
    ),
    this.showYAxis = true,
    this.yAxisWidth = 36,
    this.showXAxis = true,
    this.xLabelEvery = 1,
    this.axisLabelColor = const ColorRGBA(
      r: 112 / 255,
      g: 120 / 255,
      b: 130 / 255,
      a: 1,
    ),
    this.axisFontSize = 10,
    this.axisFontFamily,
    this.referenceLines = const [],
    this.barWidthFraction = 0.62,
    this.maxBarWidth = 36,
    this.barGap = 2,
    this.barRadius = 0,
    this.dashEmpty = true,
    this.selectionColor = const ColorRGBA(r: 1, g: 212 / 255, b: 0, a: 0.08),
    this.xSlots = 0,
    this.startField = 'from',
    this.endField = 'to',
    this.segmentColorField = 'color',
    this.domainMin = 0,
    this.domainMax = 100,
    this.nowValue,
    this.nowColor,
    this.trackColor = const ColorRGBA(
      r: 18 / 255,
      g: 19 / 255,
      b: 22 / 255,
      a: 1,
    ),
    this.divisions = 8,
  });

  /// Duplicates these properties with the given overrides.
  ChartProperties copyWith({
    ChartType? chartType,
    List<ChartSeries>? series,
    String? labelField,
    List<Map<String, Object?>>? sampleData,
    double? minY,
    double? maxY,
    int? gridLines,
    ColorRGBA? gridColor,
    bool? showYAxis,
    double? yAxisWidth,
    bool? showXAxis,
    int? xLabelEvery,
    ColorRGBA? axisLabelColor,
    double? axisFontSize,
    String? axisFontFamily,
    List<ChartReferenceLine>? referenceLines,
    double? barWidthFraction,
    double? maxBarWidth,
    double? barGap,
    double? barRadius,
    bool? dashEmpty,
    ColorRGBA? selectionColor,
    int? xSlots,
    String? startField,
    String? endField,
    String? segmentColorField,
    double? domainMin,
    double? domainMax,
    double? nowValue,
    ColorRGBA? nowColor,
    ColorRGBA? trackColor,
    int? divisions,
  }) => ChartProperties(
    chartType: chartType ?? this.chartType,
    series: series ?? this.series,
    labelField: labelField ?? this.labelField,
    sampleData: sampleData ?? this.sampleData,
    minY: minY ?? this.minY,
    maxY: maxY ?? this.maxY,
    gridLines: gridLines ?? this.gridLines,
    gridColor: gridColor ?? this.gridColor,
    showYAxis: showYAxis ?? this.showYAxis,
    yAxisWidth: yAxisWidth ?? this.yAxisWidth,
    showXAxis: showXAxis ?? this.showXAxis,
    xLabelEvery: xLabelEvery ?? this.xLabelEvery,
    axisLabelColor: axisLabelColor ?? this.axisLabelColor,
    axisFontSize: axisFontSize ?? this.axisFontSize,
    axisFontFamily: axisFontFamily ?? this.axisFontFamily,
    referenceLines: referenceLines ?? this.referenceLines,
    barWidthFraction: barWidthFraction ?? this.barWidthFraction,
    maxBarWidth: maxBarWidth ?? this.maxBarWidth,
    barGap: barGap ?? this.barGap,
    barRadius: barRadius ?? this.barRadius,
    dashEmpty: dashEmpty ?? this.dashEmpty,
    selectionColor: selectionColor ?? this.selectionColor,
    xSlots: xSlots ?? this.xSlots,
    startField: startField ?? this.startField,
    endField: endField ?? this.endField,
    segmentColorField: segmentColorField ?? this.segmentColorField,
    domainMin: domainMin ?? this.domainMin,
    domainMax: domainMax ?? this.domainMax,
    nowValue: nowValue ?? this.nowValue,
    nowColor: nowColor ?? this.nowColor,
    trackColor: trackColor ?? this.trackColor,
    divisions: divisions ?? this.divisions,
  );

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'labelField': StringFieldAccess(
      'Label Field',
      'Field holding x-axis labels',
      () => labelField,
      (v) => labelField = v,
    ),
    'gridLines': NumFieldAccess<int>(
      'Grid Lines',
      'Horizontal grid intervals',
      () => gridLines,
      (v) => gridLines = v,
    ),
    'gridColor': ColorFieldAccess<ColorRGBA>(
      'Grid Color',
      'Grid line color',
      () => gridColor,
      (v) => gridColor = v,
    ),
    'showYAxis': BoolFieldAccess(
      'Y Axis',
      'Show y-axis labels',
      () => showYAxis,
      (v) => showYAxis = v,
    ),
    'showXAxis': BoolFieldAccess(
      'X Axis',
      'Show x-axis labels',
      () => showXAxis,
      (v) => showXAxis = v,
    ),
    'axisLabelColor': ColorFieldAccess<ColorRGBA>(
      'Axis Color',
      'Axis label color',
      () => axisLabelColor,
      (v) => axisLabelColor = v,
    ),
    'maxBarWidth': NumFieldAccess<double>(
      'Max Bar Width',
      'Widest a bar gets',
      () => maxBarWidth,
      (v) => maxBarWidth = v,
    ),
    'dashEmpty': BoolFieldAccess(
      'Dash Empty',
      'Dashed outline for empty categories',
      () => dashEmpty,
      (v) => dashEmpty = v,
    ),
  };

  @override
  List<Object?> get props => [
    chartType,
    series,
    labelField,
    sampleData,
    minY,
    maxY,
    gridLines,
    gridColor,
    showYAxis,
    yAxisWidth,
    showXAxis,
    xLabelEvery,
    axisLabelColor,
    axisFontSize,
    axisFontFamily,
    referenceLines,
    barWidthFraction,
    maxBarWidth,
    barGap,
    barRadius,
    dashEmpty,
    selectionColor,
    xSlots,
    startField,
    endField,
    segmentColorField,
    domainMin,
    domainMax,
    nowValue,
    nowColor,
    trackColor,
    divisions,
  ];

  /// Creates [ChartProperties] from JSON.
  factory ChartProperties.fromJson(Map json) => _$ChartPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChartPropertiesOmitDefaults(this, _$ChartPropertiesToJson(this));
}
