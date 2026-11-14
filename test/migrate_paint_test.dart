// The paint steps of 30.1.0 (`paintSteps`, among the one-way steps that end
// `migrate2to3`), applied to 30.0.0's spellings: a stroke path becomes a customPaint path op, a box
// drawn as a path a path node, per-shape paints customPaint ops per color or
// per shape; what has no exact form is kept and reported. That the results
// draw the same pixels is tested in the SDK
// (test/custom_paint/migrated_paint_test.dart).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/migrate/legacy_svg.dart';
import 'package:codelessly_api/src/core/migrate/steps_spellings.dart' show spellingMigrationSteps;
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

/// [nodes] in 30.0.0's spellings through the one-way steps (whose last are
/// the paint steps), as migrate2to3 runs them after schema 2's, and the
/// report.
(Map<String, Json>, MigrationReport) _apply(Map<String, Json> nodes) {
  final report = MigrationReport(document: 't');
  final doc = migrate2to3({'schema': 2, 'nodes': nodes}, report: report, steps: spellingMigrationSteps);
  return ({for (final e in (doc['nodes'] as Map).entries) e.key as String: readMap(e.value)!}, report);
}

/// Node [node] (as `n`) after the paint steps.
(Json, MigrationReport) _node(Json node) {
  final (nodes, report) = _apply({'n': node});
  return (nodes['n']!, report);
}

Json _box(Json more) => {'type': 'box', 'layout': {'width': 100, 'height': 50}, ...more};

List<Object?> _painter(Json n, [String list = 'painter']) => (n['customPaint'] as Map)[list] as List;

