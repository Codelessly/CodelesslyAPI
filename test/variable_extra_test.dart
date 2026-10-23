import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('withCanvas keeps extra (a computed variable keeps its formula)', () {
    final VariableData variable = VariableData(
      id: 'shown',
      name: 'shown',
      type: VariableType.list,
      extra: {'formula': r'${= filter(homes, h => h.published)}'},
    );
    final CanvasVariableData saved = variable.withCanvas('app');
    expect(saved.extra, variable.extra);
    expect(
      saved.toJson()['extra'],
      {'formula': r'${= filter(homes, h => h.published)}'},
    );
  });

  test('a variable with a new formula is a different variable', () {
    VariableData withFormula(String formula) => VariableData(
      id: 'shown',
      name: 'shown',
      type: VariableType.list,
      extra: {'formula': formula},
    );
    expect(withFormula(r'${= homes}'), withFormula(r'${= homes}'));
    expect(withFormula(r'${= homes}'), isNot(withFormula(r'${= []}')));
  });
}
