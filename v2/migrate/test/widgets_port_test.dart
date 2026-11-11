// v1 features master added to text, values, rows and columns, lists and
// the new widget types: each maps to its v2 field and nothing is left in
// the node's `v1` leftovers.
import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

import 'inputs_test.dart' show page, props;

Map<String, Object?> node(Map<String, Object?> v2, String id) => ((v2['nodes'] as Map)[id] as Map).cast();

/// Unmapped keys reported, apart from editor metadata.
List<String> unmapped(MigrationReport r) =>
    [for (final k in r.unmapped.keys) if (k.split('.').last != 'createdTimestamp') k];

void main() {
  test('rows and columns: squeezeChildren and fillViewport', () {
    final report = MigrationReport();
    final v2 = migrateDocument(page({
      'c': {'type': 'rowColumn', 'rowColumnType': 'column', 'squeezeChildren': false, 'fillViewport': true,
            'isScrollable': true, 'children': []},
      // Not scrolling: fillViewport is inert.
      'r': {'type': 'rowColumn', 'rowColumnType': 'row', 'fillViewport': true, 'children': []},
    }), report: report);
    expect(props(v2, 'c'), containsPair('squeezeChildren', false));
    expect(props(v2, 'c'), containsPair('fillViewport', true));
    expect(props(v2, 'r'), isNot(contains('fillViewport')));
    expect(props(v2, 'r'), isNot(contains('squeezeChildren')));
    expect(unmapped(report), isEmpty);
  });

  group('switch, page view, grid, paints, paths', () {
    test('a switch: thumb shadows and inset', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        's': {
          'type': 'switch',
          'properties': {
            'fillTrack': true,
            'thumbInset': 3,
            'thumbShadows': [{'type': 'dropShadow', 'color': '#33000000', 'radius': 4, 'offset': {'x': 0, 'y': 1}}],
          },
        },
      }), report: report);
      final p = props(v2, 's');
      expect(p['thumbInset'], 3);
      expect(p['thumbShadows'], [{'type': 'dropShadow', 'color': '#33000000', 'offset': [0, 1], 'blurRadius': 4}]);
      expect(unmapped(report), isEmpty);
    });

    test('a page view: page motion', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        'pv': {
          'type': 'pageView',
          'children': ['i'],
          'properties': {'pageMotion': {'rotateY': -50, 'scale': 0.8}},
          // The page shown, from data (a kanban's column tabs).
          'variables': {'indexValue': r'${lanePage}'},
        },
        'i': {'type': 'rectangle', 'parentID': 'pv'},
      }), report: report);
      expect(props(v2, 'pv')['pageMotion'], {'rotateY': -50, 'scale': 0.8});
      expect(node(v2, 'pv')['bind'], {'props.initialPage': r'${lanePage}'});
      expect(unmapped(report), isEmpty);
    });

    test('bindings: a grid column count, gradient stop colors and positions by paint id', () {
      final v2 = migrateDocument(page({
        'g': {
          'type': 'gridView',
          'children': ['i'],
          'properties': {'gridDelegate': {'type': 'fixedCrossAxisCount', 'crossAxisCount': 2}},
          'variables': {'crossAxisCount': r'${bed.cols}'},
        },
        'i': {'type': 'rectangle', 'parentID': 'g'},
        'r': {
          'type': 'rectangle',
          'fills': [
            {'type': 'gradientLinear', 'id': 'g1', 'gradientStops': [
              {'position': 0, 'color': '#000000'}, {'position': 1, 'color': '#FFFFFF'}]},
          ],
          'variables': {
            'fill-g1-stop-0': r'${pal.bg}',
            'fill-g1-stop-position-1': r'${= share}',
            'stroke-paint-s-1-stop-1': r'${c}',
            'foreground-f1-stop-0': r'${c}',
            'fill-stop-position-0': r'${p}',
            'fill-stop-1': r'${c}',
          },
        },
      }));
      Map bind(String id) => node(v2, id)['bind'] as Map;
      expect(bind('g'), {'props.crossAxisCount': r'${bed.cols}'});
      expect(bind('r'), {
        'decoration.fills.g1.stops[0].color': r'${pal.bg}',
        'decoration.fills.g1.stops[1].position': r'${= share}',
        'decoration.strokes.s-1.stops[1].color': r'${c}',
        'decoration.foregroundFills.f1.stops[0].color': r'${c}',
        'decoration.fills[0].stops[0].position': r'${p}',
        'decoration.fills[0].stops[1].color': r'${c}',
      });
    });

    test('a path: per-shape gradients (also gradientUnits: subpath) and shape colors', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        'p': {
          'type': 'path',
          'pathData': 'M0 0 H10 V10 Z',
          'subpathColors': ['#E8762C', 'nope', '#80D9452B'],
          'fills': [
            {'type': 'gradientRadial', 'id': 'a', 'gradientPerSubpath': true, 'gradientStops': [
              {'position': 0, 'color': '#000000'}, {'position': 1, 'color': '#FFFFFF'}]},
            {'type': 'gradientLinear', 'id': 'b', 'gradientUnits': 'subpath', 'gradientStops': [
              {'position': 0, 'color': '#000000'}, {'position': 1, 'color': '#FFFFFF'}]},
          ],
          'variables': {'subpathColors': r'${cells}'},
        },
      }), report: report);
      final p = node(v2, 'p');
      expect((p['props'] as Map)['subpathColors'], ['#FFE8762C', null, '#80D9452B']);
      final fills = (p['decoration'] as Map)['fills'] as List;
      expect([for (final f in fills) f['gradientPerSubpath']], [true, true]);
      expect(p['bind'], {'props.subpathColors': r'${cells}'});
      expect(unmapped(report), isEmpty);
    });
  });

  group('lists', () {
    test('a list: pagination, reorder, sections and swipe actions; their nodes are slots', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        'l': {
          'type': 'listView',
          'children': ['item', 'more', 'done', 'header', 'ph'],
          'properties': {},
          'pagination': {
            'name': 'contacts', 'mode': 'pages', 'source': 'api', 'pageSize': 50, 'apiId': 'a1',
            'parameters': {'p': r'${page.page}'}, 'pullToRefresh': true, 'refreshColor': {'r': 1, 'g': 0, 'b': 0, 'a': 1},
            'loadingNodeId': 'more', 'endNodeId': 'done', 'errorNodeId': 'gone',
          },
          'reorder': {'start': 'longPress', 'group': 'board', 'apply': 'variable', 'placeholder': 'node', 'placeholderNodeId': 'ph'},
          'sections': {'groupBy': 'letter', 'headerNodeId': 'header', 'indexBar': true},
          'swipeActions': {
            'endActions': [{'id': 'delete', 'label': 'Delete'}],
            'startActions': [{'id': 'flag', 'label': 'Flag', 'removes': false, 'background': {'r': 0, 'g': 0, 'b': 1, 'a': 1}}],
            'undoMs': 3000,
          },
          'reactions': [
            {'trigger': {'type': 'refresh'}, 'action': {'type': 'paginate', 'controller': 'contacts', 'command': 'refresh'}},
            {'trigger': {'type': 'swipeAction'}, 'action': {'type': 'paginate', 'controller': 'contacts', 'command': 'goTo', 'page': r'${value}'}},
          ],
        },
        for (final id in ['item', 'more', 'done', 'header', 'ph']) id: {'type': 'rectangle', 'parentID': 'l'},
      }), report: report);
      final l = node(v2, 'l');
      expect(l['children'], ['item']);
      expect(l['slots'], {'loading': 'more', 'end': 'done', 'sectionHeader': 'header', 'reorderPlaceholder': 'ph'});
      final p = l['props'] as Map;
      expect(p['pagination'], {
        'name': 'contacts', 'mode': 'pages', 'source': 'api', 'pageSize': 50, 'apiId': 'a1',
        'parameters': {'p': r'${page.page}'}, 'pullToRefresh': true, 'refreshColor': '#FFFF0000',
      });
      expect(p['reorder'], {'start': 'longPress', 'group': 'board', 'placeholder': 'node', 'apply': 'variable'});
      expect(p['sections'], {'groupBy': 'letter', 'indexBar': true});
      expect(p['swipeActions'], {
        'startActions': [{'id': 'flag', 'label': 'Flag', 'background': '#FF0000FF', 'removes': false}],
        'endActions': [{'id': 'delete', 'label': 'Delete'}],
        'undoMs': 3000,
      });
      final reactions = l['actions'] as List;
      expect([for (final r in reactions) (r['trigger'] as Map)['type']], ['refresh', 'swipeAction']);
      expect((reactions[0]['actions'] as List).single, {'type': 'paginate', 'controller': 'contacts', 'command': 'refresh'});
      expect((reactions[1]['actions'] as List).single,
          {'type': 'paginate', 'controller': 'contacts', 'command': 'goTo', 'page': r'${value}'});
      expect(unmapped(report), isEmpty);
    });

    test('a grid: pagination and reorder', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        'g': {
          'type': 'gridView',
          'children': ['i', 'more'],
          'properties': {'gridDelegate': {'type': 'fixedCrossAxisCount', 'crossAxisCount': 3}},
          'pagination': {'name': 'photos', 'loadingNodeId': 'more'},
          'reorder': {'enabled': false},
        },
        'i': {'type': 'rectangle', 'parentID': 'g'},
        'more': {'type': 'rectangle', 'parentID': 'g'},
      }), report: report);
      final g = node(v2, 'g');
      expect(g['children'], ['i']);
      expect(g['slots'], {'loading': 'more'});
      expect((g['props'] as Map)['pagination'], {'name': 'photos'});
      expect((g['props'] as Map)['reorder'], {'enabled': false});
      expect(unmapped(report), isEmpty);
    });

    test('a list saved with overlay is a positional stack', () {
      final v2 = migrateDocument(page({
        'l': {'type': 'listView', 'children': ['i'], 'properties': {'overlay': true}},
        'i': {'type': 'rectangle', 'parentID': 'l'},
      }));
      expect(props(v2, 'l')['layout'], 'stack');
    });
  });

  group('new widget types', () {
    test('a pagination node', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        'p': {
          'type': 'pagination',
          'controller': 'contacts',
          'properties': {'showPageSize': true, 'siblingCount': 2, 'alignment': 'center',
                         'activeColor': {'r': 1, 'g': 0, 'b': 0, 'a': 1}},
        },
      }), report: report);
      final p = node(v2, 'p');
      expect(p['type'], 'pagination');
      expect(p['props'], {
        'controller': 'contacts', 'siblingCount': 2, 'showPageSize': true, 'alignment': 'center',
        'activeColor': '#FFFF0000',
      });
      expect(unmapped(report), isEmpty);
    });

    test('a table view: its cell templates are slots, its data binds', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        't': {
          'type': 'tableView',
          'children': ['cell', 'head', 'extra'],
          'clipsContent': false,
          'properties': {
            'columns': [{'key': 'name', 'label': 'Name', 'width': 200}, {'key': 'age'}],
            'cellNodeId': 'cell', 'columnHeaderNodeId': 'head', 'rowHeight': 32, 'stripeColor': {'r': 0, 'g': 0, 'b': 0, 'a': 1},
          },
          'variables': {'data': r'${people}', 'columns': r'${cols}'},
        },
        for (final id in ['cell', 'head', 'extra']) id: {'type': 'rectangle', 'parentID': 't'},
      }), report: report);
      final t = node(v2, 't');
      expect(t['type'], 'tableView');
      expect(t['slots'], {'cell': 'cell', 'columnHeader': 'head'});
      expect(t['children'], ['extra']);
      expect(t['props'], {
        'columns': [{'key': 'name', 'label': 'Name', 'width': 200}, {'key': 'age'}],
        'rowHeight': 32, 'stripeColor': '#FF000000', 'clipBehavior': 'none',
      });
      expect(t['bind'], {'data': r'${people}', 'props.columns': r'${cols}'});
      expect(unmapped(report), isEmpty);
    });
  });

  group('text and values', () {
    test('font features, leading distribution and unit spellings', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        't': {
          'type': 'text',
          'data': 'Hi 10',
          'fontFeatures': 'lnum, liga=0',
          'tabularFigures': true,
          'textMixedProps': [
            {'start': 0, 'end': 5, 'fontSize': 20, 'fontName': {'family': 'Inter'},
             'lineHeight': {'value': 150, 'unit': 'Percent', 'leadingDistribution': 'even'},
             'letterSpacing': {'value': 10, 'unit': '%'}},
          ],
        },
      }), report: report);
      final p = props(v2, 't');
      expect(p['style'], {'tabularFigures': true, 'fontFeatures': ['lnum', 'liga=0']});
      final style = (p['runs'] as List).single['style'] as Map;
      expect(style['height'], 1.5);
      expect(style['leadingDistribution'], 'even');
      expect(style['letterSpacing'], 2);
      expect(unmapped(report), isEmpty);
    });

    test('input decoration: icon padding, always-visible affixes, padding with the border', () {
      final report = MigrationReport();
      final v2 = migrateDocument(page({
        'f': {
          'type': 'textField',
          'properties': {
            'decoration': {
              'suffixText': 'kWh',
              'affixesAlwaysVisible': true,
              'paddingIncludesBorder': true,
              'prefixIconPadding': [12, 0, 8, 0],
              'suffixIconPadding': [4, 4, 4, 4],
            },
          },
        },
      }), report: report);
      final d = props(v2, 'f')['decoration'] as Map;
      expect(d['affixesAlwaysVisible'], true);
      expect(d['paddingIncludesBorder'], true);
      expect(d['prefixIconPadding'], [12, 0, 8, 0]);
      expect(d['suffixIconPadding'], 4);
      expect(unmapped(report), isEmpty);
    });

    test('an icon image given as imageUrl', () {
      final v2 = migrateDocument(page({
        'i': {
          'type': 'icon',
          'properties': {'icon': {'type': 'image', 'imageUrl': 'https://x/i.png', 'show': true}},
        },
      }));
      expect((props(v2, 'i')['icon'] as Map)['image'], 'https://x/i.png');
    });
  });
}
