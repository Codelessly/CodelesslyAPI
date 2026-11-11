// An aspect ratio keeps its precision in JSON (Strata v2: 320/180 stored as
// 1.7778 made a 300 px drawing 168.748 tall, and the text below it landed on
// the other side of a device pixel from the reference's).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a layout aspect ratio round trips with its precision', () {
    const ratio = 320 / 180;
    final back = Layout.fromJson(const Layout(aspectRatio: ratio).toJson()).aspectRatio!;
    expect((300 / back - 168.75).abs(), lessThan(1e-8));
  });

  test('pixel values still round to 4 decimals; integral ratios stay ints', () {
    expect(writeDouble(1.23456789), 1.2346);
    expect(writeRatio(2.0), 2);
    expect(writeRatio(16 / 9), closeTo(16 / 9, 1e-12));
  });
}
