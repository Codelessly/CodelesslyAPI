// The paint steps of the schema 3 → 4 migration (`paintSteps4`), applied to
// schema-3 JSON directly: a stroke path becomes a customPaint path op, a box
// drawn as a path a path node, per-shape paints customPaint ops per color or
// per shape; what has no exact form is kept and reported. That the results
// draw the same pixels is tested in the SDK
// (test/custom_paint/migrated_paint_test.dart).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/migrate/legacy_svg.dart';
import 'package:test/test.dart';

/// Schema-3 [nodes] with the paint steps applied, and the report.
(Map<String, Json>, MigrationReport) _apply(Map<String, Json> nodes, {List<MigrationStep>? steps}) {
  final report = MigrationReport(document: 't');
  final doc = migrate2to3({'schema': 2, 'nodes': nodes}, report: report, steps: steps ?? paintSteps4);
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
      expect(report.behaviourChanges, isEmpty);
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
        expect(report.behaviourChanges, isEmpty);
      }
    });

    test('the draw-on animation is kept as a legacy value and reported', () {
      final (n, report) = _node(_box({
        'strokePath': {'points': [[0, 0], [1, 1]], 'drawMs': 600, 'drawKey': r'k'},
      }));
      expect(n['legacy.strokePath.draw'], {'drawMs': 600, 'drawKey': 'k'});
      expect(_painter(n), hasLength(1));
      expect(report.behaviourChanges.single.message, contains('no longer draws itself on'));
      // Without drawMs the timing fields did nothing.
      final (quiet, r2) = _node(_box({'strokePath': {'points': [[0, 0], [1, 1]], 'drawCurve': 'linear'}}));
      expect(quiet.keys.where((k) => k.startsWith('legacy.')), isEmpty);
      expect(r2.behaviourChanges, isEmpty);
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
      expect(report.behaviourChanges, hasLength(1));
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
      expect(report.behaviourChanges.single.message, contains('bound path is empty'));
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
      final said = report.behaviourChanges.map((e) => e.path).toSet();
      expect(said, {'/props/data', '/decoration/radius', '/decoration/strokes', '/decoration/effects'});
      expect(report.rewrites.map((e) => e.path), contains('/decoration/fills/0/gradientPerSubpath'));
    });

    test('a bare box filling across a stretching row that hugs it is reported', () {
      final (_, report) = _apply({
        'row': {'type': 'row', 'layout': {'width': 200, 'height': {'hug': 30}}, 'props': {'crossAxisAlignment': 'stretch'}, 'children': ['n', 'x']},
        'n': {'type': 'box', 'layout': {'width': 20, 'height': {'fill': 20}}, 'props': {'path': 'M0 0 L1 1'}},
        'x': {'type': 'box', 'layout': {'width': 20, 'height': 30}},
      });
      expect(report.behaviourChanges.single.path, '/nodes/n/layout');
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
      expect(report.behaviourChanges, isEmpty);
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
      expect(report.behaviourChanges, hasLength(1));
    });

    test('gradientPerSubpath where only a path node read it is dropped', () {
      final (n, report) = _node(_box({
        'decoration': {'fills': [{'type': 'linear', 'gradientPerSubpath': true}]},
      }));
      expect((n['decoration'] as Map)['fills'], [{'type': 'linear'}]);
      expect(report.behaviourChanges, isEmpty);
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
      final e1 = LayoutDocument.fromJson(doc).toJson();
      expect(jsonEncode(LayoutDocument.fromJson(e1).toJson()), jsonEncode(e1));
      for (final n in LayoutDocument.fromJson(doc).nodes.values) {
        expect(n.behaviors.strokePath, isNull);
      }
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
