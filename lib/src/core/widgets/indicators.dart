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
      hugs: true,
      doc: 'Flutter `CircularProgressIndicator`. With nothing set it is the default (SSUI) spinner: a 2 px arc in the '
          'primary colour, round-ended, 16 px when it hugs.');
}

/// Flutter `CupertinoActivityIndicator`.
abstract final class ActivityIndicatorProps {
  static const color = PropDef<Color?>('color', IndicatorCodecs.optionalColor, null);
  static const radius = PropDef<double>('radius', Codecs.positive, 10);
  static const animating = PropDef<bool>('animating', Codecs.bool, true);
  static const spec = WidgetSpec('activityIndicator',
      props: [color, radius, animating], hugs: true,
      doc: 'Flutter `CupertinoActivityIndicator`: eight ticks stepping round, twice `radius` across, in the secondary '
          'text colour unless `color` says.');
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

  /// Bar: the fill is the exact fraction (false: whole percents, as a flex
  /// row of the two parts).
  static const exactFill = PropDef<bool>('exactFill', Codecs.bool, false);

  /// Bar: the fill is cut by the track's rounded shape (round only where
  /// the track is, square at its end) instead of rounded itself.
  static const clipFill = PropDef<bool>('clipFill', Codecs.bool, false);

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

  static const spec = WidgetSpec('progressBar', fillsWidth: true, props: [
    exactFill, clipFill,
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
  /// Null: the theme's outlineVariant (`ControlTheme`), so it reads in light and dark.
  static const trackColor = PropDef<Color?>('trackColor', Codecs.optionalColor, null);
  /// Null: the theme's primary (`ControlTheme`), so it reads in light and dark.
  static const valueColor = PropDef<Color?>('valueColor', Codecs.optionalColor, null);

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
  /// Null: the theme's outline (`ControlTheme`), so it reads in light and dark.
  static const tickColor = PropDef<Color?>('tickColor', Codecs.optionalColor, null);
  static const labels = PropDef<List<double>>('labels', IndicatorCodecs.doubles, [0, 60, 85, 100]);
  /// Null: the theme's onSurfaceVariant (`ControlTheme`), so it reads in light and dark.
  static const labelColor = PropDef<Color?>('labelColor', Codecs.optionalColor, null);
  static const labelFontSize = PropDef<double>('labelFontSize', Codecs.positive, 10);
  static const labelFontFamily = PropDef<String?>('labelFontFamily', IndicatorCodecs.optionalString, null);
  static const showTarget = PropDef<bool>('showTarget', Codecs.bool, true);
  static const target = PropDef<double>('target', Codecs.double, 85);
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const targetColor = PropDef<Color?>('targetColor', Codecs.optionalColor, null);
  static const showNeedle = PropDef<bool>('showNeedle', Codecs.bool, true);
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const needleColor = PropDef<Color?>('needleColor', Codecs.optionalColor, null);

  /// Where the needle starts, as a fraction of the radius.
  static const needleClearance = PropDef<double>('needleClearance', Codecs.double, 0.62);

  /// How far inside the arc's centre line the labels sit (null: inside the
  /// track, clear of the ticks).
  static const labelInset = PropDef<double?>('labelInset', IndicatorCodecs.optionalDouble, null);

  /// A hairline tick just outside the arc at each label.
  static const labelTicks = PropDef<bool>('labelTicks', Codecs.bool, false);

  /// The target mark crosses the arc (a newspaper's "last time" line)
  /// instead of sitting outside it.
  static const targetAcross = PropDef<bool>('targetAcross', Codecs.bool, false);
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 420);

  static const spec = WidgetSpec('radialGauge', props: [
    value, min, max, startAngle, sweepAngle, thickness, trackColor, valueColor, colorByZone, roundCaps, segments, segmentGap, //
    zones, zoneThickness, zoneOpacity, majorTicks, minorTicks, tickColor, labels, labelColor, labelFontSize,
    labelFontFamily, showTarget, target, targetColor, showNeedle, needleColor, needleClearance, animate,
    animationDuration,
    labelInset, labelTicks, targetAcross,
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
  /// Null: the theme's primary (`ControlTheme`), so it reads in light and dark.
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  /// Null: the theme's outlineVariant (`ControlTheme`), so it reads in light and dark.
  static const trackColor = PropDef<Color?>('trackColor', Codecs.optionalColor, null);

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
  /// Null: the theme's outline (`ControlTheme`), so it reads in light and dark.
  static const tickColor = PropDef<Color?>('tickColor', Codecs.optionalColor, null);
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

/// Where a series chart's y labels sit in the gutter left of the plot: [end]
/// right-aligned 8 px left of the plot, [start] left-aligned at the chart's
/// left edge.
enum ChartYLabelAlign { end, start }

/// How a series chart places its grid lines (and solid reference lines).
/// [centered]: centred on the value's rounded y (the bottom line one pixel
/// row up, inside the plot); a 1 px line there straddles two pixel rows.
/// [crisp] (the default): whole pixel rows from the value's rounded y down
/// (the bottom line's up, inside the plot), so a line of whole width is
/// sharp; other widths stay centred on the value. [exact]: the rows just above the value's
/// unrounded y, like a Flutter box of that height whose bottom edge sits at
/// the value (sharp when that is a whole pixel, soft otherwise).
enum ChartGridLineMode { centered, crisp, exact }

/// Where a stacked bar's [ChartProps.stackGap] goes. [between] (the
/// default): under each segment but the first, so the bar keeps its height.
/// [top]: over every segment, the top one included, as a column of boxes
/// each with a top margin (the bar's top sits the gap below its value).
enum ChartStackGapEdge { between, top }

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
  /// Null: the theme's outlineVariant (`ControlTheme`), so it reads in light and dark.
  static const gridColor = PropDef<Color?>('gridColor', Codecs.optionalColor, null);

  /// The grid's bottom line (the baseline), drawn with the grid under the
  /// bars; null: [gridColor].
  static const baselineColor = PropDef<Color?>('baselineColor', Codecs.optionalColor, null);
  static const showYAxis = PropDef<bool>('showYAxis', Codecs.bool, true);
  static const yAxisWidth = PropDef<double>('yAxisWidth', Codecs.double, 36);
  static const showXAxis = PropDef<bool>('showXAxis', Codecs.bool, true);
  static const xLabelEvery = PropDef<int>('xLabelEvery', Codecs.int, 1);
  /// Null: the theme's onSurfaceVariant (`ControlTheme`), so it reads in light and dark.
  static const axisLabelColor = PropDef<Color?>('axisLabelColor', Codecs.optionalColor, null);
  static const axisFontSize = PropDef<double>('axisFontSize', Codecs.positive, 10);
  static const axisFontFamily = PropDef<String?>('axisFontFamily', IndicatorCodecs.optionalString, null);
  static const referenceLines = PropDef<List<ChartReferenceLine>>('referenceLines', ChartReferenceLine.codec, []);
  static const barWidthFraction = PropDef<double>('barWidthFraction', Codecs.double, 0.62);
  static const maxBarWidth = PropDef<double>('maxBarWidth', Codecs.double, 36);
  static const barGap = PropDef<double>('barGap', Codecs.double, 2);
  static const barRadius = PropDef<double>('barRadius', Codecs.double, 0);
  static const dashEmpty = PropDef<bool>('dashEmpty', Codecs.bool, true);
  /// Null: the theme's primary at 10 % (`ControlTheme`), so it reads in light and dark.
  static const selectionColor = PropDef<Color?>('selectionColor', Codecs.optionalColor, null);
  static const xSlots = PropDef<int>('xSlots', Codecs.int, 0);
  static const startField = PropDef<String>('startField', Codecs.string, 'from');
  static const endField = PropDef<String>('endField', Codecs.string, 'to');
  static const segmentColorField = PropDef<String>('segmentColorField', Codecs.string, 'color');
  static const domainMin = PropDef<double>('domainMin', Codecs.double, 0);
  static const domainMax = PropDef<double>('domainMax', Codecs.double, 100);
  static const nowValue = PropDef<double?>('nowValue', IndicatorCodecs.optionalDouble, null);
  static const nowColor = PropDef<Color?>('nowColor', IndicatorCodecs.optionalColor, null);
  /// Null: the theme's outlineVariant (`ControlTheme`), so it reads in light and dark.
  static const trackColor = PropDef<Color?>('trackColor', Codecs.optionalColor, null);
  static const divisions = PropDef<int>('divisions', Codecs.int, 8);
  static const donutThickness = PropDef<double>('donutThickness', Codecs.double, 0.15);
  static const sliceGap = PropDef<double>('sliceGap', Codecs.double, 1.5);
  static const startAngle = PropDef<double>('startAngle', Codecs.double, 0);
  static const selectOnHover = PropDef<bool>('selectOnHover', Codecs.bool, false);
  static const plotInset = PropDef<double?>('plotInset', IndicatorCodecs.optionalDouble, null);
  static const fitMinY = PropDef<bool>('fitMinY', Codecs.bool, false);
  static const yLabelPrefix = PropDef<String>('yLabelPrefix', Codecs.string, '');
  static const yLabelSuffix = PropDef<String>('yLabelSuffix', Codecs.string, '');

  /// The prefix and suffix go on the top y label only (`50%` over plain
  /// `40`, `30` …), as a newspaper chart marks its unit once.
  static const yLabelAffixTopOnly = PropDef<bool>('yLabelAffixTopOnly', Codecs.bool, false);
  static const yAxisFontFamily = PropDef<String?>('yAxisFontFamily', IndicatorCodecs.optionalString, null);

  /// Bars of other categories fade while one is selected (or hovered).
  static const dimUnselected = PropDef<bool>('dimUnselected', Codecs.bool, false);

  /// A box over the selected (or hovered) category: its label, then each
  /// series' name and value there.
  static const tooltip = PropDef<bool>('tooltip', Codecs.bool, false);
  /// Null: the theme's onSurface (an inverted surface) (`ControlTheme`), so it reads in light and dark.
  static const tooltipColor = PropDef<Color?>('tooltipColor', Codecs.optionalColor, null);
  /// Null: the theme's surface (`ControlTheme`), so it reads in light and dark.
  static const tooltipTextColor = PropDef<Color?>('tooltipTextColor', Codecs.optionalColor, null);

  /// The tooltip's first line: this row field, else the category label.
  static const tooltipTitleField = PropDef<String>('tooltipTitleField', Codecs.string, '');

  /// The tooltip's title, series names and values, merged over the
  /// defaults (12 bold, 13 semibold, 13 bold; the axis font family, in
  /// [tooltipTextColor]).
  static const tooltipTitleStyle = PropDef<TextStyle>('tooltipTitleStyle', _style, TextStyle.empty);
  static const tooltipLabelStyle = PropDef<TextStyle>('tooltipLabelStyle', _style, TextStyle.empty);
  static const tooltipValueStyle = PropDef<TextStyle>('tooltipValueStyle', _style, TextStyle.empty);

  /// Each bar group's total above it; the selected one in
  /// [totalsSelectedColor].
  static const showTotals = PropDef<bool>('showTotals', Codecs.bool, false);
  static const totalsColor = PropDef<Color?>('totalsColor', Codecs.optionalColor, null);
  static const totalsSelectedColor = PropDef<Color?>('totalsSelectedColor', Codecs.optionalColor, null);

  /// Each total's bottom this far above its bar; null centres it 10 px
  /// above the bar.
  static const totalsGap = PropDef<double?>('totalsGap', IndicatorCodecs.optionalDouble, null);

  /// Space between the segments of a stacked bar.
  static const stackGap = PropDef<double>('stackGap', Codecs.positive, 0);

  /// Where [stackGap] goes (see [ChartStackGapEdge]).
  static const stackGapEdge =
      PropDef<ChartStackGapEdge>('stackGapEdge', EnumCodec(ChartStackGapEdge.values), ChartStackGapEdge.between);

  /// The x labels' color (the y labels keep [axisLabelColor]).
  static const xAxisLabelColor = PropDef<Color?>('xAxisLabelColor', Codecs.optionalColor, null);

  /// One category's x label in [highlightColor] (the current hour), apart
  /// from the selection; -1 for none.
  static const highlightIndex = PropDef<int>('highlightIndex', Codecs.int, -1);
  static const highlightColor = PropDef<Color?>('highlightColor', Codecs.optionalColor, null);

  /// Grows in from zero when it first shows (a running app).
  static const animateIn = PropDef<bool>('animateIn', Codecs.bool, false);

  /// Line charts: the row field holding each point's x value, placed over
  /// [domainMin]–[domainMax] (minutes, years...) instead of one slot per
  /// row. Unset: rows sit in slots ([xSlots]).
  static const xField = PropDef<String?>('xField', IndicatorCodecs.optionalString, null);

  /// Line charts with [xField]: x-axis labels at values (`{"x", "label"}`),
  /// drawn instead of each row's label.
  static const xLabels = PropDef<List<PlotChartLabel>>('xLabels', PlotChartLabel.codec, []);

  /// Room right of the plot for series end labels ([ChartSeries.endLabel]).
  static const endLabelWidth = PropDef<double>('endLabelWidth', Codecs.double, 0);

  /// Decimals of the values in series end labels.
  static const endLabelDecimals = PropDef<int>('endLabelDecimals', IntCodec(min: 0), 1);

  /// Where the y labels sit: right-aligned by the plot, or left-aligned at
  /// the chart's left edge.
  static const yLabelAlign =
      PropDef<ChartYLabelAlign>('yLabelAlign', EnumCodec(ChartYLabelAlign.values), ChartYLabelAlign.end);

  /// The x-axis label band's height below the plot.
  static const xAxisHeight = PropDef<double>('xAxisHeight', Codecs.positive, 22);

  /// The x labels' top this far below the plot; null centres them in the
  /// band ([xAxisHeight]).
  static const xLabelGap = PropDef<double?>('xLabelGap', IndicatorCodecs.optionalDouble, null);

  /// How grid lines and solid reference lines meet the pixel grid.
  static const gridLineMode =
      PropDef<ChartGridLineMode>('gridLineMode', EnumCodec(ChartGridLineMode.values), ChartGridLineMode.crisp);

  /// Animates numeric data changes; initial and design-canvas values rest.
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds. Zero applies data changes immediately.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 700);

  static const spec = WidgetSpec('chart', props: [
    selectedIndex, chartType, series, labelField, data, minY, maxY, gridLines, gridColor, showYAxis, yAxisWidth, //
    showXAxis, xLabelEvery, axisLabelColor, axisFontSize, axisFontFamily, referenceLines, barWidthFraction,
    maxBarWidth, barGap, barRadius, dashEmpty, selectionColor, xSlots, startField, endField, segmentColorField,
    domainMin, domainMax, nowValue, nowColor, trackColor, divisions, donutThickness, sliceGap, startAngle,
    selectOnHover, plotInset, fitMinY, yLabelPrefix, yLabelSuffix, yLabelAffixTopOnly, yAxisFontFamily, dimUnselected, tooltip,
    tooltipColor, tooltipTextColor, tooltipTitleField, tooltipTitleStyle, tooltipLabelStyle, tooltipValueStyle,
    showTotals, totalsColor, totalsSelectedColor, totalsGap, stackGap, stackGapEdge, baselineColor,
    xAxisLabelColor, highlightIndex, highlightColor, animateIn,
    xField, xLabels, endLabelWidth, endLabelDecimals, yLabelAlign, xAxisHeight, xLabelGap, gridLineMode,
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

  /// Room round the plot (top, right, bottom; the left is [yAxisWidth]) in
  /// place of [plotInset]: values map between them and ranges fill them.
  static const plotPadding = PropDef<EdgeInsets?>('plotPadding', Codecs.insets, null);
  /// Null: the theme's primary (`ControlTheme`), so it reads in light and dark.
  static const lineColor = PropDef<Color?>('lineColor', Codecs.optionalColor, null);
  static const lineWidth = PropDef<double>('lineWidth', Codecs.positive, 2);
  static const fillColor = PropDef<Color?>('fillColor', IndicatorCodecs.optionalColor, null);
  static const smooth = PropDef<bool>('smooth', Codecs.bool, false);
  static const gridStepX = PropDef<double?>('gridStepX', IndicatorCodecs.optionalDouble, null);
  /// Null: the theme's outlineVariant (`ControlTheme`), so it reads in light and dark.
  static const gridColor = PropDef<Color?>('gridColor', Codecs.optionalColor, null);
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
  /// Null: the theme's error (`ControlTheme`), so it reads in light and dark.
  static const referenceColor = PropDef<Color?>('referenceColor', Codecs.optionalColor, null);
  static const referenceWidth = PropDef<double>('referenceWidth', Codecs.double, 1.5);
  static const referenceDashed = PropDef<bool>('referenceDashed', Codecs.bool, true);
  static const selectable = PropDef<bool>('selectable', Codecs.bool, true);
  static const selectionStep = PropDef<double>('selectionStep', Codecs.double, 1);
  static const selectionMin = PropDef<double?>('selectionMin', IndicatorCodecs.optionalDouble, null);
  static const selectionMax = PropDef<double?>('selectionMax', IndicatorCodecs.optionalDouble, null);
  /// Null: the theme's onSurface at 10 % (`ControlTheme`), so it reads in light and dark.
  static const selectionColor = PropDef<Color?>('selectionColor', Codecs.optionalColor, null);
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const selectionLineColor = PropDef<Color?>('selectionLineColor', Codecs.optionalColor, null);
  static const selectionLineWidth = PropDef<double>('selectionLineWidth', Codecs.double, 1.5);
  static const selectionDotRadius = PropDef<double>('selectionDotRadius', Codecs.double, 6.5);
  /// Null: the theme's surface (`ControlTheme`), so it reads in light and dark.
  static const selectionDotColor = PropDef<Color?>('selectionDotColor', Codecs.optionalColor, null);
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const selectionDotStrokeColor = PropDef<Color?>('selectionDotStrokeColor', Codecs.optionalColor, null);
  static const selectionDotStrokeWidth = PropDef<double>('selectionDotStrokeWidth', Codecs.double, 2.5);

  /// Horizontal lines: grid lines with y-axis labels, and references (a
  /// dashed target with an inline label).
  static const yLines = PropDef<List<PlotChartYLine>>('yLines', PlotChartYLine.codec, []);

  /// Room left of the plot for the y lines' axis labels.
  static const yAxisWidth = PropDef<double>('yAxisWidth', Codecs.double, 0);

  /// Where the curve (and the area under it) stops, an x value: the rest
  /// of the domain stays empty (a series that hasn't happened yet). Unset:
  /// the whole domain.
  static const lineEndX = PropDef<double?>('lineEndX', IndicatorCodecs.optionalDouble, null);

  /// A dot of this radius where the curve ends, in the line color with a
  /// [selectionDotColor] ring; 0 for none.
  static const endDotRadius = PropDef<double>('endDotRadius', Codecs.double, 0);

  /// Markers are rings (the marker's color round a [selectionDotColor]
  /// center) instead of dots.
  static const markerHollow = PropDef<bool>('markerHollow', Codecs.bool, false);

  // --- Cartesian graph -------------------------------------------------------
  //
  // The general parts of a line chart's model (series, grid, axes, the
  // selection's guides), as chart libraries name them; any plot can use
  // them, and each is computed from the data as it paints (extents, tick
  // positions and labels), which a draw list would have to be handed
  // (docs/design/01-paint-node.md, "30.1.0").

  /// More curves over the same x domain, each with gaps (null points): a
  /// chart's series (fl_chart's `LineChartData.lineBarsData`).
  static const series = PropDef<List<PlotChartSeries>>('series', PlotChartSeries.codec, []);

  /// Where vertical grid lines start: xMin (default) or multiples of the
  /// step.
  static const gridAnchor =
      PropDef<PlotChartGridAnchor>('gridAnchor', EnumCodec(PlotChartGridAnchor.values), PlotChartGridAnchor.start);

  /// Horizontal grid lines at multiples of this step (none when unset): the
  /// grid's horizontal interval (fl_chart's `FlGridData.horizontalInterval`).
  static const gridStepY = PropDef<double?>('gridStepY', IndicatorCodecs.optionalDouble, null);

  /// Minor lines between grid lines (0: none), drawn in [minorGridColor]
  /// only while at least 6px apart: minor gridlines, as a plotting library's
  /// minor ticks.
  static const minorDivisions = PropDef<int>('minorDivisions', IntCodec(min: 0), 0);
  /// Null: the theme's outlineVariant at 50 % (`ControlTheme`), so it reads in light and dark.
  static const minorGridColor = PropDef<Color?>('minorGridColor', Codecs.optionalColor, null);

  /// Draws the x axis at y = 0 and the y axis at x = 0 (in [axisColor])
  /// instead of a baseline, with tick labels at grid lines along them;
  /// labels of an axis off the plot stick to the nearest edge: axes that
  /// cross at the origin (a plotting library's spines at zero).
  static const originAxes = PropDef<bool>('originAxes', Codecs.bool, false);
  static const axisWidth = PropDef<double>('axisWidth', Codecs.positive, 1);

  /// Arrowheads at the positive ends of the origin axes.
  static const axisArrows = PropDef<bool>('axisArrows', Codecs.bool, false);

  /// Titles at the positive ends of the origin axes (`x`, `y`).
  static const xAxisTitle = PropDef<String>('xAxisTitle', Codecs.string, '');
  static const yAxisTitle = PropDef<String>('yAxisTitle', Codecs.string, '');
  static const axisTitleStyle = PropDef<TextStyle>('axisTitleStyle', _style, TextStyle.empty);

  /// Behind each axis label, so grid lines don't run through it.
  static const labelBackground = PropDef<Color?>('labelBackground', IndicatorCodecs.optionalColor, null);

  /// Room kept clear of axis labels at each edge (left, top, right, bottom),
  /// for whatever sits over the chart's edges (a legend, buttons).
  static const labelMargin = PropDef<EdgeInsets>('labelMargin', Codecs.insets, EdgeInsets.all(2));

  /// The selection's y (default: the curve at selectedX).
  static const selectionY = PropDef<double?>('selectionY', IndicatorCodecs.optionalDouble, null);

  /// The curve the selection follows: the id of a [series], or empty for
  /// the chart's own points.
  static const selectionSeries = PropDef<String>('selectionSeries', Codecs.string, '');
  static const selectionGuides = PropDef<PlotChartSelectionGuides>(
      'selectionGuides', EnumCodec(PlotChartSelectionGuides.values), PlotChartSelectionGuides.line);

  /// Text in tags where the guides meet the axes (empty: no tag): a
  /// crosshair's axis labels.
  static const selectionXLabel = PropDef<String>('selectionXLabel', Codecs.string, '');
  static const selectionYLabel = PropDef<String>('selectionYLabel', Codecs.string, '');
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const selectionTagColor = PropDef<Color?>('selectionTagColor', Codecs.optionalColor, null);
  static const selectionTagStyle = PropDef<TextStyle>('selectionTagStyle', _style, TextStyle.empty);

  /// A soft disc under the selection dot (0: none).
  static const selectionHaloRadius = PropDef<double>('selectionHaloRadius', Codecs.double, 0);
  /// Null: the theme's onSurface at 18 % (`ControlTheme`), so it reads in light and dark.
  static const selectionHaloColor = PropDef<Color?>('selectionHaloColor', Codecs.optionalColor, null);

  /// Animates numeric data changes; initial and design-canvas values rest.
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds. Zero applies data changes immediately.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 700);

  /// Clips the drawing to the chart's box. Off, a line's stroke at the
  /// edge overhangs it, as a Flutter `CustomPaint` (which doesn't clip)
  /// draws it.
  static const clip = PropDef<bool>('clip', Codecs.bool, true);

  static const spec = WidgetSpec('plotChart', props: [
    clip, selectedX, points, xMin, xMax, yMin, yMax, plotInset, plotPadding, lineColor, lineWidth, fillColor, smooth, gridStepX, //
    gridColor, axisColor, xLabels, gridLabels, labelStyle, labelHeight, ranges, markers, markerRadius,
    markerLabelStyle, referenceX, referenceColor, referenceWidth, referenceDashed, selectable, selectionStep,
    selectionMin, selectionMax, selectionColor, selectionLineColor, selectionLineWidth, selectionDotRadius,
    selectionDotColor, selectionDotStrokeColor, selectionDotStrokeWidth,
    yLines, yAxisWidth, lineEndX, endDotRadius, markerHollow,
    series, gridAnchor, gridStepY, minorDivisions, minorGridColor, originAxes, axisWidth, axisArrows, xAxisTitle,
    yAxisTitle, axisTitleStyle, labelBackground, labelMargin, selectionY, selectionSeries, selectionGuides,
    selectionXLabel, selectionYLabel, selectionTagColor, selectionTagStyle, selectionHaloRadius, selectionHaloColor,
    animate, animationDuration,
  ], doc: 'Plot chart (line/area over an x domain; with series, origin axes and a zero-anchored grid, a '
      'Cartesian graph).');
}

/// A bar chart of [values] with optional labels, grid and a highlighted bar.
abstract final class BarChartProps {
  /// One bar per value; null draws an empty stub.
  static const values = PropDef<List<double?>>('values', NullableDoublesCodec(), []);
  static const labels = PropDef<List<String>>('labels', IndicatorCodecs.strings, []);
  static const highlight = PropDef<int?>('highlight', OptionalIntCodec(), null);

  /// The value of a full bar; 0 uses the largest value.
  static const max = PropDef<double>('max', Codecs.double, 0);
  /// Null: the theme's primary (`ControlTheme`), so it reads in light and dark.
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);

  /// Per-bar colours; missing entries fall back to color.
  static const colors = PropDef<List<Color>>('colors', ListCodec<Color>(Codecs.color), []);
  static const dimmedOpacity = PropDef<double>('dimmedOpacity', Codecs.double, 0.55);
  static const barGap = PropDef<double>('barGap', Codecs.double, 3);
  static const barRadius = PropDef<double>('barRadius', Codecs.double, 1);
  /// Null: the theme's outlineVariant (`ControlTheme`), so it reads in light and dark.
  static const emptyColor = PropDef<Color?>('emptyColor', Codecs.optionalColor, null);
  static const emptyHeight = PropDef<double>('emptyHeight', Codecs.double, 2);
  static const gridLines = PropDef<int>('gridLines', IntCodec(min: 0), 3);
  /// Null: the theme's outlineVariant (`ControlTheme`), so it reads in light and dark.
  static const gridColor = PropDef<Color?>('gridColor', Codecs.optionalColor, null);
  /// The grid lines' labels, bottom up; one more than [gridLines] labels
  /// the baseline first ("0").
  static const gridLabels = PropDef<List<String>>('gridLabels', IndicatorCodecs.strings, []);
  static const gridLabelWidth = PropDef<double>('gridLabelWidth', Codecs.double, 40);
  /// Null: the theme's outline (`ControlTheme`), so it reads in light and dark.
  static const baselineColor = PropDef<Color?>('baselineColor', Codecs.optionalColor, null);
  static const labelFontFamily = PropDef<String>('labelFontFamily', Codecs.string, 'JetBrains Mono');
  static const labelFontSize = PropDef<double>('labelFontSize', Codecs.positive, 10);
  /// Null: the theme's onSurfaceVariant (`ControlTheme`), so it reads in light and dark.
  static const labelColor = PropDef<Color?>('labelColor', Codecs.optionalColor, null);
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const highlightLabelColor = PropDef<Color?>('highlightLabelColor', Codecs.optionalColor, null);
  static const labelGap = PropDef<double>('labelGap', Codecs.double, 6);
  static const animate = PropDef<bool>('animate', Codecs.bool, true);

  /// Milliseconds.
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 700);

  /// The grid labels on the left of the chart instead of its right.
  static const gridLabelsLeft = PropDef<bool>('gridLabelsLeft', Codecs.bool, false);

  /// The widest a bar gets, centred in its column (null: the column).
  static const maxBarWidth = PropDef<double?>('maxBarWidth', Codecs.optionalPositive, null);

  /// Each bar's value above it (whole numbers without decimals).
  static const showValues = PropDef<bool>('showValues', Codecs.bool, false);

  /// Decimals of the values over the bars (null: whole numbers without
  /// decimals, else one), and text after each (`%`).
  static const valueDecimals = PropDef<int?>('valueDecimals', Codecs.optionalInt, null);
  static const valueSuffix = PropDef<String>('valueSuffix', Codecs.string, '');

  /// Letter spacing of the labels under the bars.
  static const labelLetterSpacing = PropDef<double>('labelLetterSpacing', Codecs.double, 0);

  /// The weight of the labels under the bars and of the values (100–900).
  static const labelFontWeight = PropDef<int>('labelFontWeight', IntCodec(min: 100), 400);

  /// Whether the label under the [highlight]ed bar takes
  /// [highlightLabelColor] (its value above always does).
  static const highlightLabels = PropDef<bool>('highlightLabels', Codecs.bool, true);

  /// The grid labels' own color, size and weight (null: the labels').
  static const gridLabelColor = PropDef<Color?>('gridLabelColor', Codecs.color, null);
  static const gridLabelFontSize = PropDef<double?>('gridLabelFontSize', Codecs.optionalPositive, null);
  static const gridLabelFontWeight = PropDef<int?>('gridLabelFontWeight', Codecs.optionalInt, null);

  /// The band under the plot for the labels (null: the labels' line and
  /// [labelGap]); the labels sit [labelGap] below the baseline.
  static const labelAreaHeight = PropDef<double?>('labelAreaHeight', Codecs.optionalPositive, null);

  /// Room above the top grid line (null: the values' line when [showValues]).
  static const plotTopInset = PropDef<double?>('plotTopInset', Codecs.optionalDouble, null);

  /// Pixels kept above a full bar inside the plot, for its value: bars scale
  /// to the plot's height less this while the grid keeps the whole plot.
  static const barHeadroom = PropDef<double>('barHeadroom', Codecs.double, 0);

  /// The values' size (null: the labels') and their gap above the bars.
  static const valueFontSize = PropDef<double?>('valueFontSize', Codecs.optionalPositive, null);
  static const valueGap = PropDef<double>('valueGap', Codecs.double, 2);

  static const spec = WidgetSpec('barChart', fillsWidth: true, props: [
    values, labels, highlight, max, color, colors, dimmedOpacity, barGap, barRadius, emptyColor, emptyHeight, gridLines, //
    gridColor, gridLabels, gridLabelWidth, baselineColor, labelFontFamily, labelFontSize, labelColor,
    highlightLabelColor, labelGap, animate, animationDuration, gridLabelsLeft, maxBarWidth, showValues, labelFontWeight, valueDecimals, valueSuffix, labelLetterSpacing, labelAreaHeight, plotTopInset, barHeadroom, valueFontSize, valueGap,
    highlightLabels, gridLabelColor, gridLabelFontSize, gridLabelFontWeight,
  ], doc: 'Bar chart.');
}

/// Where a line chart's x labels sit about their tick.
/// [edgeClamped]: centred, the first starting at the tick and the last
/// ending there (so both stay over the plot). [start]: starting at the tick.
/// [center]: centred on it. [end]: ending at it.
enum LineChartXLabelAnchor { edgeClamped, start, center, end }

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
  /// Null: the theme's primary (`ControlTheme`), so it reads in light and dark.
  static const lineColor = PropDef<Color?>('lineColor', Codecs.optionalColor, null);
  static const lineWidth = PropDef<double>('lineWidth', Codecs.positive, 2);
  /// Null: the theme's primary at 10 % (`ControlTheme`), so it reads in light and dark.
  static const areaTopColor = PropDef<Color?>('areaTopColor', Codecs.optionalColor, null);
  static const areaBottomColor = PropDef<Color>('areaBottomColor', Codecs.color, Color.transparent);
  /// Null: the theme's outlineVariant (`ControlTheme`), so it reads in light and dark.
  static const gridColor = PropDef<Color?>('gridColor', Codecs.optionalColor, null);
  /// Null: the theme's outline (`ControlTheme`), so it reads in light and dark.
  static const zeroLineColor = PropDef<Color?>('zeroLineColor', Codecs.optionalColor, null);
  /// Null: the theme's outline (`ControlTheme`), so it reads in light and dark.
  static const axisColor = PropDef<Color?>('axisColor', Codecs.optionalColor, null);
  /// Null: the theme's surface (`ControlTheme`), so it reads in light and dark.
  static const markerHollowColor = PropDef<Color?>('markerHollowColor', Codecs.optionalColor, null);
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const tagBackground = PropDef<Color?>('tagBackground', Codecs.optionalColor, null);
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const cursorColor = PropDef<Color?>('cursorColor', Codecs.optionalColor, null);
  /// Null: the theme's surface (`ControlTheme`), so it reads in light and dark.
  static const cursorRingFill = PropDef<Color?>('cursorRingFill', Codecs.optionalColor, null);
  /// Null: the theme's onSurface (an inverted surface) (`ControlTheme`), so it reads in light and dark.
  static const tooltipBackground = PropDef<Color?>('tooltipBackground', Codecs.optionalColor, null);
  static const tooltipShadowColor = PropDef<Color>('tooltipShadowColor', Codecs.color, Color.transparent);
  static const yAxisTitle = PropDef<String>('yAxisTitle', Codecs.string, '');
  static const axisLabelStyle = PropDef<TextStyle>('axisLabelStyle', _style, TextStyle.empty);
  static const axisTitleStyle = PropDef<TextStyle>('axisTitleStyle', _style, TextStyle.empty);
  static const markerLabelStyle = PropDef<TextStyle>('markerLabelStyle', _style, TextStyle.empty);
  static const tagTextStyle = PropDef<TextStyle>('tagTextStyle', _style, TextStyle.empty);
  /// The tooltip at [selectedX]: its first line (the x, small) and the y
  /// value (bigger, bold), each merged over its default.
  static const tooltipLabelStyle = PropDef<TextStyle>('tooltipLabelStyle', _style, TextStyle.empty);
  static const tooltipValueStyle = PropDef<TextStyle>('tooltipValueStyle', _style, TextStyle.empty);

