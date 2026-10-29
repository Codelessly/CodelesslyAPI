import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('A saved ShowDialogAction stays a dialog and omits defaults', () {
    final action = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'canvas-1',
      'params': {'id': r'${data.id}'},
    }) as ShowDialogAction;
    expect(action.presentation, DialogPresentation.dialog);
    expect(action.sheetWidth, isNull);
    expect(action.maxHeightFactor, 1);
    expect(action.showDragHandle, isFalse);
    expect(action.toJson(), {
      'type': 'showDialog',
      'destinationId': 'canvas-1',
      'params': {'id': r'${data.id}'},
    });
  });

  test('ShowDialogAction round-trips a bottom sheet', () {
    final json = {
      'type': 'showDialog',
      'destinationId': 'account',
      'params': <String, dynamic>{},
      'presentation': 'bottomSheet',
      'maxHeightFactor': 0.8,
      'showDragHandle': true,
    };
    final action = ActionModel.fromJson(json) as ShowDialogAction;
    expect(action.presentation, DialogPresentation.bottomSheet);
    expect(action.maxHeightFactor, 0.8);
    expect(action.showDragHandle, isTrue);
    expect(action.toJson(), json);
    expect(ActionModel.fromJson(action.toJson()), action);
  });

  test('ShowDialogAction round-trips a side sheet', () {
    final action = ShowDialogAction(
      destinationId: 'flag-defect',
      presentation: DialogPresentation.sideSheet,
      sheetWidth: 480,
      barrierDismissible: false,
    );
    final Map json = action.toJson();
    expect(json['presentation'], 'sideSheet');
    expect(json['sheetWidth'], 480);
    expect(json.containsKey('maxHeightFactor'), isFalse);
    expect(ActionModel.fromJson(json), action);

    final cleared = action.copyWith(clearSheetWidth: true);
    expect(cleared.sheetWidth, isNull);
    expect(cleared.presentation, DialogPresentation.sideSheet);
  });

  test('An unknown presentation falls back to a dialog', () {
    final action = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'x',
      'presentation': 'unrecognized-mode',
    }) as ShowDialogAction;
    expect(action.presentation, DialogPresentation.dialog);
    expect(DialogPresentation.bottomSheet.prettify, 'Bottom Sheet');
  });

  test('A saved dialog action without an anchor stays centered', () {
    final Map<String, dynamic> saved = {
      'type': 'showDialog',
      'destinationId': 'canvas-1',
      'params': <String, dynamic>{},
    };
    final action = ActionModel.fromJson(saved) as ShowDialogAction;
    expect(action.anchor, DialogAnchor.none);
    expect(action.isAnchored, isFalse);
    expect(action.placement, DialogPlacement.belowStart);
    expect(action.anchorGap, 4);
    expect(action.anchorOffset, 0);
    // Defaults stay out of the JSON, so old projects save unchanged.
    expect(action.toJson(), saved);
  });

  test('An anchored dialog action round-trips its placement', () {
    final action = ShowDialogAction(
      destinationId: 'menu',
      anchor: DialogAnchor.trigger,
      placement: DialogPlacement.belowEnd,
      anchorGap: 8,
      anchorOffset: -2,
      barrierColor: ColorRGBA.transparent,
    );
    final Map json = action.toJson();
    expect(json['anchor'], 'trigger');
    expect(json['placement'], 'belowEnd');
    expect(json['anchorGap'], 8);
    expect(json['anchorOffset'], -2);
    final decoded = ActionModel.fromJson(json) as ShowDialogAction;
    expect(decoded, action);
    expect(decoded.isAnchored, isTrue);

    // Only what differs from the defaults is written.
    final Map onlyAnchor = ShowDialogAction(
      destinationId: 'menu',
      anchor: DialogAnchor.trigger,
    ).toJson();
    expect(onlyAnchor.containsKey('placement'), isFalse);
    expect(onlyAnchor.containsKey('anchorGap'), isFalse);
    expect(onlyAnchor.containsKey('anchorOffset'), isFalse);
  });

  test(
    'Unknown anchors and placements from a newer editor read as defaults',
    () {
      final action = ActionModel.fromJson({
        'type': 'showDialog',
        'destinationId': 'menu',
        'anchor': 'cursor',
        'placement': 'diagonal',
      }) as ShowDialogAction;
      expect(action.anchor, DialogAnchor.none);
      expect(action.placement, DialogPlacement.belowStart);
    },
  );

  test('copyWith keeps the anchor and the enabled and blocking flags', () {
    final action = ShowDialogAction(
      destinationId: 'menu',
      anchor: DialogAnchor.trigger,
      placement: DialogPlacement.aboveCenter,
      nonBlocking: true,
      enabled: false,
    );
    final copy = action.copyWith(showCloseButton: true);
    expect(copy.anchor, DialogAnchor.trigger);
    expect(copy.placement, DialogPlacement.aboveCenter);
    expect(copy.nonBlocking, isTrue);
    expect(copy.enabled, isFalse);
    expect(copy.copyWith(anchor: DialogAnchor.none).isAnchored, isFalse);
  });

  test('Placements know their axis', () {
    expect(DialogPlacement.belowStart.isVertical, isTrue);
    expect(DialogPlacement.aboveEnd.isVertical, isTrue);
    expect(DialogPlacement.rightStart.isVertical, isFalse);
    expect(DialogPlacement.leftEnd.isVertical, isFalse);
  });

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
    expect(plain.maxHeightFactor, 1);
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
    // HEAD resets the cap using its explicit default rather than null.
    final reset = capped.copyWith(maxHeightFactor: 1);
    expect(reset.maxHeightFactor, 1);
    expect(reset.toJson().containsKey('maxHeightFactor'), isFalse);
  });
}
