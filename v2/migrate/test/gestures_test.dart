// The behaviours v1 master added, migrated: motion's shimmer, arc, phase,
// pause and path pacing; pulse phases; effect cycles; drag physics,
// bounds and drop slots; drag tracks' new settings; flip, tilt, transform
// gestures; hero placeholders and flights; a node's insert key. Each lands
// on its v2 key, with nothing left under `v1`.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

Map<String, Object?> page(Map<String, Map<String, Object?>> nodes) => {
      'rootNode': {'children': ['c']},
      'c': {'id': 'c', 'type': 'canvas', 'name': 'C', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 300],
            'properties': {'bodyId': 'f'}, 'children': ['f']},
      'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 300],
            'children': [for (final k in nodes.keys) if (nodes[k]!['parentID'] == 'f') k]},
      for (final e in nodes.entries) e.key: {'id': e.key, 'name': e.key, 'basicBoxLocal': [0, 0, 50, 50], ...e.value},
    };

/// Migrates [nodes] (all under the body), returning the v2 nodes and
/// checking nothing of theirs was left unmapped.
Map<String, Object?> migrated(Map<String, Map<String, Object?>> nodes) {
  final report = MigrationReport();
  final v2 = migrateDocument(page({
    for (final e in nodes.entries) e.key: {'parentID': 'f', ...e.value},
  }), report: report);
  final out = v2['nodes'] as Map<String, Object?>;
  for (final id in nodes.keys) {
    expect((out[id] as Map)['v1'], isNull, reason: '$id left ${(out[id] as Map)['v1']}');
  }
  expect(report.unmapped.keys.where((k) => k != 'canvas.createdTimestamp'), isEmpty);
  return out;
}

Map node(Map<String, Object?> nodes, String id) => nodes[id] as Map;