  /// The tooltip's first line: this row field, else the x ([tooltipXFormat]
  /// for dates).
  static const tooltipLabelField = PropDef<String>('tooltipLabelField', Codecs.string, '');

  /// The point (nearest x) with the cursor and tooltip; null for none.
  static const selectedX = PropDef<double?>('selectedX', IndicatorCodecs.optionalDouble, null);

  /// Hovering or dragging selects the nearest point in a running app.
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

  /// Dashed horizontal lines: `[{"y", "color"?, "width"?, "dash"?: [on, off],
  /// "label"?, "labelColor"?, "labelBelow"?, "labelAlign"?: "end" | "start"}]`;
  /// a label sits at the line's end (or start, with labelAlign "start"),
  /// above the line unless labelBelow, in [axisLabelStyle] (bold, the line's
  /// color unless labelColor).
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

  /// Draws in (rising from zero) when it first shows (a running app).
  static const animateIn = PropDef<bool>('animateIn', Codecs.bool, false);

  /// Clips the chart to its box; off, labels (a reference line's above the
  /// plot) and out-of-domain values can draw beyond it.
  static const clip = PropDef<bool>('clip', Codecs.bool, true);

  /// Where each x label sits about its tick ([xLabelOffset] then moves it).
  static const xLabelAnchor = PropDef<LineChartXLabelAnchor>(
      'xLabelAnchor', EnumCodec(LineChartXLabelAnchor.values), LineChartXLabelAnchor.edgeClamped);

