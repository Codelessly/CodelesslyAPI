import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import '../node_json_converter.dart';
import 'nodes.dart';

part 'plot_chart_node.g.dart';

/// Default width of a chart.
const double kPlotChartDefaultWidth = 320;

/// Default height of a chart.
const double kPlotChartDefaultHeight = 140;

/// Default color of a chart's line.
const ColorRGBA kPlotChartDefaultLineColor = ColorRGBA(
  r: 0x1F / 255,
  g: 0x6F / 255,
  b: 0x78 / 255,
  a: 1,
);

/// Fill color of the sample chart.
const ColorRGBA kPlotChartSampleFillColor = ColorRGBA(
  r: 0x1F / 255,
  g: 0x6F / 255,
  b: 0x78 / 255,
  a: 0x26 / 255,
);

/// Default color of a chart's reference line.
const ColorRGBA kPlotChartDefaultReferenceColor = ColorRGBA(
  r: 0xF2 / 255,
  g: 0x54 / 255,
  b: 0x2D / 255,
  a: 1,
);

/// A line/area chart that plots [PlotChartProperties.points] evenly across an x
/// domain and lets the user select an x value by tapping or dragging on it.
///
/// `variables['points']`, `variables['markers']` and `variables['selectedX']`
/// bind the data, the markers and the selection to variables. Selecting an
/// x value writes it to the bound `selectedX` variable and fires
/// [TriggerType.changed] with it.
@FlutterNode('CodelesslyPlotChart', family: 'codelessly', nodeType: 'chart', variant: 'plot')
@JsonSerializable()
class PlotChartNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'chart';

  /// Holds configurable properties of the chart.
  @override
  covariant PlotChartProperties properties;

  /// The selected x value: the start of the selection band, which is
  /// [PlotChartProperties.selectionStep] wide. Null shows no selection.
  @FlutterProp('selectedX', type: 'number', group: 'Selection', control: 'number')
  double? selectedX;

  /// Creates a chart with sample data, for previews.
  PlotChartNode.empty()
    : properties = PlotChartProperties.sample(),
      selectedX = null,
      super(
        id: 'chart',
        name: 'Chart',
        basicBoxLocal: NodeBox(
          0,
          0,
          kPlotChartDefaultWidth,
          kPlotChartDefaultHeight,
        ),
      );

  /// Creates a chart from the given properties, for previews.
  PlotChartNode.fromProperties(this.properties)
    : selectedX = null,
      super(
        id: 'chart',
        name: 'Chart',
        basicBoxLocal: NodeBox(
          0,
          0,
          kPlotChartDefaultWidth,
          kPlotChartDefaultHeight,
        ),
      );

  /// Creates a [PlotChartNode] with the given data.
  PlotChartNode({
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
    // Custom properties.
    required this.properties,
    this.selectedX,
    super.variables,
    super.multipleVariables,
  });

  @override
  bool get supportsPadding => false;

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<PlotChartProperties>(
      'Properties',
      'Properties of the chart.',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    if (selectedX case final double selectedX)
      DoubleValue(name: 'selectedX', value: selectedX),
  ];

  @override
  List<Object?> get props => [
    ...super.props,
    properties,
    selectedX,
    variables,
    multipleVariables,
  ];

  /// Creates a [PlotChartNode] from JSON data.
  factory PlotChartNode.fromJson(Map json) {
    NodeJsonConverter.validateChartWire(json, expectedType: 'plot');
    return _$PlotChartNodeFromJson(json);
  }

  @override
  Map toJson() => {
    ..._$PlotChartNodeOmitDefaults(this, _$PlotChartNodeToJson(this)),
    'type': 'chart',
    'chartKind': 'plot',
  };
}

/// Where a marker's label sits relative to its dot.
enum PlotChartMarkerPosition {
  /// Above the dot.
  above,

  /// Below the dot.
  below;

  /// Displayable string representation.
  String get prettify => switch (this) {
    PlotChartMarkerPosition.above => 'Above',
    PlotChartMarkerPosition.below => 'Below',
  };
}

