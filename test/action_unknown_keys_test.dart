// An action key its type doesn't have is reported, so an editor or agent
// can refuse it. Before, `{"type": "confirm", "style": {...}}` (the confirm's
// cosmetics are `look`) and a toast's `style` map (its `style` is the tone)
// were dropped on decode: the dialog showed in the default look and nothing
// said why.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('unknown keys are reported, nested actions included', () {
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

  test('known keys pass, with or without their defaults', () {
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

  test('a type this version doesn\'t know is kept whole', () {
    expect(ActionSpecs.unknownKeys({'type': 'teleport', 'where': 'mars'}), isEmpty);
  });

  test('every action type\'s own JSON round-trips with no unknown keys', () {
    // Whatever an action writes, it can read back: the spec lists it.
    for (final spec in ActionSpecs.all) {
      final a = ActionDef.fromJson({'type': spec.type});
      expect(ActionSpecs.unknownKeys(a?.toJson()), isEmpty, reason: spec.type);
    }
  });
}
