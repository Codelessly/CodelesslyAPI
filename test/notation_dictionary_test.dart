// The closure test of track B (docs/design/23-base-and-dictionary.md, step
// B2): each word the expander writes out in Dart, written instead as a
// definition in dictionary/, expanded both ways over its uses and compared
// node by node (tool/dictionary/closure.dart). What it found is
// docs/design/base-inventory/closure.json (tool/dictionary_closure.dart):
// this test runs the comparison again and fails when a word's result moves,
// so that a change to the expander or to a definition is seen. When the
// change is meant, run the tool again (from an LF copy) and commit the file.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart' show Catalog, standardCatalog;
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import '../tool/dictionary/closure.dart';
import '../tool/dictionary/generate.dart';

void main() {
  final files = readDictionary('dictionary');
  final words = {for (final f in files.values) ...f.words};
  final recorded = {
    for (final r in (jsonDecode(File('docs/design/base-inventory/closure.json').readAsStringSync()) as List).cast<Map<String, Object?>>()) r['word'] as String: r,
  };

  group('canonical', () {
    test('ids aside, two documents of one tree are equal', () {
      Json doc(String a, String b) => {
            'roots': ['s'],
            'nodes': {
              's': {
                'type': 'canvas',
                'slots': {'body': a},
              },
              a: {
                'type': 'row',
                'children': [b],
                'bind': {'visible': '\${= $a.x}'},
              },
              b: {'type': 'text'},
            },
          };
      expect(Comparison(doc('row1', 'text1'), doc('navItemDict1', 'text9')).equal, isTrue);
      expect(Comparison(doc('row1', 'text1'), doc('row1', 'text1')..['roots'] = ['s', 'x']).equal, isFalse);
    });

    test('an expression spelt otherwise is the same up to spelling', () {
      Json doc(String e) => {
            'roots': ['s'],
            'nodes': {
              's': {
                'type': 'text',
                'bind': {'selected': '\${= $e}'},
              },
            },
          };
      final a = doc('(tab=="home")'), b = doc('tab == "home"');
      expect(Comparison(a, b).equal, isFalse);
      expect(Comparison(a, b, spelling: true).equal, isTrue);
      // A space inside a string is part of what it says.
      expect(Comparison(doc('(f=="Sentitems")'), doc('f == "Sent items"'), spelling: true).equal, isFalse);
    });

    test('a word is renamed where a line starts with it, and nowhere else', () {
      expect(renameWords('App\n  NavItem "App" icon="apps"\n  NavItems\ndefine NavItem "x"\n', {'App', 'NavItem'}),
          'AppDict\n  NavItemDict "App" icon="apps"\n  NavItems\ndefine NavItemDict "x"\n');
    });
  });

  test('the definitions read', () {
    expect(readDefinitionsProblems(files.values), isEmpty);
  });

  group('the built-in dictionary (docs/design/23 section 5.2)', () {
    test('lib/src/core/notation/dictionary.g.dart holds the texts of dictionary/ for the built-in words', () {
      expect(File(generatedPath).readAsStringSync().replaceAll('\r\n', '\n'), generatedDictionary(), reason: 'run dart run tool/dictionary/generate.dart');
      expect(notationDictionaryWords, builtInWords.toSet());
      for (final w in builtInWords) {
        expect(recorded[w]?['closes'], isTrue, reason: '$w is built in: its closure is exact');
      }
    });

    NotationResult read(String text, [NotationOptions options = const NotationOptions()]) => Catalog.run(standardCatalog, () => parseNotation(text, options: options));

    test('a word of it is read from its definition, and recorded as the dictionary\'s', () {
      final r = read('state cart=[1,2]\ncomputed total={sum(cart)}\nColumn\n  Text "{total}"\n', const NotationOptions().open());
      expect(r.issues, isEmpty);
      final u = r.vocabulary.single;
      expect((u.kind, u.word, u.of, u.to), ('definition', 'computed', 'dictionary', 'computed'));
      expect(isDictionaryDefinition(notationDictionary['computed']!.single), isTrue);
    });

    test('a design system\'s definition of the word wins; a page\'s own is not used, as before', () {
      final ds = read('computed total={1}\nColumn\n  Text "x"\n', const NotationOptions().define({'computed.txt': 'computed\n  key k onPress={toast "the design system\'s"}\n'}));
      expect(jsonEncode(ds.document), contains('the design system'));
      expect(jsonEncode(ds.document), isNot(contains('"total"')));
      final page = read('state a=1\ncomputed total={a}\nColumn\n  Text "{total}"\ndefine computed\n  key m onPress={toast "mine"}\n');
      expect(jsonEncode(page.document), isNot(contains('mine')));
      expect(page.issues.single.message, startsWith('The notation already has computed, read as a state line'));
    });

    test('where a word\'s meaning is written: the base, the dictionary, or code', () {
      String? origin(String w) => Catalog.run(standardCatalog, () => notationWordOrigin(w));
      expect([for (final w in const ['Column', 'Text', 'state', 'computed', 'Sidebar', 'NavItem', 'H2', 'Shortcut', 'StickyNote']) origin(w)],
          ['base', 'base', 'base', 'dictionary', 'code', 'code', 'code', 'code', null]);
    });
  });

  group('closure, as recorded', () {
    for (final w in words.toList()..sort()) {
      test(w, () {
        final r = recorded[w];
        expect(r, isNotNull, reason: '$w is not in closure.json: run tool/dictionary_closure.dart');
        final uses = usesOf(w);
        final c = closure(w, uses, files.values);
        expect(c.results.length, r!['expansions'], reason: 'uses of $w changed');
        expect(c.closes, r['closes'], reason: '$w closes now: ${c.closes}');
        expect(c.closesUpToSpelling, r['closesUpToSpelling']);
        expect(c.results.where((x) => x.comparison.equal && x.issues.isEmpty).length, r['equal']);
        expect(c.results.fold<int>(0, (n, x) => n + x.comparison.same), r['same'], reason: 'nodes the same for $w');
      });
    }
    test('the frame family, renamed together', () {
      for (final w in const ['App', 'Page']) {
        final r = recorded['$w (family)']!;
        final c = closure('$w (family)', usesOf(w), files.values, renamed: frameFamily.intersection(words));
        expect(c.results.where((x) => x.comparison.equal && x.issues.isEmpty).length, r['equal']);
        expect(c.results.fold<int>(0, (n, x) => n + x.comparison.same), r['same']);
      }
    });
  });
}
