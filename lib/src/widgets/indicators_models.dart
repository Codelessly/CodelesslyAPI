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

  /// Line and area series: its [name] and last value written at the end of
  /// its line, in its color (labels of different series are kept apart).
  static const endLabelDef = PropDef<bool>('endLabel', Codecs.bool, false);

  static const spec = WidgetSpec('ChartSeries', props: [
    fieldDef, nameDef, kindDef, colorDef, colorFieldDef, stackDef, dashedDef, strokeWidthDef, endDotDef, //
    endDotHaloColorDef, curvedDef, fillToDef, fillOpacityDef, endLabelDef,
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
  Color? get endDotHaloColor => get(endDotHaloColorDef);
  bool get curved => get(curvedDef);
  String? get fillTo => get(fillToDef);
  double get fillOpacity => get(fillOpacityDef);
  bool get endLabel => get(endLabelDef);

  ChartSeries withColor(Color color) => ChartSeries._(props.set(colorDef, color));

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
