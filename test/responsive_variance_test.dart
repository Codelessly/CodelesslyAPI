import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

VarianceNode responsive(List<Variant> variants, {String? current}) =>
    VarianceNode(
      id: 'layout',
      name: 'Responsive layout',
      basicBoxLocal: NodeBox(0, 0, 390, 844),
      variants: variants,
      currentVariantId: current,
    );

Variant variant(String id, [ScreenBreakpoint? breakpoint]) =>
    Variant(id: id, name: id, children: ['$id-root'], breakpoint: breakpoint);

void main() {
  group('ScreenBreakpoint.forWidth', () {
    test('follows the screen variable rule (600 and 1024)', () {
      expect(ScreenBreakpoint.forWidth(0), ScreenBreakpoint.mobile);
      expect(ScreenBreakpoint.forWidth(390), ScreenBreakpoint.mobile);
      expect(ScreenBreakpoint.forWidth(599.9), ScreenBreakpoint.mobile);
      expect(ScreenBreakpoint.forWidth(600), ScreenBreakpoint.tablet);
      expect(ScreenBreakpoint.forWidth(834), ScreenBreakpoint.tablet);
      expect(ScreenBreakpoint.forWidth(1023.9), ScreenBreakpoint.tablet);
      expect(ScreenBreakpoint.forWidth(1024), ScreenBreakpoint.desktop);
      expect(ScreenBreakpoint.forWidth(1440), ScreenBreakpoint.desktop);
    });

    test('default widths fall in their own breakpoint', () {
      for (final ScreenBreakpoint breakpoint in ScreenBreakpoint.values) {
        expect(ScreenBreakpoint.forWidth(breakpoint.defaultWidth), breakpoint);
      }
    });
  });

  group('Variant.breakpoint JSON', () {
    test('round-trips and is omitted when unset', () {
      final Variant plain = variant('plain');
      expect(plain.toJson().containsKey('breakpoint'), isFalse);
      expect(Variant.fromJson(plain.toJson()), plain);

      final Variant tablet = variant('tablet', ScreenBreakpoint.tablet);
      expect(tablet.toJson()['breakpoint'], 'tablet');
      expect(Variant.fromJson(tablet.toJson()), tablet);
      expect(
        Variant.fromJson(tablet.toJson()).breakpoint,
        ScreenBreakpoint.tablet,
      );
    });

    test('a variance from before breakpoints reads as not responsive', () {
      // JSON written before breakpoints existed: no `breakpoint` keys.
      final Map json = jsonDecode(
        jsonEncode(responsive([variant('default')]).toJson()),
      ) as Map;
      expect(jsonEncode(json).contains('breakpoint'), isFalse);
      final VarianceNode node = VarianceNode.fromJson(json);
      expect(node.isResponsive, isFalse);
      expect(node.variants.single.breakpoint, isNull);
      expect(node.toJson()['variants'][0].containsKey('breakpoint'), isFalse);
    });

    test('a responsive variance survives a JSON-encoded round trip', () {
      final VarianceNode node = responsive([
        variant('m', ScreenBreakpoint.mobile),
        variant('t', ScreenBreakpoint.tablet),
        variant('d', ScreenBreakpoint.desktop),
      ], current: 't');
      final Map decoded = jsonDecode(jsonEncode(node.toJson())) as Map;
      final VarianceNode back = VarianceNode.fromJson(decoded);
      expect(back.isResponsive, isTrue);
      expect(back.variants.map((Variant v) => v.breakpoint).toList(), [
        ScreenBreakpoint.mobile,
        ScreenBreakpoint.tablet,
        ScreenBreakpoint.desktop,
      ]);
      expect(back.currentVariantId, 't');
      expect(back.variants, node.variants);
      // Read through the registry, as a page document is loaded.
      final BaseNode viaRegistry = NodeJsonConverter().fromJson(decoded)!;
      expect((viaRegistry as VarianceNode).variantForWidth(1440).id, 'd');
    });
  });

  group('VarianceNode.variantForWidth', () {
    test('picks the exact breakpoint', () {
      final VarianceNode node = responsive([
        variant('m', ScreenBreakpoint.mobile),
        variant('t', ScreenBreakpoint.tablet),
        variant('d', ScreenBreakpoint.desktop),
      ]);
      expect(node.variantForWidth(390).id, 'm');
      expect(node.variantForWidth(834).id, 't');
      expect(node.variantForWidth(1440).id, 'd');
      expect(node.children, ['m-root']);
    });

    test('falls back to the nearest, the smaller one on a tie', () {
      final VarianceNode mobileDesktop = responsive([
        variant('m', ScreenBreakpoint.mobile),
        variant('d', ScreenBreakpoint.desktop),
      ]);
      expect(mobileDesktop.variantForWidth(834).id, 'm');
      expect(mobileDesktop.variantForWidth(1440).id, 'd');

      final VarianceNode tabletOnly = responsive([
        variant('plain'),
        variant('t', ScreenBreakpoint.tablet),
      ]);
      expect(tabletOnly.variantForWidth(390).id, 't');
      expect(tabletOnly.variantForWidth(1440).id, 't');

      final VarianceNode mobileTablet = responsive([
        variant('m', ScreenBreakpoint.mobile),
        variant('t', ScreenBreakpoint.tablet),
      ]);
      expect(mobileTablet.variantForWidth(1440).id, 't');
    });

    test('an ordinary variance keeps its current variant', () {
      final VarianceNode node = responsive([
        variant('a'),
        variant('b'),
      ], current: 'b');
      expect(node.isResponsive, isFalse);
      expect(node.variantForBreakpoint(ScreenBreakpoint.mobile), isNull);
      expect(node.variantForWidth(390).id, 'b');
    });
  });
}
