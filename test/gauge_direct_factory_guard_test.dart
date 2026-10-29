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
