// v1 components: a node's marker and settings schema, and a stored
// component, as v2 (DESIGN.md §4.2).
import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

Map<String, Object?> _nodes() => {
      'card': {
        'id': 'card', 'name': 'Card', 'parentID': 'f', 'type': 'frame', 'basicBoxLocal': [0, 0, 120, 60],
        'children': ['label'], 'componentId': 'cmp1', 'markerType': 'component', 'componentVersion': 3,
        'componentSchema': {
          'properties': [
            {'label': 'Title', 'type': 'string', 'value': 'Hello', 'path': 'label.characters'},
            {
              'type': 'group', 'label': 'Look',
              'properties': [
                {'label': 'Radius', 'type': 'radius', 'value': 8, 'min': 0, 'paths': ['card.cornerRadius']},
                {'label': 'Fill', 'type': 'color', 'value': '#FF0000', 'paths': ['card.fills.0.color', 'card.mystery.x']},
              ],
            },
          ],
        },
      },
      'label': {
        'id': 'label', 'name': 'label', 'parentID': 'card', 'type': 'text', 'basicBoxLocal': [0, 0, 40, 16],
        'characters': 'Hello',
      },
    };

void main() {
  test("a node's component marker and settings become its link", () {
    final report = MigrationReport();
    final doc = migrateDocument({
      'rootNode': {'children': ['c']},
      'c': {'id': 'c', 'type': 'canvas', 'name': 'Home', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 300],
            'properties': {'bodyId': 'f'}, 'children': ['f']},
      'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 300], 'children': ['card', 'inst']},
      ..._nodes(),
      'inst': {'id': 'inst', 'name': 'Card', 'parentID': 'f', 'type': 'rectangle', 'basicBoxLocal': [200, 0, 50, 50],
               'componentId': 'cmp1', 'markerType': 'instance', 'componentVersion': 2},
    }, report: report);
    final nodes = doc['nodes'] as Map;
    expect(nodes['card']['component'], {
      'id': 'cmp1',
      'role': 'main',
      'version': 3,
      'settings': [
        {
          'label': 'Title', 'type': 'string', 'value': 'Hello',
          'targets': [{'node': 'label', 'path': 'props.text'}],
        },
        {
          'label': 'Look', 'type': 'group',
          'settings': [
            {
              'label': 'Radius', 'type': 'radius', 'value': 8, 'min': 0,
              'targets': [{'node': 'card', 'path': 'decoration.radius'}],
            },
            {
              'label': 'Fill', 'type': 'color', 'value': '#FF0000',
              'targets': [
                {'node': 'card', 'path': 'decoration.fills[0].color'},
                {'node': 'card', 'v1': 'mystery.x'},
              ],
            },
          ],
        },
      ],
    });
    expect(nodes['card'].containsKey('v1'), isFalse);
    expect(nodes['inst']['component'], {'id': 'cmp1', 'version': 2});
    expect(nodes['inst'].containsKey('v1'), isFalse);
    expect(report.unmappedSettings, {'frame.mystery.x': 1});
  });

  test('a stored component becomes a component definition', () {
    final out = migrateComponent({
      'id': 'cmp1',
      'name': 'Card',
      'version': 3,
      'createdAt': 1700000000000,
      'previewUrl': 'https://x/p.png',
      'blurhash': 'L00',
      'projectId': 'p',
      'pageId': 'pg',
      'privacy': {'owner': 'u'},
      'data': {
        'width': 120, 'height': 60, 'parentId': 'card', 'originalParentId': 'orig',
        'nodes': _nodes(), 'variables': {}, 'conditions': {},
      },
    });
    expect(out['size'], [120, 60]);
    expect(out['source'], {'project': 'p', 'page': 'pg', 'node': 'orig'});
    expect(out['v1'], {'privacy': {'owner': 'u'}});
    expect(out['id'], 'cmp1');
    expect(out['version'], 3);
    expect(out['preview'], {'url': 'https://x/p.png', 'blurhash': 'L00'});
    expect(out['createdAt'], 1700000000000);
    final doc = out['document'] as Map;
    expect(doc['roots'], ['card']);
    final nodes = doc['nodes'] as Map;
    expect(nodes['card']['type'], 'stack');
    expect(nodes['card']['component']['settings'][0]['targets'], [{'node': 'label', 'path': 'props.text'}]);
    expect(nodes['label']['props']['text'], 'Hello');
  });
}
