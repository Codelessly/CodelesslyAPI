import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> navigationBar([
    Map<String, dynamic> fields = const {},
  ]) => {
    'id': 'navigation',
    'name': 'Navigation',
    'type': 'navigationBar',
    'basicBoxLocal': {'x': 0, 'y': 0, 'width': 200, 'height': 80},
    'properties': {'styleDefinition': 'material_3', 'items': []},
    ...fields,
  };

  test('selectedIndex is the only navigation selection wire field', () {
    final parsed = NavigationBarNode.fromJson(
      navigationBar({'selectedIndex': 2}),
    );
    expect(parsed.selectedIndex, 2);
    final output = parsed.toJson();
    expect(output['selectedIndex'], 2);
    expect(output.containsKey('currentIndex'), isFalse);
  });

  test('old currentIndex no longer changes selectedIndex', () {
    final parsed = NavigationBarNode.fromJson(
      navigationBar({'currentIndex': 2}),
    );
    expect(parsed.selectedIndex, 0);
    expect(parsed.toJson().containsKey('currentIndex'), isFalse);
  });
}
