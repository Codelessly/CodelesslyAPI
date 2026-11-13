// Each step of the schema 2 → 3 migration on its own: what it rewrites, that
// it reports it under its id, and that running it again changes nothing.
// The legacy mappings in detail are tested where they were before schema 3
// (motion_migration_test, drag_split_test, animation_test, gestures_test),
// now through the migration (test/legacy_support.dart).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// [node] migrated in a document, with its report.
(Json, MigrationReport) migrated(Json node, {Map<String, Object?> others = const {}}) {
  final report = MigrationReport(document: 't');
  final doc = migrate2to3({
    'schema': 2,
    'roots': ['n'],
    'nodes': {'n': {'type': 'box', 'layout': <String, Object?>{}, ...node}, ...others},
  }, report: report);
  return (((doc['nodes'] as Map)['n'] as Map).cast<String, Object?>(), report);
}

/// Runs [step] alone on [node] again: nothing changes.
void expectStable(MigrationStep step, Json node) {
  final again = migrate2to3({'schema': 2, 'nodes': {'n': node}}, steps: [step]);
  expect(jsonEncode((again['nodes'] as Map)['n']), jsonEncode(node), reason: step.id);
}

void main() {
  final byId = {for (final s in schema3Steps) s.id: s};

  final samples = <String, Json>{
    'motion.legacy': {
      'motion': {'duration': 300, 'enter': true, 'enterFrom': {'opacity': 0}, 'originX': -1, 'opacity': 0.5, 'blur': 2},
      'loops': [{'type': 'pulse'}],
      'effectAnimations': [{'name': 'pop', 'type': 'pop'}],
      'bind': {'loops[0].phase': r'${p}', 'motion.opacity': r'${o}'},
    },
    'drag.split': {'drag': {'release': 'dismiss', 'restX': 4}, 'bind': {'drag.enabled': r'${on}'}},
    'track.legacy': {'track': {'variable': 'v', 'endAngle': 90, 'jumpOnTap': true, 'momentum': true, 'write': false}},
    'zoomable': {'zoomable': true},
    'draggable.legacy': {'draggable': {'group': 'g', 'whileDragging': 'hidden', 'feedbackNodeId': 'f', 'springStiffness': 300}},
    'physics.flatSpring': {'pan': {'physics': {'stiffness': 200, 'damping': 20}}},
    'transitions.legacy': {'transitions': {'style': {'duration': 120}}},
    'paint.gradientUnits': {'decoration': {'fills': [{'type': 'linear', 'gradientUnits': 'subpath'}]}},
    'action.playAnimation': {'actions': [{'trigger': {'type': 'click'}, 'actions': [{'type': 'playAnimation', 'node': 'n', 'animation': 'pop'}]}]},
    'action.animateVariable': {'actions': [{'trigger': {'type': 'click'}, 'actions': [{'type': 'animateVariable', 'variable': 't', 'to': '5'}]}]},
    'action.setVariable.animateMs': {'actions': [{'trigger': {'type': 'click'}, 'actions': [{'type': 'setVariable', 'variable': 't', 'value': '5', 'animateMs': '300'}]}]},
    'action.controlDrag': {'actions': [{'trigger': {'type': 'click'}, 'actions': [{'type': 'controlDrag', 'node': 'n', 'command': 'step'}]}]},
    'trigger.clock': {'actions': [{'trigger': {'type': 'clock', 'every': 500, 'runWhen': r'${on}'}, 'actions': <Object?>[]}]},
  };

  test('every step has a sample here', () {
    expect(byId.keys.toSet().difference({...samples.keys, 'patches.legacy'}), isEmpty);
  });

  for (final e in samples.entries) {
    test('${e.key}: rewrites, reports and is stable', () {
      final (out, report) = migrated(e.value);
      expect(report.entries.map((x) => x.step), contains(e.key));
      for (final key in ['loops', 'effectAnimations', 'drag', 'zoomable']) {
        expect(out.containsKey(key), isFalse, reason: key);
      }
      expect(jsonEncode(out), isNot(contains('"playAnimation"')));
      expect(jsonEncode(out), isNot(contains('"clock"')));
      for (final step in schema3Steps.where((s) => s.node != null)) {
        expectStable(step, out);
      }
    });
  }

  test('patches.legacy: a state patch with legacy keys is the schema-3 patch that gives the same node', () {
    final (out, report) = migrated({
      'motion': {'scale': 1},
      'states': {
        'hovered': {
          'n': {'motion': {'originX': 1, 'opacity': 0.5}},
        },
      },
    });
    final patch = ((out['states'] as Map)['hovered'] as Map)['n'] as Map;
    expect(patch, {
      'motion': {'alignment': [1, 0]},
      'opacity': 0.5,
    });
    expect(report.entries.map((e) => e.step), contains('patches.legacy'));
    final node = Node.fromJson(out, id: 'n')!;
    final hovered = node.patched(node.behaviors.states.patchFor('n', {WidgetState.hovered})!);
    expect(hovered.behaviors.motion!.alignment, const Alignment(1, 0));
    expect(hovered.opacity, 0.5);
  });

  test('patches.legacy: a media patch with a drag', () {
    final (out, _) = migrated({
      'media': [
        {'maxWidth': 600, 'patch': {'zoomable': true}},
      ],
    });
    expect(((out['media'] as List).single as Map)['patch'], {
      'transformGesture': {'target': 'content', 'pan': 'whenZoomed'},
    });
  });

  test('a bound legacy origin binds the alignment', () {
    final (out, _) = migrated({
      'motion': {'originY': 1},
      'bind': {'motion.originX': r'${= x * 2}'},
    });
    expect(out['bind'], {'motion.alignment': r'${= [x * 2, 1]}'});
  });

  test('a setVariable glide that is not one formula sets at once, said as a behaviour change', () {
    final (out, report) = migrated({
      'actions': [
        {
          'trigger': {'type': 'click'},
          'actions': [
            {'type': 'setVariable', 'variable': 't', 'value': r'n = ${n}', 'animateMs': '300'},
          ],
        },
      ],
    });
    expect(((out['actions'] as List).single as Map)['actions'], [
      {'type': 'setVariable', 'variable': 't', 'value': r'n = ${n}'},
    ]);
    expect(report.behaviourChanges.single.step, 'action.setVariable.animateMs');
  });
}
