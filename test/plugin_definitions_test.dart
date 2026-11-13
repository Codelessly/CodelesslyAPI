// A hosted plugin's node types as component definitions (docs/design/06
// §5.8, §6.5): the same call, declaration, slots and events as a project's
// components.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

final package = PluginPackage.fromJson({
  'schema': 2,
  'id': 'acme.ui',
  'catalog': {
    'widgets': [
      {
        'type': 'acme.panel',
        'props': [
          {'key': 'title', 'type': {'kind': 'string'}, 'default': ''},
        ],
      },
    ],
  },
  'implementation': {
    'widgets': {
      'acme.panel': {
        'document': {
          'roots': ['root'],
          'nodes': {
            'root': {'type': 'column', 'children': ['head', 'body'], 'layout': {'width': 200, 'height': {'hug': 80}}},
            'head': {'type': 'text', 'props': {'text': r'${props.title}'}},
            'body': {'type': 'column', 'children': ['empty']},
            'empty': {'type': 'text', 'props': {'text': 'Nothing here'}},
          },
        },
        'slots': {'children': 'body', 'footer': 'root'},
        'events': [
          {'key': 'onClose', 'payload': {'kind': 'string'}},
        ],
      },
    },
    'formulas': [
      {'name': 'twice', 'parameters': ['v'], 'formula': 'v * 2'},
    ],
  },
})!;

void main() {
  test('a plugin node type is a component definition: declaration, slot nodes, events, formulas', () {
    final doc = package.definitions(standardCatalog)['acme.panel']!;
    expect(doc.isComponent, isTrue);
    expect(doc.componentType, 'acme.panel');
    final spec = doc.widget!;
    expect(spec.prop('title'), isNotNull);
    expect(spec.slots, ['footer']);
    expect(spec.children, ChildModel.list);
    expect(spec.events.map((e) => e.key), ['onClose']);
    // The body's children became the default of a `children` slot.
    final slot = doc[doc['body']!.children.single]!;
    expect(slot.type, 'slot');
    expect(slot.prop(SlotProps.name), kChildrenSlot);
    expect(slot.children, ['empty']);
    final footer = doc[doc['root']!.children.single]!;
    expect(footer.prop(SlotProps.name), 'footer');
    expect(footer.children, ['head', 'body']);
    expect(doc.componentVariables.map((v) => v.name), ['twice']);
    // The package itself is unchanged.
    expect(package.widgets['acme.panel']!.document['nodes'], isNot(contains('body__children')));
  });

  test('a bundle embeds plugin versions; one without has none', () {
    final v = PluginVersion.of(package, version: 3);
    final b = PublishBundle(model: PublishModel(projectId: 'p')).withPluginVersions([v]);
    final again = PublishBundle.fromJson(b.toJson());
    expect(again.pluginVersions.single.version, 3);
    expect(again.pluginVersions.single.package!.id, 'acme.ui');
    expect(PublishBundle(model: PublishModel(projectId: 'p')).pluginVersions, isEmpty);
  });
}
