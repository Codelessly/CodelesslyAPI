// One test per diagnostic code: a small document with exactly that mistake.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart' show Breakpoints;
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

/// A valid document: a canvas, a column, a text and a box.
Map<String, Object?> base() => jsonDecode(jsonEncode({
      'schema': 4,
      'roots': ['home'],
      'nodes': {
        'home': {
          'type': 'canvas',
          'slots': {'body': 'col'},
          'layout': {'width': 390, 'height': 844},
        },
        'col': {
          'type': 'column',
          'children': ['title', 'box'],
          'layout': {'width': {'fill': 390}, 'height': {'fill': 844}},
        },
        'title': {
          'type': 'text',
          'layout': {'width': {'hug': 50}, 'height': {'hug': 20}},
          'props': {'text': 'Hi', 'style': {'color': '#FF000000'}},
        },
        'box': {
          'type': 'box',
          'layout': {'width': 40, 'height': 40},
        },
      },
      'variables': {
        'home': [
          {'name': 'count', 'type': 'integer', 'value': 0},
        ],
      },
    })) as Map<String, Object?>;

Map<String, Object?> nodes(Map<String, Object?> d) => d['nodes'] as Map<String, Object?>;
Map<String, Object?> node(Map<String, Object?> d, String id) => nodes(d)[id] as Map<String, Object?>;

/// The diagnostics of [doc] with [code].
List<Diagnostic> withCode(Object? doc, DiagnosticCode code, {ValidateOptions options = const ValidateOptions()}) =>
    validateDocument(doc, options: options).where((d) => d.code == code).toList();

void expectOne(Object? doc, DiagnosticCode code, {String? path, String? suggestion, ValidateOptions options = const ValidateOptions()}) {
  final found = withCode(doc, code, options: options);
  expect(found, isNotEmpty, reason: 'expected ${code.name}; got ${validateDocument(doc, options: options)}');
  if (path != null) expect(found.map((d) => d.path), contains(path));
  if (suggestion != null) expect(found.map((d) => d.suggestion), contains(suggestion));
}

