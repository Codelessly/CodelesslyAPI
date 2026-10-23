import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a plain dialog keeps its old JSON', () {
    final ActionModel action = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'c1',
    });
    expect(action, isA<ShowDialogAction>());
    final ShowDialogAction dialog = action as ShowDialogAction;
    expect(dialog.presentation, DialogPresentation.dialog);
    expect(dialog.alignment, AlignmentModel.center);
    expect(dialog.insets, EdgeInsetsModel.zero);
    expect(dialog.toJson(), {
      'type': 'showDialog',
      'destinationId': 'c1',
      'params': <String, dynamic>{},
    });
  });

  test('sheets and placed dialogs round-trip', () {
    for (final Map<String, dynamic> json in <Map<String, dynamic>>[
      {
        'type': 'showDialog',
        'destinationId': 'session',
        'params': {'id': r'${item.id}'},
        'presentation': 'bottomSheet',
      },
      {
        'type': 'showDialog',
        'destinationId': 'session',
        'params': <String, dynamic>{},
        'presentation': 'sideSheet',
        'insets': 10,
      },
      {
        'type': 'showDialog',
        'destinationId': 'settings',
        'params': <String, dynamic>{},
        'alignment': {
          'data': [-1, 1],
        },
        'insets': [96, 0, 0, 16],
      },
    ]) {
      final ShowDialogAction action =
          ActionModel.fromJson(json) as ShowDialogAction;
      expect(ActionModel.fromJson(action.toJson()), action, reason: '$json');
    }
    final ShowDialogAction popover = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'settings',
      'alignment': {
        'data': [-1, 1],
      },
      'insets': [96, 0, 0, 16],
    }) as ShowDialogAction;
    expect(popover.alignment, AlignmentModel.bottomLeft);
    expect(popover.insets.l, 96);
    expect(popover.insets.b, 16);
  });

  test('maxHeightFactor round-trips and is left out when unset', () {
    final ShowDialogAction action = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'logForm',
      'maxHeightFactor': 0.9,
    }) as ShowDialogAction;
    expect(action.maxHeightFactor, 0.9);
    expect(action.toJson()['maxHeightFactor'], 0.9);
    expect(ActionModel.fromJson(action.toJson()), action);

    final ShowDialogAction plain = ShowDialogAction(destinationId: 'c1');
    expect(plain.maxHeightFactor, isNull);
    expect(plain.toJson().containsKey('maxHeightFactor'), isFalse);
    expect(plain == action.copyWith(destinationId: 'c1'), isFalse);
  });

  test('copyWith sets and clears maxHeightFactor', () {
    final ShowDialogAction action = ShowDialogAction(
      destinationId: 'logForm',
      nonBlocking: true,
    );
    final ShowDialogAction capped = action.copyWith(maxHeightFactor: 0.8);
    expect(capped.maxHeightFactor, 0.8);
    expect(capped.nonBlocking, isTrue);
    expect(
      capped
          .copyWith(presentation: DialogPresentation.bottomSheet)
          .maxHeightFactor,
      0.8,
    );
    expect(capped.copyWith(clearMaxHeightFactor: true).maxHeightFactor, isNull);
  });
}
