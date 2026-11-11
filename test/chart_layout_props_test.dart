import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('chart layout props default to the classic layout (crisp grid lines)', () {
    final chart = Node.fromJson({'type': 'chart'}, id: 'a')!;
    expect(chart.prop(ChartProps.yLabelAlign), ChartYLabelAlign.end);
    expect(chart.prop(ChartProps.xAxisHeight), 22);
    expect(chart.prop(ChartProps.xLabelGap), isNull);
    expect(chart.prop(ChartProps.gridLineMode), ChartGridLineMode.crisp);
    final line = Node.fromJson({'type': 'lineChart'}, id: 'b')!;
    expect(line.prop(LineChartProps.clip), isTrue);
    expect(line.prop(LineChartProps.xLabelAnchor), LineChartXLabelAnchor.edgeClamped);
    expect(line.prop(LineChartProps.xLabelOffset), 0);
  });

  test('chart layout props round-trip', () {
    final chart = Node.fromJson({
      'type': 'chart',
      'props': {'yLabelAlign': 'start', 'xAxisHeight': 26, 'xLabelGap': 8, 'gridLineMode': 'exact'},
    }, id: 'a')!;
    final again = Node.fromJson(chart.toJson(), id: 'a')!;
    expect(again.prop(ChartProps.yLabelAlign), ChartYLabelAlign.start);
    expect(again.prop(ChartProps.xAxisHeight), 26);
    expect(again.prop(ChartProps.xLabelGap), 8);
    expect(again.prop(ChartProps.gridLineMode), ChartGridLineMode.exact);
    final line = Node.fromJson({
      'type': 'lineChart',
      'props': {'clip': false, 'xLabelAnchor': 'start', 'xLabelOffset': -8},
    }, id: 'b')!;
    final line2 = Node.fromJson(line.toJson(), id: 'b')!;
    expect(line2.prop(LineChartProps.clip), isFalse);
    expect(line2.prop(LineChartProps.xLabelAnchor), LineChartXLabelAnchor.start);
    expect(line2.prop(LineChartProps.xLabelOffset), -8);
  });
}
