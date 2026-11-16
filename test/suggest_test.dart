// "Did you mean": the name an author meant (lib/src/core/suggest.dart).
import 'package:codelessly_api/src/core/suggest.dart';
import 'package:codelessly_api/src/core/triggers.dart' show TriggerType;
import 'package:test/test.dart';

void main() {
  final triggers = [for (final t in TriggerType.values) t.name];

  group('triggers written as other frameworks write them', () {
    for (final (written, meant) in [
      ('tap', 'click'), ('onTap', 'click'), ('onClick', 'click'), ('onPressed', 'click'), ('press', 'click'),
      ('dblclick', 'doubleTap'), ('rightClick', 'secondaryClick'), ('mouseenter', 'cursorEnter'),
      ('mouseLeave', 'cursorExit'), ('onChange', 'changed'), ('onChanged', 'changed'), ('submit', 'submitted'),
      ('blur', 'focusLost'), ('onFocus', 'focusGained'), ('initState', 'load'), ('onLoad', 'load'),
    ]) {
      test('$written -> $meant', () => expect(didYouMean(written, triggers), meant));
    }
  });

  test('misspellings, swapped letters and case', () {
    expect(didYouMean('clikc', triggers), 'click');
    expect(didYouMean('dubleTap', triggers), 'doubleTap');
    expect(didYouMean('LONG_PRESS', triggers), 'longPress');
    expect(didYouMean('long-press', triggers), 'longPress');
    expect(didYouMean('focusgained', triggers), 'focusGained');
  });

  test('the same words in another order', () {
    expect(didYouMean('tapDouble', triggers), 'doubleTap');
    expect(didYouMean('enterCursor', triggers), 'cursorEnter');
  });

  test('a word of a longer name', () {
    expect(didYouMean('color', ['backgroundColor', 'radius']), 'backgroundColor');
    expect(didYouMean('mainAlignment', ['mainAxisAlignment', 'crossAxisAlignment']), 'mainAxisAlignment');
  });

  test('a meaning is suggested only when it is a candidate', () {
    expect(didYouMean('onPressed', ['layout', 'props', 'actions']), 'actions');
    expect(didYouMean('Container', ['row', 'column', 'box']), 'box');
    expect(didYouMean('table', ['tabs', 'tableView', 'text']), 'tableView');
    expect(didYouMean('setState', ['navigate', 'setVariable']), 'setVariable');
    expect(didYouMean('push', ['add', 'remove']), 'add');
    expect(didYouMean('push', ['navigate', 'openLink']), 'navigate');
  });

  test('nothing close: no suggestion', () {
    expect(didYouMean('zebra', triggers), isNull);
    expect(didYouMean('xy', ['width', 'height']), isNull);
    expect(didYouMean('', triggers), isNull);
  });

  test('damerau and jaro-winkler', () {
    expect(damerau('click', 'clikc'), 1);
    expect(damerau('kitten', 'sitting'), 3);
    expect(damerau('', 'abc'), 3);
    expect(jaroWinkler('martha', 'marhta'), closeTo(0.961, 0.001));
    expect(jaroWinkler('abc', 'abc'), 1);
    expect(jaroWinkler('abc', 'xyz'), 0);
  });
}
