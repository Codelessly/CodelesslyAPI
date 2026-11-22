// Round 16 (30 briefs through the Playground's assistant): what a model
// looked up before its first write is in the prompt, and two issues say
// what to write instead.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/prompt.dart' show notationComputedRule, notationLookedUpLines;
import 'package:test/test.dart';

NotationResult _page(String text) => parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 1440));

String _prompt(double width) => notationPrompt(catalog: standardCatalog, options: NotationOptions(width: width));

List<Map> _variables(NotationResult r) => [
      for (final scope in (r.document['variables'] as Map? ?? const {}).values)
        for (final v in scope as List) v as Map,
    ];

void main() {
  group('a computed value', () {
    test('the page prompt says it by that name, once; a card\'s has no room, the open prompts say it at both', () {
      final page = _prompt(1440);
      expect(page, contains('- state name=value on its own line (top level) declares a variable with a starting value. $notationComputedRule\n'));
      expect('computed'.allMatches(page).length, 1);
      expect('state total={price*qty}'.allMatches(page).length, 1);
      expect(_prompt(390), isNot(contains('computed')));
      expect(notationComputedRule, allOf(contains('computed'), contains('derived'), contains('state left={income-spent}')));
      expect(notationComputedRule.length, lessThan(520));
      // The open page prompt has the taught line as it is, not a second
      // one; the open card prompt says it in short, as it did.
      final open = notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 1440), open: true);
      expect(notationComputedRule.allMatches(open).length, 1);
      expect('state total={price*qty}'.allMatches(open).length, 1);
      final card = notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 390), open: true);
      expect('state total={price*qty}'.allMatches(card).length, 1);
    });

    test('its examples expand with no issue, and each is worked out', () {
      final examples = RegExp(r'state [a-z]+(?:\([a-z]\))?(?::[a-z]+)?=\{[^}]*\}').allMatches(notationComputedRule).map((m) => m[0]!).toList();
      expect(examples, hasLength(4));
      final r = _page('''
state price=2
state qty=3
state income=10
state spent=4
state cart=[{"price":2},{"price":5}]
state kind="All"
state cards=[{"kind":"A"}]
${examples.join('\n')}
Column
  Text#a "{total} {left} {due}"
  each c in filter(cards,c=>fits(c))
    Text "{c.kind}"
''');
      expect(r.issues, isEmpty);
      final text = jsonEncode((r.document['nodes'] as Map)['a']);
      expect(text, allOf(contains('price'), contains('income'), contains('sum(cart')));
      // No braces: a text, which is why the rule says "always the braces".
      final bare = _page('state income=10\nstate spent=4\nstate left=income-spent\nText "{left}"');
      expect(_variables(bare).firstWhere((v) => v['name'] == 'left')['value'], 'income-spent');
    });
  });

  group('what was looked up before the first write', () {
    test('is said on a page, a line each, and not on a card', () {
      final page = _prompt(1440), card = _prompt(390);
      for (final line in notationLookedUpLines) {
        expect(page, contains('\n    $line\n'));
        expect(card, isNot(contains(line.substring(0, 30))));
        expect(line.length, lessThan(560));
      }
      // The words a model searched with are in them.
      for (final word in ['Stack', 'ArrowLeft', 'result.shift', 'onScroll', 'result.fraction', 'onDrag', 'result.dx', 'setThemeMode', 'gradient', 'fontFamily', 'screen.width', 'customPaint']) {
        expect(notationLookedUpLines.join('\n'), contains(word));
      }
    });

    test('each of them expands with no issue', () {
      String head(String word) => notationLookedUpLines.firstWhere((l) => l.contains(word)).split(': ').first;
      final shapes = RegExp(r'(rect rect=\S+ fill=\S+), (circle c=\S+ radius=\d+ fill=\S+), (path d="[^"]+" fill=\S+), (line p1=\S+ p2=\S+ stroke=\S+ strokeWidth=\d)')
          .firstMatch(notationLookedUpLines.last)!;
      final r = _page('''
state hour=2
state editing=false
state day=1
state picked=[]
state rows=[{"id":1}]
state read=0
state x=0
state y=0
${head('key ArrowLeft')}
key PageDown onPress={day=day+7}
key shift+ArrowDown onPress={day=day+1}
Column
  Stack h=240
    ${head('Box x=24')} fill=#FF2563EB
    Text "Corner" x={"end":8} y=8
  each r in rows
    ${head('result.shift')}
      Text "{r.id} {result.meta} {result.alt}"
  ${head('onScroll')}
    Text "{read}"
  ${head('onDrag')} w=40 h=40
  ${head('setThemeMode')}
  Button "Light" onTap={setThemeMode light}
  Text "{theme.isDark}"
  ${head('gradient')}
  Text "…" fontFamily="Georgia" italic
  Text "12" tabularFigures=true
  if screen.width < 700
    Text "narrow"
  Box w=240 h=160
    ${head('customPaint')}
      ${shapes[1]}
      ${shapes[2]}
      ${shapes[3]}
      ${shapes[4]}
''');
      expect(r.issues.map((i) => '${i.line}: ${i.message}'), isEmpty);
    });
  });

  group('animate= written as a formula', () {
    test('says what to write instead: the line under if and else', () {
      for (final written in ['animate={still ? "" : "pulse"}', "animate={still ? 'none' : 'pulse'}"]) {
        final r = _page('state still=false\nText "A" $written');
        expect(r.issues.single.message, startsWith('animate= takes one name, not a formula: the motion was left out. For a motion only while a condition holds, write the line twice: '
            'under if <condition> with animate=pulse, and under else without it. Names: fade, '));
      }
      // What it says to write is read.
      final r = _page('state still=false\nColumn\n  if still\n    Text "A"\n  else\n    Text#b "A" animate=pulse');
      expect(r.issues, isEmpty);
      expect(jsonEncode((r.document['nodes'] as Map)['b']), contains('animations'));
      // A name the notation does not have is still said as one.
      expect(_page('Text "A" animate=wobble').issues.single.message, startsWith('No animate=wobble. Written animate=fade, '));
    });
  });

  group('a component called in a definition without what it needs', () {
    late DesignSystem ds;
    late Catalog catalog;
    setUp(() async {
      const string = {'kind': 'string', 'flutter': 'String'};
      final files = {
        'design_system.json': jsonEncode({
          'id': 'acme',
          'name': 'Acme',
          'theme': {'primary': '#FF2563EB'},
          'components': ['components/Media.json'],
        }),
        'components/Media.json': jsonEncode({
          'schema': 3,
          'widget': {
            'type': 'Media',
            'doc': 'A drawn picture.',
            'props': [
              {'key': 'kind', 'type': string, 'default': 'harbor', 'required': true},
            ],
          },
          'roots': ['root'],
          'nodes': {
            'root': {'type': 'column', 'layout': {'width': 120, 'height': 80}},
          },
        }),
      };
      final problems = <String>[];
      ds = await DesignSystem.load((ref) async => files[ref], problems: problems);
      expect(problems, isEmpty);
      catalog = ds.catalogOver(standardCatalog);
    });

    NotationResult parse(String text) => Catalog.run(
        catalog, () => parseNotation(text, catalog: catalog, options: NotationOptions.fromDesignSystem(ds, width: 1440).open(openVocabulary: true)));

    test('is said with the component and what to write (it read: "kind" is not a missing the notation has)', () {
      final r = parse('define ListingCard "title"\n  Column\n    Media\n    Text "{title}"\nListingCard "Quay house"\n');
      final messages = r.issues.map((i) => i.message).toList();
      // `page:3:` is the definition's line (a site says it at its file's).
      expect(messages, ['page:3: A Media needs kind: write kind="…".']);
      expect(messages.join(), isNot(contains('is not a missing')));
      // On a page's own line it is recorded, not an issue (the open vocabulary).
      final own = parse('Column\n  Media\n');
      expect(own.issues, isEmpty);
      expect(own.vocabulary.map((u) => '${u.kind} ${u.word}'), contains('missing kind'));
    });
  });
}
