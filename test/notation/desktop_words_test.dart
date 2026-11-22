// The words a desktop page's writer reaches for when the page goes narrower
// (experiments dsl-api-9, the six desktop-first builds): a line hidden at a
// width, a row that turns into a column, a named text style changed at a
// width, a text with a box hidden whole, a component's own rules at its call,
// a scrolling pane that grows, a bare Spacer, a dialog that follows the
// site's theme and guards Escape.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _read(String text, {NotationOptions options = const NotationOptions(), Catalog? catalog}) {
  final r = parseNotation(text, catalog: catalog ?? standardCatalog, options: options);
  expect(r.issues, isEmpty, reason: text);
  return r;
}

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

Map<String, Object?> _parentOf(NotationResult r, String id) =>
    ((r.document['nodes'] as Map).values.firstWhere((n) => n is Map && ((n['children'] as List?)?.contains(id) ?? false)) as Map).cast<String, Object?>();

/// The document [r] printed and read back is the same document.
void _roundTrips(NotationResult r) {
  final text = printNotation(r.document, catalog: standardCatalog);
  expect(text, isNot(contains(' {"')), reason: text);
  final back = parseNotation(text, catalog: standardCatalog, options: notationOptionsFor(r.document)).document;
  expect(jsonEncode(_sorted(back)), jsonEncode(_sorted(r.document)), reason: text);
}

Object? _sorted(Object? v) => switch (v) {
  final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
  final List l => [for (final e in l) _sorted(e)],
  final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
  _ => v,
};

