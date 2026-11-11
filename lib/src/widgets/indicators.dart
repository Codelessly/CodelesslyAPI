// Widget declarations: indicators. One WidgetSpec per type; props with Flutter's
// names and defaults (see ../props.dart). Widgets Flutter has no equivalent
// for (progress bars, gauges, charts, barcodes) keep Codelessly's names and
// defaults.
import '../json.dart';
import '../props.dart';
import '../values/color.dart';
import '../values/enums.dart';
import '../values/geometry.dart';
import '../values/text.dart';
import 'indicators_models.dart';

export 'indicators_models.dart';

const _radius = Codecs.radius;
const _style = Codecs.textStyle;

/// Flutter `CircularProgressIndicator`: a spinner, or a ring filled to
/// [value]. [startAngle] and [sweepAngle] draw it as an arc (a dial).
abstract final class CircularProgressIndicatorProps {
  /// Filled fraction, 0–1; null spins (indeterminate).
  static const value = PropDef<double?>('value', IndicatorCodecs.optionalDouble, null);
  static const color = PropDef<Color?>('color', IndicatorCodecs.optionalColor, null);
  static const backgroundColor = PropDef<Color?>('backgroundColor', IndicatorCodecs.optionalColor, null);
  static const strokeWidth = PropDef<double>('strokeWidth', Codecs.positive, 4);

  /// -1 inside the bounds, 0 centered on them, 1 outside.
  static const strokeAlign = PropDef<double>('strokeAlign', Codecs.double, 0);
  static const strokeCap = PropDef<StrokeCap?>('strokeCap', OptionalEnumCodec(StrokeCap.values), null);
  static const trackGap = PropDef<double?>('trackGap', IndicatorCodecs.optionalDouble, null);

  /// Where the ring starts, in degrees clockwise from 3 o'clock.
  static const startAngle = PropDef<double>('startAngle', Codecs.double, -90);

  /// How much of the circle the ring spans, in degrees.
  static const sweepAngle = PropDef<double>('sweepAngle', Codecs.double, 360);

  static const spec = WidgetSpec('circularProgressIndicator',
      props: [value, color, backgroundColor, strokeWidth, strokeAlign, strokeCap, trackGap, startAngle, sweepAngle],
      doc: 'Flutter `CircularProgressIndicator`.');
}

/// Flutter `CupertinoActivityIndicator`.
abstract final class ActivityIndicatorProps {
  static const color = PropDef<Color?>('color', IndicatorCodecs.optionalColor, null);
  static const radius = PropDef<double>('radius', Codecs.positive, 10);
  static const animating = PropDef<bool>('animating', Codecs.bool, true);
  static const spec = WidgetSpec('activityIndicator',
      props: [color, radius, animating], doc: 'Flutter `CupertinoActivityIndicator`.');
}

/// A straight progress bar, or an arc like a dial.
enum ProgressBarShape { bar, arc }

/// How an arc progress bar sits in its box: the arc fitted to the box, or
/// its whole circle (so arcs of any length line up into one ring).
enum ArcFit { arc, circle }

/// A progress bar filled to [value] of [max]: a bar (horizontal, or vertical
/// filling upward) or an arc with ticks, bands and a needle.
abstract final class ProgressBarProps {
  static const value = PropDef<double>('value', Codecs.double, 0);
  static const max = PropDef<double>('max', Codecs.double, 100);
  static const color = PropDef<Color>('color', Codecs.color, Color.black);
  static const backgroundColor = PropDef<Color>('backgroundColor', Codecs.color, Color(0x197F7F7F));
  static const direction = PropDef<Axis>('direction', EnumCodec(Axis.values), Axis.horizontal);
  static const borderRadius = PropDef<BorderRadius>('borderRadius', _radius, BorderRadius.zero);

  /// Animates changes of [value].
  static const animate = PropDef<bool>('animate', Codecs.bool, false);

