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

  test('A saved toast without colors takes the theme', () {
    // Toasts saved before theming omitted their default colors.
    final toast = ActionModel.fromJson({
      'type': 'showToast',
      'message': 'Saved',
    }) as ShowToastAction;
    expect(toast.backgroundColor, isNull);
    expect(toast.textColor, isNull);
    expect(toast.style, ToastStyle.neutral);
    expect(toast.position, ToastPosition.bottom);
    expect(toast.hasAction, isFalse);
    expect(toast.actions, isEmpty);

    // Colors a user picked stay.
    final picked = ActionModel.fromJson({
      'type': 'showToast',
      'message': 'Saved',
      'backgroundColor': {'r': 1.0, 'g': 0.0, 'b': 0.0, 'a': 1.0},
    }) as ShowToastAction;
    expect(picked.backgroundColor, const ColorRGBA(r: 1, g: 0, b: 0, a: 1));
  });

  test('ShowToastAction round-trips its button, style and position', () {
    final toast = ShowToastAction(
      message: 'Item deleted',
      style: ToastStyle.error,
      position: ToastPosition.top,
      actionLabel: 'Undo',
      actions: [ShowToastAction(message: 'Restored')],
      duration: 5000,
    );
    final Map json = toast.toJson();
    expect(json['style'], 'error');
    expect(json['position'], 'top');
    expect(json['actionLabel'], 'Undo');
    expect((json['actions'] as List).single, {
      'type': 'showToast',
      'message': 'Restored',
    });
    expect(json.containsKey('backgroundColor'), isFalse);
    final ActionModel decoded = ActionModel.fromJson(json);
    expect(decoded, toast);
    expect((decoded as ShowToastAction).hasAction, isTrue);

    // A style a newer editor adds reads as neutral.
    final future = ActionModel.fromJson({
      'type': 'showToast',
      'message': 'x',
      'style': 'sparkle',
    }) as ShowToastAction;
    expect(future.style, ToastStyle.neutral);

    expect(toast.copyWith(clearBackgroundColor: true).backgroundColor, isNull);
  });

  test('ShowToastAction keeps its accent edge, radius and width', () {
    final toast = ShowToastAction(
      message: 'Saved',
      accentColor: ColorRGBA.black,
      cornerRadius: 4,
      maxWidth: 460,
    );
    final Map json = toast.toJson();
    expect(json['maxWidth'], 460);
    expect(ShowToastAction.fromJson(json), toast);
    final Map plain = ShowToastAction(message: 'Saved').toJson();
    for (final key in ['accentColor', 'cornerRadius', 'maxWidth']) {
      expect(plain.containsKey(key), isFalse, reason: key);
    }
  });
}
