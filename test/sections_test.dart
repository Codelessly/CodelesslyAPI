// Sections and components by reference: the definition document, the call,
// the slot node, the event trigger, componentEvent, the variable parameter,
// the site manifest and cycles.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/catalog_json.dart';
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

    test('a size or a bound the root binds and the call does not is the root\'s (a dialog\'s maxHeight={screen.height - 32})', () {
      final root = Node.fromJson({
        'type': 'column',
        'layout': {'width': {'fill': 0}, 'height': 600, 'constraints': {'maxHeight': 868}},
        'bind': {'layout.height': r'${= screen.height - 300}', 'layout.constraints.maxHeight': r'${= screen.height - 32}'},
      })!;
      final call = Node.fromJson({'type': 'Dialog', 'layout': {'width': 480, 'height': 0}})!;
      final s = seamCall(root, call);
      expect(s.layout.width, call.layout.width);
      expect(s.layout.height, root.layout.height);
      expect(s.layout.constraints.maxHeight, 868);
      // A call that binds it too wins.
      final bound = Node.fromJson({'type': 'Dialog', 'layout': {'width': 480, 'height': 120}, 'bind': {'layout.height': r'${= n}'}})!;
      expect(seamCall(root, bound).layout.height, bound.layout.height);
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
    test('a required prop set to its default value is kept: read, set and written again, the call still has it', () {
      final spec = widgetSpecFromJson(planCard()['widget'])!;
      final price = spec.prop('price')!, popular = spec.prop('popular')!;
      expect(price.required, isTrue);
      final written = {'price': price.encode(price.defaultValue), 'popular': popular.encode(popular.defaultValue)};
      final props = Props.fromJson(spec, written);
      // The required one stays; the optional one equal to its default is not stored, as before.
      expect(props.toJson(spec), {'price': written['price']});
      expect(Props.empty.set(price, price.defaultValue).toJson(spec), {'price': written['price']});
      expect(Props.empty.set(popular, popular.defaultValue).toJson(spec), isEmpty);
    });
  });

  test('the guide\'s example site (tool/reference/examples/sections) is the guide\'s', () {
    const base = 'tool/reference/examples/sections';
    Json read(String f) => jsonDecode(File('$base/$f').readAsStringSync()) as Json;
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