  /// Milliseconds.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 300);
  static const shape = PropDef<ProgressBarShape>('shape', EnumCodec(ProgressBarShape.values), ProgressBarShape.bar);
  static const arcStartAngle = PropDef<double>('arcStartAngle', Codecs.double, 150);
  static const arcSweepAngle = PropDef<double>('arcSweepAngle', Codecs.double, 240);
  static const arcStrokeWidth = PropDef<double>('arcStrokeWidth', Codecs.positive, 12);
  static const needleColor = PropDef<Color?>('needleColor', IndicatorCodecs.optionalColor, null);
  static const tickCount = PropDef<int>('tickCount', IntCodec(min: 0), 0);
  static const tickColor = PropDef<Color>('tickColor', Codecs.color, Color.white);
  static const bands = PropDef<List<ProgressBand>>('bands', ProgressBand.codec, []);
  static const arcFit = PropDef<ArcFit>('arcFit', EnumCodec(ArcFit.values), ArcFit.arc);
  static const arcRoundCaps = PropDef<bool>('arcRoundCaps', Codecs.bool, false);
  static const progressEndColor = PropDef<Color?>('progressEndColor', IndicatorCodecs.optionalColor, null);
  static const arcGlow = PropDef<double>('arcGlow', Codecs.positive, 0);
  static const arcHeadDot = PropDef<bool>('arcHeadDot', Codecs.bool, false);

  static const spec = WidgetSpec('progressBar', props: [
    value, max, color, backgroundColor, direction, borderRadius, animate, animationDuration, shape, arcStartAngle, //
    arcSweepAngle, arcStrokeWidth, needleColor, tickCount, tickColor, bands, arcFit, arcRoundCaps, progressEndColor,
    arcGlow, arcHeadDot,
  ], doc: 'Progress bar (bar or arc).');
}

/// A radial dial: zones, ticks, labels, a value arc (continuous or in
/// segments), a target notch and a needle.
abstract final class RadialGaugeProps {
  static const value = PropDef<double>('value', Codecs.double, 0);
  static const min = PropDef<double>('min', Codecs.double, 0);
  static const max = PropDef<double>('max', Codecs.double, 100);
  static const startAngle = PropDef<double>('startAngle', Codecs.double, 150);
  static const sweepAngle = PropDef<double>('sweepAngle', Codecs.double, 240);
  static const thickness = PropDef<double>('thickness', Codecs.double, 14);
  static const trackColor = PropDef<Color>('trackColor', Codecs.color, Color(0xFF121316));
  static const valueColor = PropDef<Color>('valueColor', Codecs.color, Color(0xFFFFD400));

  /// The value arc takes the color of the zone its value is in.
  static const colorByZone = PropDef<bool>('colorByZone', Codecs.bool, true);
  /// Round the continuous value arc's ends; tracks and segments keep flat ends.
  static const roundCaps = PropDef<bool>('roundCaps', Codecs.bool, false);
  static const segments = PropDef<int>('segments', IntCodec(min: 0), 40);

  /// Degrees between segments.
  static const segmentGap = PropDef<double>('segmentGap', Codecs.double, 0.9);
  static const zones = PropDef<List<GaugeZone>>('zones', GaugeZone.codec, []);
  static const zoneThickness = PropDef<double>('zoneThickness', Codecs.double, 4);
  static const zoneOpacity = PropDef<double>('zoneOpacity', Codecs.double, 0.55);
  static const majorTicks = PropDef<int>('majorTicks', IntCodec(min: 0), 10);
  static const minorTicks = PropDef<int>('minorTicks', IntCodec(min: 0), 1);
  static const tickColor = PropDef<Color>('tickColor', Codecs.color, Color(0xFFA3ABB2));
  static const labels = PropDef<List<double>>('labels', IndicatorCodecs.doubles, [0, 60, 85, 100]);
  static const labelColor = PropDef<Color>('labelColor', Codecs.color, Color(0xFF707882));
  static const labelFontSize = PropDef<double>('labelFontSize', Codecs.positive, 10);
  static const labelFontFamily = PropDef<String?>('labelFontFamily', IndicatorCodecs.optionalString, null);
  static const showTarget = PropDef<bool>('showTarget', Codecs.bool, true);
  static const target = PropDef<double>('target', Codecs.double, 85);
  static const targetColor = PropDef<Color>('targetColor', Codecs.color, Color(0xFFE8EBED));
  static const showNeedle = PropDef<bool>('showNeedle', Codecs.bool, true);
  static const needleColor = PropDef<Color>('needleColor', Codecs.color, Color(0xFFE8EBED));

