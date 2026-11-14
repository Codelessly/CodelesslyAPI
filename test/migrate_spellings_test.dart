// 30.1.0's one-way steps, the last of the schema 2 → 3 migration: each
// step's rewrites of 30.0.0's spellings, that a migrated document draws what
// the 30.0.0 one drew, and how they run in migrate2to3.
import 'dart:convert';
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/migrate/steps_spellings.dart' show spellingMigrationSteps;
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

/// A document in 30.0.0's spellings holding [nodes] under one canvas.
Json doc3(Map<String, Object?> nodes, {Json extra = const {}}) => {
      'schema': 3,
      'roots': ['home'],
      'nodes': {
        'home': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'children': nodes.keys.toList()},
        ...nodes,
      },
      ...extra,
    };

/// [document] through the one-way steps alone ([steps]: some of them), as
/// migrate2to3 runs them on a schema-2 document after schema 2's steps.
Json oneWay(Json document, {MigrationReport? report, List<MigrationStep>? steps}) =>
    migrate2to3({...document, 'schema': 2}, report: report, steps: steps ?? spellingMigrationSteps);

/// Node [node] in 30.0.0's spellings (a 100 × 40 box, id `n`) through the
/// one-way steps, with the report.
(Json, MigrationReport) migrated(Json node, {Map<String, Object?> others = const {}, Json extra = const {}}) {
  final report = MigrationReport(document: 't');
  final doc = oneWay(doc3({'n': {'type': 'box', 'layout': {'width': 100, 'height': 40}, ...node}, ...others}, extra: extra),
      report: report);
  return (((doc['nodes'] as Map)['n'] as Map).cast<String, Object?>(), report);
}

Json nodeOf(Json doc, String id) => ((doc['nodes'] as Map)[id] as Map).cast<String, Object?>();

// --- 2D geometry of a drawn node -------------------------------------------------

/// An affine map of the plane: x' = a·x + c·y + tx, y' = b·x + d·y + ty.
class Affine {
  const Affine(this.a, this.b, this.c, this.d, this.tx, this.ty);
  static const identity = Affine(1, 0, 0, 1, 0, 0);
  factory Affine.translate(double x, double y) => Affine(1, 0, 0, 1, x, y);
  factory Affine.scale(double sx, double sy) => Affine(sx, 0, 0, sy, 0, 0);
  factory Affine.rotate(double degrees) {
    final r = degrees * math.pi / 180;
    return Affine(math.cos(r), math.sin(r), -math.sin(r), math.cos(r), 0, 0);
  }

  final double a, b, c, d, tx, ty;

  Affine operator *(Affine o) => Affine(
        a * o.a + c * o.b, b * o.a + d * o.b, //
        a * o.c + c * o.d, b * o.c + d * o.d,
        a * o.tx + c * o.ty + tx, b * o.tx + d * o.ty + ty,
      );

  (double, double) apply(double x, double y) => (a * x + c * y + tx, b * x + d * y + ty);

  /// About [px], [py].
  Affine about(double px, double py) => Affine.translate(px, py) * this * Affine.translate(-px, -py);
}

/// Where a [w] × [h] box's corners are drawn by a centered [motion] now
/// (the SDK's RenderMotion: translate, then scale and rotate about the box's
/// center).
List<(double, double)> drawn4(Motion m, double w, double h) {
  final t = Affine.translate(m.translateX, m.translateY) *
      (Affine.scale(m.scale * m.scaleX, m.scale * m.scaleY) * Affine.rotate(m.rotate)).about(w / 2, h / 2);
  return [for (final (x, y) in [(0.0, 0.0), (w, 0.0), (0.0, h), (w, h)]) t.apply(x, y)];
}

