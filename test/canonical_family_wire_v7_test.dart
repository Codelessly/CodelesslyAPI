import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final converter = NodeJsonConverter();
  final variants = <(BaseNode, String, String, String)>[
    (ChartNode.empty(), 'chart', 'chartKind', 'series'),
    (PlotChartNode.empty(), 'chart', 'chartKind', 'plot'),
    (GaugeNode.empty(), 'gauge', 'gaugeKind', 'radial'),
    (GaugeMeterNode.empty(), 'gauge', 'gaugeKind', 'meter'),
    (SignatureNode.empty(), 'signature', 'signatureKind', 'strokes'),
    (SignatureNormalizedNode.empty(), 'signature', 'signatureKind', 'normalized'),
  ];

  test('all family variants use one canonical type and explicit kind', () {
    for (final (node, type, key, kind) in variants) {
      final json = node.toJson();
      expect(json['type'], type);
      expect(json[key], kind);
      final decoded = converter.fromJson(json);
      expect(decoded.runtimeType, node.runtimeType);
      expect(decoded!.toJson()[key], kind);
    }
  });

  test('missing and unknown discriminator fail before shape or defaults', () {
    for (final (node, type, key, kind) in variants) {
      final json = node.toJson();
      expect(
        () => converter.fromJson({...json}..remove(key)),
        throwsA(isA<UnresolvedNodeSchema>().having(
          (error) => error.reason, 'reason', 'missing-$key',
        )),
      );
      expect(
        () => converter.fromJson({...json, key: 'future-kind'}),
        throwsA(isA<UnresolvedNodeSchema>().having(
          (error) => error.reason, 'reason', 'unknown-$key',
        )),
      );
      final opposite = variants.firstWhere(
        (candidate) => candidate.$2 == type && candidate.$4 != kind,
      ).$4;
      final wrong = {...json, key: opposite};
      expect(
        () => switch (node) {
          ChartNode() => ChartNode.fromJson(wrong),
          PlotChartNode() => PlotChartNode.fromJson(wrong),
          GaugeNode() => GaugeNode.fromJson(wrong),
          GaugeMeterNode() => GaugeMeterNode.fromJson(wrong),
          SignatureNode() => SignatureNode.fromJson(wrong),
          SignatureNormalizedNode() => SignatureNormalizedNode.fromJson(wrong),
          _ => throw StateError('Unexpected family node'),
        },
        throwsA(isA<UnresolvedNodeSchema>().having(
          (error) => error.reason, 'reason', 'conflicting-$type-kind',
        )),
      );
    }
  });

  test('legacy alternate type strings are not registered', () {
    for (final old in [
      'chartSeries', 'chartPlot', 'gaugeRadial', 'gaugeMeter',
      'signatureNormalized',
    ]) {
      expect(NodeJsonConverter.isNodeRegistered(old), isFalse);
      expect(() => converter.fromJson({'type': old}), throwsUnsupportedError);
    }
  });

  test('a malformed family node leaves the entire document unchanged', () {
    final safe = ChartNode.empty().toJson();
    final bad = {...GaugeNode.empty().toJson()}..remove('gaugeKind');
    final source = <String, dynamic>{'safe': safe, 'bad': bad};
    try {
      NodesMapConverter.deserialize(source);
      fail('missing gaugeKind must abort the complete document');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'missing-gaugeKind');
      expect(error.nodeKey, 'bad');
      expect(error.raw, source);
      (source['bad'] as Map)['name'] = 'changed';
      expect((error.raw['bad'] as Map)['name'], isNot('changed'));
    }
  });
}
