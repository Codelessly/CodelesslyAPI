// The retry protocol's pieces in the edit layer, on what live generations
// actually wrote: diagnostics that spell out the fix, a retry that tries to
// start over answered with start_over, the tool result that says what the
// document holds and how to fix it, and the lints a finished UI is checked
// with (a button with no label, text in its background's colour).
import 'dart:convert';

import 'package:codelessly_api/core.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

EditResult _apply(LayoutDocument doc, Object ops, {bool protectRoots = false}) => applyOps(doc, ops,
    catalog: Catalog.core, profile: TrustProfile.agent, check: strictEditCheck(), incomplete: true, protectRoots: protectRoots);

LayoutDocument _card() => _apply(LayoutDocument(catalog: Catalog.core), {
      'ops': [
        {'op': 'roots', 'roots': ['card']},
        {
          'op': 'set',
          'id': 'card',
          'node': {
            'type': 'canvas',
            'slots': {'body': 'wrap'},
            'layout': {'width': 390, 'height': {'hug': 200}},
          },
        },
        {
          'op': 'set',
          'id': 'wrap',
          'node': {
            'type': 'column',
            'children': ['title'],
            'layout': {'width': {'fill': 390}, 'height': {'hug': 200}, 'padding': 16},
            'decoration': {
              'fills': [{'color': '#FF0F172A'}],
            },
          },
        },
        {
          'op': 'set',
          'id': 'title',
          'node': {
            'type': 'text',
            'layout': {'width': {'fill': 358}, 'height': {'hug': 24}},
            'props': {'text': 'London to Lisbon', 'style': {'fontSize': 18, 'color': '#FFFFFFFF'}},
          },
        },
      ],
    }).document;