  /// Where the needle starts, as a fraction of the radius.
  static const needleClearance = PropDef<double>('needleClearance', Codecs.double, 0.62);
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 420);

  static const spec = WidgetSpec('radialGauge', props: [
    value, min, max, startAngle, sweepAngle, thickness, trackColor, valueColor, colorByZone, roundCaps, segments, segmentGap, //
    zones, zoneThickness, zoneOpacity, majorTicks, minorTicks, tickColor, labels, labelColor, labelFontSize,
    labelFontFamily, showTarget, target, targetColor, showNeedle, needleColor, needleClearance, animate,
    animationDuration,
  ], doc: 'Radial gauge (dial).');
}

/// The shape of a gauge meter.
enum GaugeShape { arc, bar }

/// How a gauge meter's limit line is drawn.
enum GaugeLimitStyle { solid, dashed }

/// A meter: [value] between [min] and [max] as a filled arc or bar
/// (continuous or in segments), with ticks and a [limit] marker.
abstract final class GaugeMeterProps {
  static const value = PropDef<double>('value', Codecs.double, 0);
  static const limit = PropDef<double?>('limit', IndicatorCodecs.optionalDouble, null);
  static const shape = PropDef<GaugeShape>('shape', EnumCodec(GaugeShape.values), GaugeShape.arc);
  static const min = PropDef<double>('min', Codecs.double, 0);
  static const max = PropDef<double>('max', Codecs.double, 100);
  static const color = PropDef<Color>('color', Codecs.color, Color(0xFF3DD68C));
  static const trackColor = PropDef<Color>('trackColor', Codecs.color, Color(0xFF282D35));

  /// Bar only: the fill fades from this opacity at its start to full.
  static const fillStartOpacity = PropDef<double>('fillStartOpacity', Codecs.double, 1);
  static const segments = PropDef<int>('segments', IntCodec(min: 0), 0);
  static const segmentGap = PropDef<double>('segmentGap', Codecs.double, 1.25);

  /// Arc only: stroke width; 0 derives it from the size.
  static const thickness = PropDef<double>('thickness', Codecs.double, 0);
  static const startAngle = PropDef<double>('startAngle', Codecs.double, 135);
  static const sweepAngle = PropDef<double>('sweepAngle', Codecs.double, 270);
  static const cornerRadius = PropDef<double>('cornerRadius', Codecs.double, 0);
  static const backgroundColor = PropDef<Color>('backgroundColor', Codecs.color, Color.transparent);
  static const borderColor = PropDef<Color>('borderColor', Codecs.color, Color.transparent);
  static const inset = PropDef<double>('inset', Codecs.double, 0);
  static const edgeWidth = PropDef<double>('edgeWidth', Codecs.double, 0);
  static const edgeColor = PropDef<Color>('edgeColor', Codecs.color, Color.white);
  static const ticks = PropDef<int>('ticks', IntCodec(min: 0), 0);
  static const majorTickEvery = PropDef<int>('majorTickEvery', IntCodec(min: 0), 0);
  static const tickColor = PropDef<Color>('tickColor', Codecs.color, Color(0xFF3A3F47));
  static const limitColor = PropDef<Color>('limitColor', Codecs.color, Color(0xFFF2C130));
  static const limitWidth = PropDef<double>('limitWidth', Codecs.double, 3);
  static const limitStyle =
      PropDef<GaugeLimitStyle>('limitStyle', EnumCodec(GaugeLimitStyle.values), GaugeLimitStyle.solid);
  static const limitPointer = PropDef<bool>('limitPointer', Codecs.bool, false);
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 700);

  static const spec = WidgetSpec('gaugeMeter', props: [
    value, limit, shape, min, max, color, trackColor, fillStartOpacity, segments, segmentGap, thickness, startAngle, //
    sweepAngle, cornerRadius, backgroundColor, borderColor, inset, edgeWidth, edgeColor, ticks, majorTickEvery,
    tickColor, limitColor, limitWidth, limitStyle, limitPointer, animate, animationDuration,
  ], doc: 'Gauge meter (arc or bar).');
}

/// What a series chart draws.
enum ChartType { bar, line, timeline, donut }