/// The same corners as 30.0.0 drew them: the motion, then the node's
/// scale about its center, then its rotation about its center moved by half
/// its margin's difference ([ml], [mt], [mr], [mb]).
List<(double, double)> drawn3(Motion m, double scale, double rotation, double w, double h,
    {double ml = 0, double mt = 0, double mr = 0, double mb = 0}) {
  final motion = Affine.translate(m.translateX, m.translateY) *
      (Affine.scale(m.scale * m.scaleX, m.scale * m.scaleY) * Affine.rotate(m.rotate)).about(w / 2, h / 2);
  final s = Affine.scale(scale, scale).about(w / 2, h / 2);
  final r = Affine.rotate(rotation).about(w / 2 + (ml - mr) / 2, h / 2 + (mt - mb) / 2);
  final t = motion * s * r;
  return [for (final (x, y) in [(0.0, 0.0), (w, 0.0), (0.0, h), (w, h)]) t.apply(x, y)];
}

Matcher drawnAt(List<(double, double)> want) => predicate<List<(double, double)>>(
    (got) => [for (var i = 0; i < 4; i++) (got[i].$1 - want[i].$1).abs() < 1e-6 && (got[i].$2 - want[i].$2).abs() < 1e-6]
        .every((e) => e),
    'drawn at $want');

/// Runs [step] alone on migrated node [node] again: nothing changes.
void expectStable(MigrationStep step, Json node) {
  final again = oneWay({'nodes': {'n': node}}, steps: [step]);
  expect(jsonEncode((again['nodes'] as Map)['n']), jsonEncode(node), reason: step.id);
}

