import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> legacyGauge({
  Map<String, dynamic> properties = const {},
}) => {
  'id': 'g',
  'name': 'Gauge',
  'type': 'gauge',
  'basicBoxLocal': [0, 0, 220, 185],
  'properties': properties,
};

void main() {
  final converter = NodeJsonConverter();

  test('new radial and meter default writes have permanent distinct types', () {
    final radial = GaugeNode.empty().toJson();
    final meter = GaugeMeterNode.empty().toJson();
    expect(radial['type'], 'gaugeRadial');
    expect(meter['type'], 'gaugeMeter');
    expect(converter.fromJson(radial), isA<GaugeNode>());
    expect(converter.fromJson(meter), isA<GaugeMeterNode>());
    expect(
      (converter.fromJson(radial)! as GaugeNode).properties,
      GaugeProperties(),
    );
    expect(
      (converter.fromJson(meter)! as GaugeMeterNode).properties,
      GaugeMeterProperties(),
    );
  });

  test(
    'exclusive legacy raw keys classify without changing coordinate defaults',
    () {
      final radial = legacyGauge(properties: {'showNeedle': false});
      final parsedRadial = converter.fromJson(radial)! as GaugeNode;
      expect(parsedRadial.toJson()['type'], 'gaugeRadial');
      expect(parsedRadial.properties.startAngle, 150);
      final meter = legacyGauge(properties: {'shape': 'bar'});
      final parsedMeter = converter.fromJson(meter)! as GaugeMeterNode;
      expect(parsedMeter.toJson()['type'], 'gaugeMeter');
      expect(parsedMeter.properties.startAngle, 135);
    },
  );

  test('empty and shared-only old gauges are unresolved with original raw', () {
    for (final properties in [
      <String, dynamic>{},
      {'startAngle': 135},
    ]) {
      final input = legacyGauge(properties: properties);
      try {
        converter.fromJson(input);
        fail('unmarked gauge has no provable model');
      } on UnresolvedNodeSchema catch (error) {
        expect(error.reason, 'ambiguous-gauge-schema');
        expect(error.raw, input);
      }
    }
  });

  test('mixed keys fail closed, retaining entire original document', () {
    final mixed = legacyGauge(
      properties: {'showNeedle': false, 'shape': 'bar'},
    );
    final input = <String, dynamic>{
      'first': GaugeNode.empty().toJson(),
      'mixed': mixed,
      'last': GaugeMeterNode.empty().toJson(),
    };
    try {
      NodesMapConverter.deserialize(input);
      fail('mixed gauge must reject the whole document');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'conflicting-gauge-schema');
      expect(error.nodeKey, 'mixed');
      expect(error.raw, input);
      (mixed['properties'] as Map)['shape'] = 'arc';
      expect(
        ((error.raw['mixed'] as Map)['properties'] as Map)['shape'],
        'bar',
      );
    }
  });

  test('nested canvases fail closed with all sibling data untouched', () {
    final input = <String, dynamic>{
      'a': <String, dynamic>{'good': GaugeNode.empty().toJson()},
      'b': <String, dynamic>{'ambiguous': legacyGauge()},
    };
    try {
      CanvasesMapConverter.deserialize(input);
      fail('ambiguous gauge must reject the canvases map');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'ambiguous-gauge-schema');
      expect(error.nodeKey, 'ambiguous');
      expect(error.raw, input);
      expect(error.raw.keys, ['a', 'b']);
      ((input['b'] as Map)['ambiguous'] as Map)['name'] = 'Changed';
      expect(((error.raw['b'] as Map)['ambiguous'] as Map)['name'], 'Gauge');
      expect((error.raw['a'] as Map).keys, ['good']);
    }
  });
}
