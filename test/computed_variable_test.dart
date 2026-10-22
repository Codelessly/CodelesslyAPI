import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a formula value makes a computed variable of any type', () {
    for (final VariableType type in VariableType.values) {
      final VariableData v = VariableData(
        id: 'v',
        name: 'downtime',
        type: type,
        value: r'  ${= sum(events, "minutes")} ',
      );
      expect(v.isComputed, isTrue, reason: type.name);
      expect(v.value, r'${= sum(events, "minutes")}', reason: type.name);
      expect(v.getValue(), isNull, reason: type.name);
    }
  });

  test('plain values and paths are not computed', () {
    expect(
      VariableData(
        id: 'a',
        name: 'a',
        value: 12,
        type: VariableType.integer,
      ).isComputed,
      isFalse,
    );
    expect(
      VariableData(id: 'b', name: 'b', value: r'${other}').isComputed,
      isFalse,
    );
    expect(
      VariableData(id: 'c', name: 'c', value: r'total: ${= 1 + 1}').isComputed,
      isFalse,
    );
  });

  test('a computed variable round-trips through JSON', () {
    final VariableData v = VariableData(
      id: 'v',
      name: 'pareto',
      type: VariableType.list,
      value: r'${= sortBy(rows, "min", "desc")}',
    );
    final VariableData back = VariableData.fromJson(v.toJson());
    expect(back.isComputed, isTrue);
    expect(back, v);
  });
}
