import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('Breakpoints', () {
    test('defaults are data: mobile, tablet, desktop at 0, 600, 1024', () {
      final d = Breakpoints.defaults;
      expect(d.ids, ['mobile', 'tablet', 'desktop']);
      expect(d.list.map((b) => b.minWidth), [0, 600, 1024]);
      expect(d.byId('tablet')!.designWidth, 834);
      expect(d.isDefault, isTrue);
      // No breakpoints at all are the defaults.
      expect(Breakpoints.fromJson(null), d);
      expect(Breakpoints.fromJson([1, 'x', {'name': 'no id'}]), d);
      expect(Breakpoints(const []), d);
    });

    test('a width resolves to the highest min width at or below it', () {
      final d = Breakpoints.defaults;
      expect(d.forWidth(0).id, 'mobile');
      expect(d.forWidth(599.9).id, 'mobile');
      expect(d.forWidth(600).id, 'tablet');
      expect(d.forWidth(1023).id, 'tablet');
      expect(d.forWidth(1024).id, 'desktop');
      expect(d.forWidth(5000).id, 'desktop');
      expect(d.forWidth(-5).id, 'mobile');
    });

    test('any widths, any names, any count', () {
      final b = Breakpoints([
        const Breakpoint(id: 'xl', name: 'Large desktop', minWidth: 1600),
        const Breakpoint(id: 'watch', name: 'Watch', minWidth: 120),
        const Breakpoint(id: 'phone', name: 'Phone', minWidth: 300),
      ]);
      // Sorted, the first from 0.
      expect(b.ids, ['watch', 'phone', 'xl']);
      expect(b.first.minWidth, 0);
      expect(b.forWidth(200).id, 'watch');
      expect(b.forWidth(1599).id, 'phone');
      expect(b.forWidth(1600).id, 'xl');
      expect(b.find('large desktop')!.id, 'xl');
      expect(b.find('largeDesktop')!.id, 'xl');
      expect(b.find('XL')!.id, 'xl');
      expect(b.byId('xl')!.key, 'largeDesktop');
    });

    test('normalizes: unique ids, unique min widths', () {
      final b = Breakpoints([
        const Breakpoint(id: 'a', minWidth: 0),
        const Breakpoint(id: 'a', minWidth: 500),
        const Breakpoint(id: 'b', minWidth: 700),
        const Breakpoint(id: 'c', minWidth: 700),
      ]);
      expect(b.ids, ['a', 'b']);
    });

    test('a node or canvas may move switch points, keeping the order', () {
      final d = Breakpoints.defaults;
      expect(d.forWidth(1050, const {'desktop': 1100}).id, 'tablet');
      expect(d.forWidth(1100, const {'desktop': 1100}).id, 'desktop');
      expect(d.forWidth(650, const {'tablet': 700}).id, 'mobile');
      // Unknown ids are ignored.
      expect(d.forWidth(650, const {'nope': 10}).id, 'tablet');
    });

    test('nearest: itself, else fewest steps away, the narrower on a tie', () {
      final d = Breakpoints.defaults;
      expect(d.nearest('tablet', ['mobile', 'desktop']), 'mobile');
      expect(d.nearest('tablet', ['desktop']), 'desktop');
      expect(d.nearest('gone', ['mobile']), isNull);
    });

    test('at: the breakpoint starting at a width', () {
      expect(Breakpoints.defaults.at(600)!.id, 'tablet');
      expect(Breakpoints.defaults.at(0)!.id, 'mobile');
      expect(Breakpoints.defaults.at(700), isNull);
    });

    test('governing: itself, else the widest narrower, else the narrowest', () {
      final d = Breakpoints.defaults;
      expect(d.governing('tablet', ['mobile', 'tablet']), 'tablet');
      expect(d.governing('tablet', ['mobile', 'desktop']), 'mobile');
      expect(d.governing('tablet', ['desktop']), 'desktop');
      expect(d.governing('desktop', ['mobile']), 'mobile');
      expect(d.governing('mobile', ['desktop', 'tablet']), 'tablet');
      expect(d.governing('desktop', ['gone']), isNull);
      expect(d.governing('gone', ['mobile']), isNull);
      // On the defaults, the nearest breakpoint (the narrower on a tie), for
      // every set of variants.
      const ids = ['mobile', 'tablet', 'desktop'];
      for (var mask = 1; mask < 8; mask++) {
        final have = [for (var i = 0; i < 3; i++) if (mask & (1 << i) != 0) ids[i]];
        for (var want = 0; want < 3; want++) {
          var best = -1;
          for (var i = 0; i < 3; i++) {
            if (!have.contains(ids[i])) continue;
            if (best < 0 || (i - want).abs() < (best - want).abs()) best = i;
          }
          expect(d.governing(ids[want], have), ids[best], reason: '$have at ${ids[want]}');
        }
      }
      // A breakpoint nobody names changes nothing: between tablet and
      // desktop, tablet's still governs.
      final more = d.add(const Breakpoint(id: 'mid', minWidth: 800));
      expect(more.governing('mid', ['mobile', 'tablet', 'desktop']), 'tablet');
    });

    test('add, rename, remove, move', () {
      var b = Breakpoints.defaults;
      b = b.add(Breakpoint(id: b.newId(), name: 'Wide', minWidth: 1600, width: 1920, height: 1080));
      expect(b.ids, ['mobile', 'tablet', 'desktop', 'bp4']);
      // A min width another has moves up by one.
      b = b.add(const Breakpoint(id: 'x', minWidth: 600));
      expect(b.byId('x')!.minWidth, 601);
      b = b.remove('x');
      b = b.update('tablet', (t) => t.copyWith(name: 'Tab'));
      expect(b.byId('tablet')!.name, 'Tab');
      // Moving swaps ranges: tablet now covers desktop's.
      final moved = b.move('tablet', 1);
      expect(moved.ids, ['mobile', 'desktop', 'tablet', 'bp4']);
      expect(moved.byId('desktop')!.minWidth, 600);
      expect(moved.byId('tablet')!.minWidth, 1024);
      // The last one stays.
      expect(Breakpoints([const Breakpoint(id: 'only')]).remove('only').ids, ['only']);
    });

    test('round-trips sparsely; the panel reads its fields', () {
      final b = Breakpoints([const Breakpoint(id: 'a', name: 'A', width: 400), const Breakpoint(id: 'b', minWidth: 800.5)]);
      final json = jsonDecode(jsonEncode(b.toJson()));
      expect(json, [
        {'id': 'a', 'name': 'A', 'width': 400},
        {'id': 'b', 'minWidth': 800.5},
      ]);
      expect(Breakpoints.fromJson(json), b);
      expect(Breakpoint.spec.props.map((p) => p.key), ['id', 'name', 'minWidth', 'width', 'height']);
      expect(Breakpoints.codec.type.typeName, 'List<Breakpoint>');
    });

    test('a page document carries the project set; the defaults as nothing', () {
      final doc = LayoutDocument(id: 'p');
      expect(doc.breakpoints, Breakpoints.defaults);
      final custom = Breakpoints.defaults.update('tablet', (t) => t.copyWith(minWidth: 700));
      final withSet = doc.withBreakpoints(custom);
      expect(LayoutDocument.fromJson(withSet.toJson()).breakpoints, custom);
      expect(withSet.withBreakpoints(Breakpoints.defaults).toJson().containsKey('breakpoints'), isFalse);
    });

    test('the publish model carries them', () {
      final custom = Breakpoints([const Breakpoint(id: 'n', name: 'Narrow'), const Breakpoint(id: 'w', name: 'Wide', minWidth: 900)]);
      final m = PublishModel(projectId: 'p', breakpoints: custom);
      expect(PublishModel.fromJson(m.toJson()).breakpoints, custom);
      expect(PublishModel(projectId: 'p').toJson().containsKey('breakpoints'), isFalse);
      expect(PublishModel.fromJson({'projectId': 'p'}).breakpoints, Breakpoints.defaults);
    });
  });

  group('responsive variance', () {
    Node variance({Map<String, double> minWidths = const {}, String current = 'm'}) => Node(
          id: 'v',
          type: 'variance',
          props: Props.fromJson(VarianceProps.spec, {
            'variants': [
              {'id': 'm', 'name': 'Mobile', 'children': [], 'breakpoint': 'mobile'},
              {'id': 'd', 'name': 'Desktop', 'children': [], 'breakpoint': 'desktop'},
              {'id': 'err', 'name': 'Error', 'children': []},
            ],
            'current': current,
            if (minWidths.isNotEmpty) 'minWidths': minWidths,
          }),
        );

    test('shows the variant of the breakpoint the width resolves to, else the governing one', () {
      final v = variance();
      final d = Breakpoints.defaults;
      expect(v.isResponsive, isTrue);
      expect(v.variantForWidth(390, d)!['id'], 'm');
      // Tablet has no variant: mobile's covers it.
      expect(v.variantForWidth(800, d)!['id'], 'm');
      expect(v.variantForWidth(1440, d)!['id'], 'd');
      // A breakpoint added between doesn't move the switch.
      final more = d.add(const Breakpoint(id: 'wide', minWidth: 1200));
      expect(v.variantForWidth(1300, more)!['id'], 'd');
      final narrow = d.add(const Breakpoint(id: 'small', minWidth: 300));
      expect(v.variantForWidth(350, narrow)!['id'], 'm');
    });

    test('by its own switch points', () {
      final v = variance(minWidths: const {'desktop': 1200});
      expect(v.prop(VarianceProps.minWidths), {'desktop': 1200});
      expect(v.breakpointForWidth(1100, Breakpoints.defaults).id, 'tablet');
      expect(v.variantForWidth(1100, Breakpoints.defaults)!['id'], 'm');
      expect(v.variantForWidth(1200, Breakpoints.defaults)!['id'], 'd');
      expect(v.toJson()['props'], containsPair('minWidths', {'desktop': 1200}));
      // Composes with a breakpoint no variant names: the override moves
      // where its own variants switch, the added one changes nothing.
      final more = Breakpoints.defaults.add(const Breakpoint(id: 'wide', minWidth: 1100));
      expect(v.variantForWidth(1150, more)!['id'], 'm');
      expect(v.variantForWidth(1250, more)!['id'], 'd');
      // The panel edits them.
      expect(VarianceProps.spec.props.map((p) => p.key), contains('minWidths'));
      expect(CanvasProps.spec.props.map((p) => p.key), contains('breakpointMinWidth'));
    });

    test('a variance with no breakpoints of the project shows its current variant', () {
      final v = variance(current: 'err');
      final other = Breakpoints([const Breakpoint(id: 'a'), const Breakpoint(id: 'b', minWidth: 500)]);
      expect(v.variantForWidth(800, other)!['id'], 'err');
      const plain = Node(id: 'x', type: 'variance');
      expect(plain.isResponsive, isFalse);
    });
  });
}
