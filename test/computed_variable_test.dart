import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a variable whose value is a formula is computed', () {
    final VariableData computed = VariableData(
      id: 'v',
      name: 'visible',
      type: VariableType.list,
      value: r'${= filter(records, r => r.crate == crateId)}',
    );
    expect(computed.isComputed, isTrue);
    expect(computed.value, r'${= filter(records, r => r.crate == crateId)}');
    expect(
      VariableData(id: 'w', name: 'plain', value: 'jazz').isComputed,
      isFalse,
    );
  });

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

  test('a formula stored in its own field is read into the value', () {
    final VariableData variable = VariableData.fromJson(<String, dynamic>{
      'id': 'v',
      'name': 'frontRec',
      'type': 'map',
      'formula': r'${= visibleRecords[front]}',
    });
    expect(variable.value, r'${= visibleRecords[front]}');
    expect(variable.isComputed, isTrue);
    expect(variable.toJson().containsKey('formula'), isFalse);

    final CanvasVariableData canvasVariable = CanvasVariableData.fromJson(
      <String, dynamic>{
        'id': 'v',
        'canvasId': 'c',
        'name': 'count',
        'type': 'integer',
        'formula': r'${= length(records)}',
      },
    );
    expect(canvasVariable.value, r'${= length(records)}');
    expect(canvasVariable.isComputed, isTrue);
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
