import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a service this version does not run decodes, marked unsupported, and stays so when saved again', () {
    final json = {'type': 'submitForm', 'service': 'someFutureService'};
    final a = ActionDef.fromJson(json, catalog: standardCatalog);
    expect(a, isA<SubmitFormAction>());
    expect((a! as SubmitFormAction).service, FormService.unsupported);
    final out = a.toJson();
    expect(out['service'], 'unsupported');
    expect(ActionDef.fromJson(out, catalog: standardCatalog), a);
  });

  test('a new submission stores locally', () {
    expect((ActionDef.fromJson({'type': 'submitForm'}, catalog: standardCatalog)! as SubmitFormAction).service, FormService.local);
    expect(const SubmitFormAction().service, FormService.local);
    expect(SubmitFormFields.service.defaultValue, FormService.local);
    final offered = (SubmitFormFields.service.codec as EnumCodec<FormService>).values;
    expect(offered, [FormService.local]);
  });

  test('a local submission round-trips its payload, validator and callbacks', () {
    final json = {
      'type': 'submitForm', 'service': 'local', 'payload': r'${answers}', 'validationScript': 'validate',
      'validationArguments': {'schema': r'${schema}'}, 'responseVariable': 'responses', 'prepend': true, 'resultVariable': 'submitted',
      'onSuccess': [{'type': 'setVariable', 'variable': 'done', 'value': 'true'}],
      'onError': [{'type': 'showToast', 'message': 'Invalid'}],
    };
    final action = ActionDef.fromJson(json, catalog: standardCatalog)! as SubmitFormAction;
    expect(action.toJson(), json);
    expect(action.nested.length, 2);
    final fields = SubmitFormFields.all.map((f) => f.key);
    expect(fields, containsAll(['payload', 'validationScript', 'validationArguments', 'responseVariable', 'prepend', 'resultVariable', 'onSuccess', 'onError']));
  });

}
