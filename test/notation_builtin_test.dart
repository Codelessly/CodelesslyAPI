// A built-in word wins (the owner's decision, 2026-11-18): a writer's
// definition of a word the notation already has is not used, and said where
// it is written: `primitive MiniCalendar` would turn every `MiniCalendar`
// line into a labelled box, and `define Card` would replace the notation's
// card.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _text = '''
state n=0
Column
  MiniCalendar
  Card
    Text "x"
  Rating2 "Ok"
primitive MiniCalendar "label"
define Card "title"
  Box pad=4
define Rating2 "label"
  Text "{label}"
''';

void main() {
  test('what the notation has, in one line', () {
    expect(notationBuiltInWord('MiniCalendar'), "MiniCalendar, read as the notation's Calendar");
    expect(notationBuiltInWord('Rail'), startsWith('Rail, a word of the page'));
    expect(notationBuiltInWord('Text', catalog: standardCatalog), startsWith('Text, a word of the notation'));
    expect(notationBuiltInWord('Rating2'), isNull);
    expect(notationBuiltInWord('Masthead'), isNull);
  });

  for (final stream in [false, true]) {
    test('a definition of a built-in word is not used, and said at its line (${stream ? 'a stream' : 'a whole text'})', () {
      final List<NotationIssue> issues;
      final Json document;
      final List<VocabularyUse> vocabulary;
      if (stream) {
        final s = NotationStream(catalog: standardCatalog);
        for (final l in _text.split('\n')) {
          s.add('$l\n');
        }
        s.close();
        issues = s.issues;
        document = s.result!.document;
        vocabulary = s.vocabulary;
      } else {
        final r = Catalog.run(standardCatalog, () => parseNotation(_text, catalog: standardCatalog));
        issues = r.issues;
        document = r.document;
        vocabulary = r.vocabulary;
      }
      final said = [for (final i in issues) '$i'];
      expect(said, contains(contains('The notation already has MiniCalendar, read as the notation\'s Calendar')));
      expect(said, contains(contains('So this definition of Card is not used: Card is the notation\'s.')));
      if (!stream) {
        expect(issues.where((i) => i.message.contains('MiniCalendar')).single.line, 7);
        expect(issues.where((i) => i.message.contains('of Card')).single.line, 8);
      }
      // The built-in is read: a calendar, not a primitive's box.
      expect([for (final u in vocabulary) if (u.kind == 'primitive') u.word], isEmpty);
      // (A stream reads a definition from where it is written: Rating2 is used above it.)
      if (!stream) expect([for (final u in vocabulary) if (u.kind == 'definition') u.word], ['Rating2']);
      expect('$document', contains('type: calendar'));
    });
  }
}
