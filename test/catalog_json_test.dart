import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Json _plugin() => jsonDecode(File('test/fixtures/acme_stars_plugin.json').readAsStringSync()) as Json;

void main() {
  group('Catalog.toJson', () {
    test('lists every node type, action type, trigger and value type, as JSON', () {
      final json = standardCatalog.toJson();
      expect(jsonDecode(jsonEncode(json)), json, reason: 'plain JSON');
      final widgets = [for (final w in json['widgets'] as List) (w as Map)['type']];
      expect(widgets, [for (final w in standardCatalog.widgets) w.type]);
      final actions = (json['actions'] as Map)['types'] as List;
      expect([for (final a in actions) (a as Map)['type']], [for (final a in standardCatalog.actions) a.type]);
      expect((json['triggers'] as Map)['types'], contains('click'));
      expect((json['valueTypes'] as Map).keys, containsAll(['TextStyle', 'Paint']));
      final text = (json['widgets'] as List).cast<Map>().firstWhere((w) => w['type'] == 'text');
      final style = (text['props'] as List).cast<Map>().firstWhere((p) => p['key'] == 'style');
      expect(style['type'], {'kind': 'object', 'flutter': 'TextStyle'});
      final callApi = actions.cast<Map>().firstWhere((a) => a['type'] == 'callApi');
      expect(callApi['requires'], ['api']);
      expect(callApi['nested'], ['onSuccess', 'onError']);
      expect((json['node'] as Map).keys, containsAll(['layout', 'decoration', 'behaviors']));
    });

    test('compact keeps a prop to key, type and default', () {
      final json = Catalog.core.toJson(compact: true);
      final row = (json['widgets'] as List).cast<Map>().firstWhere((w) => w['type'] == 'row');
      final spacing = (row['props'] as List).cast<Map>().firstWhere((p) => p['key'] == 'spacing');
      expect(spacing, {'key': 'spacing', 'type': 'double', 'default': 0});
      expect(json, isNot(contains('valueTypes')));
      expect(jsonEncode(json).length, lessThan(jsonEncode(Catalog.core.toJson()).length));
    });
  });

  group('Catalog.fromJson', () {
    test('reads its own export back: the same types and props', () {
      final back = Catalog.fromJson(standardCatalog.toJson());
      expect([for (final w in back.widgets) w.type], [for (final w in standardCatalog.widgets) w.type]);
      for (final w in standardCatalog.widgets) {
        expect([for (final p in back.widget(w.type)!.props) p.key], [for (final p in w.props) p.key], reason: w.type);
      }
      expect([for (final a in back.actions) a.type], [for (final a in standardCatalog.actions) a.type]);
      final spacing = back.widget('row')!.prop('spacing')!;
      expect(spacing.type.kind, PropKind.number);
      expect(spacing.defaultValue, 0);
    });

    test('a plugin declared as data decodes typed values', () {
      final acme = Catalog.fromJson(_plugin()['catalog']);
      final spec = acme.widget('acme.rating')!;
      final node = Node.fromJson({
        'type': 'acme.rating',
        'props': {'value': 7, 'color': '#FF112233', 'extra': 1},
      }, id: 'r', catalog: standardCatalog + acme)!;
      expect(node.spec, same(spec));
      expect(node.props.get(spec.prop('value')!), 5, reason: 'clamped to its max');
      expect(node.props.get(spec.prop('color')!), const Color(0xFF112233));
      expect(spec.prop('color')!.defaultValue, const Color(0xFFFFC83D));
      expect(node.props.unknown, {'extra': 1});
      expect(node.toJson()['props'], {'extra': 1, 'value': 5, 'color': '#FF112233'});
      final cheer = ActionDef.fromJson({'type': 'acme.cheer', 'amount': '3'}, catalog: standardCatalog + acme);
      expect(cheer, isA<DeclaredAction>());
      expect((cheer as DeclaredAction).values, {'amount': 3});
    });
  });

  group('hosted plugins', () {
    test('a package round-trips and declares its types', () {
      final p = PluginPackage.fromJson(_plugin())!;
      expect(p.id, 'acme.stars');
      expect(p.catalog.widget('acme.rating'), isNotNull);
      expect(p.catalog.action('acme.cheer'), isNotNull);
      expect(p.widgets['acme.rating']!.decode(standardCatalog).roots, ['root']);
      expect(PluginPackage.fromJson(p.toJson())!.toJson(), p.toJson());
      expect(p.problems(standardCatalog), isEmpty);
    });

    test('a package using what the host lacks, or more than it requires, is refused', () {
      final json = _plugin();
      final impl = json['implementation'] as Map;
      ((impl['actions'] as Map)['acme.cheer'] as Map)['chain'] = [
        {'type': 'callApi', 'api': 'x'},
        {'type': 'acme.unknown'},
      ];
      final p = PluginPackage.fromJson(json)!;
      final problems = p.problems(standardCatalog);
      expect(problems, contains(contains('callApi needs "api"')));
      expect(problems, contains(contains('"acme.unknown" is not in the app\'s catalog')));
      // The core alone has no cloud data: a tree with a video is refused too.
      final tree = ((impl['widgets'] as Map)['acme.rating'] as Map)['document'] as Map;
      (tree['nodes'] as Map)['v'] = {'type': 'video', 'layout': {}};
      expect(PluginPackage.fromJson(json)!.problems(Catalog.core), contains(contains('"video"')));
      expect(PluginPackage.fromJson({..._plugin(), 'requires': ['api']})!.problems(standardCatalog, allowed: {}),
          contains(contains('requires "api"')));
    });

    test('versions, refs and the managed rules', () {
      final p = PluginPackage.fromJson(_plugin())!;
      final v = PluginVersion.of(p, version: 3, digest: 'abc');
      final back = PluginVersion.fromJson(v.toJson())!;
      expect(back.payload, v.payload);
      expect(back.package!.toJson(), p.toJson());
      expect(back.minSdk, '24.0.0');
      const ref = PluginRef(id: 'acme.stars', version: 3, semver: '1.0.0', digest: 'abc');
      expect(PluginRef.fromJson(ref.toJson()), ref);
      expect(ref.vendor, 'acme');
      final master = ManagedComponentMaster.fromJson({
        'id': 'acme.stars',
        'versions': {'3': {'semver': '1.0.0'}, '4': {'semver': '1.1.0'}, '5': {'semver': '2.0.0'}, '6': {'semver': '1.2.0', 'minSdk': '99.0.0'}},
        'channels': {'stable': {'1': 6, '2': 5}},
      })!;
      expect(pluginUpdateTarget(ref, master, sdkVersion: '25.0.0'), 4, reason: 'same major, newest the SDK can run');
      expect(pluginUpdateTarget(const PluginRef(id: 'acme.stars', version: 3, semver: '1.0.0', pin: 2), master), 5);
      final model = PublishModel.fromJson({'projectId': 'p'}).withPlugins([ref]);
      expect(PublishModel.fromJson(model.toJson()).plugins, [ref]);
      expect(PublishModel.fromJson({'projectId': 'p'}).plugins, isEmpty);
    });
  });
}
