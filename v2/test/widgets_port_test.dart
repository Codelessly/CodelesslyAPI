// Fields master's v1 added to text, values, rows/columns, lists and the new
// widget types, as v2 models.
import 'package:codelessly_api_v2/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('switch, page view, paints, paths', () {
    test('a switch: thumb shadows and inset', () {
      final p = Props.fromJson(SwitchProps.spec, {'thumbInset': 3, 'thumbShadows': [{'type': 'dropShadow', 'blurRadius': 4}]});
      expect(p.get(SwitchProps.thumbInset), 3);
      expect(p.get(SwitchProps.thumbShadows).single.blurRadius, 4);
      expect(Props.fromJson(SwitchProps.spec, const {}).get(SwitchProps.thumbInset), isNull);
    });

    test('a page view: page motion', () {
      final m = Props.fromJson(PageViewProps.spec, {'pageMotion': {'rotateY': -50}}).get(PageViewProps.pageMotion);
      expect(m?.rotateY, -50);
    });

    test('paint: gradientPerSubpath, also from gradientUnits', () {
      expect(Paint.fromJson({'type': 'linear', 'gradientUnits': 'Subpath'})!.gradientPerSubpath, isTrue);
      expect(Paint.fromJson({'type': 'linear', 'gradientUnits': 'box'})!.gradientPerSubpath, isFalse);
      final p = Paint.fromJson({'type': 'radial', 'gradientPerSubpath': true})!;
      expect(p.toJson(), {'type': 'radial', 'gradientPerSubpath': true});
      expect(p == Paint.fromJson({'type': 'radial'}), isFalse);
    });

    test('path: subpath colors from a list or text, non-colors kept as null', () {
      expect(PathProps.subpathColors.decode(['#FF0000', 'x', '#80000000']),
          [const Color(0xFFFF0000), null, const Color(0x80000000)]);
      expect(PathProps.subpathColors.decode('#FF0000, #00FF00'), [const Color(0xFFFF0000), const Color(0xFF00FF00)]);
    });

    test('a gradient stop position binds, clamped', () {
      final n = Node.fromJson({
        'type': 'box',
        'decoration': {'fills': [
          {'type': 'linear', 'id': 'g1', 'stops': [{'position': 0, 'color': '#FF000000'}, {'position': 1, 'color': '#FFFFFFFF'}]},
        ]},
      }, id: 'b')!;
      final bound = BindPaths.apply(n, 'decoration.fills.g1.stops[1].position', '0.4');
      expect(bound.decoration.fills.single.stops[1].position, 0.4);
      expect(BindPaths.apply(n, 'decoration.fills.g1.stops[0].position', 3).decoration.fills.single.stops[0].position, 1);
    });
  });

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
