import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('debounce and watched variable round-trip, omitted by default', () {
    final TriggerModel plain = TriggerModel(type: TriggerType.changed);
    expect(plain.toJson(), {'type': 'changed'});
    final TriggerModel watched = TriggerModel(
      type: TriggerType.valueChanged,
      variable: 'query',
      debounceMs: 300,
    );
    expect(TriggerModel.fromJson(watched.toJson()), watched);
    expect(TriggerType.valueChanged.prettify, 'Value Changed');
  });
}
