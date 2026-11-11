import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final nodeJson = <String, Object?>{
    'id': 'n',
    'type': 'box',
    'layout': {'width': 40, 'height': 40},
    'motion': {
      'rotate': -3.5,
      'translateX': 10,
      'duration': 900,
      'curve': 'easeOutBack',
      'enter': true,
      'enterFrom': {'opacity': 0, 'translateY': 20},
      'keyframes': [
        {'t': 0.5, 'scale': 1.2},
      ],
    },
    'scale': 1.15,
    'loops': [
      {'type': 'pulse', 'duration': 1400, 'scaleFrom': 0.65, 'opacityFrom': 0.35, 'opacityTo': 0},
      {'type': 'fade', 'duration': 1100, 'reverse': true, 'curve': 'easeInOut', 'opacityFrom': 0.45},
    ],
    'transitions': {
      'style': {'duration': 120},
      'opacity': {'duration': 1100, 'curve': 'easeInOut'},
    },
    'inkWell': {'overlayColor': '#1F000000', 'splashColor': '#1F000000'},
    'states': {
      'hovered': {
        'n': {
          'decoration': {
            'fills': [
              {'color': '#FFEDE5D3'}
            ]
          }
        },
        't': {
          'props': {'text': 'Hovered!'}
        },
      },
    },
    'tooltip': 'Hi',
    'ignorePointer': true,
    'zoomable': true,
    'floating': true,
    'hero': {'tag': 'card', 'flight': 'morphCorners'},
    'flightKey': 'tile-1',
    'draggable': {'group': 'tiles', 'data': 'a'},
    'dropTarget': {
      'accepts': ['tiles'],
      'hoverDelay': 200
    },
    'drag': {
      'release': 'dismiss',
      'directions': ['left', 'right'],
      'track': {'variable': 'volume', 'shape': 'arc', 'max': 10}
    },
    'reveal': {'alignment': 0.3},
    'strokePath': {
      'points': [
        [0, 10],
        [1, 10]
      ],
      'color': '#FFFF5500',
      'dashPattern': [6, 4]
    },
    'effectAnimations': [
      {'name': 'shake', 'type': 'shake', 'duration': 400}
    ],
    'particles': {
      'count': 20,
      'colors': ['#FFFF0000']
    },
    'textDirection': 'rtl',
    'custom': 1,
  };

  test('behaviors round-trip, flat in the node', () {
    final n = Node.fromJson(nodeJson)!;
    final b = n.behaviors;
    expect(b.motion!.rotate, -3.5);
    expect(b.motion!.enterFrom!.opacity, 0);
    expect(b.loops, hasLength(2));
    expect(b.transitions.opacity!.curve, AnimationCurve.easeInOut);
    expect(b.inkWell!.overlayColor, const Color(0x1F000000));
    expect(b.states.patchFor('t', {WidgetState.hovered}), {
      'props': {'text': 'Hovered!'}
    });
    expect(b.states.patchFor('t', {WidgetState.pressed}), isNull);
    expect(b.hero, const HeroTag('card', flight: HeroFlightShuttle.morphCorners));
    expect(b.drag!.directions, [DragDirection.left, DragDirection.right]);
    expect(b.drag!.track!.shape, DragTrackShape.arc);
    expect(b.strokePath!.points.last, const Offset(1, 10));
    expect(b.particles!.colors, [const Color(0xFFFF0000)]);
    expect(b.textDirection, TextDirection.rtl);
    expect(n.extra, {'custom': 1});
    expect(jsonDecode(jsonEncode(n.toJson())), jsonDecode(jsonEncode(nodeJson)));
    expect(Node.fromJson(n.toJson()), n);
  });

  test('defaults are omitted; bad values fall back', () {
    expect(const Behaviors().isNone, isTrue);
    expect(Node.fromJson({'type': 'box'})!.behaviors, Behaviors.none);
    final n = Node.fromJson({
      'type': 'box',
      'motion': {'rotate': 'x', 'curve': 'nope', 'duration': -5},
      'scale': -1,
      'loops': [3, {}],
      'states': {'hovered': 'x', 'nope': {}},
      'hero': '',
      'textDirection': 4,
    })!;
    expect(n.behaviors.motion, Motion.none);
    expect(n.behaviors.motion!.toJson(), isEmpty);
    expect(n.behaviors.scale, 1);
    expect(n.behaviors.loops.single.type, LoopAnimationType.pulse);
    expect(n.behaviors.states.isEmpty, isTrue);
    expect(n.behaviors.hero, isNull);
    expect(n.behaviors.textDirection, isNull);
    expect(n.toJson()..remove('layout'), {'id': '', 'type': 'box', 'motion': {}, 'loops': [{'type': 'pulse'}]});
  });

  test('a loop rests on its first frame', () {
    const halo = LoopAnimation(type: LoopAnimationType.pulse, scaleFrom: 0.65, opacityFrom: 0.35, opacityTo: 0);
    expect(halo.poseAt(0), (scale: 0.65, opacity: 0.35, turns: 0.0, dy: 0.0));
    expect(halo.poseAt(1).scale, 1);
    expect(const LoopAnimation(type: LoopAnimationType.scale, scaleFrom: 0.5, enabled: false).poseAt(0).scale, 1);
    final bob = const LoopAnimation(type: LoopAnimationType.bob, distance: 10).poseAt(0.5);
    expect(bob.dy, closeTo(-10, 1e-9));
  });

  test('motion: rest, entrance start, keyframes', () {
    const m = Motion(rotate: 30, translateX: 10, enterFrom: Motion(opacity: 0));
    expect(m.hasTransform, isTrue);
    expect(m.atRest.hasTransform, isFalse);
    expect(m.entranceStart.opacity, 0);
    expect(m.entranceStart.rotate, 30);
    expect(Motion.lerp(m.atRest, m, 0.5).rotate, 15);
    const k = Motion(scale: 2, keyframes: [MotionKeyframe(t: 0.5, scale: 3)]);
    expect(Motion.lerp(k.atRest, k, 0.5).scale, 3);
    expect(AnimationCurve.easeInOut.transform(0.5), closeTo(0.5, 0.01));
    expect(AnimationCurve.parse('Ease Out Back'), AnimationCurve.easeOutBack);
  });

  test('state patches merge into a node', () {
    final n = Node.fromJson({
      'id': 't',
      'type': 'text',
      'props': {'text': 'A', 'maxLines': 2}
    })!;
    final p = n.patched({
      'props': {'text': 'B', 'maxLines': null}
    });
    expect(p.prop(TextProps.text), 'B');
    expect(p.toJson()['props'], {'text': 'B'});
    expect(diffPatch(n.toJson(), p.toJson()), {
      'props': {'text': 'B', 'maxLines': null}
    });
    expect(mergePatch({'a': 1}, {'a': null}, keepNulls: true), {'a': null});
  });

  test('a type without a box decoration keeps its blurs only', () {
    final t = Node.fromJson({
      'type': 'text',
      'decoration': {
        'fills': [
          {'color': '#FF000000'}
        ],
        'effects': [
          {'type': 'layerBlur', 'blurRadius': 2},
          {'type': 'dropShadow', 'color': '#FF000000'},
        ],
      },
    })!;
    expect(t.decoration.fills, isEmpty);
    expect([for (final e in t.decoration.effects) e.type], [EffectType.layerBlur]);
  });

  test('bound hero tags and effect and particle cues', () {
    final n = Node.fromJson({
      'type': 'box',
      'hero': {'tag': '', 'flight': 'arc'},
      'effectAnimations': [
        {'name': 'pop', 'type': 'pop'},
        {'name': 'nudge', 'type': 'shake'},
      ],
      'particles': {'count': 10},
    }, id: 'n')!;
    final tagged = BindPaths.apply(n, 'hero.tag', 'pass-7');
    expect(tagged.behaviors.hero, const HeroTag('pass-7', flight: HeroFlightShuttle.arc));
    final cued = BindPaths.apply(n, 'effectAnimations[1].playKey', 3);
    expect(cued.behaviors.effectAnimations[1].playKey, '3');
    expect(cued.behaviors.effectAnimations[0].playKey, isNull);
    expect(BindPaths.apply(n, 'effectAnimations[1].delay', 250).behaviors.effectAnimations[1].delay, 250);
    expect(BindPaths.apply(n, 'particles.playKey', 'w1').behaviors.particles!.playKey, 'w1');
    expect(EffectAnimation.fromJson(cued.behaviors.effectAnimations[1].toJson())!.playKey, '3');
  });
}
