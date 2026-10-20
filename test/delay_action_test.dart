import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('DelayAction round-trips and omits its default', () {
    final ActionModel action = ActionModel.fromJson({'type': 'delay'});
    expect(action, isA<DelayAction>());
    expect((action as DelayAction).milliseconds, 500);
    expect(action.toJson(), {'type': 'delay'});

    final longer = action.copyWith(milliseconds: 2000);
    expect(longer.toJson(), {'type': 'delay', 'milliseconds': 2000});
    expect(ActionModel.fromJson(longer.toJson()), longer);
    expect(ActionType.delay.prettify, 'Delay');
  });
}
