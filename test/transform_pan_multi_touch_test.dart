// TransformPan.multiTouch: pans only with two or more fingers, so a
// one-finger drag reaches what's inside (Petri v2 paints on a zoomable board).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('multiTouch reads, writes and never pans one finger', () {
    final g = TransformGesture.fromJson({'pan': 'multiTouch', 'target': 'content'})!;
    expect(g.pan, TransformPan.multiTouch);
    expect(g.toJson()['pan'], 'multiTouch');
    expect(g.pansAt(1), isFalse);
    expect(g.pansAt(3), isFalse);
    expect(TransformGesture.fromJson(g.toJson()), g);
  });

  test('the other modes keep their one-finger panning', () {
    expect(TransformGesture.fromJson({'pan': 'always'})!.pansAt(1), isTrue);
    expect(TransformGesture.fromJson({'pan': 'whenZoomed'})!.pansAt(1), isFalse);
    expect(TransformGesture.fromJson({'pan': 'whenZoomed'})!.pansAt(2), isTrue);
  });
}
