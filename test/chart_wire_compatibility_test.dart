import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> chart(
  Map<String, dynamic> properties, {
  String type = 'chart',
}) => {
  'id': 'c',
  'name': 'Chart',
  'type': type,
  'basicBoxLocal': [0, 0, 320, 140],
  'properties': properties,
};

void main() {
  final converter = NodeJsonConverter();

  test(
    'new default charts use distinct type IDs even with empty properties',
    () {
      final series = ChartNode.empty().toJson();
      final plot = PlotChartNode.empty().toJson();
      expect(series['type'], 'chartSeries');
      expect(plot['type'], 'chartPlot');
      expect(converter.fromJson(series), isA<ChartNode>());
      expect(converter.fromJson(plot), isA<PlotChartNode>());
      expect(NodeJsonConverter.isNodeRegistered('chartSeries'), isTrue);
      expect(NodeJsonConverter.isNodeRegistered('chartPlot'), isTrue);
    },
  );

  test('legacy exclusive keys dispatch without changing data', () {
    final series = converter.fromJson(
      chart({
        'series': [
          {'field': 'value'},
        ],
      }),
    );
    expect(series, isA<ChartNode>());
    expect((series!.toJson())['type'], 'chartSeries');
    final plot = converter.fromJson(
      chart({
        'points': [1, 2, 3],
      }),
    );
    expect(plot, isA<PlotChartNode>());
    expect((plot!.toJson())['type'], 'chartPlot');
  });

  test('unmarked shared-only and mixed charts retain original whole map', () {
    for (final props in [
      <String, dynamic>{},
      <String, dynamic>{'gridColor': '#334455'},
      <String, dynamic>{
        'series': [],
        'points': [1, 2],
      },
    ]) {
      final input = <String, dynamic>{
        'safe': ChartNode.empty().toJson(),
        'unknown': chart(props),
      };
      try {
        NodesMapConverter.deserialize(input);
        fail('undecidable chart must not return a partial map');
      } on UnresolvedDocumentSchema catch (error) {
        expect(error.nodeKey, 'unknown');
        expect(
          error.reason,
          props.containsKey('points')
              ? 'conflicting-chart-schema'
              : 'ambiguous-chart-schema',
        );
        expect(error.raw, input);
        (input['unknown'] as Map)['name'] = 'Changed';
        expect((error.raw['unknown'] as Map)['name'], 'Chart');
      }
    }
  });

  test('nested canvases retain siblings on ambiguous chart', () {
    final input = <String, dynamic>{
      'a': <String, dynamic>{'safe': ChartNode.empty().toJson()},
      'b': <String, dynamic>{'unknown': chart({})},
    };
    try {
      CanvasesMapConverter.deserialize(input);
      fail('must fail entire nested document');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'ambiguous-chart-schema');
      expect(error.raw, input);
      ((input['b'] as Map)['unknown'] as Map)['id'] = 'changed';
      expect(((error.raw['b'] as Map)['unknown'] as Map)['id'], 'c');
    }
  });
}
