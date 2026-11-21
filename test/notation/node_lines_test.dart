// NotationResult.lines: the line of the text that made each node, so that
// what is found wrong in the document (a size, an overflow) can be said by
// the line of the notation it comes from. And a site of files in memory
// says a word that reaches itself through the words of other files.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/notation_site.dart';
import 'package:test/test.dart';

void main() {
  group('the line that made each node', () {
    test('a node is of the line it is written on', () {
      final r = parseNotation('Column#top gap=8\n  Text#a "one"\n\n  // a comment\n  Row#row\n    Button#go "Go"\n');
      expect(r.issues, isEmpty);
      expect(r.lines['top'], 1);
      expect(r.lines['a'], 2);
      expect(r.lines['row'], 5);
      expect(r.lines['go'], 6);
      // Every node but the canvas has a line.
      final nodes = (r.document['nodes'] as Map).keys.toSet()..remove('screen');
      expect(r.lines.keys.toSet(), containsAll(nodes));
    });

    test('the nodes a word made are of the line that calls it: a defined word, a page word', () {
      final r = parseNotation(
        'define Pair "label"\n  Row gap=4\n    Text "{label}"\n    Text "*"\nColumn#top\n  Pair "one"\n  Pair "two"\n',
      );
      expect(r.issues, isEmpty);
      final byLine = <int, int>{};
      for (final l in r.lines.values) {
        byLine[l] = (byLine[l] ?? 0) + 1;
      }
      expect(byLine.keys.toSet(), {5, 6, 7});
      expect(byLine[6], 3, reason: 'a row and two texts');
      expect(byLine[7], 3);

      final page = parseNotation('App\n  Sidebar#side\n    Text#menu "Menu"\n  Main\n    Card#card\n      Text#t "Hello"\n', options: const NotationOptions(width: 1440));
      expect(page.lines['side'], 2);
      expect(page.lines['menu'], 3);
      expect(page.lines['card'], 5);
      expect(page.lines['t'], 6);
    });

    test('a text with nothing but its own lines: each node, its line, and no other', () {
      final whole = parseNotation('Column#top gap=8\n  Text#a "one"\n  Row#row\n    Button#go "Go"\n');
      expect(whole.lines, {'top': 1, 'a': 2, 'row': 3, 'go': 4});
    });
  });

  group('a site in memory', () {
    test('a word that reaches itself through another file\'s word is said once, with the way round', () {
      final site = NotationSiteFiles({
        'pages/home.txt': 'Column\n  A "x"\n',
        'components/A.txt': 'define A "t"\n  Column\n    B "{t}"\n',
        'components/B.txt': '// The other.\ndefine B "t"\n  A "{t}"\n',
      }, catalog: standardCatalog);
      final rings = [
        for (final p in site.problems)
          if (p.message.contains('uses itself')) (p.path, p.line, p.message),
      ];
      expect(rings, [('components/A.txt', 1, 'A uses itself (A > B > A): it is not read.')]);
      // And it expands: nothing nests without end.
      final all = NotationSiteExpander(site, catalog: standardCatalog).expandAll();
      expect(all.pages.single.document['nodes'], isNotEmpty);
    });

    test('a word that calls itself in its own file is said once, not twice', () {
      final site = NotationSiteFiles({
        'pages/home.txt': 'Column\n  A "x"\n',
        'components/A.txt': 'define A "t"\n  Column\n    A "{t}"\n',
      }, catalog: standardCatalog);
      expect(site.problems.where((p) => p.message.contains('uses itself')), hasLength(1));
    });
  });
}
