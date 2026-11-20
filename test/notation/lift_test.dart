// A lifted shared element (`hero.flies=lift`) and the keys of a long press
// that starts one (`holdMs`, `commitMs`, `haptic` in its parentheses):
// written, expanded, printed and read back as the same lines
// (docs/design/25-lifted-elements.md).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => parseNotation(text, catalog: standardCatalog);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

void main() {
  const text = 'state pressedId=0\n'
      'Column\n'
      '  Column#bubble pad=16 radius=12 fill=#FFF1F5F9 hero.tag="m7" hero.flies=lift hero.flight.duration=335 '
      'hero.flight.curve=easeOut onLongPress(holdMs=800, commitMs=400, haptic=heavy)={pressedId=7}\n'
      '    Text "Great work."\n';

  test('the bubble\'s two lines expand to a lifted hero and a long press with its own hold, commit point and buzz', () {
    final r = _parse(text);
    expect(r.issues, isEmpty);
    final bubble = _node(r, 'bubble');
    expect(bubble['hero'], {
      'tag': 'm7',
      'flies': 'lift',
      'flight': {'duration': 335, 'curve': 'easeOut'},
    });
    final trigger = ((bubble['actions']! as List).single as Map)['trigger'];
    expect(trigger, {'type': 'longPress', 'holdMs': 800, 'commitMs': 400, 'haptic': 'heavy'});

    final node = Node.fromJson(bubble.cast<String, Object?>())!;
    expect(node.behaviors.hero!.flies, HeroFlies.lift);
    final t = node.actions.single.trigger;
    expect(t.holdMs, 800);
    expect(t.commitMs, 400);
    expect(t.haptic, HapticKind.heavy);
  });

  test('printed and read back unchanged', () {
    final r = _parse(text);
    final printed = printNotation(r.document, catalog: standardCatalog);
    expect(printed, contains('hero.flies=lift'));
    expect(printed, contains('commitMs=400'));
    expect(printed, contains('haptic=heavy'));
    expect(printed, isNot(contains(' {"')), reason: printed);
    final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(r.document));
    expect(back.issues, isEmpty, reason: printed);
    expect(jsonDecode(jsonEncode(back.document)), jsonDecode(jsonEncode(r.document)));
  });

  test('a hero whose tag is bound keeps how it flies (the record has no tag)', () {
    final r = _parse('Column\n  each m in [{"id":1}]\n    Column#b hero.tag="m{m.id}" hero.flies=lift hero.flight.duration=335\n');
    expect(r.issues, isEmpty);
    final b = _node(r, 'b');
    expect(b['hero'], {'flies': 'lift', 'flight': {'duration': 335}});
    final hero = HeroTag.fromJson(b['hero'])!;
    expect(hero.tag, '');
    expect(hero.flies, HeroFlies.lift);
    expect(hero.toJson(), {'flies': 'lift', 'flight': {'duration': 335}});
    expect(HeroTag.fromJson(const <String, Object?>{}), isNull);
    expect(HeroTag.fromJson('avatar')!.toJson(), 'avatar');
  });

  test('a trigger without them writes none; an unknown haptic reads as none', () {
    expect(const Trigger(TriggerType.longPress).toJson(), {'type': 'longPress'});
    final t = Trigger.fromJson({'type': 'hold', 'commitMs': -5, 'haptic': 'thud'})!;
    expect(t.commitMs, 0);
    expect(t.haptic, isNull);
  });
}