void main() {
  group('strokePath', () {
    test('becomes a path op behind the content, its line Flutter\'s Paint with round joins', () {
      final (n, report) = _node(_box({
        'strokePath': {'points': [[0, 70], [0.25, 80], [1, 60]], 'color': '#FF102030', 'width': 2},
      }));
      expect(n.containsKey('strokePath'), isFalse);
      expect(_painter(n), [
        {
          'op': 'path',
          'id': 'strokePath',
          'points': [[0, 70], [r'${= 0.25 * size.width}', 80], [r'${size.width}', 60]],
          'paint': {'color': '#FF102030', 'style': 'stroke', 'strokeWidth': 2, 'strokeCap': 'round', 'strokeJoin': 'round'},
        },
      ]);
      expect(report.entries.single.step, 'paint.strokePath');
      expect(report.behaviorChanges, isEmpty);
    });

    test('inFront goes in the foreground painter, after what was there; behind goes first', () {
      final existing = {'op': 'rect', 'rect': [0, 0, 1, 1]};
      final (front, _) = _node(_box({
        'customPaint': {'painter': [existing], 'foregroundPainter': [existing]},
        'strokePath': {'points': [[0, 0], [10, 10]], 'xUnit': 'pixels', 'inFront': true},
      }));
      expect(_painter(front), [existing]);
      expect(_painter(front, 'foregroundPainter').last, containsPair('id', 'strokePath'));
      final (behind, _) = _node(_box({
        'customPaint': {'painter': [existing]},
        'strokePath': {'points': [[0, 0], [10, 10]], 'xUnit': 'pixels'},
      }));
      expect(_painter(behind).first, containsPair('id', 'strokePath'));
      expect(_painter(behind).last, existing);
    });

    test('progress becomes trimEnd; bound points, progress and color move into the op', () {
      final (n, _) = _node(_box({
        'strokePath': {'points': [[0, 0]], 'xUnit': 'pixels', 'progress': 0.5},
        'bind': {'strokePath.points': r'${route}', 'strokePath.progress': r'${p}', 'strokePath.color': r'${ink}', 'opacity': r'${o}'},
      }));
      final op = _painter(n).single as Map;
      expect(op['points'], r'${route}');
      expect(op['trimEnd'], r'${p}');
      expect((op['paint'] as Map)['color'], r'${ink}');
      expect(n['bind'], {'opacity': r'${o}'});
      final (literal, _) = _node(_box({'strokePath': {'points': [[0, 0], [1, 1]], 'progress': 0.5}}));
      expect((_painter(literal).single as Map)['trimEnd'], 0.5);
    });

    test('curves become Path calls, the midpoints computed as the painter computed them', () {
      final (n, _) = _node(_box({
        'strokePath': {'points': [[0, 10], [40, 30]], 'xUnit': 'pixels', 'curve': 'vertical'},
      }));
      expect((_painter(n).single as Map)['commands'], [
        {'moveTo': [0, 10]},
        {'cubicTo': [0, 20, 40, 20, 40, 30]},
      ]);
      final (q, _) = _node(_box({
        'strokePath': {'points': [[0, 0], [5, 9], [10, 0], [12, 3]], 'xUnit': 'pixels', 'curve': 'quadratic'},
      }));
      expect((_painter(q).single as Map)['commands'], [
        {'moveTo': [0, 0]},
        {'quadraticBezierTo': [5, 9, 10, 0]},
        {'lineTo': [12, 3]},
      ]);
    });

    test('untilWidth skips each segment that starts past the box, and every one after it', () {
      final (n, _) = _node(_box({
        'strokePath': {'points': [[0, 0], [50, 5], [120, 0], [90, 5], [200, 0]], 'xUnit': 'pixels', 'untilWidth': true},
      }));
      expect((_painter(n).single as Map)['commands'], [
        {'moveTo': [0, 0]},
        {'lineTo': [50, 5]},
        {'lineTo': [120, 0], 'when': r'${= size.width >= 50}'},
        {'lineTo': [90, 5], 'when': r'${= size.width >= 120}'},
        {'lineTo': [200, 0], 'when': r'${= size.width >= 120}'},
      ]);
      // In fractions of the box a start past 1 is past any width.
      final (f, _) = _node(_box({'strokePath': {'points': [[0, 0], [0.8, 5], [1.4, 0], [2, 5]], 'untilWidth': true}}));
      expect(((_painter(f).single as Map)['commands'] as List).length, 3);
    });

    test('points read as pairs or as x and y; one that is neither is skipped', () {
      final (n, _) = _node(_box({
        'strokePath': {'points': [[0, 1], {'x': 2, 'y': 3}, {'x': 'bad'}], 'xUnit': 'pixels'},
      }));
      expect((_painter(n).single as Map)['points'], [[0, 1], [2, 3]]);
    });

    test('fillColor is a closed path op under the line; its fade is written into the color', () {
      final (n, _) = _node(_box({
        'strokePath': {'points': [[0, 0], [10, 0], [10, 10]], 'xUnit': 'pixels', 'fillColor': '#FF00FF00', 'progress': 0.5},
      }));
      final ops = _painter(n).cast<Map>();
      expect(ops.map((o) => o['id']), ['strokePathFill', 'strokePath']);
      expect(ops.first['close'], isTrue);
      expect(ops.first['paint'], '#8000FF00');
    });

    test('a stroke path that drew nothing is dropped without an op', () {
      for (final sp in [
        {'points': [[0, 0]]},
        {'points': [[0, 0], [1, 1]], 'progress': 0},
      ]) {
        final (n, report) = _node(_box({'strokePath': sp}));
        expect(n.containsKey('strokePath'), isFalse);
        expect(n.containsKey('customPaint'), isFalse);
        expect(report.behaviorChanges, isEmpty);
      }
    });

    test('the draw-on becomes an animation of the line op\'s trimEnd and a transition of it, nothing kept', () {
      final (n, report) = _node(_box({
        'strokePath': {
          'points': [[0, 0], [1, 1]], 'drawMs': 600, 'drawDelayMs': 100, 'drawCurve': 'easeOutCubic', 'drawKey': 'k',
        },
      }));
      expect(n.keys.where((k) => k.startsWith('legacy.')), isEmpty);
      expect((_painter(n).single as Map).containsKey('trimEnd'), isFalse, reason: 'the track ends at the op\'s own 1');
      expect(n['animations'], [
        {
          'id': 'strokePathDraw',
          'duration': 600,
          'delay': 100,
          'curve': 'easeOutCubic',
          'tracks': [
            {'path': 'customPaint.painter.strokePath.trimEnd', 'from': 0},
          ],
        },
      ]);
      expect(n['transitions'], [
        {'property': 'customPaint.painter.strokePath.trimEnd', 'duration': 600, 'delay': 100, 'curve': 'easeOutCubic'},
      ]);
      expect(report.behaviorChanges, isEmpty);
      expect(report.unconvertible, isEmpty);
      // The node decodes to them.
      final node = Node.fromJson(n, id: 'n')!;
      expect(node.behaviors.animations.single.tracks.single.path, 'customPaint.painter.strokePath.trimEnd');
      expect(node.behaviors.transitions.single.duration, 600);
      // Without drawMs the timing fields did nothing.
      final (quiet, r2) = _node(_box({'strokePath': {'points': [[0, 0], [1, 1]], 'drawCurve': 'linear'}}));
      expect(quiet.keys.where((k) => k.startsWith('legacy.')), isEmpty);
      expect(quiet.containsKey('animations'), isFalse);
      expect(r2.behaviorChanges, isEmpty);
    });

    test('a drawn-on line in front with a fill fades the fill in from transparent, easeInOut by default', () {
      final (n, _) = _node(_box({
        'strokePath': {
          'points': [[0.1, 10], [0.9, 15], [0.8, 40]], 'fillColor': '#C0FF8800', 'progress': 0.5, 'inFront': true,
          'drawMs': 400,
        },
      }));
      final anim = (n['animations'] as List).single as Map;
      expect(anim['curve'], 'easeInOut');
      expect(anim['tracks'], [
        {'path': 'customPaint.foregroundPainter.strokePath.trimEnd', 'from': 0},
        {'path': 'customPaint.foregroundPainter.strokePathFill.paint', 'from': '#00FF8800'},
      ]);
    });

    test('a drawn-on line on a node that has an animation of that id takes the next free id', () {
      final (n, _) = _node(_box({
        'animations': [
          {'id': 'strokePathDraw', 'tracks': <Object?>[]},
        ],
        'strokePath': {'points': [[0, 0], [1, 1]], 'drawMs': 300},
      }));
      expect([for (final a in n['animations'] as List) (a as Map)['id']], ['strokePathDraw', 'strokePathDraw2']);
    });

    test('what has no exact form keeps the whole behavior as a legacy value', () {
      final (n, report) = _node(_box({
        'strokePath': {'points': [[0, 0], [1, 1]]},
        'bind': {'strokePath.xUnit': r'${unit}'},
      }));
      expect(n['legacy.strokePath'], {
        'value': {'points': [[0, 0], [1, 1]]},
        'bind': {'strokePath.xUnit': r'${unit}'},
      });
      expect(n.containsKey('strokePath'), isFalse);
      expect(n.containsKey('bind'), isFalse);
      expect(report.unconvertible, hasLength(1));
      expect(report.behaviorChanges, hasLength(1));
    });
  });

  group('a box with a path', () {
    test('becomes a path node with the path as its data', () {
      final (n, report) = _node(_box({
        'props': {'path': 'M0 0 L10 10', 'strokeJoin': 'round', 'strokeMiterLimit': 2},
        'decoration': {'strokes': [{'color': '#FF000000'}], 'strokeWidth': 2},
        'bind': {'props.path': r'${shape}'},
      }));
      expect(n['type'], 'path');
      expect(n['props'], {'data': 'M0 0 L10 10', 'strokeJoin': 'round', 'strokeMiterLimit': 2});
      expect(n['bind'], {'props.data': r'${shape}'});
      expect(Node.fromJson(n, id: 'n')!.prop(PathProps.strokeMiterLimit), 2);
      expect(report.behaviorChanges.single.message, contains('bound path is empty'));
    });

    test('a box without a path loses the path props it never read', () {
      final (n, report) = _node(_box({'props': {'path': '', 'strokeJoin': 'bevel'}}));
      expect(n['type'], 'box');
      expect(n.containsKey('props'), isFalse);
      expect(report.rewrites, hasLength(2));
    });

    test('where the box painter drew differently, it is reported', () {
      final (_, report) = _node(_box({
        'props': {'path': 'M0 0 L200 0 L200 40 Z'},
        'decoration': {
          'fills': [{'color': '#FFFF0000', 'gradientPerSubpath': true}],
          'radius': 6,
          'strokes': [{'type': 'linear', 'stops': [{'position': 0, 'color': '#FF000000'}]}],
          'strokeWidth': 1,
          'effects': [{'type': 'innerShadow'}],
        },
      }));
      final said = report.behaviorChanges.map((e) => e.path).toSet();
      expect(said, {'/props/data', '/decoration/radius', '/decoration/strokes', '/decoration/effects'});
      expect(report.rewrites.map((e) => e.path), contains('/decoration/fills/0/gradientPerSubpath'));
    });

    test('a bare box filling across a stretching row that hugs it is reported', () {
      final (_, report) = _apply({
        'row': {'type': 'row', 'layout': {'width': 200, 'height': {'hug': 30}}, 'props': {'crossAxisAlignment': 'stretch'}, 'children': ['n', 'x']},
        'n': {'type': 'box', 'layout': {'width': 20, 'height': {'fill': 20}}, 'props': {'path': 'M0 0 L1 1'}},
        'x': {'type': 'box', 'layout': {'width': 20, 'height': 30}},
      });
      expect(report.behaviorChanges.single.path, '/nodes/n/layout');
    });
  });

  group('per-shape paints', () {
    test('subpathColors become one path op per color, in the order the colors first appear', () {
      final (n, report) = _node({
        'type': 'path',
        'layout': {'width': 100, 'height': 50},
        'props': {'data': 'M0 0 H10 V10 Z M20 0 H30 V10 Z M40 0 H50 V10 Z', 'subpathColors': ['#FFAA0000', '#FF00AA00']},
        'decoration': {'fills': [{'color': '#FF0000AA'}]},
      });
      expect(_painter(n), [
        {'op': 'path', 'd': 'M0 0 H10 V10 Z M40 0 H50 V10 Z', 'paint': '#FFAA0000'},
        {'op': 'path', 'd': 'M20 0 H30 V10 Z', 'paint': '#FF00AA00'},
      ]);
      expect(n['props'], isEmpty);
      expect(n.containsKey('decoration'), isFalse);
      expect(report.behaviorChanges, isEmpty);
    });

    test('a hole joins the shape around it; a null color keeps the fill\'s', () {
      final (n, _) = _node({
        'type': 'path',
        'layout': {'width': 100, 'height': 50},
        'props': {'data': 'M0 0 H40 V40 H0 Z M10 10 H30 V30 H10 Z M50 0 H60 V10 Z', 'subpathColors': [null, '#FF00AA00']},
        'decoration': {'fills': [{'color': '#FF0000AA'}]},
      });
      expect(_painter(n), [
        {'op': 'path', 'd': 'M0 0 H40 V40 H0 Z M10 10 H30 V30 H10 Z', 'paint': '#FF0000AA'},
        {'op': 'path', 'd': 'M50 0 H60 V10 Z', 'paint': '#FF00AA00'},
      ]);
    });

    test('colors read from text too, and an entry that is not a color keeps its place with the fill\'s color', () {
      final (n, _) = _node({
        'type': 'path',
        'layout': {'width': 100, 'height': 50},
        'props': {'data': 'M0 0 H10 V10 Z M20 0 H30 V10 Z M40 0 H50 V10 Z', 'subpathColors': '#FFAA0000, x; #FF00AA00'},
        'decoration': {'fills': [{'color': '#FF0000AA'}]},
      });
      expect(_painter(n), [
        {'op': 'path', 'd': 'M0 0 H10 V10 Z', 'paint': '#FFAA0000'},
        {'op': 'path', 'd': 'M20 0 H30 V10 Z', 'paint': '#FF0000AA'},
        {'op': 'path', 'd': 'M40 0 H50 V10 Z', 'paint': '#FF00AA00'},
      ]);
    });

    test('the path\'s view box becomes the custom paint\'s; strokes stay on the node', () {
      final (n, _) = _node({
        'type': 'path',
        'layout': {'width': 100, 'height': 50},
        'props': {'data': 'M0 0 H10 V10 Z', 'viewBox': [20, 20], 'subpathColors': ['#FFAA0000']},
        'decoration': {'fills': [{'color': '#FF0000AA'}], 'strokes': [{'color': '#FF000000'}], 'strokeWidth': 1},
      });
      expect((n['customPaint'] as Map)['viewBox'], [20, 20]);
      expect((n['props'] as Map)['data'], 'M0 0 H10 V10 Z');
      expect((n['decoration'] as Map)['strokes'], [{'color': '#FF000000'}]);
    });

    test('a gradient per shape becomes one op per shape with the gradient as its shader', () {
      final gradient = {'type': 'linear', 'stops': [{'position': 0, 'color': '#FFFF0000'}, {'position': 1, 'color': '#FF0000FF'}]};
      final (n, report) = _node({
        'type': 'path',
        'layout': {'width': 100, 'height': 50},
        'props': {'data': 'M0 0 H10 V10 Z M20 0 H30 V10 Z'},
        'decoration': {'fills': [{...gradient, 'gradientPerSubpath': true}]},
      });
      expect(_painter(n), [
        {'op': 'path', 'd': 'M0 0 H10 V10 Z', 'paint': {'shader': gradient}},
        {'op': 'path', 'd': 'M20 0 H30 V10 Z', 'paint': {'shader': gradient}},
      ]);
      expect(report.rewrites.last.message, contains('within a pixel\'s rounding'));
    });

    test('with shadows between the paints there is no exact form: kept and reported', () {
      final (n, report) = _node({
        'type': 'path',
        'layout': {'width': 100, 'height': 50},
        'props': {'data': 'M0 0 H10 V10 Z', 'subpathColors': '#FFAA0000, #FF00AA00'},
        'decoration': {'fills': [{'color': '#FF0000AA'}], 'effects': [{'type': 'dropShadow'}]},
      });
      expect(n['legacy.props.subpathColors'], {'subpathColors': '#FFAA0000, #FF00AA00'});
      expect(n.containsKey('customPaint'), isFalse);
      expect(report.behaviorChanges, hasLength(1));
    });

    test('gradientPerSubpath where only a path node read it is dropped', () {
      final (n, report) = _node(_box({
        'decoration': {'fills': [{'type': 'linear', 'gradientPerSubpath': true}]},
      }));
      expect((n['decoration'] as Map)['fills'], [{'type': 'linear'}]);
      expect(report.behaviorChanges, isEmpty);
    });
  });

  group('the paint steps over documents', () {
    test('a state patch setting a stroke path becomes a patch of the custom paint', () {
      final (nodes, _) = _apply({
        'n': _box({
          'strokePath': {'points': [[0, 0], [10, 10]], 'xUnit': 'pixels', 'color': '#FF000000'},
          'states': {
            'hovered': {
              'n': {'strokePath': {'color': '#FFFF0000'}},
            },
          },
        }),
      });
      final patch = ((nodes['n']!['states'] as Map)['hovered'] as Map)['n'] as Map;
      expect(patch.keys, ['customPaint']);
      final op = ((patch['customPaint'] as Map)['painter'] as List).single as Map;
      expect((op['paint'] as Map)['color'], '#FFFF0000');
    });

    test('running the steps again changes nothing, and the result decodes and re-encodes as itself', () {
      final nodes = {
        'a': _box({'strokePath': {'points': [[0, 1], [0.5, 9], [1, 3]], 'curve': 'horizontal', 'fillColor': '#FF00FF00', 'inFront': true}}),
        'b': _box({'props': {'path': 'M0 0 L9 9'}, 'decoration': {'strokes': [{'color': '#FF000000'}], 'strokeWidth': 1}}),
        'c': {'type': 'path', 'layout': {'width': 9, 'height': 9}, 'props': {'data': 'M0 0 H1 V1 Z M3 0 H4 V1 Z', 'subpathColors': ['#FF111111']},
              'decoration': {'fills': [{'color': '#FF0000AA'}]}},
      };
      final (once, _) = _apply(nodes);
      final (twice, report) = _apply(once);
      expect(jsonEncode(twice), jsonEncode(once));
      expect(report.isEmpty, isTrue);
      final doc = {'schema': 3, 'roots': <String>[], 'nodes': once};
      expect(identical(migrateDocument(doc), doc), isTrue);
      final e1 = LayoutDocument.fromJson(doc).toJson();
      expect(jsonEncode(LayoutDocument.fromJson(e1).toJson()), jsonEncode(e1));
      for (final n in LayoutDocument.fromJson(doc).nodes.values) {
        expect(n.extra, isEmpty);
      }
    });
  });

  group('in the whole migration', () {
    test('a schema-2 gradient per shape is path ops after schema 2\'s steps and the paint steps', () {
      final report = MigrationReport(document: 't');
      final doc = migrateDocument({
        'schema': 2,
        'nodes': {
          'n': {
            'type': 'path',
            'layout': {'width': 20, 'height': 10},
            'props': {'data': 'M0 0 H5 V5 Z M10 0 H15 V5 Z'},
            'decoration': {
              'fills': [
                {'type': 'linear', 'gradientUnits': 'subpath', 'stops': [{'color': '#FF000000'}, {'color': '#FFFFFFFF', 'position': 1}]},
              ],
            },
          },
        },
      }, report: report);
      expect(doc['schema'], 3);
      final n = (doc['nodes'] as Map)['n'] as Map<String, Object?>;
      expect(_painter(n).map((o) => (o as Map)['d']), ['M0 0 H5 V5 Z', 'M10 0 H15 V5 Z']);
      expect(report.entries.map((e) => e.step), containsAll(['paint.gradientUnits', 'paint.perShape']));
    });

    test('a state patch setting both a scale and a stroke path moves each where it went', () {
      final (nodes, _) = _apply({
        'n': _box({
          'strokePath': {'points': [[0, 0], [10, 10]], 'xUnit': 'pixels', 'color': '#FF000000'},
          'states': {
            'pressed': {
              'n': {'scale': 0.9, 'strokePath': {'color': '#FFFF0000'}},
            },
          },
        }),
      });
      final patch = ((nodes['n']!['states'] as Map)['pressed'] as Map)['n'] as Map;
      expect(patch.containsKey('scale'), isFalse);
      expect(patch.containsKey('strokePath'), isFalse);
      expect((patch['motion'] as Map)['scale'], 0.9);
      final op = ((patch['customPaint'] as Map)['painter'] as List).single as Map;
      expect((op['paint'] as Map)['color'], '#FFFF0000');
    });

    test('a node alone migrates its own paint patches too', () {
      final n = migrateNode(_box({
        'props': {'path': 'M0 0 L9 9'},
        'media': [
          {'minWidth': 600, 'patch': {'props': {'path': 'M0 0 L20 20'}}},
        ],
      }), id: 'n');
      expect(n['type'], 'path');
      expect(((n['media'] as List).single as Map)['patch'], {'props': {'data': 'M0 0 L20 20'}});
    });
  });

  group('what the migration keeps as legacy', () {
    test('a migrated draw-on validates clean', () {
      final doc = migrateDocument({
        'schema': 2,
        'roots': ['c'],
        'nodes': {
          'c': {'type': 'canvas', 'layout': {'width': 100, 'height': 100}, 'slots': {'body': 'n'}},
          'n': _box({'strokePath': {'points': [[0, 0], [1, 1]], 'drawMs': 600, 'fillColor': '#80000000'}}),
        },
      });
      expect(validateDocument(doc).where((d) => d.severity != Severity.info), isEmpty);
    });

    test('a kept stroke path is a legacy_value warning, is not read, and round-trips', () {
      final doc = migrateDocument({
        'schema': 2,
        'roots': ['c'],
        'nodes': {
          'c': {'type': 'canvas', 'layout': {'width': 100, 'height': 100}, 'slots': {'body': 'n'}},
          'n': _box({
            'strokePath': {'points': [[0, 0], [1, 1]]},
            'bind': {'strokePath.width': r'${w}'},
          }),
        },
      });
      final found = validateDocument(doc).where((d) => d.severity != Severity.info && d.code == Codes.legacyValue).toList();
      expect(found.map((d) => d.path), ['/nodes/n/legacy.strokePath']);
      expect(found.single.severity, Severity.warning);
      final n = LayoutDocument.fromJson(doc).nodes['n']!;
      expect(n.extra.keys, ['legacy.strokePath']);
      expect(n.toJson()['legacy.strokePath'], isNotNull);
    });
  });

  group('SVG path data split into shapes', () {
    test('every subpath, a relative move written absolute, a draw after Z starting where the subpath did', () {
      final parts = svgSubpaths('M0 0 L10 0 L10 10 Z m20 0 l5 5 z L3 3 M7 7 M8 8 h1')!;
      expect(parts.map((p) => p.text), ['M0 0 L10 0 L10 10 Z', 'M20 0 l5 5 z', 'M20 0 L3 3', 'M8 8 h1']);
      expect(parts.map((p) => p.absoluteStart), [true, false, false, true]);
      expect([parts.first.left, parts.first.top, parts.first.right, parts.first.bottom], [0, 0, 10, 10]);
    });

    test('an arc\'s bounds reach as far as the cubics it is drawn as', () {
      final circle = svgSubpaths('M0 10 A10 10 0 1 0 20 10 A10 10 0 1 0 0 10 Z')!.single;
      expect(circle.left, closeTo(0, 1e-9));
      expect(circle.right, closeTo(20, 1e-9));
      expect(circle.top, closeTo(0, 0.6));
      expect(circle.bottom, closeTo(20, 0.6));
    });
  });
}
