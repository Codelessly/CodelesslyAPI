import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a node without a transition writes none', () {
    final RectangleNode node = RectangleNode(
      id: 'r',
      name: 'r',
      basicBoxLocal: NodeBox(0, 0, 10, 10),
    );
    expect(node.transition, isNull);
    expect(node.toJson().containsKey('transition'), isFalse);
  });

  test('a transition round-trips on any node with an opacity', () {
    final Map json = {
      'id': 'f',
      'name': 'f',
      'type': 'rowColumn',
      'rowColumnType': 'column',
      'basicBoxLocal': [0, 0, 10, 10],
      'transition': {'durationMillis': 1100, 'curve': 'easeInOut'},
    };
    final BaseNode node = NodeJsonConverter().fromJson(json)!;
    expect(
      (node as BlendMixin).transition,
      const NodeTransition(durationMillis: 1100),
    );
    final BaseNode again = NodeJsonConverter().fromJson(node.toJson())!;
    expect((again as BlendMixin).transition?.durationMillis, 1100);
    expect(const NodeTransition().toJson(), isEmpty);
    expect(const NodeTransition().duration, const Duration(milliseconds: 200));
  });
}
