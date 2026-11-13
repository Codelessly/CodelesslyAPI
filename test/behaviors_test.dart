import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('keyframes at the ends give the values there (a 0 -> 1 path run with no keyframe between)', () {
    // A legacy motion's keyframes, replayed by a key: a track per property
    // they name, through them on one monotone cubic.
    final a = Behaviors.fromJson({
      'motion': {
        'path': 'M0 0 L100 0',
        'duration': 400,
        'replayKey': 'a',
        'keyframes': [
          {'t': 0, 'pathProgress': 0},
          {'t': 1, 'pathProgress': 1},
        ],
      },
    }).animations.single.expanded;
    final run = a.tracks.single;
    expect(run.path, 'motion.path.progress');
    expect(run.valueAt(0, own: 0.3), 0);
    expect(run.valueAt(0.5, own: 0.3) as double, closeTo(0.5, 1e-9));
    expect(run.valueAt(1, own: 0.3), 1);
    // Keyframes inside only still run from the motion's own ends.
    const inside = AnimationTrack(
      path: 'opacity',
      keyframes: [Keyframe(at: 0.5, value: 0)],
      interpolation: KeyframeInterpolation.monotoneCubic,
    );
    expect(inside.valueAt(0.5, own: 1) as double, closeTo(0, 1e-9));
    // No keyframe for a property: no track.
    expect(a.tracks.where((t) => t.path == 'opacity'), isEmpty);
  });

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
    // The legacy loops, effect and the motion's entrance read as animations.
    expect([for (final a in b.animations) a.id], ['loop0', 'loop1', 'shake', 'enter']);
    expect(readMap(b.animations.last.params['from']), {'opacity': 0, 'translateY': 20});
    // The legacy transitions, and the motion's own timing, as transitions.
    expect(Transition.of(b.transitions, 'opacity')!.curve, AnimationCurve.easeInOut);
    expect(Transition.of(b.transitions, 'motion')!.duration, 900);
    expect(b.inkWell!.overlayColor, const Color(0x1F000000));
    expect(b.states.patchFor('t', {WidgetState.hovered}), {
      'props': {'text': 'Hovered!'}
    });
    expect(b.states.patchFor('t', {WidgetState.pressed}), isNull);
    expect(b.hero, const HeroTag('card', flight: HeroFlightShuttle.morphCorners));
    // A legacy drag with a track is the track (its swipe fields did nothing).
    expect(b.track!.shape, TrackShape.arc);
    expect(b.track!.variable, 'volume');
    expect(b.dismissible, isNull);
    expect(b.strokePath!.points.last, const Offset(1, 10));
    expect(b.particles!.colors, [const Color(0xFFFF0000)]);
    expect(b.textDirection, TextDirection.rtl);
    expect(n.extra, {'custom': 1});
    // Written in the new shape: `animations` instead of `loops`,
    // `effectAnimations` and the motion's entrance, `transitions` as a
    // list with the motion's timing, the motion as its pose; the rest as
    // given.
    final legacy = {...nodeJson}
      ..remove('loops')
      ..remove('effectAnimations')
      ..remove('motion')
      ..remove('transitions')
      ..remove('drag')
      ..remove('zoomable');
    final written = jsonDecode(jsonEncode(n.toJson())) as Map;
    expect(written['animations'], [
      {'id': 'loop0', 'preset': 'pulse', 'params': {'scaleFrom': 0.65, 'opacityFrom': 0.35, 'opacityTo': 0}, 'duration': 1400},
      {'id': 'loop1', 'preset': 'fade', 'params': {'opacityFrom': 0.45}, 'duration': 1100, 'curve': 'easeInOut', 'repeat': {'reverse': true}},
      {'id': 'shake', 'preset': 'shake', 'duration': 400},
      {
        'id': 'enter',
        'preset': 'enter',
        'params': {
          'from': {'opacity': 0, 'translateY': 20},
          'frames': [
            {'t': 0.5, 'scale': 1.2},
          ],
        },
        'duration': 900,
        'curve': 'easeOutBack',
        'autoplay': true,
      },
    ]);
    expect(written['motion'], {'translateX': 10, 'rotate': -3.5});
    expect(written['transitions'], [
      {'property': 'opacity', 'duration': 1100, 'curve': 'easeInOut'},
      {'property': 'scale', 'duration': 120},
      {'property': 'decoration.fills', 'duration': 120},
      {'property': 'visible', 'duration': 120},
      {
        'property': 'motion',
        'duration': 900,
        'curve': 'easeOutBack',
        'keyframes': [
          {'at': 0.5, 'value': {'scale': 1.2}},
        ],
        'interpolation': 'monotoneCubic',
      },
    ]);
    expect(written['track'], {'variable': 'volume', 'shape': 'arc', 'max': 10});
    // zoomable: true is the transform gesture's zoomable form.
    expect(written['transformGesture'], {'target': 'content', 'pan': 'whenZoomed'});
    expect(b.transformGesture, TransformGesture.zoomable);
    expect({...written}..removeWhere((k, _) => const {'animations', 'motion', 'transitions', 'track', 'transformGesture'}.contains(k)),
        jsonDecode(jsonEncode(legacy)));
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
    expect(n.behaviors.animations.single.preset, 'pulse');
    expect(n.behaviors.states.isEmpty, isTrue);
    expect(n.behaviors.hero, isNull);
    expect(n.behaviors.textDirection, isNull);
    expect(n.toJson()..remove('layout'), {'id': '', 'type': 'box', 'motion': {}, 'animations': [{'id': 'loop1', 'preset': 'pulse'}]});
  });

  test('a loop rests on its first frame', () {
    // LoopAnimation.poseAt is gone: the loop is the preset's tracks.
    double at(NodeAnimation a, String id, double v) =>
        readDouble(a.expanded.tracks.firstWhere((t) => t.id == id).valueAt(v))!;
    final halo = AnimationPresets.fromLoop({'type': 'pulse', 'scaleFrom': 0.65, 'opacityFrom': 0.35, 'opacityTo': 0}, 0)!;
    expect((at(halo, 'scale', 0), at(halo, 'opacity', 0)), (0.65, 0.35));
    expect(at(halo, 'scale', 1), 1);
    expect(AnimationPresets.fromLoop({'type': 'scale', 'scaleFrom': 0.5, 'enabled': false}, 0)!.enabled, isFalse);
    final bob = AnimationPresets.fromLoop({'type': 'bob', 'distance': 10}, 0)!;
    expect(at(bob, 'translateY', 0.5), closeTo(-10, 1e-9));
  });

  test('stroke path points read as pairs or {x, y} maps', () {
    final a = StrokePath.fromJson({
      'points': [
        [0, 1],
        {'x': 2, 'y': 3},
        {'x': 'bad'},
      ],
    })!;
    expect(a.points, const [Offset(0, 1), Offset(2, 3)]);
  });

  test('a flicker wavers between its values and loops seamlessly', () {
    final glow = AnimationPresets.fromLoop(
        {'type': 'flicker', 'scaleFrom': 0.9, 'scaleTo': 1.1, 'opacityFrom': 0.6, 'opacityTo': 1}, 0)!.expanded;
    double value(String id, double t) => readDouble(glow.tracks.firstWhere((x) => x.id == id).valueAt(t))!;
    final samples = [for (var i = 0; i <= 100; i++) (scale: value('scale', i / 100), opacity: value('opacity', i / 100))];
    for (final p in samples) {
      expect(p.scale, inInclusiveRange(0.9 - 1e-9, 1.1 + 1e-9));
      expect(p.opacity, inInclusiveRange(0.6 - 1e-9, 1 + 1e-9));
    }
    // Not a steady pulse: it changes direction many times in a run.
    var turns = 0;
    for (var i = 2; i < samples.length; i++) {
      final a = samples[i - 1].opacity - samples[i - 2].opacity, b = samples[i].opacity - samples[i - 1].opacity;
      if (a.sign != b.sign && a != 0 && b != 0) turns++;
    }
    expect(turns, greaterThan(6));
    expect(samples.first.opacity, closeTo(samples.last.opacity, 1e-9));
    // Exactly the legacy curve: from + (to - from) * flickerAt(t).
    for (var i = 0; i <= 100; i++) {
      expect(samples[i].opacity, closeTo(0.6 + 0.4 * flickerAt(i / 100), 1e-12));
    }
    final short = AnimationPresets.fromLoop({'type': 'flicker', 'scaleFrom': 0.9, 'scaleTo': 1.1}, 0)!;
    expect(NodeAnimation.fromJson(short.toJson()), short);
  });

  test('motion: rest, entrance start, keyframes', () {
    const m = Motion(rotate: 30, translateX: 10);
    expect(m.hasTransform, isTrue);
    expect(Motion.none.hasTransform, isFalse);
    // An entrance from enterFrom: the opacity starts at 0, the rotation at
    // its own value (no track).
    final enter = Behaviors.fromJson({
      'motion': {'rotate': 30, 'translateX': 10, 'duration': 300, 'enterFrom': {'opacity': 0}},
    }).animations.single.expanded;
    expect([for (final t in enter.tracks) (t.path, t.from)], [('opacity', 0)]);
    expect(Motion.lerp(Motion.none, m, 0.5).rotate, 15);
    // Keyframes pass through their values.
    final k = Behaviors.fromJson({
      'motion': {'scale': 2, 'duration': 300, 'enter': true, 'keyframes': [{'t': 0.5, 'scale': 3}]},
    }).animations.single.expanded.tracks.single;
    expect(k.valueAt(0.5, own: 2), 3);
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
    // The effects are animations now, addressed by id.
    NodeAnimation effect(Node n, String id) => n.behaviors.animations.firstWhere((a) => a.id == id);
    final cued = BindPaths.apply(n, 'animations.nudge.playKey', 3);
    expect(effect(cued, 'nudge').playKey, '3');
    expect(effect(cued, 'pop').playKey, isNull);
    expect(effect(BindPaths.apply(n, 'animations.nudge.delay', 250), 'nudge').delay, 250);
    expect(BindPaths.apply(n, 'particles.playKey', 'w1').behaviors.particles!.playKey, 'w1');
    expect(NodeAnimation.fromJson(effect(cued, 'nudge').toJson())!.playKey, '3');
  });

  test('reveal.follow round-trips and defaults off', () {
    expect(Reveal.fromJson({'alignment': 1})!.follow, isFalse);
    final r = Reveal.fromJson({'alignment': 1, 'duration': 0, 'follow': true})!;
    expect(r.follow, isTrue);
    expect(r.toJson(), {'alignment': 1.0, 'duration': 0, 'follow': true});
    expect(Reveal.fromJson(r.toJson()), r);
    expect(Reveal.fromJson({'follow': false})!.toJson().containsKey('follow'), isFalse);
  });

  test('typewriter.holdAtMs round-trips; absent types to the end', () {
    expect(Typewriter.fromJson({'charsPerSecond': 95})!.holdAtMs, isNull);
    final t = Typewriter.fromJson({'charsPerSecond': 95, 'holdAtMs': 1200})!;
    expect(t.holdAtMs, 1200);
    expect(t.toJson()['holdAtMs'], 1200);
    expect(Typewriter.fromJson(t.toJson()), t);
    expect(Typewriter.fromJson({'holdAtMs': ''})!.holdAtMs, isNull, reason: 'an empty binding is no hold');
    expect(Typewriter.fromJson({'holdAtMs': -5})!.holdAtMs, 0);
    expect(Typewriter.fromJson({'grow': true})!.toJson(), {'grow': true});
    expect(Typewriter.fromJson({})!.grow, isFalse);
  });

  test('strokePath.fillColor round-trips; absent is no fill', () {
    expect(StrokePath.fromJson({'points': []})!.fillColor, isNull);
    final p = StrokePath.fromJson({'points': [[0, 0], [10, 0], [10, 10]], 'fillColor': '#59FFF6DE'})!;
    expect(p.fillColor, const Color(0x59FFF6DE));
    expect(StrokePath.fromJson(p.toJson()), p);
    expect(p.copyWith(progress: 0.5).fillColor, p.fillColor);
  });
}
