import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('DragTrackModel', () {
    test('round-trips through JSON inside a DragModel and omits defaults', () {
      const drag = DragModel(
        track: DragTrackModel(
          shape: DragTrackShape.arc,
          variable: 'bpm',
          min: 30,
          max: 250,
          step: 1,
          defaultValue: 120,
        ),
      );
      final json = drag.toJson();
      expect(json['track'], {
        'shape': 'arc',
        'variable': 'bpm',
        'min': 30.0,
        'max': 250.0,
        'step': 1.0,
        'defaultValue': 120.0,
      });
      expect(DragModel.fromJson(json), drag);
    });

    test('reads a minimal track', () {
      final t = DragTrackModel.fromJson({'variable': 'level', 'y2': -250});
      expect(t.shape, DragTrackShape.line);
      expect(t.min, 0);
      expect(t.max, 1);
      expect(t.y2, -250);
      expect(t.defaultValue, isNull);
    });

    test('maps values to progress and back, snapped to steps', () {
      const t = DragTrackModel(variable: 'v', min: 30, max: 250, step: 1);
      expect(t.progressOf(140), closeTo(0.5, 1e-9));
      expect(t.progressOf(1000), 1);
      expect(t.valueAt(0.5), 140);
      expect(t.valueAt(0.50123), 140);
      const fine = DragTrackModel(variable: 'v', min: 0, max: 1, step: 0.1);
      expect(fine.snap(0.33), 0.3);
      const db = DragTrackModel(variable: 'v', min: -48, max: 6, step: 0.5);
      expect(db.snap(-6.2), -6);
      expect(db.snap(-6.3), -6.5);
      expect(db.wheelStep, 0.5);
    });

    test('runs backwards when max is below min', () {
      const t = DragTrackModel(variable: 'v', min: 10, max: 0);
      expect(t.progressOf(10), 0);
      expect(t.progressOf(0), 1);
      expect(t.valueAt(0.25), 7.5);
    });

    test('turns through the arc from start to end angle', () {
      const t = DragTrackModel(variable: 'v', shape: DragTrackShape.arc);
      expect(t.angleAt(0), -135);
      expect(t.angleAt(0.5), 0);
      expect(t.angleAt(1), 135);
    });
  });
}