/// A chart of data rows: bars, lines and areas over categories, a timeline
/// of segments, or a donut.
abstract final class ChartProps {
  /// The highlighted category, -1 for none.
  static const selectedIndex = PropDef<int>('selectedIndex', Codecs.int, -1);
  static const chartType = PropDef<ChartType>('chartType', EnumCodec(ChartType.values), ChartType.bar);
  static const series = PropDef<List<ChartSeries>>('series', ChartSeries.codec, []);

  /// The row field holding each category's x-axis label.
  static const labelField = PropDef<String>('labelField', Codecs.string, 'label');

  /// The data rows (bindable).
  static const data = PropDef<List<Json>>('data', IndicatorCodecs.objects, []);
  static const minY = PropDef<double?>('minY', IndicatorCodecs.optionalDouble, null);
  static const maxY = PropDef<double?>('maxY', IndicatorCodecs.optionalDouble, null);
  static const gridLines = PropDef<int>('gridLines', IntCodec(min: 0), 4);
  static const gridColor = PropDef<Color>('gridColor', Codecs.color, Color(0xFF292E33));
  static const showYAxis = PropDef<bool>('showYAxis', Codecs.bool, true);
  static const yAxisWidth = PropDef<double>('yAxisWidth', Codecs.double, 36);
  static const showXAxis = PropDef<bool>('showXAxis', Codecs.bool, true);
  static const xLabelEvery = PropDef<int>('xLabelEvery', Codecs.int, 1);
  static const axisLabelColor = PropDef<Color>('axisLabelColor', Codecs.color, Color(0xFF707882));
  static const axisFontSize = PropDef<double>('axisFontSize', Codecs.positive, 10);
  static const axisFontFamily = PropDef<String?>('axisFontFamily', IndicatorCodecs.optionalString, null);
  static const referenceLines = PropDef<List<ChartReferenceLine>>('referenceLines', ChartReferenceLine.codec, []);
  static const barWidthFraction = PropDef<double>('barWidthFraction', Codecs.double, 0.62);
  static const maxBarWidth = PropDef<double>('maxBarWidth', Codecs.double, 36);
  static const barGap = PropDef<double>('barGap', Codecs.double, 2);
  static const barRadius = PropDef<double>('barRadius', Codecs.double, 0);
  static const dashEmpty = PropDef<bool>('dashEmpty', Codecs.bool, true);
  static const selectionColor = PropDef<Color>('selectionColor', Codecs.color, Color(0x14FFD400));
  static const xSlots = PropDef<int>('xSlots', Codecs.int, 0);
  static const startField = PropDef<String>('startField', Codecs.string, 'from');
  static const endField = PropDef<String>('endField', Codecs.string, 'to');
  static const segmentColorField = PropDef<String>('segmentColorField', Codecs.string, 'color');
  static const domainMin = PropDef<double>('domainMin', Codecs.double, 0);
  static const domainMax = PropDef<double>('domainMax', Codecs.double, 100);
  static const nowValue = PropDef<double?>('nowValue', IndicatorCodecs.optionalDouble, null);
  static const nowColor = PropDef<Color?>('nowColor', IndicatorCodecs.optionalColor, null);
  static const trackColor = PropDef<Color>('trackColor', Codecs.color, Color(0xFF121316));
  static const divisions = PropDef<int>('divisions', Codecs.int, 8);
  static const donutThickness = PropDef<double>('donutThickness', Codecs.double, 0.15);
  static const sliceGap = PropDef<double>('sliceGap', Codecs.double, 1.5);
  static const startAngle = PropDef<double>('startAngle', Codecs.double, 0);
  static const selectOnHover = PropDef<bool>('selectOnHover', Codecs.bool, false);
  static const plotInset = PropDef<double?>('plotInset', IndicatorCodecs.optionalDouble, null);
  static const fitMinY = PropDef<bool>('fitMinY', Codecs.bool, false);
  static const yLabelPrefix = PropDef<String>('yLabelPrefix', Codecs.string, '');
  static const yLabelSuffix = PropDef<String>('yLabelSuffix', Codecs.string, '');
  static const yAxisFontFamily = PropDef<String?>('yAxisFontFamily', IndicatorCodecs.optionalString, null);

