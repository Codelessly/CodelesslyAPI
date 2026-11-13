// Fields of text, values, rows/columns, lists and the newer widget types, as
// models.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('switch, page view, paints, paths', () {

    test('a path\'s per-shape colors read from a list or from text, and non-colors are kept as gaps', () {
      expect(PathProps.subpathColors.decode(['#FF0000', 'x', '#80000000']),
          [const Color(0xFFFF0000), null, const Color(0x80000000)]);
      expect(PathProps.subpathColors.decode('#FF0000, #00FF00'), [const Color(0xFFFF0000), const Color(0xFF00FF00)]);
    });

  });

  group('lists and new widget types', () {

    test('a pagination bar shortens long page ranges with ellipses that never hide a single page', () {
      expect(PaginationProps.pageItems(page: 5, pageCount: 16), [1, null, 4, 5, 6, null, 16]);
      expect(PaginationProps.pageItems(page: 3, pageCount: 16), [1, 2, 3, 4, null, 16]);
      expect(PaginationProps.pageItems(page: 1, pageCount: 0), isEmpty);
    });

    test('table columns read from a list or from a bound value', () {
      expect(TableColumn.fromJson('name')!.label, 'name');
      final c = TableColumn.fromJson({'key': 'a', 'width': 80})!;
      expect((c.key, c.label, c.width), ('a', '', 80));
      expect(Props.fromJson(TableViewProps.spec, {'columns': [{'key': 'a'}, 'b']}).get(TableViewProps.columns).length, 2);
    });
  });

  group('text and values', () {
    test('font features read in any common form and are stored one way', () {
      final s = TextStyle.fromJson({
        'fontFeatures': [' lnum', 'liga = 0', {'tag': 'salt', 'value': 2}, {'tag': 'smcp', 'value': true}, 'bad', 'x=y'],
        'leadingDistribution': 'even',
      });
      expect(s.fontFeatures, ['lnum', 'liga=0', 'salt=2', 'smcp']);
      expect(s.leadingDistribution, TextLeadingDistribution.even);
      expect(TextStyle.fromJson(s.toJson()), s);
      expect(TextStyle.fromJson({'fontFeatures': 'lnum,tnum ss01'}).fontFeatures, ['lnum', 'tnum', 'ss01']);
      // The last setting of a tag wins.
      expect(OpenTypeFeature.resolve(['liga', 'lnum', 'liga=0']), [const OpenTypeFeature('liga', 0), const OpenTypeFeature('lnum')]);
      expect(const TextStyle(fontFeatures: ['lnum']).merge(const TextStyle(fontSize: 3)).fontFeatures, ['lnum']);
      expect(TextStyle.empty.toJson(), isEmpty);
    });

  });
}
