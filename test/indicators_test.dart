import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('every indicators type is declared', () {
    for (final type in const [
      'circularProgressIndicator', 'activityIndicator', 'progressBar', 'radialGauge', 'gaugeMeter', 'chart', //
      'plotChart', 'barChart', 'lineChart', 'barcode',
    ]) {
      expect(Widgets.of(type), isNotNull, reason: type);
    }
  });

  test('Flutter defaults; nullable props stay null', () {
    final n = Node.fromJson({'type': 'circularProgressIndicator'})!;
    expect(n.prop(CircularProgressIndicatorProps.value), isNull);
    expect(n.prop(CircularProgressIndicatorProps.strokeWidth), 4);
    expect(n.prop(CircularProgressIndicatorProps.strokeCap), isNull);
    expect(n.prop(CircularProgressIndicatorProps.color), isNull);
    expect(Node.fromJson({'type': 'activityIndicator'})!.prop(ActivityIndicatorProps.radius), 10);
  });

  test('nested records decode, compare and encode sparsely', () {
    final json = {
      'type': 'chart',
      'props': {
        'chartType': 'line',
        'series': [
          {'field': 'a', 'kind': 'area', 'color': '#FFFFD400', 'strokeWidth': 2, 'fillTo': 'b'},
          {'field': 'b', 'dashed': true, 'unknown': 1},
          'not a series',
        ],
        'referenceLines': [{'value': 15, 'dashed': false}],
        'data': [{'label': 'Mon', 'a': 1}],
        'minY': 'nope',
      },
    };
    final n = Node.fromJson(json)!;
    final series = n.prop(ChartProps.series);
    expect(series, hasLength(2));
    expect(series.first.kind, ChartSeriesKind.area);
    expect(series.first.fillTo, 'b');
    expect(series.first.strokeWidth, 2);
    expect(series.last.color, const Color(0xFF2ED17A));
    expect(n.prop(ChartProps.referenceLines).single.dashed, isFalse);
    expect(n.prop(ChartProps.minY), isNull);
    final out = n.toJson()['props'] as Map;
    expect(out['series'], [
      {'field': 'a', 'kind': 'area', 'color': '#FFFFD400', 'fillTo': 'b'},
      {'field': 'b', 'dashed': true, 'unknown': 1},
    ]);
    expect(out.containsKey('minY'), isFalse);
    expect(Node.fromJson(n.toJson()), n);
  });

  test('radial gauge round caps default to false and round-trip sparsely', () {
    final defaults = Node.fromJson({'type': 'radialGauge'})!;
    expect(defaults.prop(RadialGaugeProps.roundCaps), isFalse);
    expect(
      (defaults.toJson()['props'] as Map?)?.containsKey('roundCaps') ?? false,
      isFalse,
    );
    final rounded = Node.fromJson({
      'type': 'radialGauge',
      'props': {'roundCaps': true},
    })!;
    expect(rounded.prop(RadialGaugeProps.roundCaps), isTrue);
    expect((rounded.toJson()['props'] as Map)['roundCaps'], isTrue);
    expect(Node.fromJson(rounded.toJson()), rounded);
    final flat = rounded.withProp(RadialGaugeProps.roundCaps, false);
    expect(
      (flat.toJson()['props'] as Map?)?.containsKey('roundCaps') ?? false,
      isFalse,
    );
  });

  test('bar values keep their gaps', () {
    final n = Node.fromJson({
      'type': 'barChart',
      'props': {'values': [1, null, 2.5], 'highlight': 1},
    })!;
    expect(n.prop(BarChartProps.values), [1, null, 2.5]);
    expect(n.prop(BarChartProps.highlight), 1);
    expect((n.toJson()['props'] as Map)['values'], [1, null, 2.5]);
  });

  test('progress bar, gauges and barcode props', () {
    final bar = Node.fromJson({
      'type': 'progressBar',
      'props': {'value': 30, 'direction': 'vertical', 'borderRadius': 4, 'bands': [{'start': 0, 'end': 0.5, 'color': '#FF00FF00'}]},
    })!;
    expect(bar.prop(ProgressBarProps.direction), Axis.vertical);
    expect(bar.prop(ProgressBarProps.borderRadius), const BorderRadius.circular(4));
    expect(bar.prop(ProgressBarProps.bands).single, ProgressBand(end: 0.5, color: const Color(0xFF00FF00)));
    expect(bar.prop(ProgressBarProps.max), 100);
    expect(bar.prop(ProgressBarProps.exactFill), isFalse);
    expect(bar.prop(ProgressBarProps.clipFill), isFalse);
    final clipped = Node.fromJson({'type': 'progressBar', 'props': {'exactFill': true, 'clipFill': true}})!;
    expect(clipped.prop(ProgressBarProps.exactFill), isTrue);
    expect(clipped.prop(ProgressBarProps.clipFill), isTrue);

    final radial = Node.fromJson({'type': 'radialGauge', 'props': {'zones': [{'from': 0, 'to': 60}]}})!;
    expect(radial.prop(RadialGaugeProps.zones).single.to, 60);
    expect(radial.prop(RadialGaugeProps.labels), [0, 60, 85, 100]);
    final meter = Node.fromJson({'type': 'gaugeMeter', 'props': {'shape': 'bar', 'limit': 80}})!;
    expect(meter.prop(GaugeMeterProps.shape), GaugeShape.bar);
    expect(meter.prop(GaugeMeterProps.limit), 80);

    final code = Node.fromJson({'type': 'barcode', 'props': {'symbology': 'pdf417', 'data': 'x'}})!;
    expect(code.prop(BarcodeProps.symbology).is2D, isTrue);
    expect(code.prop(BarcodeProps.symbology).hasSquareModules, isFalse);
    expect(code.prop(BarcodeProps.overlap), 0);
    final overlapped = Node.fromJson({'type': 'barcode', 'props': {'overlap': 0.4}})!;
    expect(overlapped.prop(BarcodeProps.overlap), 0.4);
    expect(Node.fromJson({'type': 'barcode', 'props': {'overlap': -2}})!.prop(BarcodeProps.overlap), 0);
  });

  test('chart text styles and plot records', () {
    final n = Node.fromJson({
      'type': 'plotChart',
      'props': {
        'labelStyle': {'fontSize': 9, 'fontWeight': 500},
        'markers': [{'x': 3, 'label': 'Hi', 'position': 'below'}],
        'xLabels': [{'x': 6, 'label': '6a'}],
        'ranges': [{'from': 0, 'to': 5}],
      },
    })!;
    expect(n.prop(PlotChartProps.labelStyle).fontSize, 9);
    expect(n.prop(PlotChartProps.markers).single.position, PlotChartMarkerPosition.below);
    expect(n.prop(PlotChartProps.markers).single.y, isNull);
    expect(n.prop(PlotChartProps.xLabels).single.label, '6a');
    expect(n.prop(PlotChartProps.ranges).single.color, const Color(0x19000000));
    expect(Node.fromJson(n.toJson()), n);
  });

  test('chart and line chart tooltip styles, line chart selectedX', () {
    final bar = Node.fromJson({
      'type': 'chart',
      'props': {
        'tooltipTitleStyle': {'fontSize': 11},
        'tooltipLabelStyle': {'fontFamily': 'Inter'},
        'tooltipValueStyle': {'fontSize': 15, 'fontWeight': 800},
      },
    })!;
    expect(bar.prop(ChartProps.tooltipTitleStyle).fontSize, 11);
    expect(bar.prop(ChartProps.tooltipLabelStyle).fontFamily, 'Inter');
    expect(bar.prop(ChartProps.tooltipValueStyle).fontWeight, 800);
    expect(Node.fromJson({'type': 'chart'})!.prop(ChartProps.tooltipValueStyle).isEmpty, isTrue);
    expect(Node.fromJson(bar.toJson()), bar);

    final line = Node.fromJson({
      'type': 'lineChart',
      'props': {'selectedX': '42', 'tooltipLabelField': 'time', 'scrubEnabled': true},
    })!;
    expect(line.prop(LineChartProps.selectedX), 42);
    expect(line.prop(LineChartProps.tooltipLabelField), 'time');
    expect(Node.fromJson({'type': 'lineChart'})!.prop(LineChartProps.selectedX), isNull);
    expect(Node.fromJson(line.toJson()), line);
  });

  test('text countUp props', () {
    final plain = Node.fromJson({'type': 'text'})!;
    expect(plain.prop(TextProps.countUp), isFalse);
    expect(plain.prop(TextProps.countUpDuration), 500);
    expect(plain.prop(TextProps.countUpCurve), AnimationCurve.linear);
    expect(plain.prop(TextProps.countUpOnShow), isTrue);
    final n = Node.fromJson({
      'type': 'text',
      'props': {'countUp': true, 'countUpDuration': 800, 'countUpCurve': 'easeOutCubic', 'countUpOnShow': false},
    })!;
    expect(n.prop(TextProps.countUp), isTrue);
    expect(n.prop(TextProps.countUpDuration), 800);
    expect(n.prop(TextProps.countUpCurve), AnimationCurve.easeOutCubic);
    expect(n.prop(TextProps.countUpOnShow), isFalse);
    expect(n.toJson()['props'], containsPair('countUpCurve', 'easeOutCubic'));
    expect(Node.fromJson(n.toJson()), n);
  });
}
