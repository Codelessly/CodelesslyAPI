import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final settings = [
    {
      'label': 'Title',
      'type': 'string',
      'value': 'Hi',
      'targets': [
        {'node': 't', 'path': 'props.text'},
      ],
    },
    {
      'type': 'group',
      'label': 'Look',
      'settings': [
        {
          'label': 'Radius',
          'type': 'number',
          'value': 8,
          'min': 0,
          'targets': [
            {'node': 'card', 'path': 'decoration.radius'},
            {'node': 'card', 'v1': 'properties.mystery'},
          ],
        },
      ],
    },
  ];

  test('a node links to its component: main or instance, version, settings', () {
    final json = {
      'id': 'card',
      'type': 'stack',
      'layout': {'width': 100, 'height': 50},
      'component': {'id': 'cmp1', 'role': 'main', 'version': 3, 'settings': settings},
    };
    final n = Node.fromJson(json)!;
    final link = n.component!;
    expect(link.id, 'cmp1');
    expect(link.isMain, isTrue);
    expect(link.version, 3);
    expect(link.settings.first.targets.single, const SettingTarget('t', 'props.text'));
    expect(link.settings.last.isGroup, isTrue);
    expect(link.settings.last.settings.single.extra, {'min': 0});
    expect(link.settings.last.settings.single.targets.last.v1, 'properties.mystery');
    expect(n.extra, isEmpty);
    expect(n.toJson(), json);
    expect(Node.fromJson(n.toJson()), n);

    // Sparse: an instance at version 1 is just its id.
    final inst = n.withComponent(const ComponentLink(id: 'cmp1'));
    expect(inst.toJson()['component'], {'id': 'cmp1'});
    expect(n.withComponent(null).toJson().containsKey('component'), isFalse);
  });

  test("the editor's marker in extra reads as a link", () {
    final n = Node.fromJson({
      'id': 'x',
      'type': 'box',
      'component': {'id': 'c9', 'marker': 'component', 'version': 2},
    })!;
    expect(n.component, const ComponentLink(id: 'c9', role: ComponentRole.main, version: 2));
    expect(n.extra, isEmpty);
    expect(Node.fromJson({'id': 'x', 'type': 'box', 'component': {'marker': 'instance'}})!.component, isNull);
  });

  test("a copy's settings follow its new ids", () {
    final link = ComponentLink.fromJson({'id': 'cmp1', 'settings': settings})!;
    final copy = link.remapped({'t': 't2', 'card': 'card2'});
    expect(copy.settings.first.targets.single.node, 't2');
    expect(copy.settings.last.settings.single.targets.map((t) => t.node), ['card2', 'card2']);
  });

  test('a component definition round-trips', () {
    final json = {
      'schema': 2,
      'id': 'cmp1',
      'name': 'Card',
      'version': 3,
      'size': [100, 50],
      'document': {
        'schema': 2,
        'roots': ['card'],
        'nodes': {
          'card': {
            'type': 'stack',
            'children': ['t'],
            'layout': {'width': 100, 'height': 50},
            'component': {'id': 'cmp1', 'role': 'main', 'version': 3, 'settings': settings},
          },
          't': {'type': 'text', 'layout': {'width': 0, 'height': 0}, 'props': {'text': 'Hi'}},
        },
      },
      'preview': {'url': 'https://x/p.png', 'blurhash': 'L00'},
      'source': {'project': 'p', 'page': 'pg', 'node': 'orig'},
      'createdAt': 1700000000000,
    };
    final d = ComponentDefinition.fromJson(json)!;
    expect(d.rootId, 'card');
    expect(d.settings.length, 2);
    expect(d.width, 100);
    expect(d.toJson(), json);
    expect(ComponentDefinition.fromJson(d.toJson()), d);
    expect(ComponentDefinition.fromJson({'name': 'no id'}), isNull);
  });
}
