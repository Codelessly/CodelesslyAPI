import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Object? encodeDecode(Object? json) => jsonDecode(jsonEncode(json));

void main() {
  // The tide card of qa/surf_log_reference: 97 quarter-hour points over a
  // day, gridlines every 3 hours, night ranges, high/low markers, a dashed
  // "now" line and an hour selection clamped to 5..20.
  final Map tide = jsonDecode(
    File('test/fixtures/chart_tide.json').readAsStringSync(),
  ) as Map;

  group('ChartNode JSON', () {
    test('reads every property of the tide chart', () {
      final node = NodeJsonConverter().fromJson(tide)! as ChartNode;
      final props = node.properties;

      expect(node.type, 'chart');
      expect(node.selectedX, 7);
      expect(node.variables['points'], r'${tideCurve}');
      expect(node.variables['selectedX'], r'${selectedHour}');
      expect(node.reactions.single.trigger.type, TriggerType.changed);
      expect(node.triggerTypes, [TriggerType.changed]);
      expect(props.points, hasLength(97));
      expect(props.xMax, 24);
      expect(props.yMin, -0.5);
      expect(props.fillColor, ColorRGBA.fromHex('#D5E6E4'));
      expect(props.gridStepX, 3);
      expect(props.gridLabels.first, '3a');
      expect(props.labelStyle.fontFamily, 'JetBrains Mono');
      expect(props.labelStyle.height, 1.45);
      expect(props.ranges, [
        ChartRange(from: 0, to: 5, color: ColorRGBA.fromHex('#0F0E2233')!),
        ChartRange(from: 21, to: 24, color: ColorRGBA.fromHex('#0F0E2233')!),
      ]);
      expect(props.markers, hasLength(4));
      expect(props.markers[1].position, ChartMarkerPosition.below);
      expect(props.referenceX, 7.67);
      expect(props.referenceDashed, isTrue);
      expect(props.selectionMin, 5);
      expect(props.selectionMax, 20);
    });

    test('round-trips the tide chart', () {
      final node = NodeJsonConverter().fromJson(tide)! as ChartNode;
      final json = encodeDecode(node.toJson()) as Map;
      final back = NodeJsonConverter().fromJson(json)! as ChartNode;

      expect(back, node);
      expect(back.properties, node.properties);
      expect(encodeDecode(back.toJson()), json);
      // Values equal to their defaults are left out.
      final props = json['properties'] as Map;
      expect(props, isNot(contains('plotInset')));
      expect(props, isNot(contains('selectionStep')));
      expect(props['points'], tide['properties']['points']);
    });

    test('a new chart writes only what differs from the defaults', () {
      final node = ChartNode(
        id: 'c',
        name: 'Chart',
        basicBoxLocal: NodeBox(0, 0, 100, 50),
        properties: ChartProperties(points: [1, 2, 3]),
      );
      expect(encodeDecode(node.toJson()), {
        'id': 'c',
        'name': 'Chart',
        'basicBoxLocal': [0, 0, 100, 50],
        'type': 'chart',
        'properties': {
          'points': [1, 2, 3],
        },
      });
      final back = ChartNode.fromJson(encodeDecode(node.toJson()) as Map);
      expect(back.properties, ChartProperties(points: [1, 2, 3]));
      expect(back.selectedX, isNull);
    });

    test('the sample chart round-trips', () {
      final node = ChartNode.empty();
      final back = ChartNode.fromJson(encodeDecode(node.toJson()) as Map);
      expect(back.properties, node.properties);
      expect(back.properties.points, isNotEmpty);
    });
  });

  group('ChartProperties', () {
    test('copyWith overrides only what it is given', () {
      final props = ChartProperties(points: [1, 2], lineWidth: 3);
      final copy = props.copyWith(gridStepX: 2, smooth: true);
      expect(copy.points, [1, 2]);
      expect(copy.lineWidth, 3);
      expect(copy.gridStepX, 2);
      expect(copy.smooth, isTrue);
      expect(copy, isNot(props));
      expect(props.copyWith(), props);
    });

    test('snaps selections to the step and clamps them', () {
      final props = ChartProperties(
        xMax: 24,
        selectionStep: 1,
        selectionMin: 5,
        selectionMax: 20,
      );
      expect(props.snapSelection(7.9), 7);
      expect(props.snapSelection(2), 5);
      expect(props.snapSelection(23.5), 20);

      final open = ChartProperties(xMax: 24, selectionStep: 3);
      expect(open.snapSelection(-1), 0);
      expect(open.snapSelection(23.9), 21);
      expect(ChartProperties(selectionStep: 0.1).snapSelection(0.35), 0.3);
      expect(ChartProperties(selectionStep: 0).snapSelection(0.37), 0.37);
    });

    test('interpolates the curve between points', () {
      final props = ChartProperties(points: [0, 10, 20], xMax: 2);
      expect(props.valueAt(0), 0);
      expect(props.valueAt(0.5), 5);
      expect(props.valueAt(2), 20);
      expect(props.valueAt(5), 20);
      expect(ChartProperties().valueAt(0), isNull);
    });
  });
}
