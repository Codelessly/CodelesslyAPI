import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> json(Object? value) => {
    'type': 'setVariable',
    'variable': {'id': 'v', 'name': 'open', 'type': 'boolean'},
    'newValue': value,
  };

  test('JSON values become the text newValue holds', () {
    expect(SetVariableAction.fromJson(json(true)).newValue, 'true');
    expect(SetVariableAction.fromJson(json(20)).newValue, '20');
    expect(SetVariableAction.fromJson(json(['a', 1])).newValue, '["a",1]');
    expect(SetVariableAction.fromJson(json({'a': 1})).newValue, '{"a":1}');
    expect(SetVariableAction.fromJson(json(r'${= x}')).newValue, r'${= x}');
  });
}
