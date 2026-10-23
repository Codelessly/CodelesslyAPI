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
  });
}
