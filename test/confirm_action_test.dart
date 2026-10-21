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

  test('ConfirmAction round-trips its custom dialog and style', () {
    final confirm = ConfirmAction(
      title: 'Delete photo?',
      dialogId: 'canvas-confirm',
      params: {'photo': r'${data.name}'},
      barrierDismissible: false,
      barrierColor: ColorRGBA.black,
      backgroundColor: ColorRGBA.white,
      textColor: ColorRGBA.black,
      confirmColor: const ColorRGBA(r: 0.2, g: 0.4, b: 1, a: 1),
      cornerRadius: 20,
      actions: [ShowToastAction(message: 'Deleted')],
    );
    final Map json = confirm.toJson();
    expect(json['dialogId'], 'canvas-confirm');
    expect(json['params'], {'photo': r'${data.name}'});
    expect(json['barrierDismissible'], false);
    expect(json['cornerRadius'], 20);
    expect(ActionModel.fromJson(json), confirm);

    // An existing confirm keeps the built-in, themed dialog.
    final legacy = ActionModel.fromJson({
      'type': 'confirm',
      'title': 'Leave?',
    }) as ConfirmAction;
    expect(legacy.dialogId, isNull);
    expect(legacy.params, isEmpty);
    expect(legacy.barrierDismissible, isTrue);
    expect(legacy.confirmColor, isNull);
    expect(legacy.backgroundColor, isNull);
    expect(legacy.cornerRadius, isNull);
    expect(legacy.toJson(), {'type': 'confirm', 'title': 'Leave?'});

    expect(
      confirm.copyWith(clearDialogId: true, clearCornerRadius: true).dialogId,
      isNull,
    );
  });

  test('ConfirmAction reads a dialog result', () {
    expect(ConfirmAction.isConfirmResult({'confirmed': true}), isTrue);
    expect(ConfirmAction.isConfirmResult({'confirmed': 'true'}), isTrue);
    expect(ConfirmAction.isConfirmResult({'confirmed': false}), isFalse);
    expect(ConfirmAction.isConfirmResult({'other': 1}), isFalse);
    expect(ConfirmAction.isConfirmResult(<String, dynamic>{}), isFalse);
    expect(ConfirmAction.isConfirmResult(null), isFalse);
    expect(ConfirmAction.isConfirmResult(true), isTrue);
  });
}
