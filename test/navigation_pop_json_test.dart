import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a navigate back action reads without a destination', () {
    final action = NavigationAction.fromJson({
      'type': 'navigation',
      'navigationType': 'pop',
    });
    expect(action.navigationType, NavigationType.pop);
    expect(action.destinationId, '');
    // Still written, for readers that require it.
    expect(action.toJson()['destinationId'], '');
  });
}
