import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a computed variable round-trips its formula', () {
    final variable = VariableData(
      id: 'over',
      name: 'over',
      type: VariableType.boolean,
      formula: 'level > limit',
    );
    final back = VariableData.fromJson(variable.toJson());
    expect(back, variable);
    expect(back.isComputed, isTrue);
    expect(variable.withCanvas('c').formula, 'level > limit');
    expect(variable.copyWith(name: 'x').formula, 'level > limit');
  });

  test('a plain variable stores no formula', () {
    final json = VariableData(id: 'a', name: 'a', value: '1').toJson();
    expect(json.containsKey('formula'), isFalse);
    expect(VariableData.fromJson(json).isComputed, isFalse);
  });
}
