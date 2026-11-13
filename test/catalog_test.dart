import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

import 'actions_test.dart' show samples;

// A native plugin, declared in Dart: one node type and one action type.
abstract final class RatingProps {
  static const value = PropDef<double>('value', DoubleCodec(min: 0, max: 5), 0, doc: 'Stars filled.');
  static const color = PropDef<Color>('color', Codecs.color, Color(0xFFFFC83D));
  static const spec = WidgetSpec('acme.rating', props: [value, color], doc: 'A five-star rating.');
}

abstract final class ShareFields {
  static const text = PropDef<String>('text', Codecs.string, '');
  static const List<PropDef<Object?>> all = [text];
}

final class ShareAction extends ActionDef {
  const ShareAction({this.text = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'acme.share';
  static const spec = ActionSpec(typeName, label: 'Share', fields: ShareFields.all, decode: decode, requires: ['share']);

  static ShareAction decode(Json m, ActionCommon c) =>
      ShareAction(text: readString(m['text']) ?? '', enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);

  final String text;

  @override
  String get type => typeName;

  @override
  Json get fieldsJson => {if (text.isNotEmpty) 'text': text};
}

const acme = Catalog(id: 'acme', widgets: [RatingProps.spec], actions: [ShareAction.spec]);

// A data-only declaration (no Dart class): decodes as a DeclaredAction.
const confetti = Catalog(id: 'party', actions: [
  ActionSpec('party.confetti', label: 'Confetti', nested: ['then'], fields: [
    PropDef<int>('count', Codecs.int, 40),
    PropDef<Object?>('then', Codecs.any, null),
  ]),
]);

Json _page(List<Json> actions) => {
  'schema': 3,
  'roots': ['c'],
  'nodes': {
    'c': {'type': 'canvas', 'children': ['r', 'v'], 'layout': {}},
    'r': {
      'type': 'acme.rating',
      'layout': {},
      'props': {'value': 3.5, 'color': '#FF112233'},
      'actions': [
        {'trigger': {'type': 'click'}, 'actions': actions},
      ],
    },
    'v': {'type': 'video', 'layout': {}, 'props': {'url': 'https://x/v.mp4', 'looping': true}},
  },
};

void main() {
  group('Catalog', () {
    test('the standard catalog is the core and every first-party library', () {
      expect(standardCatalog.parts, [coreCatalog, dataCatalog, authCatalog, commerceCatalog, mediaCatalog, engageCatalog]);
      expect(Catalog.core, same(coreCatalog));
      expect(standardCatalog.widgets.length, coreCatalog.widgets.length + mediaCatalog.widgets.length);
      expect(standardCatalog.actions.map((a) => a.type).toSet().length, standardCatalog.actions.length);
      // Every type is declared by exactly one library.
      final libraries = [coreCatalog, dataCatalog, authCatalog, commerceCatalog, mediaCatalog, engageCatalog];
      for (final a in standardCatalog.actions) {
        expect(libraries.where((l) => l.action(a.type) != null), hasLength(1), reason: a.type);
      }
    });

    test('Widgets and ActionSpecs are views of the standard catalog', () {
      expect(Widgets.all, standardCatalog.widgets);
      expect(Widgets.of('video'), same(VideoProps.spec));
      expect(Widgets.of('acme.rating'), isNull);
      expect(ActionSpecs.all.toList(), standardCatalog.actions);
      expect(ActionSpecs.of('callApi')?.label, 'Call API');
      // The core knows no feature: ActionDef.types lists Catalog.current's.
      expect(ActionDef.types.toSet(), {for (final a in Catalog.core.actions) a.type});
    });

    test('composition: later entries win by type, parts first', () {
      const replaced = WidgetSpec('acme.rating', props: [RatingProps.value]);
      final c = standardCatalog + acme + const Catalog(widgets: [replaced]);
      expect(c.widget('acme.rating'), same(replaced));
      expect(c.widget('text'), same(TextProps.spec));
      expect(c.action('acme.share'), same(ShareAction.spec));
      expect(c.widgets.where((w) => w.type == 'acme.rating'), hasLength(1));
      expect(c.widgets.last, same(replaced));
    });

    test('every first-party action type decodes to its family, and back', () {
      final families = <String, Type>{};
      for (final json in samples) {
        final a = ActionDef.fromJson(json, catalog: standardCatalog)!;
        expect(a, isNot(isA<UnknownAction>()), reason: '${json['type']}');
        expect(a, isNot(isA<DeclaredAction>()), reason: '${json['type']}');
        final family = switch (a) {
          CoreAction() => coreCatalog,
          DataAction() => dataCatalog,
          MediaAction() => mediaCatalog,
          EngageAction() => engageCatalog,
          AuthAction() => authCatalog,
          PaywallAction() => commerceCatalog,
          _ => null,
        };
        expect(family?.action(a.type), isNotNull, reason: '${a.type} is in the catalog of its family');
        families[a.type] = a.runtimeType;
      }
      // The samples cover every declared type.
      expect(families.keys.toSet(), {for (final s in standardCatalog.actions) s.type});
      for (final s in standardCatalog.actions) {
        expect(s.decode, isNotNull, reason: s.type);
      }
    });
  });

  group('decoding with a catalog', () {
    test('a native plugin node type and action type decode typed', () {
      final doc = LayoutDocument.fromJson(_page([{'type': 'acme.share', 'text': 'hi', 'nonBlocking': true}]),
          catalog: standardCatalog + acme);
      final rating = doc['r']!;
      expect(rating.spec, same(RatingProps.spec));
      expect(rating.prop(RatingProps.value), 3.5);
      expect(rating.prop(RatingProps.color), const Color(0xFF112233));
      final share = rating.actions.single.actions.single;
      expect(share, isA<ShareAction>().having((s) => s.text, 'text', 'hi').having((s) => s.nonBlocking, 'nonBlocking', true));
      expect(doc['v']!.spec, same(VideoProps.spec));
      expect(doc.catalog, isNotNull);
    });

    test('types the catalog does not declare decode as today and round-trip', () {
      final json = _page([{'type': 'acme.share', 'text': 'hi'}, {'type': 'auth', 'operation': 'signOut'}]);
      final doc = LayoutDocument.fromJson(json, catalog: Catalog.core);
      final rating = doc['r']!;
      expect(rating.spec, isNull);
      expect(rating.props.unknown, {'value': 3.5, 'color': '#FF112233'});
      final chain = rating.actions.single.actions;
      expect(chain[0], isA<UnknownAction>());
      expect(chain[1], isA<UnknownAction>(), reason: 'auth is not a core action');
      expect(doc['v']!.spec, isNull, reason: 'video is the media library\'s');
      final standard = LayoutDocument.fromJson(json, catalog: standardCatalog);
      expect(standard['v']!.spec, same(VideoProps.spec));
      expect(standard['r']!.actions.single.actions[1], isA<AuthAction>());
      // Byte for byte, whichever catalog read it.
      expect(jsonEncode(doc.toJson()), jsonEncode(LayoutDocument.fromJson(doc.toJson(), catalog: Catalog.core).toJson()));
      expect(jsonEncode(doc['r']!.toJson()), jsonEncode(standard['r']!.toJson()));
    });

    test('the catalog reaches actions nested in props and in actions', () {
      final json = {
        'type': 'navigationBar',
        'layout': {},
        'props': {
          'destinations': [
            {
              'label': 'Share',
              'actions': [
                {'trigger': {'type': 'click'}, 'actions': [{'type': 'if', 'then': [{'type': 'acme.share', 'text': 'x'}]}]},
              ],
            },
          ],
        },
      };
      final node = Node.fromJson(json, id: 'n', catalog: standardCatalog + acme)!;
      final destinations = node.prop(NavigationBarProps.destinations);
      final ifAction = destinations.single.actions.single.actions.single as IfAction;
      expect(ifAction.then.single, isA<ShareAction>());
      final plain = Node.fromJson(json, id: 'n', catalog: standardCatalog)!;
      expect((plain.prop(NavigationBarProps.destinations).single.actions.single.actions.single as IfAction).then.single,
          isA<UnknownAction>());
    });

    test('a node keeps its catalog through copyWith and patched', () {
      final node = Node.fromJson({'type': 'acme.rating', 'props': {'value': 2}}, id: 'r', catalog: acme)!;
      expect(node.copyWith(name: 'x').spec, same(RatingProps.spec));
      expect(node.patched({'props': {'value': 4}}).prop(RatingProps.value), 4);
      expect(node.withComponent(null).spec, same(RatingProps.spec));
      // The catalog isn't part of the value.
      expect(Node.fromJson({'type': 'acme.rating', 'props': {'value': 2}}, id: 'r', catalog: Catalog.core),
          isNot(node), reason: 'undeclared props are held raw, so the values differ');
      expect(Node.fromJson(node.toJson(), id: 'r', catalog: standardCatalog + acme), node);
    });

    test('a data-only declared action holds typed fields and its nested chain', () {
      final a = ActionDef.fromJson({
        'type': 'party.confetti',
        'count': '12',
        'then': [{'type': 'delay', 'ms': 5}],
        'extra': true,
        'when': {'left': '1', 'op': 'equals', 'right': '1'},
      }, catalog: standardCatalog + confetti)!;
      expect(a, isA<DeclaredAction>());
      final d = a as DeclaredAction;
      expect(d.get(d.spec.fields.first as PropDef<int>), 12);
      expect(d.nested.single, isA<DelayAction>());
      expect(d.when, isNotNull);
      expect(d.toJson(), {
        'type': 'party.confetti',
        'extra': true,
        'count': 12,
        'then': [{'type': 'delay', 'ms': 5}],
        'when': d.when!.toJson(),
      });
    });

    test('upgrade: an action decoded with a smaller catalog becomes typed', () {
      final a = ActionDef.fromJson({'type': 'acme.share', 'text': 'y'}, catalog: Catalog.core)!;
      expect(a, isA<UnknownAction>());
      expect((standardCatalog + acme).upgrade(a), isA<ShareAction>());
      expect(standardCatalog.upgrade(a), same(a));
      final typed = ActionDef.fromJson({'type': 'delay', 'ms': 3}, catalog: standardCatalog)!;
      expect(standardCatalog.upgrade(typed), same(typed));
    });

    test('the default catalog is the core; Catalog.run scopes another', () {
      expect(Catalog.current, same(Catalog.core));
      expect(ActionDef.fromJson({'type': 'callApi'}), isA<UnknownAction>());
      Catalog.run(standardCatalog, () {
        expect(Catalog.current, same(standardCatalog));
        expect(ActionDef.fromJson({'type': 'callApi'}), isA<CallApiAction>());
      });
      expect(ActionDef.fromJson({'type': 'callApi'}), isA<UnknownAction>());
    });
  });
}
