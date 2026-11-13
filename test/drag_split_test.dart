// The legacy `drag` key split into `track`, `dismissible`, `pan` and
// `reorderHandle` (docs/design/04-drag-and-track.md): old JSON in, the new
// model out, written only in the new shape; legacy binding paths rewritten.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Node _node(Json j) => Node.fromJson({'id': 'n', 'type': 'box', ...j})!;

void main() {
  test('a drag with a track is the track; drag.enabled is its enabled', () {
    final n = _node({
      'drag': {
        'enabled': false,
        'release': 'dismiss',
        'track': {'variable': 'volume', 'shape': 'arc', 'max': 10},
      },
      'bind': {'drag.track.value': r'${level}', 'drag.enabled': r'${on}', 'drag.track.x2': '40'},
    });
    final b = n.behaviors;
    expect(b.track, const Track(enabled: false, variable: 'volume', shape: TrackShape.arc, max: 10));
    expect(b.dismissible, isNull);
    expect(b.pan, isNull);
    expect(n.bind, {'track.value': r'${level}', 'track.enabled': r'${on}', 'track.x2': '40'});
    final out = n.toJson();
    expect(out.containsKey('drag'), isFalse);
    expect(out['track'], {'enabled': false, 'variable': 'volume', 'shape': 'arc', 'max': 10});
    expect(_node(out), n);
  });

  test('drag.reorder is a reorder handle', () {
    final n = _node({
      'drag': {'reorder': true},
    });
    expect(n.behaviors.reorderHandle, isTrue);
    expect(n.behaviors.pan, isNull);
    expect(n.toJson()['reorderHandle'], isTrue);
    expect(n.toJson().containsKey('drag'), isFalse);
  });

  test('a dismissing drag is a dismissible with its old defaults written out', () {
    final n = _node({
      'drag': {
        'release': 'dismiss',
        'directions': ['left', 'right', 'up'],
        'rotateFactor': 15,
        'originY': 1.6,
        'resistance': 0.7,
        'verticalThreshold': 0.25,
      },
    });
    final d = n.behaviors.dismissible!;
    expect(d.directions, [DragDirection.left, DragDirection.right, DragDirection.up]);
    expect(d.thresholdFor(DragDirection.left), 0.35);
    expect(d.thresholdFor(DragDirection.up), 0.25);
    expect(d.flingVelocity, 800);
    expect(d.movementDuration, 320);
    expect(d.curve, AnimationCurve.easeIn);
    expect(d.effectiveReturnDuration, 450);
    expect(d.effectiveReturnCurve, AnimationCurve.spring);
    expect(d.returnSpring, isNull);
    expect(n.toJson()['dismissible'], {
      'directions': ['left', 'right', 'up'],
      'dismissThresholds': {'left': 0.35, 'right': 0.35, 'up': 0.25, 'down': 0.25},
      'flingVelocity': 800,
      'resistance': 0.7,
      'movementDuration': 320,
      'curve': 'easeIn',
      'returnDuration': 450,
      'returnCurve': 'spring',
      'rotateFactor': 15,
      'originY': 1.6,
    });
    expect(_node(n.toJson()), n);
    // Every direction by default; physics is the return spring.
    final all = _node({
      'drag': {
        'release': 'dismiss',
        'physics': {'bounce': 0.3, 'duration': 400},
        'velocityThreshold': 600,
        'flyOut': 260,
      },
    }).behaviors.dismissible!;
    expect(all.directions, DragDirection.values);
    expect(all.returnSpring, const Spring(duration: 400, bounce: 0.3));
    expect(all.flingVelocity, 600);
    expect(all.movementDuration, 260);
  });

  test('a new dismissible takes Flutter\'s defaults and names', () {
    final d = DismissibleBehavior.fromJson(<String, Object?>{})!;
    expect(d.directions, [DragDirection.left, DragDirection.right]);
    expect(d.thresholdFor(DragDirection.right), 0.4);
    expect(d.flingVelocity, 700);
    expect(d.movementDuration, 200);
    expect(d.toJson(), isEmpty);
    expect(DismissibleBehavior.fromJson({'direction': 'vertical'})!.directions, [DragDirection.up, DragDirection.down]);
    expect(DismissibleBehavior.fromJson({'direction': 'endToStart'})!.directions, [DragDirection.left]);
    final j = {
      'directions': ['up'],
      'dismissThresholds': {'up': 0.25},
      'returnSpring': {'duration': 450, 'bounce': 0.25},
    };
    expect(DismissibleBehavior.fromJson(j)!.toJson(), j);
  });

  test('any other drag is a pan', () {
    final n = _node({
      'drag': {
        'axis': 'vertical',
        'release': 'stay',
        'minY': -560,
        'maxY': 0,
        'restY': -40,
        'snapBack': 300,
        'yVariable': 'sheetY',
        'physics': {
          'snap': {
            'points': [
              [0, 0],
              [0, -560],
            ],
          },
        },
      },
    });
    final p = n.behaviors.pan!;
    expect(p.axis, DragAxis.vertical);
    expect(p.release, PanRelease.stay);
    expect(p.y, -40);
    expect(p.returnDuration, 300);
    expect(p.yVariable, 'sheetY');
    expect(p.physics!.snap!.points.last, const Offset(0, -560));
    final out = n.toJson()['pan'] as Map;
    expect(out['y'], -40);
    expect(out['returnDuration'], 300);
    expect(out.containsKey('restY'), isFalse);
    expect(out.containsKey('snapBack'), isFalse);
    expect(_node(n.toJson()), n);
    // The plain drag: springs back.
    expect(_node({'drag': <String, Object?>{}}).behaviors.pan, const Pan());
  });

  test('legacy drag binding paths address the behavior the drag became', () {
    final card = _node({
      'drag': {'release': 'dismiss'},
      'bind': {
        'drag.enabled': r'${ok}',
        'drag.restX': r'${peek}',
        'drag.distanceThreshold': '0.2',
        'drag.flyOut': '200',
        'drag.unknown': '1',
      },
    });
    expect(card.bind, {
      'dismissible.enabled': r'${ok}',
      'dismissible.restX': r'${peek}',
      'dismissible.dismissThresholds.left': '0.2',
      'dismissible.dismissThresholds.right': '0.2',
      'dismissible.dismissThresholds.up': '0.2',
      'dismissible.dismissThresholds.down': '0.2',
      'dismissible.movementDuration': '200',
      'drag.unknown': '1',
    });
    final applied = BindPaths.apply(card, 'dismissible.dismissThresholds.up', 0.1);
    expect(applied.behaviors.dismissible!.thresholdFor(DragDirection.up), 0.1);
    final sheet = _node({
      'drag': {'release': 'stay'},
      'bind': {'drag.restX': r'${x}', 'drag.enabled': r'${on}', 'drag.physics.friction': '0.5'},
    });
    expect(sheet.bind, {'pan.x': r'${x}', 'pan.enabled': r'${on}', 'pan.physics.friction': '0.5'});
    expect(BindPaths.apply(sheet, 'pan.x', 12).behaviors.pan!.x, 12);
  });

  test('the new keys are declared and the legacy one is not written', () {
    expect(Behaviors.keys, containsAll(['track', 'dismissible', 'pan', 'reorderHandle']));
    expect(Behaviors.keys, isNot(contains('drag')));
    expect(Behaviors.legacyKeys, contains('drag'));
    expect(_node({'drag': <String, Object?>{}}).extra, isEmpty);
  });
}
