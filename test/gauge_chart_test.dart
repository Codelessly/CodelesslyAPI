import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('GaugeProperties', () {
    final props = GaugeProperties();

    test('fraction clamps to the arc', () {
      expect(props.fraction(50), 0.5);
      expect(props.fraction(-10), 0);
      expect(props.fraction(140), 1);
    });

    test('the value arc takes the color of its zone', () {
      expect(props.colorFor(40), kDefaultGaugeZones[0].color);
      expect(props.colorFor(72), kDefaultGaugeZones[1].color);
      expect(props.colorFor(85), kDefaultGaugeZones[2].color);
      expect(props.colorFor(100), kDefaultGaugeZones[2].color);
      expect(
        GaugeProperties(colorByZone: false).colorFor(40),
        props.valueColor,
      );
    });

    test('a gauge with a bound value round-trips', () {
      final node = GaugeNode(
        id: 'g',
        name: 'Plant OEE',
        basicBoxLocal: NodeBox(0, 0, 220, 185),
        properties: GaugeProperties(showTarget: false, showNeedle: false),
        variables: {'value': r'${plantOee}'},
      );
      final back = NodeJsonConverter().fromJson(node.toJson())! as GaugeNode;
      expect(back.properties.showTarget, isFalse);
      expect(back.properties.showNeedle, isFalse);
      expect(back.variables['value'], r'${plantOee}');
    });
  });

  group('ChartNode', () {
    test('defaults omit from JSON and come back', () {
      final node = ChartNode(
        id: 'c',
        name: 'Chart',
        basicBoxLocal: NodeBox(0, 0, 360, 200),
        properties: ChartProperties(),
      );
      final json = node.toJson();
      expect((json['properties'] as Map?) ?? {}, isEmpty);
      final back = NodeJsonConverter().fromJson(json)! as ChartNode;
      expect(back.properties.series, kDefaultChartSeries);
      expect(back.selectedIndex, -1);
    });

    test('series and data bindings round-trip', () {
      final node = ChartNode.fromJson({
        'id': 'c',
        'name': 'Hourly',
        'type': 'chartSeries',
        'basicBoxLocal': [0, 0, 400, 220],
        'variables': {
          'data': r'${hourly}',
          'selectedIndex': r'${selectedHour}',
        },
        'properties': {
          'series': [
            {'field': 'good', 'stack': 'o', 'colorField': 'color'},
            {'field': 'plan', 'kind': 'tick', 'dashed': true},
          ],
        },
      });
      expect(node.properties.series[0].colorField, 'color');
      expect(node.properties.series[1].kind, ChartSeriesKind.tick);
      expect(node.triggerTypes, [TriggerType.changed]);
      final back = NodeJsonConverter().fromJson(node.toJson())! as ChartNode;
      expect(back, node);
    });

    test('a timeline keeps its now marker color', () {
      final props = ChartProperties.fromJson({
        'type': 'timeline',
        'nowValue': 7.7,
        'nowColor': {'r': 1, 'g': 1, 'b': 1, 'a': 1},
      });
      expect(props.nowColor, const ColorRGBA(r: 1, g: 1, b: 1, a: 1));
      expect(ChartProperties.fromJson(props.toJson()), props);
      expect(ChartProperties().toJson().containsKey('nowColor'), isFalse);
    });
  });

  test('a repeating gradient keeps its tile mode', () {
    final paint = PaintModel.linearGradient(
      id: 'p',
      gradientTileMode: GradientTileMode.repeated,
      gradientStops: const [ColorStop(position: 0, color: ColorRGBA.black)],
    );
    final back = PaintModel.fromJson(paint.toJson());
    expect(back.gradientTileMode, GradientTileMode.repeated);
    expect(back.sanitize().gradientTileMode, GradientTileMode.repeated);
    expect(
      PaintModel.fromJson(PaintModel.linearGradient(id: 'q').toJson())
          .gradientTileMode,
      GradientTileMode.clamp,
    );
  });

  test('gauge and chart JSON may leave out properties', () {
    final gauge = NodeJsonConverter().fromJson({
      'id': 'g',
      'name': 'G',
      'type': 'gaugeRadial',
      'basicBoxLocal': [0, 0, 220, 185],
    });
    final chart = NodeJsonConverter().fromJson({
      'id': 'c',
      'name': 'C',
      'type': 'chartSeries',
      'basicBoxLocal': [0, 0, 300, 200],
    });
    expect((gauge! as GaugeNode).properties, GaugeProperties());
    expect((chart! as ChartNode).properties.series, kDefaultChartSeries);
  });

  // Types that need content of their own (an icon, a URL, a title, ...)
  // still need it in JSON.
  test('nodes read minimal JSON: no properties, no scroll settings', () {
    for (final type in [
      'listView',
      'gridView',
      'pageView',
      'progressBar',
      'switch',
      'checkbox',
      'textField',
      'button',
      'chip',
      'badge',
      'divider',
      'segmentedButton',
      'listTile',
      'radio',
      'floatingActionButton',
      'accordion',
      'gaugeRadial',
      'gaugeMeter',
      'chartSeries',
      'chartPlot',
    ]) {
      final node = NodeJsonConverter().fromJson({
        'id': type,
        'name': type,
        'type': type,
        'basicBoxLocal': [0, 0, 100, 40],
      });
      expect(node?.type, type, reason: type);
    }
  });
}
