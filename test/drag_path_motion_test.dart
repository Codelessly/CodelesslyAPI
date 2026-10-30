import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('DragModel', () {
    test('defaults serialize to an empty map and read back', () {
      const drag = DragModel();
      expect(drag.toJson(), isEmpty);
      expect(DragModel.fromJson({}), drag);
    });

    test('round-trips a swipe card drag', () {
      const drag = DragModel(
        release: DragRelease.dismiss,
        directions: [DragDirection.left, DragDirection.right, DragDirection.up],
        rotateFactor: 15,
        originY: 1.6,
        distanceThreshold: 0.3,
        velocityThreshold: 700,
        resistance: 0.6,
        snapCurve: MotionCurve.elasticOut,
        flyOutMs: 280,
        shakeWhenDisabled: true,
      );
      final json = drag.toJson();
      expect(json['release'], 'dismiss');
      expect(json['directions'], ['left', 'right', 'up']);
      expect(DragModel.fromJson(json), drag);
    });

    test('canDismiss follows release, directions and axis', () {
      const drag = DragModel(
        release: DragRelease.dismiss,
        axis: DragAxis.horizontal,
        directions: [DragDirection.left, DragDirection.up],
      );
      expect(drag.canDismiss(DragDirection.left), isTrue);
      expect(drag.canDismiss(DragDirection.right), isFalse);
      expect(drag.canDismiss(DragDirection.up), isFalse, reason: 'off axis');
      expect(
        const DragModel().canDismiss(DragDirection.left),
        isFalse,
        reason: 'snap back never dismisses',
      );
    });

    test('directions map to swipe triggers', () {
      expect(DragDirection.left.swipeTrigger, TriggerType.swipeLeft);
      expect(DragDirection.up.swipeTrigger, TriggerType.swipeUp);
    });

    test('a node keeps its drag through JSON', () {
      final node = FrameNode(
        id: 'card',
        name: 'Card',
        basicBoxLocal: NodeBox(0, 0, 300, 400),
        retainedOuterBoxLocal: NodeBox(0, 0, 300, 400),
        children: const [],
      )..drag = const DragModel(release: DragRelease.dismiss, rotateFactor: 15);
      final copy = FrameNode.fromJson(node.toJson());
      expect(copy.drag, node.drag);
    });
  });

  group('MotionModel paths and faces', () {
    test('round-trips backface, path and orientation', () {
      const motion = MotionModel(
        backfaceHidden: true,
        path: 'M0 0 C 80 -160 240 -200 300 -40',
        pathProgress: 0.5,
        orientToPath: true,
        curve: MotionCurve.spring,
      );
      final json = motion.toJson();
      expect(json['backfaceHidden'], isTrue);
      expect(json['curve'], 'spring');
      expect(MotionModel.fromJson(json), motion);
      expect(motion.hasPath, isTrue);
      expect(motion.hasTransform, isTrue);
    });

    test('pathProgress is bindable and rests at 0', () {
      expect(MotionModel.properties, contains('pathProgress'));
      final moved = MotionModel.none.withValue('pathProgress', 0.75);
      expect(moved.valueOf('pathProgress'), 0.75);
      expect(moved.atRest.pathProgress, 0);
    });

    test('an empty path is no path', () {
      expect(const MotionModel(path: '  ').hasPath, isFalse);
    });
  });

  group('ControlDragAction', () {
    test('round-trips through ActionModel.fromJson', () {
      final action = ControlDragAction(
        nodeId: 'card',
        command: DragCommand.returnFrom,
        direction: DragDirection.left,
      );
      final copy = ActionModel.fromJson(action.toJson());
      expect(copy, isA<ControlDragAction>());
      expect(copy, action);
      expect(ActionType.controlDrag.prettify, 'Control Drag');
    });
  });

  group('SpeakAction', () {
    test('round-trips and omits defaults', () {
      final action = SpeakAction(text: r'${card.front}', language: 'es-ES', rate: 0.8);
      final json = action.toJson();
      expect(json.containsKey('pitch'), isFalse);
      expect(ActionModel.fromJson(json), action);
      expect(ActionModel.fromJson(SpeakAction(stop: true).toJson()), SpeakAction(stop: true));
    });
  });
}
