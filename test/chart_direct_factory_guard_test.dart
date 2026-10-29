import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> chartWire({
  required String type,
  Map<String, dynamic>? properties,
  Map<String, dynamic>? variables,
}) => {
  'id': 'c',
  'name': 'Chart',
  'type': type,
  'basicBoxLocal': [0, 0, 320, 180],
  'properties': ?properties,
  'variables': ?variables,
};

void expectUnresolved(
  Map<String, dynamic> input,
  Object? Function() decode,
  String reason,
) {
  try {
    decode();
    fail('Expected $reason for $input');
  } on UnresolvedNodeSchema catch (error) {
    expect(error.reason, reason);
    expect(error.raw, input);
    // The exception must retain the original wire payload, not a shallow copy
    // or the decoder's normalized type/properties.
    final originalProperties = input['properties'];
    if (originalProperties is Map && originalProperties['future'] is Map) {
      final previous = (originalProperties['future'] as Map)['value'];
      (originalProperties['future'] as Map)['value'] = 'changed';
      expect(
        ((error.raw['properties'] as Map)['future'] as Map)['value'],
        previous,
      );
    }
  }
}

void main() {
  group('direct chart factories', () {
    test('accept matching exclusive legacy signatures only', () {
      final series = ChartNode.fromJson(
        chartWire(type: 'chart', properties: {'series': []}),
      );
      expect(series.type, 'chartSeries');
      expect(series.toJson()['type'], 'chartSeries');
      expect(series.properties.series, isEmpty);

      final plot = PlotChartNode.fromJson(
        chartWire(
          type: 'chart',
          properties: {
            'points': [1, 2],
          },
        ),
      );
      expect(plot.type, 'chartPlot');
      expect(plot.toJson()['type'], 'chartPlot');
      expect(plot.properties.points, [1, 2]);

      expectUnresolved(
        chartWire(
          type: 'chart',
          properties: {
            'points': [1],
          },
        ),
        () => ChartNode.fromJson(
          chartWire(
            type: 'chart',
            properties: {
              'points': [1],
            },
          ),
        ),
        'conflicting-chart-schema',
      );
      expectUnresolved(
        chartWire(type: 'chart', properties: {'series': []}),
        () => PlotChartNode.fromJson(
          chartWire(type: 'chart', properties: {'series': []}),
        ),
        'conflicting-chart-schema',
      );
    });

    test('refuses unmarked and mixed legacy wires with original raw', () {
      for (final input in [
        chartWire(type: 'chart'),
        chartWire(
          type: 'chart',
          properties: {
            'future': {'value': 'original'},
          },
        ),
      ]) {
        expectUnresolved(
          input,
          () => ChartNode.fromJson(input),
          'ambiguous-chart-schema',
        );
        expectUnresolved(
          input,
          () => PlotChartNode.fromJson(input),
          'ambiguous-chart-schema',
        );
      }
      final mixed = chartWire(
        type: 'chart',
        properties: {
          'series': [],
          'points': [1],
          'future': {'value': 'original'},
        },
      );
      expectUnresolved(
        mixed,
        () => ChartNode.fromJson(mixed),
        'conflicting-chart-schema',
      );
      expectUnresolved(
        mixed,
        () => PlotChartNode.fromJson(mixed),
        'conflicting-chart-schema',
      );
    });

    test('new types refuse foreign exclusive keys at every wire location', () {
      final cases = [
        chartWire(
          type: 'chartSeries',
          properties: {
            'points': [1],
          },
        ),
        chartWire(type: 'chartSeries', variables: {'selectedX': r'${x}'}),
        {...chartWire(type: 'chartSeries'), 'selectedX': 2},
        chartWire(type: 'chartPlot', properties: {'series': []}),
        chartWire(type: 'chartPlot', variables: {'data': r'${data}'}),
        {...chartWire(type: 'chartPlot'), 'selectedIndex': 1},
      ];
      for (final input in cases) {
        expectUnresolved(
          input,
          () => input['type'] == 'chartSeries'
              ? ChartNode.fromJson(input)
              : PlotChartNode.fromJson(input),
          'conflicting-chart-schema',
        );
      }
    });

    test('preserves valid new-type defaults and tolerates future extras', () {
      final series = ChartNode.fromJson(chartWire(type: 'chartSeries'));
      expect(series.properties.series, kDefaultChartSeries);
      expect(series.selectedIndex, -1);
      final plot = PlotChartNode.fromJson(
        chartWire(
          type: 'chartPlot',
          properties: {
            'points': [1, 2],
          },
        ),
      );
      expect(plot.properties.points, [1, 2]);

      final futureSeries = chartWire(
        type: 'chartSeries',
        properties: {
          'future': {'value': 'original'},
        },
        variables: {'futureBinding': r'${future}'},
      );
      final futurePlot = chartWire(
        type: 'chartPlot',
        properties: {
          'future': {'value': 'original'},
        },
        variables: {'futureBinding': r'${future}'},
      );
      expect(ChartNode.fromJson(futureSeries), isA<ChartNode>());
      expect(PlotChartNode.fromJson(futurePlot), isA<PlotChartNode>());
      expect((futureSeries['properties'] as Map)['future'], {
        'value': 'original',
      });
      expect((futurePlot['properties'] as Map)['future'], {
        'value': 'original',
      });
      expect(
        NodeJsonConverter().fromJson(ChartNode.empty().toJson()),
        isA<ChartNode>(),
      );
      expect(
        NodeJsonConverter().fromJson(PlotChartNode.empty().toJson()),
        isA<PlotChartNode>(),
      );
    });
  });
}