  /// Animates numeric data changes; initial and design-canvas values rest.
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds. Zero applies data changes immediately.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 700);

  static const spec = WidgetSpec('chart', props: [
    selectedIndex, chartType, series, labelField, data, minY, maxY, gridLines, gridColor, showYAxis, yAxisWidth, //
    showXAxis, xLabelEvery, axisLabelColor, axisFontSize, axisFontFamily, referenceLines, barWidthFraction,
    maxBarWidth, barGap, barRadius, dashEmpty, selectionColor, xSlots, startField, endField, segmentColorField,
    domainMin, domainMax, nowValue, nowColor, trackColor, divisions, donutThickness, sliceGap, startAngle,
    selectOnHover, plotInset, fitMinY, yLabelPrefix, yLabelSuffix, yAxisFontFamily,
    animate, animationDuration,
  ], doc: 'Series chart (bar, line, timeline, donut).');
}

/// A line/area chart of [points] spread evenly over an x domain, with an
/// x value selected by tapping or dragging.
abstract final class PlotChartProps {
  static const selectedX = PropDef<double?>('selectedX', IndicatorCodecs.optionalDouble, null);
  static const points = PropDef<List<double>>('points', IndicatorCodecs.doubles, []);
  static const xMin = PropDef<double>('xMin', Codecs.double, 0);
  static const xMax = PropDef<double>('xMax', Codecs.double, 1);
  static const yMin = PropDef<double?>('yMin', IndicatorCodecs.optionalDouble, null);
  static const yMax = PropDef<double?>('yMax', IndicatorCodecs.optionalDouble, null);
  static const plotInset = PropDef<double>('plotInset', Codecs.double, 8);
  static const lineColor = PropDef<Color>('lineColor', Codecs.color, Color(0xFF1F6F78));
  static const lineWidth = PropDef<double>('lineWidth', Codecs.positive, 2);
  static const fillColor = PropDef<Color?>('fillColor', IndicatorCodecs.optionalColor, null);
  static const smooth = PropDef<bool>('smooth', Codecs.bool, false);
  static const gridStepX = PropDef<double?>('gridStepX', IndicatorCodecs.optionalDouble, null);
  static const gridColor = PropDef<Color>('gridColor', Codecs.color, Color(0x19000000));
  static const axisColor = PropDef<Color?>('axisColor', IndicatorCodecs.optionalColor, null);
  static const xLabels = PropDef<List<PlotChartLabel>>('xLabels', PlotChartLabel.codec, []);
  static const gridLabels = PropDef<List<String>>('gridLabels', IndicatorCodecs.strings, []);

  /// Axis labels; unset fields fall back to 10px, 54% black.
  static const labelStyle = PropDef<TextStyle>('labelStyle', _style, TextStyle.empty);
  static const labelHeight = PropDef<double>('labelHeight', Codecs.double, 16);
  static const ranges = PropDef<List<PlotChartRange>>('ranges', PlotChartRange.codec, []);
  static const markers = PropDef<List<PlotChartMarker>>('markers', PlotChartMarker.codec, []);
  static const markerRadius = PropDef<double>('markerRadius', Codecs.double, 3.5);

  /// Marker labels (each in its marker's color); unset fields fall back to
  /// 10px bold.
  static const markerLabelStyle = PropDef<TextStyle>('markerLabelStyle', _style, TextStyle.empty);
  static const referenceX = PropDef<double?>('referenceX', IndicatorCodecs.optionalDouble, null);
  static const referenceColor = PropDef<Color>('referenceColor', Codecs.color, Color(0xFFF2542D));
  static const referenceWidth = PropDef<double>('referenceWidth', Codecs.double, 1.5);
  static const referenceDashed = PropDef<bool>('referenceDashed', Codecs.bool, true);
  static const selectable = PropDef<bool>('selectable', Codecs.bool, true);
  static const selectionStep = PropDef<double>('selectionStep', Codecs.double, 1);
  static const selectionMin = PropDef<double?>('selectionMin', IndicatorCodecs.optionalDouble, null);
  static const selectionMax = PropDef<double?>('selectionMax', IndicatorCodecs.optionalDouble, null);
  static const selectionColor = PropDef<Color>('selectionColor', Codecs.color, Color(0x19000000));
  static const selectionLineColor = PropDef<Color>('selectionLineColor', Codecs.color, Color.black);
  static const selectionLineWidth = PropDef<double>('selectionLineWidth', Codecs.double, 1.5);
  static const selectionDotRadius = PropDef<double>('selectionDotRadius', Codecs.double, 6.5);
  static const selectionDotColor = PropDef<Color>('selectionDotColor', Codecs.color, Color.white);
  static const selectionDotStrokeColor = PropDef<Color>('selectionDotStrokeColor', Codecs.color, Color.black);
  static const selectionDotStrokeWidth = PropDef<double>('selectionDotStrokeWidth', Codecs.double, 2.5);

