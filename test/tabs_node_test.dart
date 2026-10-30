import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final box = NodeBox(0, 0, 100, 100);
  TabsNode tabs() => TabsNode(
    id: 'tabs',
    name: 'Tabs',
    basicBoxLocal: box,
    tabs: const [
      TabsItem(title: 'First', child: 'a'),
      TabsItem(title: 'Second', child: 'b'),
    ],
  );

  test('ordered tabs roundtrip and children are synchronized', () {
    final wire = tabs().toJson();
    expect(wire['type'], 'tabs');
    expect(wire['children'], ['a', 'b']);
    expect(wire['tabs'], [
      {'title': 'First', 'child': 'a'},
      {'title': 'Second', 'child': 'b'},
    ]);
    final decoded = NodeJsonConverter().fromJson(wire) as TabsNode;
    expect(decoded.children, ['a', 'b']);
    expect(decoded.toJson(), wire);
    decoded.children.removeLast();
    expect(() => decoded.toJson(), throwsStateError);
  });

  test('zero tabs, duplicates and self references are rejected', () {
    for (final items in [
      <TabsItem>[],
      [
        const TabsItem(title: 'A', child: 'a'),
        const TabsItem(title: 'B', child: 'a'),
      ],
      [const TabsItem(title: 'Self', child: 'tabs')],
    ]) {
      expect(
        () =>
            TabsNode(id: 'tabs', name: 'Tabs', basicBoxLocal: box, tabs: items),
        throwsArgumentError,
      );
    }
    final wire = tabs().toJson();
    for (final bad in [
      {...wire, 'tabs': []},
      {
        ...wire,
        'tabs': [
          {'title': 'A', 'child': 'a'},
          {'title': 'B', 'child': 'a'},
        ],
        'children': ['a', 'a'],
      },
      {
        ...wire,
        'tabs': [
          {'title': 'Self', 'child': 'tabs'},
        ],
        'children': ['tabs'],
      },
      {
        ...wire,
        'tabs': [
          {'title': 'A', 'child': 2},
        ],
      },
      {
        ...wire,
        'tabs': [
          {
            'title': {'path': '/title'},
            'child': 'a',
          },
        ],
      },
      {
        ...wire,
        'children': ['b', 'a'],
      },
      {...wire}..remove('children'),
    ]) {
      expect(() => NodeJsonConverter().fromJson(bad), throwsArgumentError);
    }
  });

  test('node map rejects missing scene child references', () {
    final wire = tabs().toJson().cast<String, dynamic>();
    final child = {
      'id': 'a',
      'name': 'A',
      'type': 'spacer',
      'basicBoxLocal': [0, 0, 10, 10],
    };
    expect(
      () => NodesMapConverter.deserialize({'tabs': wire, 'a': child}),
      throwsA(isA<UnresolvedDocumentSchema>()),
    );
    final result = NodesMapConverter.deserialize({
      'tabs': wire,
      'a': child,
      'b': {...child, 'id': 'b', 'name': 'B'},
    });
    expect((result['tabs'] as TabsNode).children, ['a', 'b']);
  });
}
