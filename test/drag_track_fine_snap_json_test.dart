import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('DragTrackModel fine mode and snapping', () {
    test('round-trips fine and snap fields and omits their defaults', () {
      const track = DragTrackModel(
        shape: DragTrackShape.arc,
        variable: 'temp',
        min: 16,
        max: 28,
        step: 0.5,
        input: DragTrackInput.vertical,
        pixelsPerRange: 384,
        fineStep: 0.1,
        finePixelsPerRange: 1200,
        fineVariable: 'tempFine',
        snapMs: 120,
      );
      final Map json = track.toJson();
      expect(json['fineStep'], 0.1);
      expect(json['finePixelsPerRange'], 1200.0);
      expect(json['fineVariable'], 'tempFine');
      expect(json['snapMs'], 120);
      expect(json.containsKey('fineHoldMs'), isFalse);
      expect(json.containsKey('snapCurve'), isFalse);
      expect(DragTrackModel.fromJson(json), track);
      expect(const DragTrackModel(variable: 'v').toJson().keys, ['variable']);
    });

    test('fine snapping and the fine range', () {
      const track = DragTrackModel(variable: 't', min: 16, max: 28, step: 0.5, fineStep: 0.1, pixelsPerRange: 384);
      expect(track.hasFine, isTrue);
      expect(track.snap(20.33), 20.5);
      expect(track.snapFine(20.33), 20.3);
      expect(track.effectiveFinePixelsPerRange, 384 * 4);
      expect(const DragTrackModel(variable: 't').hasFine, isFalse);
      expect(DragTrackModel.liveValues, contains('fine'));
    });
  });
}