/// The style of a chart's text.
@JsonSerializable()
class PlotChartTextStyle extends Equatable with SerializableMixin {
  /// Font size.
  final double fontSize;

  /// Text color. Markers paint their label in their own color instead.
  final ColorRGBA color;

  /// Font family. Null uses the app's default font.
  final String? fontFamily;

  /// Font weight, from 100 to 900.
  final int fontWeight;

  /// Line height as a multiple of [fontSize]. Null uses the font's own.
  final double? height;

  /// Creates a [PlotChartTextStyle] with the given data.
  const PlotChartTextStyle({
    this.fontSize = 10,
    this.color = ColorRGBA.black54,
    this.fontFamily,
    this.fontWeight = 400,
    this.height,
  });

  /// Duplicates this [PlotChartTextStyle] with the given data overrides.
  PlotChartTextStyle copyWith({
    double? fontSize,
    ColorRGBA? color,
    String? fontFamily,
    int? fontWeight,
    double? height,
  }) => PlotChartTextStyle(
    fontSize: fontSize ?? this.fontSize,
    color: color ?? this.color,
    fontFamily: fontFamily ?? this.fontFamily,
    fontWeight: fontWeight ?? this.fontWeight,
    height: height ?? this.height,
  );

  @override
  List<Object?> get props => [fontSize, color, fontFamily, fontWeight, height];

  /// Creates a [PlotChartTextStyle] from JSON data.
  factory PlotChartTextStyle.fromJson(Map json) =>
      _$PlotChartTextStyleFromJson(json);

  @override
  Map toJson() =>
      _$PlotChartTextStyleOmitDefaults(this, _$PlotChartTextStyleToJson(this));
}

/// A label on a chart's x axis.
@JsonSerializable()
class PlotChartLabel extends Equatable with SerializableMixin {
  /// The x value the label is centered on.
  final double x;

  /// The text of the label.
  final String label;

  /// Creates a [PlotChartLabel] with the given data.
  const PlotChartLabel({required this.x, required this.label});

  @override
  List<Object?> get props => [x, label];

  /// Creates a [PlotChartLabel] from JSON data.
  factory PlotChartLabel.fromJson(Map json) => _$PlotChartLabelFromJson(json);

  @override
  Map toJson() =>
      _$PlotChartLabelOmitDefaults(this, _$PlotChartLabelToJson(this));
}

/// A shaded x range of a chart, painted behind the curve.
@JsonSerializable()
class PlotChartRange extends Equatable with SerializableMixin {
  /// Where the range starts on the x axis.
  final double from;

  /// Where the range ends on the x axis.
  final double to;

  /// Color of the range.
  final ColorRGBA color;

  /// Creates a [PlotChartRange] with the given data.
  const PlotChartRange({
    required this.from,
    required this.to,
    this.color = ColorRGBA.black10,
  });

  @override
  List<Object?> get props => [from, to, color];

  /// Creates a [PlotChartRange] from JSON data.
  factory PlotChartRange.fromJson(Map json) => _$PlotChartRangeFromJson(json);

  @override
  Map toJson() =>
      _$PlotChartRangeOmitDefaults(this, _$PlotChartRangeToJson(this));
}

/// A labeled dot on a chart.
@JsonSerializable()
class PlotChartMarker extends Equatable with SerializableMixin {
  /// The x value of the dot.
  final double x;

  /// The y value of the dot. Null puts the dot on the curve.
  final double? y;

  /// Text shown next to the dot.
  final String label;

  /// Color of the dot and its label.
  final ColorRGBA color;

  /// Where the label sits relative to the dot.
  final PlotChartMarkerPosition position;

  /// Creates a [PlotChartMarker] with the given data.
  const PlotChartMarker({
    required this.x,
    this.y,
    this.label = '',
    this.color = ColorRGBA.black,
    this.position = PlotChartMarkerPosition.above,
  });

  @override
  List<Object?> get props => [x, y, label, color, position];

  /// Creates a [PlotChartMarker] from JSON data.
  factory PlotChartMarker.fromJson(Map json) => _$PlotChartMarkerFromJson(json);

  @override
  Map toJson() =>
      _$PlotChartMarkerOmitDefaults(this, _$PlotChartMarkerToJson(this));
}

