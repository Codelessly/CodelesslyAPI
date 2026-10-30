import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  FrameNode frame(Map extra) => FrameNode.fromJson({
    'id': 'f',
    'name': 'F',
    'type': 'frame',
    'basicBoxLocal': {'x': 0, 'y': 0, 'width': 80, 'height': 80},
    ...extra,
  });

  test('draggable and drop target round-trip on a node, omitted by default', () {
    final node = frame({
      'draggable': {
        'group': 'letters',
        'feedbackScale': 1.12,
        'feedbackRotation': -4,
        'whileDragging': 'hidden',
      },
      'dropTarget': {
        'groups': ['letters'],
        'acceptIf': '\${= drop.data.letter == "A"}',
      },
      'flightKey': 'tile-\${item.id}',
    });
    expect(node.draggable!.group, 'letters');
    expect(node.draggable!.whileDragging, DragLeaveBehavior.hidden);
    expect(node.draggable!.returnSpring, isTrue);
    expect(node.dropTarget!.groups, ['letters']);
    expect(node.flightKey, 'tile-\${item.id}');

    final json = node.toJson();
    expect(json['draggable'], {
      'group': 'letters',
      'feedbackScale': 1.12,
      'feedbackRotation': -4.0,
      'whileDragging': 'hidden',
    });
    expect(FrameNode.fromJson(json).dropTarget, node.dropTarget);

    final plain = frame({}).toJson();
    for (final key in ['draggable', 'dropTarget', 'effectAnimations', 'particles', 'flightKey']) {
      expect(plain.containsKey(key), isFalse, reason: key);
    }
  });

  test('effect animations and particles round-trip', () {
    final node = frame({
      'effectAnimations': [
        {'name': 'shake', 'type': 'shake'},
        {'name': 'hop', 'type': 'bounce', 'durationMs': 760, 'originY': 1},
      ],
      'particles': {'count': 60, 'emitMs': 3000, 'shapes': ['star'], 'direction': 180},
    });
    expect(node.effectAnimations.map((e) => e.type), [EffectAnimationType.shake, EffectAnimationType.bounce]);
    expect(node.particles!.shapes, [ParticleShape.star]);
    expect(node.particles!.colors, ParticleEmitter.defaultColors);
    final again = FrameNode.fromJson(node.toJson());
    expect(again.effectAnimations, node.effectAnimations);
    expect(again.particles, node.particles);
    expect(EffectAnimation.preset(EffectAnimationType.bounce).originY, 1);
    expect(EffectAnimation.playKeyVariable('shake'), 'animations.shake.playKey');
  });

  test('spring curve and loop bob/sway round-trip', () {
    const motion = MotionModel(curve: MotionCurve.spring, springStiffness: 500, springDamping: 12);
    final json = motion.toJson();
    expect(json, {'curve': 'spring', 'springStiffness': 500.0, 'springDamping': 12.0});
    expect(MotionModel.fromJson(json), motion);
    expect(MotionModel.fromJson({}).springStiffness, 380);

    final bob = LoopAnimation.preset(LoopAnimationType.bob).copyWith(distance: 14);
    expect(LoopAnimation.fromJson(bob.toJson()), bob);
    expect(LoopAnimation.preset(LoopAnimationType.sway).angle, 4);
  });

  test('drag and drop triggers are offered by frames, rows and text', () {
    for (final t in [...TriggerType.draggableTriggers, ...TriggerType.dropTargetTriggers]) {
      expect(frame({}).triggerTypes, contains(t));
      expect(TriggerModel.fromJson(TriggerModel(type: t).toJson()).type, t);
    }
    expect(TriggerType.dropRejected.prettify, 'Drop Rejected');
  });

  test('speak, play sound and play animation actions round-trip', () {
    final speak = SpeakAction(text: '\${word}', rateValue: '\${= slow ? 0.6 : 0.9}', pitch: 1.15);
    final again = ActionModel.fromJson(speak.toJson()) as SpeakAction;
    expect(again, speak);
    expect(speak.toJson().containsKey('language'), isFalse);

    final sound = PlaySoundAction(preset: SoundPreset.boing);
    expect((ActionModel.fromJson(sound.toJson()) as PlaySoundAction).preset, SoundPreset.boing);

    final play = PlayAnimationAction(nodeId: 'n1', animation: 'particles', nonBlocking: true);
    final p = ActionModel.fromJson(play.toJson()) as PlayAnimationAction;
    expect(p.nodeId, 'n1');
    expect(p.animation, 'particles');
    expect(p.nonBlocking, isTrue);
    expect(ActionType.playAnimation.prettify, 'Play Animation');
  });
}
