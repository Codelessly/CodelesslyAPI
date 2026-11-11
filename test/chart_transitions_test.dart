import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  for (final (type, animate, duration) in [
    ('chart', ChartProps.animate, ChartProps.animationDuration),
    ('lineChart', LineChartProps.animate, LineChartProps.animationDuration),
    ('plotChart', PlotChartProps.animate, PlotChartProps.animationDuration),
  ]) {
    test('$type animation defaults are sparse and discoverable', () {
      final n = Node.fromJson({'type': type})!;
      expect(n.prop(animate), isTrue);
      expect(n.prop(duration), 700);
      expect(
        (n.toJson()['props'] as Map?)?.containsKey('animate') ?? false,
        isFalse,
      );
      expect(
        (n.toJson()['props'] as Map?)?.containsKey('animationDuration') ??
            false,
        isFalse,
      );
      expect(n.spec!.props.where((p) => p.key == 'animate'), hasLength(1));
      expect(
        n.spec!.props.where((p) => p.key == 'animationDuration'),
        hasLength(1),
      );
    });
    test('$type disabled/custom duration survives serialization', () {
      final n = Node.fromJson({
        'type': type,
        'props': {'animate': false, 'animationDuration': 1250},
      })!;
      expect(n.prop(animate), isFalse);
      expect(n.prop(duration), 1250);
      expect(n.toJson()['props'], {
        'animate': false,
        'animationDuration': 1250,
      });
      expect(Node.fromJson(n.toJson()), n);
    });
    test(
      '$type zero duration and negative duration decode without breaking old data',
      () {
        final zero = Node.fromJson({
          'type': type,
          'props': {'animationDuration': 0},
        })!;
        final negative = Node.fromJson({
          'type': type,
          'props': {'animationDuration': -10},
        })!;
        expect(zero.prop(duration), 0);
        expect(negative.prop(duration), 0);
        expect(Node.fromJson(zero.toJson()), zero);
      },
    );
  }
}
