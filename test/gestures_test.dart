// Behaviors: a legacy motion's shimmer, arc, phase, pause and
// path pacing, loop phases, effect cycles, gesture physics and bounds,
// drag tracks' settings, flip cards, tilt, transform gestures, hero
// placeholders, and a node's insert key.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Node _node(Json j) => Node.fromJson({'id': 'n', 'type': 'box', ...j})!;

void main() {
  test('motion additions read into the new shape; named values stay', () {
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
    final m = n.behaviors.motion!;
    final loop = n.behaviors.animations.firstWhere((a) => a.id == 'loop');
    expect(loop.params['mode'], 'swing');
    expect(loop.paused, isTrue);
    expect(m.path!.pacing, PathPacing.area);
    expect(m.path!.focus, [10, -4]);
    expect(m.path!.orient, PathOrient.upright);
    expect(n.behaviors.shimmer, const Shimmer(color: Color(0xFFFFCC00), strength: 0.5, width: 0.3, angle: 90));
    expect(n.behaviors.animations.firstWhere((a) => a.id == 'shimmer').duration, 900);
    expect(Transition.of(n.behaviors.transitions, 'motion.translateX')!.arc, 0.25);
    expect(Node.fromJson(n.toJson()), n);
    // enterFrom names opacity 1 on purpose: the entrance starts there.
    Map<String, Object?> from(Json motion) =>
        readMap(_node({'motion': motion}).behaviors.animations.single.params['from'])!;
    expect(from({'opacity': 0, 'duration': 300, 'enterFrom': {'opacity': 1}}), {'opacity': 1});
    // A loop starts only from what enterFrom moves away from rest.
    expect(from({'opacity': 0, 'duration': 300, 'loop': 'restart', 'enterFrom': {'opacity': 1}}), isEmpty);
  });

  test('motion bindings: paused reads loosely, keyframes from JSON text', () {
    var n = _node({
      'motion': {'rotate': 5, 'loop': 'restart', 'duration': 400},
      'bind': {'motion.paused': r'${p}', 'motion.keyframes': r'${k}'},
    });
    expect(n.bind, {'animations.loop.paused': r'${p}', 'animations.loop.params.frames': r'${k}'});
    n = BindPaths.apply(n, 'animations.loop.paused', 1);
    expect(n.behaviors.animations.single.paused, isTrue);
    n = BindPaths.apply(n, 'animations.loop.params.frames', '[{"t": 0.4, "translateY": -60}]');
    final track = n.behaviors.animations.single.expanded.tracks.firstWhere((t) => t.id == 'translateY');
    expect(track.keyframes, [const Keyframe(at: 0.4, value: -60.0)]);
    expect(track.interpolation, KeyframeInterpolation.monotoneCubic);
  });

  test('path helpers', () {
    expect(PathFollow.wrap(1.25), closeTo(0.25, 1e-9));
    expect(PathFollow.wrap(-0.25), closeTo(0.75, 1e-9));
    expect(PathFollow.wrap(1), 1);
    expect(Motion.uprightAngle(3.0), closeTo(3.0 - 3.141592653589793, 1e-9));
  });

  test('loop phase and lag; effect cycles', () {
    // A loop's lag folds into its phase (a share of the whole loop).
    final l = AnimationPresets.fromLoop({'type': 'fade', 'duration': 500, 'reverse': true, 'phase': 0.3, 'lag': 100}, 0)!;
    expect(l.cycleMs, 1000);
    expect(l.phase, closeTo(0.2, 1e-9));
    expect(NodeAnimation.fromJson(l.toJson()), l);
    final e = AnimationPresets.fromEffect({'name': 'no', 'type': 'shake', 'cycles': 3}, 0)!;
    expect(e.params['cycles'], 3);
    expect(e.toJson()['params'], {'cycles': 3});
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
    expect(p.spring.bounce, 0.4);
    expect(p.spring.duration, 600);
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
    final b = n.behaviors;
    // A drag that stays is a pan.
    expect(b.pan!.release, PanRelease.stay);
    expect(b.pan!.hasBounds, isTrue);
    expect(b.pan!.minY, -560);
    expect(b.pan!.physics!.spring.duration, 420);
    expect(b.draggable!.dragAnchor, DragAnchor.center);
    expect(b.dropTarget!.slotSize, DropSlotSize.node);
    expect(b.dropTarget!.slotWhenRefused, isFalse);
    expect(_node(n.toJson()), n);
    // An insertion bar in the gap between items, taking no room.
    final bar = Node.fromJson({'type': 'box', 'dropTarget': {'slot': 'node', 'slotNodeId': 'bar', 'slotSize': 'inGap'}}, id: 'n')!;
    expect(bar.behaviors.dropTarget!.slotSize, DropSlotSize.inGap);
    expect(_node(bar.toJson()), bar);
    expect(const DragSource(returnSpring: null).effectivePhysics, isNull);
  });

  test('drag track: new settings, parked, endless, double tap', () {
    const t = Track(
      shape: TrackShape.arc,
      min: 1,
      max: 5,
      step: 1,
      parkedProgress: -0.125,
      doubleTapValues: [5, 3],
      clamp: true,
    );
    expect(t.restProgressOf(double.nan), -0.125);
    expect(t.restProgressOf(0), -0.125);
    expect(t.restProgressOf(3), 0.5);
    expect(t.doubleTapTarget(5), 3);
    expect(t.doubleTapTarget(2), 5);
    const e = Track(shape: TrackShape.arc, max: 40, clamp: false, step: 1);
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
    final track = Track.fromJson(j)!;
    // Read into the new shape (docs/design/04-drag-and-track.md): gain folds
    // into pixelsPerRange, momentum is physics, keyboard off is keyStep 0,
    // write off drops the variable (a bound value shows it), a view box
    // without a path draws nothing.
    expect(track.toJson(), {
      'value': 3,
      'input': 'both',
      'hitArea': 'parent',
      'pixelsPerRange': 400,
      'keyStep': 0,
      'relative': true,
      'units': 'parent',
      'detent': 0.35,
      'overscroll': 0.35,
      'physics': {'friction': 0.9257},
      'settle': 250,
      'settleCurve': 'spring',
      'snap': 120,
      'snapCurve': 'elasticOut',
      'fineStep': 0.1,
      'fineHold': 500,
      'fineVariable': 'fine',
      'smooth': true,
    });
    expect(Track.fromJson(track.toJson()), track);
    expect(track.effectiveKeyStep, isNull);
    expect(track.usesViewBox, isFalse);
    expect(Track.fromJson({'path': 'M0 0 L10 0', 'viewBoxWidth': 100, 'viewBoxHeight': 50})!.usesViewBox, isTrue);
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
    expect(n.behaviors.flip!.axis, FlipAxis.x);
    expect(n.behaviors.tilt!.max.rotateX, 6);
    expect(n.behaviors.transformGesture!.handles!.snapAngle, 15);
    expect(n.behaviors.hero!.placeholder, HeroPlaceholder.source);
    expect(n.behaviors.hero!.flight.crossFades, isTrue);
    final out = n.toJson();
    for (final k in j.keys) {
      expect(out[k], j[k], reason: k);
    }
    // zoomable is a transform gesture's first form.
    expect(_node({'zoomable': true}).behaviors.effectiveTransformGesture, TransformGesture.zoomable);
    expect(_node({'flip': <String, Object?>{}}).toJson()['flip'], isEmpty);
  });

  test('a bound switch of a drag, a drag source and a drop target reads loosely', () {
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
