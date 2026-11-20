// Links in a text (docs/design/26-text-runs-and-links.md): a run's `link`,
// the text's `onLinkTap`, runs made from a pattern's matches, and `??`.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => parseNotation(text, catalog: standardCatalog);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

void main() {
  test('onLinkTap on a text is its linkTap reaction, printed and read back the same', () {
    const text = 'state opened=""\n'
        'Column#page\n'
        '  Text#legal "Read the Terms." runs=[{"start":9,"end":14,"link":"terms","style":{"fontWeight":700}}] onLinkTap={opened=result.link}\n';
    final r = _parse(text);
    expect(r.issues, isEmpty);
    final legal = _node(r, 'legal');
    expect((legal['props'] as Map)['runs'], [
      {'start': 9, 'end': 14, 'style': {'fontWeight': 700}, 'link': 'terms'},
    ]);
    final reaction = (legal['actions'] as List).single as Map;
    expect(reaction['trigger'], {'type': 'linkTap'});
    final printed = printNotation(r.document, catalog: standardCatalog);
    expect(printed, contains('onLinkTap={opened=result.link}'));
    final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(r.document));
    expect(back.issues, isEmpty, reason: printed);
    expect(jsonEncode(back.document), jsonEncode(r.document));
    expect(Trigger.fromJson({'type': 'linkTap'})?.type, TriggerType.linkTap);
  });

  // A pattern's repetition in a formula's text (`\d{3}`) was read as a value
  // in braces: the formula got `"\d" + (3)` and the pattern lost its count.
  test('a count in braces inside a formula\'s text stays in the text', () {
    const text = 'state msg="call 555-0100"\n'
        'Text#t "{msg}" runs={map(regexMatches(msg, "\\d{3}-\\d{2,4}|x{5,}"), m => {start: m.start, end: m.end, link: "tel:" + m.text})}\n';
    final r = _parse(text);
    expect(r.issues, isEmpty);
    final runs = (_node(r, 't')['bind'] as Map)['props.runs'] as String;
    expect(runs, contains(r'"\d{3}-\d{2,4}|x{5,}"'));
    expect(runs, isNot(contains('(3)')));
    // A value read in a text still is one.
    final read = _parse('state n=2\nText#t "{n} left"\n');
    expect(read.issues, isEmpty);
    expect((_node(read, 't')['props'] as Map)['text'], contains(r'${n}'));
  });

  test('a ?? b in a binding is kept for the formula', () {
    final r = _parse('Text#t "{route.entry ?? "start"}"\n');
    expect(r.issues, isEmpty);
    expect(jsonEncode(_node(r, 't')), contains('route.entry ?? '));
  });
}
