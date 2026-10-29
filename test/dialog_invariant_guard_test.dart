import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'legacy modal placements reject conflicting presentations and anchors',
    () {
      expect(
        () => ShowDialogAction(
          destinationId: 'x',
          presentation: DialogPresentation.sideSheet,
          placement: DialogPlacement.bottomSheet,
        ),
        throwsArgumentError,
      );
      expect(
        () => ShowDialogAction(
          destinationId: 'x',
          presentation: DialogPresentation.popover,
          placement: DialogPlacement.center,
        ),
        throwsArgumentError,
      );
      expect(
        () => ShowDialogAction(
          destinationId: 'x',
          anchor: DialogAnchor.trigger,
          placement: DialogPlacement.center,
        ),
        throwsArgumentError,
      );
      expect(
        () => ShowDialogAction(
          destinationId: 'x',
          presentation: DialogPresentation.bottomSheet,
          placement: DialogPlacement.adaptive,
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'copyWith cannot carry a contradictory legacy placement into a mode',
    () {
      final sheet = ShowDialogAction(
        destinationId: 'x',
        placement: DialogPlacement.bottomSheet,
      );
      expect(
        () => sheet.copyWith(presentation: DialogPresentation.sideSheet),
        throwsArgumentError,
      );
      expect(
        () => sheet.copyWith(anchor: DialogAnchor.trigger),
        throwsArgumentError,
      );
      expect(
        () => ShowDialogAction(destinationId: 'x').copyWith(
          presentation: DialogPresentation.popover,
          placement: DialogPlacement.center,
        ),
        throwsArgumentError,
      );
    },
  );

  test('legacy default dialog placement still serializes as its PR42 mode', () {
    for (final (placement, mode) in [
      (DialogPlacement.center, 'dialog'),
      (DialogPlacement.bottomSheet, 'bottomSheet'),
      (DialogPlacement.adaptive, 'adaptive'),
      (DialogPlacement.anchored, 'dialog'),
    ]) {
      final action = ShowDialogAction(destinationId: 'x', placement: placement);
      final json = action.toJson();
      expect(json['presentation'] ?? 'dialog', mode);
      expect(json.containsKey('placement'), isFalse);
      expect(
        (ActionModel.fromJson(json) as ShowDialogAction).presentation.name,
        mode,
      );
    }
    final legacyWire = ShowDialogAction.fromJson({
      'type': 'showDialog',
      'destinationId': 'x',
      'placement': 'bottomSheet',
      'presentation': 'dialog',
    });
    expect(legacyWire.presentation, DialogPresentation.bottomSheet);
    expect(legacyWire.toJson()['presentation'], 'bottomSheet');

    final explicitLegacy = ShowDialogAction(
      destinationId: 'x',
      placement: DialogPlacement.bottomSheet,
      presentation: DialogPresentation.bottomSheet,
    );
    expect(explicitLegacy.toJson()['presentation'], 'bottomSheet');
    expect(
      ShowDialogAction(
        destinationId: 'x',
        placement: DialogPlacement.anchored,
        presentation: DialogPresentation.popover,
      ).toJson()['presentation'],
      'popover',
    );
  });

  test(
    'trigger-relative positions and popovers retain their serialization',
    () {
      final anchored = ShowDialogAction(
        destinationId: 'x',
        anchor: DialogAnchor.trigger,
        placement: DialogPlacement.aboveEnd,
      );
      expect(anchored.toJson()['placement'], 'aboveEnd');
      expect(ActionModel.fromJson(anchored.toJson()), anchored);

      final popover = ShowDialogAction(
        destinationId: 'x',
        presentation: DialogPresentation.popover,
        anchor: DialogAnchor.trigger,
        placement: DialogPlacement.rightStart,
      );
      expect(popover.toJson()['placement'], 'rightStart');
      expect(ActionModel.fromJson(popover.toJson()), popover);
    },
  );

  test('wire legacy contradictions remain format errors', () {
    for (final json in [
      {'placement': 'bottomSheet', 'presentation': 'sideSheet'},
      {'placement': 'center', 'anchor': 'trigger', 'presentation': 'dialog'},
      {'placement': 'center', 'presentation': 'popover'},
    ]) {
      expect(
        () => ShowDialogAction.fromJson({
          'type': 'showDialog',
          'destinationId': 'x',
          ...json,
        }),
        throwsFormatException,
      );
    }
  });
}