void main() {
  test('tablet.hidden and phone.hidden hide a Row, a Column, a Text at that width', () {
    final r = _read('Column#root\n  Row#a tablet.hidden\n    Text "a"\n  Column#b phone.hidden\n    Text "b"\n  Text#c "c" hidden=false');
    expect(_node(r, 'a')['media'], [
      {
        'maxWidth': 1023,
        'patch': {'visible': false},
      },
    ]);
    expect(_node(r, 'b')['media'], [
      {
        'maxWidth': 699,
        'patch': {'visible': false},
      },
    ]);
    expect(_node(r, 'c')['visible'], true);
  });

  test('a text with a box of its own (pad and fill) hides with its box: no empty pill', () {
    final r = _read('Column#root\n  Text#t "Board" pad=[8,4,8,4] fill=#FFEEEEEE hide=tablet tablet.pad=4');
    expect(_node(r, 't')['media'], isNull);
    final box = _parentOf(r, 't');
    expect(box['type'], 'column');
    expect(box['media'], [
      {
        'maxWidth': 1023,
        'patch': {
          'visible': false,
          'bind': {'visible': null},
        },
      },
      {
        'maxWidth': 1023,
        'patch': {
          'layout': {'padding': 4},
        },
      },
    ]);
  });

  test('a Row that is a column at a width is a Flex; a Flex takes scroll and the alignment words', () {
    final r = _read('Column#root\n  Row#h gap=4 stretch phone.direction=vertical\n    Text "1"\n    Text "2"\n  Flex#f direction=horizontal scroll between phone.direction=vertical\n    Text "3"');
    expect(_node(r, 'h')['type'], 'flex');
    expect(_node(r, 'h')['props'], {'direction': 'horizontal', 'spacing': 4, 'crossAxisAlignment': 'stretch'});
    expect(_node(r, 'h')['media'], [
      {
        'maxWidth': 699,
        'patch': {
          'props': {'direction': 'vertical'},
        },
      },
    ]);
    final f = _node(r, 'f');
    expect((f['props'] as Map)['scrollable'], true);
    expect((f['props'] as Map)['scrollDirection'], 'horizontal');
    expect((f['props'] as Map)['mainAxisAlignment'], 'spaceBetween');
    // It scrolls the way it runs, at every width.
    expect(f['media'], [
      {
        'maxWidth': 699,
        'patch': {
          'props': {'direction': 'vertical', 'scrollDirection': 'vertical'},
        },
      },
    ]);
    _roundTrips(_read('Column#root\n  Row#h gap=4 stretch phone.direction=vertical\n    Text "1"\n    Text "2"'));
  });

  test('a named style with a size (style=title size=34, phone.size=13) keeps the style; from=title adds no body look', () {
    final r = _read(
      'Column#root\n  Text#a "A" style=title size=34\n  Text#b "B" style=title phone.size=13\n  Text#c "C" from=title\n  Text#d "D" size=34 from=title\n  Text#e "E" style=caption color=#FFFF0000',
    );
    expect((_node(r, 'a')['props'] as Map)['style'], {'from': 'title', 'fontSize': 34});
    expect((_node(r, 'b')['props'] as Map)['style'], 'title');
    expect(_node(r, 'b')['media'], [
      {
        'maxWidth': 699,
        'patch': {
          'props': {
            'style': {'from': 'title', 'fontSize': 13},
          },
        },
      },
    ]);
    expect((_node(r, 'c')['props'] as Map)['style'], {'from': 'title'});
    expect((_node(r, 'd')['props'] as Map)['style'], {'fontSize': 34, 'from': 'title'});
    expect((_node(r, 'e')['props'] as Map)['style'], {'from': 'caption', 'color': '#FFFF0000'});
    _roundTrips(r);
  });

  test('a box that grows in a column takes the height left (a pane that scrolls under a bar); a text does not', () {
    final r = _read('Column#root h=fill\n  Row#bar h=56\n    Text "Bar"\n  Column#body scroll grow\n    Text "Body"\n  Text#t "grows" grow');
    expect((_node(r, 'body')['layout'] as Map)['height'], {'fill': 0});
    expect((_node(r, 't')['layout'] as Map)['height'], {'hug': 0});
    _roundTrips(r);
  });

  test('a bare Spacer takes the room left in its row and its column', () {
    final r = _read('Column#root h=400\n  Row#r\n    Text "Due"\n    Spacer#s1\n    Text "AB"\n  Spacer#s2\n  Text "foot"');
    expect((_node(r, 's1')['layout'] as Map)['flex'], 1);
    expect((_node(r, 's2')['layout'] as Map)['flex'], 1);
    expect((_node(r, 's2')['layout'] as Map)['height'], {'fill': 0});
    _roundTrips(r);
  });

  test("a dialog with no theme of its own is drawn in the site's surface and ink (dark mode follows); a drawer has no light rule at its side", () {
    final r = _read('state x=0\nColumn#root\n  Button "Open" onTap={open dlg}\nDialog#dlg "Delete project?" w=420\n  Text "Gone for good."\nDrawer#dr "Menu"\n  Text "One"');
    final dlg = _node(r, 'dlg');
    expect((dlg['decoration'] as Map)['fills'], [
      {'color': 'surface'},
    ]);
    final nodes = (r.document['nodes'] as Map).values.cast<Map>();
    final title = nodes.firstWhere((n) => (n['props'] as Map?)?['text'] == 'Delete project?');
    expect(((title['props'] as Map)['style'] as Map)['color'], 'onSurface');
    final drawerPanel = nodes.firstWhere((n) => n['type'] == 'column' && (n['decoration'] as Map?)?['strokeSides'] == 'right');
    expect((drawerPanel['decoration'] as Map)['fills'], [
      {'color': 'surface'},
    ]);
    expect((drawerPanel['decoration'] as Map)['strokes'], [
      {'color': '#00000000'},
    ]);
    // A theme that names no surface still draws the panel (paper), not nothing.
    expect(ThemeRefs(ThemeTokens.none).value(PropTypes.color, 'surface'), '#FFFFFFFF');
  });

  test('a dialog guards Escape, a tap outside and back with blockBack={…} and onBackPressed={…}', () {
    final r = _read('state dirty=false\nstate asked=false\nColumn#root\n  Button "Open" onTap={open dlg}\nDialog#dlg "Compose" blockBack={dirty} onBackPressed={asked=true}\n  Text "Body"');
    final dlg = _node(r, 'dlg');
    expect(dlg['bind'], {'props.blockBack': r'${= dirty}'});
    expect(jsonEncode(dlg['actions']), contains('"type":"backPressed"'));
    expect(jsonEncode(dlg['actions']), contains('"variable":"asked"'));
  });

  test("a component's call takes its root's width rules (w=232 tablet.w=64), unless the call writes its width", () async {
    final files = {
      'design_system.json': jsonEncode({
        'id': 'acme',
        'name': 'Acme',
        'components': ['components/TeamPanel.json'],
      }),
      'components/TeamPanel.json': jsonEncode({
        'schema': 3,
        'id': 'TeamPanel',
        'roots': ['r'],
        'widget': {'type': 'TeamPanel', 'doc': 'A sidebar that is a rail of icons on a tablet.', 'props': <Object?>[]},
        'nodes': {
          'r': {
            'type': 'column',
            'layout': {
              'width': 232,
              'height': {'fill': 0},
            },
            'media': [
              {
                'maxWidth': 1023,
                'patch': {
                  'layout': {'width': 64, 'padding': 8},
                },
              },
              {
                'maxWidth': 699,
                'patch': {'visible': false},
              },
            ],
          },
        },
      }),
    };
    final ds = await DesignSystem.load((ref) async => files[ref]);
    final options = NotationOptions.fromDesignSystem(ds, width: 1440, reflow: false);
    final catalog = ds.catalogOver(standardCatalog);
    final r = _read('Row#window h=fill\n  TeamPanel#nav\n  Column#main grow\n    Text "Main"', options: options, catalog: catalog);
    expect(_node(r, 'nav')['media'], [
      {
        'maxWidth': 1023,
        'patch': {
          'layout': {'width': 64},
        },
      },
      {
        'maxWidth': 699,
        'patch': {'visible': false},
      },
    ]);
    // The call's own width and its own rule win.
    final own = _read('Row#window h=fill\n  TeamPanel#nav w=200 hide=tablet\n  Column#main grow\n    Text "Main"', options: options, catalog: catalog);
    expect(_node(own, 'nav')['media'], [
      {
        'maxWidth': 1023,
        'patch': {
          'visible': false,
          'bind': {'visible': null},
        },
      },
    ]);
  });
}
