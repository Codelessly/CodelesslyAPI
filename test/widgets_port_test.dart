// Fields of text, values, rows/columns, lists and the newer widget types, as
// models.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('switch, page view, paints, paths', () {
    test('a switch: thumb shadows and inset', () {
      final p = Props.fromJson(SwitchProps.spec, {'thumbInset': 3, 'thumbShadows': [{'type': 'dropShadow', 'blurRadius': 4}]});
      expect(p.get(SwitchProps.thumbInset), 3);
      expect(p.get(SwitchProps.thumbShadows).single.blurRadius, 4);
      expect(Props.fromJson(SwitchProps.spec, const {}).get(SwitchProps.thumbInset), isNull);
    });

    test('a switch: thumb border, slide duration and curve', () {
      final p = Props.fromJson(SwitchProps.spec, {
        'activeThumbBorderColor': '#FF111111',
        'inactiveThumbBorderColor': '#FFDDDDDD',
        'thumbBorderWidth': 1.5,
        'toggleDurationMs': 180,
        'toggleCurve': 'easeOut',
      });
      expect(p.get(SwitchProps.thumbBorderWidth), 1.5);
      expect(p.get(SwitchProps.toggleDurationMs), 180);
      expect(p.get(SwitchProps.toggleCurve), AnimationCurve.easeOut);
      final d = Props.fromJson(SwitchProps.spec, const {});
      expect((d.get(SwitchProps.thumbBorderWidth), d.get(SwitchProps.toggleDurationMs)), (null, 220));
      expect(d.get(SwitchProps.toggleCurve), AnimationCurve.easeOutCubic);
    });

    test('a page view: page motion', () {
      final m = Props.fromJson(PageViewProps.spec, {'pageMotion': {'rotateY': -50}}).get(PageViewProps.pageMotion);
      expect(m?.motion.rotateY, -50);
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

  group('lists and new widget types', () {
    test('list features are sparse records', () {
      final p = Props.fromJson(ListViewProps.spec, {
        'pagination': {'name': 'c', 'source': 'cloud', 'strategy': 'page'},
        'reorder': {},
        'swipeActions': {'endActions': [{'id': 'delete'}]},
      });
      final pagination = p.get(ListViewProps.pagination)!;
      expect(pagination.name, 'c');
      // A cloud source pages by cursor.
      expect(pagination.strategy, PaginationStrategy.cursor);
      expect(pagination.pageSize, 20);
      expect(p.get(ListViewProps.reorder), ListReorder.standard);
      expect(p.get(ListViewProps.swipeActions)!.endActions.single.background, const Color(0xFFDB2626));
      expect(p.toJson(ListViewProps.spec)['swipeActions'], {'endActions': [{'id': 'delete'}]});
      expect(ListViewProps.spec.slots, containsAll(['loading', 'sectionHeader', 'reorderPlaceholder']));
    });

    test('paginate action and the list triggers', () {
      final a = ActionDef.fromJson({'type': 'paginate', 'controller': 'c', 'command': 'setPageSize', 'pageSize': '50'});
      expect(a, isA<PaginateAction>());
      expect((a as PaginateAction).command, PaginateCommand.setPageSize);
      expect(Trigger.fromJson({'type': 'refresh'})?.type, TriggerType.refresh);
      expect(Trigger.fromJson({'type': 'swipeAction'})?.type, TriggerType.swipeAction);
    });

    test('pagination page numbers, with ellipses that never hide one page', () {
      expect(PaginationProps.pageItems(page: 5, pageCount: 16), [1, null, 4, 5, 6, null, 16]);
      expect(PaginationProps.pageItems(page: 3, pageCount: 16), [1, 2, 3, 4, null, 16]);
      expect(PaginationProps.pageItems(page: 1, pageCount: 0), isEmpty);
    });

    test('table columns, also from bound values', () {
      expect(TableColumn.fromJson('name')!.label, 'name');
      final c = TableColumn.fromJson({'key': 'a', 'width': 80})!;
      expect((c.key, c.label, c.width), ('a', '', 80));
      expect(Props.fromJson(TableViewProps.spec, {'columns': [{'key': 'a'}, 'b']}).get(TableViewProps.columns).length, 2);
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
      // A bound name swaps the glyph.
      expect(IconProps.icon.decode('pause'), {'type': 'MATERIAL_ICON', 'name': 'pause', 'style': 'filled'});
      expect(IconProps.icon.decode('https://x/i.png'), {'image': 'https://x/i.png'});
      expect(IconProps.icon.decode(''), <String, Object?>{});
    });
  });
}
