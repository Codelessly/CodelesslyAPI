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

  test('ShowToastAction round-trips its look', () {
    final Map json = {
      'type': 'showToast',
      'message': r'Spotted ${item.name}',
      'actionLabel': 'View',
      'backgroundColor': '#1F2B2E',
      'textColor': '#F3ECDD',
      'actionColor': '#9CC5B5',
      'showClose': true,
      'closeColor': '#F3ECDD',
      'cornerRadius': 4,
      'border': {'color': '#1F2B2E', 'width': 1.5},
      'shadows': [
        {
          'id': 'stamp',
          'type': 'dropShadow',
          'radius': 0,
          'spread': 0,
          'color': '#1F2B2E',
          'offset': {'x': 4, 'y': 4},
        },
      ],
      'padding': [16, 0, 6, 0],
      'maxWidth': 480,
      'iconSize': 34,
      'messageStyle': {
        'fontFamily': 'Work Sans',
        'fontWeight': 'w600',
        'fontSize': 13,
        'lineHeight': 1.4,
      },
      'actionStyle': {'fontFamily': 'Work Sans', 'fontWeight': 'w700'},
      'bottomOffset': 24,
      'bottomOffsets': {'mobile': 84},
    };
    final toast = ActionModel.fromJson(json) as ShowToastAction;
    expect(toast.actionColor, ColorRGBA.fromHex('#9CC5B5'));
    expect(toast.showClose, isTrue);
    expect(toast.cornerRadius, 4);
    expect(toast.border!.width, 1.5);
    expect(toast.shadows!.single.offset, const Vec(4, 4));
    expect(toast.messageStyle!.fontName!.family, 'Work Sans');
    expect(toast.messageStyle!.fontName!.weight, FontWeightNumeric.w600);
    expect(toast.actionStyle!.fontSize, isNull);
    expect(toast.maxWidth, 480);
    expect(toast.iconSize, 34);
    // Per screen size offsets, falling back to bottomOffset.
    expect(toast.bottomOffsetFor(390), 84);
    expect(toast.bottomOffsetFor(834), 24);
    expect(toast.bottomOffsetFor(1440), 24);

    final Map out = toast.toJson();
    expect(out['bottomOffsets'], {'mobile': 84.0});
    expect(out['messageStyle'], {
      'fontFamily': 'Work Sans',
      'fontWeight': 'w600',
      'fontSize': 13.0,
      'lineHeight': 1.4,
    });
    expect(ActionModel.fromJson(out), toast);

    // None of it is written for a plain toast.
    final Map plain = ShowToastAction(message: 'Saved').toJson();
    expect(plain, {'type': 'showToast', 'message': 'Saved'});
    expect(ShowToastAction(message: 'x').bottomOffsetFor(390), 104);
  });
}
