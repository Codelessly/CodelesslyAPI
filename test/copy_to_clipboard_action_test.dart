import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a copy to clipboard action round-trips through JSON', () {
    final CopyToClipboardAction action = CopyToClipboardAction(
      text: r'https://nook.homes/homes/${route.homeId}',
    );
    final ActionModel read = ActionModel.fromJson(action.toJson());
    expect(read, isA<CopyToClipboardAction>());
    expect((read as CopyToClipboardAction).text, action.text);
    expect(read.type, ActionType.copyToClipboard);
  });
}
