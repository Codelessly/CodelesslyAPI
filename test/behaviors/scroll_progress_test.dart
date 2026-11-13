// Sticky nodes and view progress (Strata v2 benchmark): JSON round trips,
// shorthands and the progress geometry the SDK uses.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('a sticky node', () {
    test('given as true or {} sticks at the top, and an offset round-trips', () {
      expect(Sticky.fromJson(true), const Sticky());
      expect(Sticky.fromJson(<String, Object?>{}), const Sticky());
      expect(Sticky.fromJson(false), isNull);
      final n = Node.fromJson({'type': 'row', 'sticky': {'offset': 8}}, id: 'h')!;
      expect(n.behaviors.sticky, const Sticky(offset: 8));
      expect(n.toJson()['sticky'], {'offset': 8});
      expect(Node.fromJson(n.toJson(), id: 'h'), n);
    });

  });

  group('scroll progress', () {

    test('runs from 0 to 1 as the node\'s leading edge crosses the viewport', () {
      const v = ViewProgress(from: 0.92, to: 0.35);
      // viewport 1000: 0 at 920, 1 at 350
      expect(v.progressAt(1200, 300, 1000), 0);
      expect(v.progressAt(920, 300, 1000), 0);
      expect(v.progressAt(635, 300, 1000), closeTo(0.5, 1e-9));
      expect(v.progressAt(350, 300, 1000), 1);
      expect(v.progressAt(-400, 300, 1000), 1);
    });

    test('runs from 0 to 1 as a line passes over the node', () {
      const v = ViewProgress(mode: ViewProgressMode.pass, from: 0, offset: 60);
      // the line sits 60 px down the viewport
      expect(v.progressAt(100, 400, 800), 0);
      expect(v.progressAt(60, 400, 800), 0);
      expect(v.progressAt(-140, 400, 800), closeTo(0.5, 1e-9));
      expect(v.progressAt(-340, 400, 800), 1);
      expect(v.progressAt(-1000, 0, 800), 1);
    });
  });

}
