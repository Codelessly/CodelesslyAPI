import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'line_chart_node.g.dart';

/// The default width of a line chart.
const double kLineChartDefaultWidth = 360;

/// The default height of a line chart.
const double kLineChartDefaultHeight = 240;

/// A data-driven line chart: a series of points drawn as a polyline or a
/// Catmull-Rom curve with an area gradient, optional bands, grid lines,
/// reference lines, markers, vertical lines and an interactive scrub cursor
/// with a readout card.
///
/// Everything that depends on data is bound through [variables], each a
/// path such as `${chart.points}` or a formula such as `${= ... }`:
///
/// - `data`: the series, a list of maps. Each item's x is read from
///   [LineChartProperties.xField] and y from [LineChartProperties.yField].
///   x is a number or a date (an ISO string such as `2026-10-22 00:30` or
///   `2026-10-22T00:30:00`, read as wall-clock time without any timezone
///   conversion). y is a number or a numeric string.
/// - `xMin`, `xMax`, `yMin`, `yMax`: the domain. Each defaults to
///   [LineChartProperties.xMin] etc., then to the data's extent. x values
///   may be dates.
/// - `bands`: full-height rectangles drawn first, e.g. night shading.
///   `[{"from": x, "to": x, "color": "#2A3A44", "opacity": 0.08}]`
/// - `yTicks`: horizontal grid lines with labels right-aligned 10 px left
///   of the plot. `[{"y": 0, "label": "0", "color": "#CFC3AA"}]`; `label`
///   and `color` are optional (the color defaults to
///   [LineChartProperties.gridColor], or
///   [LineChartProperties.zeroLineColor] when y is 0).
/// - `areaBands`: parts of the area under the curve, inside x in
///   [from, to] and below y = `below`, filled with `color`, plus an
///   optional 4 px bar on the x axis in `barColor`.
///   `[{"from": x, "to": x, "below": 1.0, "color": "#D9573B",
///   "opacity": 0.38, "barColor": "#D9573B"}]`
/// - `referenceLines`: dashed horizontal lines across the plot.
///   `[{"y": 1.0, "color": "#D9573B", "width": 1.5, "dash": [5, 5]}]`
/// - `xTicks`: ticks and labels below the x axis. The first label is
///   left-aligned to its tick, the last right-aligned, the rest centered.
///   `[{"x": "2026-10-22 00:00", "label": "12a"}]`
/// - `markers`: points with a circle and a label above or below.
///   `[{"x": x, "y": 5.0, "label": "H 5.0", "filled": false,
///   "above": true}]`
/// - `verticalLines`: dashed vertical lines with an optional tag above the
///   plot and an optional dot on the curve. `[{"x": x, "color": "#1F2B2E",
///   "dash": [3, 3], "label": "NOW", "dotOnCurve": true,
///   "dotColor": "#D9573B"}]`
/// - `semanticLabel`: the chart's accessibility label.
/// - Any color property, e.g. `lineColor`, can be bound too.
///
/// Colors in the lists are hex strings (`#RRGGBB` or `#AARRGGBB`).
@FlutterNode('CodelesslyLineChart', family: 'codelessly', nodeType: 'lineChart')
@JsonSerializable()
class LineChartNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'lineChart';

  /// Holds configurable properties of the chart.
  @override
  covariant LineChartProperties properties;

  @override
  bool get supportsPadding => false;

  /// Creates a line chart preview. Strictly used for previews, e.g. in the
  /// components panel.
  LineChartNode.empty()
    : properties = LineChartProperties(),
      super(
        id: 'lineChart',
        name: 'Line Chart',
        basicBoxLocal: NodeBox(
          0,
          0,
          kLineChartDefaultWidth,
          kLineChartDefaultHeight,
        ),
      );

  /// Creates a line chart preview from the given [properties].
  LineChartNode.fromProperties(this.properties)
    : super(
        id: 'lineChart',
        name: 'Line Chart',
        basicBoxLocal: NodeBox(
          0,
          0,
          kLineChartDefaultWidth,
          kLineChartDefaultHeight,
        ),
      );

  /// Creates a [LineChartNode] with the given data. [properties] defaults to
  /// [LineChartProperties.new].
  LineChartNode({
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
    LineChartProperties? properties,
    super.variables,
    super.multipleVariables,
  }) : properties = properties ?? LineChartProperties() {
    setVariablesMixin(
      variables: variables,
      multipleVariables: multipleVariables,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<LineChartProperties>(
      'Properties',
      'Properties of the line chart',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<Object?> get props => [
    ...super.props,
    properties,
    variables,
    multipleVariables,
  ];

  /// Creates a [LineChartNode] from a JSON object.
  factory LineChartNode.fromJson(Map json) => _$LineChartNodeFromJson(json);

  @override
  Map toJson() =>
      _$LineChartNodeOmitDefaults(this, _$LineChartNodeToJson(this));
}

/// Holds configurable properties of a [LineChartNode]. See [LineChartNode]
/// for the data bindings and the JSON shapes of the list bindings.
@JsonSerializable()
class LineChartProperties extends CustomProperties with FieldsHolder {
  /// The key of each data item that holds its x value.
  String xField;

  /// The key of each data item that holds its y value.
  String yField;

  /// The lower bound of the x axis. Defaults to the data's minimum x.
  /// Bind `xMin` to give a date.
  double? xMin;

  /// The upper bound of the x axis. Defaults to the data's maximum x.
  /// Bind `xMax` to give a date.
  double? xMax;

  /// The lower bound of the y axis. Defaults to the data's minimum y.
  double? yMin;

  /// The upper bound of the y axis. Defaults to the data's maximum y.
  double? yMax;

  /// Space between the left edge and the plot, holding the y labels.
  double padLeft;

  /// Space between the plot and the right edge.
  double padRight;

  /// Space between the top edge and the plot, holding vertical line tags.
  double padTop;

  /// Space between the plot and the bottom edge, holding the x labels.
  double padBottom;

  /// Whether the curve is a Catmull-Rom spline through the points instead
  /// of a polyline.
  @FlutterProp(
    'smooth',
    type: 'boolean',
    group: 'Appearance',
    control: 'switch',
    field: 'properties.smooth',
  )
  bool smooth;

  /// Color of the curve, marker outlines and curve dots.
  ColorRGBA lineColor;

  /// Stroke width of the curve.
  double lineWidth;

  /// Color at the top of the plot of the area under the curve.
  ColorRGBA areaTopColor;

  /// Color at the bottom of the plot of the area under the curve.
  ColorRGBA areaBottomColor;

  /// Color of horizontal grid lines.
  ColorRGBA gridColor;

  /// Color of the horizontal grid line at y = 0.
  ColorRGBA zeroLineColor;

  /// Color of the x axis, its ticks and, by default, of vertical lines.
  ColorRGBA axisColor;

  /// Fill of markers that are not filled.
  ColorRGBA markerHollowColor;

  /// Background of vertical line tags.
  ColorRGBA tagBackground;

  /// Color of the scrub cursor's line and ring.
  ColorRGBA cursorColor;

  /// Fill of the scrub cursor's ring.
  ColorRGBA cursorRingFill;

  /// Background of the scrub readout card.
  ColorRGBA tooltipBackground;

  /// Color of the readout card's (3, 3) offset shadow.
  ColorRGBA tooltipShadowColor;

  /// Text above the y labels, e.g. a unit like "FT".
  String yAxisTitle;

  /// Style of x and y axis labels.
  TextProp axisLabelStyle;

  /// Style of [yAxisTitle].
  TextProp axisTitleStyle;

  /// Style of marker labels.
  TextProp markerLabelStyle;

  /// Style of vertical line tags.
  TextProp tagTextStyle;

  /// Style of the readout's first line, the x value.
  TextProp tooltipLabelStyle;

  /// Style of the readout's second line, the y value.
  TextProp tooltipValueStyle;

  /// Whether hovering, tapping, dragging or the arrow keys move a cursor
  /// that reads out the curve.
  bool scrubEnabled;

  /// How far the arrow keys move the cursor, in x units; minutes for a date
  /// axis.
  double scrubStep;

  /// Date pattern of the readout's x value on a date axis, as in the
  /// `formatDate` formula function, e.g. `h:mm a`.
  String tooltipXFormat;

  /// Factor the readout applies to y, e.g. 0.3048 for feet to metres.
  double tooltipYScale;

  /// Decimals of the readout's y value.
  int tooltipYDecimals;

  /// Text after the readout's y value, e.g. " ft".
  String tooltipYSuffix;

  /// Whether the readout ends with " ↑" or " ↓" for a rising or falling
  /// curve.
  bool tooltipTrend;

  /// The chart's accessibility label. Bind `semanticLabel` to compute it.
  String semanticLabel;

  /// Creates [LineChartProperties] with the given data. The paints of the
  /// default text styles have fixed ids, so default properties are equal.
  LineChartProperties({
    this.xField = 'x',
    this.yField = 'y',
    this.xMin,
    this.xMax,
    this.yMin,
    this.yMax,
    this.padLeft = 44,
    this.padRight = 14,
    this.padTop = 30,
    this.padBottom = 30,
    this.smooth = false,
    this.lineColor = ColorRGBA.black,
    this.lineWidth = 2,
    this.areaTopColor = ColorRGBA.black10,
    this.areaBottomColor = ColorRGBA.transparent,
    this.gridColor = ColorRGBA.black10,
    this.zeroLineColor = ColorRGBA.black54,
    this.axisColor = ColorRGBA.black,
    this.markerHollowColor = ColorRGBA.white,
    this.tagBackground = ColorRGBA.black,
    this.cursorColor = ColorRGBA.black,
    this.cursorRingFill = ColorRGBA.white,
    this.tooltipBackground = ColorRGBA.black,
    this.tooltipShadowColor = ColorRGBA.transparent,
    this.yAxisTitle = '',
    TextProp? axisLabelStyle,
    TextProp? axisTitleStyle,
    TextProp? markerLabelStyle,
    TextProp? tagTextStyle,
    TextProp? tooltipLabelStyle,
    TextProp? tooltipValueStyle,
    this.scrubEnabled = false,
    this.scrubStep = 1,
    this.tooltipXFormat = 'h:mm a',
    this.tooltipYScale = 1,
    this.tooltipYDecimals = 1,
    this.tooltipYSuffix = '',
    this.tooltipTrend = false,
    this.semanticLabel = '',
  }) : axisLabelStyle =
           axisLabelStyle ??
           TextProp(
             fontSize: 11,
             fills: [ColorRGBA.black54.toPaint('axisLabel')],
           ),
       axisTitleStyle =
           axisTitleStyle ??
           TextProp(
             fontSize: 10,
             fills: [ColorRGBA.black54.toPaint('axisTitle')],
           ),
       markerLabelStyle =
           markerLabelStyle ??
           TextProp(
             fontSize: 11,
             fills: [ColorRGBA.black.toPaint('markerLabel')],
           ),
       tagTextStyle =
           tagTextStyle ??
           TextProp(fontSize: 10, fills: [ColorRGBA.white.toPaint('tagText')]),
       tooltipLabelStyle =
           tooltipLabelStyle ??
           TextProp(
             fontSize: 10,
             fills: [ColorRGBA.white.toPaint('tooltipLabel', 0.7)],
           ),
       tooltipValueStyle =
           tooltipValueStyle ??
           TextProp(
             fontSize: 15,
             fills: [ColorRGBA.white.toPaint('tooltipValue')],
           );

  /// Duplicates these properties with the given data overrides.
  LineChartProperties copyWith({
    String? xField,
    String? yField,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    double? padLeft,
    double? padRight,
    double? padTop,
    double? padBottom,
    bool? smooth,
    ColorRGBA? lineColor,
    double? lineWidth,
    ColorRGBA? areaTopColor,
    ColorRGBA? areaBottomColor,
    ColorRGBA? gridColor,
    ColorRGBA? zeroLineColor,
    ColorRGBA? axisColor,
    ColorRGBA? markerHollowColor,
    ColorRGBA? tagBackground,
    ColorRGBA? cursorColor,
    ColorRGBA? cursorRingFill,
    ColorRGBA? tooltipBackground,
    ColorRGBA? tooltipShadowColor,
    String? yAxisTitle,
    TextProp? axisLabelStyle,
    TextProp? axisTitleStyle,
    TextProp? markerLabelStyle,
    TextProp? tagTextStyle,
    TextProp? tooltipLabelStyle,
    TextProp? tooltipValueStyle,
    bool? scrubEnabled,
    double? scrubStep,
    String? tooltipXFormat,
    double? tooltipYScale,
    int? tooltipYDecimals,
    String? tooltipYSuffix,
    bool? tooltipTrend,
    String? semanticLabel,
  }) => LineChartProperties(
    xField: xField ?? this.xField,
    yField: yField ?? this.yField,
    xMin: xMin ?? this.xMin,
    xMax: xMax ?? this.xMax,
    yMin: yMin ?? this.yMin,
    yMax: yMax ?? this.yMax,
    padLeft: padLeft ?? this.padLeft,
    padRight: padRight ?? this.padRight,
    padTop: padTop ?? this.padTop,
    padBottom: padBottom ?? this.padBottom,
    smooth: smooth ?? this.smooth,
    lineColor: lineColor ?? this.lineColor,
    lineWidth: lineWidth ?? this.lineWidth,
    areaTopColor: areaTopColor ?? this.areaTopColor,
    areaBottomColor: areaBottomColor ?? this.areaBottomColor,
    gridColor: gridColor ?? this.gridColor,
    zeroLineColor: zeroLineColor ?? this.zeroLineColor,
    axisColor: axisColor ?? this.axisColor,
    markerHollowColor: markerHollowColor ?? this.markerHollowColor,
    tagBackground: tagBackground ?? this.tagBackground,
    cursorColor: cursorColor ?? this.cursorColor,
    cursorRingFill: cursorRingFill ?? this.cursorRingFill,
    tooltipBackground: tooltipBackground ?? this.tooltipBackground,
    tooltipShadowColor: tooltipShadowColor ?? this.tooltipShadowColor,
    yAxisTitle: yAxisTitle ?? this.yAxisTitle,
    axisLabelStyle: axisLabelStyle ?? this.axisLabelStyle,
    axisTitleStyle: axisTitleStyle ?? this.axisTitleStyle,
    markerLabelStyle: markerLabelStyle ?? this.markerLabelStyle,
    tagTextStyle: tagTextStyle ?? this.tagTextStyle,
    tooltipLabelStyle: tooltipLabelStyle ?? this.tooltipLabelStyle,
    tooltipValueStyle: tooltipValueStyle ?? this.tooltipValueStyle,
    scrubEnabled: scrubEnabled ?? this.scrubEnabled,
    scrubStep: scrubStep ?? this.scrubStep,
    tooltipXFormat: tooltipXFormat ?? this.tooltipXFormat,
    tooltipYScale: tooltipYScale ?? this.tooltipYScale,
    tooltipYDecimals: tooltipYDecimals ?? this.tooltipYDecimals,
    tooltipYSuffix: tooltipYSuffix ?? this.tooltipYSuffix,
    tooltipTrend: tooltipTrend ?? this.tooltipTrend,
    semanticLabel: semanticLabel ?? this.semanticLabel,
  );

  @override
  FieldsMap generateFields() {
    NumFieldAccess<double> number(
      String label,
      String description,
      double Function() get,
      void Function(double) set,
    ) => NumFieldAccess<double>(label, description, get, set);
    ColorFieldAccess<ColorRGBA> color(
      String label,
      String description,
      ColorRGBA Function() get,
      void Function(ColorRGBA) set,
    ) => ColorFieldAccess<ColorRGBA>(label, description, get, set);
    TextStyleFieldAccess<TextProp> style(
      String label,
      String description,
      TextProp Function() get,
      void Function(TextProp) set,
    ) => TextStyleFieldAccess<TextProp>(label, description, get, set);
    return {
      ...super.generateFields(),
      'xField': StringFieldAccess(
        'X Field',
        'Key of each data item holding its x value',
        () => xField,
        (value) => xField = value,
      ),
      'yField': StringFieldAccess(
        'Y Field',
        'Key of each data item holding its y value',
        () => yField,
        (value) => yField = value,
      ),
      'smooth': BoolFieldAccess(
        'Smooth',
        'Whether the curve is a spline through the points',
        () => smooth,
        (value) => smooth = value,
      ),
      'lineWidth': number(
        'Line Width',
        'Stroke width of the curve',
        () => lineWidth,
        (value) => lineWidth = value,
      ),
      'padLeft': number(
        'Left Inset',
        'Space left of the plot',
        () => padLeft,
        (value) => padLeft = value,
      ),
      'padRight': number(
        'Right Inset',
        'Space right of the plot',
        () => padRight,
        (value) => padRight = value,
      ),
      'padTop': number(
        'Top Inset',
        'Space above the plot',
        () => padTop,
        (value) => padTop = value,
      ),
      'padBottom': number(
        'Bottom Inset',
        'Space below the plot',
        () => padBottom,
        (value) => padBottom = value,
      ),
      'lineColor': color(
        'Line Color',
        'Color of the curve',
        () => lineColor,
        (value) => lineColor = value,
      ),
      'areaTopColor': color(
        'Area Top Color',
        'Top color of the area gradient',
        () => areaTopColor,
        (value) => areaTopColor = value,
      ),
      'areaBottomColor': color(
        'Area Bottom Color',
        'Bottom color of the area gradient',
        () => areaBottomColor,
        (value) => areaBottomColor = value,
      ),
      'gridColor': color(
        'Grid Color',
        'Color of horizontal grid lines',
        () => gridColor,
        (value) => gridColor = value,
      ),
      'zeroLineColor': color(
        'Zero Line Color',
        'Color of the grid line at zero',
        () => zeroLineColor,
        (value) => zeroLineColor = value,
      ),
      'axisColor': color(
        'Axis Color',
        'Color of the x axis and ticks',
        () => axisColor,
        (value) => axisColor = value,
      ),
      'markerHollowColor': color(
        'Hollow Marker Color',
        'Fill of markers that are not filled',
        () => markerHollowColor,
        (value) => markerHollowColor = value,
      ),
      'tagBackground': color(
        'Tag Background',
        'Background of vertical line tags',
        () => tagBackground,
        (value) => tagBackground = value,
      ),
      'cursorColor': color(
        'Cursor Color',
        'Color of the scrub cursor',
        () => cursorColor,
        (value) => cursorColor = value,
      ),
      'cursorRingFill': color(
        'Cursor Ring Fill',
        'Fill of the scrub cursor ring',
        () => cursorRingFill,
        (value) => cursorRingFill = value,
      ),
      'tooltipBackground': color(
        'Readout Background',
        'Background of the scrub readout',
        () => tooltipBackground,
        (value) => tooltipBackground = value,
      ),
      'tooltipShadowColor': color(
        'Readout Shadow',
        'Color of the readout shadow',
        () => tooltipShadowColor,
        (value) => tooltipShadowColor = value,
      ),
      'yAxisTitle': StringFieldAccess(
        'Y Axis Title',
        'Text above the y labels',
        () => yAxisTitle,
        (value) => yAxisTitle = value,
      ),
      'axisLabelStyle': style(
        'Axis Label Style',
        'Style of axis labels',
        () => axisLabelStyle,
        (value) => axisLabelStyle = value,
      ),
      'axisTitleStyle': style(
        'Axis Title Style',
        'Style of the y axis title',
        () => axisTitleStyle,
        (value) => axisTitleStyle = value,
      ),
      'markerLabelStyle': style(
        'Marker Label Style',
        'Style of marker labels',
        () => markerLabelStyle,
        (value) => markerLabelStyle = value,
      ),
      'tagTextStyle': style(
        'Tag Text Style',
        'Style of vertical line tags',
        () => tagTextStyle,
        (value) => tagTextStyle = value,
      ),
      'tooltipLabelStyle': style(
        'Readout Label Style',
        'Style of the readout x value',
        () => tooltipLabelStyle,
        (value) => tooltipLabelStyle = value,
      ),
      'tooltipValueStyle': style(
        'Readout Value Style',
        'Style of the readout y value',
        () => tooltipValueStyle,
        (value) => tooltipValueStyle = value,
      ),
      'scrubEnabled': BoolFieldAccess(
        'Scrub',
        'Whether a cursor reads out the curve',
        () => scrubEnabled,
        (value) => scrubEnabled = value,
      ),
      'scrubStep': number(
        'Scrub Step',
        'Arrow key step in x units (minutes for dates)',
        () => scrubStep,
        (value) => scrubStep = value,
      ),
      'tooltipXFormat': StringFieldAccess(
        'Readout X Format',
        'Date pattern of the readout x value',
        () => tooltipXFormat,
        (value) => tooltipXFormat = value,
      ),
      'tooltipYScale': number(
        'Readout Y Scale',
        'Factor applied to the readout y value',
        () => tooltipYScale,
        (value) => tooltipYScale = value,
      ),
      'tooltipYDecimals': NumFieldAccess<int>(
        'Readout Y Decimals',
        'Decimals of the readout y value',
        () => tooltipYDecimals,
        (value) => tooltipYDecimals = value,
      ),
      'tooltipYSuffix': StringFieldAccess(
        'Readout Y Suffix',
        'Text after the readout y value',
        () => tooltipYSuffix,
        (value) => tooltipYSuffix = value,
      ),
      'tooltipTrend': BoolFieldAccess(
        'Readout Trend',
        'Whether the readout shows a rising or falling arrow',
        () => tooltipTrend,
        (value) => tooltipTrend = value,
      ),
      'semanticLabel': StringFieldAccess(
        'Semantic Label',
        'Accessibility label of the chart',
        () => semanticLabel,
        (value) => semanticLabel = value,
      ),
    };
  }

  @override
  List<Object?> get props => [
    xField,
    yField,
    xMin,
    xMax,
    yMin,
    yMax,
    padLeft,
    padRight,
    padTop,
    padBottom,
    smooth,
    lineColor,
    lineWidth,
    areaTopColor,
    areaBottomColor,
    gridColor,
    zeroLineColor,
    axisColor,
    markerHollowColor,
    tagBackground,
    cursorColor,
    cursorRingFill,
    tooltipBackground,
    tooltipShadowColor,
    yAxisTitle,
    axisLabelStyle,
    axisTitleStyle,
    markerLabelStyle,
    tagTextStyle,
    tooltipLabelStyle,
    tooltipValueStyle,
    scrubEnabled,
    scrubStep,
    tooltipXFormat,
    tooltipYScale,
    tooltipYDecimals,
    tooltipYSuffix,
    tooltipTrend,
    semanticLabel,
  ];

  /// Creates [LineChartProperties] from a JSON object.
  factory LineChartProperties.fromJson(Map json) =>
      _$LineChartPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LineChartPropertiesOmitDefaults(
    this,
    _$LineChartPropertiesToJson(this),
  );
}
