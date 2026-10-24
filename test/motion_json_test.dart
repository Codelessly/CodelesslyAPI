import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  RectangleNode pad() => RectangleNode(
    id: 'pad',
    name: 'Pad',
    basicBoxLocal: NodeBox(0, 0, 44, 30),
  );

  test('transition, draw scale and pulse survive JSON', () {
    final RectangleNode node = pad()
      ..transitionMs = 200
      ..drawScale = 1.15
      ..pulse = const PulseModel(
        periodMs: 1400,
        opacityFrom: 0.55,
        opacityTo: 0,
        scaleFrom: 1,
        scaleTo: 1.4,
      );
    final RectangleNode read = RectangleNode.fromJson(node.toJson());
    expect(read.transitionMs, 200);
    expect(read.drawScale, 1.15);
    expect(read.pulse, node.pulse);
    expect(read.pulse!.reverse, isTrue);
  });

  test('a node without motion leaves it out of JSON and reads defaults', () {
    final Map json = pad().toJson();
    expect(json.containsKey('transitionMs'), isFalse);
    expect(json.containsKey('drawScale'), isFalse);
    expect(json.containsKey('pulse'), isFalse);
    final RectangleNode read = RectangleNode.fromJson(json);
    expect(read.transitionMs, 0);
    expect(read.drawScale, 1);
    expect(read.pulse, isNull);
  });

  test('a pulse leaves its defaults out of JSON', () {
    expect(const PulseModel(scaleTo: 1.4).toJson(), {'scaleTo': 1.4});
  });
}
