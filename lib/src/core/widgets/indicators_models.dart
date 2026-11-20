// Value types and codecs of the indicators widgets (progress bars, gauges,
// charts, barcodes). Each nested model is a small record declared like a
// widget: its fields are PropDefs, so decoding is total, encoding sparse and
// equality by value, as for widget props.
import 'package:meta/meta.dart';

import '../json.dart';
import '../props.dart';
import '../values/color.dart';

// --- codecs -------------------------------------------------------------------


/// A list of numbers with gaps (`null` items kept, e.g. a bar with no value).
final class NullableDoublesCodec extends PropCodec<List<double?>> {
  const NullableDoublesCodec();
  @override
  List<double?>? decode(Object? json) => readList(json)?.map(readDouble).toList();
  @override
  Object encode(List<double?> value) => [for (final v in value) v == null ? null : writeDouble(v)];
  @override
  PropType get type => const PropType.list(PropType.number());
}


/// Codecs shared by the indicators declarations.
abstract final class IndicatorCodecs {
  static const optionalDouble = Codecs.optionalDouble;
  static const optionalString = Codecs.optionalString;
  static const optionalColor = Codecs.optionalColor;
  static const doubles = Codecs.doubles;
  static const strings = Codecs.strings;

  /// Free-form JSON objects (data rows, bound overlays).
  static const objects = Codecs.jsonList;
}

// --- records ------------------------------------------------------------------

/// A small immutable model whose fields are declared as [PropDef]s in
/// [schema] (as a widget's props are): only non-default fields are held and
/// encoded; unknown keys round-trip.
@immutable
abstract base class PropRecord {
  const PropRecord(this.props);

  final Props props;

  /// The field declarations.
  WidgetSpec get schema;

  T get<T>(PropDef<T> def) => props.get(def);

  Json toJson() => props.toJson(schema);

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType && other is PropRecord && other.props == props;

  @override
  int get hashCode => Object.hash(runtimeType, props);

  @override
  String toString() => '${schema.type}(${toJson()})';
}

Object? _recordOut(PropRecord r) => r.toJson();

/// A colored zone of an arc progress bar, from [start] to [end] as fractions
/// of the max value.
final class ProgressBand extends PropRecord {
  const ProgressBand._(super.props);

  ProgressBand({double start = 0, double end = 0, Color color = Color.black})
      : super(Props.empty.set(startDef, start).set(endDef, end).set(colorDef, color));

  static const startDef = PropDef<double>('start', Codecs.double, 0);
  static const endDef = PropDef<double>('end', Codecs.double, 0);
  static const colorDef = PropDef<Color>('color', Codecs.color, Color.black);
  static const spec = WidgetSpec('ProgressBand', props: [startDef, endDef, colorDef]);

  @override
  WidgetSpec get schema => spec;
  double get start => get(startDef);
  double get end => get(endDef);
  Color get color => get(colorDef);

  static ProgressBand? fromJson(Object? json) =>
      readMap(json) == null ? null : ProgressBand._(Props.fromJson(spec, json));
  static const codec = ListCodec<ProgressBand>(ValueCodec(fromJson, _recordOut, PropType.record('ProgressBand', spec)));
}

/// A colored band of a radial gauge, from [from] to [to] in value units.
final class GaugeZone extends PropRecord {
  const GaugeZone._(super.props);

  GaugeZone({double from = 0, double to = 0, Color color = Color.black})
      : super(Props.empty.set(fromDef, from).set(toDef, to).set(colorDef, color));

  static const fromDef = PropDef<double>('from', Codecs.double, 0);
  static const toDef = PropDef<double>('to', Codecs.double, 0);
  static const colorDef = PropDef<Color>('color', Codecs.color, Color.black);
  static const spec = WidgetSpec('GaugeZone', props: [fromDef, toDef, colorDef]);

  @override
  WidgetSpec get schema => spec;
  double get from => get(fromDef);
  double get to => get(toDef);
  Color get color => get(colorDef);

  static GaugeZone? fromJson(Object? json) => readMap(json) == null ? null : GaugeZone._(Props.fromJson(spec, json));
  static const codec = ListCodec<GaugeZone>(ValueCodec(fromJson, _recordOut, PropType.record('GaugeZone', spec)));
}

/// How a chart series draws its values.
enum ChartSeriesKind { bar, line, area, tick }

/// One series of a chart: the values of [field] in each data row.
final class ChartSeries extends PropRecord {
  const ChartSeries._(super.props);

  static const fieldDef = PropDef<String>('field', Codecs.string, '');
  static const nameDef = PropDef<String>('name', Codecs.string, '');
  static const kindDef = PropDef<ChartSeriesKind>('kind', EnumCodec(ChartSeriesKind.values), ChartSeriesKind.bar);
  static const colorDef = PropDef<Color>('color', Codecs.color, Color(0xFF2ED17A));

  /// A row field holding a per-row color (hex), overriding [color].
  static const colorFieldDef = PropDef<String?>('colorField', IndicatorCodecs.optionalString, null);

  /// Bar series with the same stack id are stacked into one bar.
  static const stackDef = PropDef<String?>('stack', IndicatorCodecs.optionalString, null);
  static const dashedDef = PropDef<bool>('dashed', Codecs.bool, false);
  static const strokeWidthDef = PropDef<double>('strokeWidth', Codecs.positive, 2);
  static const endDotDef = PropDef<bool>('endDot', Codecs.bool, false);
  static const endDotHaloColorDef = PropDef<Color?>('endDotHaloColor', IndicatorCodecs.optionalColor, null);
  static const curvedDef = PropDef<bool>('curved', Codecs.bool, false);

