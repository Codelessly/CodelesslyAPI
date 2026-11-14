// Each step of the schema 2 → 3 migration on its own: what it rewrites, that
// it reports it under its id, and that running it again changes nothing.
// The legacy mappings in detail are tested where they were before schema 3
// (motion_migration_test, drag_split_test, animation_test, gestures_test),
// now through the migration (test/legacy_support.dart).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:codelessly_api/src/core/migrate/steps_spellings.dart' show spellingMigrationSteps;
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
    'states.target': {'key': 'card', 'states': {'hovered': {'self': {'opacity': 0.5}}, 'pressed': {'@card': {'opacity': 0.4}}}},
    'motion.legacy': {
      'motion': {'duration': 300, 'enter': true, 'enterFrom': {'opacity': 0}, 'originX': -1, 'opacity': 0.5, 'blur': 2},
      'loops': [{'type': 'pulse'}],
      'effectAnimations': [{'name': 'pop', 'type': 'pop'}],
      'bind': {'loops[0].phase': r'${p}', 'motion.opacity': r'${o}'},
    },
    'pose.legacy': {'props': {'pageMotionBefore': {'shiftX': 1, 'originX': -1, 'opacity': 0.5}}},
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
    'track.oneApp': {'track': {'variable': 'v', 'parkedProgress': -0.5, 'fineStep': 0.1, 'smooth': true, 'fineHold': 380}},
    'dismissible.oneApp': {'dismissible': {'rotateFactor': 10, 'restX': 0}},
    'pan.oneApp': {'pan': {'shareAs': 'drag'}},
    'path.oneApp': {'motion': {'path': {'path': 'M0 0 L1 0', 'pacing': 'area', 'focus': [1, 2], 'orient': 'uprightFlip'}}},
    'transition.arc': {'transitions': [{'property': 'motion', 'duration': 200, 'arc': 0.3}]},
    'dropTarget.oneApp': {
      'dropTarget': {'accepts': ['g'], 'acceptIf': r'${ok}', 'listNodeId': 'l', 'fullIf': r'${full}', 'hoverDelay': 0},
      'actions': [{'trigger': {'type': 'dropFull'}, 'actions': <Object?>[]}],
    },
    'gesture.oneApp': {'pan': {'physics': {'snap': {'points': [[0, 0]], 'projectVelocity': false}}}, 'transformGesture': {'rotationSnap': 15}},
    'openModal.unread': {'actions': [{'trigger': {'type': 'click'}, 'actions': [{'type': 'openModal', 'to': 'm', 'fullHeight': true}]}]},
    'trigger.clock': {'actions': [{'trigger': {'type': 'clock', 'every': 500, 'runWhen': r'${on}'}, 'actions': <Object?>[]}]},
  };

  final documentSamples = <String, Json>{
    'text.padding': {
      'type': 'text',
      'layout': {'padding': [4, 8, 4, 8]},
      'bind': {'layout.padding': r'${p}', 'opacity': r'${o}'},
      'media': [
        {'maxWidth': 600, 'patch': {'layout': {'padding': 2}, 'bind': {'layout.padding': r'${q}'}}},
      ],
      'states': {
        'hovered': {'n': {'layout': {'padding': 6}, 'opacity': 0.5}},
      },
    },
  };

  documentSamples['text.lineHeight'] = {
    'type': 'text',
    'props': {
      'text': 'ab',
      'style': {'fontSize': 12, 'naturalHeight': true},
      'runs': [
        {'start': 0, 'end': 1, 'style': {'color': '#FF000000'}},
      ],
    },
  };

  test('text.lineHeight: schema 2\'s 1.33 on the top-level nodes only; a natural style\'s node takes the font\'s own', () {
    final report = MigrationReport();
    final doc = migrate2to3({
      'schema': 2,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas', 'layout': {}, 'slots': {'body': 'col'}},
        'col': {'type': 'column', 'layout': {}, 'children': ['plain', 'nat', 'btn']},
        'plain': {'type': 'text', 'layout': {}, 'props': {'text': 'a', 'style': {'fontSize': 14}}},
        'nat': {
          'type': 'text',
          'layout': {},
          'props': {'text': 'b', 'style': {'fontSize': 14, 'naturalHeight': true}},
          'typewriter': {'caretAlignStyle': {'fontSize': 9}},
        },
        'btn': {
          'type': 'chip',
          'layout': {},
          'props': {'labelStyle': {'fontSize': 11, 'naturalHeight': false}},
          'states': {'hovered': {'plain': {'props': {'style': {'naturalHeight': true}}}}},
        },
        'dialog': {'type': 'box', 'layout': {}},
      },
    }, report: report);
    final nodes = (doc['nodes'] as Map).cast<String, Map>();
    expect(nodes['c']!['defaultTextStyle'], {'height': 1.33});
    expect(nodes['dialog']!['defaultTextStyle'], {'height': 1.33});
    for (final id in ['col', 'plain', 'btn']) {
      expect(nodes[id]!.containsKey('defaultTextStyle'), isFalse, reason: id);
    }
    expect(nodes['nat']!['defaultTextStyle'], <String, Object?>{});
    expect((nodes['nat']!['props'] as Map)['style'], {'fontSize': 14});
    expect((nodes['nat']!['typewriter'] as Map)['caretAlignStyle'], {'fontSize': 9, 'height': 1.33});
    expect((nodes['btn']!['props'] as Map)['labelStyle'], {'fontSize': 11});
    expect((((nodes['btn']!['states'] as Map)['hovered'] as Map)['plain'] as Map), {'props': {'style': <String, Object?>{}}});
    expect(report.behaviourChanges.map((e) => e.path), ['/nodes/btn/states/hovered/plain/props/style/naturalHeight']);
    expect(jsonEncode(doc), isNot(contains('naturalHeight')));
    // Decoded: the text below the canvas inherits 1.33 (the nearest default wins).
    final d = LayoutDocument.fromJson(doc, catalog: standardCatalog);
    expect(d['c']!.behaviors.defaultTextStyle, const TextStyle(height: 1.33));
    expect(d['nat']!.behaviors.defaultTextStyle, TextStyle.empty);
    // Again: nothing changes.
    expect(jsonEncode(migrate2to3({...doc, 'schema': 2})), jsonEncode({...doc}));
  });

  test('text.lineHeight: a natural text\'s runs inherit its base; a natural run beside 1.33 ones is reported', () {
    final (out, report) = migrated(documentSamples['text.lineHeight']!);
    expect(out['defaultTextStyle'], <String, Object?>{});
    expect(((out['props'] as Map)['runs'] as List).single, {'start': 0, 'end': 1, 'style': {'color': '#FF000000'}});
    expect(report.behaviourChanges, isEmpty);
    final (out2, report2) = migrated({
      'type': 'text',
      'props': {
        'text': 'ab',
        'style': {'fontSize': 12},
        'runs': [
          {'start': 0, 'end': 1, 'style': {'naturalHeight': true}},
        ],
      },
    });
    expect((out2['props'] as Map)['style'], {'fontSize': 12, 'height': 1.33});
    expect(report2.behaviourChanges.single.path, '/nodes/n/props/runs');
  });

  test('a schema-2 path an action names is refused with the schema-3 path (schema2PathHint, unknown_bind_path)', () {
    expect(schema2PathHint('loops[1].duration'), contains('animations.loop1.duration'));
    expect(schema2PathHint('drag.track.min'), '"track.min"');
    expect(schema2PathHint('motion.originX'), contains('motion.alignment'));
    expect(schema2PathHint('props.style.naturalHeight'), contains('defaultTextStyle'));
    for (final ok in ['motion.scale', 'motion.path.progress', 'opacity', 'track.value', 'props.text']) {
      expect(schema2PathHint(ok), isNull, reason: ok);
    }
    final doc = {
      'schema': 3,
      'roots': ['c'],
      'nodes': {
        'c': {
          'type': 'canvas',
          'layout': {'width': 390, 'height': 844},
          'actions': [
            {
              'trigger': {'type': 'click'},
              'actions': [
                {'type': 'setValue', 'node': 'c', 'values': [{'path': 'motion.originY', 'value': 1}]},
              ],
            },
          ],
        },
      },
    };
    final d = validateDocument(doc).where((x) => x.code == Codes.unknownBindPath).single;
    expect(d.message, contains('motion.alignment'));
  });

  test('every step has a sample here (30.1.0\'s one-way steps in test/migrate_spellings_test.dart and test/migrate_paint_test.dart)', () {
    final oneWay = {for (final s in spellingMigrationSteps) s.id};
    expect(byId.keys.toSet().difference({...samples.keys, ...documentSamples.keys, 'patches.legacy', ...oneWay}), isEmpty);
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

  test('text.padding: a text\'s padding, its bindings and the patches that set it are dropped; others keep theirs', () {
    final (out, report) = migrated(documentSamples['text.padding']!, others: {
      'b': {'type': 'box', 'layout': {'padding': 4}, 'states': {'pressed': {'n': {'layout': {'padding': 1, 'width': 9}}, 'b': {'layout': {'padding': 2}}}}},
    });
    expect(out['layout'], <String, Object?>{});
    expect(out['bind'], {'opacity': r'${o}'});
    expect(((out['media'] as List).single as Map)['patch'], <String, Object?>{});
    expect(((out['states'] as Map)['hovered'] as Map)['n'], {'opacity': 0.5});
    expect(report.entries.where((e) => e.step == 'text.padding').length, 6);
    expect(report.unconvertible, isEmpty);
    expect(report.behaviourChanges, isEmpty);
    // Run on the whole document (the box's own padding and its patch of itself stay).
    final doc = migrate2to3({
      'schema': 2,
      'nodes': {
        'n': {'type': 'text', 'layout': {'padding': 3}},
        'b': {'type': 'box', 'layout': {'padding': 4}, 'states': {'pressed': {'n': {'layout': {'padding': 1, 'width': 9}}, 'b': {'layout': {'padding': 2}}}}},
      },
    });
    final b = (doc['nodes'] as Map)['b'] as Map;
    expect(b['layout'], {'padding': 4});
    expect((b['states'] as Map)['pressed'], {'n': {'layout': {'width': 9}}, 'b': {'layout': {'padding': 2}}});
    expect(identical(migrate2to3(doc), doc), isTrue);
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

  test('pose.legacy: a page view pose and a route transition side', () {
    final (out, _) = migrated({
      'type': 'pageView',
      'props': {'pageMotionBefore': {'shiftX': 1, 'originX': -1, 'opacity': 0.5}},
      'actions': [
        {
          'trigger': {'type': 'click'},
          'actions': [
            {'type': 'navigate', 'transition': {'enter': {'motion': {'originY': 1, 'scale': 0.9}}}},
          ],
        },
      ],
    });
    expect((out['props'] as Map)['pageMotionBefore'], {'shiftX': 1, 'alignment': [-1, 0], 'opacity': 0.5});
    final nav = (((out['actions'] as List).single as Map)['actions'] as List).single as Map;
    expect(((nav['transition'] as Map)['enter'] as Map)['motion'], {'scale': 0.9, 'alignment': [0, 1]});
  });

  test('a deprecated field that did something is kept as legacy.<name>, said with what to write and who used it', () {
    final (out, report) = migrated({'track': {'variable': 'v', 'parkedProgress': -0.5, 'fineHold': 200, 'smooth': false}});
    expect(out['track'], {'variable': 'v'});
    expect(out['legacy.track.parkedProgress'], -0.5);
    // fineHold without a fine step, smooth at its default: they did nothing.
    expect(out.keys.where((k) => k.startsWith('legacy.')), ['legacy.track.parkedProgress']);
    final change = report.behaviourChanges.single;
    expect(change.instead, contains('apiary'));
    expect(report.unconvertible.single.instead, contains('track.value'));
  });

  test('dropTarget.oneApp: a refused drag no longer opens the slot, said once', () {
    final (out, report) = migrated({
      'dropTarget': {'accepts': ['g'], 'acceptIf': r'${ok}', 'listNodeId': 'l'},
    });
    expect(out['dropTarget'], {'accepts': ['g'], 'acceptIf': r'${ok}', 'listNodeId': 'l'});
    expect(report.behaviourChanges.single.message, contains('acceptIf'));
  });

  test('a clock with a formula interval is a timer that validates (intervalMs takes an expression)', () {
    final doc = migrate2to3({
      'schema': 2,
      'roots': ['c'],
      'nodes': {
        'c': {
          'type': 'canvas',
          'layout': {'width': 390, 'height': 844},
          'actions': [
            {'trigger': {'type': 'clock', 'every': '1000 / speed'}, 'actions': <Object?>[]},
          ],
        },
      },
      'variables': {
        'c': [
          {'name': 'speed', 'type': 'decimal', 'value': 2},
        ],
      },
    });
    final trigger = ((((doc['nodes'] as Map)['c'] as Map)['actions'] as List).single as Map)['trigger'];
    expect(trigger, {'type': 'timer', 'intervalMs': r'${= 1000 / speed}'});
    expect(validateDocument(doc).where((d) => d.code == Codes.wrongType), isEmpty);
  });

  test('path.oneApp: uprightFlip is upright', () {
    final (out, _) = migrated({'motion': {'path': {'path': 'M0 0', 'orient': 'uprightFlip'}}});
    expect((out['motion'] as Map)['path'], {'path': 'M0 0', 'orient': 'upright'});
    expect(out['legacy.motion.path.orient'], 'uprightFlip');
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
