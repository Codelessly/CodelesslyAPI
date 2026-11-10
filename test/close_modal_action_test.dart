import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('closeModal is a distinct action', () {
    final action = CloseModalAction();
    expect(action.type, ActionType.closeModal);
    expect(action.toJson(), {'type': 'closeModal'});
    final decoded = ActionModel.fromJson(action.toJson());
    expect(decoded, isA<CloseModalAction>());
    expect(decoded, isNot(isA<ShowDialogAction>()));
    expect(decoded.toJson(), action.toJson());
    expect(ActionType.closeModal.prettify, 'Close Modal');
  });

  test('closeModal carries result params back to the opener', () {
    final decoded = ActionModel.fromJson({
      'type': 'closeModal',
      'params': {'passed': true, 'answer': r'${answer}'},
    });
    expect(decoded, isA<CloseModalAction>());
    expect((decoded as CloseModalAction).params, {
      'passed': true,
      'answer': r'${answer}',
    });
    expect(decoded.toJson(), {
      'type': 'closeModal',
      'params': {'passed': true, 'answer': r'${answer}'},
    });
    // Empty params write the bare form.
    expect(
      ActionModel.fromJson({'type': 'closeModal', 'params': {}}).toJson(),
      {'type': 'closeModal'},
    );
  });

  test('closeModal rejects unknown fields and wrong discriminators', () {
    for (final json in [
      {'type': 'closeModal', 'destinationId': 'dialog'},
      {'type': 'closeModal', 'params': 'x'},
      {'type': 'closeModal', 'enabled': false},
      {'type': 'showDialog'},
    ]) {
      expect(() => CloseModalAction.fromJson(json), throwsFormatException);
    }
  });
}
