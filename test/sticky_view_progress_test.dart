// Sticky nodes and view progress (Strata v2 benchmark): JSON round trips,
// shorthands and the progress geometry the SDK uses.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('sticky', () {
    test('true and {} read as offset 0; offsets round-trip', () {
      expect(Sticky.fromJson(true), const Sticky());
      expect(Sticky.fromJson(<String, Object?>{}), const Sticky());
      expect(Sticky.fromJson(false), isNull);
      final n = Node.fromJson({'type': 'row', 'sticky': {'offset': 8}}, id: 'h')!;
      expect(n.behaviors.sticky, const Sticky(offset: 8));
      expect(n.toJson()['sticky'], {'offset': 8});
      expect(Node.fromJson(n.toJson(), id: 'h'), n);
    });

    test('a node without it has none', () {
      expect(Node.fromJson({'type': 'row'}, id: 'a')!.behaviors.sticky, isNull);
    });
  });

  group('viewProgress', () {
    test('round-trips sparse', () {
      const v = ViewProgress(mode: ViewProgressMode.pass, from: 0, offset: 68, variable: 'layerProgress', key: 'kaibab');
      expect(v.toJson(), {'mode': 'pass', 'from': 0, 'offset': 68, 'variable': 'layerProgress', 'key': 'kaibab'});
      expect(ViewProgress.fromJson(v.toJson()), v);
      expect(ViewProgress.fromJson(true), const ViewProgress());
      expect(const ViewProgress().toJson(), isEmpty);
      final n = Node.fromJson({'type': 'column', 'viewProgress': {'from': 0.92, 'to': 0.35}}, id: 'f')!;
      expect(n.behaviors.viewProgress, const ViewProgress(from: 0.92, to: 0.35));
      expect(Node.fromJson(n.toJson(), id: 'f'), n);
    });

    test('travel: the leading edge from `from` to `to` of the viewport', () {
      const v = ViewProgress(from: 0.92, to: 0.35);
      // viewport 1000: 0 at 920, 1 at 350
      expect(v.progressAt(1200, 300, 1000), 0);
      expect(v.progressAt(920, 300, 1000), 0);
      expect(v.progressAt(635, 300, 1000), closeTo(0.5, 1e-9));
      expect(v.progressAt(350, 300, 1000), 1);
      expect(v.progressAt(-400, 300, 1000), 1);
    });

    test('pass: a line passing over the node, with an offset', () {
      const v = ViewProgress(mode: ViewProgressMode.pass, from: 0, offset: 60);
      // the line sits 60 px down the viewport
      expect(v.progressAt(100, 400, 800), 0);
      expect(v.progressAt(60, 400, 800), 0);
      expect(v.progressAt(-140, 400, 800), closeTo(0.5, 1e-9));
      expect(v.progressAt(-340, 400, 800), 1);
      expect(v.progressAt(-1000, 0, 800), 1);
    });
  });

  group('measure', () {
    test('round-trips; empty stays empty', () {
      final n = Node.fromJson({'type': 'row', 'measure': {'variable': 'chipBoxes', 'key': r'${item.id}', 'relativeTo': 'spine'}}, id: 'c')!;
      expect(n.behaviors.measure, const Measure(variable: 'chipBoxes', key: r'${item.id}', relativeTo: 'spine'));
      expect(Node.fromJson(n.toJson(), id: 'c'), n);
      expect(const Measure().toJson(), isEmpty);
    });
  });
}
