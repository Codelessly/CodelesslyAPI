import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('ShowToastAction round-trips and omits defaults', () {
    final ActionModel action = ActionModel.fromJson({
      'type': 'showToast',
      'message': r'Added ${storage.drink.name} to your order',
    });
    expect(action, isA<ShowToastAction>());
    final toast = action as ShowToastAction;
    expect(toast.duration, 2600);
    expect(toast.icon, isNull);
    expect(toast.toJson(), {
      'type': 'showToast',
      'message': r'Added ${storage.drink.name} to your order',
    });

    final custom = toast.copyWith(duration: 4000, bottomOffset: 40);
    expect(ActionModel.fromJson(custom.toJson()), custom);
    expect(ActionType.showToast.prettify, 'Show Toast');
  });
}
