import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a rectangle reads and writes an SVG path and its stroke join', () {
    final RectangleNode node = RectangleNode.fromJson({
      'id': 'bracket',
      'name': 'bracket',
      'type': 'rectangle',
      'basicBoxLocal': [0, 0, 30, 30],
      'path': 'M2 30 V10 Q2 2 10 2 H30',
      'strokeCap': 'round',
      'strokeJoin': 'bevel',
    });
    expect(node.hasPath, isTrue);
    expect(node.path, 'M2 30 V10 Q2 2 10 2 H30');
    expect(node.strokeJoin, StrokeJoinEnum.bevel);
    final Map json = node.toJson();
    expect(json['path'], 'M2 30 V10 Q2 2 10 2 H30');
    expect(json['strokeJoin'], 'bevel');
    final BaseNode? back = NodeJsonConverter().fromJson(json);
    expect(back, isA<RectangleNode>());
    expect((back! as RectangleNode).strokeJoin, StrokeJoinEnum.bevel);
  });

  test('a plain rectangle has no path and omits the defaults', () {
    final RectangleNode node = RectangleNode.fromJson({
      'id': 'r',
      'name': 'r',
      'type': 'rectangle',
      'basicBoxLocal': [0, 0, 10, 10],
      'path': '  ',
      'strokeJoin': 'sideways',
    });
    expect(node.hasPath, isFalse);
    expect(node.strokeJoin, StrokeJoinEnum.miter);
    final Map json = RectangleNode(
      id: 'r',
      name: 'r',
      basicBoxLocal: NodeBox(0, 0, 10, 10),
    ).toJson();
    expect(json.containsKey('path'), isFalse);
    expect(json.containsKey('strokeJoin'), isFalse);
  });
}
