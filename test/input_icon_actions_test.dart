// A text field's suffix icon with a tap action (the documented shape: its
// `actions` a list of reactions) validates; a list of bare actions is told
// apart from a reaction.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

void main() {
  Json doc(Object? actions) => {
        'schema': 3,
        'roots': ['c'],
        'nodes': {
          'c': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'search'}},
          'search': {
            'type': 'textField',
            'layout': {'width': {'fill': 390}, 'height': 48},
            'props': {
              'decoration': {
                'hintText': 'Search',
                'suffixIcon': {'icon': 'close', 'size': 18, 'actions': actions},
              },
            },
          },
        },
        'variables': {
          'c': [
            {'name': 'query', 'type': 'text', 'value': ''},
          ],
        },
      };

  test('a clear-field "×": a reaction list validates', () {
    expect(validateDocument(doc([
      {'trigger': {'type': 'click'}, 'actions': [{'type': 'setVariable', 'variable': 'query', 'value': ''}]},
    ])), isEmpty);
  });

  test('a bare action is told to be wrapped in a reaction', () {
    final d = validateDocument(doc([{'type': 'setVariable', 'variable': 'query', 'value': ''}]));
    expect(d.map((x) => '${x.code.name} ${x.path}'), ['invalid_reaction /nodes/search/props/decoration/suffixIcon/actions/0']);
    expect(d.single.message, contains('This is an action, not a reaction'));
  });
}
