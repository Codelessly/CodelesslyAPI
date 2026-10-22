import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a choice variable holds an option value and labels it', () {
    final VariableData state = VariableData(
      id: 's',
      name: 'cardState',
      type: VariableType.choice,
      value: 'v2',
      extra: {
        VariableData.optionsKey: [
          {'value': 'default', 'label': 'Default'},
          {'value': 'v2', 'label': 'Selected'},
          'Plain',
        ],
      },
    );
    expect(state.getValue(), 'v2');
    expect(state.choiceLabel, 'Selected');
    expect(state.choiceOptions.last, (value: 'Plain', label: 'Plain'));
    expect(VariableData.fromJson(state.toJson()), state);
    expect(VariableType.choice.label, 'Choice');
  });

  test('an SDK that predates choice reads it as text', () {
    final VariableData read = VariableData.fromJson({
      'id': 'x',
      'name': 'x',
      'type': 'somethingNew',
      'value': 'a',
    });
    expect(read.type, VariableType.text);
  });
}