void main() {
  renamedPropsTests();
  group('framework', () {
    test('schema 3 is current; a schema-2 document runs schema 2\'s steps, then the one-way steps, and says so once', () {
      expect(kSchemaVersion, 3);
      final report = MigrationReport(document: 'a.json');
      final out = migrate2to3({...doc3({'box': {'type': 'box', 'layout': {'width': 10, 'height': 10}, 'scale': 2}}), 'schema': 2}, report: report);
      expect(out['schema'], 3);
      expect(nodeOf(out, 'box')['motion'], {'scale': 2});
      expect(report.documents, ['a.json']);
      expect(report.entries.map((e) => e.step), containsAll(['text.lineHeight', 'transform.fold']));
    });

    test('a schema-2 document with an earlier spelling reaches its one spelling, when decoded too', () {
      final schema2 = {
        'roots': ['home'],
        'nodes': {
          'home': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'children': ['b']},
          'b': {'type': 'box', 'layout': {'width': 10, 'height': 10, 'rotation': 30}, 'scale': 2},
        },
      };
      final out = migrateDocument(schema2);
      expect(out['schema'], 3);
      expect(nodeOf(out, 'b')['motion'], {'scale': 2, 'rotate': 30});
      final b = LayoutDocument.fromJson(schema2)['b']!;
      expect([b.behaviors.motion!.scale, b.behaviors.motion!.rotate], [2, 30]);
    });

    test('a schema-3 document is read as current schema 3: returned as given, earlier spellings and all', () {
      final three = doc3({'b': {'type': 'box', 'scale': 2}});
      expect(identical(migrate2to3(three), three), isTrue);
      expect(identical(migrateDocument(three), three), isTrue);
      expect(LayoutDocument.fromJson(three)['b']!.behaviors.motion, isNull);
    });

    test('a node alone, and any JSON carrying schema-2 documents, reach the one spelling', () {
      expect(migrateNode({'type': 'box', 'scale': 0.5}), {'type': 'box', 'motion': {'scale': 0.5}});
      expect(migrateNode({'type': 'box', 'flightKey': 'k'}), {'type': 'box', 'hero': {'tag': 'k', 'flies': 'inPlace'}});
      expect(migrateNode({'type': 'box', 'scale': 0.5}, from: 3), {'type': 'box', 'scale': 0.5});
      final out = migrateJson({
        'schema': 2,
        'id': 'Chip',
        'document': {...doc3({'b': {'type': 'box', 'scale': 2}}), 'schema': 2},
      }) as Map;
      expect(out['schema'], 3);
      expect((out['document'] as Map)['schema'], 3);
      expect(nodeOf((out['document'] as Map).cast(), 'b')['motion'], {'scale': 2});
    });

    test('validation reports an earlier spelling in a schema-3 document with its one spelling; a newer schema is reported', () {
      final d = validateDocument({
        'schema': 3,
        'roots': ['home'],
        'nodes': {
          'home': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'b'}},
          'b': {'type': 'box', 'layout': {'width': {'fill': 390}, 'height': {'fill': 844}, 'rotation': 5}, 'scale': 2},
        },
      });
      expect(d.map((d) => '${d.code.name} ${d.severity.name} ${d.suggestion}'),
          unorderedEquals(['unknown_layout_key error motion.rotate', 'unknown_node_key error motion.scale']));
      expect(validateDocument({...doc3({}), 'schema': 4}).map((d) => d.code.name), contains('schema_version'));
    });

    test('every one-way step is stable: running it on its own output changes nothing', () {
      final samples = <String, Json>{
        'transform.fold': {
          'type': 'box',
          'layout': {'width': 100, 'height': 40, 'rotation': 15, 'margin': [12, 0, 0, 0]},
          'scale': 1.5,
          'motion': {'scale': 2},
          'bind': {'scale': r'${s}'},
          'transitions': [{'property': 'scale', 'duration': 100}],
        },
        'hero.flight': {'type': 'box', 'flightKey': 'k', 'flight': {'duration': 300}, 'bind': {'flightKey': r'${k}'}},
        'paths.moved': {
          'type': 'box',
          'actions': [
            {'trigger': {'type': 'click'}, 'actions': [{'type': 'setValue', 'node': 'n', 'values': [{'path': 'scale', 'value': 2}]}]},
          ],
        },
      };
      final byId = {for (final s in spellingMigrationSteps) s.id: s};
      for (final e in samples.entries) {
        final once = (oneWay({'nodes': {'n': e.value}}, steps: [byId[e.key]!])['nodes'] as Map)['n'] as Map;
        expect(jsonEncode(once), isNot(jsonEncode(e.value)), reason: '${e.key} changes its sample');
        expectStable(byId[e.key]!, once.cast());
      }
    });
  });

  group('transform.fold: the node scale and rotation are its motion', () {
    test('a node scale multiplies into the motion scale and a rotation adds to its rotate', () {
      final (n, report) = migrated({
        'layout': {'width': 100, 'height': 40, 'rotation': 30},
        'scale': 1.5,
        'motion': {'scale': 2, 'rotate': 10, 'translateY': -4},
      });
      expect(n['motion'], {'scale': 3, 'rotate': 40, 'translateY': -4});
      expect(n.containsKey('scale'), isFalse);
      expect((n['layout'] as Map).containsKey('rotation'), isFalse);
      expect(report.rewrites.map((e) => e.step).toSet(), {'transform.fold'});
      expect(report.behaviourChanges, isEmpty);
    });

    test('a migrated node is drawn where schema 3 drew it, an uneven margin\'s pivot included', () {
      final r = math.Random(3);
      for (var i = 0; i < 200; i++) {
        double pick(List<double> v) => v[r.nextInt(v.length)];
        final rotation = pick([0, 30, -45, 90, 12.5]), scale = pick([1, 0.5, 2, 1.25]);
        final margin = [pick([0, 12, -6]), pick([0, 4]), pick([0, 8]), pick([0, 2, -3])];
        final motion = {
          'translateX': pick([0, 10]),
          'translateY': pick([0, -4]),
          'scale': pick([1, 1.5]),
          'scaleX': pick([1, -1, 2]),
          'rotate': pick([0, 20, -90]),
        };
        final (n, _) = migrated({
          'layout': {'width': 100, 'height': 40, 'rotation': rotation, 'margin': margin},
          'scale': scale,
          'motion': motion,
        });
        final m3 = Motion.fromJson(motion)!;
        final m4 = Motion.fromJson(n['motion']) ?? Motion.none;
        expect(drawn4(m4, 100, 40),
            drawnAt(drawn3(m3, scale, rotation, 100, 40, ml: margin[0], mt: margin[1], mr: margin[2], mb: margin[3])),
            reason: 'rotation $rotation, scale $scale, margin $margin, motion $motion → ${n['motion']}');
      }
    });

    test('a state that turns a node with an uneven margin is drawn where schema 3 drew it, at rest and in the state', () {
      final (n, report) = migrated({
        'layout': {'width': 160, 'height': 56, 'rotation': 3, 'margin': [10, 0, 0, 4]},
        'scale': 1.2,
        'motion': {'scale': 1.1},
        'states': {'selected': {'n': {'scale': 0.9, 'layout': {'rotation': 12}}}},
      });
      expect(report.behaviourChanges, isEmpty);
      final rest = Motion.fromJson(n['motion'])!;
      final patch = ((n['states'] as Map)['selected'] as Map)['n'] as Map;
      final selected = Motion.fromJson({...(n['motion'] as Map), ...(patch['motion'] as Map)})!;
      final m3 = Motion.fromJson({'scale': 1.1})!;
      expect(drawn4(rest, 160, 56), drawnAt(drawn3(m3, 1.2, 3, 160, 56, ml: 10, mb: 4)));
      expect(drawn4(selected, 160, 56), drawnAt(drawn3(m3, 0.9, 12, 160, 56, ml: 10, mb: 4)));
    });

    test('a bound scale or rotation binds the motion, times or plus the other part', () {
      final (scaled, _) = migrated({'motion': {'scale': 2}, 'bind': {'scale': r'${= big ? 1.2 : 1}'}});
      expect(scaled['bind'], {'motion.scale': r'${= (big ? 1.2 : 1) * 2}'});
      final (motionBound, _) = migrated({'scale': 1.5, 'bind': {'motion.scale': r'${pulse}'}});
      expect(motionBound['bind'], {'motion.scale': r'${= (pulse) * 1.5}'});
      expect(motionBound['motion'], {'scale': 1.5});
      final (both, _) = migrated({'bind': {'layout.rotation': r'${angle}', 'motion.rotate': r'${= spin * 360}'}});
      expect(both['bind'], {'motion.rotate': r'${= (angle) + (spin * 360)}'});
      final (plain, _) = migrated({'bind': {'layout.rotation': r'${= open ? 180 : 0}'}});
      expect(plain['bind'], {'motion.rotate': r'${= open ? 180 : 0}'});
    });

    test('a scale transition times motion.scale apart from the rest of the motion', () {
      final (n, _) = migrated({
        'transitions': [
          {'property': 'motion', 'duration': 400},
          {'property': 'scale', 'duration': 120, 'curve': 'easeOut'},
        ],
        'states': {'pressed': {'n': {'scale': 0.95}}},
      });
      final list = Transition.listFromJson(n['transitions']);
      expect(Transition.of(list, 'motion.scale')!.duration, 120);
      expect(Transition.of(list, 'motion.translateY')!.duration, 400);
    });

    test('a scale that changes with no transition of its own stays instant beside a motion transition', () {
      final (n, _) = migrated({
        'transitions': [{'property': 'motion', 'duration': 400}],
        'states': {'pressed': {'n': {'scale': 0.95}}},
      });
      final list = Transition.listFromJson(n['transitions']);
      expect(Transition.of(list, 'motion.scale')!.duration, 0);
      expect(Transition.of(list, 'motion.rotate')!.duration, 400);
      // A static scale changes nothing: no transition is added.
      final (still, _) = migrated({'scale': 2, 'transitions': [{'property': 'motion', 'duration': 400}]});
      expect(Transition.listFromJson(still['transitions']).length, 1);
    });

    test('keyframes and replacing tracks land where they did over the node\'s own scale and rotation', () {
      final (n, _) = migrated({
        'scale': 2,
        'layout': {'width': 100, 'height': 40, 'rotation': 10},
        'transitions': [
          {'property': 'scale', 'duration': 200, 'keyframes': [{'at': 0.5, 'value': 1.1}]},
          {'property': 'motion', 'duration': 200, 'keyframes': [{'at': 0.5, 'value': {'rotate': 5}}]},
        ],
        'animations': [
          {'id': 'a', 'tracks': [
            {'path': 'motion.scale', 'from': 0.5, 'to': 1},
            {'path': 'layout.rotation', 'from': 0, 'to': 90},
            {'path': 'scale', 'to': r'${= big ? 2 : 1}'},
          ]},
        ],
      });
      final t = Transition.listFromJson(n['transitions']);
      expect(Transition.of(t, 'motion.scale')!.keyframesOf(''), [const Keyframe(at: 0.5, value: 1.1)]);
      expect(Transition.of(t, 'motion.rotate')!.keyframesOf('rotate'), [const Keyframe(at: 0.5, value: 15)]);
      final tracks = NodeAnimation.fromJson((n['animations'] as List).single)!.tracks;
      expect([for (final x in tracks) [x.path, x.from, x.to]], [
        ['motion.scale', 1, 2], // the motion's scale drawn over the node's 2
        ['motion.rotate', 0, 90], // the node's rotation replaced: the motion's own is 0
        ['motion.scale', null, r'${= big ? 2 : 1}'],
      ]);
    });

    test('state and media patches set the motion, at the patched node\'s values', () {
      final (n, report) = migrated({
        'motion': {'scale': 1.1, 'translateY': 2},
        'states': {
          'hovered': {'n': {'scale': 1.05}},
          'pressed': {'n': {'scale': 1, 'opacity': 0.8}},
          'selected': {'n': {'motion': {'translateY': -4}}},
        },
        'media': [{'minWidth': 600, 'patch': {'layout': {'rotation': 90}}}],
      });
      final states = (n['states'] as Map).cast<String, Object?>();
      expect((states['hovered'] as Map)['n'], {'motion': {'scale': 1.155}});
      // Set explicitly: pressed still wins over hovered.
      expect((states['pressed'] as Map)['n'], {'opacity': 0.8, 'motion': {'scale': 1.1}});
      expect((states['selected'] as Map)['n'], {'motion': {'translateY': -4}});
      expect(((n['media'] as List).single as Map)['patch'], {'motion': {'rotate': 90}});
      expect(report.rewrites.where((e) => e.step == 'patches.moved').length, 3);
    });

    test('a patch for a node the document does not hold is migrated alone', () {
      final (n, _) = migrated({
        'states': {'pressed': {'self': {'scale': 0.97, 'opacity': 0.82}}},
      });
      expect(((n['states'] as Map)['pressed'] as Map)['self'], {'opacity': 0.82, 'motion': {'scale': 0.97}});
    });

    test('setValue and condition paths move with the field, by the target\'s own motion', () {
      final (n, _) = migrated(
        {
          'motion': {'scale': 2},
          'actions': [
            {'trigger': {'type': 'click'}, 'actions': [
              {'type': 'setValue', 'node': 'n', 'values': [
                {'path': 'scale', 'value': 1.5},
                {'path': 'layout.rotation', 'value': r'${= a + 1}'},
                {'path': 'flightKey', 'value': 'x'},
              ]},
            ]},
          ],
        },
        extra: {
          'conditions': {
            'home': [
              {'branches': [{'when': null, 'sets': [{'node': 'n', 'path': 'scale', 'value': 3}]}]},
            ],
          },
        },
      );
      final values = ((((n['actions'] as List).single as Map)['actions'] as List).single as Map)['values'];
      expect(values, [
        {'path': 'motion.scale', 'value': 3},
        {'path': 'motion.rotate', 'value': r'${= a + 1}'},
        {'path': 'hero.tag', 'value': 'x'},
      ]);
      final doc = oneWay(doc3({'n': {'type': 'box', 'motion': {'scale': 2}}}, extra: {
        'conditions': {'home': [{'branches': [{'sets': [{'node': 'n', 'path': 'scale', 'value': 3}]}]}]},
      }));
      expect(jsonEncode(doc['conditions']), contains('{"node":"n","path":"motion.scale","value":6}'));
    });

    test('what cannot be the same picture is reported, not left behind', () {
      for (final (name, node) in <(String, Json)>[
        ('a flip', {'scale': 2, 'flip': {}}),
        ('a 3D motion turn', {'layout': {'width': 10, 'height': 10, 'rotation': 20}, 'motion': {'rotateY': 30}}),
        ('a motion alignment off its center', {'scale': 2, 'motion': {'alignment': [-1, -1]}}),
      ]) {
        final (n, report) = migrated(node);
        expect(n.containsKey('scale'), isFalse, reason: name);
        expect(report.behaviourChanges.single.message, contains(name));
      }
      final (_, bound) = migrated({'layout': {'width': 10, 'height': 10, 'margin': [8, 0, 0, 0]}, 'bind': {'layout.rotation': r'${a}'}});
      expect(bound.behaviourChanges.single.message, contains('uneven'));
      final (_, both) = migrated({
        'transitions': [{'property': 'motion', 'duration': 100}],
        'bind': {'scale': r'${s}', 'motion.scale': r'${m}'},
      });
      expect(both.behaviourChanges.single.message, contains('eased together'));
    });
  });

  group('hero.flight: one shared element', () {
    test('a flight key is a hero that flies in place, its flight and bindings with it', () {
      final (n, report) = migrated({
        'flightKey': 'react',
        'flight': {'duration': 720, 'lift': 110},
        'bind': {'flightKey': r'react-${emoji}', 'flight.turns': r'${t}'},
      });
      expect(n['hero'], {'tag': 'react', 'flies': 'inPlace', 'flight': {'duration': 720, 'lift': 110}});
      expect(n['bind'], {'hero.tag': r'react-${emoji}', 'hero.flight.turns': r'${t}'});
      expect(n.containsKey('flightKey') || n.containsKey('flight'), isFalse);
      expect(report.behaviourChanges, isEmpty);
      final hero = Node.fromJson(n, id: 'n')!.behaviors.hero!;
      expect([hero.tag, hero.flies, hero.flight!.duration], ['react', HeroFlies.inPlace, 720]);
    });

    test('a hero\'s flight look is its flightShuttle; a plain tag stays a tag', () {
      final (n, _) = migrated({'hero': {'tag': 'card', 'flight': 'morph', 'placeholder': 'source'}, 'bind': {'hero.flight': r'${look}'}});
      expect(n['hero'], {'tag': 'card', 'placeholder': 'source', 'flightShuttle': 'morph'});
      expect(n['bind'], {'hero.flightShuttle': r'${look}'});
      final (plain, report) = migrated({'hero': 'avatar'});
      expect(plain['hero'], 'avatar');
      expect(report.isEmpty, isTrue);
    });

    test('a node with a hero and a flight key keeps its hero and reports the flight key', () {
      final (n, report) = migrated({'hero': 'avatar', 'flightKey': 'tile', 'flight': {'duration': 300}});
      expect(n['hero'], 'avatar');
      expect([n['legacy.flightKey'], n['legacy.flight']], ['tile', {'duration': 300}]);
      expect(report.unconvertible.single.step, 'hero.flight');
      expect(report.behaviourChanges.single.message, contains('no longer flies in'));
    });

    test('a flight with no key never flew and is dropped', () {
      final (n, _) = migrated({'flight': {'duration': 300}, 'flightKey': ''});
      expect(n.containsKey('flight') || n.containsKey('flightKey') || n.containsKey('hero'), isFalse);
    });
  });

  group('the one spelling', () {
    test('a hero is its tag while the rest is Flutter\'s default, else an object', () {
      expect(const HeroTag('a').toJson(), 'a');
      const inPlace = HeroTag('r', flies: HeroFlies.inPlace, flight: Flight(duration: 300));
      expect(inPlace.toJson(), {'tag': 'r', 'flies': 'inPlace', 'flight': {'duration': 300}});
      expect(HeroTag.fromJson(inPlace.toJson()), inPlace);
      expect(HeroTag.fromJson({'tag': 'c', 'flightShuttle': 'containerTransform'})!.flightShuttle, HeroFlightShuttle.containerTransform);
    });

    test('30.0.0\'s keys in a schema-3 document are reported with where they went', () {
      final d = validateDocument({
        'schema': 3,
        'roots': ['home'],
        'nodes': {
          'home': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'b'}},
          'b': {
            'type': 'box',
            'layout': {'width': {'fill': 390}, 'height': {'fill': 844}, 'rotation': 5},
            'scale': 2,
            'flightKey': 'k',
            'hero': {'tag': 't', 'flight': 'morph'},
            'bind': {'scale': r'${s}'},
          },
        },
      });
      String? suggestion(String code, String path) =>
          d.where((x) => x.code.name == code && x.path == path).map((x) => x.suggestion).firstOrNull;
      expect(suggestion('unknown_layout_key', '/nodes/b/layout/rotation'), 'motion.rotate');
      expect(suggestion('unknown_node_key', '/nodes/b/scale'), 'motion.scale');
      expect(suggestion('unknown_node_key', '/nodes/b/flightKey'), 'hero.tag');
      expect(suggestion('wrong_type', '/nodes/b/hero/flight'), 'flightShuttle');
      expect(d.where((x) => x.code.name == 'unknown_bind_path').single.message, contains('motion.scale'));
    });

    test('a moved path in a transition, a track, a setValue or a condition, and a look set as a hero\'s flight, are reported', () {
      final d = validateDocument(doc3({
        'n': {
          'type': 'box',
          'layout': {'width': 10, 'height': 10},
          'transitions': [{'property': 'scale', 'duration': 100}],
          'animations': [
            {'id': 'a', 'duration': 100, 'tracks': [{'path': 'layout.rotation', 'keyframes': [{'at': 0, 'value': 0}, {'at': 1, 'value': 9}]}]},
          ],
          'actions': [
            {'trigger': {'type': 'click'}, 'actions': [{'type': 'setValue', 'node': 'n', 'values': [{'path': 'hero.flight', 'value': 'fade'}]}]},
          ],
        },
      }, extra: {
        'conditions': {'home': [{'branches': [{'set': [{'node': 'n', 'path': 'strokePath.progress', 'value': 1}]}]}]},
      }));
      final errors = [for (final x in d) if (x.severity == Severity.error && x.path != '/nodes/home/children') '${x.code.name} ${x.path}'];
      expect(errors, unorderedEquals([
        'unknown_bind_path /nodes/n/transitions/0/property',
        'unknown_bind_path /nodes/n/animations/0/tracks/0/path',
        'wrong_type /nodes/n/actions/0/actions/0/values/0/value',
        'unknown_bind_path /conditions/home/0/branches/0/set/0/path',
      ]));
    });

    test('a node scale or rotation binding path set from outside is refused with what to write', () {
      expect(movedPathHint('scale'), contains('motion.scale'));
      expect(movedPathHint('layout.rotation'), contains('motion.rotate'));
      expect(movedPathHint('flight.duration'), contains('hero.flight.duration'));
      expect(movedPathHint('motion.scale'), isNull);
    });
  });
}

