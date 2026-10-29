import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('an interval trigger round-trips its period', () {
    final trigger = TriggerModel(
      type: TriggerType.interval,
      intervalMillis: 3000,
    );
    final json = trigger.toJson();
    expect(json, {'type': 'interval', 'intervalMillis': 3000});
    expect(TriggerModel.fromJson(json), trigger);
  });

  test('the default period is omitted and read back as one second', () {
    final json = TriggerModel(type: TriggerType.interval).toJson();
    expect(json, {'type': 'interval'});
    expect(TriggerModel.fromJson(json).intervalMillis, 1000);
  });

  test('a trigger from before intervals still reads', () {
    expect(TriggerModel.fromJson({'type': 'click'}).type, TriggerType.click);
  });

  test('periods shorter than the minimum are clamped', () {
    expect(
      TriggerModel(
        type: TriggerType.interval,
        intervalMillis: 5,
      ).effectiveIntervalMillis,
      TriggerModel.minIntervalMillis,
    );
  });
}