/// Holds configurable properties of a [PlotChartNode].
@JsonSerializable()
class PlotChartProperties extends CustomProperties with FieldsHolder {
  /// The y values, spread evenly from [xMin] to [xMax].
  List<double> points;

  /// The x value of the first point.
  double xMin;

  /// The x value of the last point.
  double xMax;

  /// The y value at the bottom of the plot. Null uses the smallest point.
  double? yMin;

  /// The y value at the top of the plot. Null uses the largest point.
  double? yMax;

  /// Space kept above [yMax] and below [yMin] inside the plot, in pixels.
  double plotInset;

  /// Color of the line.
  ColorRGBA lineColor;

  /// Width of the line. Zero draws no line.
  double lineWidth;

  /// Color of the area under the line. Null draws no area.
  ColorRGBA? fillColor;

  /// Whether to draw the line as a smooth curve instead of straight segments.
  bool smooth;

  /// Draws a vertical gridline every [gridStepX] x units, starting at [xMin].
  /// Null draws no grid.
  double? gridStepX;

  /// Color of the gridlines.
  ColorRGBA gridColor;

  /// Color of the line along the bottom of the plot. Null draws none.
  ColorRGBA? axisColor;

  /// Labels along the bottom of the chart. When empty, the gridlines
  /// between [xMin] and [xMax] are labeled with [gridLabels] in order, or
  /// with their x value.
  List<PlotChartLabel> xLabels;

  /// Labels for the gridlines between [xMin] and [xMax], in order, used when
  /// [xLabels] is empty.
  List<String> gridLabels;

  /// Style of the axis labels.
  PlotChartTextStyle labelStyle;

  /// Height of the strip under the plot that holds the axis labels. Zero
  /// shows no labels.
  double labelHeight;

  /// Shaded x ranges painted behind the curve.
  List<PlotChartRange> ranges;

  /// Labeled dots on the curve.
  List<PlotChartMarker> markers;

  /// Radius of the marker dots.
  double markerRadius;

  /// Style of the marker labels. Each label takes its marker's color.
  PlotChartTextStyle markerLabelStyle;

  /// The x value of a vertical reference line, e.g. now. Null draws none.
  double? referenceX;

  /// Color of the reference line.
  ColorRGBA referenceColor;

  /// Width of the reference line.
  double referenceWidth;

  /// Whether the reference line is dashed.
  bool referenceDashed;

  /// Whether tapping or dragging on the chart selects an x value.
  bool selectable;

  /// Width of the selection band, and the step selections snap to from
  /// [xMin]. Zero selects any x value.
  double selectionStep;

  /// The smallest x value that can be selected. Null allows [xMin].
  double? selectionMin;

  /// The largest x value that can be selected. Null allows the last step
  /// before [xMax].
  double? selectionMax;

  /// Color of the selection band.
  ColorRGBA selectionColor;

  /// Color of the vertical line through the middle of the selection.
  ColorRGBA selectionLineColor;

  /// Width of the selection line. Zero draws no line.
  double selectionLineWidth;

  /// Radius of the dot on the curve in the middle of the selection. Zero
  /// draws no dot.
  double selectionDotRadius;

  /// Fill color of the selection dot.
  ColorRGBA selectionDotColor;

  /// Outline color of the selection dot.
  ColorRGBA selectionDotStrokeColor;

  /// Outline width of the selection dot.
  double selectionDotStrokeWidth;

