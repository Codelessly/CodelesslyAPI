import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('withCanvas keeps extra', () {
    final VariableData variable = VariableData(
      id: 'shown',
      name: 'shown',
      type: VariableType.list,
      extra: {'note': 'published homes'},
    );
    final CanvasVariableData saved = variable.withCanvas('app');
    expect(saved.extra, variable.extra);
    expect(saved.toJson()['extra'], {'note': 'published homes'});
  });

  test('a variable with a different extra is a different variable', () {
    VariableData withNote(String note) => VariableData(
      id: 'shown',
      name: 'shown',
      type: VariableType.list,
      extra: {'note': note},
    );
    expect(withNote('a'), withNote('a'));
    expect(withNote('a'), isNot(withNote('b')));
  });
}
