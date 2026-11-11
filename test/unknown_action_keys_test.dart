import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('unknownActionKeys names keys no field reads, in nested chains too', () {
    final warnings = unknownActionKeys([
      {
        'trigger': {'type': 'click', 'keys': 'Space'},
        'actions': [
          {'type': 'delay', 'durationMs': 700},
          {'type': 'showToast', 'message': 'Hi', 'style': 'error'},
          {
            'type': 'if',
            'condition': {'left': '1', 'op': 'equals', 'right': '1'},
            'then': [{'type': 'setVariable', 'variable': 'x', 'value': '1', 'animateMS': 3}],
          },
        ],
      },
    ]);
    expect(warnings, hasLength(3));
    expect(warnings[0], startsWith('actions[0].trigger has no "keys"'));
    expect(warnings[1], startsWith('actions[0].actions[0]: delay has no "durationMs" (it takes: ms, duration'));
    expect(warnings[2], startsWith('actions[0].actions[2].then[0]: setVariable has no "animateMS"'));
  });

  test('valid reactions have no warnings', () {
    expect(unknownActionKeys([
      {'trigger': {'type': 'keyDown', 'key': 'Space'}, 'actions': [{'type': 'delay', 'ms': 700, 'nonBlocking': true}]},
    ]), isEmpty);
    expect(unknownActionKeys(null), isEmpty);
  });
}
