// Fields master's v1 added to text, values, rows/columns, lists and the new
// widget types, as v2 models.
import 'package:codelessly_api_v2/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('text and values', () {
    test('font features read loosely, stored canonical; leading distribution', () {
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

    test('input decoration: new fields are sparse', () {
      final d = InputDecoration.fromJson({'affixesAlwaysVisible': true, 'prefixIconPadding': [12, 0, 8, 0]});
      expect(d.affixesAlwaysVisible, isTrue);
      expect(d.paddingIncludesBorder, isFalse);
      expect(d.prefixIconPadding, const EdgeInsets.fromLTRB(12, 0, 8, 0));
      expect(d.toJson(), {'affixesAlwaysVisible': true, 'prefixIconPadding': [12, 0, 8, 0]});
    });

    test('an icon image may be given as imageUrl', () {
      expect(IconProps.icon.decode({'imageUrl': 'u'}), {'image': 'u'});
      expect(IconProps.icon.decode({'image': 'a', 'imageUrl': 'u'}), {'image': 'a', 'imageUrl': 'u'});
    });
  });
}
