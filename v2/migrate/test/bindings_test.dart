import 'dart:convert';
import 'dart:io';

import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

final fixtures = [
  Directory('../../../CodelesslyEditor/test/fixtures/legacy_pages'),
  Directory('/home/user/CodelesslyEditor/test/fixtures/legacy_pages'),
].firstWhere((d) => d.existsSync(), orElse: () => Directory('../../../CodelesslyEditor/test/fixtures/legacy_pages'));

Json page(Map<String, Map<String, Object?>> nodes, {Object? variables, Object? conditions, MigrationReport? report}) => migrateDocument({
      'rootNode': {'children': ['c']},
      'c': {'id': 'c', 'type': 'canvas', 'name': 'Home', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 300],
            'properties': {'bodyId': 'f'}, 'children': ['f']},
      'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 300],
            'children': [...nodes.keys]},
      for (final e in nodes.entries)
        e.key: {'id': e.key, 'name': e.key, 'parentID': 'f', 'basicBoxLocal': [0, 0, 100, 20], ...e.value},
    }, variables: variables, conditions: conditions, report: report);

Map<String, Object?> bindOf(Json doc, String id) => ((doc['nodes'] as Map)[id] as Map)['bind'] as Map<String, Object?>;

void main() {
  group('binding paths', () {
    test('node-level, layout and decoration keys', () {
      final doc = page({
        'r': {
          'type': 'rectangle',
          'fills': [{'type': 'solid', 'color': '#2FD17A', 'id': 'p1'}],
          'strokes': [{'type': 'solid', 'color': '#000000', 'id': 's1'}],
          'effects': [{'type': 'dropShadow', 'id': 'e1', 'radius': 4}],
          'variables': {
            'visible': r'${shown}',
            'opacity': r'${= if(a, 0.5, 1)}',
            'width': r'${w}',
            'height': r'${h}',
            'flex': r'${= n}',
            'rotationDegrees': r'${deg}',
            'margin': r'${m}',
            'fill': r'${c}',
            'fill-p1': r'${= c}',
            'fill-image-p1': r'${item.art}',
            'fill-stop-0': r'${c}',
            'stroke': r'${c}',
            'stroke-paint-s1': r'${c}',
            'strokeWeight': r'${= sel ? 2 : 1}',
            'cornerRadius': r'${r}',
            'effectsVisible': r'${= sel}',
            'effect-visible-e1': r'${= sel}',
            'shadow-color-e1': r'${c}',
            'effectsOffsetX': r'${x}',
            'drawScale': r'${s}',
            'motion.translateY': r'${= sel ? 2 : 0}',
            'motion.durationMs': r'${ms}',
            'semanticLabel': r'${label}',
          },
        },
      });
      expect(bindOf(doc, 'r'), {
        'visible': r'${shown}',
        'opacity': r'${= if(a, 0.5, 1)}',
        'layout.width': r'${w}',
        'layout.height': r'${h}',
        'layout.flex': r'${= n}',
        'layout.rotation': r'${deg}',
        'layout.margin': r'${m}',
        'decoration.fills[0]': r'${c}',
        'decoration.fills.p1': r'${= c}',
        'decoration.fills.p1.image.url': r'${item.art}',
        'decoration.fills[0].stops[0].color': r'${c}',
        'decoration.strokes[0]': r'${c}',
        'decoration.strokes.s1': r'${c}',
        'decoration.strokeWidth': r'${= sel ? 2 : 1}',
        'decoration.radius': r'${r}',
        'decoration.effects.*.visible': r'${= sel}',
        'decoration.effects.e1.visible': r'${= sel}',
        'decoration.effects.e1.color': r'${c}',
        'decoration.effects.*.offset.dx': r'${x}',
        'scale': r'${s}',
        'motion.translateY': r'${= sel ? 2 : 0}',
        'motion.duration': r'${ms}',
        'semantics.label': r'${label}',
      });
    });

    test('a text: its fill is its color, its style keys every run', () {
      final doc = page({
        't': {
          'type': 'text',
          'data': r'Hi ${name}',
          'variables': {'fill': r'${c}', 'textColor': r'${c}', 'fontWeight': r'${= b ? 700 : 400}', 'data': r'${greeting}'},
        },
      });
      expect(bindOf(doc, 't'), {
        'props.style.color': r'${c}',
        'props.style.fontWeight': r'${= b ? 700 : 400}',
        'props.text': r'${greeting}',
      });
      // Text with `${...}` in it stays as written: the runtime interpolates.
      expect(((doc['nodes'] as Map)['t'] as Map)['props']['text'], r'Hi ${name}');
    });

    test("a widget's own properties", () {
      final doc = page({
        'l': {'type': 'listView', 'variables': {'data': r'${= take(alerts, 5)}', 'visible': r'${= length(alerts) > 0}'}},
        's': {'type': 'slider', 'properties': {'min': 16, 'max': 45}, 'value': 34, 'variables': {'value': 'dLen', 'max': r'${sideLen}'}},
        'g': {'type': 'slider', 'properties': {'min': 0, 'max': 100}, 'value': 3, 'variables': {'value': '74.2'}},
        'v': {'type': 'variance', 'variants': [{'id': 'a', 'name': 'A', 'children': []}], 'currentVariantId': 'a',
              'variables': {'currentVariantId': r'${state}'}},
        'i': {'type': 'icon', 'properties': {'icon': {'show': true, 'icon': {'codepoint': 61571, 'type': 'MATERIAL_ICON',
              'style': 'filled', 'version': 16, 'name': 'warning_amber'}}}, 'variables': {'icon': 'block_rounded', 'iconColor': r'${c}'}},
        'rc': {'type': 'rowColumn', 'rowColumnType': 'row', 'variables': {'spacing': r'${gap}', 'selected': r'${= sel}'}},
      });
      final rep = MigrationReport();
      page({
        'v': {'type': 'variance', 'variants': [{'id': 'a', 'name': 'A', 'children': []}], 'currentVariantId': 'a',
              'variables': {'currentVariantId': r'${state}'}},
        'i': {'type': 'icon', 'properties': {'icon': {'show': true, 'icon': {'codepoint': 61571, 'type': 'MATERIAL_ICON',
              'style': 'filled', 'version': 16, 'name': 'warning_amber'}}}, 'variables': {'icon': 'block_rounded', 'iconColor': r'${c}'}},
      }, report: rep);
      expect(rep.undecodable, isEmpty);
      expect((doc['nodes'] as Map).keys, containsAll(['l', 's', 'g', 'v', 'i', 'rc']));
      expect(bindOf(doc, 'l'), {'data': r'${= take(alerts, 5)}', 'visible': r'${= length(alerts) > 0}'});
      // A bare value was a variable path in v1.
      expect(bindOf(doc, 's'), {'props.value': r'${dLen}', 'props.max': r'${sideLen}'});
      // One that isn't a path read nothing in v1: dropped.
      expect(((doc['nodes'] as Map)['g'] as Map)['bind'], isNull);
      expect(bindOf(doc, 'v'), {'props.current': r'${state}'});
      expect(bindOf(doc, 'i'), {'props.icon.name': r"${= coalesce(block_rounded, 'block_rounded')}", 'props.color': r'${c}'});
      expect(bindOf(doc, 'rc'), {'props.spacing': r'${gap}', 'selected': r'${= sel}'});
    });
  });

  group('layout variables and conditions', () {
    test('variables become typed values or formulas', () {
      final doc = page({}, variables: {
        'id': 'layout',
        'variables': {
          'c': {
            'v1': {'id': 'v1', 'name': 'count', 'type': 'integer', 'value': '3'},
            'v2': {'id': 'v2', 'name': 'price', 'type': 'decimal', 'value': '4.5'},
            'v3': {'id': 'v3', 'name': 'on', 'type': 'boolean', 'value': 'true'},
            'v4': {'id': 'v4', 'name': 'items', 'type': 'list', 'value': '[1,2]'},
            'v5': {'id': 'v5', 'name': 'total', 'type': 'decimal', 'value': r'${= price * count}'},
            'v6': {'id': 'v6', 'name': 'ok', 'type': 'boolean', 'formula': 'count > 2'},
            'v7': {'id': 'v7', 'name': 'twice', 'formula': 'x * 2', 'parameters': ['x']},
            'v8': {'id': 'v8', 'name': 'tint', 'type': 'color', 'value': '#FF0000'},
            'v9': {'id': 'v9', 'name': 'tab', 'type': 'choice', 'value': 'a', 'extra': {'options': ['a', {'value': 'b', 'label': 'B'}]}},
            'v10': {'id': 'v10', 'name': 'name'},
          },
        },
      });
      expect(doc['variables'], {
        'c': [
          {'id': 'v1', 'name': 'count', 'type': 'integer', 'value': 3},
          {'id': 'v4', 'name': 'items', 'type': 'list', 'value': [1, 2]},
          {'id': 'v10', 'name': 'name', 'value': ''},
          {'id': 'v6', 'name': 'ok', 'type': 'boolean', 'formula': 'count > 2'},
          {'id': 'v3', 'name': 'on', 'type': 'boolean', 'value': true},
          {'id': 'v2', 'name': 'price', 'type': 'decimal', 'value': 4.5},
          {'id': 'v9', 'name': 'tab', 'type': 'choice', 'value': 'a', 'options': ['a', {'value': 'b', 'label': 'B'}]},
          {'id': 'v8', 'name': 'tint', 'type': 'color', 'value': '#FFFF0000'},
          {'id': 'v5', 'name': 'total', 'type': 'decimal', 'formula': 'price * count'},
          {'id': 'v7', 'name': 'twice', 'formula': 'x * 2', 'parameters': ['x']},
        ],
      });
    });

    test('condition groups become branches that set binding paths', () {
      Map<String, Object?> expr(String left, String op, Object right) => {
            'type': 'Expression',
            'leftPart': {'type': 'Variable', 'valueString': left},
            'operator': op,
            'rightPart': right is Map ? right : {'type': 'RawValue', 'value': right},
          };
      Map<String, Object?> setValue(String node, Map<String, Object?> value) => {
            'type': 'setValue',
            'nodeID': node,
            'values': [value],
          };
      final doc = page({
        'r': {'type': 'rectangle'},
        't': {'type': 'text', 'data': 'x'},
      }, conditions: {
        'c': {
          'k1': {
            'id': 'k1',
            'type': 'ConditionGroup',
            'name': 'Low stock',
            'ifCondition': {
              'id': 'i',
              'type': 'Condition',
              'mode': 'ifMode',
              'expression': {
                'type': 'ExpressionGroup',
                'join': 'and',
                'leftExpression': expr(r'${stock}', 'lessThan', '5'),
                'rightExpression': {
                  'type': 'ExpressionGroup',
                  'join': 'and',
                  'leftExpression': expr(r'${on}', 'isTrue', ''),
                  'rightExpression': expr(r'${tag}', 'contains', {'type': 'Variable', 'valueString': r'${want}'}),
                },
              },
              'actions': [
                setValue('r', {'name': 'visible', 'type': 'bool', 'value': true}),
                setValue('t', {'name': 'fill', 'type': 'paint', 'value': {'id': 'p', 'type': 'solid', 'color': {'r': 1, 'g': 0, 'b': 0}, 'opacity': 1}}),
              ],
            },
            'elseIfConditions': [
              {
                'id': 'e',
                'type': 'Condition',
                'mode': 'elseIfMode',
                'expression': expr(r'${stock}', 'equalsTo', r'${= 2 * 5}'),
                'actions': [setValue('r', {'name': 'opacity', 'type': 'double', 'value': 0.5})],
              },
            ],
            'elseCondition': {
              'id': 'x',
              'type': 'ElseCondition',
              'actions': [setValue('r', {'name': 'visible', 'type': 'bool', 'value': false})],
            },
          },
        },
      });
      expect(doc['conditions'], {
        'c': [
          {
            'id': 'k1',
            'name': 'Low stock',
            'branches': [
              {
                'when': {
                  'and': [
                    {'left': r'${stock}', 'op': 'lessThan', 'right': '5'},
                    {'left': r'${on}', 'op': 'isTrue'},
                    {'left': r'${tag}', 'op': 'contains', 'right': r'${want}'},
                  ],
                },
                'set': [
                  {'node': 'r', 'path': 'visible', 'value': true},
                  {'node': 't', 'path': 'props.style.color', 'value': '#FFFF0000'},
                ],
              },
              {
                'when': {'left': r'${stock}', 'op': 'equalsTo', 'right': {'raw': r'${= 2 * 5}'}},
                'set': [
                  {'node': 'r', 'path': 'opacity', 'value': 0.5},
                ],
              },
              {
                'set': [
                  {'node': 'r', 'path': 'visible', 'value': false},
                ],
              },
            ],
          },
        ],
      });
    });
  });

  test('every fixture binding has a v2 path', () {
    if (!fixtures.existsSync()) return markTestSkipped('fixtures not checked out');
    final total = MigrationReport();
    for (final f in fixtures.listSync().whereType<File>().where((f) => f.path.endsWith('.json.gz'))) {
      final json = jsonDecode(utf8.decode(gzip.decode(f.readAsBytesSync()))) as Map<String, dynamic>;
      migrateDocument(((json['document'] as Map?) ?? json).cast(), report: total);
    }
    expect(total.unmappedBindings, isEmpty);
  });
}
