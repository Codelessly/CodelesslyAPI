import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('ConfirmAction reads presentation like ShowDialogAction', () {
    final ConfirmAction action = ConfirmAction.fromJson({
      'type': 'confirm',
      'title': 'Reopen DF-3104?',
      'dialogId': 'reopen',
      'presentation': 'sideSheet',
      'sheetWidth': 440,
      'showDragHandle': true,
    });
    expect(action.presentation, DialogPresentation.sideSheet);
    expect(action.sheetWidth, 440);
    expect(action.showDragHandle, isTrue);
    expect(ConfirmAction.fromJson(action.toJson()), action);
    expect(
      ConfirmAction.fromJson({
        'type': 'confirm',
        'title': 'x',
        'presentation': 'popover',
      }).presentation,
      DialogPresentation.dialog,
    );
    expect(
      ConfirmAction(title: 'x').toJson().keys,
      isNot(contains('sheetWidth')),
    );
  });

  test('ShowToastAction keeps its accent, icon color, font and radius', () {
    final ShowToastAction toast = ShowToastAction(
      message: 'Saved',
      accentColor: ColorRGBA.black,
      iconColor: ColorRGBA.white,
      fontFamily: 'Barlow',
      cornerRadius: 4,
    );
    final ShowToastAction copy = ShowToastAction.fromJson(toast.toJson());
    expect(copy, toast);
    expect(copy.accentWidth, 4);
    expect(
      copy.copyWith(clearAccentColor: true, clearFontFamily: true),
      isA<ShowToastAction>()
          .having((t) => t.accentColor, 'accentColor', isNull)
          .having((t) => t.fontFamily, 'fontFamily', isNull),
    );
  });

  test('a text field can bind errorText and error', () {
    final TextFieldNode field = TextFieldNode(
      id: 'f',
      name: 'f',
      basicBoxLocal: NodeBox(0, 0, 100, 40),
      properties: TextFieldProperties(),
    );
    expect(
      field.propertyVariables.map((value) => value.name),
      containsAll(['errorText', 'error']),
    );
  });

  test('frame contentFit reads from JSON', () {
    final FrameNode frame = FrameNode.fromJson({
      'id': 'f',
      'name': 'f',
      'type': 'frame',
      'basicBoxLocal': [0, 0, 300, 660],
      'children': <String>[],
      'contentFit': 'contain',
    });
    expect(frame.contentFit, Fit.contain);
    expect(frame.contentAlignment, AlignmentModel.center);
  });
}
