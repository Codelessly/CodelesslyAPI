import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';
void main(){
 test('legacy submissions retain their Mailchimp default and JSON shape',(){
  final json={'type':'submitForm','service':'mailchimp','emailField':'email','apiKey':'key','dataCenter':'us1','listId':'list'};
  expect(ActionDef.fromJson(json)!.toJson(),json);
  expect((ActionDef.fromJson({'type':'submitForm'}) as SubmitFormAction).service,FormService.mailchimp);
 });
 test('generic local submissions roundtrip typed payload, validator and callbacks',(){
  final json={'type':'submitForm','service':'local','emailField':'','payload':r'${answers}','validationScript':'validate','validationArguments':{'schema':r'${schema}'},'responseVariable':'responses','prepend':true,'resultVariable':'submitted','onSuccess':[{'type':'setVariable','variable':'done','value':'true'}],'onError':[{'type':'showToast','message':'Invalid'}]};
  final action=ActionDef.fromJson(json) as SubmitFormAction;
  expect(action.toJson(),json);expect(action.nested.length,2);
  final fields=SubmitFormFields.all.map((f)=>f.key);
  expect(fields,containsAll(['payload','validationScript','validationArguments','responseVariable','prepend','resultVariable','onSuccess','onError']));
 });
}
