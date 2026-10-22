import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('An interval trigger round-trips and omits its default period', () {
    final TriggerModel trigger = TriggerModel.fromJson({'type': 'interval'});
    expect(trigger.type, TriggerType.interval);
    expect(trigger.intervalMs, 1000);
    expect(trigger.toJson(), {'type': 'interval'});

    final TriggerModel faster = trigger.copyWith(intervalMs: 250);
    expect(faster.toJson(), {'type': 'interval', 'intervalMs': 250});
    expect(TriggerModel.fromJson(faster.toJson()), faster);
    expect(TriggerType.interval.prettify, 'Every Interval');
  });

  test('Screens offer the interval trigger', () {
    final CanvasNode canvas = CanvasNode(
      id: 'canvas',
      name: 'Canvas',
      basicBoxLocal: NodeBox(0, 0, 390, 844),
      children: [],
      properties: CanvasProperties(bodyId: 'body'),
    );
    expect(canvas.triggerTypes, contains(TriggerType.interval));
  });
}