void main() {
  group('diagnostics models hit say how to fix them', () {
    test('a size written as a layout key', () {
      final r = _apply(_card(), {
        'op': 'set',
        'id': 't2',
        'parent': 'wrap',
        'node': {
          'type': 'text',
          'layout': {'width': {'hug': 160}, 'hug': 46},
          'props': {'text': 'x', 'style': {'color': '#FFFFFFFF'}},
        },
      });
      final d = r.errors.single;
      expect(d.code, 'unknown_layout_key');
      expect(d.message, contains('sizes go under width/height: "height": {"hug": 46}'));
      expect(d.suggestion, 'height');
    });
    test('children on a type that takes none name the types that do', () {
      final r = _apply(_card(), {
        'op': 'set',
        'id': 'tag',
        'parent': 'wrap',
        'node': {
          'type': 'box',
          'children': ['tagText'],
          'layout': {'width': 80, 'height': 24},
        },
      });
      final d = r.errors.firstWhere((d) => d.code == 'children_not_allowed');
      expect(d.message, contains('Types that take children: column, row, stack'));
      expect(d.message, contains('"type": "row"'));
      expect(d.expected, containsAll(['column', 'row', 'stack']));
      // Placing a child under it says the same.
      final under = _apply(_card(), [
        const SetOp('btn', {'type': 'box', 'layout': {'width': 80, 'height': 24}}, parent: 'wrap'),
        const SetOp('btnText', {'type': 'text', 'props': {'text': 'Go'}}, parent: 'btn'),
      ]);
      expect(under.errors.single.code, 'invalid_parent');
      expect(under.errors.single.message, contains('make the box a row or column'));
      expect(under.errors.single.path, '/ops/1/parent');
    });
    test('a button prop that is not one names the props and the one meant', () {
      final r = _apply(_card(), {
        'op': 'set',
        'id': 'go',
        'parent': 'wrap',
        'node': {'type': 'filledButton', 'layout': {'width': 120, 'height': 44}, 'props': {'text': 'Go'}},
      });
      final d = r.errors.single;
      expect(d.code, 'unknown_prop');
      expect(d.message, contains('Its props: label'));
      expect(d.suggestion, 'label');
    });
    test('an expression written as a plain value says to bind it, with the binding to write (question_flow, dashboard, carousel)', () {
      // Five recorded SSUI cards wrote a theme token or a condition where a
      // value goes: "radius": "${theme.radii.panel}", "visible": "${step > 0}".
      final r = _apply(_card(), [
        {
          'op': 'set',
          'id': 'panel',
          'parent': 'wrap',
          'node': {
            'type': 'column',
            'layout': {'width': {'fill': 358}, 'height': {'hug': 40}},
            'decoration': {'radius': r'${theme.radii.panel}', 'fills': [{'color': '#FFFFFFFF'}]},
          },
        },
        {
          'op': 'set',
          'id': 'back',
          'parent': 'wrap',
          'node': {'type': 'text', 'visible': r'${step > 0}', 'props': {'text': 'Back'}},
        },
      ]);
      final radius = r.errors.firstWhere((d) => d.path == '/nodes/panel/decoration/radius');
      expect(radius.code, 'wrong_type');
      expect(radius.message, contains(r'"bind": {"decoration.radius": "${theme.radii.panel}"}'));
      expect(radius.suggestion, 'bind.decoration.radius');
      final visible = r.errors.firstWhere((d) => d.path == '/nodes/back/visible');
      expect(visible.message, contains(r'"bind": {"visible": "${step > 0}"}'));
    });
    test('replacing the root canvas with a column is rejected, with how to set its body (image_gallery@claude-haiku-5-5 retry)', () {
      // The retry wrote {"op": "set", "id": "gallery", "slot": "body", "node":
      // {"type": "column", ...}}: the canvas became a column, and a view shows
      // nothing without a canvas.
      final r = _apply(_card(), {
        'op': 'set',
        'id': 'card',
        'slot': 'body',
        'node': {'type': 'column', 'children': ['wrap'], 'layout': {'width': {'fill': 390}, 'height': {'hug': 400}}},
      });
      expect(r.rejected, [0]);
      final d = r.errors.firstWhere((d) => d.path == '/nodes/card/type');
      expect(d.message, contains('"card" is the canvas this UI is shown on'));
      expect(d.message, contains('"parent": "card", "slot": "body"'));
      // A node its canvas's slot already names may be set with "slot" and no
      // "parent" (question_flow@claude-haiku-5-5's second retry did): it is placed.
      final card = _apply(LayoutDocument(catalog: Catalog.core), [
        {'op': 'roots', 'roots': ['quiz']},
        {'op': 'set', 'id': 'quiz', 'node': {'type': 'canvas', 'slots': {'body': 'body'}, 'layout': {'width': 390, 'height': 200}}},
        {'op': 'set', 'id': 'body', 'slot': 'body', 'node': {'type': 'column', 'layout': {'width': {'fill': 390}, 'height': {'hug': 40}}}},
      ]);
      expect(card.errors, isEmpty);
      expect(card.document.parentOf('body'), 'quiz');
    });
    test('a patch that writes a size in another form replaces it (image_gallery@claude-haiku-5-5 retry2)', () {
      // {"layout": {"height": {"fill": 400}}} over {"hug": 200} merged into
      // {"hug": 200, "fill": 400}, no size at all, and the patch was rejected.
      final r = _apply(_card(), {
        'op': 'patch',
        'id': 'wrap',
        'patch': {
          'layout': {'height': {'fill': 400}, 'padding': 12},
        },
      });
      expect(r.errors, isEmpty);
      expect(r.document['wrap']!.toJson()['layout'], {'width': {'fill': 390}, 'height': {'fill': 400}, 'padding': 12});
    });
    test('would_orphan says to patch', () {
      final r = _apply(_card(), {
        'op': 'set',
        'id': 'wrap',
        'node': {'type': 'column', 'children': <String>[]},
      });
      expect(r.errors.single.code, 'would_orphan');
      expect(r.errors.single.message, contains('{"op": "patch", "id": "wrap"'));
    });
  });

  test('a retry that starts over is answered with start_over; the existing UI is kept', () {
    final doc = _card();
    // What the live retry of flights@claude-haiku-5-5 sent.
    final r = _apply(
        doc,
        {
          'ops': [
            {'op': 'roots', 'roots': ['flights']},
            {
              'op': 'set',
              'id': 'flights',
              'node': {'type': 'canvas', 'slots': {'body': 'card2'}},
            },
            {'op': 'patch', 'id': 'title', 'patch': {'props': {'text': 'London → Lisbon, Friday'}}},
          ],
        },
        protectRoots: true);
    expect([for (final d in r.errors) d.code], ['start_over', 'start_over']);
    expect(r.errors.first.message, contains('fix the existing document by patching it'));
    expect(r.document.roots, ['card']);
    expect(r.applied, [2]);
    // Without protection a design-time batch may replace the roots.
    expect(_apply(doc, const RootsOp(['other'])).ok, isTrue);
    // Adding a screen keeps the existing root: allowed.
    expect(_apply(doc, const RootsOp(['card', 'more']), protectRoots: true).ok, isTrue);
  });

  test('the tool result says what the document holds and how to fix it', () {
    final r = _apply(_card(), [
      const PatchOp('title', {'props': {'text': 'Lisbon'}}),
      const SetOp('row', {'type': 'row', 'children': ['a', 'b']}, parent: 'wrap'),
      const SetOp('a', {'type': 'text', 'props': {'text': 'A', 'style': {'color': '#FFFFFFFF'}}, 'layout': {'hug': 3}}, parent: 'row'),
    ]);
    final j = r.toModelJson();
    expect(j['ids'], {'patched': ['title'], 'set': ['row']});
    expect((j['rejected']! as List).single, containsPair('code', 'unknown_layout_key'));
    expect(j['pending'], containsAll(['a', 'b']));
    expect(j['document'], {'roots': ['card'], 'nodes': 4});
    expect(j['next'], allOf(contains('fix it by patching it'), contains('Never start over'), contains('a, b')));
    // Nothing to fix: no instruction.
    expect(_apply(_card(), const PatchOp('title', {'opacity': 0.9})).toModelJson().containsKey('next'), isFalse);
    expect(jsonEncode(j), isA<String>());
  });

  group('lints', () {
    test('a button that does nothing when pressed: dead_control (plan_progress@claude-haiku-5-5)', () {
      // The recorded plan card had Start and Pause buttons with no reactions
      // and a "Migration complete" line shown from the start: a static
      // mock-up that validated cleanly.
      final doc = _apply(_card(), [
        {'op': 'set', 'id': 'start', 'parent': 'wrap', 'node': {'type': 'filledButton', 'props': {'label': 'Start'}, 'layout': {'width': 120, 'height': 40}}},
        {
          'op': 'set',
          'id': 'go',
          'parent': 'wrap',
          'node': {
            'type': 'filledButton',
            'props': {'label': 'Go'},
            'layout': {'width': 120, 'height': 40},
            'actions': [
              {'trigger': {'type': 'click'}, 'actions': [{'type': 'setVariable', 'variable': 'x', 'value': '1'}]},
            ],
          },
        },
        {'op': 'set', 'id': 'off', 'parent': 'wrap', 'node': {'type': 'filledButton', 'props': {'label': 'Off', 'enabled': false}, 'layout': {'width': 120, 'height': 40}}},
      ]).document;
      final lints = uiLints(doc).where((d) => d.code == 'dead_control').toList();
      expect([for (final d in lints) d.nodeId], ['start']);
      expect(lints.single.error, isFalse);
      expect(lints.single.message, contains('"start" (filledButton) does nothing when pressed'));
      expect(lints.single.message, contains('"trigger": {"type": "click"}'));
    });
    test('a tappable box with no label: empty_button (weather@claude-haiku-5-5)', () {
      final doc = _apply(_card(), {
        'op': 'set',
        'id': 'alertBtn',
        'parent': 'wrap',
        'node': {
          'type': 'box',
          'layout': {'width': {'fill': 350}, 'height': 48},
          'decoration': {
            'fills': [{'color': '#FFFBBF24'}],
            'radius': 12,
          },
          'actions': [
            {
              'trigger': {'type': 'click'},
              'actions': [
                {'type': 'componentEvent', 'event': 'alert'},
              ],
            },
          ],
        },
      }).document;
      final l = uiLints(doc);
      expect(l.single.code, 'empty_button');
      expect(l.single.error, isFalse);
      expect(l.single.message, contains('set "alertBtn" again as a row'));
    });
    test('text in its background colour, or with no colour on a dark fill: low_contrast', () {
      final doc = _apply(_card(), [
        const SetOp('same', {'type': 'text', 'props': {'text': 'x', 'style': {'color': '#FF0F172A'}}}, parent: 'wrap'),
        const SetOp('none', {'type': 'text', 'props': {'text': 'y'}}, parent: 'wrap'),
      ]).document;
      final l = uiLints(doc);
      expect({for (final d in l) d.nodeId}, {'same', 'none'});
      expect(l.every((d) => d.code == 'low_contrast'), isTrue);
      expect(l.firstWhere((d) => d.nodeId == 'none').message, contains('no text colour'));
      expect(uiLints(_card()), isEmpty);
    });
  });

  test('a node field written beside "node" is moved into it', () {
    final ops = decodeOps({
      'ops': [
        {
          'op': 'set',
          'id': 'a',
          'node': {'type': 'box'},
          'bind': {'visible': r'${x}'},
        },
      ],
    });
    expect((ops.ops.single.$2 as SetOp).node['bind'], {'visible': r'${x}'});
    expect(ops.diagnostics.single.code, 'misplaced_field');
  });
}
