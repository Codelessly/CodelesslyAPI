import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('ConfirmAction round-trips with its branches and omits defaults', () {
    final ActionModel action = ActionModel.fromJson({
      'type': 'confirm',
      'title': 'Leave album?',
      'destructive': true,
      'actions': [
        {'type': 'showToast', 'message': 'Left the album'},
      ],
    });
    expect(action, isA<ConfirmAction>());
    final confirm = action as ConfirmAction;
    expect(confirm.confirmLabel, 'OK');
    expect(confirm.cancelLabel, 'Cancel');
    expect(confirm.actions.single, isA<ShowToastAction>());
    expect(confirm.cancelActions, isEmpty);
    expect(confirm.toJson(), {
      'type': 'confirm',
      'title': 'Leave album?',
      'destructive': true,
      'actions': [
        {'type': 'showToast', 'message': 'Left the album'},
      ],
    });

    final custom = confirm.copyWith(confirmLabel: 'Leave', message: 'Sure?');
    expect(ActionModel.fromJson(custom.toJson()), custom);
    expect(ActionType.confirm.prettify, 'Confirm Dialog');
  });
}
