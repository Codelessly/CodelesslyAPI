import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

// plotChart as a Cartesian graph: series with gaps, a zero-anchored grid
// with minor lines, origin axes, marker shapes and a guided selection.

void main() {
  test('a chart\'s nested series and labels round-trip and write only what is set', () {
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

  test('a bar chart\'s missing values stay missing through JSON', () {
    final n = Node.fromJson({
      'type': 'barChart',
      'props': {'values': [1, null, 2.5], 'highlight': 1},
    })!;
    expect(n.prop(BarChartProps.values), [1, null, 2.5]);
    expect(n.prop(BarChartProps.highlight), 1);
    expect((n.toJson()['props'] as Map)['values'], [1, null, 2.5]);
  });

  group('a plot chart', () {
    final json = {
      'type': 'plotChart',
      'props': {
        'xMin': -10.5,
        'xMax': 9.5,
        'yMin': -8,
        'yMax': 8,
        'series': [
          {'id': 'l1', 'points': [1, null, 2.5], 'color': '#FFD1452F', 'width': 2.5},
          {'id': 'l2', 'points': [0, 1]},
        ],
        'gridAnchor': 'zero',
        'gridStepY': 2,
        'minorDivisions': 5,
        'minorGridColor': '#FFD9E5D2',
        'originAxes': true,
        'axisArrows': true,
        'axisWidth': 1.5,
        'xAxisTitle': 'x',
        'yAxisTitle': 'y',
        'labelBackground': '#D9F3F5EC',
        'labelMargin': [2, 22, 24, 2],
        'markers': [
          {'x': 1, 'y': 0, 'shape': 'ring', 'color': '#FFD1452F', 'fillColor': '#FFFBFCF7', 'radius': 5},
          {'x': 2, 'y': 1, 'shape': 'diamond', 'strokeColor': '#FF22302A', 'strokeWidth': 1.6, 'radius': 7},
        ],
        'selectedX': 2.03,
        'selectionY': 1.8197,
        'selectionSeries': 'l1',
        'selectionGuides': 'axes',
        'selectionXLabel': '2.0300',
        'selectionYLabel': '1.8197',
        'selectionHaloRadius': 9,
      },
    };

    test('decodes its series, axes and markers', () {
      final node = Node.fromJson(json, id: 'g')!;
      final series = node.prop(PlotChartProps.series);
      expect(series, hasLength(2));
      expect(series.first.points, [1.0, null, 2.5]);
      expect(series.first.id, 'l1');
      expect(series.first.width, 2.5);
      expect(series.last.color, const Color(0xFF1F6F78));
      expect(node.prop(PlotChartProps.gridAnchor), PlotChartGridAnchor.zero);
      expect(node.prop(PlotChartProps.gridStepY), 2);
      expect(node.prop(PlotChartProps.minorDivisions), 5);
      expect(node.prop(PlotChartProps.originAxes), isTrue);
      expect(node.prop(PlotChartProps.labelMargin), const EdgeInsets.fromLTRB(2, 22, 24, 2));
      final markers = node.prop(PlotChartProps.markers);
      expect(markers.first.shape, PlotChartMarkerShape.ring);
      expect(markers.first.radius, 5);
      expect(markers.last.shape, PlotChartMarkerShape.diamond);
      expect(markers.last.strokeWidth, 1.6);
      expect(node.prop(PlotChartProps.selectionGuides), PlotChartSelectionGuides.axes);
      expect(node.prop(PlotChartProps.selectionSeries), 'l1');
      expect(node.prop(PlotChartProps.selectionY), 1.8197);
    });

    test('round-trips and writes nothing at the defaults', () {
      final node = Node.fromJson(json, id: 'g')!;
      final out = node.toJson()['props'] as Map;
      expect(Node.fromJson(node.toJson(), id: 'g'), node);
      expect((out['series'] as List).last, {'id': 'l2', 'points': [0, 1]});
      final plain = Node.fromJson({'type': 'plotChart'}, id: 'p')!;
      expect(plain.prop(PlotChartProps.gridAnchor), PlotChartGridAnchor.start);
      expect(plain.prop(PlotChartProps.selectionGuides), PlotChartSelectionGuides.line);
      expect(plain.prop(PlotChartProps.originAxes), isFalse);
      expect(plain.toJson()['props'], anyOf(isNull, isEmpty));
    });

    test('with bad values falls back without failing', () {
      final node = Node.fromJson({
        'type': 'plotChart',
        'props': {
          'series': [
            {'points': ['a', null, 3]},
            'junk',
          ],
          'gridAnchor': 'sideways',
          'markers': [
            {'shape': 'star'},
          ],
        },
      }, id: 'b')!;
      expect(node.prop(PlotChartProps.series).single.points, [null, null, 3.0]);
      expect(node.prop(PlotChartProps.gridAnchor), PlotChartGridAnchor.start);
      expect(node.prop(PlotChartProps.markers).single.shape, PlotChartMarkerShape.dot);
    });
  });

  group('chart animation', () {
    for (final (type, _, duration) in [
      ('chart', ChartProps.animate, ChartProps.animationDuration),
      ('lineChart', LineChartProps.animate, LineChartProps.animationDuration),
      ('plotChart', PlotChartProps.animate, PlotChartProps.animationDuration),
    ]) {
      test(
        'a $type with a zero or negative animation duration still decodes',
        () {
          final zero = Node.fromJson({
            'type': type,
            'props': {'animationDuration': 0},
          })!;
          final negative = Node.fromJson({
            'type': type,
            'props': {'animationDuration': -10},
          })!;
          expect(zero.prop(duration), 0);
          expect(negative.prop(duration), 0);
          expect(Node.fromJson(zero.toJson()), zero);
        },
      );
    }
  });
}
