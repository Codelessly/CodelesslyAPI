import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('selfAndNestedActions finds API calls at any depth', () {
    final ActionModel load = ConditionalAction(
      expression: Expression(
        leftPart: VariablePart(valueString: r'${= true}'),
        operator: ConditionOperation.isTrue,
        rightPart: RawValuePart(''),
      ),
      actions: [
        ApiCallAction(
          apiId: 'curve',
          onError: [ShowToastAction(message: 'Offline')],
        ),
        ForEachAction(
          items: r'${= range(0, 6)}',
          actions: [
            ApiCallAction(
              apiId: 'sun',
              onSuccess: [ApiCallAction(apiId: 'nested')],
            ),
          ],
        ),
      ],
      elseActions: [ApiCallAction(apiId: 'else')],
    );
    expect(
      load.selfAndNestedActions.whereType<ApiCallAction>().map((a) => a.apiId),
      ['curve', 'sun', 'nested', 'else'],
    );
    expect(load.selfAndNestedActions.first, same(load));
  });

  test('a leaf action has no children', () {
    expect(ApiCallAction(apiId: 'a').childActions, isEmpty);
  });
}
