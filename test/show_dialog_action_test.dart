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
    expect(action.maxHeightFactor, 0.92);
    expect(action.showDragHandle, isTrue);
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
      'showDragHandle': false,
    };
    final action = ActionModel.fromJson(json) as ShowDialogAction;
    expect(action.presentation, DialogPresentation.bottomSheet);
    expect(action.maxHeightFactor, 0.8);
    expect(action.showDragHandle, isFalse);
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
      'presentation': 'popover',
    }) as ShowDialogAction;
    expect(action.presentation, DialogPresentation.dialog);
    expect(DialogPresentation.bottomSheet.prettify, 'Bottom Sheet');
  });
}
