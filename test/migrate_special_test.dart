// The last special-case fields, each said with a general mechanism: the
// steps that rewrite them (steps_special.dart), what the result decodes to,
// and validation refusing the old spelling in a schema-3 document.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

import 'migrate_spellings_test.dart' show doc3, nodeOf, oneWay;

/// Node [node] (id `n`) through the one-way steps, with its report.
(Json, Json, MigrationReport) migrate(Json node, {Map<String, Object?> others = const {}}) {
  final report = MigrationReport(document: 't');
  final doc = oneWay(doc3({'n': node, ...others}), report: report);
  return (nodeOf(doc, 'n'), doc, report);
}

/// The error codes of [doc] by path.
List<String> errors(Json doc) => [
      for (final d in validateDocument(doc))
        // doc3's canvas lists its children as a test document does.
        if (d.isError && d.path != '/nodes/home/children') '${d.code.name} ${d.path}: ${d.message}',
    ];

void main() {
  group('a text that counts up is a transition and an animation of its text', () {
    test('countUp with its timing becomes a transition of props.text and a count from 0 when it shows', () {
      final (n, doc, report) = migrate({
        'type': 'text',
        'layout': {'width': 100, 'height': 20},
        'props': {'text': r'$1,204', 'countUp': true, 'countUpDuration': 800, 'countUpCurve': 'easeOutCubic'},
      });
      expect(n['props'], {'text': r'$1,204'});
      expect(n['transitions'], [
        {'property': 'props.text', 'duration': 800, 'curve': 'easeOutCubic'},
      ]);
      expect(n['animations'], [
        {
          'id': 'countUp',
          'duration': 800,
          'curve': 'easeOutCubic',
          'tracks': [
            {'path': 'props.text', 'from': 0},
          ],
        },
      ]);
      expect(report.rewrites.map((e) => e.step).toSet(), {'text.countUp'});
      expect(errors(doc), isEmpty);
    });

    test('countUpOnShow off writes only the transition; countUp off drops the timing', () {
      final (on, _, _) = migrate({'type': 'text', 'props': {'text': '1', 'countUp': true, 'countUpOnShow': false}});
      expect(on['transitions'], [
        {'property': 'props.text', 'duration': 500},
      ]);
      expect(on.containsKey('animations'), isFalse);
      final (off, _, _) = migrate({'type': 'text', 'props': {'text': '1', 'countUpDuration': 900}});
      expect(off['props'], {'text': '1'});
      expect(off.containsKey('transitions'), isFalse);
    });

    test('a number in a text counts, written as the end writes it', () {
      expect(AnimationTrack.lerpValue(0, r'$1,204.50', 0, text: true), r'$0.00');
      expect(AnimationTrack.lerpValue(0, r'$1,204.50', 0.5, text: true), r'$602.25');
      expect(AnimationTrack.lerpValue('87%', '91%', 0.5, text: true), '89%');
      expect(AnimationTrack.lerpValue(r'$1,204.50', r'$1,204.50', 1, text: true), r'$1,204.50');
      expect(AnimationTrack.lerpValue(0, '1204', 0.5, text: true), '602');
      // Not a text's value: as before (a number written as text is a
      // number; a color is a color).
      expect(AnimationTrack.lerpValue(0, '1204', 0.5), 602.0);
      expect(AnimationTrack.lerpValue('#000000FF', '#FF0000FF', 0.5), isNot(isA<String>()));
      // No number in the end: switches at the end, as before.
      expect(AnimationTrack.lerpValue(0, 'done', 0.5, text: true), 0);
      const track = AnimationTrack(path: 'props.text', from: 0);
      expect(track.valueAt(0.25, own: '-40 °C', text: true), '-10 °C');
    });
  });

  group('a slider\'s ruler, marker, fade and grip are its custom paint', () {
    test('a ruler track\'s baseline and ticks are line ops over the track, in the ruler\'s colors', () {
      final (n, doc, _) = migrate({
        'type': 'slider',
        'layout': {'width': 300, 'height': 40},
        'props': {'trackShape': 'ruler', 'rulerTicks': 10, 'rulerMajorEvery': 2, 'rulerTickColor': '#FF22302A', 'rulerMinorTickColor': '#FF56645C'},
      });
      expect(n['props'], {'trackShape': 'ruler'});
      final ops = (n['customPaint'] as Map)['painter'] as List;
      expect(ops.map((o) => (o as Map)['id']), ['rulerBaseline', 'rulerTicks']);
      final ticks = ops[1] as Map;
      expect(ticks['count'], r'${= 10 + 1}');
      expect(jsonEncode(ticks), contains(r'index % 2 == 0'));
      expect(jsonEncode(ticks), contains('#FF56645C'));
      expect(errors(doc), isEmpty);
    });

    test('a ruler with no ruler fields still gets its default ticks (20, every fifth long, black)', () {
      final (n, _, _) = migrate({'type': 'slider', 'layout': {'width': 300, 'height': 40}, 'props': {'trackShape': 'ruler'}});
      final ticks = ((n['customPaint'] as Map)['painter'] as List)[1] as Map;
      expect(ticks['count'], r'${= 20 + 1}');
      expect(jsonEncode(ticks), contains('index % 5 == 0'));
      expect(jsonEncode(ticks), contains('#FF000000'));
      // Once they are ops, the step leaves them.
      final again = oneWay(doc3({'n': n}));
      expect(((nodeOf(again, 'n')['customPaint'] as Map)['painter'] as List).length, 2);
    });

    test('a marker is a rect op at its value along the track rect; a bound value is read in the op', () {
      final (n, doc, report) = migrate({
        'type': 'slider',
        'layout': {'width': 200, 'height': 40},
        'props': {'fillFromEnd': true, 'markerValue': 0.25, 'markerColor': '#FFFF0000', 'markerWidth': 3},
        'bind': {'props.markerHeight': r'${h}'},
      });
      final marker = ((n['customPaint'] as Map)['painter'] as List).single as Map;
      expect(marker['id'], 'marker');
      expect((marker['rect'] as List)[0], contains('clamp((0.25 - slider.min) / (slider.max - slider.min), 0, 1) - 3 / 2'));
      expect((marker['rect'] as List)[3], r'${= (h)}');
      expect(n.containsKey('bind'), isFalse);
      expect(report.behaviorChanges, isEmpty, reason: 'fillFromEnd keeps the plain track the marker drew on');
      expect(errors(doc), isEmpty);
    });

    test('a marker without fillFromEnd reports that the track is now its trackShape\'s', () {
      final (_, _, report) = migrate({'type': 'slider', 'props': {'markerValue': 0.5}});
      expect(report.behaviorChanges.single.message, contains('trackShape'));
    });

    test('a rectangular thumb\'s grip is a rect over the thumb, at its center', () {
      final (n, doc, _) = migrate({
        'type': 'slider',
        'layout': {'width': 200, 'height': 40},
        'props': {'thumbShape': 'rectangle', 'thumbSize': [20, 30], 'thumbGripColor': '#FF101010'},
      });
      final grip = ((n['customPaint'] as Map)['foregroundPainter'] as List).single as Map;
      expect(grip['rect'], [r'${= slider.thumbCenter.x - 4.3}', r'${= slider.thumbCenter.y - 1}', 8.6, 2]);
      expect(grip['paint'], {'color': '#FF101010'});
      expect(errors(doc), isEmpty);
    });

    test('the fade over an opaque inactive track is a gradient of that color from 1 − opacity to none', () {
      final (n, _, report) = migrate({
        'type': 'slider',
        'props': {'fillFromEnd': true, 'activeTrackStartOpacity': 0.2, 'inactiveTrackColor': '#FFDDDDDD'},
      });
      final fade = ((n['customPaint'] as Map)['painter'] as List).single as Map;
      expect(fade['id'], 'activeTrackFade');
      expect(jsonEncode(fade), contains('#CCDDDDDD'));
      expect(report.behaviorChanges, isEmpty);
      final (_, _, without) = migrate({'type': 'slider', 'props': {'activeTrackStartOpacity': 0.2}});
      expect(without.behaviorChanges.single.message, contains('inactiveTrackColor'));
    });

    test('deriveOverlayColorFromThumb, read by no renderer, is dropped', () {
      final (n, doc, report) = migrate({'type': 'slider', 'props': {'deriveOverlayColorFromThumb': false, 'value': 0.5}});
      expect(n['props'], {'value': 0.5});
      expect(n.containsKey('customPaint'), isFalse);
      expect(report.behaviorChanges, isEmpty);
      expect(errors(doc), isEmpty);
    });
  });

  group('a text field\'s highlight is its runs', () {
    test('a literal range is the first run', () {
      final (n, doc, _) = migrate({
        'type': 'textField',
        'layout': {'width': 200, 'height': 40},
        'props': {'highlightStart': 2, 'highlightEnd': 5, 'highlightStyle': {'color': '#FFB3261E'}},
      });
      expect(n['props'], {
        'runs': [
          {'start': 2, 'end': 5, 'style': {'color': '#FFB3261E'}},
        ],
      });
      expect(Node.fromJson(n, id: 'n')!.prop(TextFieldProps.runs).single.end, 5);
      expect(errors(doc), isEmpty);
    });

    test('a style alone or an empty range highlighted nothing and is dropped', () {
      final (a, _, _) = migrate({'type': 'textField', 'props': {'highlightStyle': {'color': '#FFB3261E'}}});
      expect(a.containsKey('props'), isFalse);
      final (b, _, _) = migrate({'type': 'textField', 'props': {'highlightStart': 4, 'highlightEnd': 4}});
      expect(b.containsKey('props'), isFalse);
    });

    test('bound ends make the runs a formula that has no run while either is null', () {
      final (n, _, _) = migrate({
        'type': 'textField',
        'props': {'highlightStyle': {'color': '#FFB3261E'}},
        'bind': {'props.highlightStart': r'${err.start}', 'props.highlightEnd': r'${= err.start + err.length}'},
      });
      expect((n['bind'] as Map).keys, ['props.runs']);
      expect((n['bind'] as Map)['props.runs'],
          r'${= (err.start) == null || (err.start + err.length) == null || (err.start + err.length) <= (err.start) ? [] : '
          "[{'start': err.start, 'end': err.start + err.length, 'style': {'color': '#FFB3261E'}}]}");
    });
  });

  group('a table\'s selected row edge is its cell template\'s selected style', () {
    test('the edge becomes a left stroke while the cell is the first of the selected row', () {
      final (_, doc, report) = migrate({
        'type': 'tableView',
        'layout': {'width': 300, 'height': 200},
        'props': {'selectedRow': 1, 'selectedRowColor': '#FFEEEEEE', 'selectedRowEdgeColor': '#FF0057FF', 'selectedRowEdgeWidth': 3},
        'slots': {'cell': 'cell'},
      }, others: {
        'cell': {'type': 'text', 'layout': {'width': {'fill': 1}, 'height': {'fill': 1}}, 'props': {'text': r'${item.value}'}},
      });
      final table = nodeOf(doc, 'n'), cell = nodeOf(doc, 'cell');
      expect(table['props'], {'selectedRow': 1, 'selectedRowColor': '#FFEEEEEE'});
      expect(cell['bind'], {'selected': r'${= item.rowIndex == (1) && item.columnIndex == 0}'});
      expect(cell['states'], {
        'selected': {
          'cell': {
            'decoration': {
              'strokes': [
                {'color': '#FF0057FF'},
              ],
              'strokeWidth': 3,
              'strokeSides': 'left',
            },
          },
        },
      });
      expect(report.behaviorChanges, isEmpty);
    });

    test('a template that does not fill its cell is reported: the edge is on its box', () {
      final (_, _, report) = migrate({
        'type': 'tableView',
        'props': {'selectedRowEdgeColor': '#FF0057FF'},
        'bind': {'props.selectedRow': r'${row}'},
        'slots': {'cell': 'cell'},
      }, others: {
        'cell': {'type': 'text', 'props': {'text': r'${item.value}'}},
      });
      expect(report.behaviorChanges.single.message, contains('first cell\'s box'));
    });
  });

  group('a date/time input\'s displayFormat is its format', () {
    test('displayFormat becomes format when format is unset; a set format wins as it did', () {
      final (n, doc, _) = migrate({'type': 'dateTimeInput', 'layout': {'width': 200, 'height': 48}, 'props': {'displayFormat': 'EEE, MMM d'}});
      expect(n['props'], {'format': 'EEE, MMM d'});
      expect(errors(doc), isEmpty);
      final (both, _, _) = migrate({'type': 'dateTimeInput', 'props': {'format': 'y', 'displayFormat': 'EEE'}});
      expect(both['props'], {'format': 'y'});
    });

    test('a named style is reported: format reads intl patterns', () {
      final (_, _, report) = migrate({'type': 'dateTimeInput', 'props': {'displayFormat': 'full'}});
      expect(report.behaviorChanges.single.message, contains('named style'));
    });
  });

  group('in a schema-3 document the removed props are refused, naming the general form', () {
    test('each removed prop is an unknown prop whose message says what to write', () {
      final cases = {
        'text': ['countUp', 'transition of "props.text"'],
        'slider': ['rulerTicks', '"customPaint"'],
        'textField': ['highlightStart', '"runs"'],
        'tableView': ['selectedRowEdgeColor', '"selected" state style'],
        'dateTimeInput': ['displayFormat', '"format"'],
      };
      for (final e in cases.entries) {
        final found = validateDocument(doc3({
          'x': {'type': e.key, 'layout': {'width': 100, 'height': 40}, 'props': {e.value[0]: 1}},
        })).where((d) => d.code == Codes.unknownProp && d.path.endsWith(e.value[0])).single;
        expect(found.message, contains(e.value[1]), reason: e.key);
      }
      expect(movedPathHint('props.markerValue'), contains('slider.trackRect'));
      expect(movedPathHint('props.highlightStyle.color'), contains('runs'));
    });

    test('a setValue of a removed path is rewritten where it has a place, else reported', () {
      final report = MigrationReport(document: 't');
      final doc = oneWay(doc3({
        'd': {'type': 'dateTimeInput', 'props': {'value': '2026-01-01'}},
        'b': {
          'type': 'box',
          'actions': [
            {
              'trigger': {'type': 'click'},
              'actions': [
                {'type': 'setValue', 'node': 'd', 'values': [{'path': 'props.displayFormat', 'value': 'y'}]},
                {'type': 'setValue', 'node': 'd', 'values': [{'path': 'props.markerValue', 'value': 1}]},
              ],
            },
          ],
        },
      }), report: report);
      final actions = (((nodeOf(doc, 'b')['actions'] as List).single as Map)['actions'] as List).cast<Map>();
      expect(((actions[0]['values'] as List).single as Map)['path'], 'props.format');
      expect(report.behaviorChanges.map((e) => e.message), contains(contains('props.markerValue')));
    });
  });
}
