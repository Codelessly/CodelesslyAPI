import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a formula value is kept as is for every variable type', () {
    const String formula = r"${= filter(units, u => u.status == 'Available')}";
    for (final VariableType type in VariableType.values) {
      expect(
        VariableData(id: 'v', name: 'v', value: formula, type: type).value,
        formula,
        reason: '$type',
      );
    }
    expect(
      VariableData(
        id: 'v',
        name: 'v',
        value: '[]',
        type: VariableType.list,
      ).copyWith(value: r'${= range(3)}').value,
      r'${= range(3)}',
    );
  });

  test('other values are still sanitized by type', () {
    expect(
      VariableData(
        id: 'v',
        name: 'v',
        value: 'abc',
        type: VariableType.integer,
      ).value,
      isNot('abc'),
    );
  });
}
