import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a reset navigation round-trips with its base screen', () {
    final NavigationAction action = NavigationAction(
      navigationType: NavigationType.reset,
      destinationId: 'trip',
      params: {'tripId': r'${data.id}'},
      baseDestinationId: 'trips',
      baseParams: {'tab': 'upcoming'},
    );
    final Map json = action.toJson();
    expect(json['navigationType'], 'reset');
    expect(json['baseDestinationId'], 'trips');
    final ActionModel back = ActionModel.fromJson(json);
    expect(back, isA<NavigationAction>());
    expect(back, action);
    expect((back as NavigationAction).baseParams, {'tab': 'upcoming'});
    expect(NavigationType.reset.prettify, 'Clear history and navigate');
  });

  test('a navigation without a base screen writes no base keys', () {
    final Map json = NavigationAction(destinationId: 'home').toJson();
    expect(json.containsKey('baseDestinationId'), isFalse);
    expect(json.containsKey('baseParams'), isFalse);
    expect(json.containsKey('navigationType'), isFalse);
    final NavigationAction reset = NavigationAction.fromJson({
      'type': 'navigation',
      'navigationType': 'reset',
      'destinationId': 'home',
    });
    expect(reset.navigationType, NavigationType.reset);
    expect(reset.baseDestinationId, isNull);
  });
}
