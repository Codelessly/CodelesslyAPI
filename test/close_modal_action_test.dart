import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('closeModal is a distinct parameterless action', () {
    final action = CloseModalAction();
    expect(action.type, ActionType.closeModal);
    expect(action.toJson(), {'type': 'closeModal'});
    final decoded = ActionModel.fromJson(action.toJson());
    expect(decoded, isA<CloseModalAction>());
    expect(decoded, isNot(isA<ShowDialogAction>()));
    expect(decoded.toJson(), action.toJson());
    expect(ActionType.closeModal.prettify, 'Close Modal');
  });

  test('closeModal rejects parameters and wrong discriminators', () {
    for (final json in [
      {'type': 'closeModal', 'destinationId': 'dialog'},
      {'type': 'closeModal', 'params': <String, dynamic>{}},
      {'type': 'closeModal', 'enabled': false},
      {'type': 'showDialog'},
    ]) {
      expect(() => CloseModalAction.fromJson(json), throwsFormatException);
    }
    expect(
      () => ActionModel.fromJson({'type': 'closeModal', 'params': {}}),
      throwsFormatException,
    );
  });
}
