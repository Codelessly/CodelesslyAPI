import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

BaseNode roundTrip(BaseNode node) => NodeJsonConverter.instance.fromJson(
  jsonDecode(jsonEncode(node.toJson())) as Map,
)!;

void main() {
  group('GaugeMeterNode', () {
    test('a default gauge stores only its identity and box', () {
      final node = GaugeMeterNode(
        id: 'g',
        name: 'Gauge',
        basicBoxLocal: NodeBox(0, 0, 160, 160),
        properties: GaugeMeterProperties(),
      );
      final json = node.toJson();
      expect(json['type'], 'gauge');
      expect(json['gaugeKind'], 'meter');
      expect(json['properties'], isEmpty);
      expect(json.containsKey('value'), isFalse);
      expect(json.containsKey('limit'), isFalse);
      expect(roundTrip(node), node);
    });

    test('a tank-style bar gauge round-trips every property', () {
      final node = GaugeMeterNode(
        id: 'tank',
        name: 'Black tank',
        basicBoxLocal: NodeBox(0, 0, 76, 220),
        value: 87,
        limit: 75,
        variables: {'value': r'${= tanks.black * 100}'},
        properties: GaugeMeterProperties(
          shape: GaugeShape.bar,
          color: ColorRGBA.black,
          trackColor: ColorRGBA.transparent,
          fillStartOpacity: 0.55,
          segments: 0,
          cornerRadius: 4,
          backgroundColor: ColorRGBA.black,
          borderColor: ColorRGBA.white,
          inset: 3,
          edgeWidth: 2,
          ticks: 10,
          majorTickEvery: 5,
          limitStyle: GaugeLimitStyle.dashed,
          limitWidth: 2,
          limitPointer: true,
          animate: false,
        ),
      );
      final back = roundTrip(node) as GaugeMeterNode;
      expect(back, node);
      expect(back.properties.shape, GaugeShape.bar);
      expect(back.properties.limitStyle, GaugeLimitStyle.dashed);
      expect(back.limit, 75);
      expect(back.variables['value'], r'${= tanks.black * 100}');
    });

    test('exposes value, limit and colors as settable properties', () {
      final node = GaugeMeterNode(
        id: 'g',
        name: 'Gauge',
        basicBoxLocal: NodeBox(0, 0, 160, 160),
        properties: GaugeMeterProperties(),
      );
      expect(
        node.propertyVariables.map((v) => v.name),
        containsAll(['value', 'limit', 'color', 'limitColor']),
      );
    });
  });

  group('BarChartNode', () {
    test('round-trips nullable values, labels and highlight', () {
      final node = BarChartNode(
        id: 'chart',
        name: 'Solar by hour',
        basicBoxLocal: NodeBox(0, 0, 400, 160),
        values: [4, 22, 78, null, null],
        labels: ['6a', '', '8a', '', '10a'],
        highlight: 2,
        properties: BarChartProperties(
          max: 480,
          gridLabels: ['160', '320', '480'],
          labelFontSize: 11,
        ),
      );
      final back = roundTrip(node) as BarChartNode;
      expect(back, node);
      expect(back.values, [4, 22, 78, null, null]);
      expect(back.properties.gridLabels, ['160', '320', '480']);
    });

    test('a default chart omits its defaults', () {
      final node = BarChartNode(
        id: 'chart',
        name: 'Chart',
        basicBoxLocal: NodeBox(0, 0, 320, 160),
        properties: BarChartProperties(),
      );
      expect(node.toJson()['properties'], isEmpty);
      expect(roundTrip(node), node);
    });
  });
}
