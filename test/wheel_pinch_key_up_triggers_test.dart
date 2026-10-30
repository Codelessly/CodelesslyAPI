import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('wheel, pinch and key up triggers round-trip with their names', () {
    for (final (type, name, label) in [
      (TriggerType.wheel, 'wheel', 'Wheel'),
      (TriggerType.pinch, 'pinch', 'Pinch'),
      (TriggerType.keyUp, 'keyUp', 'Key Up'),
    ]) {
      final TriggerModel trigger = TriggerModel(type: type, key: type == TriggerType.keyUp ? ' ' : null);
      expect(trigger.toJson()['type'], name);
      expect(TriggerModel.fromJson(trigger.toJson()).type, type);
      expect(type.prettify, label);
    }
  });

  test('frames and rectangles take wheel and pinch reactions', () {
    final List<ReactionMixin> shapes = [
      FrameNode(id: 'f', name: 'f', basicBoxLocal: NodeBox(0, 0, 10, 10), children: const []),
      RectangleNode(id: 'r', name: 'r', basicBoxLocal: NodeBox(0, 0, 10, 10)),
    ];
    for (final ReactionMixin node in shapes) {
      expect(node.triggerTypes, containsAll([TriggerType.wheel, TriggerType.pinch]));
    }
  });
}