  /// Creates a [PlotChartProperties] with the given data.
  PlotChartProperties({
    this.points = const [],
    this.xMin = 0,
    this.xMax = 1,
    this.yMin,
    this.yMax,
    this.plotInset = 8,
    this.lineColor = kPlotChartDefaultLineColor,
    this.lineWidth = 2,
    this.fillColor,
    this.smooth = false,
    this.gridStepX,
    this.gridColor = ColorRGBA.black10,
    this.axisColor,
    this.xLabels = const [],
    this.gridLabels = const [],
    this.labelStyle = const PlotChartTextStyle(),
    this.labelHeight = 16,
    this.ranges = const [],
    this.markers = const [],
    this.markerRadius = 3.5,
    this.markerLabelStyle = const PlotChartTextStyle(fontWeight: 700),
    this.referenceX,
    this.referenceColor = kPlotChartDefaultReferenceColor,
    this.referenceWidth = 1.5,
    this.referenceDashed = true,
    this.selectable = true,
    this.selectionStep = 1,
    this.selectionMin,
    this.selectionMax,
    this.selectionColor = ColorRGBA.black10,
    this.selectionLineColor = ColorRGBA.black,
    this.selectionLineWidth = 1.5,
    this.selectionDotRadius = 6.5,
    this.selectionDotColor = ColorRGBA.white,
    this.selectionDotStrokeColor = ColorRGBA.black,
    this.selectionDotStrokeWidth = 2.5,
  });

  /// A chart with a sample wave, so a new chart looks like one.
  factory PlotChartProperties.sample() => PlotChartProperties(
    points: const [
      2, 2.6, 3.4, 4.2, 4.7, 4.8, 4.4, 3.7, 2.8, 2.0, 1.4, 1.1, 1.2, //
      1.7, 2.5, 3.3, 4.0, 4.3, 4.2, 3.7, 3.0, 2.3, 1.8, 1.6, 1.8,
    ],
    xMin: 0,
    xMax: 24,
    yMin: 0,
    yMax: 5.5,
    fillColor: kPlotChartSampleFillColor,
    gridStepX: 6,
    gridLabels: const ['6a', '12p', '6p'],
    selectionStep: 1,
  );

  /// Duplicates this [PlotChartProperties] with the given data overrides.
  PlotChartProperties copyWith({
    List<double>? points,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    double? plotInset,
    ColorRGBA? lineColor,
    double? lineWidth,
    ColorRGBA? fillColor,
    bool? smooth,
    double? gridStepX,
    ColorRGBA? gridColor,
    ColorRGBA? axisColor,
    List<PlotChartLabel>? xLabels,
    List<String>? gridLabels,
    PlotChartTextStyle? labelStyle,
    double? labelHeight,
    List<PlotChartRange>? ranges,
    List<PlotChartMarker>? markers,
    double? markerRadius,
    PlotChartTextStyle? markerLabelStyle,
    double? referenceX,
    ColorRGBA? referenceColor,
    double? referenceWidth,
    bool? referenceDashed,
    bool? selectable,
    double? selectionStep,
    double? selectionMin,
    double? selectionMax,
    ColorRGBA? selectionColor,
    ColorRGBA? selectionLineColor,
    double? selectionLineWidth,
    double? selectionDotRadius,
    ColorRGBA? selectionDotColor,
    ColorRGBA? selectionDotStrokeColor,
    double? selectionDotStrokeWidth,
  }) => PlotChartProperties(
    points: points ?? this.points,
    xMin: xMin ?? this.xMin,
    xMax: xMax ?? this.xMax,
    yMin: yMin ?? this.yMin,
    yMax: yMax ?? this.yMax,
    plotInset: plotInset ?? this.plotInset,
    lineColor: lineColor ?? this.lineColor,
    lineWidth: lineWidth ?? this.lineWidth,
    fillColor: fillColor ?? this.fillColor,
    smooth: smooth ?? this.smooth,
    gridStepX: gridStepX ?? this.gridStepX,
    gridColor: gridColor ?? this.gridColor,
    axisColor: axisColor ?? this.axisColor,
    xLabels: xLabels ?? this.xLabels,
    gridLabels: gridLabels ?? this.gridLabels,
    labelStyle: labelStyle ?? this.labelStyle,
    labelHeight: labelHeight ?? this.labelHeight,
    ranges: ranges ?? this.ranges,
    markers: markers ?? this.markers,
    markerRadius: markerRadius ?? this.markerRadius,
    markerLabelStyle: markerLabelStyle ?? this.markerLabelStyle,
    referenceX: referenceX ?? this.referenceX,
    referenceColor: referenceColor ?? this.referenceColor,
    referenceWidth: referenceWidth ?? this.referenceWidth,
    referenceDashed: referenceDashed ?? this.referenceDashed,
    selectable: selectable ?? this.selectable,
    selectionStep: selectionStep ?? this.selectionStep,
    selectionMin: selectionMin ?? this.selectionMin,
    selectionMax: selectionMax ?? this.selectionMax,
    selectionColor: selectionColor ?? this.selectionColor,
    selectionLineColor: selectionLineColor ?? this.selectionLineColor,
    selectionLineWidth: selectionLineWidth ?? this.selectionLineWidth,
    selectionDotRadius: selectionDotRadius ?? this.selectionDotRadius,
    selectionDotColor: selectionDotColor ?? this.selectionDotColor,
    selectionDotStrokeColor:
        selectionDotStrokeColor ?? this.selectionDotStrokeColor,
    selectionDotStrokeWidth:
        selectionDotStrokeWidth ?? this.selectionDotStrokeWidth,
  );

