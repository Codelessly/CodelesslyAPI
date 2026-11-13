import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Keys only the removed built-in newsletter integration wrote.
const _removedKeys = ['apiKey', 'dataCenter', 'listId', 'emailField', 'firstNameField', 'lastNameField'];

void main() {
  group('a submission saved for the removed newsletter services', () {
    final stored = <Json>[
      {'type': 'submitForm', 'service': 'mailchimp', 'emailField': 'email', 'apiKey': 'key-us1', 'dataCenter': 'us1', 'listId': 'list',
       'firstNameField': 'first', 'lastNameField': 'last', 'nonBlocking': true},
      // Before `service` was written, its default was the newsletter.
      {'type': 'submitForm', 'emailField': 'email', 'apiKey': 'key-us1', 'dataCenter': 'us1', 'listId': 'list'},
      {'type': 'submitForm', 'service': 'mailchimp', 'emailField': ''},
      // A service a newer version might add.
      {'type': 'submitForm', 'service': 'someFutureService'},
    ];

    test('decodes, marked unsupported', () {
      for (final json in stored) {
        final a = ActionDef.fromJson(json, catalog: standardCatalog);
        expect(a, isA<SubmitFormAction>(), reason: '$json');
        expect((a! as SubmitFormAction).service, FormService.unsupported, reason: '$json');
      }
      expect(ActionDef.fromJson(stored.first, catalog: standardCatalog)!.nonBlocking, isTrue);
    });

    test('drops the removed fields when saved again and stays unsupported', () {
      for (final json in stored) {
        final out = ActionDef.fromJson(json, catalog: standardCatalog)!.toJson();
        for (final k in _removedKeys) {
          expect(out.containsKey(k), isFalse, reason: '$k in $out');
        }
        expect(out['service'], 'unsupported');
        expect(out.values.whereType<String>(), isNot(contains('key-us1')));
        // Stable: decoding the re-encoded action gives the same action.
        expect(ActionDef.fromJson(out, catalog: standardCatalog), ActionDef.fromJson(json, catalog: standardCatalog));
      }
    });

    test('decodes inside a reaction list and inside callbacks', () {
      final list = ActionDef.listFromJson([
        {'type': 'submitForm', 'service': 'local', 'onError': [stored.first]},
        stored[1],
      ], catalog: standardCatalog);
      expect(list, hasLength(2));
      final nested = (list.first as SubmitFormAction).onError.single as SubmitFormAction;
      expect(nested.service, FormService.unsupported);
      expect(list.first.toJson().toString(), isNot(contains('apiKey')));
    });
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
