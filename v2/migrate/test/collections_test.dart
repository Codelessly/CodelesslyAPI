import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

/// Migrates a canvas whose body frame holds [nodes] (v1 JSON by id; the
/// first is the body's child) and returns the v2 nodes.
Map _migrate(Map<String, Map<String, Object?>> nodes) {
  final first = nodes.keys.first;
  final v2 = migrateDocument({
    'rootNode': {
      'children': ['c'],
    },
    'c': {
      'id': 'c',
      'type': 'canvas',
      'name': 'c',
      'parentID': 'rootNode',
      'basicBoxLocal': [0, 0, 400, 400],
      'properties': {'bodyId': 'b'},
      'children': ['b'],
    },
    'b': {
      'id': 'b',
      'type': 'frame',
      'name': 'b',
      'parentID': 'c',
      'basicBoxLocal': [0, 0, 400, 400],
      'children': [first],
    },
    for (final e in nodes.entries) e.key: {'id': e.key, 'name': e.key, ...e.value},
  });
  return v2['nodes'] as Map;
}

Map<String, Object?> _item(String parent) => {
  'type': 'rectangle',
  'parentID': parent,
  'basicBoxLocal': [20, 30, 50, 20],
};

Map<String, Object?> _list(Map<String, Object?> properties, [Map<String, Object?> more = const {}]) => {
  'type': 'listView',
  'parentID': 'b',
  'basicBoxLocal': [0, 0, 200, 100],
  'children': ['i'],
  'properties': {'dividerProperties': {}, ...properties},
  ...more,
};

void main() {
  test('a list with its own wrap spacing always wraps', () {
    final n = _migrate({
      'l': _list(
        {'wrap': true, 'wrapSpacing': 6, 'wrapRunSpacing': 4, 'wrapCrossAlignment': 'center'},
        {'scrollDirection': 'horizontal'},
      ),
      'i': _item('l'),
    });
    expect(n['l']['props'], {
      'scrollDirection': 'horizontal',
      'wrap': true,
      'wrapSpacing': 6,
      'runSpacing': 4,
      'wrapCrossAlignment': 'center',
    });
    expect(n['l'].containsKey('v1'), isFalse);
  });

  test('a list spaced by its separator wraps only with a known count', () {
    final uncounted = _migrate({
      'l': _list({'wrap': true, 'hasSeparator': true, 'separatorSpacing': 12, 'runSpacing': 8}),
      'i': _item('l'),
    });
    expect(uncounted['l']['props'], {'separator': 'space', 'spacing': 12});
    final counted = _migrate({
      'l': _list({'itemCount': 4, 'wrap': true, 'hasSeparator': true, 'separatorSpacing': 12, 'runSpacing': 8}),
      'i': _item('l'),
    });
    expect(counted['l']['props'], {'itemCount': 4, 'wrap': true, 'wrapSpacing': 12, 'runSpacing': 8});
  });

  test('stacked lists become decks; positional stacks keep the item position', () {
    expect(
      _migrate({
        'l': _list({'stacked': true}),
        'i': _item('l'),
      })['l']['props'],
      {'layout': 'deck'},
    );
    final stack = _migrate({
      'l': _list(
        {'layout': 'stack'},
        {
          'padding': [10, 5, 0, 0],
        },
      ),
      'i': _item('l'),
    });
    expect(stack['l']['props'], {
      'layout': 'stack',
      'itemPosition': [10, 25],
    });
    expect(stack['i']['layout'].containsKey('x'), isFalse);
  });

  test('dividers, clipping and cloud queries', () {
    final n = _migrate({
      'l': _list(
        {
          'hasSeparator': true,
          'separator': 'divider',
          'separatorSpacing': 9,
          'dividerProperties': {'thickness': 2, 'color': '#FF0000', 'indent': 4},
        },
        {
          'clipsContent': false,
          'useCloudDatabase': true,
          'collectionPath': 'posts',
          'limit': 10,
          'isScrollable': false,
        },
      ),
      'i': _item('l'),
    });
    expect(n['l']['props'], {
      'clipBehavior': 'none',
      'query': {'enabled': true, 'collectionPath': 'posts', 'limit': 10},
      'scrollable': false,
      'separator': 'divider',
      'spacing': 9,
      'dividerThickness': 2,
      'dividerColor': '#FFFF0000',
      'dividerIndent': 4,
    });
    expect(n['l'].containsKey('v1'), isFalse);
  });

  test('a grid flattens its delegate', () {
    final n = _migrate({
      'g': {
        'type': 'gridView',
        'parentID': 'b',
        'basicBoxLocal': [0, 0, 300, 300],
        'children': ['i'],
        'isScrollable': true,
        'useFlutterListView': false,
        'properties': {
          'itemCount': 6,
          'gridDelegate': {
            'type': 'maxCrossAxisExtent',
            'maxCrossAxisExtent': 120,
            'childAspectRatio': 0.8,
            'mainAxisSpacing': 4,
            'shrinkWrapRows': true,
          },
        },
      },
      'i': _item('g'),
    });
    expect(n['g']['props'], {
      'itemCount': 6,
      'maxCrossAxisExtent': 120,
      'mainAxisSpacing': 4,
      'childAspectRatio': 0.8,
      'shrinkWrapRows': true,
    });
  });

  test('an expansion tile takes its list tile as a slot', () {
    final n = _migrate({
      'e': {
        'type': 'expansionTile',
        'parentID': 'b',
        'basicBoxLocal': [0, 0, 300, 112],
        'children': ['lt', 'x'],
        'listTileChild': 'lt',
        'rowColumnType': 'column',
        'mainAxisAlignment': 'start',
        'crossAxisAlignment': 'center',
        'isExpanded': false,
        'properties': {
          'tilePadding': [16, 0, 24, 0],
          'initiallyExpanded': true,
        },
      },
      'lt': {
        'type': 'listTile',
        'parentID': 'e',
        'basicBoxLocal': [0, 0, 300, 56],
        'properties': {},
      },
      'x': _item('e'),
    });
    expect(n['e']['type'], 'expansionTile');
    expect(n['e']['slots'], {'tile': 'lt'});
    expect(n['e']['children'], ['x']);
    expect(n['e']['props']['initiallyExpanded'], true);
    expect(n['e']['props']['tilePadding'], [16, 0, 24, 0]);
    expect(n['e'].containsKey('v1'), isFalse);
  });

  test('an accordion keeps its alignment props, not a column\'s', () {
    final n = _migrate({
      'a': {
        'type': 'accordion',
        'parentID': 'b',
        'basicBoxLocal': [0, 0, 300, 200],
        'children': ['x', 'y'],
        'mainAxisAlignment': 'end',
        'crossAxisAlignment': 'start',
        'properties': {'isExpanded': false},
      },
      'x': _item('a'),
      'y': _item('a'),
    });
    expect(n['a']['type'], 'accordion');
    expect(n['a']['props'], {'mainAxisAlignment': 'end', 'crossAxisAlignment': 'start', 'expanded': false});
  });
}
