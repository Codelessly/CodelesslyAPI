// Gesture physics presets and the loosely read switches of the gesture behaviors.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Node _node(Json j) => Node.fromJson({'id': 'n', 'type': 'box', ...j}, catalog: standardCatalog)!;

void main() {

  test('a gesture physics preset gives its bounce and duration, and snap points read in any form', () {
    final p = GesturePhysics.fromJson({
      'preset': 'bouncy',
      'snap': {
        'points': [
          [0, 0],
          {'y': -280},
          -560,
        ],
      },
    })!;
    expect(p.spring.bounce, 0.4);
    expect(p.spring.duration, 600);
    expect(p.snap!.points, const [Offset(0, 0), Offset(0, -280), Offset(-560, -560)]);
    expect(GesturePhysics.fromJson(p.toJson()), p);
    expect(p.effectiveStiffness, greaterThan(0));
    expect(const GesturePhysics().projectFling(0, 0), 0);
  });

  test('a pan, a dismissible, a track, a drag source and a drop target switched by a binding read yes and no loosely', () {
    for (final (v, on) in [(0, false), (1, true), ('true', true), ('off', false), ('?', true)]) {
      expect(Pan.fromJson({'enabled': v})!.enabled, on, reason: '$v');
      expect(DismissibleBehavior.fromJson({'enabled': v})!.enabled, on, reason: '$v');
      expect(Track.fromJson({'enabled': v})!.enabled, on, reason: '$v');
      expect(DragSource.fromJson({'enabled': v})!.enabled, on, reason: '$v');
      expect(DropTarget.fromJson({'enabled': v})!.enabled, on, reason: '$v');
    }
    final n = BindPaths.apply(_node({'pan': <String, Object?>{}}), 'pan.enabled', 0);
    expect(n.behaviors.pan!.enabled, isFalse);
    expect(BindPaths.apply(n, 'pan.x', '40').behaviors.pan!.x, 40);
  });
}
