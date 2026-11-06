import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A confirm action's dialog layout fields (width, maxWidth, insets,
/// padding, buttonHeight) read and write JSON, and are left out unset.
void main() {
  test('layout fields round-trip', () {
    final ConfirmAction action =
        ActionModel.fromJson({
              'type': 'confirm',
              'title': 'Take it down?',
              'width': 380,
              'maxWidth': 380,
              'insets': 20,
              'padding': {'l': 24, 't': 26, 'r': 24, 'b': 22},
              'buttonHeight': 48,
              'variables': {'width': r'${= screen.isMobile ? 340 : 380}'},
            })
            as ConfirmAction;
    expect(action.width, 380);
    expect(action.maxWidth, 380);
    expect(action.insets, const EdgeInsetsModel.all(20));
    expect(
      action.padding,
      const EdgeInsetsModel.only(left: 24, top: 26, right: 24, bottom: 22),
    );
    expect(action.buttonHeight, 48);
    final ConfirmAction back = ConfirmAction.fromJson(action.toJson());
    expect(back, action);
    expect(ConfirmAction.bindableSizes, contains('width'));
  });

  test('unset layout fields are left out', () {
    final Map json = ConfirmAction(title: 'Sure?').toJson();
    for (final String key in [
      'width',
      'maxWidth',
      'insets',
      'padding',
      'buttonHeight',
    ]) {
      expect(json.containsKey(key), isFalse, reason: key);
    }
  });
}
