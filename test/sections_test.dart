// Sections and components by reference: the definition document, the call,
// the slot node, the event trigger, componentEvent, the variable parameter,
// the site manifest, cycles, and every diagnostic of a call or a definition.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/catalog_json.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

Json planCard() => {
  'schema': 3,
  'id': 'PlanCard',
  'roots': ['card'],
  'widget': {
    'type': 'PlanCard',
    'doc': 'One pricing plan.',
    'children': 'none',
    'slots': ['footer'],
    'props': [
      {
        'key': 'plan',
        'type': {'kind': 'json', 'flutter': 'Plan'},
        'default': {},
      },
      {
        'key': 'price',
        'type': {'kind': 'number', 'flutter': 'double', 'min': 0},
        'default': 0,
        'required': true,
      },
      {
        'key': 'popular',
        'type': {'kind': 'boolean', 'flutter': 'bool'},
        'default': false,
      },
      {
        'key': 'annual',
        'type': {
          'kind': 'variable',
          'of': {'kind': 'boolean', 'flutter': 'bool'},
        },
        'default': '',
      },
    ],
    'events': [
      {
        'key': 'onChoose',
        'payload': {'kind': 'string', 'flutter': 'String'},
        'doc': 'The plan was chosen.',
      },
    ],
  },
  'variables': {
    'card': [
      {'name': 'hovered', 'type': 'boolean', 'value': false},
    ],
  },
  'previews': [
    {
      'name': 'Popular',
      'size': [432, 760],
      'props': {'popular': true, 'price': 47},
    },
  ],
  'nodes': {
    'card': {
      'type': 'column',
      'children': ['name', 'cta', 'foot'],
      'layout': {
        'width': 432,
        'height': {'hug': 700},
        'padding': 24,
      },
      'bind': {'visible': r'${= !hovered || props.popular}'},
    },
    'name': {
      'type': 'text',
      'props': {'text': r'${props.plan.name}'},
      'layout': {
        'width': {'hug': 80},
        'height': {'hug': 20},
      },
    },
    'cta': {
      'type': 'box',
      'layout': {'width': 100, 'height': 40},
      'actions': [
        {
          'trigger': {'type': 'click'},
          'actions': [
            {'type': 'setVariable', 'variable': 'props.annual', 'op': 'toggle'},
            {'type': 'componentEvent', 'event': 'onChoose', 'value': r'${props.plan.id}'},
          ],
        },
      ],
    },
    'foot': {
      'type': 'slot',
      'props': {'name': 'footer'},
      'layout': {'width': 10, 'height': 10},
    },
  },
};

Json page({Json? call, Map<String, Object?> extraNodes = const {}}) => {
  'schema': 3,
  'id': 'pricing',
  'roots': ['pricing'],
  'variables': {
    'pricing': [
      {'name': 'annual', 'type': 'boolean', 'value': false},
      {'name': 'count', 'type': 'integer', 'value': 0},
    ],
  },
  'nodes': {
    'pricing': {
      'type': 'canvas',
      'slots': {'body': 'col'},
      'layout': {'width': 1440, 'height': 900},
    },
    'col': {
      'type': 'column',
      'children': ['card1', ...extraNodes.keys],
      'layout': {
        'width': {'fill': 1440},
        'height': {'hug': 900},
      },
    },
    'card1':
        call ??
        {
          'type': 'PlanCard',
          'props': {'popular': true, 'price': 47, 'annual': 'annual'},
          'slots': {'footer': 'note'},
          'layout': {
            'width': 432,
            'height': {'hug': 716},
          },
          'bind': {'props.plan': r'${= {"id": "team", "name": "Team"}}'},
          'actions': [
            {
              'trigger': {'type': 'event', 'event': 'onChoose'},
              'actions': [
                {'type': 'setVariable', 'variable': 'count', 'op': 'add', 'value': '1'},
              ],
            },
          ],
        },
    'note': {
      'type': 'text',
      'props': {'text': 'Billed yearly'},
      'layout': {
        'width': {'hug': 80},
        'height': {'hug': 20},
      },
    },
    ...extraNodes,
  },
};

