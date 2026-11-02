import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('A card toast round-trips its title, disc, layout and bindings', () {
    final Map<String, dynamic> json = {
      'type': 'showToast',
      'title': 'Gate change',
      'message': r'MR 88 now boards at ${flight.gate}',
      'position': 'top',
      'duration': 6000,
      'icon': const MultiSourceIconModel.icon(size: 18).toJson(),
      'iconDiscColor': '#2EE5B04A',
      'iconDiscSize': 40,
      'titleStyle': {'fontSize': 13.5, 'fontWeight': 'w800'},
      'messageColor': '#B3F7F1E3',
      'alignment': 'end',
      'alignments': {'mobile': 'stretch'},
      'sideMargin': 24,
      'sideMargins': {'mobile': 14},
      'maxWidth': 380,
      'minWidth': 380,
      'actionLabel': 'View',
      'actions': [
        {'type': 'navigation', 'destinationId': 'pass'},
      ],
      'showClose': true,
      'variables': {
        'backgroundColor': r'${pal.toast}',
        'iconColor': r'${alert.color}',
        'iconDiscColor': r'${= alpha(alert.color, 0.18)}',
        'borderColor': r'${= alpha(alert.color, 0.5)}',
        'actionColor': r'${alert.color}',
      },
    };
    final ShowToastAction toast = ActionModel.fromJson(json) as ShowToastAction;
    expect(toast.hasTitle, isTrue);
    expect(toast.title, 'Gate change');
    expect(toast.iconDiscSize, 40);
    expect(toast.iconDiscColor!.a, closeTo(0x2E / 255, 1e-9));
    expect(toast.alignmentFor(390), ToastAlignment.stretch);
    expect(toast.alignmentFor(1440), ToastAlignment.end);
    expect(toast.sideMarginFor(390), 14);
    expect(toast.sideMarginFor(900), 24);
    expect(toast.variables['borderColor'], r'${= alpha(alert.color, 0.5)}');
    expect(toast.titleStyle!.fontSize, 13.5);

    final ShowToastAction copy =
        ActionModel.fromJson(toast.toJson()) as ShowToastAction;
    expect(copy, toast);
    expect(copy.toJson(), toast.toJson());
  });

  test('A toast reads body as its message and keeps old JSON unchanged', () {
    final ShowToastAction body = ActionModel.fromJson({
      'type': 'showToast',
      'title': 'Now boarding',
      'body': 'MR 88 / Gate A11',
    }) as ShowToastAction;
    expect(body.message, 'MR 88 / Gate A11');
    expect(body.toJson(), {
      'type': 'showToast',
      'message': 'MR 88 / Gate A11',
      'title': 'Now boarding',
    });

    final ShowToastAction titleOnly = ActionModel.fromJson({
      'type': 'showToast',
      'title': 'Link copied',
    }) as ShowToastAction;
    expect(titleOnly.message, '');

    // A toast saved before the card fields reads and writes as it did.
    final Map<String, dynamic> legacy = {
      'type': 'showToast',
      'message': 'Saved',
      'alignment': 'start',
      'sideMargin': 20,
    };
    final ShowToastAction old = ActionModel.fromJson(legacy) as ShowToastAction;
    expect(old.hasTitle, isFalse);
    expect(old.iconDiscColor, isNull);
    expect(old.variables, isEmpty);
    expect(old.alignmentFor(390), ToastAlignment.start);
    expect(old.sideMarginFor(390), 20);
    expect(old.toJson(), legacy);
  });

  test('ConfirmAction round-trips its color bindings', () {
    final ConfirmAction action = ActionModel.fromJson({
      'type': 'confirm',
      'title': 'Remove pass?',
      'message': 'It leaves your wallet.',
      'confirmLabel': 'Remove',
      'cancelLabel': 'Keep',
      'variables': {
        'backgroundColor': r'${pal.surface}',
        'titleColor': r'${pal.ink}',
        'messageColor': r'${pal.inkSoft}',
        'confirmColor': r'${pal.danger}',
        'cancelColor': r'${pal.surface}',
        'buttonBorderColor': r'${= alpha(pal.ink, 0.22)}',
      },
    }) as ConfirmAction;
    expect(action.variables['confirmColor'], r'${pal.danger}');
    final ConfirmAction copy =
        ActionModel.fromJson(action.toJson()) as ConfirmAction;
    expect(copy, action);
    expect(
      ConfirmAction(title: 'x').toJson().containsKey('variables'),
      isFalse,
    );
    for (final String key in action.variables.keys) {
      expect(ConfirmAction.bindableColors, contains(key));
    }
  });

  test('A frame keeps a content design size apart from its box', () {
    final FrameNode frame = FrameNode.fromJson({
      'id': 'face',
      'name': 'face',
      'type': 'frame',
      'basicBoxLocal': {'x': 0, 'y': 0, 'width': 680, 'height': 428},
      'children': <String>[],
      'contentFit': 'contain',
      'contentSize': {'width': 340, 'height': 214},
      'horizontalFit': 'expanded',
      'aspectRatio': 340 / 214,
    });
    expect(frame.contentSize, const SizeC(340, 214));
    expect(frame.contentDesignSize, const SizeC(340, 214));
    expect(frame.aspectRatio, closeTo(1.5888, 1e-4));
    final Map json = frame.toJson();
    expect(json['contentSize'], {'width': 340.0, 'height': 214.0});
    expect(json['aspectRatio'], closeTo(1.5888, 1e-4));
    expect(json.containsKey('contentDesignSize'), isFalse);
    final FrameNode copy = FrameNode.fromJson(json);
    expect(copy.contentSize, frame.contentSize);
    expect(copy.aspectRatio, frame.aspectRatio);

    // Without a design size the frame scales from its own content box.
    final FrameNode plain = FrameNode.fromJson({
      'id': 'f',
      'name': 'f',
      'type': 'frame',
      'basicBoxLocal': {'x': 0, 'y': 0, 'width': 300, 'height': 200},
      'children': <String>[],
    });
    expect(plain.contentSize, isNull);
    expect(plain.aspectRatio, isNull);
    expect(plain.contentDesignSize, const SizeC(300, 200));
    expect(plain.toJson().containsKey('contentSize'), isFalse);
    expect(plain.toJson().containsKey('aspectRatio'), isFalse);
  });
}
