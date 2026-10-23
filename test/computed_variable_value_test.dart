import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a formula value survives sanitizing for every type', () {
    const String formula = r"${= find(trips, 'id', selected)}";
    for (final VariableType type in VariableType.values) {
      expect(
        VariableData(id: 'v', name: 'v', type: type, value: formula).value,
        formula,
        reason: type.name,
      );
    }
  });
}