/// The props renamed to Flutter's names after 30.1.0 (`props.renamed`).
void renamedPropsTests() {
  group('a time picker\'s use24h is Flutter\'s alwaysUse24HourFormat', () {
    test('its prop, its binding, a state patch and a setValue path are renamed', () {
      final doc = oneWay(doc3({
        't': {
          'type': 'timePicker',
          'layout': {'width': 160, 'height': 40},
          'props': {'value': '13:00', 'use24h': true},
          'bind': {'props.use24h': r'${h24}'},
          'states': {
            'hovered': {
              't': {'props': {'use24h': false}},
            },
          },
          'actions': [
            {
              'trigger': {'type': 'click'},
              'actions': [
                {'type': 'setValue', 'node': 't', 'values': [{'path': 'props.use24h', 'value': true}]},
              ],
            },
          ],
        },
      }));
      final t = nodeOf(doc, 't');
      expect(t['props'], {'value': '13:00', 'alwaysUse24HourFormat': true});
      expect(t['bind'], {'props.alwaysUse24HourFormat': r'${h24}'});
      expect(jsonEncode(t), isNot(contains('use24h')));
      final node = Node.fromJson(t, id: 't')!;
      expect(node.prop(TimePickerProps.alwaysUse24HourFormat), isTrue);
    });

    test('in a schema-3 document the old spelling is refused, naming the new one', () {
      final found = validateDocument(doc3({
        't': {'type': 'timePicker', 'layout': {'width': 160, 'height': 40}, 'props': {'use24h': true}},
      })).where((d) => d.code == Codes.unknownProp).single;
      expect(found.message, contains('alwaysUse24HourFormat'));
      expect(movedPathHint('props.use24h'), contains('props.alwaysUse24HourFormat'));
    });
  });
}
