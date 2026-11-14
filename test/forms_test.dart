// Forms as data: Flutter's TextFormField.validator, Form, RadioGroup and
// FormState.validate().
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
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
  test('a validator is an expression reading the field\'s text as value, and validates', () {
    final doc = _doc({
      'email': {
        'type': 'textField',
        'layout': {'width': {'fill': 390}, 'height': {'hug': 56}},
        'props': {'validator': r"${= value == '' ? 'Enter your email.' : ''}", 'autovalidateMode': 'onUserInteractionIfError'},
      },
    });
    expect(validateDocument(doc), isEmpty);
    final field = LayoutDocument.fromJson(doc)['email']!;
    expect(field.prop(TextFieldProps.validator), r"${= value == '' ? 'Enter your email.' : ''}");
    expect(field.prop(TextFieldProps.autovalidateMode), AutovalidateMode.onUserInteractionIfError);
  });

  test('a validator that reads an unknown name is reported, value is not', () {
    final doc = _doc({
      'email': {
        'type': 'textField',
        'layout': {'width': {'fill': 390}, 'height': {'hug': 56}},
        'props': {'validator': r'${vaule}'},
      },
    });
    final found = validateDocument(doc).where((d) => d.code == Codes.unknownName).toList();
    expect(found.map((d) => d.path), ['/nodes/email/props/validator']);
    expect(found.single.suggestion, 'value');
  });

  test('an older document\'s validator object reads as the expression it named', () {
    Node field(Object validator) => LayoutDocument.fromJson(_doc({
          'email': {'type': 'textField', 'layout': {'width': 100, 'height': 56}, 'props': {'validator': validator}},
        }))['email']!;
    expect(field({'type': 'required'}).prop(TextFieldProps.validator), r"${= trim(value) == '' ? 'Required.' : ''}");
    expect(field({'type': 'email', 'message': 'Use your work email'}).prop(TextFieldProps.validator), contains('matches(value'));
    expect(field({'type': 'none'}).prop(TextFieldProps.validator), '');
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
    expect(validateDocument(doc.toJson()), isEmpty);
  });

  test('the validate action names its form, and reading form inside one is valid', () {
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
    expect(validateDocument(doc), isEmpty);
    final send = LayoutDocument.fromJson(doc)['send']!;
    expect(send.actions.single.actions.first, const ValidateAction(node: 'form'));
  });
}
