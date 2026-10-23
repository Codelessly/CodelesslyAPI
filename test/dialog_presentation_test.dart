import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a dialog action keeps its presentation through JSON', () {
    for (final DialogPresentation presentation in DialogPresentation.values) {
      final ShowDialogAction action = ShowDialogAction(
        destinationId: 'sheet',
        presentation: presentation,
      );
      final ShowDialogAction read =
          ActionModel.fromJson(action.toJson()) as ShowDialogAction;
      expect(read.presentation, presentation);
    }
  });

  test('actions written before presentations existed open as dialogs', () {
    final ShowDialogAction read = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'old',
    }) as ShowDialogAction;
    expect(read.presentation, DialogPresentation.dialog);
    expect(read.toJson().containsKey('presentation'), isFalse);
  });
}