void main() {
  test('motion: shimmer, arc, phase, paused, path pacing, swing, named values', () {
    const motion = MotionModel(
      loop: MotionLoop.swing,
      rotate: 20,
      durationMs: 1200,
      arc: 0.25,
      paused: true,
      phase: 0.5,
      path: 'M0 0 L100 0',
      pathPacing: MotionPathPacing.area,
      pathFocusX: 10,
      pathFocusY: -4,
      pathWrap: true,
      orientToPath: true,
      orientUpright: true,
      shimmer: MotionShimmer(color: '#FFCC00', durationMs: 900, angle: 90),
    );
    final json = Map<String, Object?>.from(motion.toJson());
    // A value named on purpose at its default (an entrance from full opacity).
    json['enterFrom'] = {'opacity': 1};
    final out = migrated({
      'r': {'type': 'rectangle', 'motion': json},
    });
    expect(node(out, 'r')['motion'], {
      'rotate': 20,
      'duration': 1200,
      'loop': 'swing',
      'enterFrom': {'opacity': 1, 'pathProgress': 0},
      'path': 'M0 0 L100 0',
      'orientToPath': true,
      'orientUpright': true,
      'arc': 0.25,
      'paused': true,
      'phase': 0.5,
      'pathPacing': 'area',
      'pathFocusX': 10,
      'pathFocusY': -4,
      'pathWrap': true,
      'shimmer': {'color': '#FFFFCC00', 'duration': 900, 'angle': 90},
    });
  });

  test('pulse phase and delay; effect cycles', () {
    final out = migrated({
      'p': {
        'type': 'rectangle',
        'loopAnimation': const LoopAnimation(type: LoopAnimationType.spin).toJson(),
        'pulse': const PulseModel(minOpacity: 0.3, phase: 0.15, delayMs: 160).toJson(),
        'effectAnimations': [
          const EffectAnimation(name: 'no', type: EffectAnimationType.shake, cycles: 3).toJson(),
        ],
        'variables': {'pulsePhase': r'${= index * 0.15}', 'pulseDelayMs': r'${= index * 160}'},
      },
    });
    final p = node(out, 'p');
    expect((p['loops'] as List)[1], {
      'type': 'fade', 'duration': 1100, 'reverse': true, 'curve': 'easeInOut', 'opacityFrom': 0.3, //
      'phase': 0.15, 'lag': 160,
    });
    expect((p['effectAnimations'] as List).single['cycles'], 3);
    expect(p['bind'], {'loops[1].phase': r'${= index * 0.15}', 'loops[1].lag': r'${= index * 160}'});
  });

  test('drag: physics, bounds, limits; drag source and drop target settings', () {
    final out = migrated({
      'd': {
        'type': 'rectangle',
        'drag': const DragModel(
          axis: DragAxis.vertical,
          release: DragRelease.stay,
          bounds: GestureBounds.contain,
          minY: -560,
          maxY: 0,
          physics: PhysicsModel(
            bounce: 0.12,
            durationMs: 420,
            snap: SnapModel(points: [SnapPoint(), SnapPoint(y: -280)]),
          ),
        ).toJson(),
        'draggable': const DraggableModel(
          group: 'g',
          feedbackAnchor: FeedbackAnchor.center,
          physics: PhysicsModel(fling: false, durationMs: 300),
        ).toJson(),
        'dropTarget': const DropTargetModel(slotSize: DropSlotSize.node, slotWhenRefused: false).toJson(),
      },
    });
    final d = node(out, 'd');
    expect(d['drag'], {
      'axis': 'vertical',
      'release': 'stay',
      'physics': {
        'bounce': 0.12,
        'duration': 420,
        'snap': {
          'points': [
            [0, 0],
            [0, -280],
          ],
        },
      },
      'bounds': 'contain',
      'minY': -560,
      'maxY': 0,
    });
    expect(d['draggable'], {
      'group': 'g',
      'feedbackAnchor': 'center',
      'physics': {'duration': 300, 'fling': false},
    });
    expect(d['dropTarget'], {'slotSize': 'node', 'slotWhenRefused': false});
  });

  test('drag track: new settings and bindings', () {
    final out = migrated({
      't': {
        'type': 'rectangle',
        'drag': DragModel(
          track: const DragTrackModel(
            shape: DragTrackShape.arc,
            variable: 'dial',
            max: 40,
            step: 1,
            input: DragTrackInput.both,
            orientUpright: true,
            detent: 0.35,
            overscroll: 0.2,
            settleMs: 250,
            settleCurve: MotionCurve.spring,
            settleStiffness: 260,
            settleDamping: 27.7,
            parkedProgress: -0.125,
            keyboard: false,
            viewBoxWidth: 100,
            viewBoxHeight: 50,
            relative: true,
            wheelStep: 2,
            doubleTapValues: [10, 20],
            keyStep: 5,
            hitArea: DragTrackHitArea.parent,
            units: DragTrackUnits.parent,
            fineStep: 0.1,
            finePixelsPerRange: 900,
            fineHoldMs: 500,
            fineVariable: 'fine',
            snapMs: 120,
            snapCurve: 'elasticOut',
            write: false,
            endless: true,
            momentum: true,
            friction: 3,
            smooth: true,
            gain: 0.5,
          ),
        ).toJson(),
        'variables': {
          'track.value': r'${item.kelvin}',
          'track.x2': r'${= parent.width - 26}',
          'track.step': '0.5',
          'dragTrack.endAngle': r'${= maxDays / unitDays * 360}',
          'track.defaultValue': r'${item.default}',
          'track.gain': r'${sensitivity}',
        },
      },
    });
    final t = node(out, 't');
    expect((t['drag'] as Map)['track'], {
      'variable': 'dial',
      'shape': 'arc',
      'max': 40,
      'step': 1,
      'input': 'both',
      'orientUpright': true,
      'detent': 0.35,
      'overscroll': 0.2,
      'settle': 250,
      'settleCurve': 'spring',
      'settleStiffness': 260,
      'settleDamping': 27.7,
      'parkedProgress': -0.125,
      'keyboard': false,
      'viewBoxWidth': 100,
      'viewBoxHeight': 50,
      'relative': true,
      'wheelStep': 2,
      'doubleTapValues': [10, 20],
      'keyStep': 5,
      'hitArea': 'parent',
      'units': 'parent',
      'fineStep': 0.1,
      'finePixelsPerRange': 900,
      'fineHold': 500,
      'fineVariable': 'fine',
      'snap': 120,
      'snapCurve': 'elasticOut',
      'write': false,
      'endless': true,
      'momentum': true,
      'friction': 3,
      'smooth': true,
      'gain': 0.5,
    });
    expect(t['bind'], {
      'drag.track.value': r'${item.kelvin}',
      'drag.track.x2': r'${= parent.width - 26}',
      'drag.track.step': '0.5',
      'drag.track.endAngle': r'${= maxDays / unitDays * 360}',
      'drag.track.defaultValue': r'${item.default}',
      'drag.track.gain': r'${sensitivity}',
    });
  });

  test('flip, tilt, transform gesture, hero placeholder and flights, insert key', () {
    final out = migrated({
      'card': {
        'type': 'frame',
        'key': 'content',
        'flip': const FlipModel(axis: FlipAxis.x, dragToFlip: true, variable: 'back',
            spring: TransitionSpring(damping: 20)).toJson(),
        'tilt': const TiltModel(max: MotionModel(rotateX: 6, rotateY: 6), hover: false, resetMs: 250).toJson(),
        'transformGesture': const TransformGestureModel(
          rotate: true,
          bounds: GestureBounds.contain,
          wheel: WheelZoom.zoom,
          scaleVariable: 'zoom',
          physics: PhysicsModel(fling: false, bounce: 0.2, durationMs: 300),
          handles: TransformHandlesModel(snapAngle: 15, color: '#000000'),
        ).toJson(),
        'heroTag': 'photo',
        'heroFlight': 'containerTransform',
        'heroPlaceholder': 'source',
        'variables': {'flip.flipped': r'${showBack}', 'transform.scale': r'${zoomLevel}'},
      },
      'arc': {'type': 'rectangle', 'heroTag': 'planet', 'heroFlight': 'arc'},
    });
    final c = node(out, 'card');
    expect(c['key'], 'content');
    expect(c['flip'], {
      'axis': 'x',
      'dragToFlip': true,
      'variable': 'back',
      'spring': {'damping': 20},
    });
    expect(c['tilt'], {
      'max': {'rotateX': 6, 'rotateY': 6},
      'hover': false,
      'reset': 250,
    });
    expect(c['transformGesture'], {
      'rotate': true,
      'bounds': 'contain',
      'wheel': 'zoom',
      'physics': {'bounce': 0.2, 'duration': 300, 'fling': false},
      'scaleVariable': 'zoom',
      'handles': {'snapAngle': 15, 'color': '#FF000000'},
    });
    expect(c['hero'], {'tag': 'photo', 'flight': 'containerTransform', 'placeholder': 'source'});
    expect(c['bind'], {'flip.flipped': r'${showBack}', 'transformGesture.scale': r'${zoomLevel}'});
    expect(node(out, 'arc')['hero'], {'tag': 'planet', 'flight': 'arc'});
  });
}
