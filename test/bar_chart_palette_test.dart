import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'per-bar colours survive serialization; old charts inherit their single colour',
    () {
      final node = Node.fromJson({
        'type': 'barChart',
        'props': {
          'values': [1, 2],
          'colors': ['#FFC45144', '#FF285B91'],
        },
      }, id: 'bars')!;
      final restored = Node.fromJson(node.toJson(), id: 'bars')!;
      expect(restored.prop(BarChartProps.colors).map((c) => c.toJson()), [
        '#FFC45144',
        '#FF285B91',
      ]);
      final legacy = Node.fromJson({
        'type': 'barChart',
        'props': {'color': '#FF00FF00'},
      }, id: 'legacy')!;
      expect(legacy.prop(BarChartProps.colors), isEmpty);
      expect((legacy.toJson()['props'] as Map).containsKey('colors'), isFalse);
    },
  );
}
