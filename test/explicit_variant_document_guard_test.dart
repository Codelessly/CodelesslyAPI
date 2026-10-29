import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  for (final (node, reason) in [
    (
      <String, dynamic>{
        'id': 'g',
        'name': 'Gauge',
        'type': 'gaugeRadial',
        'basicBoxLocal': [0, 0, 220, 185],
        'properties': <String, dynamic>{
          'shape': 'bar',
          'future': <String, dynamic>{
            'value': [1, 2],
          },
        },
      },
      'conflicting-gauge-schema',
    ),
    (
      <String, dynamic>{
        'id': 'c',
        'name': 'Chart',
        'type': 'chartSeries',
        'basicBoxLocal': [0, 0, 320, 180],
        'properties': <String, dynamic>{
          'points': [1, 2],
          'future': <String, dynamic>{
            'value': [1, 2],
          },
        },
      },
      'conflicting-chart-schema',
    ),
  ]) {
    test('${node['type']} foreign keys fail entire node map', () {
      final input = <String, dynamic>{
        'before': ChartNode.empty().toJson(),
        'conflict': node,
        'after': GaugeNode.empty().toJson(),
      };
      try {
        NodesMapConverter.deserialize(input);
        fail('must not return a partial document');
      } on UnresolvedDocumentSchema catch (error) {
        expect(error.reason, reason);
        expect(error.nodeKey, 'conflict');
        expect(error.raw, input);
        expect(error.raw.keys, ['before', 'conflict', 'after']);
        ((node['properties'] as Map)['future'] as Map)['value'] = [9];
        expect(
          (((error.raw['conflict'] as Map)['properties'] as Map)['future']
              as Map)['value'],
          [1, 2],
        );
      }
    });

    test('${node['type']} foreign keys fail all nested canvases', () {
      final input = <String, dynamic>{
        'before': <String, dynamic>{'safe': ChartNode.empty().toJson()},
        'affected': <String, dynamic>{
          'safe': GaugeNode.empty().toJson(),
          'conflict': node,
        },
        'after': <String, dynamic>{'safe': ChartNode.empty().toJson()},
      };
      try {
        CanvasesMapConverter.deserialize(input);
        fail('must not return a partial canvas tree');
      } on UnresolvedDocumentSchema catch (error) {
        expect(error.reason, reason);
        expect(error.nodeKey, 'conflict');
        expect(error.raw, input);
        expect(error.raw.keys, ['before', 'affected', 'after']);
        (input['after'] as Map)['later'] = 'mutated';
        expect((error.raw['after'] as Map).containsKey('later'), isFalse);
      }
    });
  }
}