  /// Animates numeric data changes; initial and design-canvas values rest.
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds. Zero applies data changes immediately.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 700);

  static const spec = WidgetSpec('plotChart', props: [
    selectedX, points, xMin, xMax, yMin, yMax, plotInset, lineColor, lineWidth, fillColor, smooth, gridStepX, //
    gridColor, axisColor, xLabels, gridLabels, labelStyle, labelHeight, ranges, markers, markerRadius,
    markerLabelStyle, referenceX, referenceColor, referenceWidth, referenceDashed, selectable, selectionStep,
    selectionMin, selectionMax, selectionColor, selectionLineColor, selectionLineWidth, selectionDotRadius,
    selectionDotColor, selectionDotStrokeColor, selectionDotStrokeWidth,
    animate, animationDuration,
  ], doc: 'Plot chart (line/area over an x domain).');
}

/// A bar chart of [values] with optional labels, grid and a highlighted bar.
abstract final class BarChartProps {
  /// One bar per value; null draws an empty stub.
  static const values = PropDef<List<double?>>('values', NullableDoublesCodec(), []);
  static const labels = PropDef<List<String>>('labels', IndicatorCodecs.strings, []);
  static const highlight = PropDef<int?>('highlight', OptionalIntCodec(), null);

  /// The value of a full bar; 0 uses the largest value.
  static const max = PropDef<double>('max', Codecs.double, 0);
  static const color = PropDef<Color>('color', Codecs.color, Color(0xFFF2C130));

  /// Per-bar colours; missing entries fall back to color.
  static const colors = PropDef<List<Color>>('colors', ListCodec<Color>(Codecs.color), []);
  static const dimmedOpacity = PropDef<double>('dimmedOpacity', Codecs.double, 0.55);
  static const barGap = PropDef<double>('barGap', Codecs.double, 3);
  static const barRadius = PropDef<double>('barRadius', Codecs.double, 1);
  static const emptyColor = PropDef<Color>('emptyColor', Codecs.color, Color(0xFF3A3F47));
  static const emptyHeight = PropDef<double>('emptyHeight', Codecs.double, 2);
  static const gridLines = PropDef<int>('gridLines', IntCodec(min: 0), 3);
  static const gridColor = PropDef<Color>('gridColor', Codecs.color, Color(0xFF2B3038));
  static const gridLabels = PropDef<List<String>>('gridLabels', IndicatorCodecs.strings, []);
  static const gridLabelWidth = PropDef<double>('gridLabelWidth', Codecs.double, 40);
  static const baselineColor = PropDef<Color>('baselineColor', Codecs.color, Color(0xFF3A3F47));
  static const labelFontFamily = PropDef<String>('labelFontFamily', Codecs.string, 'JetBrains Mono');
  static const labelFontSize = PropDef<double>('labelFontSize', Codecs.positive, 10);
  static const labelColor = PropDef<Color>('labelColor', Codecs.color, Color(0xFF6B727C));
  static const highlightLabelColor = PropDef<Color>('highlightLabelColor', Codecs.color, Color(0xFFE8EAED));
  static const labelGap = PropDef<double>('labelGap', Codecs.double, 6);
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 700);

  static const spec = WidgetSpec('barChart', props: [
    values, labels, highlight, max, color, colors, dimmedOpacity, barGap, barRadius, emptyColor, emptyHeight, gridLines, //
    gridColor, gridLabels, gridLabelWidth, baselineColor, labelFontFamily, labelFontSize, labelColor,
    highlightLabelColor, labelGap, animate, animationDuration,
  ], doc: 'Bar chart.');
}

