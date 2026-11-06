import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  TextNode text({List<String> features = const [], bool tabular = false}) =>
      TextNode(
        id: 't',
        name: 'Clock',
        basicBoxLocal: NodeBox(0, 0, 100, 40),
        data: '7:42 PM',
        fontFeatures: features,
        tabularFigures: tabular,
      );

  test('font features survive JSON and are left out when empty', () {
    final Map json = text(features: ['lnum', 'liga=0']).toJson();
    expect(json['fontFeatures'], ['lnum', 'liga=0']);
    final TextNode back = TextNode.fromJson(json);
    expect(back.fontFeatures, ['lnum', 'liga=0']);
    expect(back.resolvedFontFeatures, [
      OpenTypeFeature('lnum'),
      OpenTypeFeature('liga', 0),
    ]);

    expect(text().toJson().containsKey('fontFeatures'), isFalse);
    expect(TextNode.fromJson(text().toJson()).fontFeatures, isEmpty);
  });

  test(
    'JSON accepts maps, one string and spaced values, stored canonically',
    () {
      final Map base = text().toJson();
      expect(
        TextNode.fromJson({
          ...base,
          'fontFeatures': [
            {'tag': 'salt', 'value': 2},
            {'tag': 'smcp'},
            ' liga = 0 ',
            'ss01=1',
          ],
        }).fontFeatures,
        ['salt=2', 'smcp', 'liga=0', 'ss01'],
      );
      expect(
        TextNode.fromJson({...base, 'fontFeatures': 'lnum, tnum smcp'})
            .fontFeatures,
        ['lnum', 'tnum', 'smcp'],
      );
      // The constructor normalizes too.
      expect(text(features: ['liga = 0', 'lnum=1']).fontFeatures, [
        'liga=0',
        'lnum',
      ]);
    },
  );

  test('an invalid feature is rejected', () {
    final Map base = text().toJson();
    for (final Object bad in [
      ['lining'],
      ['ln'],
      ['liga=off'],
      ['liga=-1'],
      [3],
      {'tag': 'lnum'},
    ]) {
      expect(
        () => TextNode.fromJson({...base, 'fontFeatures': bad}),
        throwsFormatException,
        reason: '$bad',
      );
    }
  });

  test('tabularFigures means tnum, unless the features set tnum', () {
    expect(text(tabular: true).resolvedFontFeatures, [OpenTypeFeature('tnum')]);
    expect(text(features: ['lnum'], tabular: true).resolvedFontFeatures, [
      OpenTypeFeature('lnum'),
      OpenTypeFeature('tnum'),
    ]);
    expect(text(features: ['tnum=0'], tabular: true).resolvedFontFeatures, [
      OpenTypeFeature('tnum', 0),
    ]);
    // The last setting of a tag wins.
    expect(text(features: ['onum', 'lnum', 'onum=0']).resolvedFontFeatures, [
      OpenTypeFeature('onum', 0),
      OpenTypeFeature('lnum'),
    ]);
  });
}
