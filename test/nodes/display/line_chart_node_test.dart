import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Object? encodeDecode(Object? json) => jsonDecode(jsonEncode(json));

void main() {
  group('LineChartNode', () {
    test('is registered as lineChart', () {
      expect(LineChartNode.empty().type, 'lineChart');
      expect(NodeJsonConverter.isNodeRegistered('lineChart'), isTrue);
    });

    test('has the documented defaults', () {
      final props = LineChartProperties();
      expect(props.xField, 'x');
      expect(props.yField, 'y');
      expect(props.xMin, isNull);
      expect(props.xMax, isNull);
      expect(props.yMin, isNull);
      expect(props.yMax, isNull);
      expect(props.padLeft, 44);
      expect(props.padRight, 14);
      expect(props.padTop, 30);
      expect(props.padBottom, 30);
      expect(props.smooth, isFalse);
      expect(props.lineWidth, 2);
      expect(props.scrubEnabled, isFalse);
      expect(props.scrubStep, 1);
      expect(props.tooltipXFormat, 'h:mm a');
      expect(props.tooltipYScale, 1);
      expect(props.tooltipYDecimals, 1);
      expect(props.tooltipYSuffix, '');
      expect(props.tooltipTrend, isFalse);
      expect(props.semanticLabel, '');
    });

    test('decodes with only a type, id, name and box', () {
      final node = NodeJsonConverter().fromJson({
        'type': 'lineChart',
        'id': 'chart',
        'name': 'Chart',
        'basicBoxLocal': [0, 0, 300, 200],
      }) as LineChartNode;
      expect(node.properties, LineChartProperties());
      expect(node.variables, isEmpty);
    });

    test('leaves default scalar properties out of its JSON', () {
      final json = encodeDecode(LineChartNode.empty().toJson()) as Map;
      final props = json['properties'] as Map;
      for (final key in [
        'xField',
        'yField',
        'padLeft',
        'padTop',
        'smooth',
        'lineColor',
        'lineWidth',
        'scrubEnabled',
        'tooltipXFormat',
        'tooltipYScale',
        'semanticLabel',
      ]) {
        expect(props.containsKey(key), isFalse, reason: key);
      }
      expect(props.containsKey('xMin'), isFalse);
    });

    test('round-trips a tide-like chart', () {
      final node = LineChartNode(
        id: 'tide',
        name: 'Tide chart',
        basicBoxLocal: NodeBox(0, 0, 600, 280),
        properties: LineChartProperties(
          xField: 't',
          yField: 'ft',
          yMin: -1,
          yMax: 7,
          smooth: true,
          lineColor: ColorRGBA.fromHex('#1F2B2E')!,
          lineWidth: 2.5,
          areaTopColor: ColorRGBA.fromHex('#6B1F6F78')!,
          areaBottomColor: ColorRGBA.fromHex('#1F9CC5B5')!,
          yAxisTitle: 'FT',
          scrubEnabled: true,
          scrubStep: 30,
          tooltipYSuffix: ' ft',
          tooltipTrend: true,
          axisLabelStyle: TextProp(
            fontSize: 11,
            fontName: const FontName(
              family: 'IBM Plex Mono',
              weight: FontWeightNumeric.w600,
            ),
            fills: [ColorRGBA.fromHex('#7D8584')!.toPaint('muted')],
          ),
        ),
        variables: {
          'data': r'${tides.points}',
          'xMin': r'${= tides.day + " 00:00"}',
          'bands': r'${tides.night}',
          'semanticLabel': r'${= "Tide chart for " + tides.dayName}',
        },
      );
      final json = encodeDecode(node.toJson()) as Map;
      expect(json['type'], 'lineChart');
      expect((json['properties'] as Map)['smooth'], isTrue);
      expect((json['properties'] as Map)['yMin'], -1);
      final back = NodeJsonConverter().fromJson(json)! as LineChartNode;
      expect(back, node);
      expect(back.properties.axisLabelStyle.fontName.family, 'IBM Plex Mono');
      expect(back.variables['data'], r'${tides.points}');
      expect(encodeDecode(back.toJson()), json);
    });

    test('copyWith overrides only the given fields', () {
      final props = LineChartProperties(smooth: true);
      final copy = props.copyWith(lineWidth: 3);
      expect(copy.smooth, isTrue);
      expect(copy.lineWidth, 3);
      expect(copy, isNot(props));
      expect(props.copyWith(), props);
    });
  });
}
