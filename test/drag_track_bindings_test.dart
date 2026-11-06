import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  const track = DragTrackModel(
    shape: DragTrackShape.arc,
    variable: 'days',
    min: 0,
    max: 365,
    startAngle: 0,
    endAngle: 360,
  );

  test('bound numbers replace the saved settings', () {
    // One turn of the dial is a decade instead of a year.
    final DragTrackModel decade = track.withBinding('endAngle', 36.5).withBinding('max', '3652.5');
    expect(decade.endAngle, 36.5);
    expect(decade.max, 3652.5);
    expect(decade.angleAt(decade.progressOf(365.25)), closeTo(3.65, 1e-9));
  });

  test('values that are not numbers leave the setting as saved', () {
    expect(track.withBinding('min', 'soon'), track);
    expect(track.withBinding('max', null), track);
    expect(track.withBinding('max', double.nan), track);
    expect(track.withBinding('unknown', 3), track);
  });

  test('a path binds as text, and step and pixels per range stay sane', () {
    expect(track.withBinding('path', 'M0 0 L10 0').path, 'M0 0 L10 0');
    expect(track.withBinding('step', -2).step, 0);
    expect(track.withBinding('pixelsPerRange', 0).pixelsPerRange, track.pixelsPerRange);
  });

  test('every bindable setting has a variables key', () {
    expect(DragTrackModel.variableKey('endAngle'), 'dragTrack.endAngle');
    expect(DragTrackModel.bindable, containsAll(['min', 'max', 'startAngle', 'endAngle', 'path']));
  });
}