  /// Snaps [x] to the selection step and clamps it to the selectable range.
  double snapSelection(double x) {
    final double step = selectionStep;
    double snapped = step > 0 ? xMin + ((x - xMin) / step).floor() * step : x;
    final double lowest = selectionMin ?? xMin;
    final double highest =
        selectionMax ?? (step > 0 ? xMax - step : xMax).clamp(lowest, xMax);
    if (snapped < lowest) snapped = lowest;
    if (snapped > highest) snapped = highest;
    // Steps like 0.1 accumulate float error; keep 10 decimals at most.
    return double.parse(snapped.toStringAsFixed(10));
  }

  /// The y value of the curve at [x], interpolated between points.
  double? valueAt(double x, [List<double>? points]) {
    final List<double> values = points ?? this.points;
    if (values.isEmpty) return null;
    if (values.length == 1 || xMax == xMin) return values.first;
    final double position =
        ((x - xMin) / (xMax - xMin)).clamp(0.0, 1.0) * (values.length - 1);
    final int index = position.floor().clamp(0, values.length - 2);
    final double t = position - index;
    return values[index] + (values[index + 1] - values[index]) * t;
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'lineColor': ColorFieldAccess<ColorRGBA>(
      'Line Color',
      'Color of the line',
      () => lineColor,
      (value) => lineColor = value,
    ),
    'lineWidth': NumFieldAccess<double>(
      'Line Width',
      'Width of the line',
      () => lineWidth,
      (value) => lineWidth = value,
    ),
    'smooth': BoolFieldAccess(
      'Smooth',
      'Whether to draw the line as a smooth curve',
      () => smooth,
      (value) => smooth = value,
    ),
    'gridColor': ColorFieldAccess<ColorRGBA>(
      'Grid Color',
      'Color of the gridlines',
      () => gridColor,
      (value) => gridColor = value,
    ),
    'selectionStep': NumFieldAccess<double>(
      'Selection Step',
      'Width of the selection band',
      () => selectionStep,
      (value) => selectionStep = value,
    ),
    'selectable': BoolFieldAccess(
      'Selectable',
      'Whether tapping or dragging on the chart selects an x value',
      () => selectable,
      (value) => selectable = value,
    ),
  };

  @override
  List<Object?> get props => [
    points,
    xMin,
    xMax,
    yMin,
    yMax,
    plotInset,
    lineColor,
    lineWidth,
    fillColor,
    smooth,
    gridStepX,
    gridColor,
    axisColor,
    xLabels,
    gridLabels,
    labelStyle,
    labelHeight,
    ranges,
    markers,
    markerRadius,
    markerLabelStyle,
    referenceX,
    referenceColor,
    referenceWidth,
    referenceDashed,
    selectable,
    selectionStep,
    selectionMin,
    selectionMax,
    selectionColor,
    selectionLineColor,
    selectionLineWidth,
    selectionDotRadius,
    selectionDotColor,
    selectionDotStrokeColor,
    selectionDotStrokeWidth,
  ];

  /// Creates a [PlotChartProperties] from JSON data.
  factory PlotChartProperties.fromJson(Map json) =>
      _$PlotChartPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlotChartPropertiesOmitDefaults(
    this,
    _$PlotChartPropertiesToJson(this),
  );
}