/// A line chart of data rows ([xField], [yField]; dates or numbers on x),
/// with bands, ticks, markers and lines given as data (usually bound).
abstract final class LineChartProps {
  static const data = PropDef<List<Json>>('data', IndicatorCodecs.objects, []);
  static const xField = PropDef<String>('xField', Codecs.string, 'x');
  static const yField = PropDef<String>('yField', Codecs.string, 'y');
  static const xMin = PropDef<double?>('xMin', IndicatorCodecs.optionalDouble, null);
  static const xMax = PropDef<double?>('xMax', IndicatorCodecs.optionalDouble, null);
  static const yMin = PropDef<double?>('yMin', IndicatorCodecs.optionalDouble, null);
  static const yMax = PropDef<double?>('yMax', IndicatorCodecs.optionalDouble, null);

  /// Room around the plot for the axes and labels.
  static const plotPadding =
      PropDef<EdgeInsets>('plotPadding', Codecs.insets, EdgeInsets.fromLTRB(44, 30, 14, 30));
  static const smooth = PropDef<bool>('smooth', Codecs.bool, false);
  static const lineColor = PropDef<Color>('lineColor', Codecs.color, Color.black);
  static const lineWidth = PropDef<double>('lineWidth', Codecs.positive, 2);
  static const areaTopColor = PropDef<Color>('areaTopColor', Codecs.color, Color(0x19000000));
  static const areaBottomColor = PropDef<Color>('areaBottomColor', Codecs.color, Color.transparent);
  static const gridColor = PropDef<Color>('gridColor', Codecs.color, Color(0x19000000));
  static const zeroLineColor = PropDef<Color>('zeroLineColor', Codecs.color, Color(0x89000000));
  static const axisColor = PropDef<Color>('axisColor', Codecs.color, Color.black);
  static const markerHollowColor = PropDef<Color>('markerHollowColor', Codecs.color, Color.white);
  static const tagBackground = PropDef<Color>('tagBackground', Codecs.color, Color.black);
  static const cursorColor = PropDef<Color>('cursorColor', Codecs.color, Color.black);
  static const cursorRingFill = PropDef<Color>('cursorRingFill', Codecs.color, Color.white);
  static const tooltipBackground = PropDef<Color>('tooltipBackground', Codecs.color, Color.black);
  static const tooltipShadowColor = PropDef<Color>('tooltipShadowColor', Codecs.color, Color.transparent);
  static const yAxisTitle = PropDef<String>('yAxisTitle', Codecs.string, '');
  static const axisLabelStyle = PropDef<TextStyle>('axisLabelStyle', _style, TextStyle.empty);
  static const axisTitleStyle = PropDef<TextStyle>('axisTitleStyle', _style, TextStyle.empty);
  static const markerLabelStyle = PropDef<TextStyle>('markerLabelStyle', _style, TextStyle.empty);
  static const tagTextStyle = PropDef<TextStyle>('tagTextStyle', _style, TextStyle.empty);
  static const tooltipLabelStyle = PropDef<TextStyle>('tooltipLabelStyle', _style, TextStyle.empty);
  static const tooltipValueStyle = PropDef<TextStyle>('tooltipValueStyle', _style, TextStyle.empty);
  static const scrubEnabled = PropDef<bool>('scrubEnabled', Codecs.bool, false);
  static const scrubStep = PropDef<double>('scrubStep', Codecs.double, 1);
  static const tooltipXFormat = PropDef<String>('tooltipXFormat', Codecs.string, 'h:mm a');
  static const tooltipYScale = PropDef<double>('tooltipYScale', Codecs.double, 1);
  static const tooltipYDecimals = PropDef<int>('tooltipYDecimals', IntCodec(min: 0), 1);
  static const tooltipYSuffix = PropDef<String>('tooltipYSuffix', Codecs.string, '');
  static const tooltipTrend = PropDef<bool>('tooltipTrend', Codecs.bool, false);
  static const semanticLabel = PropDef<String>('semanticLabel', Codecs.string, '');

  /// Full-height bands: `[{"from", "to", "color", "opacity"?}]`.
  static const bands = PropDef<List<Json>>('bands', IndicatorCodecs.objects, []);