void main() {
  test('the base document is valid', () {
    expect(validateDocument(base()), isEmpty);
  });

  test('every diagnostic code has a test here', () {
    // Keep this list in step with Codes.all.
    expect(Codes.all.length, 70); // invalid_media, media_overridden: test/media_test.dart; unknown_theme_name, invalid_theme: test/theme_refs_test.dart; components: test/sections_test.dart
  });

  group('document', () {
    test('a document that is not a map is invalid (invalid_document)', () => expectOne([1, 2], Codes.invalidDocument));
    test('a document without a schema, or with one newer than 4, is reported (schema_version)', () {
      expectOne(base()..remove('schema'), Codes.schemaVersion, path: '/schema');
      expectOne(base()..['schema'] = 5, Codes.schemaVersion, path: '/schema');
    });
    test('a schema-2 document is valid with a note, and is checked as migrated (schema_outdated)', () {
      final d = validateDocument(base()..['schema'] = 2);
      expect(d.map((d) => '${d.code.name} ${d.severity.name}'), ['schema_outdated info']);
    });
    test('a value the migration kept is reported as legacy, not unknown (legacy_value)', () {
      final d = base();
      node(d, 'box')['legacy.track.parkedProgress'] = -0.6;
      expectOne(d, Codes.legacyValue, path: '/nodes/box/legacy.track.parkedProgress');
      expect(withCode(d, Codes.unknownNodeKey), isEmpty);
    });
    test('a misspelt document key is reported with the right one (unknown_document_key)', () => expectOne(base()..['node'] = {}, Codes.unknownDocumentKey, suggestion: 'nodes'));
    test('a root naming no node is reported (dangling_root)', () => expectOne(base()..['roots'] = ['home', 'hone'], Codes.danglingRoot, path: '/roots/1'));
    test('a root that is not a canvas is reported (root_not_canvas)', () => expectOne(base()..['roots'] = ['home', 'box'], Codes.rootNotCanvas));
    test('a document without roots is reported (no_roots)', () => expectOne(base()..['roots'] = [], Codes.noRoots));
  });

  group('nodes', () {
    test('a node without a type is reported (invalid_node)', () {
      final d = base();
      nodes(d)['x'] = {'name': 'no type'};
      expectOne(d, Codes.invalidNode, path: '/nodes/x');
    });
    test('a misspelt node type is reported with the right one (unknown_node_type)', () {
      final d = base();
      node(d, 'box')['type'] = 'boxx';
      expectOne(d, Codes.unknownNodeType, path: '/nodes/box/type', suggestion: 'box');
    });
    test('a key in the wrong place on a node is reported with where it belongs (unknown_node_key)', () {
      final d = base();
      node(d, 'title')['text'] = 'Hi';
      expectOne(d, Codes.unknownNodeKey, path: '/nodes/title/text', suggestion: 'props.text');
    });
    test('a prop the node type does not have is reported (unknown_prop)', () {
      final d = base();
      node(d, 'col')['props'] = {'gap': 8};
      expectOne(d, Codes.unknownProp, path: '/nodes/col/props/gap');
    });
    test('a misspelt layout key is reported with the right one (unknown_layout_key)', () {
      final d = base();
      (node(d, 'box')['layout'] as Map)['widht'] = 3;
      expectOne(d, Codes.unknownLayoutKey, suggestion: 'width');
    });
    test('a misspelt decoration key is reported with the right one (unknown_decoration_key)', () {
      final d = base();
      node(d, 'box')['decoration'] = {'fill': []};
      expectOne(d, Codes.unknownDecorationKey, suggestion: 'fills');
    });
    test('a misspelt field inside a prop\'s object is reported with the right one (unknown_field)', () {
      final d = base();
      ((node(d, 'title')['props'] as Map)['style'] as Map)['colour'] = '#FF000000';
      expectOne(d, Codes.unknownField, path: '/nodes/title/props/style/colour', suggestion: 'color');
    });
    test('a padding of two numbers is the wrong type (wrong_type)', () {
      final d = base();
      (node(d, 'col')['layout'] as Map)['padding'] = [16, 8];
      expectOne(d, Codes.wrongType, path: '/nodes/col/layout/padding');
    });
    test('a short hex color is the wrong type (wrong_type)', () {
      final d = base();
      node(d, 'box')['decoration'] = {
        'fills': [
          {'color': '#FFF'},
        ],
      };
      expectOne(d, Codes.wrongType, path: '/nodes/box/decoration/fills/0/color');
    });
    test('an effect without its type is reported as dropped (wrong_type)', () {
      final d = base();
      node(d, 'box')['decoration'] = {
        'effects': [
          {'blurRadius': 4},
        ],
      };
      expectOne(d, Codes.wrongType, path: '/nodes/box/decoration/effects/0');
    });
    test('a number written as text is reported as loose (loose_value)', () {
      final d = base();
      node(d, 'col')['props'] = {'spacing': '12'};
      expectOne(d, Codes.looseValue, path: '/nodes/col/props/spacing');
    });
    test('a misspelt enum value is reported with the right one (invalid_enum)', () {
      final d = base();
      node(d, 'col')['props'] = {'crossAxisAlignment': 'starts'};
      expectOne(d, Codes.invalidEnum, suggestion: 'start');
    });
    test('a value outside its range is reported (out_of_range)', () {
      final d = base();
      node(d, 'box')['opacity'] = 2;
      expectOne(d, Codes.outOfRange, path: '/nodes/box/opacity');
    });
    test('a decoration on a text is reported as ignored (decoration_ignored)', () {
      final d = base();
      node(d, 'title')['decoration'] = {
        'fills': [
          {'color': '#FFFF0000'},
        ],
      };
      expectOne(d, Codes.decorationIgnored);
    });
  });

  group('tree', () {
    test('a child naming no node is reported (dangling_child)', () {
      final d = base();
      (node(d, 'col')['children'] as List).add('ghost');
      expectOne(d, Codes.danglingChild, path: '/nodes/col/children/2');
    });
    test('a slot naming no node is reported with the likely node (dangling_slot)', () {
      final d = base();
      node(d, 'home')['slots'] = {'body': 'coll'};
      expectOne(d, Codes.danglingSlot, suggestion: 'col');
    });
    test('a node listed under two parents is reported (multiple_parents)', () {
      final d = base();
      (node(d, 'col')['children'] as List).add('title');
      expectOne(d, Codes.multipleParents, path: '/nodes/title');
    });
    test('a node that contains itself is reported (cycle)', () {
      final d = base();
      nodes(d)['loop'] = {
        'type': 'column',
        'children': ['col'],
        'layout': {'width': 1, 'height': 1},
      };
      (node(d, 'col')['children'] as List).add('loop');
      expectOne(d, Codes.cycle);
    });
    test('a node no root reaches is reported (unreachable_node)', () {
      final d = base();
      nodes(d)['stray'] = {'type': 'box', 'layout': {'width': 1, 'height': 1}};
      expectOne(d, Codes.unreachableNode, path: '/nodes/stray');
    });
    test('a slot the node type does not have is reported (unknown_slot)', () {
      final d = base();
      node(d, 'home')['slots'] = {'body': 'col', 'footer': 'box'};
      (node(d, 'col')['children'] as List).remove('box');
      expectOne(d, Codes.unknownSlot);
    });
    test('children on a node type that takes none are reported (children_not_allowed)', () {
      final d = base();
      (node(d, 'col')['children'] as List).remove('box');
      node(d, 'title')['children'] = ['box'];
      expectOne(d, Codes.childrenNotAllowed, path: '/nodes/title/children');
    });
    test('slots on a node type that has none are reported (slots_not_allowed)', () {
      final d = base();
      (node(d, 'col')['children'] as List).remove('box');
      node(d, 'title')['slots'] = {'child': 'box'};
      expectOne(d, Codes.slotsNotAllowed);
    });
    test('a canvas placed as a child is reported (canvas_as_child)', () {
      final d = base();
      nodes(d)['other'] = {'type': 'canvas', 'layout': {'width': 1, 'height': 1}};
      (node(d, 'col')['children'] as List).add('other');
      d['roots'] = ['home', 'other'];
      expectOne(d, Codes.canvasAsChild);
    });
    test('a position outside a stack is reported as ignored (layout_field_ignored)', () {
      final d = base();
      (node(d, 'box')['layout'] as Map)['x'] = {'start': 4};
      expectOne(d, Codes.layoutFieldIgnored, path: '/nodes/box/layout/x');
    });
    test('filling along a scrolling axis is not allowed (fit_not_allowed)', () {
      final d = base();
      node(d, 'col')['props'] = {'scrollable': true};
      (node(d, 'box')['layout'] as Map)['height'] = {'fill': 40};
      expectOne(d, Codes.fitNotAllowed, path: '/nodes/box/layout/height');
    });
    test('a grid\'s item extent is ignored when its rows shrink-wrap, and the allowed fits follow its rows (prop_ignored)', () {
      Map<String, Object?> grid(Map<String, Object?> props, Object? itemHeight) {
        final d = base();
        nodes(d)['grid'] = <String, Object?>{'type': 'gridView', 'children': ['card'], 'layout': {'width': {'fill': 390}, 'height': {'hug': 400}},
          'props': {'physics': 'never', ...props}};
        nodes(d)['card'] = {'type': 'column', 'layout': {'width': {'fill': 100}, 'height': itemHeight}};
        (node(d, 'col')['children'] as List).add('grid');
        return d;
      }
      expectOne(grid({'shrinkWrapRows': true, 'mainAxisExtent': 37}, {'hug': 37}), Codes.propIgnored, path: '/nodes/grid/props/mainAxisExtent');
      // Rows sized by their tallest item stretch hugging and filling items to it.
      expect(validateDocument(grid({'shrinkWrapRows': true}, {'hug': 300})), isEmpty);
      expect(validateDocument(grid({'shrinkWrapRows': true}, {'fill': 300})), isEmpty);
      // A fixed row extent fills the cell: hug cannot apply there.
      expectOne(grid({'mainAxisExtent': 120}, {'hug': 300}), Codes.fitNotAllowed, path: '/nodes/card/layout/height');
      expectOne(grid({'masonry': true}, {'fill': 300}), Codes.fitNotAllowed, path: '/nodes/card/layout/height');
    });
    test('a node without a size is reported (zero_size)', () {
      final d = base();
      node(d, 'box').remove('layout');
      expectOne(d, Codes.zeroSize, path: '/nodes/box/layout/width');
    });
    test('a text\'s padding is applied, so it is not reported as ignored', () {
      final d = base();
      (node(d, 'title')['layout'] as Map)['padding'] = [0, 0, 0, 26];
      expect(withCode(d, Codes.layoutFieldIgnored), isEmpty);
    });
    test('a negative margin, or a negative offset in a hugging stack, is reported as clamped (layout_clamped)', () {
      final d = base();
      (node(d, 'box')['layout'] as Map)['margin'] = [0, -8, 0, 0];
      expectOne(d, Codes.layoutClamped, path: '/nodes/box/layout/margin');
      final s = base();
      nodes(s)['st'] = <String, Object?>{'type': 'stack', 'children': ['glow'], 'layout': <String, Object?>{'width': {'fill': 390}, 'height': {'hug': 100}}};
      nodes(s)['glow'] = <String, Object?>{'type': 'box', 'layout': {'width': 100, 'height': 100, 'y': {'start': -30}}};
      (node(s, 'col')['children'] as List).add('st');
      expectOne(s, Codes.layoutClamped, path: '/nodes/glow/layout/y');
      (node(s, 'st')['layout'] as Map)['height'] = 300;
      expect(withCode(s, Codes.layoutClamped), isEmpty);
    });
    test('a vertical wrap is reported, and a wrapping list keeps its items\' sizes (vertical_wrap)', () {
      final d = base();
      nodes(d)['list'] = <String, Object?>{'type': 'listView', 'children': ['it'], 'layout': {'width': {'fill': 390}, 'height': {'hug': 40}}, 'props': <String, Object?>{'wrap': true}};
      nodes(d)['it'] = {'type': 'box', 'layout': {'width': 120, 'height': {'hug': 40}}};
      (node(d, 'col')['children'] as List).add('list');
      expect(validateDocument(d).map((x) => x.code.name), ['vertical_wrap']);
      (node(d, 'list')['props'] as Map)['scrollDirection'] = 'horizontal';
      expect(validateDocument(d), isEmpty);
    });
    test('a spacer with no size is valid: it is Flutter\'s Spacer() (it fills its row or column)', () {
      final d = base();
      nodes(d)['sp'] = {'type': 'spacer'};
      (node(d, 'col')['children'] as List).add('sp');
      expect(validateDocument(d), isEmpty);
    });
  });

  group('bindings and expressions', () {
    test('a binding to a path that does not exist is reported with the right one (unknown_bind_path)', () {
      final d = base();
      node(d, 'title')['bind'] = {'props.txt': r'${count}'};
      expectOne(d, Codes.unknownBindPath, suggestion: 'props.text');
    });
    test('a binding to a reserved path is reported (reserved_bind_path)', () {
      final d = base();
      node(d, 'title')['bind'] = {'enabled': r'${count}'};
      expectOne(d, Codes.reservedBindPath);
    });
    test('an unclosed expression is reported (expression_syntax)', () {
      final d = base();
      (node(d, 'title')['props'] as Map)['text'] = r'Hi ${count';
      expectOne(d, Codes.expressionSyntax);
    });
    test('a formula with a syntax error is reported by the formula checker (expression_syntax)', () {
      final d = base();
      node(d, 'title')['bind'] = {'props.text': r'${= count +}'};
      expectOne(d, Codes.expressionSyntax,
          options: ValidateOptions(formulas: (f) => (error: f.endsWith('+') ? 'Unexpected end' : null, paths: <String>{})));
    });
    test('an expression naming an unknown variable is reported with the likely one (unknown_name)', () {
      final d = base();
      (node(d, 'title')['props'] as Map)['text'] = r'${cuont} clicks';
      expectOne(d, Codes.unknownName, suggestion: 'count');
    });
    test('a literal written as a variable name is reported with the formula to write instead (unknown_name)', () {
      final d = base();
      node(d, 'title')['bind'] = {'visible': r'${false}'};
      expectOne(d, Codes.unknownName, suggestion: r'${= false}');
    });
    test('a formula naming an unknown variable is reported by the formula checker (unknown_name)', () {
      final d = base();
      node(d, 'title')['bind'] = {'props.text': r'${= cnt * 2}'};
      expectOne(d, Codes.unknownName,
          options: ValidateOptions(formulas: (f) => (error: null, paths: {'cnt'})));
    });
  });

  group('reactions', () {
    Map<String, Object?> withActions(List<Object?> reactions) {
      final d = base();
      node(d, 'box')['actions'] = reactions;
      return d;
    }

    test('a misspelt trigger is reported with the right one (unknown_trigger)', () => expectOne(withActions([
          {'trigger': {'type': 'clik'}, 'actions': []},
        ]), Codes.unknownTrigger, suggestion: 'click'));
    test('a misspelt trigger key is reported with the right one (unknown_trigger_key)', () => expectOne(withActions([
          {'trigger': {'type': 'click', 'debounce': 3}, 'actions': []},
        ]), Codes.unknownTriggerKey, suggestion: 'debounceMs'));
    test('a misspelt action type is reported with the right one (unknown_action_type)', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'navigateTo'}]},
        ]), Codes.unknownActionType, suggestion: 'navigate'));
    test('a key an action does not have is reported (unknown_action_key)', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'delay', 'durationMs': 3}]},
        ]), Codes.unknownActionKey, path: '/nodes/box/actions/0/actions/0/durationMs'));
    test('an action targeting a node that does not exist is reported with the likely one (unknown_target_node)', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'scrollTo', 'node': 'titel'}]},
        ]), Codes.unknownTargetNode, suggestion: 'title'));
    test('navigation to a screen that does not exist is reported (unknown_screen)', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'navigate', 'to': 'contact'}]},
        ]), Codes.unknownScreen));
    test('a screen of another document is known when the validator is told the project\'s screens', () {
      final d = withActions([
        {'trigger': 'click', 'actions': [{'type': 'navigate', 'to': 'contact'}]},
      ]);
      expect(withCode(d, Codes.unknownScreen, options: const ValidateOptions(screens: {'contact'})), isEmpty);
    });
    test('setting a variable that does not exist is reported with the likely one (unknown_variable)', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'setVariable', 'variable': 'cuont', 'value': '1'}]},
        ]), Codes.unknownVariable, suggestion: 'count'));
    test('an action where a reaction belongs is reported (invalid_reaction)', () => expectOne(withActions([
          {'type': 'navigate', 'to': 'home'},
        ]), Codes.invalidReaction));
    test('actions nested in other actions are checked too', () => expectOne(withActions([
          {
            'trigger': 'click',
            'actions': [
              {
                'type': 'if',
                'condition': {'left': r'${count}', 'op': 'isTrue'},
                'then': [{'type': 'delay', 'msec': 1}],
              },
            ],
          },
        ]), Codes.unknownActionKey, path: '/nodes/box/actions/0/actions/0/then/0/msec'));
  });

  group('variables, conditions, breakpoints, project', () {
    test('a malformed variable is reported (invalid_variable)', () {
      final d = base();
      d['variables'] = {
        'home': [
          {'name': 'n', 'type': 'integer', 'value': 'many'},
        ],
      };
      expectOne(d, Codes.invalidVariable, path: '/variables/home/0/value');
    });
    test('two variables of the same name are reported (duplicate_variable)', () {
      final d = base();
      ((d['variables'] as Map)['home'] as List).add({'name': 'count', 'type': 'text'});
      expectOne(d, Codes.duplicateVariable);
    });
    test('variables under an unknown scope are reported with the right one (unknown_scope)', () {
      final d = base();
      d['variables'] = {'page': []};
      expectOne(d, Codes.unknownScope, suggestion: 'page_variables');
    });
    test('a malformed condition is reported (invalid_condition)', () {
      final d = base();
      d['conditions'] = {
        'home': [
          {
            'id': 'c',
            'branches': [
              {'when': {'left': r'${count}', 'op': 'isTrue'}, 'sets': []},
            ],
          },
        ],
      };
      expectOne(d, Codes.invalidCondition, suggestion: 'set');
    });
    test('a condition setting a node or path that does not exist is reported', () {
      final d = base();
      d['conditions'] = {
        'home': [
          {
            'id': 'c',
            'branches': [
              {
                'set': [
                  {'node': 'title', 'path': 'props.txt', 'value': 'x'},
                  {'node': 'nobody', 'path': 'visible', 'value': false},
                ],
              },
            ],
          },
        ],
      };
      expectOne(d, Codes.unknownBindPath);
      expectOne(d, Codes.unknownTargetNode);
    });
    test('a canvas naming an unknown breakpoint is reported (unknown_breakpoint)', () {
      final d = base();
      node(d, 'home')['props'] = {'breakpoint': 'phone', 'screen': 'home'};
      expectOne(d, Codes.unknownBreakpoint, suggestion: null);
    });
    test('a document\'s own breakpoints are the ones known', () {
      final d = base();
      node(d, 'home')['props'] = {'breakpoint': 'phone', 'screen': 'home'};
      d['breakpoints'] = [
        {'id': 'phone', 'name': 'Phone', 'minWidth': 0, 'width': 390, 'height': 844},
      ];
      expect(withCode(d, Codes.unknownBreakpoint), isEmpty);
      expect(Breakpoints.defaults.list.length, 3);
    });
    test('two canvases of one screen at the same breakpoint are reported (duplicate_breakpoint_canvas)', () {
      final d = base();
      node(d, 'home')['props'] = {'breakpoint': 'mobile', 'screen': 'home'};
      nodes(d)['home2'] = {'type': 'canvas', 'props': {'breakpoint': 'mobile', 'screen': 'home'}};
      d['roots'] = ['home', 'home2'];
      expectOne(d, Codes.duplicateBreakpointCanvas);
    });
    test('a screen canvas without a breakpoint is reported (screen_without_breakpoint)', () {
      final d = base();
      node(d, 'home')['props'] = {'screen': 'home'};
      expectOne(d, Codes.screenWithoutBreakpoint);
    });
    test('the same node id in two documents of a project is reported (duplicate_id)', () {
      final out = validateProject({'a': base(), 'b': base()});
      expect(out.where((d) => d.code == Codes.duplicateId), isNotEmpty);
      expect(out.first.file, isNotNull);
    });
  });

  group('repeated subtrees', () {
    Map<String, Object?> card(String t, String x) => {
          't$x': {'type': 'column', 'children': ['h$x', 'b$x'], 'name': 'Card $x', 'layout': {'width': 100, 'height': {'hug': 50}}},
          'h$x': {'type': 'text', 'props': {'text': t, 'style': {'color': '#FF000000'}}, 'layout': {'width': {'hug': 50}, 'height': {'hug': 20}}},
          'b$x': {'type': 'box', 'layout': {'width': 10, 'height': 10}},
        };
    Map<String, Object?> page(List<Map<String, Object?>> cards) {
      final d = base();
      final ids = [for (final c in cards) c.keys.first];
      node(d, 'col')['children'] = ['title', 'box', ...ids];
      for (final c in cards) {
        nodes(d).addAll(c);
      }
      return d;
    }

    test('exact repeats (ids and names aside) are reported once, as an info', () {
      final d = page([card('A', '1'), card('A', '2'), card('A', '3')]);
      final found = withCode(d, Codes.repeatedSubtree);
      expect(found, hasLength(1));
      expect(found.single.severity, Severity.info);
      expect(found.single.nodeId, 't1');
      expect(found.single.message, contains('3 times'));
      expect(found.single.message, contains('t1, t2, t3'));
      // Nothing else: the page is valid.
      expect(validateDocument(d).where((x) => x.code != Codes.repeatedSubtree), isEmpty);
    });

    test('no hint when anything but ids and names differs, or for small repeats', () {
      expect(withCode(page([card('A', '1'), card('B', '2')]), Codes.repeatedSubtree), isEmpty);
      final d = base();
      node(d, 'col')['children'] = ['title', 'box', 'box2'];
      nodes(d)['box2'] = {'type': 'box', 'layout': {'width': 40, 'height': 40}};
      expect(withCode(d, Codes.repeatedSubtree), isEmpty, reason: 'one node is not a subtree worth a component');
    });

    test('a repeat inside a reported one is not reported again', () {
      Map<String, Object?> pair(String x) => {
            'p$x': {'type': 'row', 'children': ['t${x}a', 't${x}b']},
            ...card('A', '${x}a'),
            ...card('A', '${x}b'),
          };
      final found = withCode(page([pair('1'), pair('2')]), Codes.repeatedSubtree);
      expect([for (final f in found) f.nodeId], ['p1']);
    });
  });

  test('validation never throws on garbage input', () {
    for (final junk in <Object?>[null, 3, 'x', [], {}, {'nodes': 3}, {'nodes': {'a': 3}, 'roots': 'a'}]) {
      expect(() => validateDocument(junk), returnsNormally);
    }
  });
}
