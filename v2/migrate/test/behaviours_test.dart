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

void main() {
  test('motion, scale, loops and transitions', () {
    final report = MigrationReport();
    final v2 = migrateDocument(page({
      'r': {'type': 'rectangle', 'parentID': 'f', 'opacity': 0.8,
            'motion': {'rotate': -3.5, 'durationMs': 900, 'delayMs': 10, 'spinRampMs': 100, 'curve': 'easeOutBack',
                       'enterFrom': {'opacity': 0}},
            'drawScale': 1.15,
            'loopAnimation': {'type': 'pulse', 'scaleFrom': 0.65, 'durationMs': 1400},
            'pulse': {'pulseKind': 'relative', 'minOpacity': 0.2},
            'transitionMs': 120, 'transition': {'durationMillis': 1100},
            'sizeTransition': {'durationMillis': 300, 'curve': 'easeOutCubic'},
            'aspectRatioLock': false},
      'm': {'type': 'rectangle', 'parentID': 'f',
            'pulse': {'pulseKind': 'motion', 'opacityFrom': 0.55, 'opacityTo': 0, 'periodMs': 1400, 'scaleTo': 1.3}},
    }), report: report);
    final r = (v2['nodes'] as Map)['r'] as Map;
    expect(r['motion'], {'rotate': -3.5, 'duration': 900, 'delay': 10, 'curve': 'easeOutBack', 'spinRamp': 100,
                         'enterFrom': {'opacity': 0}});
    expect(r['scale'], 1.15);
    expect(r['loops'], [
      {'type': 'pulse', 'scaleFrom': 0.65, 'duration': 1400},
      {'type': 'fade', 'duration': 1100, 'reverse': true, 'curve': 'easeInOut', 'opacityFrom': 0.2},
    ]);
    expect(r['transitions'], {
      'style': {'duration': 120},
      'opacity': {'duration': 1100, 'curve': 'easeInOut'},
      'size': {'duration': 300, 'curve': 'easeOutCubic'},
    });
    expect((v2['nodes'] as Map)['m']['loops'], [
      {'type': 'pulse', 'duration': 1400, 'reverse': true, 'curve': 'easeInOut', 'scaleTo': 1.3, 'opacityFrom': 0.55,
       'opacityTo': 0},
    ]);
    expect(report.unmapped.keys.where((k) => k != 'canvas.createdTimestamp'), isEmpty);
  });

  test('interaction states become patches of v2 nodes', () {
    final v2 = migrateDocument(page({
      'b': {'type': 'rowColumn', 'rowColumnType': 'row', 'parentID': 'f', 'children': ['t'],
            'fills': [{'type': 'solid', 'color': '#FFFFFF', 'id': 'bf'}],
            'inkWell': {'overlayColor': '#1F000000', 'splashColor': '#1F000000'},
            'interactionStates': {
              'hovered': {'b': {'fills': [{'type': 'solid', 'color': '#EDE5D3'}]}, 't': {'data': 'Hover'}},
              'pressed': {'b': {'opacity': 0.5}},
            }},
      't': {'type': 'text', 'parentID': 'b', 'data': 'Hi', 'textMixedProps': [
        {'start': 0, 'end': 2, 'fontSize': 13, 'fontName': {'family': 'Inter'}, 'fills': []}]},
    }));
    final b = (v2['nodes'] as Map)['b'] as Map;
    expect(b['inkWell'], {'overlayColor': '#1F000000', 'splashColor': '#1F000000'});
    expect(b['states'], {
      'hovered': {
        'b': {'decoration': {'fills': [{'id': 'bf', 'color': '#FFEDE5D3'}]}},
        't': {'props': {'text': 'Hover'}},
      },
      'pressed': {'b': {'opacity': 0.5}},
    });
  });

  test('interaction, drag and drop, paths, effects and direction', () {
    final report = MigrationReport();
    final v2 = migrateDocument(page({
      'r': {'type': 'rectangle', 'parentID': 'f', 'tooltip': 'Hi', 'ignorePointer': true, 'zoomable': true,
            'floating': true, 'heroTag': 'card', 'heroFlight': 'morphCorners', 'flightKey': 'k',
            'draggable': {'group': 'g'}, 'dropTarget': {'accepts': ['g'], 'hoverDelayMs': 200},
            'drag': {'returnMs': 300, 'track': {'variable': 'v', 'max': 10}},
            'reveal': {'durationMs': 400},
            'strokePath': {'points': [{'x': 0, 'y': 1}, {'x': 1, 'y': 2}], 'color': '#FF5500', 'dash': [4, 2]},
            'effectAnimations': [{'name': 'shake', 'type': 'shake', 'durationMs': 400}],
            'particles': {'colors': ['#FF0000'], 'lifetimeMs': 1000, 'emitMs': 10},
            'variables': {'layoutDirection': 'rtl', 'drawScale': r'${s}'}},
      't': {'type': 'text', 'parentID': 'f', 'data': 'x', 'effects': [{'id': 'e', 'type': 'layerBlur', 'radius': 3}],
            'textMixedProps': [{'start': 0, 'end': 1, 'fontSize': 13, 'fontName': {'family': 'Inter'}, 'fills': []}]},
    }), report: report);
    final r = (v2['nodes'] as Map)['r'] as Map;
    expect(r['tooltip'], 'Hi');
    expect(r['ignorePointer'], true);
    expect(r['zoomable'], true);
    expect(r['floating'], true);
    expect(r['hero'], {'tag': 'card', 'flight': 'morphCorners'});
    expect(r['flightKey'], 'k');
    expect(r['draggable'], {'group': 'g'});
    expect(r['dropTarget'], {'accepts': ['g'], 'hoverDelay': 200});
    expect(r['drag']['snapBack'], 300);
    expect(r['drag']['track'], {'variable': 'v', 'max': 10.0});
    expect(r['reveal'], {'duration': 400});
    expect(r['strokePath'], {'points': [[0.0, 1.0], [1.0, 2.0]], 'color': '#FFFF5500', 'dashPattern': [4.0, 2.0]});
    expect(r['effectAnimations'], [{'name': 'shake', 'type': 'shake', 'duration': 400}]);
    expect(r['particles'], {'emit': 10, 'colors': ['#FFFF0000'], 'lifetime': 1000});
    expect(r['textDirection'], 'rtl');
    expect(r['bind'], {'scale': r'${s}'});
    expect((v2['nodes'] as Map)['t']['decoration'], {'effects': [{'type': 'layerBlur', 'blurRadius': 3.0}]});
    expect(report.unmapped.keys.where((k) => k != 'canvas.createdTimestamp'), isEmpty);
  });

  test('bound hero tags, effect cues and delays, particle cues', () {
    final report = MigrationReport();
    final v2 = migrateDocument(page({
      'r': {'type': 'rectangle', 'parentID': 'f', 'heroFlight': 'arc',
            'variables': {
              'heroTag': r'pass-${item.id}',
              'animations.nudge.playKey': r'${nudges}',
              'animations.nudge.delayMs': r'${wait}',
              'particles.playKey': r'${wins}',
            },
            'effectAnimations': [
              {'name': 'pop', 'type': 'pop'},
              {'name': 'nudge', 'type': 'shake', 'cycles': 6},
            ],
            'particles': {'count': 10}},
    }), report: report);
    final r = (v2['nodes'] as Map)['r'] as Map;
    expect(r['hero'], {'tag': '', 'flight': 'arc'});
    expect(r['bind'], {
      'hero.tag': r'pass-${item.id}',
      'effectAnimations[1].playKey': r'${nudges}',
      'effectAnimations[1].delay': r'${wait}',
      'particles.playKey': r'${wins}',
    });
    expect(report.unmapped.keys.where((k) => k != 'canvas.createdTimestamp'), isEmpty);
  });
}
