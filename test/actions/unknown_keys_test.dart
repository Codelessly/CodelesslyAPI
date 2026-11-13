import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

// An action key its type doesn't have is reported, so an editor or agent
// can refuse it. Before, `{"type": "confirm", "style": {...}}` (the confirm's
// cosmetics are `look`) and a toast's `style` map (its `style` is the tone)
// were dropped on decode: the dialog showed in the default look and nothing
// said why.

void main() {
  test('a key an action does not have is reported, in nested actions too', () {
    expect(ActionSpecs.unknownKeys({
      'type': 'confirm',
      'title': 'Wash the slide?',
      'style': {'radius': 18},
      'actions': [
        {'type': 'runScript', 'script': 'clearBoard'},
        {'type': 'showToast', 'message': 'Washed', 'colour': '#FF000000'},
      ],
    }), ['style', 'actions[1].colour']);
  });

  test('an action\'s own keys are not reported', () {
    expect(ActionSpecs.unknownKeys({
      'type': 'confirm',
      'title': 'Wash the slide?',
      'presentation': 'dialog',
      'look': {'radius': 18},
      'destructive': true,
      'when': {'left': r'${pop}', 'op': 'greaterThan', 'right': '0'},
      'enabled': true,
    }), isEmpty);
    expect(ActionSpecs.unknownKeys({'type': 'showToast', 'message': 'Saved', 'style': 'success', 'look': {'radius': 12}}), isEmpty);
    expect(ActionSpecs.unknownKeys({'type': 'openModal', 'to': 'c1', 'params': {'a': '1'}, 'barrierColor': '#99000000'}), isEmpty);
  });

  test('an action type this version does not know is not reported', () {
    expect(ActionSpecs.unknownKeys({'type': 'teleport', 'where': 'mars'}), isEmpty);
  });

  test('no action reports a key it writes itself', () {
    // Whatever an action writes, it can read back: the spec lists it.
    for (final spec in ActionSpecs.all) {
      final a = ActionDef.fromJson({'type': spec.type});
      expect(ActionSpecs.unknownKeys(a?.toJson()), isEmpty, reason: spec.type);
    }
  });

  group('in a node\'s reactions', () {
    test('a misspelt trigger or action key is named with where it is and what the action takes', () {
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
  });
}
