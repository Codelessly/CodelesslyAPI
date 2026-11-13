// One test per diagnostic code: a small document with exactly that mistake.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart' show Breakpoints;
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

/// A valid document: a canvas, a column, a text and a box.
Map<String, Object?> base() => jsonDecode(jsonEncode({
      'schema': 2,
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

  test('every code has a test below', () {
    // Keep this list in step with Codes.all.
    expect(Codes.all.length, 50);
  });

  group('document', () {
    test('invalid_document', () => expectOne([1, 2], Codes.invalidDocument));
    test('schema_version', () => expectOne(base()..remove('schema'), Codes.schemaVersion, path: '/schema'));
    test('unknown_document_key', () => expectOne(base()..['node'] = {}, Codes.unknownDocumentKey, suggestion: 'nodes'));
    test('dangling_root', () => expectOne(base()..['roots'] = ['home', 'hone'], Codes.danglingRoot, path: '/roots/1'));
    test('root_not_canvas', () => expectOne(base()..['roots'] = ['home', 'box'], Codes.rootNotCanvas));
    test('no_roots', () => expectOne(base()..['roots'] = [], Codes.noRoots));
  });

  group('nodes', () {
    test('invalid_node', () {
      final d = base();
      nodes(d)['x'] = {'name': 'no type'};
      expectOne(d, Codes.invalidNode, path: '/nodes/x');
    });
    test('unknown_node_type', () {
      final d = base();
      node(d, 'box')['type'] = 'boxx';
      expectOne(d, Codes.unknownNodeType, path: '/nodes/box/type', suggestion: 'box');
    });
    test('unknown_node_key, with where it belongs', () {
      final d = base();
      node(d, 'title')['text'] = 'Hi';
      expectOne(d, Codes.unknownNodeKey, path: '/nodes/title/text', suggestion: 'props.text');
    });
    test('unknown_prop', () {
      final d = base();
      node(d, 'col')['props'] = {'gap': 8};
      expectOne(d, Codes.unknownProp, path: '/nodes/col/props/gap');
    });
    test('unknown_layout_key', () {
      final d = base();
      (node(d, 'box')['layout'] as Map)['widht'] = 3;
      expectOne(d, Codes.unknownLayoutKey, suggestion: 'width');
    });
    test('unknown_decoration_key', () {
      final d = base();
      node(d, 'box')['decoration'] = {'fill': []};
      expectOne(d, Codes.unknownDecorationKey, suggestion: 'fills');
    });
    test('unknown_field in a model', () {
      final d = base();
      ((node(d, 'title')['props'] as Map)['style'] as Map)['colour'] = '#FF000000';
      expectOne(d, Codes.unknownField, path: '/nodes/title/props/style/colour', suggestion: 'color');
    });
    test('wrong_type: padding of two numbers', () {
      final d = base();
      (node(d, 'col')['layout'] as Map)['padding'] = [16, 8];
      expectOne(d, Codes.wrongType, path: '/nodes/col/layout/padding');
    });
    test('wrong_type: a short hex color', () {
      final d = base();
      node(d, 'box')['decoration'] = {
        'fills': [
          {'color': '#FFF'},
        ],
      };
      expectOne(d, Codes.wrongType, path: '/nodes/box/decoration/fills/0/color');
    });
    test('wrong_type: an effect without its type is dropped', () {
      final d = base();
      node(d, 'box')['decoration'] = {
        'effects': [
          {'blurRadius': 4},
        ],
      };
      expectOne(d, Codes.wrongType, path: '/nodes/box/decoration/effects/0');
    });
    test('loose_value', () {
      final d = base();
      node(d, 'col')['props'] = {'spacing': '12'};
      expectOne(d, Codes.looseValue, path: '/nodes/col/props/spacing');
    });
    test('invalid_enum', () {
      final d = base();
      node(d, 'col')['props'] = {'crossAxisAlignment': 'starts'};
      expectOne(d, Codes.invalidEnum, suggestion: 'start');
    });
    test('out_of_range', () {
      final d = base();
      node(d, 'box')['opacity'] = 2;
      expectOne(d, Codes.outOfRange, path: '/nodes/box/opacity');
    });
    test('decoration_ignored on a text', () {
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
    test('dangling_child', () {
      final d = base();
      (node(d, 'col')['children'] as List).add('ghost');
      expectOne(d, Codes.danglingChild, path: '/nodes/col/children/2');
    });
    test('dangling_slot', () {
      final d = base();
      node(d, 'home')['slots'] = {'body': 'coll'};
      expectOne(d, Codes.danglingSlot, suggestion: 'col');
    });
    test('multiple_parents', () {
      final d = base();
      (node(d, 'col')['children'] as List).add('title');
      expectOne(d, Codes.multipleParents, path: '/nodes/title');
    });
    test('cycle', () {
      final d = base();
      nodes(d)['loop'] = {
        'type': 'column',
        'children': ['col'],
        'layout': {'width': 1, 'height': 1},
      };
      (node(d, 'col')['children'] as List).add('loop');
      expectOne(d, Codes.cycle);
    });
    test('unreachable_node', () {
      final d = base();
      nodes(d)['stray'] = {'type': 'box', 'layout': {'width': 1, 'height': 1}};
      expectOne(d, Codes.unreachableNode, path: '/nodes/stray');
    });
    test('unknown_slot', () {
      final d = base();
      node(d, 'home')['slots'] = {'body': 'col', 'footer': 'box'};
      (node(d, 'col')['children'] as List).remove('box');
      expectOne(d, Codes.unknownSlot);
    });
    test('children_not_allowed', () {
      final d = base();
      (node(d, 'col')['children'] as List).remove('box');
      node(d, 'title')['children'] = ['box'];
      expectOne(d, Codes.childrenNotAllowed, path: '/nodes/title/children');
    });
    test('slots_not_allowed', () {
      final d = base();
      (node(d, 'col')['children'] as List).remove('box');
      node(d, 'title')['slots'] = {'child': 'box'};
      expectOne(d, Codes.slotsNotAllowed);
    });
    test('canvas_as_child', () {
      final d = base();
      nodes(d)['other'] = {'type': 'canvas', 'layout': {'width': 1, 'height': 1}};
      (node(d, 'col')['children'] as List).add('other');
      d['roots'] = ['home', 'other'];
      expectOne(d, Codes.canvasAsChild);
    });
    test('layout_field_ignored: x outside a stack', () {
      final d = base();
      (node(d, 'box')['layout'] as Map)['x'] = {'start': 4};
      expectOne(d, Codes.layoutFieldIgnored, path: '/nodes/box/layout/x');
    });
    test('fit_not_allowed: fill along a scrolling axis', () {
      final d = base();
      node(d, 'col')['props'] = {'scrollable': true};
      (node(d, 'box')['layout'] as Map)['height'] = {'fill': 40};
      expectOne(d, Codes.fitNotAllowed, path: '/nodes/box/layout/height');
    });
    test('zero_size', () {
      final d = base();
      node(d, 'box').remove('layout');
      expectOne(d, Codes.zeroSize, path: '/nodes/box/layout/width');
    });
  });

  group('bindings and expressions', () {
    test('unknown_bind_path', () {
      final d = base();
      node(d, 'title')['bind'] = {'props.txt': r'${count}'};
      expectOne(d, Codes.unknownBindPath, suggestion: 'props.text');
    });
    test('reserved_bind_path', () {
      final d = base();
      node(d, 'title')['bind'] = {'enabled': r'${count}'};
      expectOne(d, Codes.reservedBindPath);
    });
    test('expression_syntax', () {
      final d = base();
      (node(d, 'title')['props'] as Map)['text'] = r'Hi ${count';
      expectOne(d, Codes.expressionSyntax);
    });
    test('expression_syntax from a formula checker', () {
      final d = base();
      node(d, 'title')['bind'] = {'props.text': r'${= count +}'};
      expectOne(d, Codes.expressionSyntax,
          options: ValidateOptions(formulas: (f) => (error: f.endsWith('+') ? 'Unexpected end' : null, paths: <String>{})));
    });
    test('unknown_name', () {
      final d = base();
      (node(d, 'title')['props'] as Map)['text'] = r'${cuont} clicks';
      expectOne(d, Codes.unknownName, suggestion: 'count');
    });
    test('unknown_name in a formula, with a formula checker', () {
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

    test('unknown_trigger', () => expectOne(withActions([
          {'trigger': {'type': 'clik'}, 'actions': []},
        ]), Codes.unknownTrigger, suggestion: 'click'));
    test('unknown_trigger_key', () => expectOne(withActions([
          {'trigger': {'type': 'click', 'debounce': 3}, 'actions': []},
        ]), Codes.unknownTriggerKey, suggestion: 'debounceMs'));
    test('unknown_action_type', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'navigateTo'}]},
        ]), Codes.unknownActionType, suggestion: 'navigate'));
    test('unknown_action_key', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'delay', 'durationMs': 3}]},
        ]), Codes.unknownActionKey, path: '/nodes/box/actions/0/actions/0/durationMs'));
    test('unknown_target_node', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'scrollTo', 'node': 'titel'}]},
        ]), Codes.unknownTargetNode, suggestion: 'title'));
    test('unknown_screen', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'navigate', 'to': 'contact'}]},
        ]), Codes.unknownScreen));
    test('a screen of another document is known through ValidateOptions.screens', () {
      final d = withActions([
        {'trigger': 'click', 'actions': [{'type': 'navigate', 'to': 'contact'}]},
      ]);
      expect(withCode(d, Codes.unknownScreen, options: const ValidateOptions(screens: {'contact'})), isEmpty);
    });
    test('unknown_variable', () => expectOne(withActions([
          {'trigger': 'click', 'actions': [{'type': 'setVariable', 'variable': 'cuont', 'value': '1'}]},
        ]), Codes.unknownVariable, suggestion: 'count'));
    test('invalid_reaction: an action where a reaction goes', () => expectOne(withActions([
          {'type': 'navigate', 'to': 'home'},
        ]), Codes.invalidReaction));
    test('nested chains are checked', () => expectOne(withActions([
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
    test('invalid_variable', () {
      final d = base();
      d['variables'] = {
        'home': [
          {'name': 'n', 'type': 'integer', 'value': 'many'},
        ],
      };
      expectOne(d, Codes.invalidVariable, path: '/variables/home/0/value');
    });
    test('duplicate_variable', () {
      final d = base();
      ((d['variables'] as Map)['home'] as List).add({'name': 'count', 'type': 'text'});
      expectOne(d, Codes.duplicateVariable);
    });
    test('unknown_scope', () {
      final d = base();
      d['variables'] = {'page': []};
      expectOne(d, Codes.unknownScope, suggestion: 'page_variables');
    });
    test('invalid_condition', () {
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
    test('a condition setting an unknown node or path', () {
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
    test('unknown_breakpoint', () {
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
    test('duplicate_breakpoint_canvas', () {
      final d = base();
      node(d, 'home')['props'] = {'breakpoint': 'mobile', 'screen': 'home'};
      nodes(d)['home2'] = {'type': 'canvas', 'props': {'breakpoint': 'mobile', 'screen': 'home'}};
      d['roots'] = ['home', 'home2'];
      expectOne(d, Codes.duplicateBreakpointCanvas);
    });
    test('screen_without_breakpoint', () {
      final d = base();
      node(d, 'home')['props'] = {'screen': 'home'};
      expectOne(d, Codes.screenWithoutBreakpoint);
    });
    test('duplicate_id across the documents of a project', () {
      final out = validateProject({'a': base(), 'b': base()});
      expect(out.where((d) => d.code == Codes.duplicateId), isNotEmpty);
      expect(out.first.file, isNotNull);
    });
  });

  test('never throws on garbage', () {
    for (final junk in <Object?>[null, 3, 'x', [], {}, {'nodes': 3}, {'nodes': {'a': 3}, 'roots': 'a'}]) {
      expect(() => validateDocument(junk), returnsNormally);
    }
  });
}