/// The diagnostics of a project of [docs] (file name → JSON), by code name.
List<Diagnostic> project(Map<String, Object?> docs, {SiteManifest? manifest}) =>
    validateProject(docs, manifest: manifest);

List<Diagnostic> coded(List<Diagnostic> ds, DiagnosticCode code) => ds.where((d) => d.code == code).toList();

void main() {
  group('the component model', () {
    test('a definition decodes: its widget is a catalog entry with typed props and events', () {
      final doc = LayoutDocument.fromJson(planCard());
      expect(doc.isComponent, isTrue);
      expect(doc.componentType, 'PlanCard');
      expect(doc.componentRoot, 'card');
      final w = doc.widget!;
      expect(w.props.map((p) => p.key), ['plan', 'price', 'popular', 'annual']);
      expect(w.prop('price')!.required, isTrue);
      expect(w.prop('price')!.type.kind, PropKind.number);
      expect(w.prop('annual')!.type.isVariable, isTrue);
      expect(w.prop('annual')!.type.kind, PropKind.string, reason: 'no new PropKind: the name is text');
      expect(w.prop('annual')!.type.variableOf!.kind, PropKind.boolean);
      expect(w.prop('annual')!.type.typeName, 'ValueNotifier<bool>');
      expect(w.slots, ['footer']);
      expect(w.event('onChoose')!.payload!.kind, PropKind.string);
      expect(doc.previews.single.width, 432);
      expect(doc.previews.single.props['popular'], true);
      expect(doc.componentVariables.single.name, 'hovered');
      expect(doc['foot']!.prop(SlotProps.name), 'footer');
    });

    test('a definition round-trips byte for byte', () {
      final json = planCard();
      final doc = LayoutDocument.fromJson(json);
      expect(
        jsonDecode(jsonEncode(doc.toJson())),
        jsonDecode(jsonEncode(LayoutDocument.fromJson(doc.toJson()).toJson())),
      );
      expect(doc.toJson()['widget'], json['widget']);
      expect(doc.toJson()['previews'], json['previews']);
    });

    test('the widget JSON round-trips through the catalog', () {
      final spec = widgetSpecFromJson(planCard()['widget'])!;
      final again = widgetSpecFromJson(widgetSpecToJson(spec))!;
      expect(widgetSpecToJson(again), widgetSpecToJson(spec));
      expect(widgetSpecToJson(spec)['events'], [
        {
          'key': 'onChoose',
          'payload': {'kind': 'string', 'flutter': 'String'},
          'doc': 'The plan was chosen.',
        },
      ]);
      expect(propTypeToJson(spec.prop('annual')!.type), {
        'kind': 'variable',
        'of': {'kind': 'boolean', 'flutter': 'bool'},
      });
      expect(propDefToJson(spec.prop('price')!)['required'], true);
    });

    test('a call decodes with typed props through the library\'s catalog, and round-trips', () {
      final library = ComponentLibrary.of([LayoutDocument.fromJson(planCard())]);
      final doc = LayoutDocument.fromJson(page(), catalog: standardCatalog + library.catalog);
      final call = doc['card1']!;
      expect(call.spec, isNotNull);
      final price = call.spec!.prop('price')!;
      expect(call.props.get(price), 47.0);
      expect(call.props.get(call.spec!.prop('annual')!), 'annual');
      expect(call.slots, {'footer': 'note'});
      expect(call.actions.single.trigger.type, TriggerType.event);
      expect(call.actions.single.trigger.event, 'onChoose');
      expect(doc.toJson()['nodes'], LayoutDocument.fromJson(page()).toJson()['nodes']);
    });

    test('a call decoded without its definition keeps its props raw (lenient)', () {
      final doc = LayoutDocument.fromJson(page());
      final call = doc['card1']!;
      expect(call.spec, isNull);
      expect(call.props.unknown['price'], 47);
      // Read through a declaration later, it decodes.
      final spec = widgetSpecFromJson(planCard()['widget'])!;
      expect(call.props.get(spec.prop('price')!), 47.0);
    });

    test('lenient decode: a malformed widget is not a component; bad entries drop', () {
      final bad = LayoutDocument.fromJson({...planCard(), 'widget': 'PlanCard'});
      expect(bad.isComponent, isFalse);
      final spec = widgetSpecFromJson({
        'type': 'X',
        'props': [
          {
            'type': {'kind': 'number'},
          },
          7,
          {
            'key': 'ok',
            'type': {'kind': 'nonsense'},
          },
        ],
        'events': [
          'onTap',
          3,
          {'doc': 'no key'},
        ],
      })!;
      expect(spec.props.map((p) => p.key), ['ok']);
      expect(spec.prop('ok')!.type.kind, PropKind.json);
      expect(spec.events.map((e) => e.key), ['onTap']);
    });

    test('a component event is a core action that the component helpers read', () {
      final a = ActionDef.fromJson({'type': 'componentEvent', 'event': 'onChoose', 'value': r'${x}'})!;
      expect(a, isA<ComponentEventAction>());
      expect(a, isA<CoreAction>());
      expect(componentEventOf(a), 'onChoose');
      expect(componentEventOf(componentEventAction('x')), 'x');
      expect(componentEventOf(UnknownAction('componentEvent', const {'event': 'y'})), 'y');
    });

    test('a component call sizes and places the component\'s root, which keeps its inside', () {
      final root = LayoutDocument.fromJson(planCard())['card']!;
      final call = LayoutDocument.fromJson(page())['card1']!.copyWith(opacity: 0.5);
      final s = seamCall(root, call);
      expect(s.layout.width, call.layout.width);
      expect(s.layout.height, call.layout.height);
      expect(s.layout.padding, root.layout.padding);
      expect(s.type, 'column');
      expect(s.children, root.children);
      expect(s.opacity, 0.5);
      expect(s.actions, isEmpty, reason: 'event reactions are handled, not wired on the box');
      expect(seamCall(root, call.copyWith(visible: false)).visible, isFalse);
    });

    test('the site manifest round-trips, keeping what it does not model', () {
      final json = {
        'schema': 3,
        'pages': ['pages/pricing.json'],
        'components': ['components/PlanCard.json'],
        'variables': [
          {
            'name': 'plans',
            'type': 'list',
            'value': [1, 2],
          },
        ],
        'breakpoints': [
          {'id': 'mobile', 'minWidth': 0},
        ],
        'favicon': {'x': 1},
      };
      final m = SiteManifest.fromJson(json);
      expect(m.pages, ['pages/pricing.json']);
      expect(m.variables.single.name, 'plans');
      expect(m.extra, {
        'favicon': {'x': 1},
      });
      expect(m.toJson(), json);
      expect(SiteManifest.fromJson('nonsense').pages, isEmpty);
    });

    test('component cycles are found through other components, once each', () {
      expect(
        componentCycles({
          'A': {'B'},
          'B': {'C'},
          'C': {'A'},
          'D': {'D'},
          'E': {'A'},
        }),
        [
          ['A', 'B', 'C', 'A'],
          ['D', 'D'],
        ],
      );
      expect(
        componentCycles({
          'A': {'B'},
          'B': {},
        }),
        isEmpty,
      );
      final lib = ComponentLibrary.of([LayoutDocument.fromJson(planCard())]);
      expect(lib.closureOf(LayoutDocument.fromJson(page())), ['PlanCard']);
    });
  });

  group('validation', () {
    Map<String, Object?> docs({Json? card, Json? p}) => {
      'PlanCard.json': card ?? planCard(),
      'pricing.json': p ?? page(),
    };

    test('a valid definition and call report nothing', () {
      expect(project(docs()).map((d) => '$d'), isEmpty);
    });

    test('a call of a component that does not exist is reported on the call node (unknown_component)', () {
      final ds = coded(project({'pricing.json': page()}), Codes.unknownComponent);
      expect(ds.single.nodeId, 'card1');
      expect(ds.single.path, '/nodes/card1/type');
      final typo = coded(
        project(
          docs(
            p: page(
              call: {
                'type': 'PlanCrad',
                'layout': {'width': 10, 'height': 10},
              },
            ),
          ),
        ),
        Codes.unknownComponent,
      );
      expect(typo.single.suggestion, 'PlanCard');
    });

    test('a call without a required prop is reported, suggesting the prop (missing_prop)', () {
      final p = page();
      ((p['nodes'] as Map)['card1'] as Map)['props'] = {'popular': true, 'annual': 'annual'};
      final ds = coded(project(docs(p: p)), Codes.missingProp);
      expect(ds.single.nodeId, 'card1');
      expect(ds.single.suggestion, 'price');
    });

    test('a required prop given by a binding counts as set', () {
      final p = page();
      final call = (p['nodes'] as Map)['card1'] as Map;
      call['props'] = {'annual': 'annual'};
      (call['bind'] as Map)['props.price'] = r'${count}';
      expect(coded(project(docs(p: p)), Codes.missingProp), isEmpty);
    });

    test('a call\'s props are checked for unknown names, wrong types and out-of-range values', () {
      final p = page();
      ((p['nodes'] as Map)['card1'] as Map)['props'] = {
        'price': -3,
        'popularr': true,
        'popular': 'yes',
        'annual': 'annual',
      };
      final ds = project(docs(p: p));
      printOnFailure('$ds');
      expect(coded(ds, Codes.unknownProp).single.suggestion, 'popular');
      expect(coded(ds, Codes.outOfRange), isNotEmpty);
      expect(coded(ds, Codes.wrongType).map((d) => d.path), contains('/nodes/card1/props/popular'));
    });

    test('a variable parameter names a variable of a compatible type', () {
      Json withAnnual(Object v) {
        final p = page();
        ((p['nodes'] as Map)['card1'] as Map)['props'] = {'price': 1, 'annual': v};
        return p;
      }

      expect(coded(project(docs(p: withAnnual('anual'))), Codes.unknownVariable).single.suggestion, 'annual');
      expect(coded(project(docs(p: withAnnual('count'))), Codes.wrongType).single.path, '/nodes/card1/props/annual');
      expect(coded(project(docs(p: withAnnual(r'${annual}'))), Codes.wrongType), isNotEmpty);
    });

    test('a call fills only the slots its component declares, and takes no children', () {
      final p = page();
      final call = (p['nodes'] as Map)['card1'] as Map;
      call['slots'] = {'fotter': 'note'};
      final ds = project(docs(p: p));
      expect(coded(ds, Codes.unknownSlot).single.suggestion, 'footer');
      call
        ..remove('slots')
        ..['children'] = ['note'];
      expect(coded(project(docs(p: p)), Codes.childrenNotAllowed).single.nodeId, 'card1');
    });

    test('reactions to undeclared component events are reported (unknown_event)', () {
      final p = page();
      final call = (p['nodes'] as Map)['card1'] as Map;
      ((call['actions'] as List).single as Map)['trigger'] = {'type': 'event', 'event': 'onChose'};
      ((p['nodes'] as Map)['note'] as Map)['actions'] = [
        {
          'trigger': {'type': 'event', 'event': 'onChoose'},
          'actions': [],
        },
      ];
      final ds = coded(project(docs(p: p)), Codes.unknownEvent);
      expect(ds.map((d) => d.nodeId), containsAll(['card1', 'note']));
      expect(ds.firstWhere((d) => d.nodeId == 'card1').suggestion, 'onChoose');

      final card = planCard();
      final chain = (((card['nodes'] as Map)['cta'] as Map)['actions'] as List).single['actions'] as List;
      (chain[1] as Map)['event'] = 'onPick';
      expect(coded(project(docs(card: card)), Codes.unknownEvent).single.file, 'PlanCard.json');
      // A componentEvent outside a component.
      final p2 = page(
        extraNodes: {
          'b': {
            'type': 'box',
            'layout': {'width': 1, 'height': 1},
            'actions': [
              {
                'trigger': {'type': 'click'},
                'actions': [
                  {'type': 'componentEvent', 'event': 'x'},
                ],
              },
            ],
          },
        },
      );
      // A top-level componentEvent (in a document that is not a component)
      // is an event to the document's host: a generated UI's session, which
      // sends it to the agent. Not reported; one without an event name is.
      expect(coded(project(docs(p: p2)), Codes.unknownEvent), isEmpty);
      final b = (p2['nodes'] as Map)['b'] as Map;
      (((b['actions'] as List).single as Map)['actions'] as List)[0] = {'type': 'componentEvent'};
      expect(coded(project(docs(p: p2)), Codes.unknownEvent).single.nodeId, 'b');
    });

    test('a call may not set decoration or padding, which belong to the component (call_field_not_allowed)', () {
      final p = page();
      final call = (p['nodes'] as Map)['card1'] as Map;
      call['decoration'] = {
        'fills': [
          {'color': '#FF000000'},
        ],
      };
      (call['layout'] as Map)['padding'] = 8;
      expect(
        coded(project(docs(p: p)), Codes.callFieldNotAllowed).map((d) => d.path),
        containsAll(['/nodes/card1/decoration', '/nodes/card1/layout/padding']),
      );
    });

    test('a slot outside a component, or one the component does not declare, is reported', () {
      final p = page(
        extraNodes: {
          's': {
            'type': 'slot',
            'layout': {'width': 1, 'height': 1},
          },
        },
      );
      expect(coded(project(docs(p: p)), Codes.slotOutsideComponent).single.nodeId, 's');
      final card = planCard();
      (((card['nodes'] as Map)['foot'] as Map)['props'] as Map)['name'] = 'fooster';
      final ds = coded(project(docs(card: card)), Codes.unknownSlot);
      expect(ds.single.suggestion, 'footer');
      expect(ds.single.file, 'PlanCard.json');
    });

    test('a slot has no box of its own: no size needed', () {
      final card = planCard();
      ((card['nodes'] as Map)['foot'] as Map).remove('layout');
      expect(project(docs(card: card)), isEmpty);
    });

    test('a component root whose placement is bound is reported (root_placement_bound)', () {
      final card = planCard();
      (((card['nodes'] as Map)['card'] as Map)['bind'] as Map)['layout.width'] = r'${= props.price}';
      expect(coded(project(docs(card: card)), Codes.rootPlacementBound).single.nodeId, 'card');
    });

    test('a definition reads props and its own variables, not the page\'s', () {
      final card = planCard();
      ((card['nodes'] as Map)['name'] as Map)['props'] = {'text': r'${count} ${props.plan.name} ${hovered}'};
      final ds = coded(project(docs(card: card)), Codes.unknownName);
      expect(ds.single.message, contains('"count"'));
    });

    test('a component whose id differs from its file, is malformed or is declared twice is reported', () {
      expect(coded(project({'Card.json': planCard()}), Codes.componentIdMismatch).single.suggestion, 'Card');
      expect(
        coded(
          project({
            'PlanCard.json': {...planCard(), 'id': 'Plan'},
          }),
          Codes.componentIdMismatch,
        ).single.path,
        '/id',
      );
      final lower = planCard()..['widget'] = {...(planCard()['widget'] as Map), 'type': 'planCard'};
      expect(coded(project({'planCard.json': lower}), Codes.invalidComponent).single.suggestion, 'PlanCard');
      expect(
        coded(
          project({
            'PlanCard.json': {
              ...planCard(),
              'roots': ['card', 'name'],
            },
          }),
          Codes.invalidComponent,
        ),
        isNotEmpty,
      );
      expect(
        coded(
          project({
            'PlanCard.json': {
              ...planCard(),
              'widget': {'doc': 'no type'},
            },
          }),
          Codes.invalidComponent,
        ),
        isNotEmpty,
      );
      expect(
        coded(project({'PlanCard.json': planCard(), 'b/PlanCard.json': planCard()}), Codes.duplicateComponent),
        isNotEmpty,
      );
      final row = planCard()..['widget'] = {...(planCard()['widget'] as Map), 'type': 'Row'};
      expect(
        coded(project({'Row.json': row}), Codes.duplicateComponent),
        isEmpty,
        reason: 'Row is not a core type (row is)',
      );
    });

    test('a component that calls itself, directly or through another, is reported on each call node', () {
      Json comp(String type, String calls) => {
        'schema': 3,
        'roots': ['r'],
        'widget': {'type': type},
        'nodes': {
          'r': {
            'type': 'column',
            'children': ['c'],
            'layout': {'width': 10, 'height': 10},
          },
          'c': {
            'type': calls,
            'layout': {'width': 10, 'height': 10},
          },
        },
      };
      final ds = coded(
        project({'A.json': comp('A', 'B'), 'B.json': comp('B', 'A'), 'C.json': comp('C', 'C')}),
        Codes.componentCycle,
      );
      expect(ds.map((d) => '${d.file}:${d.nodeId}'), unorderedEquals(['A.json:c', 'B.json:c', 'C.json:c']));
      expect(ds.first.message, contains('A → B → A'));
    });

    test('project variables can be read everywhere and may not share a name with a document\'s', () {
      final manifest = SiteManifest.fromJson({
        'variables': [
          {'name': 'count', 'type': 'integer', 'value': 0},
          {'name': 'site', 'type': 'map', 'value': {}},
        ],
      });
      final card = planCard();
      ((card['nodes'] as Map)['name'] as Map)['props'] = {'text': r'${site.name}'};
      final ds = project(docs(card: card), manifest: manifest);
      expect(coded(ds, Codes.duplicateVariable).single.file, 'pricing.json');
      expect(coded(ds, Codes.unknownName), isEmpty);
    });

    test('ids are local to a component: the same id in a page and a definition is fine', () {
      final p = page(
        extraNodes: {
          'cta': {
            'type': 'box',
            'layout': {'width': 1, 'height': 1},
          },
        },
      );
      expect(coded(project(docs(p: p)), Codes.duplicateId), isEmpty);
    });
  });

  test('the guide\'s example site (tool/reference/examples/sections) is valid, and is the guide\'s', () {
    const base = 'tool/reference/examples/sections';
    Json read(String f) => jsonDecode(File('$base/$f').readAsStringSync()) as Json;
    final manifest = SiteManifest.fromJson(read('site.json'));
    final docs = {for (final f in ['pages/home.json', ...manifest.components]) f: read(f)};
    expect(validateProject(docs, manifest: manifest).map((d) => '$d'), isEmpty);
    final section = File('docs/reference/components.md').readAsStringSync();
    final blocks = RegExp(r'```json\n(.*?)\n```', dotAll: true).allMatches(section).map((m) => m[1]!).toList();
    expect(jsonDecode(blocks[0]), read('components/Chip.json'));
    final calls = (jsonDecode('{${blocks[1]}}') as Map)['nodes'] as Map;
    for (final e in calls.entries) {
      expect((read('pages/home.json')['nodes'] as Map)[e.key], e.value);
    }
    expect(jsonDecode(blocks[2]), read('site.json'));
  });
}
