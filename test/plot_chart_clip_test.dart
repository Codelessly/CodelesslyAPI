import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('plotChart clips by default and can draw past its box', () {
    expect(Node.fromJson({'type': 'plotChart'}, id: 'a')!.prop(PlotChartProps.clip), isTrue);
    final open = Node.fromJson({'type': 'plotChart', 'props': {'clip': false}}, id: 'b')!;
    expect(open.prop(PlotChartProps.clip), isFalse);
    expect(Node.fromJson(open.toJson(), id: 'b')!.prop(PlotChartProps.clip), isFalse);
  });
}
