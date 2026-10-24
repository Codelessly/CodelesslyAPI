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

  test('ConfirmAction round-trips its border, shadows, fonts and buttons', () {
    final Map stamp = {
      'id': 'stamp',
      'type': 'dropShadow',
      'radius': 0,
      'spread': 0,
      'color': '#1F2B2E',
      'offset': {'x': 6, 'y': 6},
    };
    final confirm = ActionModel.fromJson({
      'type': 'confirm',
      'title': 'Delete this sighting?',
      'destructive': true,
      'backgroundColor': '#F3ECDD',
      'cornerRadius': 6,
      'border': {'color': '#1F2B2E', 'width': 1.5},
      'shadows': [stamp],
      'titleStyle': {
        'fontFamily': 'Fraunces',
        'fontWeight': 'w600',
        'fontSize': 19,
      },
      'messageStyle': {'fontFamily': 'Work Sans', 'color': '#4A5558'},
      'buttonStyle': {'fontFamily': 'Work Sans', 'fontWeight': 'w600'},
      'buttonRadius': 4,
      'buttonBorder': {'color': '#1F2B2E', 'width': 1.5},
      'buttonShadows': [
        {
          ...stamp,
          'offset': {'x': 3, 'y': 3},
        },
      ],
      'confirmColor': '#B3392B',
      'confirmTextColor': '#F3ECDD',
      'cancelColor': '#FBF7EE',
      'cancelTextColor': '#1F2B2E',
    }) as ConfirmAction;
    expect(confirm.border!.width, 1.5);
    expect(confirm.shadows!.single.offset, const Vec(6, 6));
    expect(confirm.titleStyle!.fontName!.family, 'Fraunces');
    expect(confirm.messageStyle!.color, ColorRGBA.fromHex('#4A5558'));
    expect(confirm.buttonRadius, 4);
    expect(confirm.buttonShadows!.single.offset, const Vec(3, 3));
    expect(confirm.cancelColor, ColorRGBA.fromHex('#FBF7EE'));
    expect(ActionModel.fromJson(confirm.toJson()), confirm);
    expect(confirm.copyWith(clearShadows: true).shadows, isNull);

    // An existing confirm writes none of it.
    expect(ConfirmAction(title: 'Leave?').toJson(), {
      'type': 'confirm',
      'title': 'Leave?',
    });
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