  /// Moves every x label right by this much (negative: left).
  static const xLabelOffset = PropDef<double>('xLabelOffset', Codecs.double, 0);

  static const spec = WidgetSpec('lineChart', fillsWidth: true, props: [
    data, xField, yField, xMin, xMax, yMin, yMax, plotPadding, smooth, lineColor, lineWidth, areaTopColor, //
    areaBottomColor, gridColor, zeroLineColor, axisColor, markerHollowColor, tagBackground, cursorColor,
    cursorRingFill, tooltipBackground, tooltipShadowColor, yAxisTitle, axisLabelStyle, axisTitleStyle,
    markerLabelStyle, tagTextStyle, tooltipLabelStyle, tooltipValueStyle, tooltipLabelField, selectedX, scrubEnabled, scrubStep, tooltipXFormat,
    tooltipYScale, tooltipYDecimals, tooltipYSuffix, tooltipTrend, semanticLabel, bands, yTicks, areaBands,
    referenceLines, xTicks, markers, verticalLines, animateIn, clip, xLabelAnchor, xLabelOffset,
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
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const backgroundColor = PropDef<Color?>('backgroundColor', IndicatorCodecs.optionalColor, null);
  static const errorCorrection = PropDef<BarcodeErrorCorrection>(
      'errorCorrection', EnumCodec(BarcodeErrorCorrection.values), BarcodeErrorCorrection.medium);

  /// 1D codes: the text under the bars.
  static const drawText = PropDef<bool>('drawText', Codecs.bool, true);

  /// Pixels each dark bar and module reaches past its right and bottom edge,
  /// so neighbours overlap: no hairline seams where anti-aliased edges
  /// meet, and a small ink gain (as `canvas.drawRect` codes widen bars to
  /// hide seams). 0 draws the exact geometry.
  static const overlap = PropDef<double>('overlap', Codecs.positive, 0);

  static const spec = WidgetSpec('barcode',
      props: [data, symbology, color, backgroundColor, errorCorrection, drawText, overlap], doc: 'Barcode / QR code.');
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
