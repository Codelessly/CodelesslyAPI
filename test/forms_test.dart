// Forms as data: Flutter's TextFormField.validator, Form, RadioGroup and
// FormState.validate().
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, Object?> _doc(Map<String, Object?> extraNodes, {List<String> children = const ['email']}) => {
      'schema': 3,
      'roots': ['home'],
      'nodes': {
        'home': {'type': 'canvas', 'slots': {'body': 'form'}, 'layout': {'width': 390, 'height': 844}},
        'form': {
          'type': 'column',
          'children': children,
          'layout': {'width': {'fill': 390}, 'height': {'fill': 844}},
          'form': {'autovalidateMode': 'onUnfocus'},
        },
        ...extraNodes,
      },
    };

void main() {
  test('a one-time code is one text field with a slot count and optional digit filter', () {
    final doc = _doc({
      'email': {
        'type': 'textField',
        'layout': {'width': 320, 'height': 56},
        'props': {'otpLength': 6, 'otpDigitsOnly': true, 'decoration': {'labelText': 'Verification code'}},
      },
    });
    final field = LayoutDocument.fromJson(doc)['email']!;
    expect(field.prop(TextFieldProps.otpLength), 6);
    expect(field.prop(TextFieldProps.otpDigitsOnly), isTrue);
    expect(field.toJson()['props'], containsPair('otpLength', 6));
  });

  test('a validator is an expression reading the field\'s text as value', () {
    final doc = _doc({
      'email': {
        'type': 'textField',
        'layout': {'width': {'fill': 390}, 'height': {'hug': 56}},
        'props': {'validator': r"${= value == '' ? 'Enter your email.' : ''}", 'autovalidateMode': 'onUserInteractionIfError'},
      },
    });
    final field = LayoutDocument.fromJson(doc)['email']!;
    expect(field.prop(TextFieldProps.validator), r"${= value == '' ? 'Enter your email.' : ''}");
    expect(field.prop(TextFieldProps.autovalidateMode), AutovalidateMode.onUserInteractionIfError);
  });

  test('a form and a radio group are behaviors that round-trip, and true is the default form', () {
    final doc = LayoutDocument.fromJson(_doc({
      'budget': {
        'type': 'column',
        'layout': {'width': 200, 'height': {'hug': 80}},
        'radioGroup': {'groupValue': 'small'},
        'bind': {'radioGroup.groupValue': r'${budget}'},
      },
    }, children: ['budget'])..['variables'] = {
        'home': [
          {'name': 'budget', 'type': 'text', 'value': 'small'},
        ],
      });
    expect(doc['form']!.behaviors.form, const FormBehavior(autovalidateMode: AutovalidateMode.onUnfocus));
    expect(doc['budget']!.behaviors.radioGroup, const RadioGroupBehavior(groupValue: 'small'));
    expect(doc['form']!.toJson()['form'], {'autovalidateMode': 'onUnfocus'});
    expect(Behaviors.fromJson({'form': true}).form, const FormBehavior());
  });

  test('the validate action names its form', () {
    final doc = _doc({
      'email': {'type': 'textField', 'layout': {'width': 100, 'height': 56}, 'props': {'validator': r"${= value == '' ? 'x' : ''}"}},
      'send': {
        'type': 'filledButton',
        'layout': {'width': 100, 'height': 48},
        'props': {'label': 'Send'},
        'actions': [
          {
            'trigger': {'type': 'click'},
            'actions': [
              {'type': 'validate', 'node': 'form'},
              {'type': 'if', 'condition': {'left': r'${result}', 'op': 'isTrue'}, 'then': [{'type': 'showToast', 'message': 'Sent'}]},
            ],
          },
        ],
      },
      'summary': {
        'type': 'text',
        'layout': {'width': 100, 'height': {'hug': 20}},
        'props': {'text': '', 'style': {'color': '#FF000000'}},
        'bind': {'props.text': r"${= length(form.errors) + ' to fix'}", 'visible': r'${= !form.valid}'},
      },
    }, children: ['email', 'send', 'summary']);
    final send = LayoutDocument.fromJson(doc)['send']!;
    expect(send.actions.single.actions.first, const ValidateAction(node: 'form'));
  });
}
