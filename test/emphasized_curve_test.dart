import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('the emphasized curve is Material 3\'s Cubic(0.2, 0, 0, 1)', () {
    const c = AnimationCurve.emphasized;
    expect(AnimationCurve.parse('emphasized'), c);
    expect(c.transform(0), 0);
    expect(c.transform(1), 1);
    // Quick start, gentle settle: well past halfway at a quarter of the time.
    expect(c.transform(.25), greaterThan(.6));
    expect(c.transform(.5), closeTo(.89, .02));
  });
}
