import 'dart:convert';
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Encodes to a JSON string and back, as Firestore and the MCP do.
Map _wire(Map json) => jsonDecode(jsonEncode(json)) as Map;

FrameNode _frame() => FrameNode(
  id: 'n',
  name: 'N',
  basicBoxLocal: NodeBox(0, 0, 200, 100),
  children: [],
);

void main() {
  group('PhysicsModel', () {
    test('defaults are omitted and round-trip', () {
      expect(const PhysicsModel().toJson(), isEmpty);
      const PhysicsModel physics = PhysicsModel(
        stiffness: 500,
        damping: 20,
        mass: 2,
        friction: 0.6,
        overscroll: 0,
        fling: false,
        snap: SnapModel(
          kind: SnapKind.grid,
          gridX: 40,
          gridY: 40,
          projectVelocity: false,
        ),
      );
      final PhysicsModel back = PhysicsModel.fromJson(_wire(physics.toJson()));
      expect(back, physics);
    });

    test('presets read by name and can be overridden', () {
      final PhysicsModel bouncy = PhysicsModel.fromJson({'preset': 'bouncy'});
      expect(bouncy, PhysicsModel.presets['bouncy']);
      final PhysicsModel tuned = PhysicsModel.fromJson({
        'preset': 'snappy',
        'friction': 0.5,
      });
      expect(tuned.bounce, 0.15);
      expect(tuned.durationMs, 300);
      expect(tuned.friction, 0.5);
    });

    test('bounce and duration match withDurationAndBounce', () {
      const PhysicsModel p = PhysicsModel(bounce: 0.3, durationMs: 300);
      const double t = 0.3;
      final double k = 4 * math.pi * math.pi / (t * t);
      expect(p.effectiveStiffness, closeTo(k, 1e-9));
      expect(p.effectiveDamping, closeTo(0.7 * 2 * math.sqrt(k), 1e-9));
      // An overdamped (negative) bounce.
      const PhysicsModel slow = PhysicsModel(bounce: -0.5, durationMs: 300);
      expect(slow.effectiveDamping, closeTo(2 * 2 * math.sqrt(k), 1e-9));
      // Plain springs report their own values.
      expect(const PhysicsModel().effectiveStiffness, 380);
      expect(const PhysicsModel().effectiveDamping, 32);
    });

    test('a fling projects to x − v / ln(drag)', () {
      const PhysicsModel p = PhysicsModel(friction: 0.865);
      expect(p.projectFling(0, 1000), closeTo(-1000 / math.log(0.135), 1e-9));
      // Too slow to fling.
      expect(p.projectFling(10, 20), 10);
      // No fling at all.
      expect(const PhysicsModel(fling: false).projectFling(5, 3000), 5);
      // Clamped to the fastest fling.
      expect(
        p.projectFling(0, 1e6),
        closeTo(p.projectFling(0, p.maxFlingVelocity), 1e-9),
      );
    });

    test('snap points read numbers, pairs and maps', () {
      final SnapModel snap = SnapModel.fromJson({
        'points': [
          -300,
          [10, 20],
          {'y': -600},
        ],
      });
      expect(snap.points, const [
        SnapPoint(x: -300, y: -300),
        SnapPoint(x: 10, y: 20),
        SnapPoint(y: -600),
      ]);
    });
  });

  group('TransformGestureModel', () {
    test('a node without one writes no key; full model round-trips', () {
      final FrameNode node = _frame();
      expect(node.toJson().containsKey('transformGesture'), isFalse);
      node.transformGesture = const TransformGestureModel(
        target: TransformTarget.content,
        pan: TransformPan.whenZoomed,
        rotate: true,
        minScale: 0.5,
        maxScale: 8,
        bounds: GestureBounds.contain,
        doubleTapScale: 3,
        wheel: WheelZoom.zoom,
        rotationSnap: 15,
        physics: PhysicsModel(bounce: 0.2, durationMs: 400),
        xVariable: 'x',
        yVariable: 'y',
        scaleVariable: 'zoom',
        rotationVariable: 'angle',
        scaleXVariable: 'sx',
        scaleYVariable: 'sy',
        handles: TransformHandlesModel(
          edges: true,
          aspectLock: false,
          snapAngle: 15,
          minWidth: 40,
          maxWidth: 600,
          color: '#FF0000',
          selectionVariable: 'selected',
          selectionKey: r'${item.id}',
        ),
      );
      final BaseNode back = NodeJsonConverter().fromJson(_wire(node.toJson()))!;
      expect(back.transformGesture, node.transformGesture);
      expect(back.effectiveTransformGesture, node.transformGesture);
    });

    test('defaults are omitted', () {
      expect(const TransformGestureModel().toJson(), isEmpty);
      expect(const TransformHandlesModel().toJson(), isEmpty);
      expect(
        const TransformGestureModel(handles: TransformHandlesModel()).toJson(),
        {'handles': <String, dynamic>{}},
      );
    });

    test('unknown enum values fall back instead of throwing', () {
      final TransformGestureModel model = TransformGestureModel.fromJson({
        'target': 'galaxy',
        'pan': 'sometimes',
        'bounds': 'weird',
        'wheel': 'spin',
      });
      expect(model.target, TransformTarget.node);
      expect(model.pan, TransformPan.always);
      expect(model.bounds, GestureBounds.cover);
      expect(model.wheel, WheelZoom.ctrlZoom);
    });

    test('zoomable: true reads as the zoomable transform gesture', () {
      final BaseNode node = NodeJsonConverter().fromJson({
        'type': 'frame',
        'id': 'photo',
        'name': 'Photo',
        'basicBoxLocal': NodeBox(0, 0, 300, 200).toJson(),
        'children': <String>[],
        'zoomable': true,
      })!;
      expect(node.transformGesture, isNull);
      expect(node.effectiveTransformGesture, TransformGestureModel.zoomable);
      expect(node.effectiveTransformGesture!.target, TransformTarget.content);
      expect(node.effectiveTransformGesture!.pansAt(1), isFalse);
      expect(node.effectiveTransformGesture!.pansAt(2), isTrue);
      // An explicit model wins over the switch.
      node.transformGesture = const TransformGestureModel(maxScale: 2);
      expect(node.effectiveTransformGesture!.maxScale, 2);
    });

    test('bound variables list only the names that are set', () {
      const TransformGestureModel model = TransformGestureModel(
        scaleVariable: ' zoom ',
        rotationVariable: 'angle',
      );
      expect(model.boundVariables, {'scale': 'zoom', 'rotation': 'angle'});
    });
  });

  group('DragModel physics', () {
    test('physics, bounds and limits round-trip', () {
      const DragModel drag = DragModel(
        axis: DragAxis.vertical,
        release: DragRelease.stay,
        bounds: GestureBounds.contain,
        minY: -560,
        maxY: 0,
        physics: PhysicsModel(
          snap: SnapModel(points: [SnapPoint(), SnapPoint(y: -280)]),
        ),
      );
      final DragModel back = DragModel.fromJson(_wire(drag.toJson()));
      expect(back, drag);
      expect(back.hasBounds, isTrue);
    });

    test('old JSON loads unchanged and maps to physics', () {
      // A drag saved before physics existed.
      final DragModel old = DragModel.fromJson({
        'axis': 'horizontal',
        'release': 'snapBack',
        'snapBackMs': 600,
      });
      expect(old.physics, isNull);
      expect(old.bounds, GestureBounds.none);
      expect(old.hasBounds, isFalse);
      // The default spring curve maps to a spring of the same time.
      expect(
        old.effectivePhysics,
        const PhysicsModel(bounce: 0.25, durationMs: 600, fling: false),
      );
      // Its JSON still writes no physics keys.
      expect(old.toJson().containsKey('physics'), isFalse);
      expect(old.toJson()['snapBackMs'], 600);

      // A curve-timed snap back keeps its curve.
      final DragModel curved = DragModel.fromJson({'snapCurve': 'easeOut'});
      expect(curved.effectivePhysics, isNull);

      // The very first (Meridian) format still migrates.
      final DragModel legacy = DragModel.fromJson({'dismissDistance': 0.4});
      expect(legacy.release, DragRelease.dismiss);
      expect(legacy.physics, isNull);
    });

    test('explicit physics wins over the legacy fields', () {
      const DragModel drag = DragModel(
        snapCurve: MotionCurve.spring,
        physics: PhysicsModel(stiffness: 100),
      );
      expect(drag.effectivePhysics!.stiffness, 100);
    });

    test('copyWith clears physics and limits', () {
      const DragModel drag = DragModel(physics: PhysicsModel(), minX: 3);
      expect(drag.copyWith(clearPhysics: true).physics, isNull);
      expect(drag.copyWith(clearLimits: true).minX, isNull);
      expect(drag.copyWith(maxX: 9).minX, 3);
    });
  });

  group('DraggableModel physics', () {
    test('returnSpring maps into the shared physics model', () {
      final DraggableModel old = DraggableModel.fromJson({
        'group': 'tile',
        'springStiffness': 300,
        'springDamping': 18,
      });
      expect(old.physics, isNull);
      expect(
        old.effectivePhysics,
        const PhysicsModel(stiffness: 300, damping: 18, fling: false),
      );
      expect(
        DraggableModel.fromJson({'returnSpring': false}).effectivePhysics,
        isNull,
      );
    });

    test('physics round-trips and wins', () {
      const DraggableModel model = DraggableModel(
        group: 'tile',
        physics: PhysicsModel(bounce: 0.4, durationMs: 600),
      );
      final DraggableModel back = DraggableModel.fromJson(
        _wire(model.toJson()),
      );
      expect(back, model);
      expect(back.effectivePhysics, model.physics);
    });
  });

  group('GesturePresets', () {
    test('every preset parses back onto a node', () {
      for (final MapEntry<String, Map<String, Object?>> preset
          in GesturePresets.all.entries) {
        expect(GesturePresets.names.containsKey(preset.key), isTrue);
        final Map json = _wire({
          'type': 'frame',
          'id': preset.key,
          'name': preset.key,
          'basicBoxLocal': NodeBox(0, 0, 100, 100).toJson(),
          'children': <String>[],
          ...preset.value,
        });
        final BaseNode node = NodeJsonConverter().fromJson(json)!;
        expect(
          node.transformGesture != null || node.drag != null,
          isTrue,
          reason: preset.key,
        );
      }
      final DragModel sheet = DragModel.fromJson(
        GesturePresets.all['bottomSheetFling']!['drag'] as Map,
      );
      expect(sheet.physics!.snap!.points.length, 3);
    });
  });

  group('trigger result docs', () {
    test('every gesture trigger documents its result', () {
      for (final TriggerType type in [
        TriggerType.drag,
        TriggerType.dragEnd,
        TriggerType.pinch,
        TriggerType.wheel,
        TriggerType.doubleTap,
        TriggerType.changed,
        TriggerType.changeEnd,
        ...TriggerType.swipes,
        ...TriggerType.dragSource,
        ...TriggerType.dropTarget,
      ]) {
        expect(type.resultDoc, isNotEmpty, reason: type.name);
      }
      expect(TriggerType.pinch.resultDoc, contains('rotation'));
      expect(TriggerType.pinch.resultDoc, contains('pointerCount'));
      expect(TriggerType.dragEnd.resultDoc, contains('snapIndex'));
    });
  });
}