  /// Area series: fill down to this field's line instead of the axis.
  static const fillToDef = PropDef<String?>('fillTo', IndicatorCodecs.optionalString, null);
  static const fillOpacityDef = PropDef<double>('fillOpacity', DoubleCodec(min: 0, max: 1), 0.25);

  /// Area series: the fill is strongest under the line and fades to
  /// nothing at the foot of the plot.
  static const fadeDef = PropDef<bool>('fade', Codecs.bool, false);

  /// Line and area series: its [name] and last value written at the end of
  /// its line, in its color (labels of different series are kept apart).
  static const endLabelDef = PropDef<bool>('endLabel', Codecs.bool, false);

  static const spec = WidgetSpec('ChartSeries', props: [
    fieldDef, nameDef, kindDef, colorDef, colorFieldDef, stackDef, dashedDef, strokeWidthDef, endDotDef, //
    endDotHaloColorDef, curvedDef, fillToDef, fillOpacityDef, endLabelDef, fadeDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  String get field => get(fieldDef);
  String get name => get(nameDef);
  ChartSeriesKind get kind => get(kindDef);
  Color get color => get(colorDef);
  String? get colorField => get(colorFieldDef);
  String? get stack => get(stackDef);
  bool get dashed => get(dashedDef);
  double get strokeWidth => get(strokeWidthDef);
  bool get endDot => get(endDotDef);
  bool get fade => get(fadeDef);
  Color? get endDotHaloColor => get(endDotHaloColorDef);
  bool get curved => get(curvedDef);
  String? get fillTo => get(fillToDef);
  double get fillOpacity => get(fillOpacityDef);
  bool get endLabel => get(endLabelDef);

  ChartSeries withColor(Color color) => ChartSeries._(props.set(colorDef, color));
  ChartSeries withKind(ChartSeriesKind kind) => ChartSeries._(props.set(kindDef, kind));

  static ChartSeries? fromJson(Object? json) => readMap(json) == null ? null : ChartSeries._(Props.fromJson(spec, json));
  static const codec = ListCodec<ChartSeries>(ValueCodec(fromJson, _recordOut, PropType.record('ChartSeries', spec)));
}

/// A horizontal line across a chart's plot at [value].
final class ChartReferenceLine extends PropRecord {
  const ChartReferenceLine._(super.props);

  static const valueDef = PropDef<double>('value', Codecs.double, 0);
  static const colorDef = PropDef<Color>('color', Codecs.color, Color(0x99FFFFFF));
  static const dashedDef = PropDef<bool>('dashed', Codecs.bool, true);
  static const strokeWidthDef = PropDef<double>('strokeWidth', Codecs.positive, 1.5);

  /// Text at the line's right end ("CAPACITY 360"), above it unless
  /// [labelBelow]; in [labelColor], else the line's color.
  static const labelDef = PropDef<String>('label', Codecs.string, '');
  static const labelColorDef = PropDef<Color?>('labelColor', Codecs.optionalColor, null);
  static const labelBelowDef = PropDef<bool>('labelBelow', Codecs.bool, false);
  static const spec = WidgetSpec('ChartReferenceLine',
      props: [valueDef, colorDef, dashedDef, strokeWidthDef, labelDef, labelColorDef, labelBelowDef]);

  @override
  WidgetSpec get schema => spec;
  double get value => get(valueDef);
  Color get color => get(colorDef);
  bool get dashed => get(dashedDef);
  double get strokeWidth => get(strokeWidthDef);
  String get label => get(labelDef);
  Color? get labelColor => get(labelColorDef);
  bool get labelBelow => get(labelBelowDef);

  static ChartReferenceLine? fromJson(Object? json) =>
      readMap(json) == null ? null : ChartReferenceLine._(Props.fromJson(spec, json));
  static const codec = ListCodec<ChartReferenceLine>(ValueCodec(fromJson, _recordOut, PropType.record('ChartReferenceLine', spec)));
}

/// A label on a plot chart's x axis, centered on [x].
final class PlotChartLabel extends PropRecord {
  const PlotChartLabel._(super.props);

  static const xDef = PropDef<double>('x', Codecs.double, 0);
  static const labelDef = PropDef<String>('label', Codecs.string, '');
  static const spec = WidgetSpec('PlotChartLabel', props: [xDef, labelDef]);

  @override
  WidgetSpec get schema => spec;
  double get x => get(xDef);
  String get label => get(labelDef);

  static PlotChartLabel? fromJson(Object? json) =>
      readMap(json) == null ? null : PlotChartLabel._(Props.fromJson(spec, json));
  static const codec = ListCodec<PlotChartLabel>(ValueCodec(fromJson, _recordOut, PropType.record('PlotChartLabel', spec)));
}

/// A shaded x range of a plot chart, painted behind the curve.
final class PlotChartRange extends PropRecord {
  const PlotChartRange._(super.props);

  static const fromDef = PropDef<double>('from', Codecs.double, 0);
  static const toDef = PropDef<double>('to', Codecs.double, 0);
  static const colorDef = PropDef<Color>('color', Codecs.color, Color(0x19000000));

  /// Written at the range's top left (the chart's marker label style, muted).
  static const labelDef = PropDef<String>('label', Codecs.string, '');
  static const labelColorDef = PropDef<Color?>('labelColor', IndicatorCodecs.optionalColor, null);
  static const spec = WidgetSpec('PlotChartRange', props: [fromDef, toDef, colorDef, labelDef, labelColorDef]);

  @override
  WidgetSpec get schema => spec;
  double get from => get(fromDef);
  double get to => get(toDef);
  Color get color => get(colorDef);
  String get label => get(labelDef);
  Color? get labelColor => get(labelColorDef);

  static PlotChartRange? fromJson(Object? json) =>
      readMap(json) == null ? null : PlotChartRange._(Props.fromJson(spec, json));
  static const codec = ListCodec<PlotChartRange>(ValueCodec(fromJson, _recordOut, PropType.record('PlotChartRange', spec)));
}

/// Where a plot chart marker's label sits relative to its dot.
enum PlotChartMarkerPosition { above, below }

/// How a plot chart marker is drawn: a filled dot (the default), a hollow
/// ring, a square or a diamond.
enum PlotChartMarkerShape { dot, ring, square, diamond }

/// A labeled dot on a plot chart (on the curve when [y] is null).
final class PlotChartMarker extends PropRecord {
  const PlotChartMarker._(super.props);

  static const xDef = PropDef<double>('x', Codecs.double, 0);
  static const yDef = PropDef<double?>('y', IndicatorCodecs.optionalDouble, null);
  static const labelDef = PropDef<String>('label', Codecs.string, '');
  static const colorDef = PropDef<Color>('color', Codecs.color, Color.black);
  static const positionDef = PropDef<PlotChartMarkerPosition>(
      'position', EnumCodec(PlotChartMarkerPosition.values), PlotChartMarkerPosition.above);

  /// The marker's shape. A ring and a square are outlined in [color] and
  /// filled with [fillColor]; a dot is filled with [color]; a diamond is
  /// filled with [fillColor] and outlined in [strokeColor].
  static const shapeDef =
      PropDef<PlotChartMarkerShape>('shape', EnumCodec(PlotChartMarkerShape.values), PlotChartMarkerShape.dot);

  /// The size: a dot's or ring's radius, half a square's side, a diamond's
  /// half diagonal. Null uses the chart's markerRadius.
  static const radiusDef = PropDef<double?>('radius', IndicatorCodecs.optionalDouble, null);

  /// The inside of a ring, square or diamond (default white).
  static const fillColorDef = PropDef<Color?>('fillColor', IndicatorCodecs.optionalColor, null);

  /// An outline around a dot or diamond (none by default for a dot; black
  /// for a diamond).
  static const strokeColorDef = PropDef<Color?>('strokeColor', IndicatorCodecs.optionalColor, null);

  /// The outline width (default 2 for a ring and square, 1.2 for a dot or
  /// diamond's [strokeColor]).
  static const strokeWidthDef = PropDef<double?>('strokeWidth', IndicatorCodecs.optionalDouble, null);
  static const spec = WidgetSpec('PlotChartMarker', props: [
    xDef, yDef, labelDef, colorDef, positionDef, shapeDef, radiusDef, fillColorDef, strokeColorDef, strokeWidthDef, //
  ]);

  @override
  WidgetSpec get schema => spec;
  double get x => get(xDef);
  double? get y => get(yDef);
  String get label => get(labelDef);
  Color get color => get(colorDef);
  PlotChartMarkerPosition get position => get(positionDef);
  PlotChartMarkerShape get shape => get(shapeDef);
  double? get radius => get(radiusDef);
  Color? get fillColor => get(fillColorDef);
  Color? get strokeColor => get(strokeColorDef);
  double? get strokeWidth => get(strokeWidthDef);

  static PlotChartMarker? fromJson(Object? json) =>
      readMap(json) == null ? null : PlotChartMarker._(Props.fromJson(spec, json));
  static const codec = ListCodec<PlotChartMarker>(ValueCodec(fromJson, _recordOut, PropType.record('PlotChartMarker', spec)));
}

/// A horizontal line across a plot chart at [y]: a grid line, or a
/// reference such as a target (dashed, with an inline [label]). [axisLabel]
/// is written in the chart's y-axis gutter ([PlotChartProps.yAxisWidth]).
final class PlotChartYLine extends PropRecord {
  const PlotChartYLine._(super.props);

  static const yDef = PropDef<double>('y', Codecs.double, 0);
  static const colorDef = PropDef<Color>('color', Codecs.color, Color(0x19000000));
  static const widthDef = PropDef<double>('width', Codecs.positive, 1);
  static const dashedDef = PropDef<bool>('dashed', Codecs.bool, false);

  /// Written above the line at the plot's left, on a box of [labelBackground].
  static const labelDef = PropDef<String>('label', Codecs.string, '');
  static const labelBackgroundDef = PropDef<Color?>('labelBackground', IndicatorCodecs.optionalColor, null);
  static const axisLabelDef = PropDef<String>('axisLabel', Codecs.string, '');
  static const spec = WidgetSpec('PlotChartYLine',
      props: [yDef, colorDef, widthDef, dashedDef, labelDef, labelBackgroundDef, axisLabelDef]);

  @override
  WidgetSpec get schema => spec;
  double get y => get(yDef);
  Color get color => get(colorDef);
  double get width => get(widthDef);
  bool get dashed => get(dashedDef);
  String get label => get(labelDef);
  Color? get labelBackground => get(labelBackgroundDef);
  String get axisLabel => get(axisLabelDef);

  static PlotChartYLine? fromJson(Object? json) =>
      readMap(json) == null ? null : PlotChartYLine._(Props.fromJson(spec, json));
  static const codec = ListCodec<PlotChartYLine>(ValueCodec(fromJson, _recordOut, PropType.record('PlotChartYLine', spec)));
}

/// One more curve on a plot chart, over the chart's x domain: [points] are
/// evenly spaced from xMin to xMax like the chart's own, and a null point
/// is a gap (the line breaks there: an undefined value or an asymptote).
final class PlotChartSeries extends PropRecord {
  const PlotChartSeries._(super.props);

  static const pointsDef = PropDef<List<double?>>('points', NullableDoublesCodec(), []);
  static const colorDef = PropDef<Color>('color', Codecs.color, Color(0xFF1F6F78));
  static const widthDef = PropDef<double>('width', Codecs.positive, 2);

  /// Names the series for a selection (selectionSeries) and for matching
  /// series across data updates.
  static const idDef = PropDef<String>('id', Codecs.string, '');
  static const spec = WidgetSpec('PlotChartSeries', props: [pointsDef, colorDef, widthDef, idDef]);

  @override
  WidgetSpec get schema => spec;
  List<double?> get points => get(pointsDef);
  Color get color => get(colorDef);
  double get width => get(widthDef);
  String get id => get(idDef);

  static PlotChartSeries? fromJson(Object? json) =>
      readMap(json) == null ? null : PlotChartSeries._(Props.fromJson(spec, json));
  static const codec = ListCodec<PlotChartSeries>(ValueCodec(fromJson, _recordOut, PropType.record('PlotChartSeries', spec)));
}

/// Where a plot chart's grid lines start: at xMin (every step from the
/// left edge, as a category axis), or at multiples of the step (0, ±step,
/// …: a Cartesian graph whose grid stays put as the domain pans).
enum PlotChartGridAnchor { start, zero }

/// How the selection is marked: a full-height line, dashed guides from
/// the point to both axes, or only the dot.
enum PlotChartSelectionGuides { line, axes, none }

// --- graph ----------------------------------------------------------------------
//
// The parts of a graph (GraphProps). Each is a record: on a node's line its
// fields are dotted keys (`xAxis.label=month`, `selection.on=both`,
// `marks[0].y=web`).

const _gs = Codecs.string, _gd = Codecs.double, _gp = Codecs.positive, _gb = Codecs.bool;
const _gc = Codecs.optionalColor, _gn = Codecs.optionalDouble;

/// A graph's x scale: where each row stands, what is written under it, and
/// the view of it the user moves.
final class GraphXAxis extends PropRecord {
  const GraphXAxis._(super.props);

  /// `index`: rows evenly spaced, one place each. `linear`: each row where
  /// its `field`'s number is, between `min` and `max` (the rows' own least
  /// and most when not given).
  static const scaleDef = PropDef<String>('scale', _gs, 'index');

  /// Linear: the row field holding a row's number.
  static const fieldDef = PropDef<String>('field', _gs, '');
  static const minDef = PropDef<double?>('min', _gn, null);
  static const maxDef = PropDef<double?>('max', _gn, null);

  /// The row field written under a row (and at the head of a tooltip).
  static const labelDef = PropDef<String>('label', _gs, 't');

  /// A date pattern, when the label is a time (milliseconds, or ISO text);
  /// empty writes the labels as they are.
  static const formatDef = PropDef<String>('format', _gs, 'MMM d');

  /// `none`: the view is the user's to pan and zoom. `bars`: every row has
  /// its place across the plot. `points`: the first and last rows are at
  /// its edges.
  static const fitDef = PropDef<String>('fit', _gs, 'none');

  /// With a fit: the places across the plot, when more than the rows there
  /// are (a day not over yet).
  static const slotsDef = PropDef<int?>('slots', Codecs.optionalInt, null);

  /// The ticks themselves, when the graph does not choose them: `12` or
  /// `{value, label}` (a number on a linear scale, a row's place on rows).
  static const tickValuesDef = PropDef<Object?>('tickValues', Codecs.any, null);

  /// A label every this many rows; null lets the graph choose.
  static const tickEveryDef = PropDef<int?>('tickEvery', Codecs.optionalInt, null);

  /// `step` (every n-th row) or `calendar` (the rows that start an hour, a
  /// day, a month, a year).
  static const ticksDef = PropDef<String>('ticks', _gs, 'step');

  /// Whether the ticks' labels are written. Labels that would touch are
  /// thinned to every second, third… from the first, evenly apart: the
  /// step ends on the last label where one near it does, else the last is
  /// left out. Long labels are first cut with an ellipsis to the room
  /// between two, where thinning alone would write fewer than half.
  static const labelsDef = PropDef<bool>('labels', _gb, true);

  /// Whether a line is drawn up each pane at every tick.
  static const gridDef = PropDef<bool>('grid', _gb, true);
  static const axisHeightDef = PropDef<double>('axisHeight', _gp, 24);

  /// Rows: pixels from one row to the next at rest, and how close and far
  /// zooming may bring them.
  static const barSpacingDef = PropDef<double>('barSpacing', _gp, 8);
  static const minBarSpacingDef = PropDef<double>('minBarSpacing', _gp, 0.5);
  static const maxBarSpacingDef = PropDef<double>('maxBarSpacing', _gp, 80);

  /// Rows: the empty places right of the last row at rest.
  static const rightOffsetDef = PropDef<double>('rightOffset', _gd, 3);

  /// `end`: a new row is followed while the last row is in view. `none`.
  static const followDef = PropDef<String>('follow', _gs, 'end');
  static const clampDef = PropDef<bool>('clamp', _gb, true);

  /// Whether the view may go past the rows there are.
  static const overscrollDef = PropDef<bool>('overscroll', _gb, false);

  /// Whether there are older rows to load, and how near the first row (in
  /// rows) the view comes before the graph asks (its `scroll` trigger with
  /// `nearStart`).
  static const moreHistoryDef = PropDef<bool>('moreHistory', _gb, true);
  static const historyThresholdDef = PropDef<double>('historyThreshold', _gp, 10);

  /// Milliseconds a line takes to change its shape to new rows' (0: at
  /// once).
  static const morphDef = PropDef<double>('morph', _gp, 0);

  /// Named stretches of the scale: `{id, from, to, group}`.
  static const bandsDef = PropDef<List<Json>>('bands', Codecs.jsonList, []);

  /// Pixels kept clear at each end of a fitted view (`fit`): the first and
  /// the last row stand this far inside the plot, so a dot or a line's end
  /// there is whole.
  static const insetDef = PropDef<double>('inset', _gp, 0);

  /// The widest a bar or a candle is drawn, in the middle of its place
  /// (bars side by side: each of them); its share of the place when not
  /// given, however wide.
  static const maxBarWidthDef = PropDef<double?>('maxBarWidth', _gn, null);

  static const spec = WidgetSpec('GraphXAxis', props: [
    scaleDef, fieldDef, minDef, maxDef, labelDef, formatDef, fitDef, slotsDef, tickValuesDef, tickEveryDef, ticksDef, //
    labelsDef, gridDef, axisHeightDef, barSpacingDef, minBarSpacingDef, maxBarSpacingDef, rightOffsetDef, followDef,
    clampDef, overscrollDef, moreHistoryDef, historyThresholdDef, morphDef, bandsDef, insetDef, maxBarWidthDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static const empty = GraphXAxis._(Props.empty);
  static GraphXAxis fromJson(Object? json) => GraphXAxis._(Props.fromJson(spec, json));
  static const codec = ValueCodec<GraphXAxis>(fromJson, _recordOut, PropType.record('GraphXAxis', spec));
}

/// A pane's y scale.
final class GraphYAxis extends PropRecord {
  const GraphYAxis._(super.props);

  /// `visible`: fitted to the rows in view. `data`: to all rows. `fixed`:
  /// `min` to `max`.
  static const domainDef = PropDef<String>('domain', _gs, 'visible');
  static const minDef = PropDef<double?>('min', _gn, null);
  static const maxDef = PropDef<double?>('max', _gn, null);

  /// Room above and below the fitted values, `[top, bottom]`, as shares of
  /// their span (`[0.1, 0.1]` when not given).
  static const marginsDef = PropDef<List<double>>('margins', Codecs.doubles, []);

  /// Values the fitted domain always holds (zero, a goal).
  static const includeDef = PropDef<List<double>>('include', Codecs.doubles, []);

  /// `linear`, or `percent`: labels are the change from the first row in
  /// view.
  static const modeDef = PropDef<String>('mode', _gs, 'linear');

  /// `right` or `left`: where the axis is (one side for the whole graph:
  /// left when any pane says so).
  static const sideDef = PropDef<String>('side', _gs, 'right');

  /// The axis's width; 0 for none.
  static const widthDef = PropDef<double>('width', _gp, 56);
  static const labelsDef = PropDef<bool>('labels', _gb, true);
  static const decimalsDef = PropDef<int>('decimals', IntCodec(min: 0), 2);

  /// Written before and after each label (`$`, `k`, `%`).
  static const prefixDef = PropDef<String>('prefix', _gs, '');
  static const suffixDef = PropDef<String>('suffix', _gs, '');

  /// About how many round ticks the axis has.
  static const ticksDef = PropDef<int>('ticks', IntCodec(min: 0), 5);

  /// The ticks themselves, when the graph does not choose them: `12` or
  /// `{value, label}`.
  static const tickValuesDef = PropDef<Object?>('tickValues', Codecs.any, null);

  /// A fitted domain is rounded out to the ticks, so the plot starts and
  /// ends on a labeled line (`margins` are then not added).
  static const niceDef = PropDef<bool>('nice', _gb, false);

  static const spec = WidgetSpec('GraphYAxis', props: [
    domainDef, minDef, maxDef, marginsDef, includeDef, modeDef, sideDef, widthDef, labelsDef, decimalsDef, prefixDef, //
    suffixDef, ticksDef, tickValuesDef, niceDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static const empty = GraphYAxis._(Props.empty);
  static GraphYAxis fromJson(Object? json) => GraphYAxis._(Props.fromJson(spec, json));
  static const codec = ValueCodec<GraphYAxis>(fromJson, _recordOut, PropType.record('GraphYAxis', spec));
}

/// What a graph draws of its rows: one mark.
final class GraphMark extends PropRecord {
  const GraphMark._(super.props);

  /// `line`, `area`, `bar`, `candle`, or in a polar pane `arc`.
  static const typeDef = PropDef<String>('type', _gs, 'line');

  /// The row field of the mark's value.
  static const yDef = PropDef<String>('y', _gs, '');

  /// A candle's fields (a bar with `open` and `close` is colored by its
  /// direction).
  static const openDef = PropDef<String>('open', _gs, '');
  static const highDef = PropDef<String>('high', _gs, '');
  static const lowDef = PropDef<String>('low', _gs, '');
  static const closeDef = PropDef<String>('close', _gs, '');

  /// What a tooltip and the legend call the mark; its field when empty (a
  /// mark with no name has no key in the legend).
  static const nameDef = PropDef<String>('name', _gs, '');

  /// Its color; when not given, the next of the style's `palette` (the
  /// first field drawn takes the first color, and every mark of one field
  /// the same).
  static const colorDef = PropDef<Color?>('color', _gc, null);

  /// A row field holding the row's own color.
  static const colorFieldDef = PropDef<String>('colorField', _gs, '');

  /// Colors row by row (a slice's, a bar's), where the row gives none. An
  /// arc that gives neither these nor a `color` takes the style's `palette`.
  static const colorsDef = PropDef<List<String>>('colors', Codecs.strings, []);
  static const upColorDef = PropDef<Color?>('upColor', _gc, null);
  static const downColorDef = PropDef<Color?>('downColor', _gc, null);

  /// Bars with the same stack stand on one another; bars with none stand
  /// side by side in the row's place.
  static const stackDef = PropDef<String?>('stack', Codecs.optionalString, null);

  /// A bar's corner radius (the top of a stack).
  static const radiusDef = PropDef<double>('radius', _gp, 0);

  /// A bar's value is written over it.
  static const labelsDef = PropDef<bool>('labels', _gb, false);

  /// A line's width.
  static const widthDef = PropDef<double>('width', _gp, 1.5);

  /// A line or an area is drawn as a smooth curve through its values,
  /// which never rises above or dips below the values it joins.
  static const curvedDef = PropDef<bool>('curved', _gb, false);

  /// A line: a dot of this radius on every row (0: none).
  static const dotsDef = PropDef<double>('dots', _gp, 0);

  /// An area: its fill's opacity, whether it fades to nothing at the
  /// bottom, or the color it runs to there.
  static const fillOpacityDef = PropDef<double>('fillOpacity', DoubleCodec(min: 0, max: 1), 0.18);
  static const fadeDef = PropDef<bool>('fade', _gb, false);
  static const fillToDef = PropDef<Color?>('fillTo', _gc, null);

  /// A dot of this radius on the last row (0: none), with a ring that
  /// swells and fades when `pulse`.
  static const endDotDef = PropDef<double>('endDot', _gp, 0);
  static const endDotColorDef = PropDef<Color?>('endDotColor', _gc, null);
  static const pulseDef = PropDef<bool>('pulse', _gb, false);

  /// The mark is on a scale of its own, standing in this share of the pane
  /// from its bottom (volume under a price).
  static const overlayDef = PropDef<double?>('overlay', _gn, null);

  /// A line breaks where this row field changes, and the parts outside the
  /// x scale's band in use are drawn at `dimInactive` of their opacity.
  static const segmentByDef = PropDef<String>('segmentBy', _gs, '');
  static const dimInactiveDef = PropDef<double>('dimInactive', DoubleCodec(min: 0, max: 1), 1);

  /// An arc: the hole's share of the radius (0: a pie), the room between
  /// slices and where the first starts (degrees, clockwise from the top).
  static const innerDef = PropDef<double>('inner', DoubleCodec(min: 0, max: 1), 0);
  static const gapDef = PropDef<double>('gap', _gp, 0);
  static const startAngleDef = PropDef<double>('startAngle', _gd, 0);

  /// An arc with a hole: what is written in it. `total`: the sum of its
  /// values, and while a slice is selected that slice's value. Empty:
  /// nothing. `centerLabel` is written small under the figure (while a
  /// slice is selected, its label).
  static const centerDef = PropDef<String>('center', _gs, '');
  static const centerLabelDef = PropDef<String>('centerLabel', _gs, '');

  static const spec = WidgetSpec('GraphMark', props: [
    typeDef, yDef, openDef, highDef, lowDef, closeDef, nameDef, colorDef, colorFieldDef, colorsDef, upColorDef, //
    downColorDef, stackDef, radiusDef, labelsDef, widthDef, curvedDef, fillOpacityDef, fadeDef, fillToDef, endDotDef,
    endDotColorDef, pulseDef, overlayDef, segmentByDef, dimInactiveDef, innerDef, gapDef, startAngleDef, dotsDef,
    centerDef, centerLabelDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static GraphMark? fromJson(Object? json) => readMap(json) == null ? null : GraphMark._(Props.fromJson(spec, json));
  static const codec = ListCodec<GraphMark>(ValueCodec(fromJson, _recordOut, PropType.record('GraphMark', spec)));
}

/// Something drawn at a place of a pane's scales, over its marks: a line up
/// the pane (`x`), a line across it (`y`), a dot (`x` and `y`) or a tinted
/// stretch (`from` to `to`). A place on x is a number on a linear scale, a
/// row's key on rows.
final class GraphGuide extends PropRecord {
  const GraphGuide._(super.props);

  static const xDef = PropDef<Object?>('x', Codecs.any, null);
  static const yDef = PropDef<double?>('y', _gn, null);
  static const fromDef = PropDef<Object?>('from', Codecs.any, null);
  static const toDef = PropDef<Object?>('to', Codecs.any, null);
  static const colorDef = PropDef<Color?>('color', _gc, null);

  /// `solid`, `dashed` or `dotted`.
  static const lineDef = PropDef<String>('line', _gs, 'solid');
  static const widthDef = PropDef<double>('width', _gp, 1);
  static const labelDef = PropDef<String>('label', _gs, '');
  static const labelColorDef = PropDef<Color?>('labelColor', _gc, null);

  /// A dot's radius, and its inside when it is not the dot's own color.
  static const radiusDef = PropDef<double>('radius', _gp, 3.5);
  static const fillDef = PropDef<Color?>('fill', _gc, null);

  /// The label is under the dot or the line.
  static const belowDef = PropDef<bool>('below', _gb, false);

  static const spec = WidgetSpec('GraphGuide', props: [
    xDef, yDef, fromDef, toDef, colorDef, lineDef, widthDef, labelDef, labelColorDef, radiusDef, fillDef, belowDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static GraphGuide? fromJson(Object? json) => readMap(json) == null ? null : GraphGuide._(Props.fromJson(spec, json));
  static const codec = ListCodec<GraphGuide>(ValueCodec(fromJson, _recordOut, PropType.record('GraphGuide', spec)));
}

/// One pane of a graph with several: marks over the shared x scale, on a y
/// scale of its own.
final class GraphPane extends PropRecord {
  const GraphPane._(super.props);

  /// Its share of the graph's height.
  static const growDef = PropDef<double>('grow', _gp, 1);

  /// `rect` (marks over the x scale) or `polar` (the rows round a center:
  /// `arc` marks, no axes).
  static const coordDef = PropDef<String>('coord', _gs, 'rect');
  static const yAxisDef = PropDef<GraphYAxis>('yAxis', GraphYAxis.codec, GraphYAxis.empty);
  static const marksDef = PropDef<List<GraphMark>>('marks', GraphMark.codec, []);
  static const guidesDef = PropDef<List<GraphGuide>>('guides', GraphGuide.codec, []);

  /// Lines at a value, tagged on the axis: `{value | field, label, color,
  /// line, tag, note}` (`field`: the last row's, a last price).
  static const priceLinesDef = PropDef<List<Json>>('priceLines', Codecs.jsonList, []);

  /// Lettered badges at the foot of the pane: `{at, text, color}` (`at`: a
  /// row's key).
  static const markersDef = PropDef<List<Json>>('markers', Codecs.jsonList, []);

  static const spec = WidgetSpec('GraphPane', props: [
    growDef, coordDef, yAxisDef, marksDef, guidesDef, priceLinesDef, markersDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static GraphPane? fromJson(Object? json) => readMap(json) == null ? null : GraphPane._(Props.fromJson(spec, json));
  static const codec = ListCodec<GraphPane>(ValueCodec(fromJson, _recordOut, PropType.record('GraphPane', spec)));
}

/// A field worked out from the rows before each row.
final class GraphTransform extends PropRecord {
  const GraphTransform._(super.props);

  /// `sma`, `ema`, `rsi` (written to `as`) or `bollinger` (to `as` with
  /// `Mid`, `Upper`, `Lower` after it).
  static const typeDef = PropDef<String>('type', _gs, 'sma');
  static const fieldDef = PropDef<String>('field', _gs, '');
  static const asDef = PropDef<String>('as', _gs, '');
  static const periodDef = PropDef<int>('period', IntCodec(min: 1), 20);

  /// Bollinger: how many deviations the bands stand off.
  static const kDef = PropDef<double>('k', _gd, 2);

  static const spec = WidgetSpec('GraphTransform', props: [typeDef, fieldDef, asDef, periodDef, kDef]);

  @override
  WidgetSpec get schema => spec;
  static GraphTransform? fromJson(Object? json) =>
      readMap(json) == null ? null : GraphTransform._(Props.fromJson(spec, json));
  static const codec =
      ListCodec<GraphTransform>(ValueCodec(fromJson, _recordOut, PropType.record('GraphTransform', spec)));
}

/// The selection: the row (or the one bar or slice) under the pointer or a
/// finger, or pinned by a tap. The graph draws it apart and says what it
/// holds in a tooltip.
final class GraphSelection extends PropRecord {
  const GraphSelection._(super.props);

  /// `none`, `hover` (the pointer, or a finger while it is down), `tap` (a
  /// tap selects and stays; a tap on it again lets go) or `both`.
  static const onDef = PropDef<String>('on', _gs, 'none');

  /// `row`: everything the row has. `mark`: the one bar or slice.
  static const byDef = PropDef<String>('by', _gs, 'row');

  /// The opacity of what is not selected while something is (1: as it is).
  static const dimDef = PropDef<double>('dim', DoubleCodec(min: 0, max: 1), 0.35);

  /// A fill behind the selected row, the height of the pane.
  static const bandDef = PropDef<Color?>('band', _gc, null);

  /// How much larger a selected slice is drawn.
  static const growDef = PropDef<double>('grow', _gp, 4);

  /// A dot of this radius on each line at the selected row (0: none).
  static const dotDef = PropDef<double>('dot', _gp, 4);
  static const tooltipDef = PropDef<bool>('tooltip', _gb, true);

  /// The row field of the tooltip's first line; the x label when empty.
  static const titleDef = PropDef<String>('title', _gs, '');

  /// The tooltip's ground and text; the style's `tooltip` and
  /// `tooltipText` when not given.
  static const tooltipFillDef = PropDef<Color?>('tooltipFill', _gc, null);
  static const tooltipTextDef = PropDef<Color?>('tooltipText', _gc, null);

  /// A last tooltip row with the sum of the row's marks.
  static const totalDef = PropDef<bool>('total', _gb, false);

  static const spec = WidgetSpec('GraphSelection', props: [
    onDef, byDef, dimDef, bandDef, growDef, dotDef, tooltipDef, titleDef, tooltipFillDef, tooltipTextDef, totalDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static const empty = GraphSelection._(Props.empty);
  static GraphSelection fromJson(Object? json) => GraphSelection._(Props.fromJson(spec, json));
  static const codec = ValueCodec<GraphSelection>(fromJson, _recordOut, PropType.record('GraphSelection', spec));
}

/// The crosshair: a line through the row under the pointer and one at its
/// value, tagged on both axes.
final class GraphCrosshair extends PropRecord {
  const GraphCrosshair._(super.props);

  static const enabledDef = PropDef<bool>('enabled', _gb, false);

  /// `hover`, `longPress`, `both`, or `touch` (a hover, and a finger from
  /// the moment it is down).
  static const onDef = PropDef<String>('on', _gs, 'both');

  /// The row field its value snaps to; empty for the pointer's own.
  static const magnetDef = PropDef<String>('magnet', _gs, '');
  static const verticalDef = PropDef<bool>('vertical', _gb, true);
  static const horizontalDef = PropDef<bool>('horizontal', _gb, true);

  /// `dashed`, `dotted` or `solid`.
  static const lineDef = PropDef<String>('line', _gs, 'dashed');

  /// A dot of this radius where the lines cross, ringed `dotStroke` wide.
  static const dotDef = PropDef<double>('dot', _gp, 0);
  static const dotStrokeDef = PropDef<double>('dotStroke', _gp, 0);

  /// Where the row's label is written: `axis`, `top` or `none`.
  static const timeLabelDef = PropDef<String>('timeLabel', _gs, 'axis');
  static const timeFormatDef = PropDef<String>('timeFormat', _gs, '');
  static const priceTagDef = PropDef<bool>('priceTag', _gb, true);

  static const spec = WidgetSpec('GraphCrosshair', props: [
    enabledDef, onDef, magnetDef, verticalDef, horizontalDef, lineDef, dotDef, dotStrokeDef, timeLabelDef, //
    timeFormatDef, priceTagDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static const empty = GraphCrosshair._(Props.empty);
  static GraphCrosshair fromJson(Object? json) => GraphCrosshair._(Props.fromJson(spec, json));
  static const codec = ValueCodec<GraphCrosshair>(fromJson, _recordOut, PropType.record('GraphCrosshair', spec));
}

/// What each gesture does to a graph whose view is the user's (an x scale
/// with no fit).
final class GraphInteractions extends PropRecord {
  const GraphInteractions._(super.props);

  /// A drag on the plot pans the view.
  static const dragPanDef = PropDef<bool>('dragPan', _gb, true);

  /// The wheel zooms about the pointer.
  static const wheelZoomDef = PropDef<bool>('wheelZoom', _gb, true);

  /// Two fingers zoom about their middle.
  static const pinchZoomDef = PropDef<bool>('pinchZoom', _gb, true);

  /// A drag on the y axis scales it; on the x axis, zooms.
  static const axisScaleDef = PropDef<bool>('axisScale', _gb, true);

  /// A double tap on an axis fits it again.
  static const doubleTapResetDef = PropDef<bool>('doubleTapReset', _gb, true);

  /// A flick keeps panning and slows down.
  static const flingDef = PropDef<bool>('fling', _gb, true);

  static const spec = WidgetSpec('GraphInteractions', props: [
    dragPanDef, wheelZoomDef, pinchZoomDef, axisScaleDef, doubleTapResetDef, flingDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static const empty = GraphInteractions._(Props.empty);
  static GraphInteractions fromJson(Object? json) => GraphInteractions._(Props.fromJson(spec, json));
  static const codec =
      ValueCodec<GraphInteractions>(fromJson, _recordOut, PropType.record('GraphInteractions', spec));
}

/// A graph's colors and text.
final class GraphStyle extends PropRecord {
  const GraphStyle._(super.props);

  /// Its ground; clear when not given.
  static const backgroundDef = PropDef<Color?>('background', _gc, null);
  static const gridDef = PropDef<Color?>('grid', _gc, null);

  /// The axes' labels.
  static const textDef = PropDef<Color?>('text', _gc, null);
  static const crosshairDef = PropDef<Color?>('crosshair', _gc, null);

  /// A value's tag on an axis, and its text.
  static const tagDef = PropDef<Color?>('tag', _gc, null);
  static const tagTextDef = PropDef<Color?>('tagText', _gc, null);

  /// The line between two panes.
  static const separatorDef = PropDef<Color?>('separator', _gc, null);
  static const fontSizeDef = PropDef<double>('fontSize', _gp, 11);
  static const fontFamilyDef = PropDef<String?>('fontFamily', Codecs.optionalString, null);

  /// Room above the panes.
  static const topInsetDef = PropDef<double>('topInset', _gp, 0);

  /// A figure written large (the one in a donut's hole).
  static const inkDef = PropDef<Color?>('ink', _gc, null);

  /// A tooltip: its ground, its text and the line round it. When not
  /// given: the surface the graph is on, that surface's ink, and a
  /// hairline of it.
  static const tooltipDef = PropDef<Color?>('tooltip', _gc, null);
  static const tooltipTextDef = PropDef<Color?>('tooltipText', _gc, null);
  static const tooltipBorderDef = PropDef<Color?>('tooltipBorder', _gc, null);

  /// The colors of the marks that give none, in turn, and of an arc's
  /// slices. When not given: the theme's series colors (`chart1`,
  /// `chart2`…) where it names them, else its primary followed by colors of
  /// other hues as light and as strong as it.
  static const paletteDef = PropDef<List<String>>('palette', Codecs.strings, []);

  static const spec = WidgetSpec('GraphStyle', props: [
    backgroundDef, gridDef, textDef, crosshairDef, tagDef, tagTextDef, separatorDef, fontSizeDef, fontFamilyDef, //
    topInsetDef, inkDef, paletteDef, tooltipDef, tooltipTextDef, tooltipBorderDef,
  ]);

  @override
  WidgetSpec get schema => spec;
  static const empty = GraphStyle._(Props.empty);
  static GraphStyle fromJson(Object? json) => GraphStyle._(Props.fromJson(spec, json));
  static const codec = ValueCodec<GraphStyle>(fromJson, _recordOut, PropType.record('GraphStyle', spec));
}

/// A graph's legend: a key for each named mark (a dot in its color and its
/// name), or in a polar pane for each slice (its color, its label and its
/// share of the whole).
final class GraphLegend extends PropRecord {
  const GraphLegend._(super.props);

  /// `none`. `auto`: drawn when there is more than one thing to tell apart
  /// and there is room: under a plot with two or more named marks; beside
  /// labeled slices in a graph wide enough that the ring keeps at least
  /// three quarters of its height (slices in a narrower graph have none).
  /// `always`: whenever there is a key to draw (slices in a narrower
  /// graph: under them).
  static const showDef = PropDef<String>('show', _gs, 'none');

  /// `bottom` or `top` (a line of keys in the middle, wrapped) or `right`
  /// (a list). `auto`: under a plot; beside slices where the list fits
  /// there, else under them.
  static const positionDef = PropDef<String>('position', _gs, 'auto');

  /// Each slice's share is written after its label.
  static const valuesDef = PropDef<bool>('values', _gb, true);

  static const spec = WidgetSpec('GraphLegend', props: [showDef, positionDef, valuesDef]);

  @override
  WidgetSpec get schema => spec;
  static const empty = GraphLegend._(Props.empty);
  static GraphLegend fromJson(Object? json) => GraphLegend._(Props.fromJson(spec, json));
  static const codec = ValueCodec<GraphLegend>(fromJson, _recordOut, PropType.record('GraphLegend', spec));
}
