// The behaviours v1 master added: motion's shimmer, arc, phase, pause and
// path pacing, loop phases, effect cycles, gesture physics and bounds,
// drag tracks' new settings, flip cards, tilt, transform gestures, hero
// placeholders, and a node's insert key.
import 'package:codelessly_api_v2/codelessly_api.dart';
import 'package:test/test.dart';

Node _node(Json j) => Node.fromJson({'id': 'n', 'type': 'box', ...j})!;

void main() {
  test('motion additions round-trip; named values stay', () {
    final j = {
      'motion': {
        'loop': 'swing',
        'rotate': 20,
        'duration': 1200,
        'arc': 0.25,
        'paused': true,
        'phase': 0.5,
        'path': 'M0 0 L100 0',
        'pathPacing': 'area',
        'pathFocusX': 10,
        'pathFocusY': -4,
        'pathWrap': true,
        'orientToPath': true,
        'orientUpright': true,
        'shimmer': {'color': '#FFFFCC00', 'strength': 0.5, 'width': 0.3, 'duration': 900, 'angle': 90},
        'enterFrom': {'opacity': 1, 'pathProgress': 0},
      },
    };
    final n = _node(j);
    final m = n.behaviours.motion!;
    expect(m.loop, MotionLoop.swing);
    expect(m.paused, isTrue);
    expect(m.pathPacing, MotionPathPacing.area);
    expect(
      m.shimmer,
      const MotionShimmer(color: Color(0xFFFFCC00), strength: 0.5, width: 0.3, duration: 900, angle: 90),
    );
    expect(n.toJson()['motion'], j['motion']);
    // enterFrom names opacity 1 on purpose: the entrance starts there.
    final faded = Motion.fromJson({
      'opacity': 0,
      'enterFrom': {'opacity': 1},
    })!;
    expect(faded.entranceStart.opacity, 1);
    // A loop starts only from what enterFrom moves.
    expect(faded.loopStart.opacity, 0);
  });

  test('motion bindings: paused reads loosely, keyframes from JSON text', () {
    var n = _node({
      'motion': {'rotate': 5},
    });
    n = BindPaths.apply(n, 'motion.paused', 1);
    expect(n.behaviours.motion!.paused, isTrue);
    n = BindPaths.apply(n, 'motion.keyframes', '[{"t": 0.4, "translateY": -60}]');
    expect(n.behaviours.motion!.keyframes, [const MotionKeyframe(t: 0.4, translateY: -60)]);
  });

  test('path helpers', () {
    expect(Motion.wrapProgress(1.25), closeTo(0.25, 1e-9));
    expect(Motion.wrapProgress(-0.25), closeTo(0.75, 1e-9));
    expect(Motion.wrapProgress(1), 1);
    expect(Motion.uprightAngle(3.0), closeTo(3.0 - 3.141592653589793, 1e-9));
  });

  test('loop phase and lag; effect cycles', () {
    const l = LoopAnimation(type: LoopAnimationType.fade, duration: 500, reverse: true, phase: 0.3, lag: 100);
    expect(l.loop, 1000);
    expect(l.startFraction, closeTo(0.2, 1e-9));
    expect(LoopAnimation.fromJson(l.toJson()), l);
    final e = EffectAnimation.fromJson({'name': 'no', 'type': 'shake', 'cycles': 3})!;
    expect(e.cycles, 3);
    expect(e.toJson()['cycles'], 3);
  });

  test('gesture physics: presets, snap points, effective spring', () {
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
    expect(p.bounce, 0.4);
    expect(p.duration, 600);
    expect(p.snap!.points, const [Offset(0, 0), Offset(0, -280), Offset(-560, -560)]);
    expect(GesturePhysics.fromJson(p.toJson()), p);
    expect(p.effectiveStiffness, greaterThan(0));
    expect(const GesturePhysics().projectFling(0, 0), 0);
  });

  test('drag: physics, bounds, limits; source and target settings', () {
    final n = _node({
      'drag': {
        'release': 'stay',
        'bounds': 'contain',
        'minY': -560,
        'maxY': 0,
        'physics': {'bounce': 0.12, 'duration': 420},
      },
      'draggable': {
        'group': 'g',
        'feedbackAnchor': 'center',
        'physics': {'fling': false},
      },
      'dropTarget': {'slotSize': 'node', 'slotWhenRefused': false},
    });
    final b = n.behaviours;
    expect(b.drag!.hasBounds, isTrue);
    expect(b.drag!.minY, -560);
    expect(b.drag!.effectivePhysics!.duration, 420);
    expect(b.draggable!.feedbackAnchor, FeedbackAnchor.center);
    expect(b.dropTarget!.slotSize, DropSlotSize.node);
    expect(b.dropTarget!.slotWhenRefused, isFalse);
    expect(_node(n.toJson()), n);
    // A spring snap back is a spring.
    expect(const DragMotion().effectivePhysics!.bounce, 0.25);
    expect(const DragSource(returnSpring: false).effectivePhysics, isNull);
  });

  test('drag track: new settings, parked, endless, double tap', () {
    const t = DragTrack(
      shape: DragTrackShape.arc,
      min: 1,
      max: 5,
      step: 1,
      parkedProgress: -0.125,
      doubleTapValues: [5, 3],
      endless: false,
    );
    expect(t.restProgressOf(double.nan), -0.125);
    expect(t.restProgressOf(0), -0.125);
    expect(t.restProgressOf(3), 0.5);
    expect(t.doubleTapTarget(5), 3);
    expect(t.doubleTapTarget(2), 5);
    const e = DragTrack(shape: DragTrackShape.arc, max: 40, endless: true, step: 1);
    expect(e.progressOf(80), 2);
    expect(e.snapValue(81.4), 81);
    final j = {
      'variable': 'v',
      'input': 'both',
      'hitArea': 'parent',
      'units': 'parent',
      'settle': 250,
      'settleCurve': 'spring',
      'snap': 120,
      'snapCurve': 'elasticOut',
      'fineStep': 0.1,
      'fineHold': 500,
      'fineVariable': 'fine',
      'momentum': true,
      'smooth': true,
      'gain': 0.5,
      'write': false,
      'keyboard': false,
      'viewBoxWidth': 100,
      'viewBoxHeight': 50,
      'relative': true,
      'detent': 0.35,
      'overscroll': 0.35,
      'value': 3,
    };
    final track = DragTrack.fromJson(j)!;
    expect(track.toJson(), j);
    expect(track.effectiveKeyStep, isNull);
    expect(track.usesViewBox, isTrue);
  });

  test('flip, tilt, transform gesture, hero placeholder, node key', () {
    final j = {
      'key': 'content',
      'flip': {
        'axis': 'x',
        'flipped': true,
        'dragToFlip': true,
        'variable': 'back',
        'spring': {'damping': 20},
      },
      'tilt': {
        'max': {'rotateX': 6, 'rotateY': 6},
        'hover': false,
        'reset': 250,
      },
      'transformGesture': {
        'rotate': true,
        'bounds': 'contain',
        'wheel': 'zoom',
        'scaleVariable': 'zoom',
        'physics': {'fling': false},
        'handles': {'snapAngle': 15, 'color': '#FF000000'},
      },
      'hero': {'tag': 'photo', 'flight': 'containerTransform', 'placeholder': 'source'},
    };
    final n = _node(j);
    expect(n.key, 'content');
    expect(n.behaviours.flip!.axis, FlipAxis.x);
    expect(n.behaviours.tilt!.max.rotateX, 6);
    expect(n.behaviours.transformGesture!.handles!.snapAngle, 15);
    expect(n.behaviours.hero!.placeholder, HeroPlaceholder.source);
    expect(n.behaviours.hero!.flight.crossFades, isTrue);
    final out = n.toJson();
    for (final k in j.keys) {
      expect(out[k], j[k], reason: k);
    }
    // zoomable is a transform gesture's first form.
    expect(_node({'zoomable': true}).behaviours.effectiveTransformGesture, TransformGesture.zoomable);
    expect(_node({'flip': <String, Object?>{}}).toJson()['flip'], isEmpty);
  });

  test('a bound switch of a drag, a drag source and a drop target reads loosely', () {
    for (final (v, on) in [(0, false), (1, true), ('true', true), ('off', false), ('?', true)]) {
      expect(DragMotion.fromJson({'enabled': v})!.enabled, on, reason: '$v');
      expect(DragSource.fromJson({'enabled': v})!.enabled, on, reason: '$v');
      expect(DropTarget.fromJson({'enabled': v})!.enabled, on, reason: '$v');
    }
    final n = BindPaths.apply(_node({'drag': <String, Object?>{}}), 'drag.enabled', 0);
    expect(n.behaviours.drag!.enabled, isFalse);
    expect(BindPaths.apply(n, 'drag.restX', '40').behaviours.drag!.restX, 40);
  });
}
