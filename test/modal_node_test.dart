import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final box = NodeBox(0, 0, 100, 100);
  ModalNode modal() => ModalNode(
    id: 'modal',
    name: 'Modal',
    basicBoxLocal: box,
    trigger: 'trigger',
    content: 'content',
  );

  test('typed modal roundtrips with ordered scene children', () {
    final node = modal();
    final wire = node.toJson();
    expect(wire['type'], 'modal');
    expect(wire['children'], ['trigger', 'content']);
    final decoded = NodeJsonConverter().fromJson(wire) as ModalNode;
    expect(decoded.trigger, 'trigger');
    expect(decoded.content, 'content');
    expect(decoded.toJson(), wire);
  });

  test(
    'constructor and wire reject malformed IDs and inconsistent children',
    () {
      for (final ids in [
        (' ', 'content'),
        ('same', 'same'),
        ('modal', 'content'),
      ]) {
        expect(
          () => ModalNode(
            id: 'modal',
            name: 'Modal',
            basicBoxLocal: box,
            trigger: ids.$1,
            content: ids.$2,
          ),
          throwsArgumentError,
        );
      }
      final wire = modal().toJson();
      for (final bad in [
        {...wire, 'trigger': 4},
        {...wire, 'content': ''},
        {
          ...wire,
          'children': ['content', 'trigger'],
        },
        {
          ...wire,
          'children': ['trigger'],
        },
        {...wire}..remove('children'),
      ]) {
        expect(
          () => NodeJsonConverter().fromJson(bad),
          throwsA(isA<ArgumentError>()),
        );
      }
    },
  );

  test('node map rejects unknown modal child, accepts present references', () {
    final wire = modal().toJson().cast<String, dynamic>();
    expect(
      () => NodesMapConverter.deserialize({'modal': wire}),
      throwsA(isA<UnresolvedDocumentSchema>()),
    );
    final children = {
      for (final id in ['trigger', 'content'])
        id: {
          'id': id,
          'name': id,
          'type': 'spacer',
          'basicBoxLocal': [0, 0, 10, 10],
        },
    };
    final result = NodesMapConverter.deserialize({'modal': wire, ...children});
    expect((result['modal'] as ModalNode).children, ['trigger', 'content']);
  });
}
