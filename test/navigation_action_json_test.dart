import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a pop needs no destination', () {
    final action = NavigationAction.fromJson({
      'type': 'navigation',
      'navigationType': 'pop',
    });
    expect(action.navigationType, NavigationType.pop);
    expect(action.destinationId, '');
    // Still written out, for SDKs that require it.
    expect(action.toJson()['destinationId'], '');
  });
}
