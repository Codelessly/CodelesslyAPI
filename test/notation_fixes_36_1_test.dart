// The fix pass after 36.0.0 (fixes-36-1): what round 10's register
// (FRICTION-dsl-api-10.md, in the editor repository) and a fresh build on
// the release (support desk, test 11) left open. Each is read as meant, or
// said where it is written.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/catalog_json.dart' show catalogFromJson;
import 'package:test/test.dart';

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

Map<String, Object?> _string(String key, [String def = '']) => {'key': key, 'type': {'kind': 'string', 'flutter': 'String'}, 'default': def};
Map<String, Object?> _number(String key, num def) => {'key': key, 'type': {'kind': 'number', 'flutter': 'double'}, 'default': def};

NotationResult _with(Catalog extra, String text, [NotationOptions options = const NotationOptions()]) {
  final catalog = standardCatalog + extra;
  return Catalog.run(catalog, () => parseNotation(text, catalog: catalog, options: options));
}

void main() {
  group('R11: a Grid of cells written one by one takes its columns at other widths', () {
    test('Grid cols=4 phone.cols=2 tablet.cols=3 over five cells: the grid an each over range(5) makes, a cell a copy', () {
      final r = parseNotation('''
Column
  Grid#g cols=4 phone.cols=2 tablet.cols=3 gap=16
    Box#a h=40
      Text "1"
    Text#b "2"
    Text#c "3" visible={on}
    Text#d "4"
    Text#e "5"
''', catalog: standardCatalog, options: const NotationOptions(width: 1440));
      expect(r.issues, isEmpty);
      final list = _node(r, 'gCells');
      expect(list['type'], 'gridView');
      expect((list['props'] as Map)['crossAxisCount'], 4);
      expect((list['bind'] as Map)['data'], r'${= range(5)}');
      // The narrower width's rule last, so it wins where both hold.
      expect(list['media'], [
        {'maxWidth': 1023, 'patch': {'props': {'crossAxisCount': 3}}},
        {'maxWidth': 699, 'patch': {'props': {'crossAxisCount': 2}}},
      ]);
      expect(_node(r, 'gCellsItem')['children'], ['a', 'b', 'c', 'd', 'e']);
      expect((_node(r, 'a')['bind'] as Map)['visible'], r'${= item == 0}');
      expect((_node(r, 'c')['bind'] as Map)['visible'], r'${= (item == 2) && (on)}');
      expect(_node(r, 'g')['children'], ['gCells']);
      // No rows and no spacers filling the last one.
      expect((r.document['nodes'] as Map).keys.where((k) => '$k'.startsWith('gRow') || '$k'.startsWith('spacer')), isEmpty);
    });

    test('it prints back as the Grid line and its cells', () {
      const text = 'Column\n  Grid#g cols=4 gap=16 tablet.cols=3 phone.cols=2\n    Text "1"\n    Text "2"\n    Text "3" hidden\n';
      final r = parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 1440));
      final printed = printNotation(r.document, catalog: standardCatalog);
      expect(printed, contains('  Grid#g cols=4 gap=16 tablet.cols=3 phone.cols=2\n    Text "1"\n    Text "2"\n    Text "3" hidden'));
      final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(r.document));
      expect(back.document, r.document);
    });

    test('without columns at other widths the cells stay in rows, as before', () {
      final r = parseNotation('Grid#g cols=2\n  Text "a"\n  Text "b"\n  Text "c"\n', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      expect(_node(r, 'g')['children'], ['gRow1', 'gRow2']);
    });
  });

  group('R28: an overlay a component writes is there wherever it is called, as written', () {
    const mast = '''
component Mast "A top bar with a basket drawer."
  param title="Shop"
Row#mast pad=12 gap=8
  Text "{props.title}"
  Button#bag "Bag" onTap={open basket}
  Button#about "Info" onTap={open info}
Drawer#basket "Your bag" right w=440
  Text "Items"
Sheet#info "About" stops=[0.5,0.9]
  Text "Info"
''';

    test('the component keeps its overlays (screenOverlays), its opens say how each is shown', () {
      final r = parseNotation(mast, catalog: standardCatalog);
      expect(r.issues, isEmpty);
      final overlays = r.document['screenOverlays'] as List;
      expect([for (final o in overlays) (o as Map)['id']], ['basket', 'info']);
      expect(((overlays.first as Map)['nodes'] as Map)['basket'], containsPair('type', 'canvas'));
      final open = (((_node(r, 'about')['actions'] as List).single as Map)['actions'] as List).single as Map;
      expect(open, containsPair('presentation', 'bottomSheet'));
      expect(open['snapHeights'], [0.5, 0.9]);
    });

    test('a page that calls it takes them once, with ids of their own; its own overlay of that id is its own', () {
      final component = parseNotation(mast, catalog: standardCatalog).document;
      final widget = catalogFromJson({
        'widgets': [
          {
            'type': 'Mast',
            'props': [_string('title', 'Shop')],
          },
        ],
      });
      final options = NotationOptions(width: 1280, componentScreenOverlays: {
        'Mast': [for (final o in component['screenOverlays'] as List) (o as Map).cast<String, Object?>()],
      });
      final r = _with(widget, 'Column\n  Mast "Store"\n  Mast "Again"\n  Text#text1 "Body"\n', options);
      expect(r.issues, isEmpty);
      expect(r.document['roots'], ['screen', 'basket', 'info']);
      final nodes = r.document['nodes'] as Map;
      expect(nodes['basket'], containsPair('type', 'canvas'));
      // The component's ids are its document's: in the page they are the overlay's.
      expect(nodes.keys.where((k) => '$k'.startsWith('basket-')), isNotEmpty);
      expect(_node(r, 'text1')['props'], containsPair('text', 'Body'));

      final own = _with(widget, 'Column\n  Mast "Store"\nSheet#info "Mine"\n  Text "Page"\n', options);
      expect(own.issues, isEmpty);
      expect(own.document['roots'], ['screen', 'info', 'basket']);
      expect((own.document['nodes'] as Map).keys.where((k) => '$k'.startsWith('info-')), isEmpty);
    });
  });

  group('R41: a string on a component call fills a text parameter the line does not name', () {
    final heading = catalogFromJson({
      'widgets': [
        {
          'type': 'GuideSection',
          'props': [_string('label'), _string('note')],
        },
      ],
    });

    test('GuideSection "01" label="Installation": the string is the next text parameter, label the named one', () {
      final r = _with(heading, 'Column\n  GuideSection#g "01" label="Installation"\n');
      expect(r.issues, isEmpty);
      expect(_node(r, 'g')['props'], {'label': 'Installation', 'note': '01'});
    });

    test('a key the line gives the string itself keeps it (a printed line that says both reads back)', () {
      final r = _with(heading, 'Column\n  GuideSection#g "{t}" label={t}\n');
      expect(_node(r, 'g')['bind'], {'props.label': r'${t}'});
    });

    test('strings alone fill the text parameters in their order, as before', () {
      final r = _with(heading, 'Column\n  GuideSection#g "Installation" "01"\n');
      expect(r.issues, isEmpty);
      expect(_node(r, 'g')['props'], {'label': 'Installation', 'note': '01'});
    });
  });

  group('R31: what a component call takes of the keys every line takes', () {
    final disc = catalogFromJson({
      'widgets': [
        {
          'type': 'Disc',
          'props': [_string('label'), _number('size', 28)],
        },
      ],
    });

    test('its size, place and widths are the call\'s; its look (fill, border, radius, clip) is said, not left out silently', () {
      final r = _with(disc, 'Column\n  Disc#d "MR" maxw=300 margin=4 phone.w=fill opacity=0.5\n');
      expect(r.issues, isEmpty);
      final d = _node(r, 'd');
      expect((d['layout'] as Map)['constraints'], {'maxWidth': 300});
      expect(d['media'], [
        {'maxWidth': 699, 'patch': {'layout': {'width': {'fill': 0}}}},
      ]);
      final look = _with(disc, 'Column\n  Disc#a "A" fill=#FFFF0000 border=#FF00FF00\n  Disc#b "B" radius=8\n  Disc#c "C" clip\n');
      expect(look.issues, hasLength(3));
      expect(look.issues[0].message, startsWith('fill=, border= on a call of Disc is left out.'));
      expect(look.issues.every((i) => i.message.contains('A component call has no look of its own')), isTrue);
      expect(_node(look, 'a')['decoration'], isNull);
    });
  });

  group('support desk: a component\'s own size is its parameter', () {
    test('Avatar "…" size=32 on an Avatar whose size is a number keeps 32; one that sizes by name takes the nearest', () {
      final desk = catalogFromJson({
        'widgets': [
          {
            'type': 'Avatar',
            'props': [_string('name'), _number('size', 28)],
          },
        ],
      });
      final r = _with(desk, 'Column\n  Avatar#a "Maya Chen" size=32\n  Avatar#b name="Jo Park" size=20\n');
      expect(r.issues, isEmpty);
      expect(_node(r, 'a')['props'], {'name': 'Maya Chen', 'size': 32});
      expect((_node(r, 'b')['props'] as Map)['size'], 20);

      final named = catalogFromJson({
        'widgets': [
          {
            'type': 'Avatar',
            'props': [
              _string('name'),
              {'key': 'size', 'type': {'kind': 'enumeration', 'flutter': 'String', 'values': ['xs', 'small', 'medium', 'large']}, 'default': 'medium'},
            ],
          },
        ],
      });
      final n = _with(named, 'Column\n  Avatar#a "Maya Chen" size=32\n');
      expect((_node(n, 'a')['props'] as Map)['size'], 'small');
    });
  });
  group('R20: what the head and the tree of a component may say of its parameters', () {
    test('param @selected, a bare List, event …:void and props.selected=… in the tree', () {
      final r = parseNotation('''
component Picker "Choose one."
  param @selected=""
  param items:List=[]
  event onPick:void
Column#picker gap=4
  each it in props.items
    Text#row "{it}" onTap={props.selected=it; emit onPick}
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      final widget = r.document['widget'] as Map;
      final props = {for (final p in widget['props'] as List) (p as Map)['key']: p['type']};
      expect(props['selected'], {'kind': 'variable', 'of': {'kind': 'string', 'flutter': 'String'}});
      expect((props['items'] as Map)['kind'], 'list');
      expect(widget['events'], [
        {'key': 'onPick'},
      ]);
      final tap = ((_node(r, 'row')['actions'] as List).single as Map)['actions'] as List;
      expect(tap.first, {'type': 'setVariable', 'variable': 'props.selected', 'value': r'${= item}'});
    });

    test('props.x=… on a parameter the call gives (not a variable one) is said, with how to keep it', () {
      final r = parseNotation('''
component Picker "Choose one."
  param selected=""
Column#picker
  Text#row "x" onTap={props.selected="a"}
''', catalog: standardCatalog);
      expect(r.issues.single.message, contains('param @selected'));
    });
  });

  group('R50: resizable on a pane is said with the Splitter that does it', () {
    test('Pane … resizable and Sidebar … resizable=@w: an issue naming Splitter; the Splitter form reads', () {
      final r = parseNotation('''
state w=300
App
  Sidebar w={w} resizable=@w
    Text "a"
  Main
    Text "b"
  Pane w=300 resizable
    Text "c"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280));
      expect(r.issues, hasLength(1));
      expect(r.issues.every((i) => i.message.contains('Splitter @listW')), isTrue);
      final open = parseNotation('''
App
  Pane w=300 resizable
    Text "c"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280).open());
      expect(open.issues.single.message, contains('Splitter'));
      final ok = parseNotation('''
state w=300
App
  Pane w={w}
    Text "a"
  Splitter @w min=240 max=480
  Main
    Text "b"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280));
      expect(ok.issues, isEmpty);
    });
  });

  group('R17: a Table\'s sort arrow is in the theme\'s accent', () {
    test('by its name where the theme names it (a design system, a site\'s primary); the default blue without one', () {
      const text = 'state rows=[{"n":"a"}]\nstate sk="n"\nTable r in rows columns=["N"] sort=@sk\n  Text "{r.n}"\n';
      String arrow(NotationResult r) => [
            for (final n in (r.document['nodes'] as Map).values)
              if ((n as Map)['type'] == 'icon' && '${(n['bind'] as Map?)?['props.icon']}'.contains('arrow_upward')) (n['props'] as Map)['color'],
          ].single as String;
      expect(arrow(parseNotation(text, catalog: standardCatalog, options: const NotationOptions(accent: 'primary'))), 'primary');
      expect(arrow(parseNotation(text, catalog: standardCatalog)), '#FF2563EB');
    });
  });

  group('R22: an every line in minutes or hours', () {
    test('every 1m and every 2h are timers of that many milliseconds', () {
      final r = parseNotation('state n=0\nText "{n}"\nevery 1m onTick={n=n+1}\nevery 2h onTick={n=0}\n', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      final timers = [for (final a in _node(r, 'screen')['actions'] as List) ((a as Map)['trigger'] as Map)['intervalMs']];
      expect(timers, [60000, 7200000]);
    });
  });
}
