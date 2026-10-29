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
}
