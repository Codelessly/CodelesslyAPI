import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> gaugeWire(
  String type, {
  Map<String, dynamic>? properties,
  Map<String, dynamic>? variables,
  Object? limit,
}) => {
  'id': 'g',
  'name': 'Gauge',
  'type': type,
  'basicBoxLocal': [0, 0, 220, 185],
  'properties': ?properties,
  'variables': ?variables,
  'limit': ?limit,
};

void expectUnresolved(Map<String, dynamic> input, String reason) {
  try {
    GaugeNode.fromJson(input);
    fail('Expected $reason for direct GaugeNode.fromJson');
  } on UnresolvedNodeSchema catch (error) {
    expect(error.reason, reason);
    expect(error.raw, input);
    // The exception preserves the raw source before any normalization.
    input['name'] = 'Changed after rejection';
    expect(error.raw['name'], 'Gauge');
  }
}

void main() {
  group('direct GaugeMeterNode.fromJson wire guard', () {
    test('unmarked legacy gauge with no exclusive keys remains unresolved', () {
      final input = gaugeWire('gauge', properties: {'startAngle': 135});
      expect(
        () => GaugeMeterNode.fromJson(input),
        throwsA(
          isA<UnresolvedNodeSchema>()
              .having((e) => e.reason, 'reason', 'ambiguous-gauge-schema')
              .having((e) => e.raw, 'raw', input),
        ),
      );
    });

    test('radial-exclusive keys cannot be decoded as meter', () {
      for (final input in [
        gaugeWire('gauge', properties: {'showNeedle': true}),
        gaugeWire('gaugeMeter', properties: {'zones': []}),
        gaugeWire('gaugeMeter', properties: {'shape': 'bar', 'zones': []}),
      ]) {
        try {
          GaugeMeterNode.fromJson(input);
          fail('radial fields cannot become meter fields');
        } on UnresolvedNodeSchema catch (error) {
          expect(error.reason, 'conflicting-gauge-schema');
          expect(error.raw, input);
          (input['properties'] as Map)['zones'] = [42];
          expect(error.raw['name'], 'Gauge');
        }
      }
    });

    test('exclusive old meter and default new meter remain decodable', () {
      final old = GaugeMeterNode.fromJson(
        gaugeWire('gauge', properties: {'shape': 'bar'}),
      );
      expect(old.type, 'gaugeMeter');
      expect(old.toJson()['type'], 'gaugeMeter');
      final generated = GaugeMeterNode.empty().toJson();
      expect(GaugeMeterNode.fromJson(generated).toJson(), generated);
      expect(
        GaugeMeterNode.fromJson(gaugeWire('gaugeMeter')).type,
        'gaugeMeter',
      );
    });

    test('arbitrary future metadata does not imply radial fields', () {
      final input = gaugeWire(
        'gaugeMeter',
        properties: {
          'futureMeterSetting': {'note': 'retain raw in caller'},
        },
      )..['futureMetadata'] = {'source': 'test'};
      expect(GaugeMeterNode.fromJson(input).type, 'gaugeMeter');
    });
  });

  group('direct GaugeNode.fromJson wire guard', () {
    test('ambiguous legacy gauge is not assigned radial defaults', () {
      expectUnresolved(gaugeWire('gauge'), 'ambiguous-gauge-schema');
      expectUnresolved(
        gaugeWire('gauge', properties: {'startAngle': 135}),
        'ambiguous-gauge-schema',
      );
    });

    test('legacy meter-only gauge is not silently read as radial', () {
      expectUnresolved(
        gaugeWire('gauge', properties: {'shape': 'bar'}),
        'conflicting-gauge-schema',
      );
      expectUnresolved(
        gaugeWire('gauge', variables: {'limitColor': 'var'}),
        'conflicting-gauge-schema',
      );
    });

    test('mixed legacy gauge retains the unmodified wire payload', () {
      expectUnresolved(
        gaugeWire('gauge', properties: {'showNeedle': false, 'shape': 'bar'}),
        'conflicting-gauge-schema',
      );
    });

    test('explicit radial rejects meter-exclusive properties and fields', () {
      expectUnresolved(
        gaugeWire('gaugeRadial', properties: {'shape': 'bar'}),
        'conflicting-gauge-schema',
      );
      expectUnresolved(
        gaugeWire('gaugeRadial', limit: 50),
        'conflicting-gauge-schema',
      );
      expectUnresolved(
        gaugeWire('gaugeRadial', variables: {'color': 'theme.color'}),
        'conflicting-gauge-schema',
      );
    });

    test('legacy radial keys and explicit radial generated wire decode', () {
      final legacy = GaugeNode.fromJson(
        gaugeWire('gauge', properties: {'showNeedle': false}),
      );
      expect(legacy.properties.showNeedle, isFalse);
      expect(legacy.properties.startAngle, 150);
      expect(legacy.type, 'gaugeRadial');
      expect(legacy.toJson()['type'], 'gaugeRadial');

      final generated = GaugeNode.empty().toJson();
      expect(GaugeNode.fromJson(generated).toJson(), generated);
      expect(
        GaugeNode.fromJson(gaugeWire('gaugeRadial')).properties,
        GaugeProperties(),
      );
    });

    test('unknown future extras alone are not mistaken for meter keys', () {
      final wire = gaugeWire(
        'gaugeRadial',
        properties: {'futureDialSetting': true},
      )..['futureNodeSetting'] = 42;
      expect(GaugeNode.fromJson(wire).type, 'gaugeRadial');
    });
  });
}
