import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a pop navigation parses without a destination', () {
    final ActionModel action = ActionModel.fromJson({
      'type': 'navigation',
      'navigationType': 'pop',
    });
    expect(action, isA<NavigationAction>());
    final nav = action as NavigationAction;
    expect(nav.navigationType, NavigationType.pop);
    expect(nav.destinationId, '');
    expect(ActionModel.fromJson(nav.toJson()), nav);
  });

  test('a push keeps its destination and params', () {
    final nav = NavigationAction(
      destinationId: 'canvas1',
      params: {'id': r'${item.id}'},
    );
    final json = nav.toJson();
    expect(json['destinationId'], 'canvas1');
    expect(ActionModel.fromJson(json), nav);
  });
}