  /// Horizontal grid lines: `[{"y", "label"?, "color"?, "align"?: "start"}]`.
  static const yTicks = PropDef<List<Json>>('yTicks', IndicatorCodecs.objects, []);

  /// Parts of the area under the curve: `[{"from", "to", "below", "color", "barColor"?}]`.
  static const areaBands = PropDef<List<Json>>('areaBands', IndicatorCodecs.objects, []);

  /// Dashed horizontal lines: `[{"y", "color"?, "width"?, "dash"?: [on, off]}]`.
  static const referenceLines = PropDef<List<Json>>('referenceLines', IndicatorCodecs.objects, []);

  /// X axis ticks: `[{"x", "label"}]`.
  static const xTicks = PropDef<List<Json>>('xTicks', IndicatorCodecs.objects, []);

  /// Circles on points: `[{"x", "y", "label"?, "filled"?, "above"?, "color"?, "radius"?, ...}]`.
  static const markers = PropDef<List<Json>>('markers', IndicatorCodecs.objects, []);

  /// Dashed vertical lines: `[{"x", "color"?, "dash"?, "label"?, "dotOnCurve"?, "dotColor"?}]`.
  static const verticalLines = PropDef<List<Json>>('verticalLines', IndicatorCodecs.objects, []);

  /// Animates numeric data changes; initial and design-canvas values rest.
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds. Zero applies data changes immediately.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 700);

  static const spec = WidgetSpec('lineChart', props: [
    data, xField, yField, xMin, xMax, yMin, yMax, plotPadding, smooth, lineColor, lineWidth, areaTopColor, //
    areaBottomColor, gridColor, zeroLineColor, axisColor, markerHollowColor, tagBackground, cursorColor,
    cursorRingFill, tooltipBackground, tooltipShadowColor, yAxisTitle, axisLabelStyle, axisTitleStyle,
    markerLabelStyle, tagTextStyle, tooltipLabelStyle, tooltipValueStyle, scrubEnabled, scrubStep, tooltipXFormat,
    tooltipYScale, tooltipYDecimals, tooltipYSuffix, tooltipTrend, semanticLabel, bands, yTicks, areaBands,
    referenceLines, xTicks, markers, verticalLines,
    animate, animationDuration,
  ], doc: 'Line chart.');
}

/// The encoding of a barcode.
enum BarcodeSymbology {
  qrCode,
  pdf417,
  code128,
  aztec,
  dataMatrix,
  ean13;

  /// A two-dimensional code (never draws text).
  bool get is2D => switch (this) {
        qrCode || pdf417 || aztec || dataMatrix => true,
        code128 || ean13 => false,
      };

  /// Square modules: kept square and centered; the others stretch.
  bool get hasSquareModules => this == qrCode || this == aztec || this == dataMatrix;
}

/// How much of a QR code can be damaged and still be read.
enum BarcodeErrorCorrection { low, medium, quartile, high }

/// A barcode or QR code of [data], filling the box.
abstract final class BarcodeProps {
  static const data = PropDef<String>('data', Codecs.string, '');
  static const symbology =
      PropDef<BarcodeSymbology>('symbology', EnumCodec(BarcodeSymbology.values), BarcodeSymbology.qrCode);
  static const color = PropDef<Color>('color', Codecs.color, Color.black);
  static const backgroundColor = PropDef<Color?>('backgroundColor', IndicatorCodecs.optionalColor, null);
  static const errorCorrection = PropDef<BarcodeErrorCorrection>(
      'errorCorrection', EnumCodec(BarcodeErrorCorrection.values), BarcodeErrorCorrection.medium);

  /// 1D codes: the text under the bars.
  static const drawText = PropDef<bool>('drawText', Codecs.bool, true);

  static const spec = WidgetSpec('barcode',
      props: [data, symbology, color, backgroundColor, errorCorrection, drawText], doc: 'Barcode / QR code.');
}

const List<WidgetSpec> indicatorsSpecs = [
  CircularProgressIndicatorProps.spec,
  ActivityIndicatorProps.spec,
  ProgressBarProps.spec,
  RadialGaugeProps.spec,
  GaugeMeterProps.spec,
  ChartProps.spec,
  PlotChartProps.spec,
  BarChartProps.spec,
  LineChartProps.spec,
  BarcodeProps.spec,
];
