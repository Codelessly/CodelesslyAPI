// A legacy motion (50 fields) read as the transform it is now, plus the
// animations, transitions and node values its other keys became
// (docs/design/03-motion.md §6): old JSON in, new model out, and the new
// shape decoding to the same model again.
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

import 'legacy_support.dart';

Node _node(Json j) => legacyNode(j);

NodeAnimation _animation(Node n, String id) => n.behaviors.animations.firstWhere((a) => a.id == id);

/// [n] written and read again is [n] (the new shape is stable).
void _stable(Node n) => expect(Node.fromJson(n.toJson()), n);

void main() {
  group('the pose', () {
    test('originX/Y read as alignment; the pose keys stay', () {
      final m = legacyMotion({'translateX': 4, 'rotateY': 30, 'perspective': 1.5, 'originX': -1, 'originY': 0.5})!;
      expect(m, const Motion(translateX: 4, rotateY: 30, perspective: 1.5, alignment: Alignment(-1, 0.5)));
      expect(m.toJson(), {'translateX': 4, 'rotateY': 30, 'perspective': 1.5, 'alignment': [-1, 0.5]});
      expect(Motion.fromJson(m.toJson()), m);
      // A legacy origin set over the new shape (a state style) wins on its axis.
      expect(legacyMotion({'alignment': [1, 1], 'originY': 0})!.alignment, const Alignment(1, 0));
    });

    test('the flat path keys read as a PathFollow', () {
      final m = legacyMotion({
        'path': 'M0 0 L100 0',
        'pathProgress': 0.25,
        'orientToPath': true,
        'orientUpright': true,
        'uprightMirror': true,
        'pathViewBox': [760, 420],
        'pathWrap': true,
      })!;
      // uprightMirror (uprightFlip) is upright in schema 3.
      expect(m.path, const PathFollow(path: 'M0 0 L100 0', progress: 0.25, orient: PathOrient.upright, viewBox: [760, 420]));
      expect(m.toJson(), {
        'path': {'path': 'M0 0 L100 0', 'viewBox': [760, 420], 'progress': 0.25, 'orient': 'upright'},
      });
      expect(Motion.fromJson(m.toJson()), m);
      expect(legacyMotion({'path': 'M0 0', 'orientToPath': true})!.path!.orient, PathOrient.tangent);
      expect(legacyMotion({'path': 'M0 0', 'orientToPath': true, 'orientUpright': true})!.path!.orient, PathOrient.upright);
      // Orientation without a path yet (the path is bound): kept for it.
      expect(legacyMotion({'orientToPath': true})!.path, const PathFollow(path: '', orient: PathOrient.tangent));
      // A legacy progress over the new shape.
      expect(legacyMotion({'path': {'path': 'M0 0 L1 0', 'progress': 0.1}, 'pathProgress': 0.6})!.path!.progress, 0.6);
    });

    test('path bindings', () {
      final n = _node({
        'motion': {'orientToPath': true},
        'bind': {'motion.path': r'${plan.path}', 'motion.pathProgress': r'${p}', 'motion.originX': r'${o}'},
      });
      // A bound origin binds the alignment.
      expect(n.bind, {'motion.path.path': r'${plan.path}', 'motion.path.progress': r'${p}', 'motion.alignment': r'${= [o, 0]}'});
      final bound = BindPaths.apply(BindPaths.apply(n, 'motion.path.path', 'M0 0 L10 0'), 'motion.path.progress', 0.5);
      expect(bound.behaviors.motion!.path, const PathFollow(path: 'M0 0 L10 0', progress: 0.5, orient: PathOrient.tangent));
      expect(BindPaths.apply(n, 'motion.alignment', [1, 0]).behaviors.motion!.alignment, const Alignment(1, 0));
    });

    test('opacity is the node\'s: multiplied in, bindings and state styles too', () {
      final a = _node({'opacity': 0.5, 'motion': {'opacity': 0.4, 'translateY': 2}});
      expect(a.opacity, closeTo(0.2, 1e-9));
      expect(a.behaviors.motion, const Motion(translateY: 2));
      _stable(a);
      expect(_node({'motion': {'opacity': 0.4}, 'bind': {'motion.opacity': r'${o}'}}).bind, {'opacity': r'${o}'});
      expect(_node({'opacity': 0.5, 'motion': {}, 'bind': {'motion.opacity': r'${o}'}}).bind, {'opacity': r'${= (0.5) * (o)}'});
      expect(_node({'motion': {}, 'bind': {'motion.opacity': r'${o}', 'opacity': r'${= a}'}}).bind, {'opacity': r'${= (a) * (o)}'});
      expect(_node({'motion': {'opacity': 0.5}, 'bind': {'opacity': r'${a}'}}).bind, {'opacity': r'${= (a) * 0.5}'});
      // A state style's motion opacity is the node's.
      final s = _node({
        'states': {
          'hovered': {
            'n': {'motion': {'opacity': 1, 'scale': 1.02}},
          },
        },
      });
      expect(s.behaviors.states.patchFor('n', {WidgetState.hovered}), {'motion': {'scale': 1.02}, 'opacity': 1});
    });

    test('blur is a layer blur, bound by its id', () {
      final n = _node({
        'decoration': {'effects': [{'type': 'dropShadow', 'blurRadius': 4}]},
        'motion': {'blur': 6},
        'bind': {'motion.blur': r'${b}'},
      });
      expect(n.decoration.effects.last, const Effect(type: EffectType.layerBlur, id: 'motionBlur', blurRadius: 6));
      expect(n.decoration.effects.first.type, EffectType.dropShadow);
      expect(n.bind, {'decoration.effects.motionBlur.blurRadius': r'${b}'});
      expect(BindPaths.apply(n, 'decoration.effects.motionBlur.blurRadius', 2).decoration.effects.last.blurRadius, 2);
      _stable(n);
    });
  });

  group('timing: transitions', () {
    test('duration, delay and curve are the motion\'s transition; opacity and blur keep easing', () {
      final n = _node({
        'motion': {'duration': 240, 'delay': 30, 'curve': 'easeOutCubic', 'opacity': 0.5, 'blur': 1, 'arc': 0.2},
      });
      expect(n.behaviors.transitions, [
        const Transition(property: 'motion', duration: 240, delay: 30, curve: AnimationCurve.easeOutCubic),
        const Transition(property: 'opacity', duration: 240, delay: 30, curve: AnimationCurve.easeOutCubic),
        const Transition(property: 'decoration.effects.motionBlur.blurRadius', duration: 240, delay: 30, curve: AnimationCurve.easeOutCubic),
      ]);
      expect(n.behaviors.animations, isEmpty);
      _stable(n);
      // The default curve was easeInOut; the `spring` curve is the spring.
      expect(_node({'motion': {'duration': 100}}).behaviors.transitions.single.curve, AnimationCurve.easeInOut);
      final spring = _node({'motion': {'curve': 'spring'}}).behaviors.transitions.single;
      expect(spring.spring, const Spring.physical(stiffness: 380, damping: 20));
      // No duration: no transition.
      expect(_node({'motion': {'translateX': 3}}).behaviors.transitions, isEmpty);
    });

    test('keyframes are passed through on every change (a card that swells as it turns)', () {
      final n = _node({
        'motion': {'perspective': 1.25, 'duration': 420, 'curve': 'easeInOut', 'keyframes': [{'t': 0.5, 'scale': 1.05}]},
        'bind': {'motion.rotateY': r'${= flipped ? 180 : 0}'},
      });
      final t = Transition.of(n.behaviors.transitions, 'motion.rotateY')!;
      expect(t.keyframesOf('scale'), [const Keyframe(at: 0.5, value: 1.05)]);
      expect(t.interpolation, KeyframeInterpolation.monotoneCubic);
      expect(n.bind, {'motion.rotateY': r'${= flipped ? 180 : 0}'});
    });

    test('the legacy transitions object and a property map read as the list', () {
      expect(legacyTransitions({'style': {'duration': 120}, 'size': {'duration': 300, 'curve': 'easeInOut'}}), [
        const Transition(property: 'opacity', duration: 120),
        // 30.0.0's node scale is motion.scale since 30.1.0.
        const Transition(property: 'motion.scale', duration: 120),
        const Transition(property: 'decoration.fills', duration: 120),
        const Transition(property: 'visible', duration: 120),
        const Transition(property: 'layout', duration: 300, curve: AnimationCurve.easeInOut),
      ]);
      expect(legacyTransitions({'motion': {'duration': 160}, 'motion.rotate': {'spring': {'bounce': 0.3}}}), [
        const Transition(property: 'motion', duration: 160),
        const Transition(property: 'motion.rotate', spring: Spring(bounce: 0.3)),
      ]);
      final list = Transition.listFromJson([{'property': '*', 'duration': 50}, {'property': 'motion', 'duration': 60}]);
      expect(Transition.of(list, 'motion.rotate')!.duration, 60);
      expect(Transition.of(list, 'layout.width')!.duration, 50);
      expect(Transition.of(const [Transition(property: 'motion')], 'motionBlur'), isNull);
    });

    test('bound timing addresses the animations and transitions it became', () {
      final n = _node({
        'motion': {'enter': true, 'enterFrom': {'translateY': 10}, 'duration': 300, 'opacity': 0.5, 'fadeShare': 0.5},
        'bind': {'motion.delay': r'${= 60 + i * 45}', 'motion.duration': r'${ms}'},
      });
      expect(n.bind, {
        'animations.enter.delay': r'${= 60 + i * 45}',
        'transitions[0].delay': r'${= 60 + i * 45}',
        'transitions[1].delay': r'${= 60 + i * 45}',
        'animations.enter.duration': r'${ms}',
        'transitions[0].duration': r'${ms}',
        'transitions[1].duration': r'${= (ms) * 0.5}',
      });
      expect(BindPaths.apply(n, 'transitions[0].delay', 90).behaviors.transitions.first.delay, 90);
    });
  });

  group('entrances', () {
    test('enter + enterFrom + replayKey + enterHeld are the animation enter', () {
      final n = _node({
        'motion': {
          'translateX': 10,
          'duration': 400,
          'delay': 200,
          'curve': 'linear',
          'enter': true,
          'enterFrom': {'translateY': -100, 'opacity': 0, 'scale': 1},
          'replayKey': 'a',
          'enterHeld': true,
        },
      });
      final a = _animation(n, 'enter');
      expect(a.toJson(), {
        'id': 'enter',
        'preset': 'enter',
        'params': {
          'from': {'translateY': -100, 'opacity': 0},
        },
        'duration': 400,
        'delay': 200,
        'curve': 'linear',
        'autoplay': true,
        'playKey': 'a',
        'paused': true,
      });
      expect([for (final t in a.expanded.tracks) (t.path, t.from, t.to)], [('motion.translateY', -100, null), ('opacity', 0, null)]);
      _stable(n);
    });

    test('enter without enterFrom starts every moved value at rest; a reveal alone fades in', () {
      final a = _animation(
          _node({
            'motion': {'enter': true, 'duration': 300, 'scale': 2, 'translateX': 30},
            'bind': {'motion.rotate': r'${r}'},
          }),
          'enter');
      expect(readMap(a.params['from']), {'translateX': 0, 'scale': 1, 'rotate': 0});
      final r = _animation(_node({'motion': {'revealOnScroll': true, 'revealFraction': 0.4, 'duration': 300}}), 'enter');
      expect(readMap(r.params['from']), {'opacity': 0});
      expect(r.visibleFraction, 0.4);
      expect(_animation(_node({'motion': {'revealOnScroll': true, 'enter': true, 'enterFrom': {'opacity': 0}, 'duration': 3}}), 'enter').visibleFraction,
          0.15);
    });

    test('an entrance on a path starts at its progress; keyframes go through on one monotone cubic', () {
      final a = _animation(
          _node({
            'motion': {
              'path': 'M0 0 L100 0',
              'pathProgress': 1,
              'duration': 500,
              'enterFrom': {'opacity': 0},
              'keyframes': [{'t': 0.5, 'translateY': -20}],
            },
          }),
          'enter');
      final tracks = {for (final t in a.expanded.tracks) t.path: t};
      expect(tracks['motion.path.progress']!.from, 0);
      final hop = tracks['motion.translateY']!;
      expect(hop.from, isNull);
      expect(hop.interpolation, KeyframeInterpolation.monotoneCubic);
      expect(hop.valueAt(0.5, own: 0), -20);
      expect(hop.valueAt(1, own: 0), 0);
    });

    test('keyframes replayed by a key wait for it', () {
      final a = _animation(
          _node({
            'motion': {'duration': 400, 'curve': 'linear', 'keyframes': [{'t': 0.25, 'translateX': -8}]},
            'bind': {'motion.replayKey': r'${shake}'},
          }),
          'enter');
      expect(a.autoplay, isFalse);
      expect(a.expanded.tracks.single.path, 'motion.translateX');
    });

    test('bound entrance keys', () {
      final n = _node({
        'motion': {'enterFrom': {'translateY': -100}, 'duration': 400},
        'bind': {
          'motion.enter': r'${= order[item] != null}',
          'motion.replayKey': r'${k}',
          'motion.enterHeld': r'${= !settled}',
          'motion.enterFrom.translateY': r'${y}',
          'motion.rotateCurve': 'elasticOut',
        },
      });
      // enter is moot with an enterFrom; rotateCurve has no counterpart.
      expect(n.bind, {
        'animations.enter.playKey': r'${k}',
        'animations.enter.paused': r'${= !settled}',
        'animations.enter.params.from.translateY': r'${y}',
      });
      final e = _node({'motion': {'duration': 400, 'translateX': 5}, 'bind': {'motion.enter': r'${on}'}});
      expect(_animation(e, 'enter').enabled, isFalse);
      expect(e.bind, {'animations.enter.enabled': r'${on}'});
    });

    test('no duration, no entrance (it showed its values at once)', () {
      expect(_node({'motion': {'enter': true, 'enterFrom': {'opacity': 0}}}).behaviors.animations, isEmpty);
    });
  });

  group('loops and spins', () {
    test('restart, reverse and swing loops are the animation loop', () {
      Map<String, Object?> loop(Json motion) => _animation(_node({'motion': motion}), 'loop').toJson();
      expect(loop({'translateX': 40, 'loop': 'restart', 'duration': 1000, 'curve': 'linear', 'phase': 0.25}), {
        'id': 'loop',
        'preset': 'loop',
        'params': {
          'from': {'translateX': 0},
        },
        'duration': 1000,
        'curve': 'linear',
        'repeat': {},
        'phase': 0.25,
      });
      final reverse = loop({'opacity': 0, 'loop': 'reverse', 'duration': 800, 'repeat': 3, 'phase': 0.5, 'paused': true});
      expect(reverse['repeat'], {'reverse': true, 'count': 3});
      // A reverse loop's phase was a share of one way.
      expect(reverse['phase'], 0.25);
      expect(reverse['paused'], true);
      expect(reverse['curve'], 'easeInOut');
      final swing = _animation(_node({'motion': {'rotate': 20, 'loop': 'swing', 'duration': 1000}}), 'loop');
      expect(swing.params['mode'], 'swing');
      expect(swing.curve, AnimationCurve.linear);
      final track = swing.expanded.tracks.single;
      // Around rest on a sine: to its value and as far the other way.
      expect(track.valueAt(0.25, own: 20) as double, closeTo(20, 1e-9));
      expect(track.valueAt(0.75, own: 20) as double, closeTo(-20, 1e-9));
      expect(track.valueAt(1, own: 20) as double, closeTo(0, 1e-9));
    });

    test('a loop from enterFrom starts there; a counted loop replays when a bound value moves', () {
      final n = _node({
        'motion': {'loop': 'reverse', 'repeat': 3, 'duration': 70, 'enterFrom': {'translateY': -10, 'opacity': 1}},
        'bind': {'motion.translateX': r'${= shake % 2 == 1 ? 9 : -9}', 'motion.phase': r'${= index / 4}', 'motion.loop': r'${l}'},
      });
      expect(readMap(_animation(n, 'loop').params['from']), {'translateY': -10});
      expect(n.bind, {
        'motion.translateX': r'${= shake % 2 == 1 ? 9 : -9}',
        'animations.loop.phase': r'${= (index / 4) / 2}',
        // A bound mode over a static one: on while it names it.
        'animations.loop.enabled': r"${= (l) == 'reverse'}",
        'animations.loop.playKey': r"${= 'loop|' + (shake % 2 == 1 ? 9 : -9)}",
      });
      // A bound mode turns the loop on and off.
      final b = _node({
        'motion': {'rotate': 4, 'duration': 900},
        'bind': {'motion.loop': r'${= still ? "none" : "swing"}'},
      });
      expect(_animation(b, 'loop').enabled, isFalse);
      expect(b.bind, {'animations.loop.enabled': r'''${= (still ? "none" : "swing") == 'swing'}'''});
    });

    test('spin and spinRamp are the animation spin, ramped', () {
      final n = _node({'motion': {'spin': -0.5, 'originY': 1, 'paused': true}});
      final s = _animation(n, 'spin');
      expect(s.toJson(), {
        'id': 'spin',
        'preset': 'spin',
        'params': {'perSecond': -0.5},
        'paused': true,
        'alignment': [0, 1],
        'ramp': 800,
      });
      final e = s.expanded;
      expect(e.durationMs, 2000);
      expect(e.tracks.single.to, -360);
      expect(_animation(_node({'motion': {'spin': 2, 'spinRamp': 0}}), 'spin').ramp, 0);
      final bound = _node({'motion': {}, 'bind': {'motion.spin': r'${speed}', 'motion.paused': r'${p}'}});
      expect(bound.bind, {'animations.spin.params.perSecond': r'${speed}', 'animations.spin.paused': r'${p}'});
      // Still at 0 turns a second.
      expect(_animation(bound, 'spin').expanded.durationMs, 0);
      _stable(n);
    });
  });

  test('shimmer is the behavior shimmer and the animation shimmer', () {
    final n = _node({
      'motion': {'shimmer': {'color': '#FFFFCC00', 'duration': 900}},
      'bind': {'motion.shimmer.strength': r'${s}'},
    });
    expect(n.behaviors.shimmer, const Shimmer(color: Color(0xFFFFCC00)));
    expect(_animation(n, 'shimmer').toJson(), {'id': 'shimmer', 'preset': 'shimmer', 'duration': 900});
    expect(n.bind, {'shimmer.strength': r'${s}'});
    final e = _animation(n, 'shimmer').expanded;
    expect(e.repeat, AnimationRepeat.forever);
    expect(e.tracks.single.path, 'shimmer.position');
    _stable(n);
  });

  group('the primitive', () {
    test('numbers carry on past their ends on a curve that overshoots (Tween)', () {
      const t = AnimationTrack(path: 'motion.rotate', from: 0, to: 10, curve: AnimationCurve.elasticOut);
      final peak = [for (var i = 1; i < 100; i++) (t.valueAt(i / 100) as num).toDouble()].reduce(math.max);
      expect(peak, greaterThan(10));
      expect(AnimationTrack.lerpValue(0, 10, -0.5), -5);
      expect(AnimationTrack.lerpValue(0, 10, 0), 0);
    });

    test('a monotone cubic never overshoots a keyframe', () {
      const t = AnimationTrack(
        path: 'motion.scale',
        from: 1,
        to: 1,
        keyframes: [Keyframe(at: 0.5, value: 1.05)],
        interpolation: KeyframeInterpolation.monotoneCubic,
      );
      for (var i = 0; i <= 100; i++) {
        final v = (t.valueAt(i / 100) as num).toDouble();
        expect(v, inInclusiveRange(1, 1.05 + 1e-12));
      }
      expect(t.toJson()['interpolation'], 'monotoneCubic');
      expect(AnimationTrack.fromJson(t.toJson()), t);
    });

    test('ramp and visibleFraction round-trip', () {
      const a = NodeAnimation(id: 'a', ramp: 500, visibleFraction: 0.3);
      expect(a.toJson(), {'id': 'a', 'ramp': 500, 'visibleFraction': 0.3});
      expect(NodeAnimation.fromJson(a.toJson()), a);
    });
  });

  group('setVariable.animateMs', () {
    test('a glide is animate animateTo on the variable', () {
      ActionDef read(Json j) => legacyAction({'type': 'setVariable', ...j});
      expect(read({'variable': 'total', 'value': r'${sum}', 'animateMs': '800', 'curve': 'easeOutCubic'}).toJson(), {
        'type': 'animate',
        'variable': 'total',
        'command': 'animateTo',
        'target': r'${sum}',
        'duration': '800',
        'curve': 'easeOutCubic',
      });
      // add and subtract: the value it has when the action runs, moved.
      expect((read({'variable': 'n', 'op': 'add', 'value': '5', 'animateMs': r'${ms}'}) as AnimateAction).target, r'${= n + (5)}');
      expect((read({'variable': 'n', 'op': 'subtract', 'value': r'${= d * 2}', 'animateMs': '300'}) as AnimateAction).target,
          r'${= n - (d * 2)}');
      // What isn't a glide of a whole variable stays a setVariable.
      expect(read({'variable': 'rows', 'op': 'insert', 'value': r'${item}', 'animateMs': '300'}), isA<SetVariableAction>());
      expect(read({'variable': 'draft.title', 'value': '1', 'animateMs': '300'}), isA<SetVariableAction>());
      expect(read({'variable': 'n', 'value': 'a \${b}', 'animateMs': '300'}), isA<SetVariableAction>());
      expect(read({'variable': 'n', 'value': '1', 'animateMs': '0'}), isA<SetVariableAction>());
    });
  });
}
