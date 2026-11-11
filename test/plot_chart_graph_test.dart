// plotChart as a Cartesian graph: series with gaps, a zero-anchored grid
// with minor lines, origin axes, marker shapes and a guided selection.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
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

  test('the graph props decode with their types', () {
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

  test('round-trips sparsely, defaults stay omitted', () {
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

  test('bad values fall back without throwing', () {
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
}
